		local redis = require "resty.redis"
		local cjson = require "cjson"
                local cache = redis.new()
                cache:set_timeout(1000)
                cache.connect(cache, '172.17.0.4', '6379')

                cache:get_reused_times()
		--ngx.say(table.getn(cache:keys("*_*")))
		--ngx.say(table.getn(cache:keys("share_*")))
		--ngx.say(table.getn(cache:keys("like_*")))
		--ngx.say(table.getn(cache:keys("reply_*")))

		local res = cache:keys("share_43EFCCF658C3B8D1_*")
		for k,v in pairs(res) do
			if k < 10 then
			local l = cjson.decode(cache:get(v))
			l.like = table.getn(cache:keys("like_*_*_*_"..l.id))

			ngx.say(cjson.encode(l))
			end
		end
		

		cache:set_keepalive(10000, 100)


