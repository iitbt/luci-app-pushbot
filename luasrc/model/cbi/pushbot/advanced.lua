local nt = require "luci.sys".net
local fs=require"nixio.fs"

m=Map("pushbot",translate("Hint"),
translate("Do not modify if you don't understand these options."))

s = m:section(TypedSection, "pushbot", "高级设置")
s.anonymous = true
s.addremove = false

a=s:option(Value,"up_timeout",translate('Device Online Timeout (s)'))
a.default = "2"
a.optional=false
a.datatype="uinteger"

a=s:option(Value,"down_timeout",translate('Device Offline Timeout (s)'))
a.default = "20"
a.optional=false
a.datatype="uinteger"

a=s:option(Value,"timeout_retry_count",translate('Offline Detection Count'))
a.default = "2"
a.optional=false
a.datatype="uinteger"
a.description = translate("If no secondary router and good signal, reduce the above values.<br/>Adjust if frequent disconnects occur due to WiFi sleep.<br/>..╮(╯_╰）╭..")

a=s:option(Value,"thread_num",translate('Max Concurrent Threads'))
a.default = "3"
a.datatype="uinteger"

a=s:option(Value, "soc_code", "自定义温度读取命令")
a.rmempty = true 
a:value("",translate("Default"))
a:value("pve",translate("PVE Virtual Machine"))
a.description = translate("Avoid special symbols like ", $, !. Result must be a number for temp comparison.")

a=s:option(Value,"pve_host",translate("Host Address"))
a.rmempty=true
a.default="10.0.0.2"
a.description = translate("Ensure key login is set, else scripts will fail!<br/>Google how to install sensors on PVE.<br/>Key login example:<br/>opkg update<br/>opkg install openssh-client openssh-keygen<br/>ssh-keygen -t rsa<br/>ssh root@10.0.0.2 "tee -a ~/.ssh/id_rsa.pub" < ~/.ssh/id_rsa.pub<br/>ssh root@10.0.0.2 "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"<br/>ssh -i ~/.ssh/id_rsa root@10.0.0.2 sensors")
a:depends({soc_code="pve"})

a=s:option(Value,"pve_port",translate("SSH Port"))
a.rmempty=true
a.default="22"
a.description = translate("Default is 22. Enter custom SSH port if any.")
a:depends({soc_code="pve"})

a=s:option(Button,"soc",translate("Test Temperature Command"))
a.inputtitle = translate("Output Info")
a.write = function()
	luci.sys.call("/usr/bin/pushbot/pushbot soc")
	luci.http.redirect(luci.dispatcher.build_url("admin","services","pushbot","advanced"))
end

if nixio.fs.access("/tmp/pushbot/soc_tmp") then
e=s:option(TextValue,"soc_tmp")
e.rows=2
e.readonly=true
e.cfgvalue = function()
	return luci.sys.exec("cat /tmp/pushbot/soc_tmp && rm -f /tmp/pushbot/soc_tmp")
end
end

a=s:option(Flag,"err_enable",translate("Unattended Tasks"))
a.default=0
a.rmempty=true
a.description = translate("Ensure script runs properly to avoid frequent reboots!")

a=s:option(Flag,"err_sheep_enable",translate("Redial only during DND"))
a.default=0
a.rmempty=true
a.description = translate("Avoid daytime DDNS redials. Does not affect disconnect detection.<br/>May be unstable due to nighttime traffic.")
a:depends({err_enable="1"})

a= s:option(DynamicList, "err_device_aliases", translate("Watchlist"))
a.rmempty = true 
a.description = translate("Executes only when all listed devices are offline.<br/>After 1 hour of DND, watched devices with low traffic (~100kb/m) for 5 mins are considered offline.")
nt.mac_hints(function(mac, name) a :value(mac, "%s (%s)" %{ mac, name }) end)
a:depends({err_enable="1"})

a=s:option(ListValue,"network_err_event",translate("When Network Disconnected"))
a.default=""
a:depends({err_enable="1"})
a:value("",translate("No Action"))
a:value("1",translate("Reboot Router"))
a:value("2",translate("Redial"))
a:value("3",translate("Modify settings to auto-repair network"))
a.description = translate("Options 1 and 2 won't modify settings, max 2 attempts.<br/>Option 3 backs up to /usr/bin/pushbot/configbak and restores on failure.<br/>[!! COMPATIBILITY NOT GUARANTEED !!] Do not use if unfamiliar.")

a=s:option(ListValue,"system_time_event",translate("Scheduled Reboot"))
a.default=""
a:depends({err_enable="1"})
a:value("",translate("No Action"))
a:value("1",translate("Reboot Router"))
a:value("2",translate("Redial"))

a= s:option(Value, "autoreboot_time", "系统运行时间大于")
a.rmempty = true 
a.default = "24"
a.datatype="uinteger"
a:depends({system_time_event="1"})
a.description = translate("Unit is hours")

a=s:option(Value, "network_restart_time", "网络在线时间大于")
a.rmempty = true 
a.default = "24"
a.datatype="uinteger"
a:depends({system_time_event="2"})
a.description = translate("Unit is hours")

a=s:option(Flag,"public_ip_event",translate("Redial to get Public IP"))
a.default=0
a.rmempty=true
a:depends({err_enable="1"})
a.description = translate("Redial skips IP change notification and delays DDNS update.<br/>Ensure redial gets a public IP, otherwise it just causes drops.<br/>Don't bother if you're on a carrier-grade NAT!")

a= s:option(Value, "public_ip_retry_count", "当天最大重试次数")
a.rmempty = true 
a.default = "10"
a.datatype="uinteger"
a:depends({public_ip_event="1"})

return m
