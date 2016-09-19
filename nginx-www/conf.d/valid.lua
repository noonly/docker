if ngx.var.arg_username == nil then
	ngx.say("{\"status\":\"-10\",\"msg\":\"username does not null\"}")
	ngx.exit(200)
end
if ngx.var.arg_type ~= "sign" and ngx.var.arg_type ~= "auth" and ngx.var.arg_type ~= "forgot" then
	ngx.say("{\"status\":\"-9\",\"msg\":\"type unknow\"}")
        ngx.exit(200)
end
local pass = 0
local codeuser = ngx.var.arg_flag .. "code_" .. ngx.var.arg_username
local timesuser = ngx.var.arg_flag .. "times_" .. ngx.var.arg_username
local redis = require "resty.redis"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, '172.17.0.3', '6379')
--cache.set_timeout(1000)
cache:get_reused_times()
local usercode = cache:get(codeuser)
local usertimes = cache:get(timesuser)

if ngx.var.arg_type == "auth" then
	--send code
	if  usertimes == ngx.null then
		math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		local code = math.random(899999)+100000
 	       	cache:set(codeuser,code)
        	cache:expire(codeuser,"1800")
       	 	cache:set(timesuser,0)
        	cache:expire(timesuser,"60")
		ngx.var.arg_c = "vcode="..code
		pass = 1
        	--ngx.say("{\"status\":\"1\",\"msg\":\"valid code was sent\"}")
	else
		ngx.say("{\"status\":\"-11\",\"msg\":\"can not send frequent vcode\"}")
	end
else
if ngx.var.arg_code == nil then
                ngx.say("{\"status\":\"-2\",\"msg\":\"code wrong\"}")
else 
if usercode ~= ngx.null then
	if usertimes == ngx.null then
		usertimes = 1
		cache:set(timesuser,1)
		cache:expire(timesuser,"60")
	else
		usertimes = usertimes+1
		cache:set(timesuser,usertimes)
		cache:expire(timesuser,"60")
	end 

	if usertimes > 3 then
                ngx.say("{\"status\":\"-3\",\"msg\":\"valid code try failed\"}")
        else

	if ngx.var.arg_code == nil or ngx.var.arg_code ~= usercode then
		ngx.say("{\"status\":\"-5\",\"msg\":\"valid code wrong\"}")
	else
		cache:expire(codeuser,"5")
		pass = 1
	end
	end
else
	if ngx.var.arg_code ~= nil then
		ngx.say("{\"status\":\"-4\",\"msg\":\"valid code expired\"}")
	else
		ngx.say("{\"status\":\"-1\",\"msg\":\"invalidate args\"}")
	end
end
end
end
cache:set_keepalive(10000, 100)
if pass == 0 then
	ngx.exit(200)
end
