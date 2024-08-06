warn('Begin')

local decompile = loadstring(game:HttpGet("https://raw.githubusercontent.com/NKachi2U/Advanced-Decompiler-V3/patch-1/init.lua"))()

local function construct_TimeoutHandler(timeout, f, timeout_ret)
	return function(script) -- TODO Ideally use ... (vararg) instead of `script` in case this is reused for something other than `decompile` & `getscriptbytecode`
			if timeout < 0 then
				return pcall(f, script, timeout)
			end

			local thread = coroutine.running()
			local timeoutThread, isCancelled

			timeoutThread = task.delay(timeout, function()
				isCancelled = true -- TODO task.cancel
				coroutine.resume(thread, nil, timeout_ret)
			end)

			task.spawn(function()
				local ok, result = pcall(f, script, timeout)

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

local function createReader()
	local FONT_NAME = 'Inconsolata'
	local CODE_FONT_NAME = 'ComicNeueAngular'
	
	local function rgb(...)
	    return Color3.fromRGB(...)
	end
	
	local function scale2(...)
	    return UDim2.fromScale(...)
	end
	
	local ScreenGui = Instance.new('ScreenGui')
	local Full = Instance.new('Frame')
    	local Info = Instance.new('Frame')
    	local UIstroke = Instance.new('UIStroke')
    	local MainInfo = Instance.new('Frame')
    	local UIListLayout = Instance.new("UIListLayout")
    	local sName = Instance.new('TextLabel')
    	local Credit = Instance.new('TextLabel')
    	local Body = Instance.new('ScrollingFrame')
    	local SourceInput = Instance.new('TextLabel')

    	ScreenGui.Name = 'ScriptViewer'
	ScreenGui.ResetOnSpawn = false
    	ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui

    	Full.Name = 'Full'
    	Full.BackgroundColor3 = rgb(71,71,71)
	Full.BorderSizePixel = 0
    	Full.Position = scale2(.238, .13)
    	Full.Size = scale2(.531, .774)
 	Full.Parent = ScreenGui

    	Info.Name = 'Info'
    	Info.BackgroundColor3 = rgb(57,57,57)
    	Info.Position = scale2(0,0)
    	Info.Size = scale2(1,.168)
    	Info.Parent = Full

    	UIstroke.Color = rgb(0,0,0)
    	UIstroke.Thickness = 2
    	UIstroke.Parent = Info

    	MainInfo.Name = 'MainInfo'
   	MainInfo.BackgroundTransparency = 1
    	MainInfo.Position = scale2(.02,.087)
    	MainInfo.Size = scale2(.194,.913)
    	MainInfo.Parent = Info

    	UIListLayout.Padding = UDim.new(.07)
    	UIListLayout.Parent = MainInfo

    	sName.Name = 'sName'
    	sName.BackgroundColor3 = rgb(39,39,39)
	sName.BorderSizePixel = 0
    	sName.Size = scale2(2.61,.288)
    	sName.FontFace = Font.fromName(FONT_NAME)
    	sName.Text = '  Path: ...'
    	sName.TextColor3 = rgb(255,255,255)
    	sName.TextSize = 14
    	sName.TextXAlignment = Enum.TextXAlignment.Left
    	sName.Parent = MainInfo

    	Credit.Name = 'Credit'
    	Credit.BackgroundColor3 = rgb(0,0,0)
    	Credit.BackgroundTransparency = .9
	Credit.BorderSizePixel = 0
    	Credit.Position = scale2(.694,.788)
    	Credit.Size = scale2(.295,.213)
    	Credit.FontFace = Font.fromName(FONT_NAME)
    	Credit.Text = 'Decompiled by fast_decomp'
    	Credit.TextColor3 = rgb(255,255,255)
    	Credit.TextSize = 11
    	Credit.Parent = Info

    	Body.Name = 'Body'
    	Body.BackgroundTransparency = 1
    	Body.Position = scale2(.034,.187)
    	Body.Size = scale2(.965,.813)
    	Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    	Body.CanvasPosition = Vector2.new(0,0)
    	Body.CanvasSize = scale2(0,0)
    	Body.Parent = Full

   	SourceInput.Name = 'SourceInput'
    	SourceInput.BackgroundTransparency = 1
    	SourceInput.Position = scale2(0,0)
    	SourceInput.Size = scale2(1,1)
    	SourceInput.FontFace = Font.fromName(CODE_FONT_NAME)
    	SourceInput.TextColor3 = rgb(227,227,170)
    	SourceInput.TextSize = 14
    	SourceInput.TextXAlignment = Enum.TextXAlignment.Left
    	SourceInput.TextYAlignment = Enum.TextYAlignment.Top
    	SourceInput.Parent = Body

    	return ScreenGui
end

local function fast_decompile(script, timeout, createGui, tlog)
	warn('Starting decomp of', script)
	
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

	if createGui then
		local gui = createReader()
		gui.Full.Info.MainInfo.sName.Text = string.gsub(gui.Full.Info.MainInfo.sName.Text, '...', script.Name)
		gui.Full.Body.SourceInput.Text = output
	end
	return ok, output
end

local _ENV = (getgenv or getrenv or getfenv)()
_ENV.fast_decompile = fast_decompile
	



