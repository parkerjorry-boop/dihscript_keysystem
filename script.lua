--[[
    ================================================================
    [ OYB OFFICIAL | ROBLOX DEVELOPER ]
    Website: https://oybofficial.com/
    Builder: https://oybofficial.com/keysystem
    YouTube: https://youtube.com/@OYBOfficial
    Discord: https://discord.gg/kT55J724BK
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "9285@faf@faw)((@32@!!!@#fafw))",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "DIHSCRIPT(ANOMALY LOCKDOWN)"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local function onChanged(name, value)
	if destroyed then return end
end

local function onSelfDestruct()

end

local HubScale = 1
local Settings, ToggleControls = {}, {}
local destroyed = false

local Resetters = {}
local function addReset(page, fn)
	Resetters[page] = Resetters[page] or {}
	table.insert(Resetters[page], fn)
end

local CONFIG_FILE = "AnomalyLockdownConfig.json"
local Loaded = { settings = {}, colors = {} }
do
	if isfile and readfile then
		local ok, raw = pcall(function()
			if isfile(CONFIG_FILE) then return readfile(CONFIG_FILE) end
			return nil
		end)
		if ok and typeof(raw) == "string" then
			local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
			if ok2 and typeof(data) == "table" then
				if typeof(data.settings) == "table" then Loaded.settings = data.settings end
				if typeof(data.colors) == "table" then Loaded.colors = data.colors end
			end
		end
	end
end

local Connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Connections, c)
	return c
end

local DefaultKeys = {}
local KeyToToggle = { esp_key = "esp" }
local OPEN_KEY = Enum.KeyCode.RightShift

local C = {
	titleBar = Color3.fromRGB(161, 125, 170),
	track = Color3.fromRGB(89, 89, 89),
	trackOn = Color3.fromRGB(161, 125, 170),
	white = Color3.new(1, 1, 1),
	gray = Color3.fromRGB(192, 192, 192),
	black = Color3.new(0, 0, 0),
	borderA = Color3.fromRGB(179, 155, 186),
	borderB = Color3.fromRGB(157, 155, 157),
	fill = Color3.fromRGB(135, 80, 155),
	tabActive = Color3.fromRGB(161, 125, 170),
	success = Color3.fromRGB(50, 220, 130),
	danger = Color3.fromRGB(255, 60, 60),
	discord = Color3.fromRGB(114, 137, 218),
}

local WINDOW_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(150, 110, 160)),
	ColorSequenceKeypoint.new(0.12, Color3.fromRGB(150, 110, 160)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(165, 132, 173)),
	ColorSequenceKeypoint.new(0.42, Color3.fromRGB(187, 162, 192)),
	ColorSequenceKeypoint.new(0.59, Color3.fromRGB(205, 188, 209)),
	ColorSequenceKeypoint.new(0.76, Color3.fromRGB(221, 210, 223)),
	ColorSequenceKeypoint.new(0.88, Color3.fromRGB(230, 223, 232)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(237, 232, 238)),
})

local FREDOKA = Font.fromEnum(Enum.Font.FredokaOne)
local LUCKY = Font.fromEnum(Enum.Font.LuckiestGuy)
local WINDOW_TRANSPARENCY = 0.15

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
	return c
end

