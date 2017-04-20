local request_method = ngx.var.request_method
local args = nil

if "GET" == request_method then
    args = ngx.req.get_uri_args()
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end	
--ngx.say(args.replyid)
if ngx.var.cookie_NOONLYSESSION ~= nil and args.replyid ~= nil and string.len(args.replyid) > 1 then
	local userid = string.sub(ngx.var.cookie_NOONLYSESSION,0,16).."__"..args.replyid;
	local redis = require "resty.redis"
       	local cache = redis.new()
       	cache:set_timeout(1000)
       	cache.connect(cache, 'redis-master.service.dc1.consul', '6379')

        cache:get_reused_times()
	ngx.req.set_header("user", cache:get(ngx.var.cookie_NOONLYSESSION))
	local resp = nil
	res = cache:exists(userid)
	if tonumber(res) == 1 then
		resp = ngx.location.capture("/appMessage/Clike?replyid=".. args.replyid)
                cache:del(userid)
                cache:set(userid.."_","")
                cache:expire(userid.."_",600)
	else
		cache:set(userid,"")
		if cache:exists(userid.."_") == 0 then
			--ngx.say("add"..userid)
			resp = ngx.location.capture("/appMessage/Ilike?notify=true&replyid=".. args.replyid)
		else
			resp = ngx.location.capture("/appMessage/Ilike?notify=false&replyid=".. args.replyid)
		end
	end

	ngx.say(resp.body)
	cache:set_keepalive(10000, 100)
else
	ngx.say("{\"status\":\"0\"}")
	ngx.exit(401)
end


--ngx.say(islikes(ngx.var.cookie_NOONLYSESSION,ngx.var.arg_msgid))
