local redis = require "resty.redis"
local cache = redis.new()
cache.connect(cache, '172.17.0.3', '6379')
local res = cache:get(ngx.var.cookie_NOONLYSESSION)
cache:set_timeout(1000)
if res~=ngx.null then
cache:expire(ngx.var.cookie_NOONLYSESSION,"600")
ngx.say(res)
else
ngx.say("NULL")
end
cache:set_keepalive(10000, 100)
--cache:close()

