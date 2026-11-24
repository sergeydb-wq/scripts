--[[
    W  —  загрузка → экран блокировки → вкладки с 3D-переходами
    Luau / Roblox LocalScript (или executor). Скрыть/показать: RightShift
]]

------------------------------------------------------------------
-- НАСТРОЙКИ
------------------------------------------------------------------
local CONFIG = {
    AssetBase = "https://raw.githubusercontent.com/sergeydb-wq/Logos/main/rockstar/",
    Assets = {
        Logo      = "logo_w.png",
        Wallpaper = "wallpaper.png",
        User      = "user.png",
        Users     = "users.png",
        Settings  = "settings.png",
        Power     = "power.png",
        Arrow     = "arrow.png",
    },
    CacheVersion = "1",
    KeySysUrl    = "https://raw.githubusercontent.com/sergeydb-wq/scripts/refs/heads/wannaclient/keysys.lua",
    ToggleKey    = Enum.KeyCode.RightShift,
    MinLoadTime  = 2.6,

    -- Скрипты (вкладка «Игры»). Places пусто = работает в любой игре. Script пусто = «Скоро»
    -- Image: имя файла из AssetBase или полная ссылка. Fit = true — картинка по центру (для лого)
    Games = {
        {
            Name = "WannaCry Visuals", Places = {},
            Script = "https://raw.githubusercontent.com/sergeydb-wq/scripts/refs/heads/wannaclient/wannacry.lua",
            Image = "logo_w.png", Fit = true,
        },
        {
            Name = "WannaCry + Blockcraft", Places = { 136169205786617 },
            Script = "https://raw.githubusercontent.com/sergeydb-wq/scripts/refs/heads/wannaclient/WannaBloc.lua",
            Image = "https://raw.githubusercontent.com/sergeydb-wq/Logos/main/blockcraft.png", Premium = true,
        },
        {
            Name = "WannaCry + Carry People Sim 3", Places = { 7267631004 },
            Script = "https://raw.githubusercontent.com/sergeydb-wq/scripts/refs/heads/wannaclient/WannaCarry.lua",
            Image = "https://raw.githubusercontent.com/sergeydb-wq/Logos/main/carrypeoplesimulator3.png", Premium = true,
        },
    },
}

------------------------------------------------------------------
-- СЕРВИСЫ / УТИЛИТЫ
------------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local connections = {}

local FONT_CLOCK = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Heavy)
local FONT_UI_B  = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)

local Quint, Quad, Sine, Back = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Sine, Enum.EasingStyle.Back
local In, Out, InOut = Enum.EasingDirection.In, Enum.EasingDirection.Out, Enum.EasingDirection.InOut

