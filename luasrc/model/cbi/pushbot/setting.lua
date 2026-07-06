
local nt = require "luci.sys".net
local fs=require"nixio.fs"
local e=luci.model.uci.cursor()
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local ifaces = sys.net:devices()

m=Map("pushbot",translate("PushBot"),
translate("“PushBot”可将路由器的报警和日志推送到各种平台。<br>支持钉钉、企业微信、PushPlus 等等。")
)

m:section(SimpleSection).template  = "pushbot/pushbot_status"

s=m:section(NamedSection,"pushbot","pushbot",translate(""))
s:tab("basic", translate("基本设置"))
s:tab("content", translate("推送内容"))
s:tab("crontab", translate("定时推送"))
s:tab("disturb", translate("免打扰"))
s.addremove = false
s.anonymous = true

--基本设置
a=s:taboption("basic", Flag,"pushbot_enable",translate("Enable"))
a.default=0
a.rmempty = true

--精简模式
a = s:taboption("basic", MultiValue, "lite_enable", translate("Lite Mode"))
a:value("device", translate("Lite Current Device List"))
a:value("nowtime", translate("Lite Current Time"))
a:value("content", translate("Push Title Only"))
a.widget = "checkbox"
a.default = nil
a.optional = true

--推送模式
a=s:taboption("basic", ListValue,"jsonpath",translate("Push Mode"))
a.default="/usr/bin/pushbot/api/dingding.json"
a.rmempty = true
a:value("/usr/bin/pushbot/api/dingding.json",translate("DingTalk"))
a:value("/usr/bin/pushbot/api/ent_wechat.json",translate("WeCom"))
a:value("/usr/bin/pushbot/api/feishu.json",translate("Feishu"))
a:value("/usr/bin/pushbot/api/bark.json",translate("Bark"))
a:value("/usr/bin/pushbot/api/pushplus.json",translate("PushPlus"))
a:value("/usr/bin/pushbot/api/pushdeer.json",translate("PushDeer"))
a:value("/usr/bin/pushbot/api/diy.json",translate("Custom Push"))

a=s:taboption("basic", Value,"dd_webhook",translate('Webhook'), translate("DingTalk Bot Webhook").."，只输入access_token=后面的即可<br>调用代码获取<a href='https://developers.dingtalk.com/document/robots/custom-robot-access' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/dingding.json")

a=s:taboption("basic", Value, "we_webhook", translate("Webhook"),translate("WeCom Bot Webhook").."，只输入key=后面的即可<br>调用代码获取<a href='https://work.weixin.qq.com/api/doc/90000/90136/91770' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/ent_wechat.json")

a=s:taboption("basic", Value,"pp_token",translate('PushPlus Token'), translate("PushPlus Token").."<br>调用代码获取<a href='http://pushplus.plus/doc/' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushplus.json")

a=s:taboption("basic", ListValue,"pp_channel",translate('PushPlus Channel'))
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushplus.json")
a:value("wechat",translate("wechat: PushPlus WeChat Official Account"))
a:value("cp",translate("cp: WeCom App"))
a:value("webhook",translate("webhook: Third-party Webhook"))
a:value("sms",translate("sms: SMS"))
a:value("mail",translate("mail: Email"))
a.description = translate("Third-party webhook: WeCom, DingTalk, Feishu, ServerChan<br>SMS/Email: PushPlus not yet open<br>Channel settings: <a href='http://pushplus.plus/doc/extend/webhook.html' target='_blank'>Click Here</a>")

a=s:taboption("basic", Value,"pp_webhook",translate('PushPlus Custom Webhook'), translate("PushPlus Custom Webhook").."<br>第三方webhook或企业微信调用<br>具体自定义Webhook设定参见：<a href='http://pushplus.plus/doc/extend/webhook.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pp_channel","cp")
a:depends("pp_channel","webhook")

a=s:taboption("basic", Flag,"pp_topic_enable",translate("PushPlus One-to-Many Push"))
a.default=0
a.rmempty = true
a:depends("pp_channel","wechat")

a=s:taboption("basic", Value,"pp_topic",translate('PushPlus Topic'), translate("PushPlus Group Code").."<br>一对多推送时指定的群组编码<br>具体群组编码Topic设定参见：<a href='http://www.pushplus.plus/push2.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pp_topic_enable","1")

a=s:taboption("basic", Value,"pushdeer_key",translate('PushDeer Key'), translate("PushDeer Key").."<br>调用代码获取<a href='http://www.pushdeer.com/' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushdeer.json")

a=s:taboption("basic", Flag,"pushdeer_srv_enable",translate("Self-hosted PushDeer Server"))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushdeer.json")

