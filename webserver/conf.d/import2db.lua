local user = nil
if (ngx.var.cookie_NOONLYSESSION ~= nil) then

        user = string.sub(ngx.var.cookie_NOONLYSESSION,0,16)

else

--	ngx.exit(401)
end

local cjson = require "cjson"
local redis = require("resty.rediscli")

local red = redis.new()

--local r
--r = "e57ee787bb362cd3fe264bce9e3fae092954624c"
--r = "1696bb90525a39832fbd48d76d6950a5e4f96cf2"
--r = "6fbf7b32080b1753c1376f5e0fd86d6164e855de"
--r = "0c8370de9f611a91c6f1d92d2209b176987b31f2"
--r = "53b47d2cc1d7da96e4f3e0f849764d80515a4738"
--r = "004a0f6e7aa1e92f7abf7645e54343b4b8bf407c"
--r = "33e52cc4addbcb5f61c684b8e0655934dc83eb23"
--r = "adb2965242c8276c593d2628744b8b60b212f7eb"
--r = "60607647ddd585e84ff9e58bc3f9965c79877720"
--r = "9ed547a17cf84571adabd7f417817ff057c94b70"
--r = "a466898245fd9f38060956b4cee76487b146b41a"
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
