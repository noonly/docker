local resty_sha1 = require "resty.sha1"
local str = require "resty.string"
local upload = require "resty.upload"
--local cjson = require "cjson"

local chunk_size = 8192
local form = upload:new(chunk_size)
local sha1 = resty_sha1:new()
local file

function get_filename(res)
        local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)')
        if filename then
                return filename[2]
        end
end
function getExtension(str)
        return str:match(".+%.(%w+)$")
end
local file_name
local suffix
local result
while true do
        local typ, res, err = form:read()

        if not typ then
                ngx.say('{"msg":"0","info":"no data"}')
                ngx.exit(200);
        end

        if typ == "header" then
                if res[1] ~= "Content-Type" then
                        local filename = get_filename(res[2]);
			suffix = nil
			if filename then
				suffix = getExtension(filename)
			else
				break
			end
			if suffix == nil then
				suffix = ""
			else
				suffix = "." .. suffix
			end
                        file_name = "/img/".. ngx.md5(math.random(9999) .. ngx.var.remote_addr .. math.random(9999))
                        if file_name then
                                file = io.open(file_name, "w+")
                                if not file then
                                        ngx.say('{"msg":"0","info","file server error"}')
                                        ngx.exit(200);
                                end
                        end
                end
        elseif typ == "body" then
                if file then
                        file:write(res)
                        sha1:update(res)
                end

        elseif typ == "part_end" then
                file:close()
                file = nil
                local sha1_sum = sha1:final()
                sha1:reset()
                local shasum = str.to_hex(sha1_sum)
                os.rename(file_name,"/img/"..shasum .. suffix)
		if result ~= nil then
			result = result ..","..'{"msg":"1","name":"'..shasum .. suffix..'","type":"'..suffix..'"}'
		else
			result = '{"msg":"1","name":"'..shasum .. suffix..'","type":"'..suffix..'"}'
		end
                --ngx.say('{"msg":"1","name":"'..shasum .. suffix..'","type":"'..suffix..'"}')
        elseif typ == "eof" then
                break

        else
            -- do nothing
        end
end

ngx.say("{\"filedesc\":["..result.."]}")