a=s:taboption("basic", Value,"pushdeer_srv",translate('PushDeer Server'), translate("PushDeer Self-hosted Server Address").."<br>如https://your.domain:port<br>具体自建服务器设定参见：<a href='http://www.pushdeer.com/selfhosted.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pushdeer_srv_enable","1")

a=s:taboption("basic", Value,"fs_webhook",translate('WebHook'), translate("Feishu WebHook").."<br>调用代码获取<a href='https://www.feishu.cn/hc/zh-CN/articles/360024984973' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/feishu.json")

a=s:taboption("basic", Value,"bark_token",translate('Bark Token'), translate("Bark Token").."<br>调用代码获取<a href='https://github.com/Finb/Bark' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Flag,"bark_srv_enable",translate("Self-hosted Bark Server"))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Value,"bark_srv",translate('Bark Server'), translate("Bark Self-hosted Server Address").."<br>如https://your.domain:port<br>具体自建服务器设定参见：<a href='https://github.com/Finb/Bark' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("bark_srv_enable","1")

a=s:taboption("basic", Value,"bark_sound",translate('Bark Sound'), translate("Bark Notification Sound").."<br>如silence.caf<br>具体设定参见：<a href='https://github.com/Finb/Bark/tree/master/Sounds' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a.default = "silence.caf"
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Flag,"bark_icon_enable",translate("Bark Notification Icon"))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Value,"bark_icon",translate('Bark Icon'), translate("Bark Notification Icon").."(仅 iOS15 或以上支持)<br>如http://day.app/assets/images/avatar.jpg<br>具体设定参见：<a href='https://github.com/Finb/Bark#%E5%85%B6%E4%BB%96%E5%8F%82%E6%95%B0' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a.default = "http://day.app/assets/images/avatar.jpg"
a:depends("bark_icon_enable","1")

a=s:taboption("basic", Value,"bark_level",translate('Bark Level'), translate("Bark Time-Sensitive Notification").."<br>可选参数值：<br/>active：不设置时的默认值，系统会立即亮屏显示通知。<br/>timeSensitive：时效性通知，可在专注状态下显示通知。<br/>passive：仅将通知添加到通知列表，不会亮屏提醒。")
a.rmempty = true
a.default = "active"
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", TextValue, "diy_json", translate("Custom Push"))
a.optional = false
a.rows = 28
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/diy.json")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/diy.json", value:gsub("\r\n", "\n"))
end
a:depends("jsonpath","/usr/bin/pushbot/api/diy.json")

a=s:taboption("basic", Button,"__add",translate("Send Test"))
a.inputtitle=translate("Send")
a.inputstyle = "apply"
function a.write(self, section)
	luci.sys.call("cbi.apply")
	luci.sys.call("/usr/bin/pushbot/pushbot test &")
end

a=s:taboption("basic", Value,"device_name",translate('Device Name'))
a.rmempty = true
a.description = translate("Device name added to push title to identify source.")

a=s:taboption("basic", Value,"sleeptime",translate('Detection Interval'))
a.rmempty = true
a.optional = false
a.default = "60"
a.datatype = "and(uinteger,min(10))"
a.description = translate("Shorter times give faster responses but use more resources.")

a=s:taboption("basic", ListValue,"oui_data",translate("MAC Device Info Database"))
a.rmempty = true
a.default=""
a:value("",translate("Disable"))
a:value("1",translate("Simplified Version"))
a:value("2",translate("Full Version"))
a:value("3",translate("Network Query"))
a.description = translate("Requires 4.36M raw data. Full ~1.2M, Lite ~250kb.<br/>Do not use network query without proxy.")

a=s:taboption("basic", Flag,"oui_dir",translate("Download to RAM"))
a.rmempty = true
a:depends("oui_data","1")
a:depends("oui_data","2")
a.description = translate("Downloads to RAM, re-downloads on reboot.<br/>Download to flash if no proxy.")

a=s:taboption("basic", Flag,"reset_regularly",translate("Reset traffic data daily at midnight"))
a.rmempty = true

a=s:taboption("basic", Flag,"debuglevel",translate("Enable Logging"))
a.rmempty = true

a= s:taboption("basic", DynamicList, "device_aliases", translate("Device Alias"))
a.rmempty = true
a.description = translate("<br/>Enter MAC and alias separated by '-', e.g.:<br/>XX:XX:XX:XX:XX:XX-MyPhone")

--设备状态
a=s:taboption("content", ListValue,"pushbot_ipv4",translate("IPv4 Change Notification"))
a.rmempty = true
a.default=""
a:value("",translate("Disable"))
a:value("1",translate("Get via Interface"))
a:value("2",translate("Get via URL"))