local function stroke(p, t, col, tr)
	local s = Instance.new("UIStroke")
	s.Thickness = t
	s.Color = col
	s.Transparency = tr or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function frame(parent, x, y, w, h, color, transp, radius)
	local f = Instance.new("Frame")
	f.Position = UDim2.fromOffset(x, y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transp or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	if radius then corner(f, radius) end
	return f
end

local function text(parent, str, font, size, x, y, w, h, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = str
	l.FontFace = font
	l.TextSize = size
	l.TextColor3 = color or C.white
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(w, h)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.Parent = parent
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Color = C.black
	s.Transparency = 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = l
	return l
end

local gui = Instance.new("ScreenGui")
gui.Name = "HubGui"
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.OnTopOfCoreBlur = true
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local hubHolder = Instance.new("Frame")
hubHolder.Name = "HubHolder"
hubHolder.Size = UDim2.fromOffset(448, 593)
hubHolder.Position = UDim2.fromScale(0.5, 0.5)
hubHolder.AnchorPoint = Vector2.new(0.5, 0.5)
hubHolder.BackgroundTransparency = 1
hubHolder.Parent = gui

local HubUIScale = Instance.new("UIScale")
HubUIScale.Scale = HubScale
HubUIScale.Parent = hubHolder

local function UpdateHubScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local v = cam.ViewportSize
	local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local fit = math.min(v.X / 448, v.Y / 593, 1)
	HubUIScale.Scale = math.clamp(HubScale * fit * (mobile and 0.82 or 1), 0.55, 1.25)
end

local camera = workspace.CurrentCamera
if camera then
	connect(camera:GetPropertyChangedSignal("ViewportSize"), UpdateHubScale)
end

local shadowHolder = Instance.new("Frame")
shadowHolder.Size = UDim2.fromOffset(448, 593)
shadowHolder.Position = UDim2.fromScale(0.5, 0.5)
shadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
shadowHolder.BackgroundTransparency = 1
shadowHolder.ZIndex = 0
shadowHolder.Parent = hubHolder

for i = 1, 8 do
	local grow = (i - 1) * 2
	local ring = frame(shadowHolder, -grow, 4 - grow, 448 + grow * 2, 593 + grow * 2, C.black, 1, 26 + grow)
	stroke(ring, 2, C.black, 0.8 + i * 0.022)
end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(448, 593)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = C.white
main.BackgroundTransparency = WINDOW_TRANSPARENCY
main.BorderSizePixel = 0
main.ZIndex = 1
main.Parent = hubHolder
corner(main, 26)

local winGrad = Instance.new("UIGradient")
winGrad.Rotation = 90
winGrad.Color = WINDOW_GRADIENT
winGrad.Parent = main

local border = stroke(main, 6, C.white, WINDOW_TRANSPARENCY * 0.5)
local bgGrad = Instance.new("UIGradient")
bgGrad.Rotation = 90
bgGrad.Color = ColorSequence.new(C.borderA, C.borderB)
bgGrad.Parent = border

local titleBar = frame(main, 13, 7, 428, 51, C.titleBar, 0, 20)
text(titleBar, "ANOMALY LOCKDOWN", LUCKY, 28, 14, 0, 350, 51)

local closeBg = frame(main, 387, 14, 42, 36, C.white, 0, 8)
local cg = Instance.new("UIGradient")
cg.Rotation = 90
cg.Color = ColorSequence.new(Color3.fromRGB(255, 22, 22), Color3.fromRGB(245, 162, 162))
cg.Parent = closeBg
stroke(closeBg, 2, C.black, 0)

local close = Instance.new("TextButton")
close.Position = UDim2.fromOffset(387, 14)
close.Size = UDim2.fromOffset(42, 36)
close.BackgroundTransparency = 1
close.AutoButtonColor = false
close.Text = "X"
close.FontFace = LUCKY
close.TextSize = 27
close.TextColor3 = C.white
close.Parent = main
local xs = Instance.new("UIStroke")
xs.Thickness = 2
xs.Color = C.black
xs.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
xs.Parent = close
Instance.new("UIPadding", close).PaddingTop = UDim.new(0, 6)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)

local pages, tabPills, tabButtons = {}, {}, {}
local activeTab = "COMBAT"
local VIEW_TOP = 125

local viewport = Instance.new("Frame")
viewport.Position = UDim2.fromOffset(0, VIEW_TOP)
viewport.Size = UDim2.fromOffset(448, 458)
viewport.BackgroundTransparency = 1
viewport.ClipsDescendants = true
viewport.Parent = main

local tabDefs = {
	{ "COMBAT", 13, 81, 100, 38, 15, 98, 35, 2.0 },
	{ "ESP", 118, 81, 75, 38, 15, 72, 35, -1.5 },
	{ "COLORS", 198, 81, 100, 38, 14, 96, 35, 1.2 },
	{ "SETTINGS", 305, 81, 110, 38, 14, 104, 35, -0.8 },
}

local setScroll
local function setTabActive(name)
	for tabName, pill in pairs(tabPills) do
		local on = (tabName == name)
		local base = pill:GetAttribute("BaseSize") or pill.Size
		TweenService:Create(pill, TweenInfo.new(0.18), {
			BackgroundColor3 = on and C.tabActive or C.white,
			BackgroundTransparency = on and 0.15 or 0.4,
		}):Play()
		if on then
			TweenService:Create(pill, TweenInfo.new(0.12), {
				Size = UDim2.fromOffset(base.X.Offset * 1.05, base.Y.Offset * 1.05),
			}):Play()
			task.delay(0.12, function()
				TweenService:Create(pill, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = base,
				}):Play()
			end)
		end
	end
	activeTab = name
end

local function showPage(n)
	local pk = main:FindFirstChild("ColorPicker")
	if pk then pk.Visible = false end
	for k, p in pairs(pages) do p.Visible = (k == n) end
	setTabActive(n)
	if setScroll then setScroll(0, true) end
end

for _, d in ipairs(tabDefs) do
	local name, x, y, w, h, ts, pw, ph, rot = table.unpack(d)

	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(0.5, 0.5)
	pill.Position = UDim2.fromOffset(x + w / 2, y + h / 2)
	pill.Size = UDim2.fromOffset(pw, ph)
	pill.Rotation = rot
	pill.BackgroundColor3 = C.white
	pill.BackgroundTransparency = 0.4
	pill.BorderSizePixel = 0
	pill.Parent = main
	pill:SetAttribute("BaseSize", pill.Size)
	corner(pill, math.floor(ph / 2))
	local pg = Instance.new("UIGradient")
	pg.Rotation = 90
	pg.Color = ColorSequence.new(Color3.fromRGB(65, 65, 65), Color3.fromRGB(128, 128, 128))
	pg.Parent = pill
	stroke(pill, 1.5, C.black, 0.4)
	tabPills[name] = pill

	local b = Instance.new("TextButton")
	b.Position = UDim2.fromOffset(x, y)
	b.Size = UDim2.fromOffset(w, h)
	b.BackgroundTransparency = 1
	b.AutoButtonColor = false
	b.Text = name
	b.FontFace = FREDOKA
	b.TextSize = ts
	b.TextColor3 = C.white
	b.Parent = main
	local ts_ = Instance.new("UIStroke")
	ts_.Thickness = 1.2
	ts_.Color = C.black
	ts_.Transparency = 0.35
	ts_.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	ts_.Parent = b
	tabButtons[name] = b

	b.MouseEnter:Connect(function()
		if activeTab ~= name then
			TweenService:Create(pill, TweenInfo.new(0.12), { BackgroundTransparency = 0.25 }):Play()
		end
	end)
	b.MouseLeave:Connect(function()
		if activeTab ~= name then
			TweenService:Create(pill, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
		end
	end)
	b.MouseButton1Click:Connect(function()
		local orig = pill.Size
		TweenService:Create(pill, TweenInfo.new(0.07), {
			Size = UDim2.fromOffset(orig.X.Offset * 0.92, orig.Y.Offset * 0.92),
		}):Play()
		task.delay(0.07, function()
			TweenService:Create(pill, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = orig,
			}):Play()
		end)
		showPage(name)
	end)

	local page = Instance.new("Frame")
	page.Size = UDim2.fromOffset(448, 900)
	page.BackgroundTransparency = 1
	page.Position = UDim2.fromOffset(0, -VIEW_TOP)
	page.Visible = false
	page.Parent = viewport
	pages[name] = page