local function new(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function tween(obj, time, props, style, dir, repeats, reverses, delay)
    local t = TweenService:Create(obj, TweenInfo.new(
        time, style or Quint, dir or Out, repeats or 0, reverses or false, delay or 0
    ), props)
    t:Play()
    return t
end

local function corner(r) return new("UICorner", { CornerRadius = r or UDim.new(1, 0) }) end

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

-- Плавно растворяет всё дерево (без CanvasGroup и UIStroke — никаких «призраков»)
local FADE_PROPS = {
    Frame          = { "BackgroundTransparency" },
    ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" },
    TextLabel      = { "BackgroundTransparency", "TextTransparency" },
    TextButton     = { "BackgroundTransparency", "TextTransparency" },
    ImageLabel     = { "BackgroundTransparency", "ImageTransparency" },
    ImageButton    = { "BackgroundTransparency", "ImageTransparency" },
    UIStroke       = { "Transparency" },
}
local function fadeOut(root, time, style, dir)
    local list = root:GetDescendants()
    table.insert(list, root)
    for _, obj in ipairs(list) do
        local props = FADE_PROPS[obj.ClassName]
        if props then
            local goal = {}
            for _, p in ipairs(props) do goal[p] = 1 end
            tween(obj, time, goal, style or Quad, dir or InOut)
        end
    end
end

------------------------------------------------------------------
-- АССЕТЫ (GitHub → getcustomasset, иначе rbxassetid)
------------------------------------------------------------------
local function isImage(data)
    return type(data) == "string" and (data:sub(1, 4) == "\137PNG" or data:sub(1, 2) == "\255\216")
end

local function loadAsset(name, src)
    if not src or src == "" then return nil end
    if src:find("^rbxasset") then return src end
    local url = src:find("^https?://") and src or (CONFIG.AssetBase .. src)
    if not (writefile and getcustomasset) then return nil end
    local ok, result = pcall(function()
        local folder = "wannacry"
        if isfolder and not isfolder(folder) then makefolder(folder) end
        local ext  = url:match("%.(%w+)$") or "png"
        local path = ("%s/%s_v%s.%s"):format(folder, name, CONFIG.CacheVersion, ext)
        if not (isfile and isfile(path)) then
            local data = game:HttpGet(url)
            if not isImage(data) then error("not an image") end
            writefile(path, data)
        end
        return getcustomasset(path)
    end)
    return ok and result or nil
end

local ASSET = {}
local KeySys -- модуль ключей (грузится с GitHub во время загрузки)

------------------------------------------------------------------
-- GUI
------------------------------------------------------------------
local gui = new("ScreenGui", {
    Name = "W_" .. tostring(math.random(1e5, 9e5)),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})
do
    local parented = false
    if gethui then parented = pcall(function() gui.Parent = gethui() end) end
    if not parented then parented = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not parented or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

------------------------------------------------------------------
-- 1. ЗАГРУЗКА (лого W)
------------------------------------------------------------------
local loading = new("Frame", {
    Parent = gui, ZIndex = 20, Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, BorderSizePixel = 0,
})
local logoHolder = new("Frame", {
    Parent = loading, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 300, 0, 150), BackgroundTransparency = 1,
})
local logoScale = new("UIScale", { Parent = logoHolder, Scale = 0.82 })
local logoShine = new("UIGradient", {
    Rotation = 20, Offset = Vector2.new(-1, 0),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(0.44, 0.12),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.56, 0.12), NumberSequenceKeypoint.new(1, 0.12),
    }),
})
local barBack = new("Frame", {
    Parent = loading, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 110),
    Size = UDim2.new(0, 200, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, { corner() })
local barFill = new("Frame", {
    Parent = barBack, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, { corner() })

ASSET.Logo = loadAsset("logo", CONFIG.Assets.Logo)
local logo
if ASSET.Logo then
    logo = new("ImageLabel", {
        Parent = logoHolder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Image = ASSET.Logo, ScaleType = Enum.ScaleType.Fit, ImageTransparency = 1,
    })
else
    logo = new("TextLabel", {
        Parent = logoHolder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "W", FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Black),
        TextSize = 150, TextColor3 = Color3.fromRGB(240, 240, 240), TextTransparency = 1,
    })
end
logoShine.Parent = logo

------------------------------------------------------------------
-- 2. ЭКРАН БЛОКИРОВКИ / ГЛАВНОЕ МЕНЮ / ВКЛАДКИ
------------------------------------------------------------------
local WEEKDAYS = { "Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота" }
local MONTHS = { "января", "февраля", "марта", "апреля", "мая", "июня",
                 "июля", "августа", "сентября", "октября", "ноября", "декабря" }

local state = { unlocked = false, section = nil, busy = false }

local lock, wall, home, homeScale, clockHolder, dateLabel, timeLabel, hint, hintPulse
local dockButtons, sections = {}, {}

-- Куда уезжает главное меню и откуда приходит вкладка (центр = 0.5, 0.5)
local DIRS = {
    left  = { home = UDim2.fromScale(-0.55, 0.5), from = UDim2.fromScale(1.55, 0.5),  wall = UDim2.fromScale(0.47, 0.5), arrow = 180 }, -- стрелка ←
    down  = { home = UDim2.fromScale(0.5, 1.55),  from = UDim2.fromScale(0.5, -0.55), wall = UDim2.fromScale(0.5, 0.53), arrow = 90 },  -- стрелка ↓
    right = { home = UDim2.fromScale(1.55, 0.5),  from = UDim2.fromScale(-0.55, 0.5), wall = UDim2.fromScale(0.53, 0.5), arrow = 0 },   -- стрелка →
}
local CENTER = UDim2.fromScale(0.5, 0.5)
local DEPTH  = 0.86 -- насколько «отдаляется» слой (UIScale)

-- Круглая кнопка (стиль дока)
local function makeRoundButton(parent, image, glyph, props, onClick)
    local btn = new("TextButton", {
        Parent = parent, Text = "", AutoButtonColor = false,
        Size = UDim2.new(0, 68, 0, 68), BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, { corner() })
    for k, v in pairs(props or {}) do btn[k] = v end
    local scale = new("UIScale", { Parent = btn, Scale = 0.6 })

    local icon
    if image then
        icon = new("ImageLabel", {
            Parent = btn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.42, 0.42), BackgroundTransparency = 1,
            Image = image, ImageTransparency = 1, ImageColor3 = Color3.fromRGB(235, 235, 245),
        })
    else
        icon = new("TextLabel", {
            Parent = btn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = glyph, TextSize = 28, FontFace = FONT_UI_B,
            TextColor3 = Color3.fromRGB(235, 235, 245), TextTransparency = 1,
        })
    end
    local iconProp = icon:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"

    local obj = { btn = btn, icon = icon, shown = false }
    local REST, HOVER = 0.86, 0.76

    function obj.show(delay)
        obj.shown = true
        tween(btn, 0.5, { BackgroundTransparency = REST }, nil, nil, 0, false, delay)
        tween(icon, 0.5, { [iconProp] = 0 }, nil, nil, 0, false, delay)
        tween(scale, 0.6, { Scale = 1 }, Back, nil, 0, false, delay)
    end
    function obj.hide(delay)
        obj.shown = false
        tween(btn, 0.25, { BackgroundTransparency = 1 }, nil, nil, 0, false, delay)
        tween(icon, 0.25, { [iconProp] = 1 }, nil, nil, 0, false, delay)
        tween(scale, 0.3, { Scale = 0.7 }, nil, nil, 0, false, delay)
    end

    connect(btn.MouseEnter, function()
        if not obj.shown then return end
        tween(btn, 0.2, { BackgroundTransparency = HOVER })
        tween(scale, 0.25, { Scale = 1.08 })
    end)
    connect(btn.MouseLeave, function()
        if not obj.shown then return end
        tween(btn, 0.25, { BackgroundTransparency = REST })
        tween(scale, 0.3, { Scale = 1 })
    end)
    connect(btn.MouseButton1Down, function()
        if obj.shown then tween(scale, 0.12, { Scale = 0.92 }) end
    end)
    connect(btn.MouseButton1Up, function()
        if obj.shown then tween(scale, 0.35, { Scale = 1.08 }, Back) end
    end)
    connect(btn.MouseButton1Click, function()
        if obj.shown and not state.busy then onClick() end
    end)
    return obj
end

-- 3D-переход: слой «отдаляется», уезжает, новый приезжает и «приближается»
local function openSection(name)
    if state.section or state.busy or not state.unlocked then return end
    local sec = sections[name]
    local d = DIRS[sec.dir]
    state.busy, state.section = true, name

    for i, b in ipairs(dockButtons) do b.hide((i - 1) * 0.03) end

    sec.frame.Position = d.from
    sec.scale.Scale = DEPTH
    sec.frame.Visible = true

    tween(homeScale, 0.35, { Scale = DEPTH }, Quad, Out)                           -- отдаляется
    tween(home, 0.75, { Position = d.home }, Quint, InOut, 0, false, 0.2)          -- уезжает
    tween(sec.frame, 0.75, { Position = CENTER }, Quint, InOut, 0, false, 0.2)    -- вкладка приезжает
    tween(wall, 0.95, { Position = d.wall }, Quint, InOut, 0, false, 0.15)        -- параллакс фона
    tween(sec.scale, 0.45, { Scale = 1 }, Quint, Out, 0, false, 0.9)               -- приближается

    sec.arrow.show(1.0)
    task.delay(1.3, function()
        home.Visible = false
        state.busy = false
        if sec.onOpen then sec.onOpen() end
    end)
end

local function closeSection()
    local name = state.section
    if not name or state.busy then return end
    local sec = sections[name]
    state.busy = true

    sec.arrow.hide()
    home.Visible = true

    tween(sec.scale, 0.35, { Scale = DEPTH }, Quad, Out)
    tween(sec.frame, 0.75, { Position = DIRS[sec.dir].from }, Quint, InOut, 0, false, 0.2)
    tween(home, 0.75, { Position = CENTER }, Quint, InOut, 0, false, 0.2)
    tween(wall, 0.95, { Position = CENTER }, Quint, InOut, 0, false, 0.15)
    tween(homeScale, 0.45, { Scale = 1 }, Quint, Out, 0, false, 0.9)

    for i, b in ipairs(dockButtons) do b.show(0.95 + (i - 1) * 0.06) end
    task.delay(1.3, function()
        sec.frame.Visible = false
        state.section = nil
        state.busy = false
    end)
end

local function shutdown()
    if state.busy then return end
    state.busy = true
    for i, b in ipairs(dockButtons) do b.hide((i - 1) * 0.03) end
    tween(homeScale, 0.9, { Scale = 0.94 }, Quad, InOut)
    fadeOut(lock, 0.9)
    task.delay(1.0, function()
        for _, c in ipairs(connections) do c:Disconnect() end
        gui:Destroy()
    end)
end

local function unlock()
    if state.unlocked then return end
    state.unlocked = true
    state.busy = true
    if hintPulse then hintPulse:Cancel() end
    tween(hint, 0.3, { TextTransparency = 1 })
    tween(clockHolder, 0.8, { Position = UDim2.fromScale(0.5, 0.33) })
    tween(dateLabel, 0.6, { TextTransparency = 0.3 })
    tween(timeLabel, 0.6, { TextTransparency = 0.15 })
    for i, b in ipairs(dockButtons) do b.show(0.25 + (i - 1) * 0.07) end
    task.delay(0.9, function() state.busy = false end)
end

------------------------------------------------------------------
-- СТИЛЬ ПАНЕЛЕЙ (стекло в цветах обоев)
------------------------------------------------------------------
local C = {
    panel  = Color3.fromRGB(22, 18, 52),
    text   = Color3.fromRGB(238, 236, 252),
    sub    = Color3.fromRGB(168, 162, 210),
    accent = Color3.fromRGB(124, 104, 255),
    ok     = Color3.fromRGB(96, 224, 158),
    bad    = Color3.fromRGB(255, 96, 128),
    warn   = Color3.fromRGB(255, 186, 84),
    alt    = Color3.fromRGB(140, 170, 255),
}

local function text(parent, props)
    local p = {
        Parent = parent, BackgroundTransparency = 1, FontFace = FONT_UI_B, TextSize = 16,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd,
    }
    for k, v in pairs(props) do p[k] = v end
    return new("TextLabel", p)
end

local function stroke(t) return new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = t or 0.86, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end

-- Большая стеклянная панель по центру экрана
local function glassPanel(parent)
    local panel = new("Frame", {
        Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42),
        Size = UDim2.fromScale(0.64, 0.64), BackgroundColor3 = C.panel, BackgroundTransparency = 0.28,
    }, {
        corner(UDim.new(0, 24)), stroke(0.84),
        new("UISizeConstraint", { MaxSize = Vector2.new(940, 600), MinSize = Vector2.new(720, 400) }),
        new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 185, 225)),
            Transparency = NumberSequence.new(0, 0.12),
        }),
        new("UIPadding", {
            PaddingTop = UDim.new(0, 22), PaddingBottom = UDim.new(0, 22),
            PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24),
        }),
    })
    return panel
