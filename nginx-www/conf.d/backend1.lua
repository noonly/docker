if ngx.var.arg_callback == nil then
	ngx.exit(502)
        return
        --rewrite /wap/(\d+)/(.+) /$2?$args break;
end

local expire = 1400

if ngx.var.arg_expire ~= nil then
	expire = ngx.var.arg_expire
end

local request_method = ngx.var.request_method
local args = nil

if "GET" == request_method then
    args = ngx.req.get_uri_args()
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

if args == nil then
	--ngx.log(ngx.ERR,ngx.var.args)
        ngx.exit(404)
        return
end

local source = ""
for k, v in pairs(args) do
	if source == "" then
		source = k.."="..v
	else
		source = source .."&"..k.."="..v
	end
end
--ngx.log(ngx.ERR,ngx.var.uri.."?"..source)
local key = ngx.var.uri..source;
local redis = require "resty.redis"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, 'redis-master.service.dc1.consul', '6379')
--cache.set_timeout(1000)

cache:get_reused_times()
local res = cache:get(key)
--if res == "sdsd" then
if res==ngx.null then

	if source then
		source = "?"..source
	end
	local resp = ngx.location.capture(ngx.var.arg_callback..source)

	if resp.status == ngx.HTTP_OK then
		res = resp.body
        	cache:set(key,res)
       		cache:expire(key,expire)
	end

end
if ngx.var.cookie_NOONLYSESSION ~= nil then
	local cjson = require "cjson"
	local body = cjson.decode(res)
 
	local userid = string.sub(ngx.var.cookie_NOONLYSESSION,0,16);
	for _,v in pairs(body.message) do 
		if cache:exists(userid.."__"..v.id) == 1 then
			v.islike = "true"
		end
	end
	res = cjson.encode(body) 
end
ngx.say(res)

cache:set_keepalive(10000, 100)

