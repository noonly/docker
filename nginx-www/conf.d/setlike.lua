function islikes(sessionid,messageid)
	local ret = false
	if sessionid ~= nil and messageid ~= nil then

		local userid = string.sub(sessionid,0,16).."__";
		local replykey = userid..messageid
		local redis = require "resty.redis"
        	local cache = redis.new()
        	cache:set_timeout(1000)
        	cache.connect(cache, '172.17.0.4', '6379')

	        cache:get_reused_times()
		local res = cache:exists(replykey)
		if tonumber(res) == 1 then
			cache:set_keepalive(10000, 100)
			return true
		end

		cache:set_keepalive(10000, 100)

		return false


	end
end

ngx.say(islikes(ngx.var.cookie_NOONLYSESSION,ngx.var.arg_msgid))