end

local resetBtn = Instance.new("TextButton")
resetBtn.Position = UDim2.fromOffset(309, 14)
resetBtn.Size = UDim2.fromOffset(72, 36)
resetBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 130)
resetBtn.AutoButtonColor = false
resetBtn.Text = "RESET"
resetBtn.FontFace = LUCKY
resetBtn.TextSize = 20
resetBtn.TextColor3 = C.white
resetBtn.Parent = main
corner(resetBtn, 8)
stroke(resetBtn, 2, C.black, 0)
local resetStroke = Instance.new("UIStroke")
resetStroke.Thickness = 1.5
resetStroke.Color = C.black
resetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
resetStroke.Parent = resetBtn
resetBtn.MouseButton1Click:Connect(function()
	local pk = main:FindFirstChild("ColorPicker")
	if pk then pk.Visible = false end
	local list = Resetters[pages[activeTab]]
	if list then
		for _, fn in ipairs(list) do pcall(fn) end
	end
end)

local TRACK_Y, TRACK_H, THUMB_H = 132, 450, 320
local MAX_SCROLL = 270
local scrollA, targetA, shownA = 0, 0, 0
local track = frame(main, 433, TRACK_Y, 8, TRACK_H, C.white, 1, 4)
local thumb = frame(main, 433, TRACK_Y, 8, THUMB_H, C.white, 0.5, 4)

local function applyScroll(a)
	thumb.Position = UDim2.fromOffset(433, TRACK_Y + a * (TRACK_H - THUMB_H))
	for _, pg in pairs(pages) do
		pg.Position = UDim2.fromOffset(0, -VIEW_TOP - a * MAX_SCROLL)
	end
end

function setScroll(a, snap)
	scrollA = math.clamp(a, 0, 1)
	targetA = scrollA
	if snap then shownA = targetA applyScroll(shownA) end
end

connect(RunService.RenderStepped, function(dt)
	if math.abs(targetA - shownA) < 0.0005 then
		if shownA ~= targetA then shownA = targetA applyScroll(shownA) end
		return
	end
	shownA += (targetA - shownA) * (1 - math.exp(-dt * 14))
	applyScroll(shownA)
end)

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function overMenu()
	if not gui.Enabled then return false end
	local m = UIS:GetMouseLocation()
	local p, sz = main.AbsolutePosition, main.AbsoluteSize
	return m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
end

local function pointerY(i)
	if i.UserInputType == Enum.UserInputType.Touch then return i.Position.Y end
	return UIS:GetMouseLocation().Y
end

local thumbDrag, thumbGrabY
thumb.InputBegan:Connect(function(i)
	if isPress(i) then
		thumbDrag = true
		thumbGrabY = pointerY(i) - thumb.AbsolutePosition.Y
	end
end)
track.InputBegan:Connect(function(i)
	if isPress(i) then
		local y = pointerY(i) - track.AbsolutePosition.Y - THUMB_H / 2
		setScroll(y / (TRACK_H - THUMB_H))
		thumbDrag = true
		thumbGrabY = THUMB_H / 2
	end
end)
connect(UIS.InputChanged, function(i)
	if thumbDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local y = pointerY(i) - track.AbsolutePosition.Y - thumbGrabY
		setScroll(y / (TRACK_H - THUMB_H))
	elseif i.UserInputType == Enum.UserInputType.MouseWheel then
		if overMenu() then setScroll(scrollA - i.Position.Z * 25 / MAX_SCROLL) end
	end
end)
connect(UIS.InputEnded, function(i)
	if isPress(i) then thumbDrag = false end
end)
ContextActionService:BindActionAtPriority("HubMenuWheelSink", function()
	return overMenu() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseWheel)

local function toggle(page, key, x, y, w)
	Settings[key] = false
	local trackBtn = Instance.new("TextButton")
	trackBtn.Position = UDim2.fromOffset(x, y)
	trackBtn.Size = UDim2.fromOffset(w, 36)
	trackBtn.BackgroundColor3 = C.track
	trackBtn.Text = ""
	trackBtn.AutoButtonColor = false
	trackBtn.Parent = page
	corner(trackBtn, 18)
	local knob = frame(trackBtn, 0, 0, 36, 36, C.white, 0, 18)
	local function apply(state, fire)
		Settings[key] = state
		knob:TweenPosition(UDim2.fromOffset(state and (w - 36) or 0, 0), "Out", "Quad", 0.12, true)
		trackBtn.BackgroundColor3 = state and C.trackOn or C.track
		if fire then onChanged(key, state) end
	end
	trackBtn.MouseButton1Click:Connect(function() apply(not Settings[key], true) end)
	ToggleControls[key] = {
		set = function(state) apply(state, true) end,
		toggle = function() apply(not Settings[key], true) end,
	}
	addReset(page, function() apply(false, true) end)
	local saved = Loaded.settings[key]
	if typeof(saved) == "boolean" then
		task.defer(function()
			if ToggleControls[key] then ToggleControls[key].set(saved) end
		end)
	end
