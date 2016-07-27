local random = ngx.var.cookie_NOONLY_KEY
if (random == nil) then
    return ngx.redirect("/auth_token?url=" .. ngx.var.request_uri)
end
local token = ngx.md5("Ntoken" .. random .. ngx.var.remote_addr .. random)
if (ngx.var.cookie_NOONLY_ACCESS ~= token) then
    return ngx.redirect("/auth_token?url=".. ngx.var.request_uri)
end

