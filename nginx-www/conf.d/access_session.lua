uri = {"/myprofile","/zuxia/exam.html","/Login/regster","/admin/register.html","/appMessage/hotnews","/appMessage/QueryCircleMsg","/appMessage/rdcircle","/zuxia/member.html","/zuxia/app.html","/zuxia/play.html","/Video/response","/Video/typeInfo","/Video/type","/Video/limitType","/zuxia/video.html","/zuxia/circle.html","/zuxia/index.html","/Login/web","/admin/login.html","/Back/BackOne","/Back/BackTwo","/Back/BackThree","/Back/BackFour"} 
for i,v in ipairs(uri) do 
	if (ngx.var.uri == v) then
		return
	end
end 
if (ngx.var.cookie_NOONLYSESSION ~= nil) then
	local redis = require "resty.redis"
	local cache = redis.new()
	cache:set_timeout(1000)
	cache.connect(cache, '192.168.4.193', '6379')
	--cache.set_timeout(1000)
	
	cache:get_reused_times()
	local res = cache:get(ngx.var.cookie_NOONLYSESSION)
	if res~=ngx.null then
		cache:expire(ngx.var.cookie_NOONLYSESSION,"1200")
		ngx.req.set_header("user", res)
		--cache:close()
		--return
	else
		ngx.exit(403)
	end
	cache:set_keepalive(10000, 100)
	--cache:close()
	--cache:set_keepalive(10000, 100)
else
	ngx.exit(403)
end
