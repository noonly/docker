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
if res~=ngx.null then
        ngx.say(res)
--      ngx.log(ngx.ERR,"res~=ngx.null")
        cache:set_keepalive(10000, 100)
        return
end

if source then
	source = "?"..source
end
local resp = ngx.location.capture(ngx.var.arg_callback..source)

if resp.status == ngx.HTTP_OK then
        cache:set(key,resp.body)
        cache:expire(key,expire)
end
cache:set_keepalive(10000, 100)
ngx.say(resp.body)
