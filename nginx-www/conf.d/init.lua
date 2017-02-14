
--local res = cache:eval("return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}", 2, "key1", "key2", "first", "second")
--	local res = cache:eval("return redis.call('get',KEYS[1])", 1, "222")
if ngx.var.arg_c == nil then
	return
else
	return
end

local mysql = require "resty.mysql"
local db, err = mysql:new()
local cjson = require "cjson"

db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
		 host = "172.17.0.33",
                 port = 3306,
                 database = "app_noonly",
                 user = "root",
                 password = "123456",
                 max_packet_size = 1024 * 1024 }

local res, err, errcode, sqlstate = db:query("SELECT `gid`,`messageid` FROM app_noonly.messagemgroup order by time asc;")
local redis = require "resty.redis"
        local cache = redis.new()
        cache:set_timeout(1000)
        cache.connect(cache, '172.17.0.4', '6379')

        cache:get_reused_times()
		for _,v in pairs(res) do

                        cache:del("circle:"..v.gid)
                end

		for k,v in pairs(res) do
			cache:lpush("circle:"..v.gid,v.messageid)
		end
            --return red:eval("return redis.call('get',KEYS[1])", 1, "222")

	db:query("SET NAMES utf8")
res, err, errcode, sqlstate = db:query('SELECT `ofUser`.`userid` as user,id,`studentmessageroot`.`studentmessageroot` as fid,`messagetype`,unix_timestamp(`time`) as time,`message`,`read`,ifnull(group_concat(stdmsgpicsid order by `unitkey` asc),"") as pic,ifnull(gisinfo,"") as gisinfo FROM studentmessage left join ofUser on studentmessage.username = ofUser.username left join studentmessageroot on  studentmessageroot.studentmessageid=studentmessage.id left join `studentmessagefrom` on studentmessage.id=studentmessagefrom.messageid left join studentmessagepicture on studentmessage.id=studentmessagepicture.messageid group by studentmessage.id')
for k,v in pairs(res) do
	cache:del(v.id)
	if v.messagetype == "share" then
		cache:hmset(v.id,"username",v.user,"time",v.time,"message",v.message,"read",v.read,"pic",v.pic,"gisinfo",v.gisinfo)
	else if v.messagetype == "like" then 
		cache:sadd("likes:"..tostring(v.user),v.fid)
		cache:hincrby(v.fid,"likes",1)
	else if v.messagetype == "reply" then

		cache:hincrby(v.fid,"replys",1)
        end
	end
	end
end
--96DC2CC9EF95056F

res, err, errcode, sqlstate = db:query('SELECT userid,name as nick, sex,enable FROM app_noonly.ofUser;')
for k,v in pairs(res) do
	cache:del(v.userid)
        cache:hmset(v.userid,"nick",v.nick,"sex",v.sex,"enable",v.enable)
end

res, err, errcode, sqlstate = db:query('SELECT *, COUNT(d.gid) AS allcount FROM (SELECT a.id id, a.name name,a.info info, a.picid picid, COUNT(b.gid) AS alluser FROM app_noonly.mgroup a LEFT JOIN usermgroup b ON b.gid=a.id GROUP BY a.id) c LEFT JOIN messagemgroup d ON c.id=d.gid GROUP BY c.id;')
for k,v in pairs(res) do
        cache:del("mgroup:"..v.id)
        cache:hmset("mgroup:"..v.id,"id",v.id,"name",v.name,"info",v.info,"picid",v.picid,"alluser",v.alluser,"allcount",v.allcount)
end


res, err, errcode, sqlstate = db:query('SELECT a.gid,b.userid FROM app_noonly.usermgroup a left join ofUser b on a.username=b.username;')
for k,v in pairs(res) do
        --cache:del("usermgroup:"..v.userid)
        cache:sadd("usermgroup:"..v.userid,v.gid)
end


cache:set_keepalive(10000, 50)

db:set_keepalive(10000, 50)
ngx.say("ok")
