uri = {"/public/zuxiaketang.apk","/zuxia/forget.html","/indexController/appWBLogin","/Login/outRegster","/appMessage/QueryMessage","/appMessage/QueryReplayOrLike","/indexController/login","/indexController/appQQLogin","/appMessage/LiveList","/Medias/aboutHot","/Login/appQQLogin","/Login/displayAvatar","/appMessage/QueryCircleMsg","/appMessage/QueryCircleTopMsg","/appMessage/OneCircle","/myprofile","/zuxia/exam.html","/Login/regster","/admin/register.html","/appMessage/hotnews","/appMessage/QueryCircleMsg","/appMessage/rdcircle","/zuxia/member.html","/zuxia/app.html","/zuxia/play.html","/Medias/response","/Medias/typeInfo","/Medias/type","/Medias/limitType","/zuxia/video.html","/zuxia/circle.html","/zuxia/index.html","/Login/web","/admin/login.html","/Back/BackOne","/Back/BackTwo","/Back/BackThree","/Back/BackFour"}

function allow_url(status)
        for i,v in ipairs(uri) do
                if (ngx.var.uri == v) then
                        return
                end
        end
        ngx.exit(status)
end
if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, '172.17.0.3', '6379')
        --cache.set_timeout(1000)

        cache:get_reused_times()
        local res = cache:get(ngx.var.cookie_NOONLYSESSION)
        if res~=ngx.null then
		
		if type(res) == "string" then
			local cjson = require "cjson"
                	local obj = cjson.decode(res)
			if obj.stdid ~= nil then
                		cache:expire(obj.stdid,"1300")
			end
			cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")
	                ngx.req.set_header("user", res)

	        end


                --cache:close()
                --return
        else
                cache:set_keepalive(10000, 100)
                allow_url(401)
        end
        cache:set_keepalive(10000, 100)
        --cache:close()
        --cache:set_keepalive(10000, 100)
else
        allow_url(401)
end

