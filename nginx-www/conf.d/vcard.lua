if ngx.var.arg_key == nil then
	ngx.exit(404)
	return
end

local key = "Avatar"..ngx.var.arg_key;
local redis = require "resty.redis"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, '172.17.0.4', '6379')
--cache.set_timeout(1000)

cache:get_reused_times()
local res = cache:get(key)
--if res == "sdsd" then
if res~=ngx.null then
        ngx.say(res)
--	ngx.log(ngx.ERR,"res~=ngx.null")
        cache:set_keepalive(10000, 100)
       	return
end



local resp = ngx.location.capture("/java/userAvatar", {
    method = ngx.HTTP_GET,
    args = {key=ngx.var.arg_key}
})

if resp.status == ngx.HTTP_OK then
	cache:set(key,resp.body)
	cache:expire(key,1400)
end
cache:set_keepalive(10000, 100)
ngx.say(resp.body)

--ngx.log(ngx.ERR,tostring(resp))
