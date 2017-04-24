local user = nil
if (ngx.var.cookie_NOONLYSESSION ~= nil) then

        user = string.sub(ngx.var.cookie_NOONLYSESSION,0,16)

else

--	ngx.exit(401)
end

local cjson = require "cjson"
local redis = require("resty.rediscli")

local red = redis.new()

local r 
--r = "084afb1d87aa3998aecb8b78458c8d9cd2024e5d"
r="086c8b2d670d4545d29ebba8c1f7a8f89baace8f"
--r = "7fa762ba8eb5b13e689034dc3ee35f6f9aba0635"
local res, err = red:exec(
        function(red)
		if user ~= nil then
            		return red:evalsha(r,3,ngx.var.arg_c,ngx.var.arg_pr,user)
		else
			return red:evalsha(r,2,ngx.var.arg_c,ngx.var.arg_pr)
		end
        end
)
--ngx.say(res)
--res.currenttime = os.time()
local r = cjson.decode(res)
r.ct = os.time()
ngx.say(cjson.encode(r))
