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
	local head = "likes:"..string.sub(ngx.var.cookie_NOONLYSESSION,0,16)
	--local history = head.."_"..args.replyid;
	--ngx.req.set_header("user", cache:get(ngx.var.cookie_NOONLYSESSION))
	local redis = require("resty.rediscli")

	local red = redis.new()

	local res = red:exec(
        	function(red)
            	return red:sadd(head,args.replyid)
        	end
	)


	local header = red:exec(
                        function(red)
                                return red:get(ngx.var.cookie_NOONLYSESSION)
                        end
                )


	ngx.req.set_header("user",header)

	if res == 0 then
		red:exec(
                	function(red)
                		red:srem(head,args.replyid)
                	end
        	)

		resp = ngx.location.capture("/appMessage/Clike?replyid=".. args.replyid)
	else
		resp = ngx.location.capture("/appMessage/Ilike?notify=true&replyid=".. args.replyid)
		--cache:set(userid,"")
		--[[if cache:exists(history) == 0 then
			--ngx.say("add"..userid)
			resp = ngx.location.capture("/appMessage/Ilike?notify=true&replyid=".. args.replyid)
		else
			resp = ngx.location.capture("/appMessage/Ilike?notify=false&replyid=".. args.replyid)
		end]]
	end

	ngx.say(resp.body)
else
	ngx.say("{\"status\":\"0\"}")
	ngx.exit(401)
end


--ngx.say(islikes(ngx.var.cookie_NOONLYSESSION,ngx.var.arg_msgid))
