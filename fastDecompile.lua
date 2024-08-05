warn('Begin')

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

local function fast_decompile(script, timeout, tlog)
	warn('Starting decomp of', path)
	
	if tlog then
		task.delay(timeout, function()
			if not ok then
				warn('Timeout')
		    	end
		end)
	end
	ok, result = construct_TimeoutHandler(timeout, decompile, "Decompiler timed out")(script)
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

	warn('finished decomp')
	return ok, output
end

local _ENV = (getgenv or getrenv or getfenv)()
_ENV.fast_decompile = fast_decompile
	



