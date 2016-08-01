local random = ngx.var.cookie_NOONLY_KEY
if (random == nil) then
    return ngx.redirect("/auth_token?url=" .. ngx.var.request_uri)
end
local token = ngx.md5("Ntoken" .. random .. ngx.var.remote_addr .. random)
if (ngx.var.cookie_NOONLY_ACCESS ~= token) then
    return ngx.redirect("/auth_token?url=".. ngx.var.request_uri)
end
if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local redis = require "resty.redis"
        local cache = redis.new()
        cache.connect(cache, '192.168.4.193', '6379')
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if res~=ngx.null then
                return  ngx.redirect("/admin/index.html")
        end
end
return  ngx.redirect("/admin/login.html")
