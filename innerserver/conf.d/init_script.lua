local user = nil
if ngx.var.cookie_NOONLYSESSION ~= nil then

        user = string.sub(ngx.var.cookie_NOONLYSESSION,0,16)

--	if user ~= "111" then
--		ngx.exit(403)
--	end
--	ngx.say("RIGHT")
else

	ngx.exit(401)
end

local lua = [[
	local r = {}
	local len = 10
	local pos = tonumber(KEYS[2])
	if pos ~= 0 then
		r.pos = pos - len
		pos = redis.call("LLEN","circle:"..KEYS[1]) - pos 
	else
		local count = redis.call("LLEN","circle:"..KEYS[1]) --redis.call("HGET","mgroup:"..KEYS[1],"allcount")
		if KEYS[3] ~= nil then
			redis.call("set","unread:"..KEYS[3]..":"..KEYS[1],count)
		end
		r.pos = count - len
	end
	local msgids = redis.call("LRANGE","circle:"..KEYS[1],pos,len-1+ pos)
	local bulk
	local result = {}
	local res
	local nextkey
	for k,id in pairs(msgids) do
		res = {}
		bulk = redis.call('HGETALL',id)
		res['id'] = id
		for i, v in ipairs(bulk) do
			if i % 2 == 1 then
				nextkey = v
			else
				res[nextkey] = v
			end
		end
		if res['username'] ~= nil then
			bulk = redis.call('HGETALL',res['username'])
			if table.getn(bulk) ~= 0 then
				for i, v in ipairs(bulk) do
                	      		if i % 2 == 1 then
                                		nextkey = v
                        		else
                                		res[nextkey] = v
                        		end
                		end
			end
			--res["vcard"] = "/Login/userAvatar?key="..res['username']
		end
		if KEYS[3] ~= nil and redis.call("SISMEMBER","likes:"..KEYS[3],id) == 1 then
			res["islike"] = "true"
		else
			res["islike"] = "false"
		end
		result[k] = res
	end
	r.message = result
	return cjson.encode(r)
]]

local addpic = [[

	local src = redis.call("HGET",KEYS[1],"pic")
	if type(src) == "string" and string.len(src) > 10 then
		redis.call("HSET",KEYS[1],"pic",src..","..KEYS[2])
	else
		redis.call("HSET",KEYS[1],"pic",KEYS[2])
	end

]]

local mgroup = [[
	local result = {}
	local res = {}
	local r = {}
	if KEYS[1] ~= nil then
		result['countnew'] = 0
		result.status = 1
		local bulk
		local nextkey
		if redis.call("SCARD","usermgroup:"..KEYS[1]) > 0 then
			local all = redis.call("smembers","usermgroup:"..KEYS[1])
			local t = {}
			for k,v in pairs(all) do
				r = {}
				if redis.call("exists","mgroup:"..v) == 1 and redis.call("hget","mgroup:"..v,"id") == v then
					bulk = redis.call('HGETALL',"mgroup:"..v)
                			for i, v in ipairs(bulk) do
                        			if i % 2 == 1 then
                               		 		nextkey = v
                       				else
                        	        		r[nextkey] = v
                      		  		end
                			end
					bulk = redis.call("get","unread:"..KEYS[1]..":"..v)
					if bulk then
						r.noreadcount = tonumber(r.allcount) - tonumber(bulk)
					else
						r.noreadcount = tonumber(r.allcount)
					end
					r.isadd = true
					if r.noreadcount > 0 then
                        			table.insert(t,r)
                 	       		else
						table.insert(res,r)
					end
					--res[k] = r
			
				end
			end
			table.sort(res, function(a,b) return tonumber(a.alluser)>tonumber(b.alluser) end )
			for _,v in pairs(t) do
				table.insert(res,1,v)
			end
			--table.sort(res, function(a,b) return ((a.noreadcount == 0 and b.noreadcount == 0) and a.alluser > b.alluser) or (a.noreadcount ~= 0 and b.noreadcount == 0) or ((a.noreadcount ~= 0 and b.noreadcount ~= 0) and a.noreadcount > b.noreadcount) end)
			result['mgroup'] = res
		else
			bulk = redis.call('HGETALL',"mgroup:3")
                        for i, v in ipairs(bulk) do
                        	if i % 2 == 1 then
                                	nextkey = v
                                else
                                	r[nextkey] = v
                                end
                        end
			r.noreadcount = tonumber(r.allcount)
			table.insert(res,r)
			result['mgroup'] = res
		end
	else
		result['countnew'] = 0
                result.status = 1
                local all = redis.call("smembers","usermgroup:43EFCCF658C3B8D1")
                local bulk
                local nextkey
                for k,v in pairs(all) do
			if redis.call("exists","mgroup:"..v) == 1 and redis.call("hget","mgroup:"..v,"id") == v then
                       		r = {}
                        	bulk = redis.call('HGETALL',"mgroup:"..v)
                       		for i, v in ipairs(bulk) do
                                	if i % 2 == 1 then
                                        	nextkey = v
                                	else
                                        	r[nextkey] = v
                                	end
                        	end
				r.noreadcount = 0
				r.isadd = false
                        	res[k] = r
			end
                end
                table.sort(res, function(a,b) return tonumber(a.alluser)>tonumber(b.alluser) end )
                result['mgroup'] = res
		
	end

	return cjson.encode(result)
]]
local cjson = require "cjson"
local redis = require("resty.rediscli")

local red = redis.new()

local r, e = red:exec(
        function(red)
            return red:script("load",lua)
        end
)
ngx.say("message="..r)

r, e = red:exec(
        function(red)
            return red:script("load",addpic)
        end
)
ngx.say("addpic="..r)

r, e = red:exec(
        function(red)
            return red:script("load",mgroup)
        end
)
ngx.say("mgroup="..r)
--ngx.say(pic)
--[[
local res, err = red:exec(
        function(red)
		if user ~= nil then
            		return red:evalsha(r,3,ngx.var.arg_c,ngx.var.arg_pr,user)
		else
			return red:evalsha(r,2,ngx.var.arg_c,ngx.var.arg_pr)
		end
        end
)
--ngx.say(res)
--res.currenttime = os.time()
local r = cjson.decode(res)
r.ct = os.time()
ngx.say(cjson.encode(r))
]]