end

local function header(panel, title, subtitle)
    text(panel, { Text = title, TextSize = 26, Size = UDim2.new(1, 0, 0, 32) })
    text(panel, { Text = subtitle, TextSize = 15, TextColor3 = C.sub, Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 20) })
end

-- Кнопка-пилюля
local function pillButton(parent, label, primary, props, onClick)
    local base = primary and 0 or 0.9
    local btn = new("TextButton", {
        Parent = parent, AutoButtonColor = false, Text = label, FontFace = FONT_UI_B, TextSize = 15,
        TextColor3 = C.text, BackgroundColor3 = primary and C.accent or Color3.new(1, 1, 1),
        BackgroundTransparency = base, Size = UDim2.new(0, 132, 0, 38),
    }, { corner(), stroke(primary and 0.7 or 0.85) })
    for k, v in pairs(props or {}) do btn[k] = v end
    local sc = new("UIScale", { Parent = btn })
    connect(btn.MouseEnter, function() tween(btn, 0.2, { BackgroundTransparency = math.max(base - 0.06, 0) }); tween(sc, 0.2, { Scale = 1.04 }) end)
    connect(btn.MouseLeave, function() tween(btn, 0.25, { BackgroundTransparency = base }); tween(sc, 0.25, { Scale = 1 }) end)
    connect(btn.MouseButton1Down, function() tween(sc, 0.1, { Scale = 0.95 }) end)
    connect(btn.MouseButton1Up, function() tween(sc, 0.3, { Scale = 1.04 }, Back) end)
    connect(btn.MouseButton1Click, onClick)
    return btn
end