end

local function keyBox(page, key, x, y, transp)
	local keyName = (typeof(Loaded.settings[key]) == "string" and Loaded.settings[key]) or DefaultKeys[key] or "None"
	if keyName == "Unknown" then keyName = "None" end
	Settings[key] = keyName
	local b = Instance.new("TextButton")
	b.Position = UDim2.fromOffset(x, y)
	b.Size = UDim2.fromOffset(76, 36)
	b.BackgroundColor3 = C.black
	b.BackgroundTransparency = transp or 0.8
	b.AutoButtonColor = false
	b.Text = keyName
	b.FontFace = FREDOKA
	b.TextSize = 28
	b.TextColor3 = C.white
	b.Parent = page
	corner(b, 5)
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Transparency = 0.35
	s.Color = C.black
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = b
	addReset(page, function()
		Settings[key] = "None"
		b.Text = "None"
		onChanged(key, "None")
	end)
	b.MouseButton1Click:Connect(function()
		b.Text = "..."
		local conn
		conn = connect(UIS.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				local newName = (i.KeyCode == Enum.KeyCode.Backspace or i.KeyCode == Enum.KeyCode.Unknown) and "None" or i.KeyCode.Name
				Settings[key] = newName
				b.Text = newName
				onChanged(key, newName)
				conn:Disconnect()
			end
		end)
	end)
end

local function selector(page, key, x, y, options)
	local start = options[1]
	local savedSel = Loaded.settings[key]
	if typeof(savedSel) == "string" and table.find(options, savedSel) then
		start = savedSel
		task.defer(function() onChanged(key, savedSel) end)
	end
	Settings[key] = start
	local b = Instance.new("TextButton")
	b.Position = UDim2.fromOffset(x, y)
	b.Size = UDim2.fromOffset(121, 36)
	b.BackgroundColor3 = C.black
	b.BackgroundTransparency = 0.8
	b.AutoButtonColor = false
	b.Text = start
	b.FontFace = FREDOKA
	b.TextSize = 24
	b.TextColor3 = C.white
	b.Parent = page
	corner(b, 5)
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Transparency = 0.35
	s.Color = C.black
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = b
	addReset(page, function()
		Settings[key] = options[1]
		b.Text = options[1]
		onChanged(key, options[1])
	end)
	b.MouseButton1Click:Connect(function()
		local i = table.find(options, Settings[key]) or 1
		Settings[key] = options[i % #options + 1]
		b.Text = Settings[key]
		onChanged(key, Settings[key])
	end)
end

local function slider(page, key, x, y, defaultA)
	defaultA = defaultA or 0.35
	local origA = defaultA
	local savedA = Loaded.settings[key]
	if typeof(savedA) == "number" then
		defaultA = math.clamp(savedA, 0, 1)
		task.defer(function() onChanged(key, defaultA) end)
	end
	Settings[key] = defaultA
	local bar = frame(page, x - 5, y - 4, 391, 10, C.track, 0, 5)
	local fill = frame(bar, 0, 0, 9, 10, C.fill, 0, 5)
	local knob = frame(bar, 0, 0, 27, 26, C.white, 0, 13)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 9, 0.5, 0)
	local dragging = false
	local function setFromX(px)
		local width = math.max(bar.AbsoluteSize.X - 18, 1)
		local a = math.clamp((px - bar.AbsolutePosition.X - 9) / width, 0, 1)
		local kx = 9 + a * width
		knob.Position = UDim2.new(0, kx, 0.5, 0)
		fill.Size = UDim2.new(0, kx, 0, 10)
		Settings[key] = a
		onChanged(key, a)
	end
	task.defer(function()
		if bar.AbsoluteSize.X > 0 then
			local kx = 9 + defaultA * (bar.AbsoluteSize.X - 18)
			knob.Position = UDim2.new(0, kx, 0.5, 0)
			fill.Size = UDim2.fromOffset(math.max(kx, 9), 10)
		end
	end)
	knob.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			if i.UserInputType == Enum.UserInputType.Touch then setFromX(i.Position.X) end
		end
	end)
	bar.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			setFromX(i.Position.X)
		end
	end)
	connect(UIS.InputEnded, function(i)
		if isPress(i) then dragging = false end
	end)
	connect(UIS.InputChanged, function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			setFromX(i.Position.X)
		end
	end)
	addReset(page, function()
		local kx = 9 + origA * math.max(bar.AbsoluteSize.X - 18, 1)
		knob.Position = UDim2.new(0, kx, 0.5, 0)
		fill.Size = UDim2.fromOffset(math.max(kx, 9), 10)
		Settings[key] = origA
		onChanged(key, origA)
	end)
end

local function lbl(page, str, x, y, w, size, color)
	text(page, str, FREDOKA, size, x, y, w, 30, color)
end

local ESPOn, BoxOn, ChamsOn, NameOn, HealthOn, TracerOn, TeamCheckOn =
	false, false, false, false, false, false, false
local ESPMaxDist = 800

local ESPColors = {
	enemy = Color3.fromRGB(255, 60, 60),
	team = Color3.fromRGB(70, 255, 140),
	neutral = Color3.fromRGB(255, 255, 255),
	scp = Color3.fromRGB(255, 170, 0),
}

local DefaultColors = {}
for k, v in pairs(ESPColors) do DefaultColors[k] = v end

