local redis = require "resty.redis"
local cache = redis.new()
cache.connect(cache, '192.168.4.193', '6379')
local res = cache:get(ngx.var.cookie_NOONLYSESSION)
if res==ngx.null then
    ngx.say("This is Null")
    return
end
cache:expire(ngx.var.cookie_NOONLYSESSION,"600")
ngx.say(res)
cache:close()
