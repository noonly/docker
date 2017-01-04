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
--r = "e57ee787bb362cd3fe264bce9e3fae092954624c"
--r = "1696bb90525a39832fbd48d76d6950a5e4f96cf2"
--r = "6fbf7b32080b1753c1376f5e0fd86d6164e855de"
--r = "0c8370de9f611a91c6f1d92d2209b176987b31f2"
r = "53b47d2cc1d7da96e4f3e0f849764d80515a4738"
local res, err = red:exec(
        function(red)
		if user ~= nil then
            		return red:evalsha(r,1,user)
		else
			return red:evalsha(r,0)
		end
        end
)
ngx.say(res)
--res.currenttime = os.time()
--local r = cjson.decode(res)
--r.ct = os.time()
--ngx.say(cjson.encode(r))