for k, v in pairs(Loaded.colors) do
	if ESPColors[k] and typeof(v) == "table" and typeof(v[1]) == "number" and typeof(v[2]) == "number" and typeof(v[3]) == "number" then
		ESPColors[k] = Color3.new(math.clamp(v[1], 0, 1), math.clamp(v[2], 0, 1), math.clamp(v[3], 0, 1))
	end
end

local saveThread
local function SaveConfig()
	if destroyed or not writefile then return end
	local colors = {}
	for k, c in pairs(ESPColors) do colors[k] = { c.R, c.G, c.B } end
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode({ settings = Settings, colors = colors })
	end)
	if ok and encoded then pcall(writefile, CONFIG_FILE, encoded) end
end

local function DebouncedSave()
	if destroyed then return end
	if saveThread then pcall(task.cancel, saveThread) end
	saveThread = task.delay(0.4, SaveConfig)
end

local NeutralTeamIDs = {
	[""] = true,
	["anomalylockdown"] = true,
	["neutral"] = true,
	["none"] = true,
	["noteam"] = true,
}

local function RealTeamID(player)
	local v = player:GetAttribute("TeamID")
	if typeof(v) == "string" then
		local norm = (v:lower():gsub("[^%w]", ""))
		if NeutralTeamIDs[norm] then return nil end
		return v
	elseif typeof(v) == "number" then
		return v
	end
	return nil
end

local function IsSCP(name)
	if typeof(name) ~= "string" then return false end
	local norm = (name:lower():gsub("[^%w]", ""))
	return norm:find("scp", 1, true) ~= nil
end

local function GetRelation(player)

	if LocalPlayer:GetAttribute("TeamID") ~= nil or player:GetAttribute("TeamID") ~= nil then
		local theirID = RealTeamID(player)
		if not theirID then return "neutral", false end
		local myID = RealTeamID(LocalPlayer)
		local same = myID ~= nil and myID == theirID
		if IsSCP(theirID) then return "scp", same end
		if same then return "team", true end
		return "enemy", false
	end

	local myTeam, theirTeam = LocalPlayer.Team, player.Team
	if not myTeam or not theirTeam or LocalPlayer.Neutral or player.Neutral then return "neutral", false end
	local same = myTeam == theirTeam
	if IsSCP(theirTeam.Name) then return "scp", same end
	if same then return "team", true end
	return "enemy", false
end

local espGui = Instance.new("ScreenGui")
espGui.Name = "HubESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = -1
espGui.OnTopOfCoreBlur = true
espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local entries = {}

local function makeFrame()
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundTransparency = 1
	f.Visible = false
	f.Parent = espGui
	return f
end

local function newEntry(player)
	local e = {}

	e.box = makeFrame()
	e.boxStroke = Instance.new("UIStroke")
	e.boxStroke.Thickness = 1.5
	e.boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	e.boxStroke.Parent = e.box

	e.name = Instance.new("TextLabel")
	e.name.BackgroundTransparency = 1
	e.name.Size = UDim2.fromOffset(200, 16)
	e.name.AnchorPoint = Vector2.new(0.5, 1)
	e.name.Font = Enum.Font.GothamBold
	e.name.TextSize = 13
	e.name.TextStrokeTransparency = 0.4
	e.name.Visible = false
	e.name.Parent = espGui

	e.healthBg = makeFrame()
	e.healthBg.BackgroundTransparency = 0.3
	e.healthBg.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	e.healthFill = Instance.new("Frame")
	e.healthFill.BorderSizePixel = 0
	e.healthFill.AnchorPoint = Vector2.new(0, 1)
	e.healthFill.Position = UDim2.fromScale(0, 1)
	e.healthFill.Parent = e.healthBg

	e.tracer = makeFrame()
	e.tracer.BackgroundTransparency = 0
	e.tracer.AnchorPoint = Vector2.new(0.5, 0.5)

	entries[player] = e
	return e
end

local function hideEntry(e)
	e.box.Visible = false
	e.name.Visible = false
	e.healthBg.Visible = false
	e.tracer.Visible = false
	if e.cham then e.cham.Enabled = false end
end

local function removeEntry(player)
	local e = entries[player]
	if not e then return end
	entries[player] = nil
	if e.cham then e.cham:Destroy() end
	e.box:Destroy()
	e.name:Destroy()
	e.healthBg:Destroy()
	e.tracer:Destroy()
end

local function ensureCham(e, char, color)
	local h = e.cham
	if not h or h.Parent ~= char then
		if h then h:Destroy() end
		h = Instance.new("Highlight")
		h.Name = "HubCham"
		h.FillTransparency = 0.55
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Adornee = char
		h.Parent = char
		e.cham = h
	end
	h.FillColor = color
	h.OutlineColor = color
	h.Enabled = true
end

local SIGNS = { -1, 1 }
local GREEN, YELLOW, RED = Color3.fromRGB(50, 255, 120), Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 60, 60)