-- Маленький цветной «чип»
local function chip(parent, label, color, props)
    local f = new("TextLabel", {
        Parent = parent, Text = label, FontFace = FONT_UI_B, TextSize = 12, TextColor3 = color,
        BackgroundColor3 = color, BackgroundTransparency = 0.84, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 24), TextTruncate = Enum.TextTruncate.None,
    }, { corner(), new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
    for k, v in pairs(props or {}) do f[k] = v end
    return f
end

------------------------------------------------------------------
-- ПРОВЕРКА ФУНКЦИЙ ЭКЗЕКУТОРА (WannaDepCheck)
------------------------------------------------------------------
local DEP = {}
do
    local TEST_URL = "https://raw.githubusercontent.com/sergeydb-wq/scripts/wannaclient/README.md"
    local env = (getgenv and getgenv()) or _G
    local function g(name)
        local ok, v = pcall(function()
            local cur = getfenv and getfenv(0) or env
            for part in string.gmatch(name, "[^%.]+") do
                if cur == nil then return nil end
                cur = cur[part]
            end
            return cur
        end)
        if ok and v ~= nil then return v end
        ok, v = pcall(function() return env[name] end)
        return ok and v or nil
    end
    local function first(...)
        for _, n in ipairs({ ... }) do
            local v = g(n)
            if v ~= nil then return v, n end
        end
        return nil
    end
    DEP.first = first

    local DIR = "WannaDepCheck"
    local FILE = DIR .. "/test.txt"

    local T = {}
    T.loadstring = function()
        local f = first("loadstring")
        if type(f) ~= "function" then return false, "нет" end
        local chunk = f("return 1 + 1")
        return chunk and chunk() == 2, "работает"
    end
    T.httpget = function()
        local body = game:HttpGet(TEST_URL)
        return type(body) == "string" and #body > 0, "HttpGet: " .. #tostring(body) .. " байт"
    end
    T.folders = function()
        local isfolder, makefolder = first("isfolder"), first("makefolder")
        if not (isfolder and makefolder) then return false, "нет isfolder/makefolder" end
        if not isfolder(DIR) then makefolder(DIR) end
        return isfolder(DIR), "папки ок"
    end
    T.files = function()
        local writefile, readfile, isfile = first("writefile"), first("readfile"), first("isfile")
        if not (writefile and readfile and isfile) then return false, "нет write/read/isfile" end
        writefile(FILE, "wanna-ok")
        return isfile(FILE) and readfile(FILE) == "wanna-ok", "запись/чтение ок"
    end
    T.customasset = function()
        local gca, nm = first("getcustomasset", "getsynasset")
        local writefile = first("writefile")
        if not (gca and writefile) then return false, "нет — косметика без своих текстур" end
        writefile(DIR .. "/t.png", string.char(137, 80, 78, 71, 13, 10, 26, 10))
        local id = gca(DIR .. "/t.png")
        return type(id) == "string" and id:find("rbxasset") ~= nil, nm
    end
    T.request = function()
        local req, nm = first("request", "http_request", "syn.request", "http.request", "fluxus.request")
        if not req then return false, "нет — Community не подключится" end
        local r = req({ Url = TEST_URL, Method = "GET" })
        local code = r and (r.StatusCode or r.Status)
        return code == 200, nm .. " → " .. tostring(code)
    end
    T.hook = function()
        local hf = first("hookfunction", "replaceclosure", "hookfunc")
        if not hf then return false, "нет hookfunction" end
        local ncc = first("newcclosure")
        local function target() return 1 end
        local old = hf(target, (ncc or function(f) return f end)(function() return 2 end))
        local works = target() == 2
        pcall(hf, target, old)
        return works, ncc and "хук + newcclosure" or "хук есть, newcclosure нет"
    end
    T.vim = function()
        local vim = game:GetService("VirtualInputManager")
        return vim ~= nil and type(vim.SendMouseButtonEvent) == "function", "доступен"
    end
    T.gethui = function()
        local f, nm = first("gethui", "get_hidden_gui")
        if not f then return false, "нет — меню в CoreGui" end
        return typeof(f()) == "Instance", nm
    end
    T.clipboard = function()
        local f, nm = first("setclipboard", "toclipboard", "syn.write_clipboard", "Clipboard.set")
        return f ~= nil, f and nm or "нет"
    end
    T.listdel = function()
        local listfiles, delfile, isfile = first("listfiles"), first("delfile"), first("isfile")
        local parts, ok = {}, true
        if listfiles then
            local l = listfiles(DIR)
            ok = ok and type(l) == "table"
            table.insert(parts, "listfiles ок")
        else ok = false; table.insert(parts, "нет listfiles") end
        if delfile then
            delfile(FILE); pcall(delfile, DIR .. "/t.png")
            ok = ok and not (isfile and isfile(FILE))
            table.insert(parts, "delfile ок")
        else ok = false; table.insert(parts, "нет delfile") end
        return ok, table.concat(parts, ", ")
    end
    T.getgenv = function()
        local f = first("getgenv")
        return type(f) == "function" and type(f()) == "table", "ок"
    end
    T.identify = function()
        local f = first("identifyexecutor", "getexecutorname")
        local gi = first("getthreadidentity", "getidentity", "syn.get_thread_identity")
        local parts = {}
        if f then local a, b = f(); table.insert(parts, tostring(a) .. (b and (" " .. tostring(b)) or "")) end
        if gi then table.insert(parts, "identity " .. tostring(gi())) end
        return f ~= nil and gi ~= nil, #parts > 0 and table.concat(parts, ", ") or "нет"
    end
    T.mouse = function()
        local p, r = first("mouse1press"), first("mouse1release")
        return p ~= nil and r ~= nil, (p and r) and "есть" or "нет — метод VirtualInput"
    end
    T.virtualuser = function()
        return game:GetService("VirtualUser") ~= nil, "доступен"
    end
    DEP.tests = T

    -- kind: crit / imp / opt  (как в таблице)
    DEP.rows = {
        { kind = "crit", level = "Без этого не запустится", funcs = "loadstring, game:HttpGet", why = "загрузка самого скрипта", tests = { "loadstring", "httpget" } },
        { kind = "imp",  level = "Важно", funcs = "writefile, readfile, isfile, isfolder, makefolder", why = "конфиги, история Carry, файлы косметики", tests = { "folders", "files" } },
        { kind = "imp",  level = "Важно", funcs = "getcustomasset", why = "текстуры и звуки косметики", tests = { "customasset" } },
        { kind = "imp",  level = "Важно", funcs = "request (http_request, syn.request)", why = "Community: Global Chat, хаб", tests = { "request" } },
        { kind = "imp",  level = "Важно · WannaBloc", funcs = "hookfunction (+ newcclosure)", why = "No Suffocation", tests = { "hook" } },
        { kind = "imp",  level = "Важно · WannaBloc", funcs = "VirtualInputManager", why = "автоклик в фарме", tests = { "vim" } },
        { kind = "opt",  level = "Есть замена", funcs = "gethui", why = "без него меню кладётся в CoreGui", tests = { "gethui" } },
        { kind = "opt",  level = "Есть замена", funcs = "setclipboard / toclipboard", why = "кнопки «скопировать»", tests = { "clipboard" } },
        { kind = "opt",  level = "Есть замена", funcs = "listfiles, delfile", why = "список и удаление конфигов", tests = { "listdel" } },
        { kind = "opt",  level = "Есть замена", funcs = "getgenv", why = "выгрузка старой копии при перезапуске", tests = { "getgenv" } },
        { kind = "opt",  level = "Есть замена", funcs = "identifyexecutor, getthreadidentity", why = "только для информации", tests = { "identify" } },
        { kind = "opt",  level = "Есть замена · WannaBloc", funcs = "mouse1press / mouse1release", why = "запасной метод клика", tests = { "mouse" } },
        { kind = "opt",  level = "Есть замена · WannaCarry", funcs = "VirtualUser", why = "Anti-AFK", tests = { "virtualuser" } },
    }

    function DEP.executor()
        local name = "Неизвестно"
        pcall(function()
            local f = first("identifyexecutor", "getexecutorname")
            if f then local a, b = f(); name = tostring(a) .. (b and (" " .. tostring(b)) or "") end
        end)
        local ident = "?"
        pcall(function()
            local gi = first("getthreadidentity", "getidentity", "syn.get_thread_identity")
            if gi then ident = tostring(gi()) end
        end)
        return name, ident
    end

    function DEP.cleanup()
        pcall(function() local df = first("delfolder"); if df then df(DIR) end end)
    end
end

local KIND_COLOR = { crit = C.bad, imp = C.warn, opt = C.alt }

------------------------------------------------------------------
-- ВКЛАДКА 1: ПОДДЕРЖКА ФУНКЦИЙ
------------------------------------------------------------------
local function buildSupport(content)
    local panel = glassPanel(content)
    header(panel, "Поддержка функций", "Что умеет твой экзекутор и что из этого нужно скриптам")

    -- Карточка экзекутора
    local card = new("Frame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, 68), Size = UDim2.new(1, 0, 0, 84),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.94,
    }, { corner(UDim.new(0, 16)), stroke(0.9) })

    local execName, ident = DEP.executor()
    text(card, { Text = "ТВОЙ ЭКЗЕКУТОР", TextSize = 12, TextColor3 = C.sub, Position = UDim2.new(0, 18, 0, 10), Size = UDim2.new(0.4, 0, 0, 16) })
    text(card, { Text = execName .. "   ·   identity " .. ident, TextSize = 20, Position = UDim2.new(0, 18, 0, 27), Size = UDim2.new(1, -320, 0, 24) })

    local verdict = text(card, {
        Text = "Нажми «Проверить»", TextSize = 14, TextColor3 = C.sub,
        Position = UDim2.new(0, 18, 0, 54), Size = UDim2.new(1, -320, 0, 20),
    })

    local copyBtn, checkBtn
    local report = ""
    copyBtn = pillButton(card, "Скопировать", false, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -158, 0.5, 0), Size = UDim2.new(0, 124, 0, 38),
    }, function()
        local f = DEP.first("setclipboard", "toclipboard")
        if f and report ~= "" then pcall(f, report); copyBtn.Text = "Скопировано" else copyBtn.Text = "Нечего / нет функции" end
        task.delay(1.5, function() if copyBtn.Parent then copyBtn.Text = "Скопировать" end end)
    end)

    -- Таблица
    local tableTop = 168
    local COLS = { { "Уровень", 0, 0.24 }, { "Функции", 0.24, 0.32 }, { "Для чего", 0.56, 0.30 }, { "Статус", 0.86, 0.14 } }
    local head = new("Frame", { Parent = panel, Position = UDim2.new(0, 0, 0, tableTop), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 })
    for _, col in ipairs(COLS) do
        text(head, { Text = col[1]:upper(), TextSize = 12, TextColor3 = C.sub,
            Position = UDim2.new(col[2], 14, 0, 0), Size = UDim2.new(col[3], -14, 1, 0) })
    end

    local list = new("ScrollingFrame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, tableTop + 28), Size = UDim2.new(1, 0, 1, -(tableTop + 28)),
        BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.new(1, 1, 1), ScrollBarImageTransparency = 0.6,
    }, {
        new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
        new("UIPadding", { PaddingRight = UDim.new(0, 8) }),
    })

    local rowUI = {}
    for i, row in ipairs(DEP.rows) do
        local r = new("Frame", {
            Parent = list, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 58),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.955,
        }, { corner(UDim.new(0, 12)) })
        connect(r.MouseEnter, function() tween(r, 0.2, { BackgroundTransparency = 0.92 }) end)
        connect(r.MouseLeave, function() tween(r, 0.25, { BackgroundTransparency = 0.955 }) end)

        local lvl = new("Frame", { Parent = r, Position = UDim2.new(COLS[1][2], 12, 0, 0), Size = UDim2.new(COLS[1][3], -12, 1, 0), BackgroundTransparency = 1 })
        chip(lvl, row.level, KIND_COLOR[row.kind], { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0) })

        text(r, { Text = row.funcs, TextSize = 14, TextWrapped = true, TextTruncate = Enum.TextTruncate.None,
            Position = UDim2.new(COLS[2][2], 14, 0, 6), Size = UDim2.new(COLS[2][3], -18, 0, 32) })
        local info = text(r, { Text = "", TextSize = 12, TextColor3 = C.sub,
            Position = UDim2.new(COLS[2][2], 14, 0, 38), Size = UDim2.new(COLS[2][3] + COLS[3][3], -18, 0, 16) })
        text(r, { Text = row.why, TextSize = 14, TextColor3 = C.sub, TextWrapped = true, TextTruncate = Enum.TextTruncate.None,
            Position = UDim2.new(COLS[3][2], 14, 0, 6), Size = UDim2.new(COLS[3][3], -18, 0, 32) })

        local status = chip(r, "—", C.sub, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(COLS[4][2], 14, 0.5, 0) })
        rowUI[i] = { status = status, info = info }
    end

    -- Запуск проверки
    local running = false
    local function runCheck()
        if running then return end
        running = true
        checkBtn.Text = "Проверяю…"
        verdict.TextColor3 = C.sub
        verdict.Text = "Идёт проверка…"
        for _, ui in ipairs(rowUI) do
            ui.status.Text = "…"; ui.status.TextColor3 = C.sub; ui.status.BackgroundColor3 = C.sub
            ui.info.Text = ""
        end

        local fails = { crit = 0, imp = 0, opt = 0 }
        local lines = { "=== WannaDepCheck · экзекутор: " .. (DEP.executor()) .. " ===" }
        for i, row in ipairs(DEP.rows) do
            local allOk, infos = true, {}
            for _, key in ipairs(row.tests) do
                local ok, res, inf = pcall(DEP.tests[key])
                if not ok then allOk = false; table.insert(infos, "ошибка: " .. tostring(res))
                else
                    if not res then allOk = false end
                    if inf and inf ~= "" then table.insert(infos, inf) end
                end
            end
            if not allOk then fails[row.kind] += 1 end

            local ui = rowUI[i]
            local col = allOk and C.ok or (row.kind == "opt" and C.warn or C.bad)
            ui.status.Text = allOk and "✓  OK" or "✕  НЕТ"
            ui.status.TextColor3 = col
            ui.status.BackgroundColor3 = col
            ui.status.TextTransparency = 1
            tween(ui.status, 0.35, { TextTransparency = 0 })
            ui.info.Text = table.concat(infos, " · ")
            table.insert(lines, ("[%s] %s | %s | %s"):format(allOk and "OK" or "НЕТ", row.level, row.funcs, ui.info.Text))
            task.wait(0.05)
        end
        DEP.cleanup()

        local v, col
        if fails.crit > 0 then
            v, col = "Не запустится: нет критичных функций", C.bad
        elseif fails.imp > 0 then
            v, col = ("Запустится, но %d важн. функц. не работают"):format(fails.imp), C.warn
        else
            v, col = "Всё нужное есть" .. (fails.opt > 0 and (" (без замен: " .. fails.opt .. ")") or ""), C.ok
        end
        verdict.Text = v
        verdict.TextColor3 = col
        verdict.TextTransparency = 1
        tween(verdict, 0.4, { TextTransparency = 0 })
        table.insert(lines, "ИТОГ: " .. v)
        report = table.concat(lines, "\n")
        print(report)

        checkBtn.Text = "Проверить снова"
        running = false
    end

    checkBtn = pillButton(card, "Проверить", true, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 136, 0, 38),
    }, function() task.spawn(runCheck) end)

    -- При первом открытии вкладки проверка запускается сама
    local done = false
    return function()
        if not done then done = true; task.spawn(runCheck) end
    end
