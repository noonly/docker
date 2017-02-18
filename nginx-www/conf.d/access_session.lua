uri = {"/Login/displayCode","/indexController/nAppLogin","/indexController/bindCode","/indexController/telCode","/indexController/nAppBind","/zuxia/app/sarticle.html","/Payment/status","/m/course/course.html","/m/index.html","/zuxia/single.html","/Medias/typesuBset","/visit/login.html","/appMessage/addMessageRead","/indexController/weiBoLogin","/afterLoginController/weiBoLogin","/public/zuxiaketang.apk","/Weekly/lectureList","/public/zuxiaketang.exe","/Weekly/groupList","/Weekly/followMediaInfoUserList","/Weekly/followMediaInfo","/zuxia/app/subscribe.html","/appMessage/WebRdcircle","/zuxia/moment.html","/zuxia/down.html","/afterLoginController/afterLogin","/appMessage/QueryMedia","/appMessage/QueryOneMeadia","/appMessage/QueryLikesAndReplys","/appMessage/htCircle","/zuxia/cinfo.html","/zuxia/schedule.html","/Question/appNotIntercepor/practice","/public/zuxiaketang.apk","/zuxia/forget.html","/indexController/appWBLogin","/Login/outRegster","/appMessage/QueryMessage","/appMessage/QueryReplayOrLike","/indexController/login","/indexController/appQQLogin","/appMessage/LiveList","/Medias/aboutHot","/Login/appQQLogin","/Login/displayAvatar","/appMessage/QueryCircleMsg","/appMessage/QueryCircleTopMsg","/appMessage/OneCircle","/myprofile","/zuxia/exam.html","/Login/regster","/admin/register.html","/appMessage/hotnews","/appMessage/QueryCircleMsg","/appMessage/rdcircle","/zuxia/member.html","/zuxia/app.html","/zuxia/play.html","/Medias/response","/Medias/typeInfo","/Medias/type","/Medias/limitType","/zuxia/video.html","/zuxia/circle.html","/zuxia/index.html","/Login/web","/admin/login.html","/Back/BackOne","/Back/BackTwo","/Back/BackThree","/Back/BackFour"}



function allow_url(status)
        for i,v in ipairs(uri) do
                if (ngx.var.uri == v) then
                        return
                end
        end
--	ngx.redirect('/',status)
        ngx.exit(status)
end
if (ngx.var.cookie_NOONLYSESSION ~= nil) then
        local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, '172.17.0.4', '6379')
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
                allow_url(401)
        end
        cache:set_keepalive(10000, 100)
        --cache:close()
        --cache:set_keepalive(10000, 100)
else
        allow_url(401)
end