local function updateESP()
	if not ESPOn then
		for _, e in pairs(entries) do hideEntry(e) end
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local e = entries[player] or newEntry(player)
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local rel, same = GetRelation(player)

			if not (hum and root) or hum.Health <= 0 or (TeamCheckOn and same) then
				hideEntry(e)
			else
				local dist = (root.Position - origin).Magnitude
				if dist > ESPMaxDist then
					hideEntry(e)
				else
					local color = ESPColors[rel]

					if ChamsOn then
						ensureCham(e, char, color)
					elseif e.cham then
						e.cham.Enabled = false
					end

					local boxOk = false
					local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
					if BoxOn or NameOn or HealthOn then
						local cf, size = char:GetBoundingBox()
						boxOk = true
						for _, sx in ipairs(SIGNS) do
							for _, sy in ipairs(SIGNS) do
								for _, sz in ipairs(SIGNS) do
									local pt = (cf * CFrame.new(sx * size.X / 2, sy * size.Y / 2, sz * size.Z / 2)).Position
									local v = cam:WorldToViewportPoint(pt)
									if v.Z <= 0 then boxOk = false end
									minX = math.min(minX, v.X)
									minY = math.min(minY, v.Y)
									maxX = math.max(maxX, v.X)
									maxY = math.max(maxY, v.Y)
								end
							end
						end
						if boxOk and (maxX < 0 or minX > vp.X or maxY < 0 or minY > vp.Y) then
							boxOk = false
						end
					end
					local w, h = maxX - minX, maxY - minY

					if boxOk and BoxOn then
						e.box.Position = UDim2.fromOffset(minX, minY)
						e.box.Size = UDim2.fromOffset(w, h)
						e.boxStroke.Color = color
						e.box.Visible = true
					else
						e.box.Visible = false
					end

					if boxOk and NameOn then
						e.name.Text = string.format("%s [%d]", player.DisplayName, math.floor(dist))
						e.name.TextColor3 = color
						e.name.Position = UDim2.fromOffset(minX + w / 2, minY - 2)
						e.name.Visible = true
					else
						e.name.Visible = false
					end

					if boxOk and HealthOn then
						local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
						e.healthBg.Position = UDim2.fromOffset(minX - 6, minY)
						e.healthBg.Size = UDim2.fromOffset(3, h)
						e.healthFill.Size = UDim2.fromScale(1, pct)
						e.healthFill.BackgroundColor3 = (pct > 0.6 and GREEN) or (pct > 0.3 and YELLOW) or RED
						e.healthBg.Visible = true
					else
						e.healthBg.Visible = false
					end

					local rp = cam:WorldToViewportPoint(root.Position)
					if TracerOn and rp.Z > 0 then
						local from = Vector2.new(vp.X / 2, vp.Y)
						local to = Vector2.new(rp.X, rp.Y)
						local d = to - from
						e.tracer.Size = UDim2.fromOffset(d.Magnitude, 1.5)
						e.tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
						e.tracer.Rotation = math.deg(math.atan2(d.Y, d.X))
						e.tracer.BackgroundColor3 = color
						e.tracer.Visible = true
					else
						e.tracer.Visible = false
					end
				end
			end
		end
	end
end

local function DestroyESP()
	for player in pairs(entries) do removeEntry(player) end
	espGui:Destroy()
end

connect(Players.PlayerRemoving, removeEntry)
connect(RunService.RenderStepped, updateESP)

local pickerTarget
local pickerH, pickerS, pickerV = 0, 1, 1
local swatches = {}

local picker = Instance.new("Frame")
picker.Name = "ColorPicker"
picker.Size = UDim2.fromOffset(330, 252)
picker.Position = UDim2.fromOffset(59, 190)
picker.BackgroundColor3 = Color3.fromRGB(46, 38, 52)
picker.BackgroundTransparency = 0.03
picker.BorderSizePixel = 0
picker.Visible = false
picker.ZIndex = 20
picker.Parent = main
corner(picker, 16)
stroke(picker, 3, C.white, 0.2)

local pickerTitle = text(picker, "Colour", FREDOKA, 26, 16, 8, 220, 34)
local previewSwatch = frame(picker, 250, 10, 64, 30, C.white, 0, 8)
stroke(previewSwatch, 2, C.white, 0)

local refreshPicker

local function makeBar(y, labelText, onSet)
	text(picker, labelText, FREDOKA, 18, 16, y - 26, 200, 22, C.gray)
	local bar = frame(picker, 16, y, 298, 14, C.white, 0, 7)
	local grad = Instance.new("UIGradient")
	grad.Parent = bar
	local knob = frame(bar, 0, 0, 20, 20, C.white, 0, 10)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	stroke(knob, 2, C.black, 0.2)
	local dragging = false
	local function fromX(px)
		local a = math.clamp((px - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		onSet(a)
	end
	bar.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			fromX(i.Position.X)
		end
	end)
	knob.InputBegan:Connect(function(i)
		if isPress(i) then dragging = true end
	end)
	connect(UIS.InputEnded, function(i)
		if isPress(i) then dragging = false end
	end)
	connect(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end)
	return { grad = grad, knob = knob }
end

local hueBar = makeBar(78, "Hue", function(a) pickerH = a refreshPicker() DebouncedSave() end)
local satBar = makeBar(126, "Saturation", function(a) pickerS = a refreshPicker() DebouncedSave() end)
local valBar = makeBar(174, "Brightness", function(a) pickerV = a refreshPicker() DebouncedSave() end)

local hueKeys = {}
for i = 0, 6 do
	table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
end
hueBar.grad.Color = ColorSequence.new(hueKeys)

refreshPicker = function()
	local col = Color3.fromHSV(pickerH, pickerS, pickerV)
	previewSwatch.BackgroundColor3 = col
	hueBar.knob.Position = UDim2.new(pickerH, 0, 0.5, 0)
	satBar.knob.Position = UDim2.new(pickerS, 0, 0.5, 0)
	valBar.knob.Position = UDim2.new(pickerV, 0, 0.5, 0)
	satBar.grad.Color = ColorSequence.new(Color3.fromHSV(pickerH, 0, pickerV), Color3.fromHSV(pickerH, 1, pickerV))
	valBar.grad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(pickerH, pickerS, 1))
	if pickerTarget then
		ESPColors[pickerTarget] = col
		if swatches[pickerTarget] then swatches[pickerTarget].BackgroundColor3 = col end
	end
