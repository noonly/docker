local request_method = ngx.var.request_method
local args = nil

if "GET" == request_method then
    args = ngx.req.get_uri_args()
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

ngx.log(ngx.ERR, args['pn'])
if args == nil then
	--ngx.log(ngx.ERR,ngx.var.args)
        ngx.exit(404)
        return
end
local key = "hotnews_pr"..args['pr'].."pn"..args['pn'];
local redis = require "resty.redis"
local cache = redis.new()
cache:set_timeout(1000)
cache.connect(cache, '172.17.0.4', '6379')
--cache.set_timeout(1000)

cache:get_reused_times()
local res = cache:get(key)
--if res == "sdsd" then
if res~=ngx.null then
        ngx.say(res)
--	ngx.log(ngx.ERR,"res~=ngx.null")
        cache:set_keepalive(10000, 100)
       	return
end



local resp = ngx.location.capture("/javahotnews/hotnews", {
    method = ngx.HTTP_GET,
    args = {pr=args['pr'],pn=args['pn']}
})

if resp.status == ngx.HTTP_OK then
	cache:set(key,resp.body)
	cache:expire(key,1400)
end
cache:set_keepalive(10000, 100)
ngx.say(resp.body)

--ngx.log(ngx.ERR,tostring(resp))