end

------------------------------------------------------------------
-- ВКЛАДКА 2: ПОДДЕРЖИВАЕМЫЕ ИГРЫ
------------------------------------------------------------------
local function buildGames(content)
    local panel = glassPanel(content)
    header(panel, "Скрипты", "Выбери скрипт и нажми «Запустить»")

    local grid = new("ScrollingFrame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, 72), Size = UDim2.new(1, 0, 1, -72),
        BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.new(1, 1, 1), ScrollBarImageTransparency = 0.6,
    }, {
        new("UIGridLayout", {
            CellSize = UDim2.new(1 / 3, -12, 0, 190), CellPadding = UDim2.new(0, 12, 0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        new("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2) }),
    })

    if #CONFIG.Games == 0 then
        text(panel, { Text = "Скоро здесь появятся игры", TextSize = 18, TextColor3 = C.sub,
            TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 24) })
        return
    end

    for i, info in ipairs(CONFIG.Games) do
        local ready = info.Script and info.Script ~= ""
        local places = info.Places or {}
        local universal = #places == 0
        local here = table.find(places, game.PlaceId) ~= nil
        local img = info.Image and loadAsset("game" .. i, info.Image)

        local card = new("Frame", {
            Parent = grid, LayoutOrder = i, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.94,
        }, { corner(UDim.new(0, 18)) })
        local cs = stroke(here and 0.55 or 0.88); cs.Parent = card
        if here then cs.Color = C.accent end
        local sc = new("UIScale", { Parent = card })

        -- Обложка
        local cover = new("Frame", {
            Parent = card, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 0, 96),
            BackgroundColor3 = Color3.new(1, 1, 1),
        }, {
            corner(UDim.new(0, 12)),
            new("UIGradient", {
                Rotation = 35,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 28, 110)),
                    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(124, 104, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 180, 255)),
                }),
            }),
        })
        if img and info.Fit then
            new("ImageLabel", {
                Parent = cover, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.62, 0.62), BackgroundTransparency = 1,
                Image = img, ScaleType = Enum.ScaleType.Fit,
            })
        elseif img then
            new("ImageLabel", {
                Parent = cover, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                Image = img, ScaleType = Enum.ScaleType.Crop,
            }, { corner(UDim.new(0, 12)) })
        else
            text(cover, { Text = info.Name:sub(1, 1):upper(), TextSize = 54, TextXAlignment = Enum.TextXAlignment.Center,
                FontFace = FONT_CLOCK, Size = UDim2.fromScale(1, 1), TextTransparency = 0.1 })
        end

        text(card, { Text = info.Name, TextSize = 16, Position = UDim2.new(0, 16, 0, 110), Size = UDim2.new(1, -32, 0, 24) })
        local status, statusCol
        if not ready then status, statusCol = "Скоро", C.sub
        elseif info.Premium then status, statusCol = "🔑 По ключу", C.accent
        else status, statusCol = "Бесплатно", C.ok end
        if here then status = status .. " · тут" end
        chip(card, status, statusCol, {
            Position = UDim2.new(0, 14, 1, -38),
        })

        local btn
        btn = pillButton(card, ready and "Запустить" or "Скоро", ready, {
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -10), Size = UDim2.new(0, 104, 0, 32), TextSize = 14,
        }, function()
            if not ready then
                tween(sc, 0.08, { Scale = 0.97 }); task.delay(0.08, function() tween(sc, 0.3, { Scale = 1 }, Back) end)
                return
            end
            btn.Text = "Загрузка…"
            task.spawn(function()
                local ok, err = pcall(function() loadstring(game:HttpGet(info.Script), "@" .. info.Name)() end)
                if btn.Parent then btn.Text = ok and "Запущено" or "Ошибка" end
                if not ok then warn("[W] " .. info.Name .. ": " .. tostring(err)) end
            end)
        end)

        connect(card.MouseEnter, function()
            tween(sc, 0.25, { Scale = 1.03 }); tween(card, 0.2, { BackgroundTransparency = 0.91 })
            tween(cs, 0.2, { Transparency = here and 0.4 or 0.75 })
        end)
        connect(card.MouseLeave, function()
            tween(sc, 0.3, { Scale = 1 }); tween(card, 0.25, { BackgroundTransparency = 0.94 })
            tween(cs, 0.25, { Transparency = here and 0.55 or 0.88 })
        end)
    end