a = s:taboption("content", ListValue, "ipv4_interface", translate("Interface Name"))
a.rmempty = true
a:depends({pushbot_ipv4="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>Generally select wan. Choose manually for multi-wan.")

a=s:taboption("content", TextValue, "ipv4_list", translate("IPv4 API List"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ipv4.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ipv4.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>May fail due to server stability or frequent connections.<br/>Not recommended if IP can be obtained via interface.<br/>Access randomly from the above list.")
a:depends({pushbot_ipv4="2"})

a=s:taboption("content", ListValue,"pushbot_ipv6",translate("IPv6 Change Notification"))
a.rmempty = true
a.default="disable"
a:value("0",translate("Disable"))
a:value("1",translate("Get via Interface"))
a:value("2",translate("Get via URL"))

a = s:taboption("content", ListValue, "ipv6_interface", translate("Interface Name"))
a.rmempty = true
a:depends({pushbot_ipv6="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>Generally select wan. Choose manually for multi-wan.")

a=s:taboption("content", TextValue, "ipv6_list", translate("IPv6 API List"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ipv6.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ipv6.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>May fail due to server stability or frequent connections.<br/>Not recommended if IP can be obtained via interface.<br/>Access randomly from the above list.")
a:depends({pushbot_ipv6="2"})

a=s:taboption("content", Flag,"pushbot_up",translate("Device Online Notification"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"pushbot_down",translate("Device Offline Notification"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"cpuload_enable",translate("CPU Load Alert"))
a.default=1
a.rmempty = true

a= s:taboption("content", Value, "cpuload", "负载报警阈值")
a.default = 2
a.rmempty = true
a:depends({cpuload_enable="1"})

a=s:taboption("content", Flag,"temperature_enable",translate("CPU Temperature Alert"))
a.default=1
a.rmempty = true
a.description = translate("Ensure device can read temperature. Change command in Advanced Settings.")

a= s:taboption("content", Value, "temperature", "温度报警阈值")
a.rmempty = true
a.default = "80"
a.datatype="uinteger"
a:depends({temperature_enable="1"})
a.description = translate("<br/>Device alerts pushed only after 5 mins continuous exceedance.<br/>Max once per hour.")

a=s:taboption("content", Flag,"client_usage",translate("Device Abnormal Traffic"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "client_usage_max", "每分钟流量限制")
a.default = "10M"
a.rmempty = true
a:depends({client_usage="1"})
a.description = translate("Device Abnormal Traffic Alert (bytes), can append K or M")

a=s:taboption("content", Flag,"client_usage_disturb",translate("Abnormal Traffic DND"))
a.default=1
a.rmempty = true
a:depends({client_usage="1"})

a = s:taboption("content", DynamicList, "client_usage_whitelist", translate("Abnormal Traffic Watchlist"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({client_usage_disturb="1"})
a.description = translate("Enter Device MAC")

--LoginNoti
a=s:taboption("content", Flag,"web_logged",translate("Web Login Alert"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_logged",translate("SSH Login Alert"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"web_login_failed",translate("Web Error Attempt Alert"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_login_failed",translate("SSH Error Attempt Alert"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "login_max_num", "错误尝试次数")
a.default = "3"
a.datatype="and(uinteger,min(1))"
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("Push Alert After Exceeding Limit")

a=s:taboption("content", Flag,"web_login_black",translate("Auto Block"))
a.default=0
a.rmempty = true
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("Count won't reset until reboot. Please add whitelist first.")

a= s:taboption("content", Value, "ip_black_timeout", "拉黑时间(秒)")
a.default = "86400"
a.datatype="and(uinteger,min(0))"
a:depends("web_login_black","1")
a.description = translate("0 is permanent block. Use with caution.<br>If locked out, change your IP to enter LUCI and clear rules.")

a=s:taboption("content", DynamicList, "ip_white_list", translate("IP Whitelist"))
a.datatype = "ipaddr"
a.rmempty = true
luci.ip.neighbors({family = 4}, function(entry)
	if entry.reachable then
		a:value(entry.dest:string())
	end
end)
a:depends("web_logged","1")
a:depends("ssh_logged","1")
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("Ignore whitelist login alerts and block actions. Mask notation not supported.")

a=s:taboption("content", TextValue, "ip_black_list", translate("IP Blacklist"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ip_blacklist")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ip_blacklist", value:gsub("\r\n", "\n"))
end
a:depends("web_login_black","1")

--定时推送
a=s:taboption("crontab", ListValue,"crontab",translate("Cron Settings"))
a.rmempty = true
a.default=""
a:value("",translate("Disable"))
a:value("1",translate("Scheduled Sending"))
a:value("2",translate("Interval Sending"))

a=s:taboption("crontab", ListValue,"regular_time",translate("Send Time"))
a.rmempty = true
for t=0,23 do
a:value(t,translate("Every day at "..t.." o'clock"))
end
a.default=8
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_2",translate("Send Time"))
a.rmempty = true
a:value("",translate("Disable"))
for t=0,23 do
a:value(t,translate("Every day at "..t.." o'clock"))
end
a.default="关闭"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_3",translate("Send Time"))
a.rmempty = true

a:value("",translate("Disable"))
for t=0,23 do
a:value(t,translate("Every day at "..t.." o'clock"))
end
a.default="关闭"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"interval_time",translate("Send Interval"))
a.rmempty = true
for t=1,23 do
a:value(t,translate(t.."小时"))
end
a.default=6
a.datatype=uinteger
a:depends("crontab","2")
a.description = translate("<br/>Sends every * hours starting from 00:00")

a= s:taboption("crontab", Value, "send_title", translate("Push Title"))
a:depends("crontab","1")
a:depends("crontab","2")
a.placeholder = "OpenWrt By tty228 路由状态："
a.description = translate("<br/>Special characters may cause sending failure")

a=s:taboption("crontab", Flag,"router_status",translate("System Status"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"router_temp",translate("Device Temperature"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"router_wan",translate("WAN Info"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"client_list",translate("Client List"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Value,"google_check_timeout",translate("Global Internet Detection Timeout"))
a.rmempty = true
a.optional = false
a.default = "10"
a.datatype = "and(uinteger,min(3))"
a.description = translate("Too short time may cause inaccurate detection")

e=s:taboption("crontab", Button,"_add",translate("Send Manually"))
e.inputtitle=translate("Send")
e:depends("crontab","1")
e:depends("crontab","2")
e.inputstyle = "apply"
function e.write(self, section)
luci.sys.call("cbi.apply")
        luci.sys.call("/usr/bin/pushbot/pushbot send &")
end

--免打扰
a=s:taboption("disturb", ListValue,"pushbot_sheep",translate("DND Time Settings"),translate("Pause pushes during specified hours.<br/>Scheduled pushes are also blocked during DND."))
a.rmempty = true

a:value("",translate("Disable"))
a:value("1",translate("Mode 1: Script Suspended"))
a:value("2",translate("Mode 2: Silent Mode"))
a.description = translate("Mode 1 stops all detection, including unattended tasks.")
a=s:taboption("disturb", ListValue,"starttime",translate("DND Start Time"))
a.rmempty = true

for t=0,23 do
a:value(t,translate("Every day at "..t.." o'clock"))
end
a.default=0
a.datatype=uinteger
a:depends({pushbot_sheep="1"})
a:depends({pushbot_sheep="2"})
a=s:taboption("disturb", ListValue,"endtime",translate("DND End Time"))
a.rmempty = true

for t=0,23 do
a:value(t,translate("Every day at "..t.." o'clock"))
end
a.default=8
a.datatype=uinteger
a:depends({pushbot_sheep="1"})
a:depends({pushbot_sheep="2"})

a=s:taboption("disturb", ListValue,"macmechanism",translate("MAC Filter"))
a:value("",translate("Disable"))
a:value("allow",translate("Ignore Listed Devices"))
a:value("block",translate("Notify only listed devices"))
a:value("interface",translate("Notify only this interface's devices"))
a.rmempty = true


a = s:taboption("disturb", DynamicList, "pushbot_whitelist", translate("Ignore List"))
nt.mac_hints(function(mac, name) a :value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="allow"})
a.description = translate("Format: AA:AA:AA:AA:AA:AA|BB:BB... Treats multiple MACs as one user.<br/>Pushes only when all devices are offline to avoid dual-wifi spam.")

a = s:taboption("disturb", DynamicList, "pushbot_blacklist", translate("Watchlist"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="block"})
a.description = translate("Format: AA:AA:AA:AA:AA:AA|BB:BB... Treats multiple MACs as one user.<br/>Pushes only when all devices are offline to avoid dual-wifi spam.")

a = s:taboption("disturb", ListValue, "pushbot_interface", translate("Interface Name"))
a:depends({macmechanism="interface"})
a.rmempty = true

for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end

a=s:taboption("disturb", ListValue,"macmechanism2",translate("MAC Filter 2"))
a:value("",translate("Disable"))
a:value("MAC_online",translate("DND when any listed device is online"))
a:value("MAC_offline",translate("DND after all listed devices are offline"))
a.rmempty = true

a = s:taboption("disturb", DynamicList, "MAC_online_list", translate("Online DND List"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_online"})

a = s:taboption("disturb", DynamicList, "MAC_offline_list", translate("DND List for Any Offline"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_offline"})

return m
