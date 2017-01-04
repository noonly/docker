		
if ngx.var.cookie_NOONLYSESSION ~= "we" then
	return
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
		local res, err, errcode, sqlstate = db:query("SELECT substring(upper(md5(`username`)),9,16) as user, `replyid` FROM app_noonly.studentmessage where `messagetype`='like';")

		if table.getn(res) == 0 then
			db:set_keepalive(10000, 50)
			return
		end
		local redis = require "resty.redis"
                local cache = redis.new()
                cache:set_timeout(1000)
                cache.connect(cache, '172.17.0.4', '6379')

                cache:get_reused_times()

		for k, v in pairs(res) do      
			local expire = tonumber(v['expire'])
			local reply = tostring(v['user']).."__"..tostring(v['replyid'])

			cache:set(reply,"")
			--cache:expire(reply,tonumber(v['expire']))
			
		end
		--cache:set(userid,"")
                --cache:expire(userid,86400)


		cache:set_keepalive(10000, 100)


		db:set_keepalive(10000, 50)
