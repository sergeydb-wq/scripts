--[[
    WannaCry · система ключей
    Используется премиум-скриптами (WannaBloc, WannaCarry) и хабом.
    Ключ хранится на ПК: workspace/wannacry/keys.json  (кнопка «Забыть ключ» удаляет его)
]]

local KeySys = {}

-- Адрес сервера ключей (IP:порт с панели хостинга)
KeySys.API = "http://78.154.103.26:13968"

local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")

local FOLDER, FILE = "wannacry", "wannacry/keys.json"

------------------------------------------------------------------
-- утилиты
------------------------------------------------------------------
local function configured()
    return KeySys.API ~= "" and not KeySys.API:find("SERVER_IP", 1, true)
end

local function enc(s) return HttpService:UrlEncode(tostring(s or "")) end

local function getJSON(url)
    local ok, body = pcall(game.HttpGet, game, url)
    if not ok then return nil, "Сервер ключей недоступен" end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok2 or type(data) ~= "table" then return nil, "Странный ответ сервера" end
    return data
end

function KeySys.hwid()
    if KeySys._hwid then return KeySys._hwid end
    local id
    local env = (getgenv and getgenv()) or getfenv(0)
    local candidates = { env.gethwid, env.get_hwid, env.syn and env.syn.gethwid }
    for i = 1, 3 do
        local fn = candidates[i]
        if type(fn) == "function" then
            local ok, v = pcall(fn)
            if ok and v and tostring(v) ~= "" then id = tostring(v) break end
        end
    end
    if not id then
        pcall(function() id = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end
    KeySys._hwid = id or ("uid-" .. Players.LocalPlayer.UserId)
    return KeySys._hwid
end

------------------------------------------------------------------
-- сохранение ключей на ПК
------------------------------------------------------------------
local function readStore()
    if not (isfile and readfile) then return {} end
    local ok, data = pcall(function()
        if not isfile(FILE) then return {} end
        return HttpService:JSONDecode(readfile(FILE))
    end)
    return (ok and type(data) == "table") and data or {}
end

local function writeStore(t)
    if not writefile then return end
    pcall(function()
        if isfolder and makefolder and not isfolder(FOLDER) then makefolder(FOLDER) end
        writefile(FILE, HttpService:JSONEncode(t))
    end)
end

-- Сохранённый ключ: для конкретного скрипта, иначе последний введённый
function KeySys.saved(name)
    local t = readStore()
    return (name and t[name]) or t.last
end

function KeySys.save(key, name)
    local t = readStore()
    t.last = key
    if name then t[name] = key end
    writeStore(t)
end

-- Забыть ключ: для скрипта (name) или все ключи (без аргумента)
function KeySys.forget(name)
    if name then
        local t = readStore()
        if t.last == t[name] then t.last = nil end
        t[name] = nil
        writeStore(t)
    else
        writeStore({})
        if delfile and isfile then pcall(function() if isfile(FILE) then delfile(FILE) end end) end
    end
end

------------------------------------------------------------------
-- сервер
------------------------------------------------------------------
function KeySys.check(key, name)
    if not configured() then return { ok = false, reason = "Сервер ключей не настроен" } end
    local data, err = getJSON(("%s/api/check?key=%s&hwid=%s&script=%s"):format(
        KeySys.API, enc(key), enc(KeySys.hwid()), enc(name or "")))
    return data or { ok = false, reason = err }
end

function KeySys.botUrl()
    if KeySys._bot then return KeySys._bot end
    if not configured() then return "" end
    local data = getJSON(KeySys.API .. "/api/info")
    KeySys._bot = (data and data.bot_url) or ""
    return KeySys._bot
end

function KeySys.launch(name, key, res)
    res = res or KeySys.check(key, name)
    -- срок ключа для самого скрипта (надпись «N days left» в профиле)
    local env = (getgenv and getgenv()) or _G
    env.WannaKey = { key = key, script = name, left = res and res.left, expires_at = res and res.expires_at }
    local src = game:HttpGet(("%s/api/script?name=%s&key=%s&hwid=%s"):format(
        KeySys.API, enc(name), enc(key), enc(KeySys.hwid())))
    local fn, err = loadstring(src, "@" .. name)
    if not fn then error("[WannaCry] " .. name .. " не загрузился: " .. tostring(err), 0) end
    return fn()
end

------------------------------------------------------------------
-- окно ввода ключа (стиль хаба: стекло в цветах обоев)
------------------------------------------------------------------
local C = {
    panel  = Color3.fromRGB(22, 18, 52),
    text   = Color3.fromRGB(238, 236, 252),
    sub    = Color3.fromRGB(168, 162, 210),
    accent = Color3.fromRGB(124, 104, 255),
    ok     = Color3.fromRGB(96, 224, 158),
    bad    = Color3.fromRGB(255, 96, 128),
}
local FONT   = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
local FONT_M = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold)

local function new(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end
local function tw(o, t, p, s, d, delay)
    local x = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out, 0, false, delay or 0), p)
    x:Play()
    return x
