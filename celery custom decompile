warn('Begin')

local path = nil -- CHANGE THIS TO PATH!

local timeout = 10
local decompile = loadstring(game:HttpGet("https://raw.githubusercontent.com/NKachi2U/Advanced-Decompiler-V3/patch-1/init.lua"))()

local function construct_TimeoutHandler(timeout, f, timeout_ret)
	return function(script) -- TODO Ideally use ... (vararg) instead of `script` in case this is reused for something other than `decompile` & `getscriptbytecode`
			if timeout < 0 then
				return pcall(f, script)
			end

			local thread = coroutine.running()
			local timeoutThread, isCancelled

			timeoutThread = task.delay(timeout, function()
				isCancelled = true -- TODO task.cancel
				coroutine.resume(thread, nil, timeout_ret)
			end)

			task.spawn(function()
				local ok, result = pcall(f, script)

				if isCancelled then
					return
				end

				task.cancel(timeoutThread)

				while coroutine.status(thread) ~= "suspended" do
					task.wait()
				end

				coroutine.resume(thread, ok, result)
			end)

			return coroutine.yield()
	end
end

local decomp = construct_TimeoutHandler(timeout, decompile, "Decompiler timed out")

warn('Construct')

local function fast_decompile(script)
	local ok, result = decomp(script)
	if not result then
		ok, result = false, "Empty Output"
    end

	local output
    if ok then
    	result = string.gsub(result, "\0", "\\0") -- ? Some decompilers sadly output \0 which prevents files from opening
		output = result
	else
		output = "--[[ Failed to decompile\nReason:\n" .. (result or "") .. "\n]]"
	end

	return ok, output
end

	
warn('Starting decomp of', path)
task.delay(timeout, function()
    if not success then
        warn('Timeout')
    end
end)

success, src = fast_decompile(path)
warn(src)

warn('finished decomp')
