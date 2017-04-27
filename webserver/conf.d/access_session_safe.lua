
if (ngx.var.cookie_NOONLYSESSION ~= nil and string.len(ngx.var.cookie_NOONLYSESSION)>0) then
        local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, 'redis-master.service.dc1.consul', '6379')
        --cache.set_timeout(1000)

        cache:get_reused_times()
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if res~=ngx.null then
		local device = ngx.req.get_headers()["user-agent"]
		if string.find(device,'iPhone') or string.find(device,'Android') then
			cache:expire(ngx.var.cookie_NOONLYSESSION,"604800")
        --		ngx.log(ngx.ERR,"iphone")
	--		ngx.req.set_header("user", res)
		else	
		if type(res) == "string" then
			local cjson = require "cjson"
                	local obj = cjson.decode(res)

			if obj.stdid ~= nil then
                		cache:expire(obj.stdid,"1300")
			end
			cache:expire(ngx.var.cookie_NOONLYSESSION,"2400")
	                --ngx.req.set_header("user", res)

	        end
		end
		ngx.req.set_header("user", res)
                --cache:close()
                --return
        else
                cache:set_keepalive(10000, 100)
                ngx.exit(401)
        end
        cache:set_keepalive(10000, 100)
        --cache:close()
        --cache:set_keepalive(10000, 100)
else
        ngx.exit(401)
end
