if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, '172.17.0.3', '6379')

        cache:get_reused_times()
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if res~=ngx.null then
                local device = ngx.req.get_headers()["user-agent"]
                if string.find(device,'iPhone') or string.find(device,'Android') then
                        cache:expire(ngx.var.cookie_NOONLYSESSION,"604800")
                else
                if type(res) == "string" then
                        local cjson = require "cjson"
                        local obj = cjson.decode(res)

                        if obj.stdid ~= nil then
                                cache:expire(obj.stdid,"1300")
                        end
                        cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")

                end
                end
        end
        cache:set_keepalive(10000, 100)
end