end

local doneBtn = Instance.new("TextButton")
doneBtn.Position = UDim2.fromOffset(16, 204)
doneBtn.Size = UDim2.fromOffset(298, 36)
doneBtn.BackgroundColor3 = C.titleBar
doneBtn.AutoButtonColor = false
doneBtn.Text = "DONE"
doneBtn.FontFace = FREDOKA
doneBtn.TextSize = 22
doneBtn.TextColor3 = C.white
doneBtn.Parent = picker
corner(doneBtn, 10)
doneBtn.MouseButton1Click:Connect(function()
	local key = pickerTarget
	pickerTarget = nil
	picker.Visible = false
	if key then onChanged("espColor_" .. key, ESPColors[key]) end
end)

local function openPicker(key, title)
	pickerTarget = key
	pickerTitle.Text = title
	pickerH, pickerS, pickerV = Color3.toHSV(ESPColors[key])
	picker.Visible = true
	refreshPicker()
end

local SelectAimTarget
local AimOn, AimTeamCheck, AimPredict = false, false, false
local AimPart = "Head"
local AimSmooth = 0.5
local AimTarget = nil
local AIM_MAX = 1000

local function GetAimPart(player)
	local char = player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	if AimPart == "Head" then
		return char:FindFirstChild("Head")
	end
	return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function AimPosition(part, dist)
	local pos = part.Position
	if AimPredict then
		local root = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
		if root then
			pos = pos + root.AssemblyLinearVelocity * (0.08 + dist * 0.0006)
		end
	end
	return pos
end

SelectAimTarget = function()
	if not AimOn then return end
	if AimTarget then
		AimTarget = nil
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local mouse = UIS:GetMouseLocation()
	local best, bestDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local part = GetAimPart(player)
			if part then
				local _, same = GetRelation(player)
				if not (AimTeamCheck and same) then
					local dist = (part.Position - cam.CFrame.Position).Magnitude
					if dist <= AIM_MAX then
						local v = cam:WorldToViewportPoint(part.Position)
						if v.Z > 0 then
							local d = (Vector2.new(v.X, v.Y) - mouse).Magnitude
							if d < bestDist then
								best, bestDist = player, d
							end
						end
					end
				end
			end
		end
	end
	AimTarget = best
end

RunService:BindToRenderStep("HubAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not AimOn or not AimTarget then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local part = GetAimPart(AimTarget)
	if not part then
		AimTarget = nil
		return
	end
	if AimTeamCheck then
		local _, same = GetRelation(AimTarget)
		if same then
			AimTarget = nil
			return
		end
	end
	local origin = cam.CFrame.Position
	local dist = (part.Position - origin).Magnitude
	local goal = CFrame.lookAt(origin, AimPosition(part, dist))
	local alpha = 1 - math.exp(-(60 - 56 * AimSmooth) * dt)
	cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end)

do
	local p = pages["COMBAT"]
	lbl(p, "Aimbot", 21, 157, 160, 33)
	keyBox(p, "aimbot_key", 179, 153)
	toggle(p, "aimbot", 320, 153, 75)
	lbl(p, "Body Part", 21, 210, 220, 33)
	selector(p, "aimBodyPart", 279, 212, { "Head", "Body" })
	lbl(p, "Team Check", 21, 263, 240, 33)
	toggle(p, "aimTeamCheck", 320, 259, 75)
	lbl(p, "Prediction", 21, 316, 200, 33)
	toggle(p, "aimPrediction", 320, 312, 75)
	lbl(p, "Smoothness", 21, 369, 200, 33, C.gray)
	slider(p, "aimSmooth", 20, 418, 0.5)
	lbl(p, "Press the aimbot key to lock / unlock a target", 21, 440, 400, 22, C.gray)
end

do
	local p = pages["ESP"]
	lbl(p, "ESP", 21, 157, 160, 33)
	keyBox(p, "esp_key", 179, 153)
	toggle(p, "esp", 320, 153, 75)
	lbl(p, "Boxes", 21, 210, 200, 33)
	toggle(p, "boxEsp", 320, 206, 75)
	lbl(p, "Chams", 21, 263, 200, 33)
	toggle(p, "chamsEsp", 320, 259, 75)
	lbl(p, "Names", 21, 316, 200, 33)
	toggle(p, "nameEsp", 320, 312, 75)
	lbl(p, "Health Bar", 21, 369, 240, 33)
	toggle(p, "healthEsp", 320, 365, 75)
	lbl(p, "Tracers", 21, 422, 200, 33)
	toggle(p, "tracerEsp", 320, 418, 75)
	lbl(p, "Team Check", 21, 475, 240, 33)
	toggle(p, "espTeamCheck", 320, 471, 75)
	lbl(p, "max distance", 21, 528, 250, 28, C.gray)
	slider(p, "maxDistance", 20, 577, 0.37)

end

