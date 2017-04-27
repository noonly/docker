local cjson = require "cjson"

local t = {}
local t1 = {}
local t2 = {}
local r = {}

t1.name = "t1-1"
t1.sex = "t1-2"
t1.old = "t1-3"
t1.nick = "t1-4"
t1.school = "t1-5"

t2.name = "t2-1"
t2.sex = "t2-2"
t2.old = "t2-3"
t2.nick = "t2-4"
t2.school = "t2-5"


t[1] = t1
t[2] = t2
--t['pr'] = "123123"
r['message'] = t
r['pr'] = "123123" 

ngx.say(cjson.encode(r))