end

------------------------------------------------------------------
-- ВКЛАДКА 3: НАСТРОЙКИ (ключ доступа)
------------------------------------------------------------------
local function maskKey(k)
    if #k <= 10 then return k end
    return k:sub(1, 6) .. "••••-••••-" .. k:sub(-4)
end

local function buildSettings(content)
    local panel = glassPanel(content)
    header(panel, "Настройки", "Ключ доступа к WannaBloc и WannaCarry")

    local card = new("Frame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, 72), Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.94,
    }, { corner(UDim.new(0, 16)), stroke(0.9) })
    text(card, { Text = "СОХРАНЁННЫЙ КЛЮЧ", TextSize = 12, TextColor3 = C.sub, Position = UDim2.new(0, 18, 0, 14), Size = UDim2.new(1, -36, 0, 16) })
    local keyLbl = text(card, { Text = "—", TextSize = 24, Position = UDim2.new(0, 18, 0, 32), Size = UDim2.new(1, -36, 0, 30) })
    local stLbl = text(card, { Text = "", TextSize = 15, TextColor3 = C.sub, Position = UDim2.new(0, 18, 0, 64), Size = UDim2.new(1, -36, 0, 20) })

    local row = new("Frame", {
        Parent = card, Position = UDim2.new(0, 18, 1, -56), Size = UDim2.new(1, -36, 0, 40), BackgroundTransparency = 1,
    }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local refresh
    local enterBtn = pillButton(row, "Ввести ключ", true, { LayoutOrder = 1, Size = UDim2.new(0, 150, 0, 40) }, function()
        if KeySys then KeySys.prompt(nil, function() refresh(true) end) end
    end)
    local checkBtn = pillButton(row, "Проверить", false, { LayoutOrder = 2, Size = UDim2.new(0, 130, 0, 40) }, function()
        refresh(true)
    end)
    local forgetBtn
    forgetBtn = pillButton(row, "Забыть ключ", false, { LayoutOrder = 3, Size = UDim2.new(0, 140, 0, 40), TextColor3 = C.bad }, function()
        if not KeySys then return end
        KeySys.forget()
        refresh(false)
        stLbl.Text = "Ключ удалён с этого ПК"
    end)

    -- Telegram-бот
    local bot = new("Frame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, 236), Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.94,
    }, { corner(UDim.new(0, 16)), stroke(0.9) })
    text(bot, { Text = "Telegram-бот", TextSize = 18, Position = UDim2.new(0, 18, 0, 14), Size = UDim2.new(1, -200, 0, 24) })
    text(bot, { Text = "Купить ключ, посмотреть срок, сбросить HWID при смене ПК", TextSize = 14, TextColor3 = C.sub,
        Position = UDim2.new(0, 18, 0, 38), Size = UDim2.new(1, -200, 0, 20) })
    local linkBtn
    linkBtn = pillButton(bot, "Скопировать ссылку", false, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.new(0, 170, 0, 40),
    }, function()
        local url = KeySys and KeySys.botUrl() or ""
        local clip = DEP.first("setclipboard", "toclipboard")
        if url ~= "" and clip then pcall(clip, url); linkBtn.Text = "Скопировано"
        else linkBtn.Text = url ~= "" and url or "Сервер недоступен" end
        task.delay(1.6, function() if linkBtn.Parent then linkBtn.Text = "Скопировать ссылку" end end)
    end)

    local checking = false
    refresh = function(doCheck)
        if not KeySys then
            keyLbl.Text = "—"
            stLbl.Text = "Модуль ключей не загрузился (нет связи с GitHub)"
            stLbl.TextColor3 = C.bad
            return
        end
        local key = KeySys.saved()
        forgetBtn.Visible = key ~= nil
        if not key then
            keyLbl.Text = "Ключ не сохранён"
            stLbl.Text = "Нажми «Ввести ключ» — он запомнится на этом ПК"
            stLbl.TextColor3 = C.sub
            return
        end
        keyLbl.Text = maskKey(key)
        if not doCheck or checking then return end
        checking = true
        stLbl.Text = "Проверяю…"
        stLbl.TextColor3 = C.sub
        task.spawn(function()
            local res = KeySys.check(key)
            checking = false
            if not stLbl.Parent then return end
            if res.ok then
                stLbl.Text = "✓ Активен · осталось: " .. tostring(res.left_text or "навсегда")
                stLbl.TextColor3 = C.ok
            else
                stLbl.Text = "✕ " .. tostring(res.reason)
                stLbl.TextColor3 = C.bad
            end
            stLbl.TextTransparency = 1
            tween(stLbl, 0.35, { TextTransparency = 0 })
        end)
    end

    refresh(false)
    return function() refresh(true) end -- проверка при каждом открытии