do
	local p = pages["COLORS"]
	local function colorRow(key, label, y)
		lbl(p, label, 21, y, 260, 33)
		local sw = Instance.new("TextButton")
		sw.Position = UDim2.fromOffset(300, y - 2)
		sw.Size = UDim2.fromOffset(95, 36)
		sw.BackgroundColor3 = ESPColors[key]
		sw.AutoButtonColor = false
		sw.Text = ""
		sw.Parent = p
		corner(sw, 8)
		stroke(sw, 2, C.white, 0)
		swatches[key] = sw
		sw.MouseButton1Click:Connect(function() openPicker(key, label) end)
	end
	colorRow("enemy", "Enemy color", 157)
	colorRow("team", "Team color", 210)
	colorRow("neutral", "Neutral color", 263)
	colorRow("scp", "SCP color", 316)
	addReset(p, function()
		for k, c in pairs(DefaultColors) do
			ESPColors[k] = c
			if swatches[k] then swatches[k].BackgroundColor3 = c end
		end
		DebouncedSave()
	end)
	lbl(p, "Click a color to change it", 21, 372, 400, 22, C.gray)
end

do
	local p = pages["SETTINGS"]
	lbl(p, "RightShift = Menu", 21, 157, 400, 28, C.gray)
	lbl(p, "Hub Size", 21, 210, 200, 28, C.gray)
	slider(p, "hubScale", 20, 258, math.clamp((HubScale - 0.55) / 0.70, 0, 1))
	lbl(p, "Use the slider to resize the hub", 21, 280, 400, 22, C.gray)

	local function SelfDestruct()
		if destroyed then return end
		destroyed = true
		pcall(onSelfDestruct)
		pcall(DestroyESP)
		for _, c in ipairs(Connections) do
			pcall(function() c:Disconnect() end)
		end
		table.clear(Connections)
		pcall(function() ContextActionService:UnbindAction("HubMenuWheelSink") end)
		pcall(function() RunService:UnbindFromRenderStep("HubAim") end)
		AimTarget = nil
		table.clear(ToggleControls)
		table.clear(Settings)
		gui:Destroy()
	end

	local sd = Instance.new("TextButton")
	sd.Position = UDim2.fromOffset(21, 340)
	sd.Size = UDim2.fromOffset(380, 42)
	sd.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
	sd.BackgroundTransparency = 0.1
	sd.AutoButtonColor = false
	sd.Text = "SELF DESTRUCT"
	sd.FontFace = FREDOKA
	sd.TextSize = 24
	sd.TextColor3 = C.white
	sd.Parent = p
	corner(sd, 10)
	local sds = Instance.new("UIStroke")
	sds.Thickness = 1.5
	sds.Color = C.black
	sds.Transparency = 0.4
	sds.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	sds.Parent = sd

	lbl(p, "Config autosaves on change", 21, 400, 400, 22, C.gray)

	local dbg = Instance.new("TextButton")
	dbg.Position = UDim2.fromOffset(21, 436)
	dbg.Size = UDim2.fromOffset(380, 36)
	dbg.BackgroundColor3 = C.black
	dbg.BackgroundTransparency = 0.7
	dbg.AutoButtonColor = false
	dbg.Text = "PRINT TEAM IDS (F9)"
	dbg.FontFace = FREDOKA
	dbg.TextSize = 20
	dbg.TextColor3 = C.white
	dbg.Parent = p
	corner(dbg, 10)
	dbg.MouseButton1Click:Connect(function()
		for _, pl in ipairs(Players:GetPlayers()) do
			print("[TeamID]", pl.Name, "|", tostring(pl:GetAttribute("TeamID")), "|", GetRelation(pl))
		end
	end)

	local armed = false
	sd.MouseButton1Click:Connect(function()
		if not armed then
			armed = true
			sd.Text = "CLICK AGAIN TO CONFIRM"
			task.delay(2.5, function()
				if destroyed then return end
				armed = false
				sd.Text = "SELF DESTRUCT"
			end)
		else
			SelfDestruct()
		end
	end)
end

local baseOnChanged = onChanged
onChanged = function(name, value)
	if destroyed then return end
	if name == "hubScale" then
		HubScale = math.clamp(0.55 + value * 0.70, 0.55, 1.25)
		UpdateHubScale()
	elseif name == "esp" then ESPOn = value
	elseif name == "boxEsp" then BoxOn = value
	elseif name == "chamsEsp" then ChamsOn = value
	elseif name == "nameEsp" then NameOn = value
	elseif name == "healthEsp" then HealthOn = value
	elseif name == "tracerEsp" then TracerOn = value
	elseif name == "espTeamCheck" then TeamCheckOn = value
	elseif name == "maxDistance" then ESPMaxDist = math.floor(100 + value * 1900 + 0.5)
	elseif name == "aimbot" then
		AimOn = value
		if not value then AimTarget = nil end
	elseif name == "aimBodyPart" then AimPart = value
	elseif name == "aimTeamCheck" then AimTeamCheck = value
	elseif name == "aimPrediction" then AimPredict = value
	elseif name == "aimSmooth" then AimSmooth = value
	end
	baseOnChanged(name, value)
	DebouncedSave()
end

UpdateHubScale()
showPage("COMBAT")

local dragStart, startPos
titleBar.InputBegan:Connect(function(i)
	if isPress(i) then
		dragStart, startPos = i.Position, hubHolder.Position
	end
end)
connect(UIS.InputChanged, function(i)
	if dragStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		hubHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
connect(UIS.InputEnded, function(i)
	if isPress(i) then dragStart = nil end
end)

connect(UIS.InputBegan, function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local name = input.KeyCode.Name
	if name == "Unknown" or name == "None" then return end
	if input.KeyCode == OPEN_KEY then
		gui.Enabled = not gui.Enabled
		return
	end
	if Settings.aimbot_key == name then SelectAimTarget() end
	for keyId, toggleId in pairs(KeyToToggle) do
		if Settings[keyId] == name then
			if ToggleControls[toggleId] then ToggleControls[toggleId].toggle() end
		end
	end
end)
