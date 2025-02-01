-- Note this script wasn't designed to be public so things might be a mess ^^;
-- A basic script that uses the window name of a program to set your Discord Rich Presence
-- Check the readme.md

-- Replace 1201616832885444789 with whatever your Discord Rich Presence Application ID is. THIS HAS TO BE A STRING
local APPID = "1201616832885444789"
--  The command that gets run when you turn on DRP.
local process = 'xterm -e \'luvit "~/.config/awesome/AwesomeWMRichPresence/Luvit-FakeDRP.lua" "~/.config/awesome/AwesomeWMRichPresence/Haxe-FakeDRP" '..APPID..'\''
-- The program that gets killed when you disable DRP
local DRPCommand = "FakeDRP" 
-- The address used to communicate with the http server
local DRP_ENDPOINT = 'http://localhost:7286/' 
-- The command executed to update rich presence
local command = 'bash -c \'curl -s %q\'' 

-- Table consisting of Pattern > Function, function should return a valid string for the Haxe portion
--  Valid strings are either a http styled "?KEY1=VALUE1&KEY2=VALUE2" or a "TITLE|FOOTER"
-- Below are some examples
local pattToDRP = {
	['^DRP{']= function(name) -- Matches DRP{(VALID_STRING)}
		return name:match('DRP{(.-)}') 
	end, 
	['%- YouTube']= function(name) -- Matches (FOOTER) - Youtube
		return 'Watching YouTube|'..(name:match('%) (.+) %- YouTube') or name)
	end, 
	['%| Comic Fury']= function(name) -- Matches (FOOTER) | (TITLE) | Comic Fury
		return "Reading " .. (name:match('.-%| (.-) %|') or "??")..' on Comic Fury | '..(name:match('(.-) %|') or "??") 
	end,
}


-- Actual script
local module = {}
local gears,awful,naughty = require("gears"), require("awful"), require("naughty")
enableDRP = false -- I'm too lazy to rewrite my workflow to make this specific to the module, sorry



local newLine,rn,hex,byte = "\n","\r\n",("%%%02X"),string.byte
local function char_to_hex(c) return hex:format(byte(c)) end
local function DRPNotify(content)
	naughty.notify({preset = naughty.config.presets.normal, title = "Discord Rich Presence", text = content })
end
local function urlencode(url)
	if url == nil then return end
	return url:gsub(newLine, rn):gsub("([^%w ])", char_to_hex):gsub(" ", "+")
end

function module.sendToDRP(content)
	if not module.inited then
		naughty.notify({preset = naughty.config.presets.critical, title = "Discord Rich Presence", text = "Attempted to sendToDRP before DRP.initDRP was run!" })
		return 
	end
	if not enableDRP then return end
	awful.spawn(command:format(DRP_ENDPOINT.. urlencode(content:gsub('\'','\\\'') )))
end
function module.updateDRP(c)
	if(not (enableDRP and c.name)) then return end
	for patt,func in pairs(pattToDRP) do
		if(c.name:find(patt)) then
			local str = func(c.name)
			if str then
				return module.sendToDRP(str)
			end
		end
	end
end
function module.toggleDRP(state,skipSetup)
	if not module.inited then
		naughty.notify({preset = naughty.config.presets.critical, title = "Discord Rich Presence", text = "Attempted to toggleDRP before DRP.initDRP was run!" })
		return 
	end
	if(state == nil) then 
		enableDRP = not enableDRP 
	else
		enableDRP = state
	end
	if(not skipSetup) then
		awful.spawn.with_shell((enableDRP and 'touch' or 'rm') ..' /tmp/DRPENABLED')
		local ranThing = io.popen("pidof " .. process,'r')
		local pid = ranThing:read('*a')
		ranThing:close()
		if(pid == nil or not pid:find('%d')) then
			if(enableDRP) then
				awful.spawn(DRPCommand)
			end
			DRPNotify("Started")
			return
		end
		if pid then
			if not enableDRP then
				awful.spawn('kill ' .. pid)
				DRPNotify("Stopped")
				return
			end
		end

		-- end)
		DRPNotify("Set DRP to " .. tostring(enableDRP))
	end
end
function module.initDRP(state)
	client.connect_signal("property::name", module.updateDRP)
	client.connect_signal("property::focus", module.updateDRP)
	client.connect_signal("raised", module.updateDRP)

	-- awful.spawn.easy_async_with_shell("",function()
	module.inited=true
	if(state ~= nil) then
		module.toggleDRP(state,true)
	else
		if(gears.filesystem.file_readable('/tmp/DRPENABLED')) then
			module.toggleDRP(true,true)
		end
	end
end
-- end)
return module