end
local function corner(r) return new("UICorner", { CornerRadius = r or UDim.new(1, 0) }) end
local function stroke(t) return new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = t or 0.86, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end

local FADE = {
    Frame = { "BackgroundTransparency" }, TextLabel = { "BackgroundTransparency", "TextTransparency" },
    TextButton = { "BackgroundTransparency", "TextTransparency" }, TextBox = { "BackgroundTransparency", "TextTransparency" },
    ImageLabel = { "BackgroundTransparency", "ImageTransparency" }, UIStroke = { "Transparency" },
}
local function fadeAll(root, t)
    local list = root:GetDescendants(); table.insert(list, root)
    for _, o in ipairs(list) do
        local ps = FADE[o.ClassName]
        if ps then
            local g = {}
            for _, p in ipairs(ps) do g[p] = 1 end
            tw(o, t, g, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        end
    end
end

local function parentGui(gui)
    local ok = false
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then ok = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not ok or not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
end

local function button(parent, label, primary, props)
    local base = primary and 0 or 0.9
    local b = new("TextButton", {
        Parent = parent, AutoButtonColor = false, Text = label, FontFace = FONT, TextSize = 15,
        TextColor3 = C.text, BackgroundColor3 = primary and C.accent or Color3.new(1, 1, 1),
        BackgroundTransparency = base,
    }, { corner(), stroke(primary and 0.7 or 0.85) })
    for k, v in pairs(props or {}) do b[k] = v end
    local sc = new("UIScale", { Parent = b })
    b.MouseEnter:Connect(function() tw(b, 0.2, { BackgroundTransparency = math.max(base - 0.06, 0) }); tw(sc, 0.2, { Scale = 1.04 }) end)
    b.MouseLeave:Connect(function() tw(b, 0.25, { BackgroundTransparency = base }); tw(sc, 0.25, { Scale = 1 }) end)
    b.MouseButton1Down:Connect(function() tw(sc, 0.1, { Scale = 0.95 }) end)
    b.MouseButton1Up:Connect(function() tw(sc, 0.3, { Scale = 1.04 }, Enum.EasingStyle.Back) end)
    return b
end

--[[
    KeySys.prompt(name, onSuccess, startReason)
    Показывает окно. При верном ключе сохраняет его, закрывает окно и вызывает onSuccess(key, result).
]]
function KeySys.prompt(name, onSuccess, startReason)
    local gui = new("ScreenGui", {
        Name = "WannaKey_" .. math.random(1e5, 9e5), IgnoreGuiInset = true, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
    })
    parentGui(gui)

    local dim = new("Frame", {
        Parent = gui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 4, 18),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    tw(dim, 0.4, { BackgroundTransparency = 0.35 })

    local panel = new("Frame", {
        Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 460, 0, 318), BackgroundColor3 = C.panel, BackgroundTransparency = 0.12,
    }, {
        corner(UDim.new(0, 24)), stroke(0.82),
        new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 185, 225)),
        }),
        new("UIPadding", { PaddingTop = UDim.new(0, 24), PaddingBottom = UDim.new(0, 22), PaddingLeft = UDim.new(0, 26), PaddingRight = UDim.new(0, 26) }),
    })
    local scale = new("UIScale", { Parent = panel, Scale = 0.88 })
    tw(scale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)

    -- шапка
    local badge = new("TextLabel", {
        Parent = panel, Size = UDim2.new(0, 46, 0, 46), BackgroundColor3 = C.accent, BackgroundTransparency = 0.75,
        Text = "🔑", TextSize = 22, FontFace = FONT, TextColor3 = C.text,
    }, { corner(UDim.new(0, 14)) })
    new("TextLabel", {
        Parent = panel, Position = UDim2.new(0, 60, 0, 0), Size = UDim2.new(1, -100, 0, 26),
        BackgroundTransparency = 1, FontFace = FONT, TextSize = 22, TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left, Text = "Нужен ключ",
    })
    new("TextLabel", {
        Parent = panel, Position = UDim2.new(0, 60, 0, 26), Size = UDim2.new(1, -100, 0, 20),
        BackgroundTransparency = 1, FontFace = FONT_M, TextSize = 15, TextColor3 = C.sub,
        TextXAlignment = Enum.TextXAlignment.Left, Text = name and (name .. " работает по ключу") or "Ключ для WannaBloc и WannaCarry",
    })
    local close = new("TextButton", {
        Parent = panel, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 4, 0, 0), Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.92, Text = "✕", TextSize = 16,
        FontFace = FONT, TextColor3 = C.sub, AutoButtonColor = false,
    }, { corner() })

    -- поле ввода
    local boxHolder = new("Frame", {
        Parent = panel, Position = UDim2.new(0, 0, 0, 70), Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.94,
    }, { corner(UDim.new(0, 14)) })
    local boxStroke = stroke(0.85); boxStroke.Parent = boxHolder
    local box = new("TextBox", {
        Parent = boxHolder, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -32, 1, 0),
        BackgroundTransparency = 1, ClearTextOnFocus = false, Text = KeySys.saved(name) or "",
        PlaceholderText = "WANNA-XXXX-XXXX-XXXX", PlaceholderColor3 = Color3.fromRGB(120, 114, 160),
        FontFace = FONT, TextSize = 18, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
    })
    box.Focused:Connect(function() tw(boxStroke, 0.2, { Transparency = 0.4, Color = C.accent }) end)
    box.FocusLost:Connect(function() tw(boxStroke, 0.25, { Transparency = 0.85, Color = Color3.new(1, 1, 1) }) end)

    local status = new("TextLabel", {
        Parent = panel, Position = UDim2.new(0, 2, 0, 128), Size = UDim2.new(1, -4, 0, 36),
        BackgroundTransparency = 1, FontFace = FONT_M, TextSize = 14, TextWrapped = true,
        TextColor3 = startReason and C.bad or C.sub, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = startReason or "Ключ можно получить в нашем Telegram-боте. После ввода он сохранится на этом ПК.",
    })

    -- кнопки
    local getBtn = button(panel, "Получить ключ", false, { Position = UDim2.new(0, 0, 0, 176), Size = UDim2.new(0.5, -6, 0, 44) })
    local okBtn  = button(panel, "Войти", true, { Position = UDim2.new(0.5, 6, 0, 176), Size = UDim2.new(0.5, -6, 0, 44) })
    local forgetBtn = new("TextButton", {
        Parent = panel, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1, FontFace = FONT_M, TextSize = 14, TextColor3 = C.sub,
        Text = "Забыть сохранённый ключ", AutoButtonColor = false, Visible = KeySys.saved(name) ~= nil,
    })
    forgetBtn.MouseEnter:Connect(function() tw(forgetBtn, 0.2, { TextColor3 = C.text }) end)
    forgetBtn.MouseLeave:Connect(function() tw(forgetBtn, 0.2, { TextColor3 = C.sub }) end)

    local function setStatus(t, col)
        status.Text = t
        status.TextColor3 = col or C.sub
        status.TextTransparency = 1
        tw(status, 0.3, { TextTransparency = 0 })
    end
    local function shake()
        local p = panel.Position
        for i, dx in ipairs({ -10, 9, -6, 4, 0 }) do
            tw(panel, 0.05, { Position = p + UDim2.fromOffset(dx, 0) }, Enum.EasingStyle.Sine, nil, (i - 1) * 0.05)
        end
    end
    local closed = false
    local function closeGui()
        if closed then return end
        closed = true
        tw(scale, 0.35, { Scale = 0.92 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        fadeAll(gui, 0.35)
        task.delay(0.4, function() gui:Destroy() end)
    end

    close.MouseButton1Click:Connect(closeGui)

    getBtn.MouseButton1Click:Connect(function()
        local url = KeySys.botUrl()
        if url == "" then return setStatus("Не получилось узнать ссылку на бота — сервер недоступен", C.bad) end
        local clip = setclipboard or toclipboard
        if clip then pcall(clip, url); setStatus("Ссылка на бота скопирована: " .. url, C.ok)
        else setStatus("Бот: " .. url, C.text) end
    end)

    forgetBtn.MouseButton1Click:Connect(function()
        KeySys.forget()
        box.Text = ""
        forgetBtn.Visible = false
        setStatus("Сохранённый ключ удалён с этого ПК", C.sub)
    end)

    local busy = false
    local function submit()
        if busy then return end
        local key = box.Text:gsub("%s", ""):upper()
        if key == "" then shake(); return setStatus("Вставь ключ в поле выше", C.bad) end
        busy = true
        okBtn.Text = "Проверяю…"
        local res = KeySys.check(key, name)
        busy = false
        if res.ok then
            KeySys.save(key, name)
            okBtn.Text = "Готово"
            setStatus("Ключ принят · осталось: " .. tostring(res.left_text or "навсегда"), C.ok)
            task.delay(0.6, function()
                closeGui()
                if onSuccess then task.spawn(onSuccess, key, res) end
            end)
        else
            okBtn.Text = "Войти"
            setStatus(res.reason or "Ключ не подошёл", C.bad)
            shake()
        end
    end
    okBtn.MouseButton1Click:Connect(submit)
    box.FocusLost:Connect(function(enter) if enter then submit() end end)

    return gui
end

------------------------------------------------------------------
-- Главная функция для премиум-скриптов
------------------------------------------------------------------
function KeySys.run(name)
    if not configured() then
        return KeySys.prompt(name, nil, "Сервер ключей ещё не настроен. Попробуй позже.")
    end
    local key = KeySys.saved(name)
    if key then
        local res = KeySys.check(key, name)
        if res.ok then return KeySys.launch(name, key, res) end
        return KeySys.prompt(name, function(k, r) KeySys.launch(name, k, r) end, res.reason)
    end
    return KeySys.prompt(name, function(k, r) KeySys.launch(name, k, r) end)
end

return KeySys
