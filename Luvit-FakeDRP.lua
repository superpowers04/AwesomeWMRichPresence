#!/bin/luvit
local arg = arg or args
local uv = require('uv')
local http = require('http')
local path = arg[2] or "./FakeDRP"

os.execute(('cd %q'):format(path:match('.+/')))
local port = 7286
stdout = uv.new_pipe()
stdin = uv.new_pipe()
stderr = uv.new_pipe()
local char_to_hex = function(c)
  return ("%%%02X"):format(c:byte())
end

local decodeURL = function(url)
  if url == nil or url == "" then
    return
  end
  url = url:gsub("+", " ")
  		:gsub("\\", "")
  		:gsub("%%(%x%x)", function(x) return string.char(tonumber(x, 16)) end)
  return url
end

DRP,pid = uv.spawn(path, {stdio = {stdin, 1, 2},args={
	arg[3]
}}, function(code, signal)
	print('Child process closed with code '..code..', exiting')
	os.exit()
end)
function websitefunc(req, res)
	if req.url ~= "/favicon.ico" then 
		local a = 0
		stdin:write(decodeURL(req.url:sub(2)):gsub('\\',''):gsub('|',function() a=a+1; return a == 1 and "|" or "-" end) .. '\n')
	end 
	res:setHeader("Content-Length",0)
	res:finish();
end

http.createServer(function(req, res)
	local succ,err=pcall(function() websitefunc(req, res) end) 
	if not succ then print(err) end
end):listen(port)
print('Listening at localhost:'..port)