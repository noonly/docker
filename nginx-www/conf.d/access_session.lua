uri = {"/Login/web","Wednesday","Thursday","Friday","Saturday"  
}  
for i,v in ipairs(uri) do 
if (ngx.var.uri == v) then
	return
end
end 
if (ngx.var.cookie_NOONLYSESSION ~= nil) then
	local redis = require "resty.redis"
	local cache = redis.new()
	cache.connect(cache, '192.168.4.193', '6379')
	local res = cache:get(ngx.var.cookie_NOONLYSESSION)
	if res~=ngx.null then
		cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")
		ngx.req.set_header("user", res)
		cache:close()
		return
	end
end
return ngx.redirect("/")