end

local function buildSection(name, dir, builder)
    local frame = new("Frame", {
        Parent = lock, ZIndex = 4, Visible = false, Name = "Section_" .. name,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = DIRS[dir].from,
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    })
    local scale = new("UIScale", { Parent = frame, Scale = DEPTH })

    -- Здесь будет содержимое вкладки (пока пусто)
    local content = new("Frame", {
        Parent = frame, Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    })
    local onOpen = builder and builder(content)

    local arrow = makeRoundButton(frame, ASSET.Arrow, ({ left = "←", down = "↓", right = "→" })[dir], {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.8),
    }, closeSection)
    if ASSET.Arrow then arrow.icon.Rotation = DIRS[dir].arrow end

    sections[name] = { frame = frame, scale = scale, content = content, arrow = arrow, dir = dir, onOpen = onOpen }
end

local function buildLockScreen()
    lock = new("Frame", {
        Parent = gui, ZIndex = 1, Size = UDim2.fromScale(1, 1), ClipsDescendants = true,
        BackgroundColor3 = Color3.fromRGB(10, 9, 22), BackgroundTransparency = 0, BorderSizePixel = 0,
    })

    -- Обои (чуть больше экрана — для параллакса)
    local wallProps = {
        Parent = lock, AnchorPoint = Vector2.new(0.5, 0.5), Position = CENTER,
        Size = UDim2.fromScale(1.14, 1.14), BorderSizePixel = 0,
    }
    if ASSET.Wallpaper then
        wallProps.BackgroundTransparency = 1
        wallProps.Image = ASSET.Wallpaper
        wallProps.ScaleType = Enum.ScaleType.Crop
        wall = new("ImageLabel", wallProps)
    else
        wallProps.BackgroundColor3 = Color3.new(1, 1, 1)
        wall = new("Frame", wallProps, {
            new("UIGradient", {
                Rotation = 35,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 12, 34)),
                    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(64, 44, 170)),
                    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(150, 140, 215)),
                    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(58, 40, 150)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 12, 34)),
                }),
            }),
        })
    end
    local wallScale = new("UIScale", { Parent = wall, Scale = 1 })
    tween(wallScale, 14, { Scale = 1.05 }, Sine, InOut, -1, true)

    new("Frame", {
        Parent = lock, Name = "Dim", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55,
    })

    -- Главное меню (всё, что уезжает при открытии вкладки)
    home = new("Frame", {
        Parent = lock, ZIndex = 3, Name = "Home", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = CENTER, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    })
    homeScale = new("UIScale", { Parent = home, Scale = 1 })

    clockHolder = new("Frame", {
        Parent = home, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47),
        Size = UDim2.new(0, 640, 0, 200), BackgroundTransparency = 1,
    })
    dateLabel = new("TextLabel", {
        Parent = clockHolder, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
        FontFace = FONT_UI_B, TextSize = 34, TextColor3 = Color3.fromRGB(215, 215, 225),
        TextTransparency = 0.55, Text = "",
    })
    timeLabel = new("TextLabel", {
        Parent = clockHolder, Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 150),
        BackgroundTransparency = 1, FontFace = FONT_CLOCK, TextSize = 150,
        TextColor3 = Color3.fromRGB(215, 215, 225), TextTransparency = 0.5, Text = "",
    })
    hint = new("TextLabel", {
        Parent = home, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -22),
        Size = UDim2.new(0, 400, 0, 30), BackgroundTransparency = 1,
        FontFace = FONT_UI_B, TextSize = 22, TextColor3 = Color3.fromRGB(215, 215, 225),
        TextTransparency = 0.4, Text = "Кликните для продолжения",
    })
    hintPulse = tween(hint, 1.6, { TextTransparency = 0.8 }, Sine, InOut, -1, true)

    local catcher = new("TextButton", {
        Parent = home, ZIndex = 5, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
    })
    connect(catcher.MouseButton1Click, function()
        catcher:Destroy()
        unlock()
    end)

    local dock = new("Frame", {
        Parent = home, ZIndex = 3, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.8),
        Size = UDim2.new(0, 4 * 68 + 3 * 20, 0, 68), BackgroundTransparency = 1,
    }, {
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 20),
            HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    dockButtons = {
        makeRoundButton(dock, ASSET.User,     "👤", { LayoutOrder = 1 }, function() openSection("profile") end),
        makeRoundButton(dock, ASSET.Users,    "👥", { LayoutOrder = 2 }, function() openSection("players") end),
        makeRoundButton(dock, ASSET.Settings, "⚙",  { LayoutOrder = 3 }, function() openSection("settings") end),
        makeRoundButton(dock, ASSET.Power,    "⏻",  { LayoutOrder = 4 }, shutdown),
    }

    -- Вкладки: профиль (поддержка функций) — меню влево, игры — вниз, настройки (ключ) — вправо
    buildSection("profile", "left", buildSupport)
    buildSection("players", "down", buildGames)
    buildSection("settings", "right", buildSettings)

    task.spawn(function()
        while gui.Parent do
            local t = os.date("*t")
            dateLabel.Text = ("%s, %d %s"):format(WEEKDAYS[t.wday], t.day, MONTHS[t.month])
            timeLabel.Text = ("%02d:%02d"):format(t.hour, t.min)
            task.wait(1)
        end
    end)
