local random = ngx.var.cookie_NOONLY_KEY
if (random == nil) or (ngx.var.cookie_NOONLY_ACCESS ~= ngx.md5("Ntoken" .. random .. "NT123456NT" .. random)) then
        local random = ngx.var.cookie_NOONLY_KEY
        if (random == nil) then
                random = ngx.md5(math.random(9999) .. os.time() .. math.random(9999) .. ngx.var.remote_addr)
        end
        local token = ngx.md5("Ntoken" .. random .. "NT123456NT" .. random)
        if (ngx.var.cookie_NOONLY_ACCESS ~= token) then
                ngx.header["Set-Cookie"] = {"NOONLY_ACCESS=" .. token.."; path=/", "NOONLY_KEY=" .. random.."; path=/"}
        end

end
