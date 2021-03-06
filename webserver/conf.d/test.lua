local resty_sha1 = require "resty.sha1"
local str = require "resty.string"
local upload = require "resty.upload"
--local cjson = require "cjson"
local gearman = require "resty.gearman"

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
local filelen = 0
local dosomting = true
while dosomting do
        local typ, res, err = form:read()

        if not typ then
                ngx.say('{"msg":"0","info":"no data"}')
                ngx.exit(200);
        end

        if typ == "header" then
                if res[1] ~= "Content-Type" then
                        local filename = get_filename(res[2]);
			if filename then
				suffix = getExtension(filename)
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
                else
                      if res[2] == "image/jpeg" then
                              suffix = ".jpg"
                      elseif  res[2] == "image/png" then
                              suffix = ".png"
                      elseif res[2] == "application/x-zip-compressed" then
                               suffix = ".zip"
                      elseif res[2] == "text/plain" then
                                 suffix = ".txt"
		      elseif res[2] == "media/mp4" then
                                 suffix = ".mp4"
		      elseif res[2] == "audio/mp3" then
                                 suffix = ".mp3"
		      elseif res[2] == "media/wav" then
                                 suffix = ".wav"
		      elseif res[2] == "media/amr" then
                                 suffix = ".amr"
		      elseif res[2] == "image/gif" then
                                 suffix = ".gif"
		       elseif res[2] == "video/mp4" then
                                 suffix = ".mp4"
                      --elseif suffix == nil then
                      --        ngx.say('{"msg":"0","info","do not support this file type"}')
                      --        ngx.exit(200);
                      end
                end
        elseif typ == "body" then
                if file then
			filelen = filelen + tonumber(string.len(res))
			if filelen > 104857600 then
				file:close()
				file = nil
				dosomting = false
				ngx.say('{"msg":"0","info":"file size too larger!!!"}')
				break
			end
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
                --ngx.say(file_name,"/tmp/"..shasum .. "."..suffix)
                ngx.say('{"msg":"1","name":"'..shasum .. suffix..'","type":"'..suffix..'","size":"'..filelen..'"}')

		if suffix == ".mp4" then
			local gm = gearman:new()
			gm:set_timeout(1000) -- 1 sec

            		local ok, err = gm:connect("172.17.0.33", 4730)

            		ok, err = gm:submit_job("video2png",shasum .. suffix)

            		local ok, err = gm:set_keepalive(1, 100)
		end

        elseif typ == "eof" then
                break

        else
            -- do nothing
        end
end

