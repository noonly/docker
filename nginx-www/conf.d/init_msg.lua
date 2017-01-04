		
if ngx.var.cookie_NOONLYSESSION ~= "we" then
	--return
end

local mysql = require "resty.mysql"
		local db, err = mysql:new()
		local cjson = require "cjson"

		db:set_timeout(1000) -- 1 sec

		local ok, err, errcode, sqlstate = db:connect{
        	            host = "172.17.0.31",
               		     port = 3306,
                    		database = "app_noonly",
                    	user = "root",
                    password = "123456",
		    max_packet_size = 1024 * 1024 }

	--	local _, count = string.gsub(user.username, "[^\128-\193]", "")
	--	ngx.log(ngx.ERR,user.username)
	--	local code = math.random(9)+1
		db:query("SET NAMES utf8")
		local res, err, errcode, sqlstate = db:query("SELECT substring(upper(md5(`username`)),9,16) as user,`id`, `replyid` as pid,`studentmessageroot`.`studentmessageroot` as fid,`messagetype`, `time`, `message`, group_concat(stdmsgpicsid order by `unitkey` asc) pic,gisinfo FROM studentmessage left join studentmessageroot on studentmessageroot.studentmessageid=studentmessage.id left join `studentmessagefrom` on studentmessage.id=studentmessagefrom.messageid left join studentmessagepicture on studentmessage.id=studentmessagepicture.messageid group by studentmessage.id;")

		if res ~= nil and table.getn(res) == 0 then
			db:set_keepalive(10000, 50)
			return
		end
		local redis = require "resty.redis"
                local cache = redis.new()
                cache:set_timeout(1000)
                cache.connect(cache, '172.17.0.4', '6379')

                cache:get_reused_times()
		local key = nil

		for k, v in pairs(res) do      
			--local expire = tonumber(v['expire'])
			--local reply = tostring(v['user']).."__"..tostring(v['replyid'])
			--ngx.say(cjson.encode(v))
			key = v['messagetype'].."_"..v['user']
			if v['id'] ~= ngx.null and v['pid'] ~= ngx.null then
				 key = key.."_"..v['id'].."_"..v['pid']
				if v['fid'] ~= ngx.null then
					key = key.."_"..v['fid']
				else
					key = key.."_"..v['pid']
				end
				cache:set(key,cjson.encode(v))
	--			cache:expire(key,6000)			
			else
	--			ngx.say("error:"..v['id'])
			end
			--cache:set(v['messagetype'].."_"..v['user'].."_"..v['id'].."_"..v['pid'].."_"..v['fid'],cjson.encode(v))
			--cache:expire(v['messagetype'].."_"..v['user'].."_"..v['id'].."_"..v['pid'].."_"..v['fid'],60)
			
		end
		--cache:set(userid,"")
                --cache:expire(userid,86400)


		cache:set_keepalive(10000, 100)


		db:set_keepalive(10000, 50)
