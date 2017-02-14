--if ngx.var.arg_msgid/2 ==0 then

--end

--local resp = ngx.location.capture("/appMessage/addMessageRead", {
--    method = ngx.HTTP_GET,
--    args = {id = ngx.var.arg_msgid}

--})
ngx.var.arg_img = "normal.png"
if ngx.var.arg_msgid ~= nil then

	local cookie = ""
	if ngx.var.cookie_NOONLY_ACCESS ~= nil then
		cookie = ngx.var.cookie_NOONLY_ACCESS
	end
	local key = "hotpoint"..cookie..ngx.var.arg_msgid;
	local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, '172.17.0.4', '6379')
        --cache.set_timeout(1000)

        cache:get_reused_times()
	local res = cache:get(key)
	if res~=ngx.null then
		ngx.var.arg_img = res
		cache:set_keepalive(10000, 100)
		return
	end

	--cache:hincrby(ngx.var.arg_msgid,read,1)
	cache:hincrby(ngx.var.arg_msgid,"read",1)

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

	if not ok then
                  ngx.log(ngx.ERR,"bad result: "..err..": "..errcode)
                  return
          end

	--ngx.log(ngx.ERR,err)
--	local code = math.random(9)+1
	local res, err, errcode, sqlstate = db:query("UPDATE `app_noonly`.`studentmessage` SET `read`=`read`+1 WHERE `id`='"..ngx.var.arg_msgid.."';")
	if not res then
        	ngx.log(ngx.ERR,"bad result: "..err..": ")
		return
	end
	--SELECT `messageType` as type, count(`messageType`) as count  FROM app_noonly.studentmessage where `replyid`='96418235184273709'  and `time` > date_sub(curdate(),interval 7 day) group by `messagetype` ;
--	res, err, errcode, sqlstate = db:query("SELECT `messagetype` as types, count(`messagetype`) as counts  FROM app_noonly.studentmessage where `replyid`='"..ngx.var.arg_msgid.."'  and `time` > date_sub(curdate(),interval 7 day) group by `messagetype`;")
	res, err, errcode, sqlstate = db:query("select types,count(types) as counts from (SELECT `messagetype` as types, username  FROM app_noonly.studentmessage where `replyid`='"..ngx.var.arg_msgid.."'  and `time` > date_sub(curdate(),interval 7 day) group by `username`,`types`) a group by a.types;")
--                if not res then
--                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
--                end

	--res, err, errcode, sqlstate = db:query("SELECT count(*) as c FROM app_noonly.studentmessage where `replyid`='"..ngx.var.arg_msgid.."' and `messageType`='reply' and `time` > date_sub(curdate(),interval 7 day);")

if not res then
	ngx.log(ngx.ERR,"bad result: "..err..": ")--..": "..sqlstate..".")
	return
end
	
--	local count = cjson.encode(res)
--	count = cjson.decode(count)
--	ngx.log(ngx.ERR,sqlstate)
--	ngx.log(ngx.ERR,count[1].types)

	for _, v in pairs(res) do      
--		ngx.log(ngx.ERR,k.."======="..tostring(v['types']))
		local c = tonumber(v['counts'])
  		if tostring(v['types']) == 'like' then
			if c > 10 then
				ngx.var.arg_img = "tuijian.jpg"
				if c > 30 then
        	                        ngx.var.arg_img = "remen.jpg"
	                        end
			end
		else if tostring(v['types']) == 'reply' then
			if c > 10 then
                                ngx.var.arg_img = "reyi.jpg"
				break
                        end
		end
		end 		  
	end

--	if tonumber(count[1].c) > 10 then
--		ngx.var.arg_img = "reyi.jpg"
--	end
	

	ok, err = db:set_keepalive(10000, 50)
    	if not ok then
        	ngx.log(ngx.ERR, "failed to set keepalive: ", err)
        	ngx.exit(500)
    	end

	cache:set(key,ngx.var.arg_img)
	cache:expire(key,math.random(120)+60)
        cache:set_keepalive(10000, 100)

end
if ngx.var.arg_img == "" then
	--ngx.exit(200)
	ngx.var.arg_img = "normal.png"
end
--ngx.var.arg_img = "reyi.jpg"