end

------------------------------------------------------------------
-- ЗАПУСК
------------------------------------------------------------------
connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.ToggleKey then gui.Enabled = not gui.Enabled end
end)

task.spawn(function()
    local started = os.clock()

    if logo:IsA("ImageLabel") then
        tween(logo, 0.9, { ImageTransparency = 0 })
    else
        tween(logo, 0.9, { TextTransparency = 0 })
    end
    tween(logoScale, 1.1, { Scale = 1 }, Back)
    tween(barBack, 0.6, { BackgroundTransparency = 0.85 }, nil, nil, 0, false, 0.3)
    tween(barFill, 0.6, { BackgroundTransparency = 0 }, nil, nil, 0, false, 0.3)
    local shine = tween(logoShine, 1.6, { Offset = Vector2.new(1, 0) }, Sine, InOut, -1, false, 0.4)

    local order = { "Wallpaper", "User", "Users", "Settings", "Power", "Arrow" }
    for i, key in ipairs(order) do
        ASSET[key] = loadAsset(key:lower(), CONFIG.Assets[key])
        tween(barFill, 0.4, { Size = UDim2.new(i / #order * 0.9, 0, 1, 0) })
    end

    pcall(function()
        KeySys = loadstring(game:HttpGet(CONFIG.KeySysUrl), "@keysys")()
    end)

    buildLockScreen()

    local left = CONFIG.MinLoadTime - (os.clock() - started)
    if left > 0 then task.wait(left) end
    tween(barFill, 0.35, { Size = UDim2.new(1, 0, 1, 0) })
    task.wait(0.45)

    -- Переход: лого чуть увеличивается, чёрный экран растворяется
    shine:Cancel()
    tween(logoScale, 0.7, { Scale = 1.12 }, Quint, In)
    fadeOut(loading, 0.8)
    task.wait(0.9)
    loading:Destroy()
end)
