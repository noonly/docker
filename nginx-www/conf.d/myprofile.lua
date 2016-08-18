local redis = require "resty.redis"
local cjson = require "cjson"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, '192.168.4.193', '6379')
--cache.set_timeout(1000)

cache:get_reused_times()

if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if res~=ngx.null then
                cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")
		local obj = cjson.decode(res)
		res = cache:get(obj.stdid)
		cache:expire(obj.stdid,"12000")
		ngx.say(res) 
        else
                ngx.exit(500)
        end
else
	
        local stdid = ngx.var.arg_stdid
	local profile = cache:get(stdid)
        if profile~=ngx.null then
                cache:expire(stdid,"12000")
                ngx.say(profile)
        else
                ngx.exit(503)
        end

end
cache:set_keepalive(10000, 100)
