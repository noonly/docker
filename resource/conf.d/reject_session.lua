local redis = require "resty.redis"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, '172.17.0.3', '6379')
--cache.set_timeout(1000)

cache:get_reused_times()

if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if type(res) == "string" then
                cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")
                local obj = cjson.decode(res)
                res = cache:get(obj.stdid)
                --cache:expire(obj.stdid,"12000")
                ngx.say(res)
        end

end
cache:set_keepalive(10000, 100)
ngx.exit(200)
