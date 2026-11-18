-- LocalScript (Executor) - Wannacry UI + Movement + Cosmetics + Community + Troll

-- ================= СЕТЬ: Global Chat и хаб юзеров (Wispbyte) =================
local WC_NET = {
    chatUrl = "http://78.154.103.40:14541",   -- твой сервер Global Chat
    chatKey = "rbx_k9Xp2mQ7vLw4Zt8",
    hubUrl  = "http://78.154.103.46:11041",   -- Wispbyte-хаб
    hubKey  = "wc_8fK2mQx9Lp",                -- тот же hubKey, что в config.json хаба
    admins  = {"Tobby2281E", "sergeoomg"},    -- кому видна вкладка Admin Chat (доступ проверяет сервер по токену)
}
-- Иконки Lucide (MIT, lucide.dev) — готовые ассеты Roblox из latte-soft/lucide-roblox (48px спрайт-листы)
local WC_ICON = {
    sparkles = {16898613777, 918, 49},
    send     = {16898613699, 869, 906},
    x        = {16898613869, 869, 906},
    check    = {16898612819, 710, 869},
}
function WC_ICON.make(name, props)
    local d = WC_ICON[name]
    local im = Instance.new("ImageLabel")
    im.BackgroundTransparency = 1
    im.Image = "rbxassetid://" .. d[1]
    im.ImageRectOffset = Vector2.new(d[2], d[3])
    im.ImageRectSize = Vector2.new(48, 48)
    im.ScaleType = Enum.ScaleType.Fit
    for k, v in pairs(props or {}) do im[k] = v end
    return im
end
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local _genv = (typeof(getgenv) == "function" and getgenv()) or _G

if type(_genv.__WC_UNLOAD) == "function" then
    pcall(_genv.__WC_UNLOAD)
    task.wait(0.1)
end

local Conns = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Conns, c)
    return c
end

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    camera = Workspace.CurrentCamera or camera
end)

local parentGui
local okH, hui = pcall(function() return gethui and gethui() end)
if okH and hui then parentGui = hui
else
    local okC = pcall(function() return CoreGui end)
    parentGui = (okC and CoreGui) or playerGui
end

local function LoadCustomAsset(url, file)
    local success, result = pcall(function()
        local dir = file:match("^(.*)/[^/]+$")
        if dir then
            local path = ""
            for part in string.gmatch(dir, "[^/]+") do
                path = (path == "") and part or (path .. "/" .. part)
                if type(isfolder) == "function" and not isfolder(path) then makefolder(path) end
            end
        end
        if type(isfile) == "function" and type(writefile) == "function" and type(getcustomasset) == "function" then
            if not isfile(file) then writefile(file, game:HttpGet(url)) end
            return getcustomasset(file)
        end
        return ""
    end)
    return success and result or ""
end

local LOGO_URL = "https://i.ibb.co/21nYC0Dc/images.jpg"
local LOGO_FILE = "WannacryAssets/logo.png"
local logoAsset = LoadCustomAsset(LOGO_URL, LOGO_FILE)

local AvatarURLs = {
    "https://i.pinimg.com/736x/31/7f/23/317f23f4e103ca8dae73eacc408ecdc7.jpg",
    "https://i.pinimg.com/originals/e2/25/eb/e225eb637d5acc17a463a01e06c3c994.png",
    "https://andrey-eltsov.ru/wp-content/uploads/2017/09/1492814204_ca3-muzhchina-ava-stim.jpg",
    "https://aniyuki.com/wp-content/uploads/2022/06/aniyuki-profile-picture-1.jpg"
}
local LoadedAvatars = {}
for i, url in ipairs(AvatarURLs) do
    LoadedAvatars[i] = LoadCustomAsset(url, "WannacryAssets/avatar_" .. i .. ".png")
end
local defaultAvatarAsset = LoadedAvatars[1]


local Colors = {
    Background = Color3.fromRGB(10, 10, 12),
    Sidebar = Color3.fromRGB(4, 4, 5),
    ElementBg = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(130, 130, 140),
    Accent = Color3.fromRGB(60, 100, 255),
    Stroke = Color3.fromRGB(35, 35, 40),
    Neon = Color3.fromRGB(0, 150, 255)
}

local currentESPColor = Color3.fromRGB(255, 105, 180)
local espHPEnabled = false
local espEnabled = false
local isOpen = false

local Themes = {
    Black = {Bg = Color3.fromRGB(12,12,18), Card = Color3.fromRGB(18,18,24), Stroke = Color3.fromRGB(50,50,65), Accent = Color3.fromRGB(200,200,255), Text = Color3.fromRGB(255,255,255), VisualColor = Color3.fromRGB(255,255,255)},
}
local State = {
    CurrentTheme = "Black",
    FogEnabled = false, FogSettings = {Density = 0.4, Offset = 0.25, Color = Color3.fromRGB(199,199,199), Decay = Color3.fromRGB(106,112,125)},
    SkyEnabled = false, SkyIndex = 1, SkyCelestial = true, SkyCustomId = "", AspectEnabled = false, AspectValue = 0.80, AspectComp = 1.0,
    FullbrightEnabled = false, FullbrightBrightness = 3, MotionBlurEnabled = false, MotionBlurStrength = 50,
    WorldEnabled = false, WorldSettings = {Saturation = 0, Contrast = 0, Brightness = 0, TintColor = Color3.fromRGB(255,255,255)},
    JumpCircleEnabled = false, JumpCircleUseTheme = true, JumpCircleCustomColor = Color3.fromRGB(255,255,255), JumpCircleStyle = "segments", JumpCircleGlow = true,
    ParticlesEnabled = false, ParticlesUseTheme = true, ParticlesCustomColor = Color3.fromRGB(255,255,255),
    TrailsEnabled = false, TrailsUseTheme = true, TrailsCustomColor = Color3.fromRGB(255,255,255),
    AnimationPackEnabled = false, HudEnabled = false,
    CustomTimeEnabled = false, CustomTimeValue = 14,
    AtmosphereEnabled = false, AtmosphereType = "Зима", AtmosphereSpread = 0,
    DBDAnimationEnabled = false,
    KorbloxEnabled = false,
    HeadlessEnabled = false,
    StrafeEnabled = false, StrafeSpeed = 75, StrafeSharp = 30, StrafeBhop = false, StrafeGround = false,
    FlyEnabled = false,
    TrollEnabled = false,
    BgEnabled = false, BgIndex = 1, BgTransparency = 0.3, BgDim = 0.5,
    UISoundsEnabled = true,
    Cos = {},
    EspEnabled = false, EspHpEnabled = false,
}
-- ================= НАСТРОЙКИ И КОНФИГИ =================
-- settings.json — глобальные настройки (клавиша меню, кнопка-логотип, автозагрузка);
-- configs/<имя>.json — снимки State (визуалы, движение, косметика, ESP).
local WC_CFG = {
    cards = {},
    dir = "WannacryAssets/configs",
    settingsFile = "WannacryAssets/settings.json",
    settings = {menuKey = "Insert", logoButton = true, autoload = ""},
    capturing = false,
    autoloaded = false,
}
do (function()
    local Http = game:GetService("HttpService")
    local canFile = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
    WC_CFG.canFile = canFile
    local NO_SAVE = {TrollEnabled = true}   -- не сохраняем опасное/временное

    local function enc(v, top)
        local t = typeof(v)
        if t == "Color3" then
            return {__c3 = {math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)}}
        elseif t == "table" then
            local o = {}
            for k, x in pairs(v) do
                if type(k) == "string" and not (top and NO_SAVE[k]) then o[k] = enc(x) end
            end
            return o
        elseif t == "number" or t == "string" or t == "boolean" then
            return v
        end
        return nil
    end
    local function dec(v)
        if type(v) == "table" then
            if type(v.__c3) == "table" then
                return Color3.fromRGB(tonumber(v.__c3[1]) or 255, tonumber(v.__c3[2]) or 255, tonumber(v.__c3[3]) or 255)
            end
            local o = {}
            for k, x in pairs(v) do o[k] = dec(x) end
            return o
        end
        return v
    end
    local function merge(dst, src)
        for k, v in pairs(src) do
            local cur = dst[k]
            if cur ~= nil and not NO_SAVE[k] then
                if typeof(cur) == "Color3" then
                    if typeof(v) == "Color3" then dst[k] = v end
                elseif type(cur) == "table" and type(v) == "table" then
                    if k == "Cos" then
                        for kk in pairs(cur) do cur[kk] = nil end
                        for kk, vv in pairs(v) do if vv == true then cur[kk] = true end end
                    else
                        merge(cur, v)
                    end
                elseif type(cur) == type(v) then
                    dst[k] = v
                end
            end
        end
    end
    local function ensureDir()
        pcall(function()
            if type(isfolder) == "function" and type(makefolder) == "function" then
                if not isfolder("WannacryAssets") then makefolder("WannacryAssets") end
                if not isfolder(WC_CFG.dir) then makefolder(WC_CFG.dir) end
            end
        end)
    end
    function WC_CFG.safeName(n)
        n = tostring(n or ""):gsub("[^%w%-_ ]", ""):sub(1, 32)
        return (n:match("^%s*(.-)%s*$")) or ""
    end
    local function path(name) return WC_CFG.dir .. "/" .. name .. ".json" end

    function WC_CFG.saveSettings()
        if not canFile then return end
        ensureDir()
        pcall(writefile, WC_CFG.settingsFile, Http:JSONEncode(WC_CFG.settings))
    end
    function WC_CFG.loadSettings()
        if not canFile then return end
        pcall(function()
            if not isfile(WC_CFG.settingsFile) then return end
            local d = Http:JSONDecode(readfile(WC_CFG.settingsFile))
            if type(d) == "table" then merge(WC_CFG.settings, d) end
        end)
    end
    function WC_CFG.menuKeyCode()
        local ok, k = pcall(function() return Enum.KeyCode[WC_CFG.settings.menuKey] end)
        return (ok and k) or Enum.KeyCode.Insert
    end
    function WC_CFG.list()
        if not canFile or type(listfiles) ~= "function" then return {} end
        ensureDir()
        local out = {}
        local ok, files = pcall(listfiles, WC_CFG.dir)
        for _, f in ipairs(ok and type(files) == "table" and files or {}) do
            local n = tostring(f):gsub("\\", "/"):match("([^/]+)%.json$")
            if n then table.insert(out, n) end
        end
        table.sort(out, function(a, b) return a:lower() < b:lower() end)
        return out
    end
    function WC_CFG.save(name)
        name = WC_CFG.safeName(name)
        if name == "" then return false, "пустое имя" end
        if not canFile then return false, "экзекьютор не умеет сохранять файлы" end
        ensureDir()
        local data = {version = 1, state = enc(State, true), esp = {color = enc(currentESPColor)}}
        local ok, err = pcall(function() writefile(path(name), Http:JSONEncode(data)) end)
        if not ok then return false, tostring(err) end
        return true, name
    end
    function WC_CFG.read(name)
        if not canFile then return nil end
        local ok, d = pcall(function()
            if not isfile(path(name)) then return nil end
            return Http:JSONDecode(readfile(path(name)))
        end)
        return (ok and type(d) == "table") and d or nil
    end
    function WC_CFG.delete(name)
        if type(delfile) ~= "function" then return false end
        return (pcall(delfile, path(name)))
    end
    function WC_CFG.applyToState(d)
        if type(d.state) == "table" then merge(State, dec(d.state)) end
        if type(d.esp) == "table" then
            local c = dec(d.esp.color)
            if typeof(c) == "Color3" then currentESPColor = c end
        end
    end

    -- старт: настройки + автозагрузка конфига (до постройки интерфейса —
    -- карточки и ползунки сразу создаются с нужными значениями)
    WC_CFG.loadSettings()
    local auto = WC_CFG.settings.autoload
    if auto ~= "" then
        local d = WC_CFG.read(auto)
        if d then
            WC_CFG.applyToState(d)
            WC_CFG.autoloaded = true
        end
    end
end)() end
local SKIES = {
    {name="Космос",         bk="159454299", dn="159454296", ft="159454293", lf="159454286", rt="159454300", up="159454288", space=true},
    {name="Night",          bk="169210090", dn="169210108", ft="169210121", lf="169210133", rt="169210143", up="169210149", space=true},
    {name="Закат",          bk="600830446", dn="600831635", ft="600832720", lf="600886090", rt="600833862", up="600835177"},
    {name="Розовое небо",   bk="271042516", dn="271077243", ft="271042556", lf="271042310", rt="271042467", up="271077958"},
    {name="Vaporwave",      bk="1417494030", dn="1417494146", ft="1417494253", lf="1417494402", rt="1417494499", up="1417494643", space=true},
    {name="Minecraft",      bk="1876545003", dn="1876544331", ft="1876542941", lf="1876543392", rt="1876543764", up="1876544642"},
    {name="Облака",         bk="144933338", dn="144931530", ft="144933262", lf="144933244", rt="144933299", up="144931564"},
    {name="Звёздная ночь",  bk="12064107",  dn="12064152",  ft="12064121",  lf="12063984",  rt="12064115",  up="12064131", starCount=5000, space=true},
    {name="Красный космос", bk="401664839", dn="401664862", ft="401664960", lf="401664881", rt="401664901", up="401664936", space=true},
}
local SKY_NAMES = {}
for i, s in ipairs(SKIES) do SKY_NAMES[i] = s.name end
table.insert(SKY_NAMES, "Свой ID")
local function getVisualColor(useTheme, custom)
    if useTheme then
        local th = Themes[State.CurrentTheme] or Themes.Black
        return th.VisualColor or th.Accent
    end
    return custom
end

if not _genv.__WC_ORIG_LIGHTING then
    _genv.__WC_ORIG_LIGHTING = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows }
end
local originalLighting = _genv.__WC_ORIG_LIGHTING
local ScriptUnloaded = false
local Features = {}

-- =====================================================================
-- ============  ПРОЦЕДУРНЫЕ ТЕКСТУРЫ (PNG генерируется кодом)  =========
-- =====================================================================
-- Все текстуры косметики рисуются формулами прямо в скрипте, кодируются
-- в PNG и кэшируются в папке WannacryAssets (writefile + getcustomasset).
-- Если экзекутор не умеет файлы — косметика просто рисуется цветами/материалами.
local Tex = {assets = {}, ready = false}
do (function()
    local canFile = type(writefile) == "function" and type(isfile) == "function" and type(getcustomasset) == "function"
    Tex.canFile = canFile
    local VERSION = "v3"
    local band, bxor, rshift = bit32.band, bit32.bxor, bit32.rshift
    local floor, sqrt, abs, sin, cos, exp, max, min, atan2 = math.floor, math.sqrt, math.abs, math.sin, math.cos, math.exp, math.max, math.min, math.atan2
    local PI, TAU = math.pi, math.pi * 2

    -- ---------- PNG encoder (stored deflate, без сжатия) ----------
    local CRC = {}
    for i = 0, 255 do
        local c = i
        for _ = 1, 8 do
            if band(c, 1) == 1 then c = bxor(0xEDB88320, rshift(c, 1)) else c = rshift(c, 1) end
        end
        CRC[i] = c
    end
    local function crc32(s)
        local c = 0xFFFFFFFF
        local byte = string.byte
        for i = 1, #s do
            c = bxor(CRC[band(bxor(c, byte(s, i)), 255)], rshift(c, 8))
        end
        return bxor(c, 0xFFFFFFFF)
    end
    local function be32(n)
        return string.char(band(rshift(n, 24), 255), band(rshift(n, 16), 255), band(rshift(n, 8), 255), band(n, 255))
    end
    local function chunk(kind, data)
        return be32(#data) .. kind .. data .. be32(crc32(kind .. data))
    end
    local function encodePNG(w, h, rows)
        local lines = table.create(h)
        for y = 1, h do lines[y] = "\0" .. rows[y] end
        local raw = table.concat(lines)
        local a, b = 1, 0
        local byte = string.byte
        for i = 1, #raw do
            a = (a + byte(raw, i)) % 65521
            b = (b + a) % 65521
        end
        local z = {"\120\1"}
        local pos, n = 1, #raw
        while pos <= n do
            local len = min(65535, n - pos + 1)
            local final = (pos + len > n) and 1 or 0
            local nlen = 65535 - len
            z[#z + 1] = string.char(final, len % 256, floor(len / 256), nlen % 256, floor(nlen / 256))
            z[#z + 1] = string.sub(raw, pos, pos + len - 1)
            pos += len
        end
        z[#z + 1] = be32(b * 65536 + a)
        local ihdr = be32(w) .. be32(h) .. "\8\6\0\0\0"
        return "\137PNG\r\n\26\n" .. chunk("IHDR", ihdr) .. chunk("IDAT", table.concat(z)) .. chunk("IEND", "")
    end

    -- ---------- шум (бесшовный) ----------
    local PERM = {}
    do
        local rng = Random.new(20240611)
        local p = {}
        for i = 0, 255 do p[i] = i end
        for i = 255, 1, -1 do
            local j = rng:NextInteger(0, i)
            p[i], p[j] = p[j], p[i]
        end
        for i = 0, 255 do PERM[i] = p[i] end
    end
    local function hash2(x, y, s)
        return PERM[(PERM[(x + s) % 256] + y) % 256] / 255
    end
    local function vnoise(x, y, px, py, s)
        local xi, yi = floor(x), floor(y)
        local xf, yf = x - xi, y - yi
        local x0, y0 = xi % px, yi % py
        local x1, y1 = (xi + 1) % px, (yi + 1) % py
        local u = xf * xf * (3 - 2 * xf)
        local v = yf * yf * (3 - 2 * yf)
        local a, b = hash2(x0, y0, s), hash2(x1, y0, s)
        local c, d = hash2(x0, y1, s), hash2(x1, y1, s)
        return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v
    end
    -- fbm2: разная частота по осям (для волокон, меха, шлифовки)
    local function fbm2(u, v, fx, fy, oct, s)
        local t, amp, norm = 0, 0.5, 0
        for i = 1, oct do
            t += vnoise(u * fx, v * fy, fx, fy, s + i * 31) * amp
            norm += amp
            amp *= 0.5
            fx *= 2; fy *= 2
        end
        return t / norm
    end
    local function fbm(u, v, f, oct, s) return fbm2(u, v, f, f, oct, s) end

    local function clamp01(x) return x < 0 and 0 or (x > 1 and 1 or x) end
    local function smooth(e0, e1, x)
        local t = clamp01((x - e0) / (e1 - e0))
        return t * t * (3 - 2 * t)
    end
    local function mix(a, b, t) return a + (b - a) * t end
    local function segDist(px, py, ax, ay, bx, by)
        local dx, dy = bx - ax, by - ay
        local t = clamp01(((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy))
        local qx, qy = ax + dx * t - px, ay + dy * t - py
        return sqrt(qx * qx + qy * qy)
    end
    local function inPoly(px, py, poly)
        local inside = false
        local j = #poly
        for i = 1, #poly do
            local xi, yi, xj, yj = poly[i][1], poly[i][2], poly[j][1], poly[j][2]
            if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
            j = i
        end
        return inside
    end

    -- ---------- генераторы (u,v в 0..1, v сверху вниз) -> r,g,b,a ----------
    local GEN, ORDER = {}, {}
    local function def(name, w, h, fn, mirror)
        GEN[name] = {w = w, h = h, fn = fn}
        table.insert(ORDER, name)
        if mirror then
            GEN[name .. "_m"] = {w = w, h = h, fn = fn, mirror = true}
            table.insert(ORDER, name .. "_m")
        end
    end

    -- Галактика (бесшовная): туманности + звёзды
    local function galaxyCol(u, v)
        local n1 = fbm(u, v, 3, 5, 101)
        local n2 = fbm(u, v, 4, 4, 202)
        local n3 = fbm(u, v, 6, 3, 303)
        local r, g, b = 0.02, 0.015, 0.07
        local k1 = smooth(0.42, 0.82, n1)
        r += 0.50 * k1; g += 0.10 * k1; b += 0.72 * k1
        local k2 = smooth(0.48, 0.88, n2)
        r += 0.04 * k2; g += 0.42 * k2; b += 0.80 * k2
        local k3 = smooth(0.55, 0.95, n3) * k1
        r += 0.65 * k3; g += 0.22 * k3; b += 0.35 * k3
        local gx, gy = floor(u * 96), floor(v * 96)
        local h = hash2(gx, gy, 77)
        if h > 0.972 then
            local fx, fy = u * 96 - gx - 0.5, v * 96 - gy - 0.5
            local s = max(0, 1 - sqrt(fx * fx + fy * fy) * 2.2) * (0.55 + (h - 0.972) * 16)
            r += s; g += s; b += s
        end
        local cx, cy = floor(u * 8), floor(v * 8)
        local h2 = hash2(cx, cy, 91)
        if h2 > 0.62 then
            local ox, oy = 0.25 + hash2(cx, cy, 13) * 0.5, 0.25 + hash2(cx, cy, 57) * 0.5
            local fx, fy = u * 8 - cx - ox, v * 8 - cy - oy
            local d = sqrt(fx * fx + fy * fy)
            local s = exp(-d * d * 260) * 1.3
                + (exp(-abs(fx) * 70) * exp(-abs(fy) * 9) + exp(-abs(fy) * 70) * exp(-abs(fx) * 9)) * 0.7 * exp(-d * 5)
            r += s; g += s * 0.95; b += s * 1.1
        end
        return r, g, b
    end
    def("galaxy", 128, 128, function(u, v)
        local r, g, b = galaxyCol(u, v)
        return r, g, b, 1
    end)

    -- Перо: v=0 — основание (сверху), v=1 — кончик
    local function featherAlpha(u, v)
        local x = (u - 0.5) * 2
        local ax = abs(x)
        local w = 0
        if v > 0.05 then
            w = 0.96 * (sin(PI * clamp01((v - 0.05) / 0.97))) ^ (0.5)
        end
        if x > 0 then w *= 0.86 end
        w *= 1 - 0.14 * smooth(0.55, 0.85, vnoise(v * 22, x > 0 and 3.5 or 9.5, 64, 64, 3))
        local a = smooth(w, w - 0.06, ax)
        local shaftW = 0.05 * (1 - v * 0.75)
        local shaft = (v < 0.985) and smooth(shaftW, shaftW * 0.55, ax) or 0
        return max(a, shaft), ax, w, shaft
    end
    def("feather", 64, 128, function(u, v)
        local a, ax, w, shaft = featherAlpha(u, v)
        local barb = 0.5 + 0.5 * sin((v - ax * 0.38) * TAU * 26)
        local n = fbm(u, v, 4, 3, 11)
        local s = 0.86 + 0.07 * barb + 0.10 * (n - 0.5)
        s *= 1 - 0.25 * clamp01(ax / max(w, 0.01)) ^ 3
        s *= 1 - 0.12 * v
        s = mix(s, 0.99, shaft)
        return s, s * 0.99, s * 0.965, a
    end)
    def("feather_galaxy", 64, 128, function(u, v)
        local a, ax, w, shaft = featherAlpha(u, v)
        local r, g, b = galaxyCol(u * 0.5 + 0.25, v)
        local barb = 0.5 + 0.5 * sin((v - ax * 0.38) * TAU * 26)
        local k = 0.85 + 0.25 * barb
        local edge = smooth(0.55, 1, ax / max(w, 0.01))
        r, g, b = r * k + edge * 0.35, g * k + edge * 0.15, b * k + edge * 0.55
        r, g, b = mix(r, 0.9, shaft), mix(g, 0.85, shaft), mix(b, 1, shaft)
        return r, g, b, a
    end)

    -- Перепончатое крыло (демон/дракон): силуэт с фестонами, кости, вены
    local BW = {
        root = {0.0, 0.09}, wrist = {0.50, 0.07}, tip = {0.99, 0.03},
        fingers = {{0.97, 0.50}, {0.74, 0.84}, {0.43, 0.97}},
        poly = {{0.0, 0.06}, {0.5, 0.03}, {0.995, 0.01}, {0.97, 0.50}, {0.74, 0.84}, {0.43, 0.97}, {0.12, 0.90}, {0.0, 0.62}},
    }
    BW.bites = {}
    for i = 3, #BW.poly - 1 do
        local A, B = BW.poly[i], BW.poly[i + 1]
        local mx, my = (A[1] + B[1]) / 2, (A[2] + B[2]) / 2
        local dx, dy = B[1] - A[1], B[2] - A[2]
        local hl = sqrt(dx * dx + dy * dy) / 2
        local nx, ny = dy, -dx
        local nl = sqrt(nx * nx + ny * ny)
        nx, ny = nx / nl, ny / nl
        if nx * (mx - BW.wrist[1]) + ny * (my - BW.wrist[2]) < 0 then nx, ny = -nx, -ny end
        table.insert(BW.bites, {mx + nx * hl * 0.78, my + ny * hl * 0.78, hl * 1.03})
    end
    def("batwing", 128, 128, function(u, v)
        local inside = inPoly(u, v, BW.poly)
        if inside then
            for _, c in ipairs(BW.bites) do
                local dx, dy = u - c[1], v - c[2]
                if dx * dx + dy * dy < c[3] * c[3] then inside = false; break end
            end
        end
        local wx, wy = BW.wrist[1], BW.wrist[2]
        local bone = 0
        bone = max(bone, smooth(0.028, 0.012, segDist(u, v, BW.root[1], BW.root[2], wx, wy)))
        bone = max(bone, smooth(0.022, 0.009, segDist(u, v, wx, wy, BW.tip[1], BW.tip[2])))
        for _, f in ipairs(BW.fingers) do
            bone = max(bone, smooth(0.016, 0.006, segDist(u, v, wx, wy, f[1], f[2])))
        end
        if not inside and bone <= 0 then return 0, 0, 0, 0 end
        local n = fbm(u, v, 5, 4, 41)
        local s = 0.34 + 0.16 * n
        local vein = smooth(0.035, 0.0, abs(fbm(u, v, 4, 4, 43) - 0.5))
        local vein2 = smooth(0.02, 0.0, abs(fbm(u, v, 8, 3, 47) - 0.5)) * 0.6
        s += 0.16 * vein + 0.08 * vein2
        local dw = sqrt((u - wx) ^ 2 + (v - wy) ^ 2)
        s *= 0.8 + 0.3 * smooth(0.9, 0.1, dw)
        s = mix(s, 0.85, bone)
        return s, s, s, inside and max(0.94, bone) or bone
    end, true)

    -- Крылья бабочки (морфо): верхнее и нижнее
    local function ellF(u, v, cx, cy, ra, rb, rot)
        local c, s = cos(rot), sin(rot)
        local dx, dy = u - cx, v - cy
        local x, y = dx * c + dy * s, -dx * s + dy * c
        return (x * x) / (ra * ra) + (y * y) / (rb * rb)
    end
    local function butterfly(u, v, E, root, spots)
        local f = 99
        for _, e in ipairs(E) do f = min(f, ellF(u, v, e[1], e[2], e[3], e[4], e[5])) end
        if f > 1 or u < 0.015 then return 0, 0, 0, 0 end
        local dx, dy = u - root[1], v - root[2]
        local r = sqrt(dx * dx + dy * dy)
        local t = clamp01(r / 0.85)
        local cr, cg, cb = mix(0.03, 0.10, t), mix(0.12, 0.75, t), mix(0.55, 1.0, t)
        local n = fbm(u, v, 5, 3, 61)
        cr, cg, cb = mix(cr, 0.55, 0.35 * n), mix(cg, 0.2, 0.25 * n), mix(cb, 0.95, 0.3 * n)
        local glow = smooth(0.35, 0.0, abs(t - 0.45)) * 0.25
        cr, cg, cb = cr + glow * 0.3, cg + glow, cb + glow
        local ang = atan2(dy, dx)
        local q = ang / (PI / 11)
        local dl = abs((q - floor(q)) - 0.5) * r * (PI / 11)
        local vein = smooth(0.011, 0.003, dl) * smooth(0.05, 0.2, r)
        cr, cg, cb = cr * (1 - 0.75 * vein), cg * (1 - 0.75 * vein), cb * (1 - 0.75 * vein)
        local border = smooth(0.62, 0.78, f)
        cr, cg, cb = mix(cr, 0.02, border), mix(cg, 0.02, border), mix(cb, 0.04, border)
        for _, sp in ipairs(spots) do
            local ex, ey = u - sp[1], v - sp[2]
            local d = sqrt(ex * ex + ey * ey)
            if d < sp[3] then
                local k = smooth(sp[3], sp[3] * 0.6, d)
                cr, cg, cb = mix(cr, 1, k), mix(cg, 1, k), mix(cb, 1, k)
            end
        end
        return cr, cg, cb, smooth(1, 0.96, f)
    end
    local BU_E = {{0.55, 0.36, 0.44, 0.31, -0.35}, {0.28, 0.56, 0.27, 0.2, 0}}
    local BU_SP = {{0.78, 0.13, 0.025}, {0.89, 0.24, 0.022}, {0.94, 0.37, 0.02}, {0.66, 0.08, 0.018}, {0.93, 0.5, 0.016}}
    def("bfly_up", 128, 128, function(u, v) return butterfly(u, v, BU_E, {0.02, 0.62}, BU_SP) end, true)
    local BL_E = {{0.40, 0.45, 0.37, 0.29, 0.45}, {0.68, 0.80, 0.22, 0.085, 0.8}, {0.2, 0.3, 0.2, 0.16, 0}}
    local BL_SP = {{0.67, 0.63, 0.02}, {0.55, 0.72, 0.018}, {0.72, 0.5, 0.017}}
    def("bfly_lo", 128, 128, function(u, v) return butterfly(u, v, BL_E, {0.02, 0.28}, BL_SP) end, true)

    -- Чешуя (бесшовная, серая — тонируется)
    def("scales", 64, 64, function(u, v)
        local N = 6
        local t, xx = 1, 0
        for dr = 0, 1 do
            local row = floor(v * N) - dr
            local off = (row % 2) * 0.5
            local yy = v * N - row
            local found = false
            for dc = -1, 1 do
                local col = floor(u * N - off) + dc
                local x = u * N - off - col - 0.5
                local d = sqrt(x * x + (yy * 0.92) ^ 2)
                if d < 0.8 then t, xx, found = d / 0.8, x, true; break end
            end
            if found then break end
        end
        local rim = smooth(0.78, 1.0, t)
        local s = (0.42 + 0.55 * (1 - t * t)) * (1 - 0.55 * rim)
        s += 0.12 * smooth(0.08, 0.0, abs(xx)) * (1 - t)
        s += 0.08 * (fbm(u, v, 8, 2, 5) - 0.5)
        return s, s, s, 1
    end)

    -- Золото (шлифованное)
    def("gold", 64, 64, function(u, v)
        local n = fbm2(u, v, 2, 24, 4, 61)
        local h = smooth(0.55, 0.85, fbm(u, v, 3, 3, 63))
        local k = 0.68 + 0.42 * n + 0.35 * h
        return 0.98 * k, 0.76 * k, 0.28 * k * (0.9 + 0.3 * h), 1
    end)

    -- Ткань (переплетение)
    def("fabric", 64, 64, function(u, v)
        local fu, fv = u * 16, v * 16
        local cu, cv = floor(fu), floor(fv)
        local tu, tv = fu - cu, fv - cv
        local s
        if (cu + cv) % 2 == 0 then s = 0.7 + 0.3 * sin(tv * PI) else s = 0.7 + 0.3 * sin(tu * PI) end
        s *= 0.84 + 0.16 * vnoise(u * 64, v * 64, 64, 64, 5)
        s *= 0.9 + 0.1 * fbm(u, v, 4, 3, 7)
        return s, s, s, 1
    end)

    -- Кожа
    def("leather", 64, 64, function(u, v)
        local n = fbm(u, v, 8, 4, 71)
        local c = abs(fbm(u, v, 4, 3, 73) - 0.5)
        local s = 0.62 + 0.25 * n - 0.28 * smooth(0.04, 0.0, c)
        s += 0.06 * (vnoise(u * 64, v * 64, 64, 64, 75) - 0.5)
        return s, s, s, 1
    end)

    -- Мех
    def("fur", 64, 64, function(u, v)
        local n = fbm2(u, v, 32, 4, 3, 81)
        local n2 = fbm2(u, v, 16, 2, 3, 83)
        local s = 0.55 + 0.38 * n + 0.12 * (n2 - 0.5)
        return s, s, s, 1
    end)

    -- Рог (кольцевые наросты)
    def("horn", 64, 64, function(u, v)
        local s = 0.5 + 0.22 * sin(v * TAU * 8 + fbm(u, v, 4, 3, 91) * 5) + 0.18 * (fbm(u, v, 8, 3, 93) - 0.5)
        return s, s, s, 1
    end)

    -- Металл (шлифовка + заклёпки)
    def("metal", 64, 64, function(u, v)
        local s = 0.62 + 0.22 * fbm2(u, v, 2, 48, 3, 95)
        local edge = min(u, v, 1 - u, 1 - v)
        s *= 0.7 + 0.3 * smooth(0.0, 0.035, edge)
        for _, p in ipairs({{0.1, 0.1}, {0.9, 0.1}, {0.1, 0.9}, {0.9, 0.9}}) do
            local d = sqrt((u - p[1]) ^ 2 + (v - p[2]) ^ 2)
            if d < 0.045 then s = 0.55 + 0.45 * (1 - d / 0.045) end
        end
        return s, s, s, 1
    end)

    -- Кибер-схема
    def("cyber", 64, 64, function(u, v)
        local r, g, b = 0.02, 0.03, 0.07
        local fu, fv = (u * 4) % 1, (v * 4) % 1
        local grid = smooth(0.03, 0.0, min(fu, 1 - fu, fv, 1 - fv))
        r += 0.05 * grid; g += 0.4 * grid; b += 0.5 * grid
        local cx, cy = floor(u * 8), floor(v * 8)
        local lx, ly = u * 8 - cx, v * 8 - cy
        local h = hash2(cx, cy, 33)
        local tr = 0
        if h > 0.5 then tr = smooth(0.09, 0.02, abs(ly - 0.5)) * ((h > 0.75) and 1 or (lx < 0.7 and 1 or 0)) end
        if h < 0.35 then tr = max(tr, smooth(0.09, 0.02, abs(lx - 0.5)) * (ly > 0.3 and 1 or 0)) end
        local node = 0
        if h > 0.5 and h <= 0.75 then
            local d = sqrt((lx - 0.7) ^ 2 + (ly - 0.5) ^ 2)
            node = smooth(0.16, 0.08, d)
        end
        local hot = hash2(cx, cy, 39) > 0.82
        local cr, cg, cb = 0.1, 0.95, 1.0
        if hot then cr, cg, cb = 1.0, 0.25, 0.85 end
        local k = max(tr, node)
        r, g, b = mix(r, cr, k), mix(g, cg, k), mix(b, cb, k)
        return r, g, b, 1
    end)

    -- Лёд
    def("ice", 64, 64, function(u, v)
        local n = fbm(u, v, 4, 5, 111)
        local r, g, b = mix(0.55, 0.88, n), mix(0.80, 0.96, n), mix(0.95, 1.0, n)
        local c1 = smooth(0.025, 0.0, abs(fbm(u, v, 3, 4, 113) - 0.5))
        local c2 = smooth(0.015, 0.0, abs(fbm(u, v, 6, 3, 117) - 0.5)) * 0.6
        local k = max(c1, c2)
        r, g, b = mix(r, 1, k), mix(g, 1, k), mix(b, 1, k)
        if hash2(floor(u * 64), floor(v * 64), 119) > 0.97 then r, g, b = 1, 1, 1 end
        return r, g, b, 1
    end)

    -- Свечение (для частиц)
    def("glow", 64, 64, function(u, v)
        local d = sqrt((u - 0.5) ^ 2 + (v - 0.5) ^ 2) * 2
        return 1, 1, 1, (clamp01(1 - d)) ^ (2.2)
    end)
    -- Искра-звёздочка
    def("sparkle", 64, 64, function(u, v)
        local x, y = (u - 0.5) * 2, (v - 0.5) * 2
        local core = exp(-(x * x + y * y) * 22)
        local rays = exp(-abs(x) * 30) * exp(-abs(y) * 3.2) + exp(-abs(y) * 30) * exp(-abs(x) * 3.2)
        local dg = (exp(-abs(x - y) * 22) * exp(-abs(x + y) * 6) + exp(-abs(x + y) * 22) * exp(-abs(x - y) * 6)) * 0.4
        local edge = smooth(1, 0.8, max(abs(x), abs(y)))
        return 1, 1, 1, clamp01(core + rays * 0.85 + dg) * edge
    end)
    -- Светящееся кольцо нимба
    def("ring", 128, 128, function(u, v)
        local d = sqrt((u - 0.5) ^ 2 + (v - 0.5) ^ 2) * 2
        local core = exp(-((d - 0.72) / 0.05) ^ 2)
        local a = core + 0.5 * exp(-((d - 0.72) / 0.17) ^ 2)
        a *= smooth(1, 0.95, d)
        return 1, mix(0.86, 1, core), mix(0.55, 1, core), clamp01(a)
    end)

    -- Мордочки питомцев
    def("face_cute", 64, 64, function(u, v)
        local r, g, b, a = 0, 0, 0, 0
        for _, cx in ipairs({0.19, 0.81}) do
            local dx, dy = (u - cx) / 0.11, (v - 0.64) / 0.06
            local d = dx * dx + dy * dy
            if d < 1 then r, g, b, a = 1, 0.45, 0.62, (1 - d) * 0.65 end
        end
        for _, cx in ipairs({0.32, 0.68}) do
            local dx, dy = (u - cx) / 0.1, (v - 0.46) / 0.13
            local d = dx * dx + dy * dy
            if d < 1 then
                r, g, b, a = 0.05, 0.04, 0.09, smooth(1, 0.82, d)
                local hx, hy = (u - (cx + 0.035)) / 0.038, (v - 0.4) / 0.038
                if hx * hx + hy * hy < 1 then r, g, b = 1, 1, 1 end
                local hx2, hy2 = (u - (cx - 0.03)) / 0.02, (v - 0.52) / 0.02
                if hx2 * hx2 + hy2 * hy2 < 1 then r, g, b = 0.85, 0.85, 1 end
            end
        end
        for _, cx in ipairs({0.465, 0.535}) do
            local d = sqrt((u - cx) ^ 2 + (v - 0.585) ^ 2)
            if v > 0.585 and abs(d - 0.035) < 0.01 then r, g, b, a = 0.15, 0.05, 0.1, 1 end
        end
        return r, g, b, a
    end)
    def("face_ghost", 64, 64, function(u, v)
        local r, g, b, a = 0, 0, 0, 0
        for _, cx in ipairs({0.35, 0.65}) do
            local dx, dy = (u - cx) / 0.075, (v - 0.42) / 0.13
            local d = dx * dx + dy * dy
            if d < 1 then r, g, b, a = 0.04, 0.03, 0.08, smooth(1, 0.85, d) end
            local hx, hy = (u - cx - 0.02) / 0.025, (v - 0.36) / 0.035
            if hx * hx + hy * hy < 1 then r, g, b = 0.8, 0.85, 1 end
        end
        local mx, my = (u - 0.5) / 0.065, (v - 0.68) / 0.085
        local md = mx * mx + my * my
        if md < 1 then
            r, g, b, a = 0.05, 0.02, 0.06, smooth(1, 0.85, md)
            if my > 0.35 then r, g, b = 0.5, 0.1, 0.2 end
        end
        return r, g, b, a
    end)

    -- Korblox: синяя энергия на кончике иглы
    def("korblox", 64, 64, function(u, v)
        local n = fbm2(u, v, 4, 2, 4, 55)
        local n2 = fbm2(u, v, 8, 3, 3, 57)
        local r, g, b = 0.01, 0.06 + 0.06 * n, 0.32 + 0.2 * n
        local vein = smooth(0.06, 0.0, abs(n - 0.5))
        local vein2 = smooth(0.035, 0.0, abs(n2 - 0.5)) * 0.7
        local k = max(vein, vein2)
        r, g, b = r + 0.25 * k, g + 0.62 * k, b + 0.68 * k
        if hash2(floor(u * 64), floor(v * 64), 59) > 0.985 then r, g, b = 0.7, 0.9, 1 end
        return r, g, b, 1
    end)

    -- Ведьминская ткань со звёздами и лунами
    def("witch", 64, 64, function(u, v)
        local k = 0.8 + 0.3 * fbm(u, v, 8, 3, 131)
        local r, g, b = 0.22 * k, 0.06 * k, 0.36 * k
        local cx, cy = floor(u * 4), floor(v * 4)
        local h = hash2(cx, cy, 133)
        local ox, oy = 0.3 + 0.4 * hash2(cx, cy, 135), 0.3 + 0.4 * hash2(cx, cy, 137)
        local x, y = (u * 4 - cx - ox) * 2, (v * 4 - cy - oy) * 2
        if h > 0.78 then
            local d1 = sqrt(x * x + y * y)
            local d2 = sqrt((x - 0.12) ^ 2 + (y + 0.08) ^ 2)
            if d1 < 0.3 and d2 > 0.26 then r, g, b = 1, 0.86, 0.35 end
        elseif h > 0.25 then
            local s = exp(-(x * x + y * y) * 60) + (exp(-abs(x) * 26) * exp(-abs(y) * 7) + exp(-abs(y) * 26) * exp(-abs(x) * 7)) * 0.9
            s = clamp01(s * 1.4)
            r, g, b = mix(r, 1, s), mix(g, 0.85, s), mix(b, 0.4, s)
        end
        return r, g, b, 1
    end)

    -- Королевский бархат: дамаск + золотая кайма по бокам
    def("cape_royal", 64, 64, function(u, v)
        local n = fbm(u, v, 4, 4, 121)
        local r, g, b = 0.48 + 0.16 * n, 0.03 + 0.02 * n, 0.07 + 0.04 * n
        local fu, fv = (u * 4) % 1, (v * 2) % 1
        local dd = abs(fu - 0.5) + abs(fv - 0.5)
        local ring = smooth(0.035, 0.0, abs(dd - 0.33))
        r += 0.14 * ring; g += 0.02 * ring
        if dd < 0.07 then r, g, b = 0.9, 0.68, 0.25 end
        local side = min(u, 1 - u)
        if side < 0.075 then
            local gk = 0.75 + 0.35 * fbm2(u, v, 2, 16, 3, 123)
            local pat = 0.5 + 0.5 * sin(v * TAU * 6)
            r, g, b = 0.95 * gk, (0.72 + 0.08 * pat) * gk, 0.26 * gk
            if side > 0.055 then r, g, b = r * 0.55, g * 0.55, b * 0.55 end
        end
        return r, g, b, 1
    end)

    -- Тартан для спальника
    def("plaid", 64, 64, function(u, v)
        local function band(t)
            local f = (t * 4) % 1
            local dark = (f > 0.38 and f < 0.62) and 1 or 0
            local line = smooth(0.025, 0.01, abs(f - 0.5))
            local thin = smooth(0.015, 0.005, abs(f - 0.12))
            return dark, line, thin
        end
        local d1, l1, t1 = band(u)
        local d2, l2, t2 = band(v)
        local r, g, b = 0.62, 0.08, 0.08
        local dk = (d1 + d2) * 0.5
        r, g, b = mix(r, 0.06, dk * 0.85), mix(g, 0.05, dk * 0.85), mix(b, 0.06, dk * 0.85)
        local yl = max(l1, l2)
        r, g, b = mix(r, 0.95, yl), mix(g, 0.8, yl), mix(b, 0.2, yl)
        local wl = max(t1, t2) * 0.7
        r, g, b = mix(r, 0.9, wl), mix(g, 0.9, wl), mix(b, 0.9, wl)
        local tw = 0.9 + 0.1 * sin((u + v) * TAU * 32)
        return r * tw, g * tw, b * tw, 1
    end)

    -- Обмотка рукояти катаны
    def("wrap", 64, 64, function(u, v)
        local dd = abs(((u * 2) % 1) - 0.5) + abs(((v * 2) % 1) - 0.5)
        local silk = smooth(0.3, 0.27, dd)
        local weave = 0.85 + 0.15 * sin((u - v) * TAU * 24)
        local s = mix(0.08, 0.92 * weave, silk)
        return s, s, s * 1.02, 1
    end)

    -- ---------- рендер ----------
    local function render(defn)
        local w, h, fn, mirror = defn.w, defn.h, defn.fn, defn.mirror
        local rows = table.create(h)
        local char = string.char
        local t0 = os.clock()
        for y = 0, h - 1 do
            local row = table.create(w)
            local v = (y + 0.5) / h
            for x = 0, w - 1 do
                local u = (x + 0.5) / w
                if mirror then u = 1 - u end
                local r, g, b, a = fn(u, v)
                row[x + 1] = char(floor(clamp01(r) * 255 + 0.5), floor(clamp01(g) * 255 + 0.5), floor(clamp01(b) * 255 + 0.5), floor(clamp01(a or 1) * 255 + 0.5))
            end
            rows[y + 1] = table.concat(row)
            if os.clock() - t0 > 0.008 then task.wait(); t0 = os.clock() end
        end
        return encodePNG(w, h, rows)
    end
    Tex.encodePNG = encodePNG

    function Tex.get(name)
        return Tex.assets[name]
    end
    function Tex.await(timeout)
        local t0 = os.clock()
        while not Tex.ready and os.clock() - t0 < (timeout or 25) do task.wait(0.05) end
    end
    function Tex.loadAll()
        if not canFile then Tex.ready = true; return end
        pcall(function()
            if type(isfolder) == "function" and not isfolder("WannacryAssets") then makefolder("WannacryAssets") end
        end)
        for _, name in ipairs(ORDER) do
            if ScriptUnloaded then break end
            local ok, err = pcall(function()
                local path = "WannacryAssets/tex_" .. VERSION .. "_" .. name .. ".png"
                if not isfile(path) then writefile(path, render(GEN[name])) end
                local id = getcustomasset(path)
                if id and id ~= "" then Tex.assets[name] = id end
            end)
            if not ok then warn("[wannacry] texture " .. name .. ": " .. tostring(err)) end
        end
        Tex.ready = true
    end
    task.spawn(Tex.loadAll)
end)() end

-- ================= ПРОЕКЦИЯ МИР → ЭКРАН (с учётом Aspect / растянутого разрешения) =================
-- Aspect растягивает камеру по Y, и движок рисует мир растянутым. Всё, что мы рисуем
-- поверх (ESP, метки, облачка чата), проецируем той же математикой — поэтому оно
-- стоит ровно на персонаже при любом разрешении, аспект-ратио, FOV и силе Aspect.
local WC_PROJ = {items = {}, gui = nil}
do (function()
    -- Точка мира → пиксель экрана.
    -- Считаем по нормальной (ортонормированной) камере — так результат не зависит от того,
    -- как и сколько раз Aspect исказил матрицу камеры. Растяжение Aspect добавляем отдельно:
    -- вертикаль от центра экрана умножается на k = сила^поправка (1 = как рендер Roblox). Поправку (State.AspectComp)
    -- можно подогнать ползунком в настройках Aspect — тогда ESP совпадает с картинкой при любой силе.
    function WC_PROJ.toScreen(pos)
        local cam = Workspace.CurrentCamera
        if not cam then return nil end
        local cf = cam.CFrame
        local rel = pos - cf.Position
        local x = rel:Dot(cf.XVector.Unit)
        local y = rel:Dot(cf.YVector.Unit)
        local z = rel:Dot(cf.ZVector.Unit)
        if z >= -0.05 then return nil end
        if State.AspectEnabled then
            local v = math.max(State.AspectValue or 1, 0.05)
            y = y * v ^ (State.AspectComp or 1)
        end
        local vp = cam.ViewportSize
        if vp.X <= 0 or vp.Y <= 0 then return nil end
        local t = math.tan(math.rad(cam.FieldOfView) / 2)
        local d = -z
        local px = (x / (d * t * vp.X / vp.Y) + 1) * 0.5 * vp.X
        local py = (1 - y / (d * t)) * 0.5 * vp.Y
        return Vector2.new(px, py), d
    end
    local function overlay()
        if WC_PROJ.gui and WC_PROJ.gui.Parent then return WC_PROJ.gui end
        local g = Instance.new("ScreenGui")
        g.Name = "WannacryOverlay"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.DisplayOrder = 996
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() g.ScreenInsets = Enum.ScreenInsets.None end)
        g.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        WC_PROJ.gui = g
        return g
    end
    -- прикрепить 2D-элемент к точке над деталью: top — студы над деталью, up — пиксели вверх
    function WC_PROJ.attach(gui, part, top, up, maxDist)
        gui.AnchorPoint = Vector2.new(0.5, 1)
        gui.Visible = false
        gui.Parent = overlay()
        WC_PROJ.items[gui] = {part = part, top = top or 0, up = up or 0, max = maxDist or 120}
        return gui
    end
    local BIND = "WC_Overlay_" .. tostring(math.random(1, 1e6))
    if _genv.__WC_OVERLAY_BIND then pcall(function() RunService:UnbindFromRenderStep(_genv.__WC_OVERLAY_BIND) end) end
    _genv.__WC_OVERLAY_BIND = BIND
    RunService:BindToRenderStep(BIND, Enum.RenderPriority.Last.Value, function()
        if ScriptUnloaded then
            pcall(function() RunService:UnbindFromRenderStep(BIND) end)
            if WC_PROJ.gui then WC_PROJ.gui:Destroy() end
            return
        end
        if next(WC_PROJ.items) == nil then return end
        local cam = Workspace.CurrentCamera
        local origin = WC_PROJ.gui and WC_PROJ.gui.AbsolutePosition or Vector2.zero
        for gui, it in pairs(WC_PROJ.items) do
            if not gui.Parent or not it.part.Parent then
                WC_PROJ.items[gui] = nil
                if gui.Parent and not it.part.Parent then gui:Destroy() end
            else
                local pos = it.part.Position + Vector3.new(0, it.top, 0)
                local sp = WC_PROJ.toScreen(pos)
                if sp and cam and (pos - cam.CFrame.Position).Magnitude <= it.max then
                    gui.Position = UDim2.fromOffset(sp.X - origin.X, sp.Y - origin.Y - it.up)
                    gui.Visible = true
                else
                    gui.Visible = false
                end
            end
        end
    end)
end)() end

do
    local ASPECT_BIND = "WC_Aspect_" .. tostring(math.random(1, 1e6))
    -- если скрипт запущен повторно без Unload — снять растяжение от старой копии
    if _genv.__WC_ASPECT_BIND then pcall(function() RunService:UnbindFromRenderStep(_genv.__WC_ASPECT_BIND) end) end
    _genv.__WC_ASPECT_BIND = ASPECT_BIND
    RunService:BindToRenderStep(ASPECT_BIND, Enum.RenderPriority.Camera.Value + 1, function()
        if ScriptUnloaded then return end
        if State.AspectEnabled then
            _genv.__WC_ASPECT_ACTIVE = true; _genv.__WC_ASPECT_VALUE = State.AspectValue
            camera.CFrame = camera.CFrame * CFrame.new(0,0,0, 1,0,0, 0,State.AspectValue,0, 0,0,1)
        else
            _genv.__WC_ASPECT_ACTIVE = false; _genv.__WC_ASPECT_VALUE = 1
        end
    end)

    local MB = {blur = nil, dof = nil, gui = nil, edges = nil, lastLook = nil, lastPos = nil, rot = 0, lin = 0, yaw = 0}

    local function mbEnsure()
        if not MB.blur or not MB.blur.Parent then
            MB.blur = Instance.new("BlurEffect"); MB.blur.Name = "WCMotionBlur"; MB.blur.Size = 0; MB.blur.Parent = Lighting
        end
        if not MB.dof or not MB.dof.Parent then
            local d = Instance.new("DepthOfFieldEffect")
            d.Name = "WCMotionDOF"; d.FarIntensity = 0; d.NearIntensity = 0; d.FocusDistance = 10; d.InFocusRadius = 50
            d.Parent = Lighting
            MB.dof = d
        end
        if not MB.gui or not MB.gui.Parent then
            local g = Instance.new("ScreenGui")
            g.Name = "WannacryFX"; g.IgnoreGuiInset = true; g.ResetOnSpawn = false; g.DisplayOrder = -10
            g.Parent = parentGui
            MB.gui, MB.edges = g, {}
            local defs = {
                left   = {UDim2.fromScale(0, 0),    UDim2.fromScale(0.3, 1),  0},
                right  = {UDim2.fromScale(0.7, 0),  UDim2.fromScale(0.3, 1),  180},
                top    = {UDim2.fromScale(0, 0),    UDim2.fromScale(1, 0.24), 90},
                bottom = {UDim2.fromScale(0, 0.76), UDim2.fromScale(1, 0.24), 270},
            }
            for k, d in pairs(defs) do
                local f = Instance.new("Frame")
                f.BackgroundColor3 = Color3.fromRGB(6, 8, 14); f.BackgroundTransparency = 1; f.BorderSizePixel = 0
                f.Position = d[1]; f.Size = d[2]; f.Parent = g
                local gr = Instance.new("UIGradient")
                gr.Rotation = d[3]
                gr.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.7), NumberSequenceKeypoint.new(1, 1),
                })
                gr.Parent = f
                MB.edges[k] = f
            end
        end
    end

    local function lerp(a, b, t) return a + (b - a) * t end

    connect(RunService.RenderStepped, function(dt)
        if ScriptUnloaded then return end
        if not State.MotionBlurEnabled then
            if MB.blur then MB.blur.Size = 0 end
            if MB.dof then MB.dof.FarIntensity = 0 end
            if MB.edges then for _, f in pairs(MB.edges) do f.BackgroundTransparency = 1 end end
            MB.lastLook, MB.lastPos, MB.rot, MB.lin, MB.yaw = nil, nil, 0, 0, 0
            return
        end
        mbEnsure()
        dt = math.max(dt, 1 / 240)
        local cf = camera.CFrame
        local look, pos = cf.LookVector, cf.Position
        local rotSpeed, yawRate, linSpeed = 0, 0, 0
        if MB.lastLook then
            rotSpeed = math.acos(math.clamp(look:Dot(MB.lastLook), -1, 1)) / dt
            yawRate = -MB.lastLook:Cross(look).Y / dt
            linSpeed = (pos - MB.lastPos).Magnitude / dt
            if linSpeed > 400 then linSpeed = 0 end
        end
        MB.lastLook, MB.lastPos = look, pos

        local s = math.clamp(State.MotionBlurStrength / 100, 0, 1)
        local rotT = math.clamp((rotSpeed - 1.2) / 6, 0, 1)
        local linT = math.clamp((linSpeed - 20) / 70, 0, 1)
        MB.rot = lerp(MB.rot, rotT, math.min(dt * ((rotT > MB.rot) and 16 or 5), 1))
        MB.lin = lerp(MB.lin, linT, math.min(dt * ((linT > MB.lin) and 8 or 4), 1))
        MB.yaw = lerp(MB.yaw, math.clamp(yawRate / 6, -1, 1), math.min(dt * 10, 1))

        local amount = math.max(MB.rot, MB.lin)
        MB.dof.FocusDistance = 10
        MB.dof.InFocusRadius = 50 - 38 * amount
        MB.dof.FarIntensity = math.clamp((MB.rot * 0.9 + MB.lin * 0.7) * s, 0, 1)
        MB.blur.Size = math.max(MB.rot - 0.6, 0) / 0.4 * 5 * s

        local base = MB.lin * 0.32 * s
        local turn = MB.rot * 0.5 * s
        MB.edges.right.BackgroundTransparency  = 1 - math.clamp(base + turn * (0.25 + math.max(MB.yaw, 0)), 0, 0.85)
        MB.edges.left.BackgroundTransparency   = 1 - math.clamp(base + turn * (0.25 + math.max(-MB.yaw, 0)), 0, 0.85)
        MB.edges.top.BackgroundTransparency    = 1 - math.clamp(base * 0.7 + turn * 0.15, 0, 0.85)
        MB.edges.bottom.BackgroundTransparency = 1 - math.clamp(base * 0.7 + turn * 0.15, 0, 0.85)
    end)
    function Features.destroyMotionBlur()
        for _, k in ipairs({"blur", "dof", "gui"}) do
            if MB[k] then pcall(function() MB[k]:Destroy() end); MB[k] = nil end
        end
        MB.edges = nil
    end

    function Features.applyFog()
        local ex = Lighting:FindFirstChild("WCFog"); if ex then ex:Destroy() end
        if not State.FogEnabled then return end
        local fog = Instance.new("Atmosphere")
        fog.Name = "WCFog"; fog.Density = State.FogSettings.Density; fog.Offset = State.FogSettings.Offset; fog.Color = State.FogSettings.Color; fog.Decay = State.FogSettings.Decay; fog.Glare = 0; fog.Haze = 1.5; fog.Parent = Lighting
    end

    local hiddenSkies = {}
    local skyGuardConn = nil

    local function hideGameSkies()
        for _, s in ipairs(Lighting:GetChildren()) do
            if s:IsA("Sky") and s.Name ~= "WCSky" then
                table.insert(hiddenSkies, s)
                s.Parent = nil
            end
        end
    end
    local function restoreGameSkies()
        for _, s in ipairs(hiddenSkies) do
            pcall(function() s.Parent = Lighting end)
        end
        hiddenSkies = {}
    end

    local function resolveSkyData()
        if State.SkyIndex > #SKIES then
            local id = tostring(State.SkyCustomId or ""):match("%d+")
            if not id then return nil end
            return {name = "Свой ID", bk = id, dn = id, ft = id, lf = id, rt = id, up = id}
        end
        return SKIES[State.SkyIndex]
    end

    function Features.applySky()
        local ex = Lighting:FindFirstChild("WCSky"); if ex then ex:Destroy() end
        if skyGuardConn then skyGuardConn:Disconnect(); skyGuardConn = nil end
        if not State.SkyEnabled or ScriptUnloaded then restoreGameSkies(); return end
        local d = resolveSkyData()
        if not d then restoreGameSkies(); return end

        hideGameSkies()
        local sky = Instance.new("Sky"); sky.Name = "WCSky"
        sky.SkyboxBk = "rbxassetid://"..d.bk; sky.SkyboxDn = "rbxassetid://"..d.dn; sky.SkyboxFt = "rbxassetid://"..d.ft
        sky.SkyboxLf = "rbxassetid://"..d.lf; sky.SkyboxRt = "rbxassetid://"..d.rt; sky.SkyboxUp = "rbxassetid://"..d.up
        pcall(function() sky.StarCount = d.starCount or 3000 end)
        pcall(function() sky.CelestialBodiesShown = State.SkyCelestial and not d.space end)
        sky.Parent = Lighting

        task.spawn(function()
            pcall(function() ContentProvider:PreloadAsync({sky}) end)
        end)

        skyGuardConn = Lighting.ChildAdded:Connect(function(c)
            if c:IsA("Sky") and c.Name ~= "WCSky" and State.SkyEnabled and not ScriptUnloaded then
                task.defer(function()
                    if c.Parent == Lighting then table.insert(hiddenSkies, c); c.Parent = nil end
                end)
            end
        end)
    end

    local function wantedClock()
        if State.CustomTimeEnabled then return State.CustomTimeValue end
        if State.FullbrightEnabled then return 12 end
        return nil
    end
    function Features.applyFullbright()
        if not State.FullbrightEnabled then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            if not State.CustomTimeEnabled then Lighting.ClockTime = originalLighting.ClockTime end
            return
        end
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = State.FullbrightBrightness
        Lighting.ClockTime = wantedClock()
        Lighting.GlobalShadows = false
    end
    function Features.applyWorld()
        local ex = Lighting:FindFirstChild("WCWorld"); if ex then ex:Destroy() end
        if not State.WorldEnabled then return end
        local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "WCWorld"; cc.Saturation = State.WorldSettings.Saturation; cc.Contrast = State.WorldSettings.Contrast; cc.Brightness = State.WorldSettings.Brightness; cc.TintColor = State.WorldSettings.TintColor; cc.Parent = Lighting
    end
    function Features.applyCustomTime()
        if not State.CustomTimeEnabled then
            if State.FullbrightEnabled then Lighting.ClockTime = 12
            else Lighting.ClockTime = originalLighting.ClockTime end
            return
        end
        Lighting.ClockTime = State.CustomTimeValue
    end

    local lightAcc = 0
    connect(RunService.Heartbeat, function(dt)
        if ScriptUnloaded then return end
        lightAcc += dt
        if lightAcc < 0.2 then return end
        lightAcc = 0
        local clock = wantedClock()
        if clock and math.abs(Lighting.ClockTime - clock) > 0.01 then Lighting.ClockTime = clock end
        if State.FullbrightEnabled then
            if Lighting.Brightness ~= State.FullbrightBrightness then Lighting.Brightness = State.FullbrightBrightness end
            if Lighting.Ambient ~= Color3.new(1, 1, 1) then Lighting.Ambient = Color3.new(1, 1, 1) end
            if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end
            if Lighting.GlobalShadows then Lighting.GlobalShadows = false end
        end
    end)

    local DBD_ANIMATIONS = {
        ["idle"] = "rbxassetid://616158929", ["walk"] = "rbxassetid://616168032", ["run"] = "rbxassetid://616163682",
        ["jump"] = "rbxassetid://616161997", ["fall"] = "rbxassetid://616157476", ["climb"] = "rbxassetid://616156119",
    }
    local DBD_SLOTS = {
        {"idle", "Animation1", "idle"}, {"idle", "Animation2", "idle"},
        {"walk", "WalkAnim", "walk"}, {"run", "RunAnim", "run"},
        {"jump", "JumpAnim", "jump"}, {"fall", "FallAnim", "fall"},
        {"climb", "ClimbAnim", "climb"},
    }
    local originalAnimations = setmetatable({}, {__mode = "k"})

    local function getAnimObj(animate, folder, name)
        local f = animate:FindFirstChild(folder)
        local a = f and f:FindFirstChild(name)
        if a and a:IsA("Animation") then return a end
        return nil
    end

    local function restartTracks(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0.1) end) end
    end

    function Features.applyDBDAnimations(enable)
        local char = player.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        local saved = originalAnimations[char]
        restartTracks(char)
        pcall(function() animate.Disabled = true end)
        if enable then
            if not saved then
                saved = {}
                for i, slot in ipairs(DBD_SLOTS) do
                    local a = getAnimObj(animate, slot[1], slot[2])
                    if a then saved[i] = a.AnimationId end
                end
                originalAnimations[char] = saved
            end
            for _, slot in ipairs(DBD_SLOTS) do
                local a = getAnimObj(animate, slot[1], slot[2])
                if a then a.AnimationId = DBD_ANIMATIONS[slot[3]] end
            end
        else
            if not saved then pcall(function() animate.Disabled = false end); return end
            for i, slot in ipairs(DBD_SLOTS) do
                local a = getAnimObj(animate, slot[1], slot[2])
                if a and saved[i] then a.AnimationId = saved[i] end
            end
            originalAnimations[char] = nil
        end
        pcall(function() animate.Disabled = false end)
    end

    local Atm = {
        Folder = nil, SnowFolder = nil, EmitterPart = nil, Emitter = nil, ParticleConn = nil,
        LastCenter = nil, Token = 0, BuildId = 0, SliderStamp = 0, Seed = 0,
        Leaves = {}, LeafPool = {}, LeafConn = nil
    }

    local SNOW_RADIUS    = 1000 
    local SNOW_REBUILD   = 250  
    local SNOW_RAY_TOP   = 1000 
    local SNOW_FADE_TIME = 2.0  
    local RAYS_PER_FRAME = 600

    local SNOW_CELL      = 20
    local SNOW_THICK     = 0.2
    local CAP_MAX_FACE   = 160

    local BLOB_R_MAX     = 45   
    local BLOB_R_MIN     = 7    
    local BLOB_HEIGHT    = 0.8  
    local MIN_COVERAGE   = 0.08 
    local MAX_BLOBS      = 6000 
    local BLOB_TILE      = 200  

    local LEAF_URL       = "https://i.ibb.co/mVfTt1FK/istockphoto-2166605367-612x612-no-bg-preview-carve-photos.png" 
    local LEAF_FILE      = "WannacryAssets/leaf.png"
    local LEAF_RATE      = 25   
    local LEAF_MAX       = 150  
    local LEAF_LIE_TIME  = 5    
    local LEAF_FADE_TIME = 1    
    local LEAF_SPAWN_H   = 35   
    local LEAF_COLORS = {
        Color3.fromRGB(230, 170, 40), Color3.fromRGB(215, 120, 30), Color3.fromRGB(190, 70, 25),
        Color3.fromRGB(160, 45, 30),  Color3.fromRGB(200, 150, 60), Color3.fromRGB(140, 90, 40),
    }
    local leafAsset = nil

    local function makeSnowPart(parent)
        local p = Instance.new("Part")
        p.Name = "WC_Snow"
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.CastShadow = false
        p.Material = Enum.Material.Snow
        p.Color = Color3.fromRGB(255, 255, 255)
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Transparency = 1 
        return p
    end

    local function newSnowSlab(parent, size, cf)
        local p = makeSnowPart(parent)
        p.Size = size
        p.CFrame = cf
        p.Parent = parent
        return p
    end

    local function newSnowBlob(parent, a, b, cf)
        local p = makeSnowPart(parent)
        p.Size = Vector3.new(a * 2, BLOB_HEIGHT, b * 2)
        p.CFrame = cf
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Parent = p
        p.Parent = parent
        return p
    end

    local function fadeSnow(folder, duration, onDone)
        task.spawn(function()
            local t0 = os.clock()
            while folder.Parent do
                local a = math.min((os.clock() - t0) / duration, 1)
                a = a * a * (3 - 2 * a)
                local tr = 1 - a
                for _, p in ipairs(folder:GetChildren()) do p.Transparency = tr end
                if a >= 1 then break end
                task.wait(0.05)
            end
            if onDone then onDone() end
        end)
    end

    local function addFilter(params, list, inst)
        table.insert(list, inst)
        local ok = pcall(function() params:AddToFilter(inst) end)
        if not ok then params.FilterDescendantsInstances = list end
    end

    local function getTopFace(part)
        local cf, s = part.CFrame, part.Size
        local axes = {
            {cf.RightVector, s.X, cf.UpVector,    s.Y, s.Z},
            {cf.UpVector,    s.Y, cf.RightVector, s.X, s.Z},
            {cf.LookVector,  s.Z, cf.RightVector, s.X, s.Y},
        }
        local best, bestDot = nil, -1
        for _, a in ipairs(axes) do
            local n, d = a[1], a[1].Y
            if d < 0 then n = -n; d = -d end
            if d > bestDot then
                bestDot = d
                best = {n = n, half = a[2] / 2, u = a[3], su = a[4], sv = a[5]}
            end
        end
        return best, bestDot
    end

    local function cframeOnNormal(pos, n)
        local right = Vector3.new(1, 0, 0)
        if math.abs(n.X) > 0.9 then right = Vector3.new(0, 0, 1) end
        right = (right - n * right:Dot(n)).Unit
        return CFrame.fromMatrix(pos, right, n)
    end

    local function castTop(origin, params, filter)
        for _ = 1, 8 do
            local r = Workspace:Raycast(origin, Vector3.new(0, -SNOW_RAY_TOP * 2, 0), params)
            if not r then return nil end
            local inst = r.Instance
            if inst == Workspace.Terrain then return r end
            local skip = nil
            if inst.Transparency >= 0.9 or not inst:IsGrounded() then
                skip = inst
            else
                local model = inst:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then skip = model end
            end
            if not skip then return r end
            addFilter(params, filter, skip)
        end
        return nil
    end

    local function buildFull(ctx)
        local center, params, filter, folder, yield = ctx.center, ctx.params, ctx.filter, ctx.folder, ctx.yield
        local capped, noCap = {}, {}
        local flat, slopes = {}, {}
        local n = math.floor(SNOW_RADIUS / SNOW_CELL)
        local topY = center.Y + SNOW_RAY_TOP
        local ox = math.floor(center.X / SNOW_CELL + 0.5) * SNOW_CELL
        local oz = math.floor(center.Z / SNOW_CELL + 0.5) * SNOW_CELL
        local count = 0

        for i = -n, n do
            local row = nil
            for j = -n, n do
                if i * i + j * j <= n * n then
                    local r = castTop(Vector3.new(ox + i * SNOW_CELL, topY, oz + j * SNOW_CELL), params, filter)
                    if r and r.Normal.Y >= 0.5 then
                        local inst = r.Instance
                        local handled = false
                        if inst ~= Workspace.Terrain and not noCap[inst] and inst:IsA("Part") and inst.Shape == Enum.PartType.Block then
                            if capped[inst] then
                                handled = true
                            else
                                local face, dot = getTopFace(inst)
                                if dot >= 0.5 and math.max(face.su, face.sv) <= CAP_MAX_FACE then
                                    capped[inst] = true
                                    handled = true
                                    local pos = inst.Position + face.n * (face.half + SNOW_THICK / 2)
                                    newSnowSlab(folder, Vector3.new(face.su, SNOW_THICK, face.sv), CFrame.fromMatrix(pos, face.u, face.n))
                                else
                                    noCap[inst] = true
                                end
                            end
                        end
                        if not handled then
                            if r.Normal.Y >= 0.98 then
                                row = row or {}
                                row[j] = r.Position.Y
                            else
                                table.insert(slopes, {r.Position, r.Normal})
                            end
                        end
                    end
                    count += 1
                    if count % RAYS_PER_FRAME == 0 and yield() then return false end
                end
            end
            flat[i] = row
        end

        local function hKey(h) return math.floor(h * 4 + 0.5) end
        local active, rects = {}, {}
        for i = -n, n do
            local row = flat[i]
            local newActive = {}
            if row then
                local j = -n
                while j <= n do
                    local h = row[j]
                    if h then
                        local k = hKey(h)
                        local j1, maxH = j, h
                        while row[j1 + 1] and hKey(row[j1 + 1]) == k do
                            j1 += 1
                            maxH = math.max(maxH, row[j1])
                        end
                        local key = j .. ":" .. j1 .. ":" .. k
                        local rect = active[key]
                        if rect then
                            rect.i1 = i
                            rect.h = math.max(rect.h, maxH)
                        else
                            rect = {i0 = i, i1 = i, j0 = j, j1 = j1, h = maxH}
                            table.insert(rects, rect)
                        end
                        newActive[key] = rect
                        j = j1 + 1
                    else
                        j += 1
                    end
                end
            end
            active = newActive
        end

        for idx, rc in ipairs(rects) do
            local sx = (rc.i1 - rc.i0 + 1) * SNOW_CELL
            local sz = (rc.j1 - rc.j0 + 1) * SNOW_CELL
            local cx = ox + (rc.i0 + rc.i1) / 2 * SNOW_CELL
            local cz = oz + (rc.j0 + rc.j1) / 2 * SNOW_CELL
            newSnowSlab(folder, Vector3.new(sx, SNOW_THICK, sz), CFrame.new(cx, rc.h + SNOW_THICK / 2, cz))
            if idx % 500 == 0 and yield() then return false end
        end
        for idx, s in ipairs(slopes) do
            local pos, nrm = s[1], s[2]
            newSnowSlab(folder, Vector3.new(SNOW_CELL * 1.15, SNOW_THICK, SNOW_CELL * 1.15), cframeOnNormal(pos + nrm * (SNOW_THICK / 2), nrm))
            if idx % 500 == 0 and yield() then return false end
        end
        return true
    end

    local function buildBlobs(ctx, spread)
        local center, params, filter, folder, yield = ctx.center, ctx.params, ctx.filter, ctx.folder, ctx.yield

        local coverage = math.clamp(1 - spread * (1 - MIN_COVERAGE), MIN_COVERAGE, 0.995)
        local R = BLOB_R_MAX + (BLOB_R_MIN - BLOB_R_MAX) * spread
        local meanArea = math.pi * R * R * 1.0833 * 0.775
        local density = -math.log(1 - coverage) / meanArea
        local regionArea = math.pi * SNOW_RADIUS * SNOW_RADIUS
        local expected = density * regionArea
        if expected > MAX_BLOBS then
            local k = math.sqrt(expected / MAX_BLOBS)
            R = R * k
            meanArea = meanArea * k * k
            density = -math.log(1 - coverage) / meanArea
        end

        local topY = center.Y + SNOW_RAY_TOP
        local seedBase = math.floor(Atm.Seed * 1000)
        local t0x = math.floor((center.X - SNOW_RADIUS) / BLOB_TILE)
        local t1x = math.floor((center.X + SNOW_RADIUS) / BLOB_TILE)
        local t0z = math.floor((center.Z - SNOW_RADIUS) / BLOB_TILE)
        local t1z = math.floor((center.Z + SNOW_RADIUS) / BLOB_TILE)
        local perTile = density * BLOB_TILE * BLOB_TILE
        local rays = 0

        local function heightAt(x, z)
            rays += 1
            return castTop(Vector3.new(x, topY, z), params, filter)
        end

        for tx = t0x, t1x do
            for tz = t0z, t1z do
                local rng = Random.new(seedBase + tx * 7919 + tz * 104729)
                local cnt = math.floor(perTile)
                if rng:NextNumber() < perTile - cnt then cnt += 1 end
                for _ = 1, cnt do
                    local x = (tx + rng:NextNumber()) * BLOB_TILE
                    local z = (tz + rng:NextNumber()) * BLOB_TILE
                    local a = R * rng:NextNumber(0.5, 1.5)        
                    local b = a * rng:NextNumber(0.55, 1)          
                    local ang = rng:NextNumber(0, math.pi * 2)     
                    local dx, dz = x - center.X, z - center.Z
                    if dx * dx + dz * dz <= SNOW_RADIUS * SNOW_RADIUS then
                        local hit = heightAt(x, z)
                        if hit and hit.Normal.Y >= 0.5 then
                            local nrm = hit.Normal
                            local base = cframeOnNormal(hit.Position, nrm) * CFrame.Angles(0, ang, 0)
                            local ax, bz = base.RightVector, base.LookVector
                            local ok = false
                            for _ = 1, 3 do
                                ok = true
                                for _, off in ipairs({ax * a * 0.85, -ax * a * 0.85, bz * b * 0.85, -bz * b * 0.85}) do
                                    local p = hit.Position + off
                                    local h2 = heightAt(p.X, p.Z)
                                    if not h2 or math.abs(h2.Position.Y - p.Y) > 1.5 then ok = false; break end
                                end
                                if ok then break end
                                a, b = a * 0.55, b * 0.55
                            end
                            if ok and a >= 1 then
                                newSnowBlob(folder, a, b, base)
                            end
                        end
                    end
                    if rays >= RAYS_PER_FRAME then
                        rays = 0
                        if yield() then return false end
                    end
                end
            end
        end
        return true
    end

    local function buildSnow(token)
        Atm.BuildId += 1
        local buildId = Atm.BuildId

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not Atm.Folder then return end
        local center = hrp.Position
        Atm.LastCenter = center

        local filter = {Atm.Folder}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then table.insert(filter, plr.Character) end
        end
        for _, name in ipairs({"WCParticles", "WCJumpRing"}) do
            local f = Workspace:FindFirstChild(name)
            if f then table.insert(filter, f) end
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = filter
        params.IgnoreWater = true

        local newFolder = Instance.new("Folder")
        newFolder.Name = "WC_SnowLayer"

        local ctx = {
            center = center, params = params, filter = filter, folder = newFolder,
            yield = function()
                RunService.Heartbeat:Wait()
                return Atm.Token ~= token or Atm.BuildId ~= buildId or ScriptUnloaded
            end,
        }

        local spread = math.clamp(State.AtmosphereSpread or 0, 0, 100) / 100
        local done
        if spread <= 0.001 then
            done = buildFull(ctx)
        else
            done = buildBlobs(ctx, spread)
        end

        if not done or Atm.Token ~= token or Atm.BuildId ~= buildId or ScriptUnloaded then
            newFolder:Destroy()
            return
        end

        local old = Atm.SnowFolder
        newFolder.Parent = Atm.Folder
        Atm.SnowFolder = newFolder
        fadeSnow(newFolder, SNOW_FADE_TIME, function()
            if old and old.Parent and Atm.SnowFolder ~= old then old:Destroy() end
        end)
    end

    function Features.updateAtmosphereSpread()
        Atm.SliderStamp += 1
        local stamp = Atm.SliderStamp
        task.delay(0.35, function()
            if stamp ~= Atm.SliderStamp then return end
            if not State.AtmosphereEnabled or not Atm.Folder then return end
            if State.AtmosphereType == "Зима" then
                buildSnow(Atm.Token)
            end
        end)
    end

    local function setupSnowParticles()
        local emitterPart = Instance.new("Part")
        emitterPart.Name = "WC_SnowEmitter"
        emitterPart.Size = Vector3.new(250, 1, 250)
        emitterPart.Transparency = 1
        emitterPart.Anchored = true
        emitterPart.CanCollide = false
        emitterPart.CanTouch = false
        emitterPart.CanQuery = false
        emitterPart.Parent = Atm.Folder

        local pe = Instance.new("ParticleEmitter")
        pe.Name = "WCSnowParticles"
        pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
        pe.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.35)})
        pe.Transparency = NumberSequence.new(0)
        pe.Lifetime = NumberRange.new(5, 8)
        pe.Rate = 150
        pe.Speed = NumberRange.new(2, 5)
        pe.SpreadAngle = Vector2.new(15, 15)
        pe.Rotation = NumberRange.new(0, 360)
        pe.RotSpeed = NumberRange.new(-45, 45)
        pe.LightEmission = 0
        pe.LightInfluence = 0
        pe.Acceleration = Vector3.new(0, -5, 0)
        pe.EmissionDirection = Enum.NormalId.Bottom
        pe.Parent = emitterPart

        Atm.EmitterPart = emitterPart
        Atm.Emitter = pe

        Atm.ParticleConn = RunService.Heartbeat:Connect(function()
            if Atm.EmitterPart and Atm.EmitterPart.Parent then
                local c = player.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    Atm.EmitterPart.CFrame = CFrame.new(r.Position.X, r.Position.Y + 40, r.Position.Z)
                end
            end
        end)
    end

    local function getLeaf()
        local L = table.remove(Atm.LeafPool)
        if not L then
            local p = Instance.new("Part")
            p.Name = "WC_Leaf"
            p.Anchored = true
            p.CanCollide = false
            p.CanTouch = false
            p.CanQuery = false
            p.CastShadow = false
            p.Material = Enum.Material.SmoothPlastic
            L = {p = p, decals = {}}
            if leafAsset ~= "" then
                p.Transparency = 1
                for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom}) do
                    local d = Instance.new("Decal")
                    d.Texture = leafAsset
                    d.Face = face
                    d.Parent = p
                    table.insert(L.decals, d)
                end
            end
        end
        local s = math.random(80, 160) / 100
        L.p.Size = Vector3.new(s, 0.05, s)
        local col = LEAF_COLORS[math.random(#LEAF_COLORS)]
        if leafAsset ~= "" then
            for _, d in ipairs(L.decals) do d.Color3 = col; d.Transparency = 0 end
        else
            L.p.Color = col
            L.p.Transparency = 0
        end
        return L
    end

    local function setLeafAlpha(L, t)
        if #L.decals > 0 then
            for _, d in ipairs(L.decals) do d.Transparency = t end
        else
            L.p.Transparency = t
        end
    end

    local function spawnLeaf()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local area = 30 + 170 * math.clamp((State.AtmosphereSpread or 0) / 100, 0, 1)
        local ang, rad = math.random() * math.pi * 2, area * math.sqrt(math.random())
        local start = hrp.Position + Vector3.new(math.cos(ang) * rad, LEAF_SPAWN_H + math.random() * 15, math.sin(ang) * rad)

        local filter = {Atm.Folder}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then table.insert(filter, plr.Character) end
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = filter
        params.IgnoreWater = true
        local hit = Workspace:Raycast(start, Vector3.new(0, -400, 0), params)
        if not hit or hit.Normal.Y < 0.3 then return end

        local L = getLeaf()
        L.x0, L.z0, L.y = start.X, start.Z, start.Y
        L.groundY = hit.Position.Y + 0.03
        L.normal = hit.Normal
        L.yaw = math.random() * math.pi * 2
        L.amp = 1 + math.random() * 2.5
        L.freq = 0.6 + math.random() * 0.8
        L.phase = math.random() * math.pi * 2
        L.spin = (math.random() - 0.5) * 4
        L.speed = 4 + math.random() * 4
        L.state = "fall"
        L.t = 0
        L.p.Parent = Atm.Folder
        table.insert(Atm.Leaves, L)
    end

    local function setupAutumn()
        if leafAsset == nil then
            leafAsset = (LEAF_URL ~= "" and LoadCustomAsset(LEAF_URL, LEAF_FILE)) or ""
        end
        Atm.Leaves, Atm.LeafPool = {}, {}
        local acc = 0
        Atm.LeafConn = RunService.Heartbeat:Connect(function(dt)
            if not Atm.Folder then return end
            acc += dt * LEAF_RATE
            while acc >= 1 do
                acc -= 1
                if #Atm.Leaves < LEAF_MAX then spawnLeaf() end
            end

            local parts, cfs = {}, {}
            local i = 1
            while i <= #Atm.Leaves do
                local L = Atm.Leaves[i]
                L.t += dt
                local remove = false
                if L.state == "fall" then
                    L.y -= L.speed * dt
                    local k = math.clamp((L.y - L.groundY) / 10, 0, 1)
                    local x = L.x0 + math.sin(L.t * L.freq + L.phase) * L.amp * k
                    local z = L.z0 + math.cos(L.t * L.freq * 0.7 + L.phase) * L.amp * 0.6 * k
                    if L.y <= L.groundY then
                        L.state, L.t = "lie", 0
                        table.insert(parts, L.p)
                        table.insert(cfs, cframeOnNormal(Vector3.new(L.x0, L.groundY, L.z0), L.normal) * CFrame.Angles(0, L.yaw, 0))
                    else
                        table.insert(parts, L.p)
                        table.insert(cfs, CFrame.new(x, L.y, z) * CFrame.Angles(
                            math.sin(L.t * 2 + L.phase) * 0.8 * k,
                            L.yaw + L.t * L.spin,
                            math.cos(L.t * 1.7 + L.phase) * 0.6 * k))
                    end
                elseif L.state == "lie" then
                    if L.t >= LEAF_LIE_TIME then L.state, L.t = "fade", 0 end
                elseif L.state == "fade" then
                    local a = math.min(L.t / LEAF_FADE_TIME, 1)
                    setLeafAlpha(L, a)
                    if a >= 1 then remove = true end
                end

                if remove then
                    L.p.Parent = nil
                    table.insert(Atm.LeafPool, L)
                    Atm.Leaves[i] = Atm.Leaves[#Atm.Leaves]
                    Atm.Leaves[#Atm.Leaves] = nil
                else
                    i += 1
                end
            end
            if #parts > 0 then
                Workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
            end
        end)
    end

    function Features.applyAtmosphere()
        Atm.Token += 1
        Atm.BuildId += 1
        if Atm.ParticleConn then Atm.ParticleConn:Disconnect() end
        if Atm.LeafConn then Atm.LeafConn:Disconnect(); Atm.LeafConn = nil end
        if Atm.LeafPool then for _, L in ipairs(Atm.LeafPool) do L.p:Destroy() end end
        Atm.Leaves, Atm.LeafPool = {}, {}
        if Atm.Folder then Atm.Folder:Destroy() end
        Atm.Folder, Atm.SnowFolder, Atm.EmitterPart, Atm.Emitter, Atm.ParticleConn, Atm.LastCenter = nil, nil, nil, nil, nil, nil

        if not State.AtmosphereEnabled or ScriptUnloaded or State.AtmosphereType == "Нет" then return end

        Atm.Seed = math.random() * 1000 + 0.5

        Atm.Folder = Instance.new("Folder")
        Atm.Folder.Name = "WannacryAtmosphere"
        Atm.Folder.Parent = Workspace

        if State.AtmosphereType == "Зима" then
            setupSnowParticles()
            local token = Atm.Token
            task.spawn(function()
                while Atm.Token == token and not ScriptUnloaded do
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (not Atm.LastCenter or (hrp.Position - Atm.LastCenter).Magnitude > SNOW_REBUILD) then
                        buildSnow(token)
                    end
                    task.wait(1)
                end
            end)
        elseif State.AtmosphereType == "Осень" then
            setupAutumn()
        end
    end

    local PA = {list = {}, conn = nil, folder = nil}
    local function createParticle()
        if not State.ParticlesEnabled or not PA.folder then return end
        local color = getVisualColor(State.ParticlesUseTheme, State.ParticlesCustomColor)
        local char = player.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local base = root.Position + Vector3.new(0, 30, 0); local ang = math.random() * math.pi * 2; local rad = math.random() * 250
        local size = math.random(20, 50) / 100
        local s = Instance.new("Part"); s.Name = "WCParticle"; s.Shape = Enum.PartType.Ball; s.Size = Vector3.new(size, size, size); s.Position = base + Vector3.new(math.cos(ang) * rad, 0, math.sin(ang) * rad)
        s.Anchored = true; s.CanCollide = false; s.CastShadow = false; s.Material = Enum.Material.Neon; s.Color = color; s.Transparency = 0; s.Parent = PA.folder
        local light = Instance.new("PointLight"); light.Color = color; light.Brightness = 0.5; light.Range = 3; light.Shadows = false; light.Parent = s
        table.insert(PA.list, s)
        local dur = math.random(4, 7); local dist = math.random(25, 40); local target = s.Position + Vector3.new(math.random(-3, 3), -dist, math.random(-3, 3))
        TweenService:Create(s, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Position = target}):Play()
        TweenService:Create(light, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Brightness = 0, Range = 0}):Play()
        task.delay(dur - 1.2, function() if s and s.Parent then TweenService:Create(s, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Transparency = 1}):Play() end end)
        task.delay(dur + 0.3, function() if s and s.Parent then s:Destroy() end end)
    end
    function Features.applyParticles()
        if PA.folder then PA.folder:Destroy(); PA.folder = nil end
        if PA.conn then PA.conn:Disconnect(); PA.conn = nil end
        for _, p in ipairs(PA.list) do if p and p.Parent then p:Destroy() end end
        PA.list = {}
        if not State.ParticlesEnabled then return end
        PA.folder = Instance.new("Folder"); PA.folder.Name = "WCParticles"; PA.folder.Parent = Workspace
        PA.conn = RunService.Heartbeat:Connect(function() if math.random() < 0.45 then createParticle() end end)
    end

    local TR = {a0 = nil, a1 = nil, trail = nil}
    function Features.applyTrails()
        if TR.a0 then TR.a0:Destroy(); TR.a0 = nil end
        if TR.a1 then TR.a1:Destroy(); TR.a1 = nil end
        if TR.trail then TR.trail:Destroy(); TR.trail = nil end
        if not State.TrailsEnabled then return end
        local char = player.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local color = getVisualColor(State.TrailsUseTheme, State.TrailsCustomColor)
        TR.a0 = Instance.new("Attachment"); TR.a0.Name = "WCTrailA0"; TR.a0.Position = Vector3.new(-0.8, 0, 0); TR.a0.Parent = root
        TR.a1 = Instance.new("Attachment"); TR.a1.Name = "WCTrailA1"; TR.a1.Position = Vector3.new(0.8, 0, 0); TR.a1.Parent = root
        TR.trail = Instance.new("Trail"); TR.trail.Name = "WCTrail"; TR.trail.Attachment0 = TR.a0; TR.trail.Attachment1 = TR.a1; TR.trail.Lifetime = 0.6; TR.trail.MinLength = 0; TR.trail.FaceCamera = true; TR.trail.LightEmission = 1; TR.trail.LightInfluence = 0
        TR.trail.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(0.5, color), ColorSequenceKeypoint.new(1, color)})
        TR.trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 0.5), NumberSequenceKeypoint.new(1, 1)})
        TR.trail.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 0)}); TR.trail.Parent = root
    end

    local JC = {circles = {}, models = {}, lights = {}}
    local function createSoftLight(parent, color)
        if not State.JumpCircleGlow or math.random() > 0.15 then return nil end
        local light = Instance.new("PointLight"); light.Brightness = 0; light.Range = 0; light.Color = Color3.new(color.R * 0.6, color.G * 0.6, color.B * 0.6); light.Shadows = false; light.Parent = parent
        table.insert(JC.lights, light); TweenService:Create(light, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Brightness = 0.6, Range = 5}):Play()
        task.delay(0.35, function() if light and light.Parent then TweenService:Create(light, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Brightness = 0, Range = 0}):Play() end end)
        return light
    end
    local function makeSegmentsCircle(position, color, model, material)
        local segments, startRadius, endRadius = 48, 1.2, 6; local thickness, height = 0.35, 0.1; local created = {}
        for i = 1, segments do
            local angle = (i / segments) * math.pi * 2; local sx, sz = math.cos(angle) * startRadius, math.sin(angle) * startRadius; local ex, ez = math.cos(angle) * endRadius, math.sin(angle) * endRadius
            local seg = Instance.new("Part"); seg.Name = "Segment"; seg.Shape = Enum.PartType.Block; seg.Size = Vector3.new((2 * math.pi * startRadius) / segments * 1.3, height, thickness); seg.CFrame = CFrame.new(position + Vector3.new(sx, 0.1, sz)) * CFrame.Angles(0, -angle, 0)
            seg.Anchored = true; seg.CanCollide = false; seg.CastShadow = false; seg.Material = material; seg.Color = color; seg.Transparency = 0; seg.Parent = model
            createSoftLight(seg, color); seg:SetAttribute("EndX", ex); seg:SetAttribute("EndZ", ez); seg:SetAttribute("StartAngle", -angle); table.insert(created, seg)
        end
        local ti = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        for _, seg in ipairs(created) do local fx = position + Vector3.new(seg:GetAttribute("EndX"), 0.1, seg:GetAttribute("EndZ")); TweenService:Create(seg, ti, {CFrame = CFrame.new(fx) * CFrame.Angles(0, seg:GetAttribute("StartAngle"), 0), Transparency = 1, Size = Vector3.new(seg.Size.X * 1.5, height, thickness * 0.5)}):Play() end
        return created
    end
    local function makeRingCircle(position, color, model, material)
        local segments, startRadius, endRadius = 180, 1.2, 6; local thickness, height = 0.1, 0.06; local created = {}
        for i = 1, segments do
            local angle = (i / segments) * math.pi * 2; local sx, sz = math.cos(angle) * startRadius, math.sin(angle) * startRadius; local ex, ez = math.cos(angle) * endRadius, math.sin(angle) * endRadius
            local seg = Instance.new("Part"); seg.Name = "RingSeg"; seg.Shape = Enum.PartType.Block; seg.Size = Vector3.new((2 * math.pi * startRadius) / segments * 3, height, thickness); seg.CFrame = CFrame.new(position + Vector3.new(sx, 0.1, sz)) * CFrame.Angles(0, -angle, 0)
            seg.Anchored = true; seg.CanCollide = false; seg.CastShadow = false; seg.Material = material; seg.Color = color; seg.Transparency = 0; seg.Parent = model
            createSoftLight(seg, color); seg:SetAttribute("EndX", ex); seg:SetAttribute("EndZ", ez); seg:SetAttribute("StartAngle", -angle); table.insert(created, seg)
        end
        local ti = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        for _, seg in ipairs(created) do local fx = position + Vector3.new(seg:GetAttribute("EndX"), 0.1, seg:GetAttribute("EndZ")); TweenService:Create(seg, ti, {CFrame = CFrame.new(fx) * CFrame.Angles(0, seg:GetAttribute("StartAngle"), 0), Transparency = 1, Size = Vector3.new(seg.Size.X * 1.3, height, thickness * 0.5)}):Play() end
        return created
    end
    local function makeSquareCircle(position, color, model, material)
        local segments, startRadius, endRadius = 64, 1.2, 6; local thickness, height = 0.35, 0.1; local created = {}
        local function squarePoint(t, r) local side = math.floor(t * 4) % 4; local localT = (t * 4) % 1; local x, z; if side == 0 then x, z = -r + 2 * r * localT, -r elseif side == 1 then x, z = r, -r + 2 * r * localT elseif side == 2 then x, z = r - 2 * r * localT, r else x, z = -r, r - 2 * r * localT end; return x, z end
        for i = 1, segments do
            local t = (i - 1) / segments; local sx, sz = squarePoint(t, startRadius); local ex, ez = squarePoint(t, endRadius)
            local seg = Instance.new("Part"); seg.Name = "SquareSeg"; seg.Shape = Enum.PartType.Block; local dx, dz = ex - sx, ez - sz; local len = math.sqrt(dx * dx + dz * dz)
            seg.Size = Vector3.new(len * 1.2, height, thickness); seg.CFrame = CFrame.new(position + Vector3.new(sx, 0.1, sz)) * CFrame.Angles(0, -math.atan2(dz, dx), 0)
            seg.Anchored = true; seg.CanCollide = false; seg.CastShadow = false; seg.Material = material; seg.Color = color; seg.Transparency = 0; seg.Parent = model
            createSoftLight(seg, color); seg:SetAttribute("EndX", ex); seg:SetAttribute("EndZ", ez); seg:SetAttribute("StartAngle", -math.atan2(dz, dx)); table.insert(created, seg)
        end
        local ti = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        for _, seg in ipairs(created) do local fx = position + Vector3.new(seg:GetAttribute("EndX"), 0.1, seg:GetAttribute("EndZ")); TweenService:Create(seg, ti, {CFrame = CFrame.new(fx) * CFrame.Angles(0, seg:GetAttribute("StartAngle"), 0), Transparency = 1, Size = Vector3.new(seg.Size.X * 1.3, height, thickness * 0.5)}):Play() end
        return created
    end
    local function createJumpCircle(position, color)
        for _, m in ipairs(JC.models) do if m and m.Parent then m:Destroy() end end
        JC.models, JC.circles, JC.lights = {}, {}, {}
        local model = Instance.new("Model"); model.Name = "WCJumpRing"; model.Parent = Workspace; table.insert(JC.models, model)
        local material = State.JumpCircleGlow and Enum.Material.Neon or Enum.Material.SmoothPlastic; local created = {}
        if State.JumpCircleStyle == "segments" then created = makeSegmentsCircle(position, color, model, material) elseif State.JumpCircleStyle == "circle" then created = makeRingCircle(position, color, model, material) elseif State.JumpCircleStyle == "square" then created = makeSquareCircle(position, color, model, material) end
        for _, s in ipairs(created) do table.insert(JC.circles, s) end
        task.delay(0.7, function() if model and model.Parent then model:Destroy() end end)
    end
    local jumpConn = nil
    function Features.resetJumpCircle() if jumpConn then pcall(function() jumpConn:Disconnect() end); jumpConn = nil end end
    function Features.setupJumpCircle()
        Features.resetJumpCircle(); local char = player.Character; if not char then return end; local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local wasOn = true
        jumpConn = RunService.Heartbeat:Connect(function()
            if ScriptUnloaded or not State.JumpCircleEnabled then wasOn = true; return end
            if not hum.Parent then return end; local st = hum:GetState(); local on = (st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.RunningNoPhysics or st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.Seated)
            if wasOn and not on then local root = char:FindFirstChild("HumanoidRootPart"); if root then local p = RaycastParams.new(); p.FilterType = Enum.RaycastFilterType.Exclude; p.FilterDescendantsInstances = {char}; local r = Workspace:Raycast(root.Position, Vector3.new(0, -50, 0), p); if r then createJumpCircle(r.Position, getVisualColor(State.JumpCircleUseTheme, State.JumpCircleCustomColor)) end end end
            wasOn = on
        end)
    end

    local AnimPack = {enabled = false, stopConn = nil}
    local function stopAllTracks() local char = player.Character; if not char then return end; local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local animator = hum:FindFirstChildOfClass("Animator"); if not animator then return end; for _, track in ipairs(animator:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end end
    function Features.applyAnimationPack(enable) AnimPack.enabled = enable; if enable then if not AnimPack.stopConn then AnimPack.stopConn = RunService.Heartbeat:Connect(function() if not AnimPack.enabled then return end; stopAllTracks() end) end; stopAllTracks() else if AnimPack.stopConn then AnimPack.stopConn:Disconnect(); AnimPack.stopConn = nil end end end

    -- ================= KORBLOX (игла как у оригинала) =================
    -- Правая нога прячется, вместо неё — тонкая чёрная игла, которая
    -- сужается к земле; кончик синий, с процедурной текстурой энергии.
    local Korblox = {model = nil, hidden = {}, conns = {}}
    local KORBLOX_LEGS = {"RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg"}

    local function korbloxClear(restore)
        for _, c in ipairs(Korblox.conns) do pcall(function() c:Disconnect() end) end
        Korblox.conns = {}
        if Korblox.model then pcall(function() Korblox.model:Destroy() end); Korblox.model = nil end
        if restore then
            for part, tr in pairs(Korblox.hidden) do
                if part.Parent then pcall(function() part.Transparency = tr end) end
            end
        end
        Korblox.hidden = {}
    end

    local function korbloxBuild(char)
        local model = Instance.new("Model")
        model.Name = "WC_Korblox"
        local BLACK, NAVY = Color3.fromRGB(14, 14, 20), Color3.fromRGB(10, 22, 60)
        local BLUE, NEON = Color3.fromRGB(30, 85, 230), Color3.fromRGB(70, 150, 255)
        local tipTex = Tex.get("korblox")
        local function piece(body, size, c0, color, mat, isCyl, texTr)
            local p = Instance.new("Part")
            p.Name = "KorbloxPart"
            if isCyl then p.Shape = Enum.PartType.Cylinder end
            p.Size = size
            p.Color = color
            p.Material = mat or Enum.Material.SmoothPlastic
            p.Reflectance = (mat == Enum.Material.Neon) and 0 or 0.12
            p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Massless = true; p.CastShadow = false
            p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
            p.CFrame = body.CFrame * c0
            if texTr and tipTex then
                for _, f in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Front, Enum.NormalId.Back}) do
                    local t = Instance.new("Texture")
                    t.Texture = tipTex
                    t.Face = f
                    t.StudsPerTileU = 0.45
                    t.StudsPerTileV = 0.45
                    t.Transparency = texTr
                    t.Parent = p
                end
            end
            local w = Instance.new("Weld")
            w.Part0 = body; w.Part1 = p; w.C0 = c0
            w.Parent = p
            p.Parent = model
            return p
        end
        local VERT = CFrame.Angles(0, 0, math.pi / 2)
        -- сужающийся стержень из цилиндров: yTop -> yBot, диаметр d0 -> d1
        local function taper(body, yTop, yBot, d0, d1, steps, colA, colB, texA, texB, mat)
            local h = (yTop - yBot) / steps
            for i = 0, steps - 1 do
                local k = (steps == 1) and 0 or i / (steps - 1)
                local d = d0 + (d1 - d0) * k
                local y = yTop - h * (i + 0.5)
                local tr = texA and (texA + ((texB or texA) - texA) * k) or nil
                piece(body, Vector3.new(h * 1.12, d, d), CFrame.new(0, y, 0) * VERT, colA:Lerp(colB, k), mat, true, tr)
            end
        end
        local function ring(body, y, d, color)
            piece(body, Vector3.new(0.04, d, d), CFrame.new(0, y, 0) * VERT, color, Enum.Material.Neon, true)
        end
        local function point(body, y, len)
            local p = piece(body, Vector3.new(0.07, len, 0.07), CFrame.new(0, y - len / 2, 0), NEON, Enum.Material.Neon)
            local m = Instance.new("SpecialMesh"); m.MeshType = Enum.MeshType.Sphere; m.Parent = p
            local l = Instance.new("PointLight"); l.Color = NEON; l.Range = 5; l.Brightness = 1.3; l.Shadows = false; l.Parent = p
            local e = Instance.new("ParticleEmitter")
            e.Texture = Tex.get("sparkle") or "rbxasset://textures/particles/sparkles_main.dds"
            e.Color = ColorSequence.new(NEON)
            e.LightEmission = 1; e.Rate = 5
            e.Lifetime = NumberRange.new(0.4, 0.8); e.Speed = NumberRange.new(0.3, 1)
            e.SpreadAngle = Vector2.new(180, 180)
            e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0)})
            e.Parent = p
        end

        local ul, ll, foot = char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg"), char:FindFirstChild("RightFoot")
        local r6 = char:FindFirstChild("Right Leg")
        if ul and ll then
            local uh, lh = ul.Size.Y / 2, ll.Size.Y / 2
            local fh = foot and foot.Size.Y or 0.35
            taper(ul, uh, -uh, 0.62, 0.36, 5, BLACK, BLACK)
            piece(ul, Vector3.new(0.42, 0.42, 0.42), CFrame.new(0, -uh, 0), NAVY, Enum.Material.SmoothPlastic, false)
            local mid = lh - (2 * lh) * 0.5
            taper(ll, lh, mid, 0.34, 0.26, 3, BLACK, NAVY)
            ring(ll, mid, 0.29, NEON)
            taper(ll, mid, -lh, 0.26, 0.17, 4, NAVY, BLUE, 0.6, 0)
            taper(ll, -lh, -lh - fh, 0.17, 0.05, 5, BLUE, BLUE, 0, 0)
            point(ll, -lh - fh + 0.02, 0.22)
        elseif r6 then
            local hh = r6.Size.Y / 2
            taper(r6, hh, -0.15, 0.62, 0.36, 6, BLACK, BLACK)
            piece(r6, Vector3.new(0.4, 0.4, 0.4), CFrame.new(0, -0.15, 0), NAVY, Enum.Material.SmoothPlastic, false)
            taper(r6, -0.15, -0.55, 0.34, 0.25, 3, BLACK, NAVY)
            ring(r6, -0.55, 0.28, NEON)
            taper(r6, -0.55, -0.82, 0.25, 0.16, 3, NAVY, BLUE, 0.55, 0)
            taper(r6, -0.82, -hh - 0.02, 0.16, 0.05, 5, BLUE, BLUE, 0, 0)
            point(r6, -hh, 0.16)
        else
            model:Destroy()
            return nil
        end
        model.Parent = char
        return model
    end

    function Features.applyKorblox(enable)
        korbloxClear(true)
        if not enable or ScriptUnloaded then return end
        local char = player.Character
        if not char then return end
        local function hide(p)
            if not p:IsA("BasePart") or Korblox.hidden[p] ~= nil then return end
            Korblox.hidden[p] = p.Transparency
            p.Transparency = 1
            table.insert(Korblox.conns, p:GetPropertyChangedSignal("Transparency"):Connect(function()
                if State.KorbloxEnabled and p.Transparency ~= 1 then p.Transparency = 1 end
            end))
        end
        for _, n in ipairs(KORBLOX_LEGS) do
            local p = char:FindFirstChild(n)
            if p then hide(p) end
        end
        Korblox.model = korbloxBuild(char)
        -- игра может пересобрать ногу (HumanoidDescription) — пересобираем иглу
        table.insert(Korblox.conns, char.ChildAdded:Connect(function(c)
            if table.find(KORBLOX_LEGS, c.Name) and State.KorbloxEnabled then
                task.delay(0.1, function()
                    if State.KorbloxEnabled and player.Character == char then Features.applyKorblox(true) end
                end)
            end
        end))
    end

    -- ================= HEADLESS =================
    local Headless = {saved = {}, conns = {}}
    local function headlessClear(restore)
        for _, c in ipairs(Headless.conns) do pcall(function() c:Disconnect() end) end
        Headless.conns = {}
        if restore then
            for obj, tr in pairs(Headless.saved) do
                if obj.Parent then pcall(function() obj.Transparency = tr end) end
            end
        end
        Headless.saved = {}
    end
    function Features.applyHeadless(enable)
        headlessClear(true)
        if not enable or ScriptUnloaded then return end
        local char = player.Character
        if not char then return end
        local function hideObj(o)
            if Headless.saved[o] ~= nil then return end
            Headless.saved[o] = o.Transparency
            o.Transparency = 1
            table.insert(Headless.conns, o:GetPropertyChangedSignal("Transparency"):Connect(function()
                if State.HeadlessEnabled and o.Transparency ~= 1 then o.Transparency = 1 end
            end))
        end
        local function apply()
            local head = char:FindFirstChild("Head")
            if not head then return end
            hideObj(head)
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") or d:IsA("Texture") then hideObj(d) end
            end
            table.insert(Headless.conns, head.ChildAdded:Connect(function(d)
                if (d:IsA("Decal") or d:IsA("Texture")) and State.HeadlessEnabled then hideObj(d) end
            end))
        end
        apply()
        table.insert(Headless.conns, char.ChildAdded:Connect(function(c)
            if c.Name == "Head" and State.HeadlessEnabled then task.wait(0.1); apply() end
        end))
    end

    -- KorBlox/Headless на чужом персонаже (другие юзеры скрипта; видно только тебе)
    function Features.applyBodyTo(char, st, korblox, headless)
        if st.model then pcall(function() st.model:Destroy() end); st.model = nil end
        for o, tr in pairs(st.hidden or {}) do
            if o.Parent then pcall(function() o.Transparency = tr end) end
        end
        st.hidden = {}
        if not char or ScriptUnloaded then return end
        local function hide(o) st.hidden[o] = o.Transparency; o.Transparency = 1 end
        if korblox then
            for _, n in ipairs(KORBLOX_LEGS) do
                local p = char:FindFirstChild(n)
                if p and p:IsA("BasePart") then hide(p) end
            end
            st.model = korbloxBuild(char)
        end
        if headless then
            local head = char:FindFirstChild("Head")
            if head then
                hide(head)
                for _, d in ipairs(head:GetChildren()) do
                    if d:IsA("Decal") then hide(d) end
                end
            end
        end
    end

    -- ================= MOVEMENT: STRAFE (быстрый и резкий) =================
    -- Скорость в воздухе берётся из настроек, направление — из WASD/стика.
    -- Резкость: насколько быстро скорость поворачивает к нужному направлению
    -- (экспоненциальное сглаживание по dt, 60 = практически мгновенно).
    local Strafe = {conn = nil}
    function Features.startStrafe()
        if Strafe.conn then return end
        Strafe.conn = RunService.Heartbeat:Connect(function(dt)
            if ScriptUnloaded or State.FlyEnabled then return end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end
            local st = hum:GetState()
            local air = st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping
            local md = hum.MoveDirection
            local moving = md.Magnitude > 0.05
            if not air then
                if State.StrafeBhop and moving and hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
                if not State.StrafeGround then return end
            end
            if not moving then return end
            local vel = hrp.AssemblyLinearVelocity
            local horiz = Vector3.new(vel.X, 0, vel.Z)
            local target = md.Unit * State.StrafeSpeed
            local alpha = 1 - math.exp(-State.StrafeSharp * dt)
            local nv = horiz:Lerp(target, alpha)
            hrp.AssemblyLinearVelocity = Vector3.new(nv.X, vel.Y, nv.Z)
        end)
    end
    function Features.stopStrafe()
        if Strafe.conn then Strafe.conn:Disconnect(); Strafe.conn = nil end
    end

            -- ================= MOVEMENT: FLY (Xneo Method) =================
    local Fly = {active = false, conn = nil, speed = 50, bv = nil, bg = nil, tpwalking = false, speeds = 1}
    _genv.WC_Fly = Fly

    function Features.startFly()
        if Fly.active then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not torso then return end
        Fly.active = true

        -- Отключаем все состояния (обход античитов)
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
            pcall(function() hum:SetStateEnabled(state, false) end)
        end
        hum:ChangeState(Enum.HumanoidStateType.Swimming) -- Или Physics
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = true end

        -- Создаем физику
        Fly.bg = Instance.new("BodyGyro", torso)
        Fly.bg.P = 9e4
        Fly.bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        Fly.bg.CFrame = torso.CFrame

        Fly.bv = Instance.new("BodyVelocity", torso)
        Fly.bv.Velocity = Vector3.new(0, 0.1, 0)
        Fly.bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        hum.PlatformStand = true

        -- Запускаем фоновый "tpwalking" для ускорения (как в оригинале)
        Fly.tpwalking = true
        task.spawn(function()
            local hb = RunService.Heartbeat
            while Fly.tpwalking and Fly.active and char.Parent and hum.Parent do
                hb:Wait()
                if hum.MoveDirection.Magnitude > 0 and Fly.active then
                    char:TranslateBy(hum.MoveDirection * (Fly.speed / 50))
                end
            end
        end)

        -- Основной цикл полета
        local ctrl = {f = 0, b = 0, l = 0, r = 0}
        local lastctrl = {f = 0, b = 0, l = 0, r = 0}
        local curSpeed = 0
        local maxspeed = Fly.speed

        Fly.conn = RunService.RenderStepped:Connect(function()
            if not Fly.active or ScriptUnloaded or not char.Parent or not Fly.bv or not Fly.bg then return end
            
            maxspeed = Fly.speed

            -- Считываем управление (W, S, A, D)
            local uis = UserInputService
            ctrl.f = (uis:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            ctrl.b = (uis:IsKeyDown(Enum.KeyCode.S) and -1 or 0)
            ctrl.l = (uis:IsKeyDown(Enum.KeyCode.A) and -1 or 0)
            ctrl.r = (uis:IsKeyDown(Enum.KeyCode.D) and 1 or 0)

            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                curSpeed = curSpeed + 0.5 + (curSpeed / maxspeed)
                if curSpeed > maxspeed then curSpeed = maxspeed end
            elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and curSpeed ~= 0 then
                curSpeed = curSpeed - 1
                if curSpeed < 0 then curSpeed = 0 end
            end

            local camCF = camera.CFrame
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                Fly.bv.Velocity = ((camCF.LookVector * (ctrl.f + ctrl.b)) + ((camCF * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - camCF.p)) * curSpeed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and curSpeed ~= 0 then
                Fly.bv.Velocity = ((camCF.LookVector * (lastctrl.f + lastctrl.b)) + ((camCF * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - camCF.p)) * curSpeed
            else
                Fly.bv.Velocity = Vector3.new(0, 0, 0)
            end

            Fly.bg.CFrame = camCF * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * curSpeed / maxspeed), 0, 0)
        end)
    end

    function Features.stopFly()
        Fly.active = false
        Fly.tpwalking = false
        
        if Fly.conn then Fly.conn:Disconnect(); Fly.conn = nil end
        if Fly.bv then Fly.bv:Destroy(); Fly.bv = nil end
        if Fly.bg then Fly.bg:Destroy(); Fly.bg = nil end
        
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false
            for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() hum:SetStateEnabled(state, true) end)
            end
        end
        if char and char:FindFirstChild("Animate") then
            char.Animate.Disabled = false
        end
    end

        -- ================= TROLL: THROWING OUT (FLING LOOP) =================
    local Troll = {active = false, conn = nil, targetIndex = 0, flingForce = 9e8, originalPos = nil}

    function Features.startThrowingOut()
        if Troll.active then return end
        Troll.active = true
        Troll.targetIndex = 0
        
        local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        Troll.originalPos = myHrp and myHrp.CFrame

        Troll.token = (Troll.token or 0) + 1
        local token = Troll.token
        task.spawn(function()
          while Troll.active and Troll.token == token and not ScriptUnloaded do
            task.wait()
            local function step()
            
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Собираем всех игроков кроме себя
            local targets = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp then table.insert(targets, tHrp) end
                end
            end
            
            if #targets == 0 then task.wait(0.5) return end
            
            -- Выбираем следующую цель по кругу
            Troll.targetIndex = Troll.targetIndex % #targets + 1
            local targetHrp = targets[Troll.targetIndex]
            
            if targetHrp and targetHrp.Parent then
                -- 1. Запоминаем свою позицию
                local safePos = Troll.originalPos or hrp.CFrame
                
                -- 2. Телепортируемся к цели
                hrp.CFrame = targetHrp.CFrame

                -- 3. Ждем кадр, чтобы физика зафиксировала коллизию
                task.wait(0.05)

                -- 4. Флинкаем цель
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(Troll.flingForce, Troll.flingForce, Troll.flingForce)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = targetHrp

                local bav = Instance.new("BodyAngularVelocity")
                bav.AngularVelocity = Vector3.new(Troll.flingForce, Troll.flingForce, Troll.flingForce)
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.Parent = targetHrp

                -- 5. Ждем еще чуть-чуть, чтобы импульс передался
                task.wait(0.1)

                -- 6. Убираем эффекты с цели
                if bv and bv.Parent then bv:Destroy() end
                if bav and bav.Parent then bav:Destroy() end

                -- 7. Возвращаемся на исходную позицию (чтобы самим не улететь)
                if hrp.Parent then hrp.CFrame = safePos end
            end
            end
            step()
          end
        end)
    end

    function Features.stopThrowingOut()
        Troll.active = false
        Troll.token = (Troll.token or 0) + 1
        if Troll.conn then Troll.conn:Disconnect(); Troll.conn = nil end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in ipairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then v:Destroy() end
            end
        end
    end
end
-- =====================================================================
-- ============================  UI  ===================================
-- =====================================================================
local GuiService = game:GetService("GuiService")

for _, n in ipairs({"WannacryUI", "WannacryHUD", "WannacryESP", "WannacryFX", "WannacryOverlay"}) do
    local old = parentGui:FindFirstChild(n)
    if old then old:Destroy() end
end
do
    local ob = Lighting:FindFirstChild("WCGlassBlur"); if ob then ob:Destroy() end
    local of = SoundService:FindFirstChild("WannacrySFX"); if of then of:Destroy() end
end

local Glass = {
    Bg         = Color3.fromRGB(9, 10, 14),
    White      = Color3.fromRGB(255, 255, 255),
    Black      = Color3.fromRGB(0, 0, 0),
    Text       = Color3.fromRGB(246, 247, 251),
    TextDim    = Color3.fromRGB(170, 175, 190),
    TextMute   = Color3.fromRGB(118, 124, 142),
    Accent     = Color3.fromRGB(10, 132, 255),
    AccentSoft = Color3.fromRGB(100, 180, 255),
    Green      = Color3.fromRGB(48, 209, 88),
}
Colors.Accent = Glass.Accent
Colors.Text = Glass.Text
Colors.TextDim = Glass.TextDim

local function makeFont(weight)
    local ok, f = pcall(function() return Font.new("rbxasset://fonts/families/GothamSSm.json", weight) end)
    if ok and f then return f end
    return Font.fromEnum(Enum.Font.GothamBold)
end
local F = {
    Regular = makeFont(Enum.FontWeight.Regular),
    Medium  = makeFont(Enum.FontWeight.Medium),
    Semi    = makeFont(Enum.FontWeight.SemiBold),
    Bold    = makeFont(Enum.FontWeight.Bold),
    Heavy   = makeFont(Enum.FontWeight.Heavy),
}

local MB1, TOUCH, MOVE = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement
local function isPress(i) return i.UserInputType == MB1 or i.UserInputType == TOUCH end
local function isMove(i) return i.UserInputType == MOVE or i.UserInputType == TOUCH end

local function pointerPos(input)
    if input and input.UserInputType == TOUCH then
        local inset = GuiService:GetGuiInset()
        return Vector2.new(input.Position.X, input.Position.Y) + inset
    end
    return UserInputService:GetMouseLocation()
end

local UI = {dragLock = false, swiping = false}
local function guarded(fn)
    return function(...)
        if UI.swiping then return end
        return fn(...)
    end
end

local function new(class, props)
    local o = Instance.new(class)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else o[k] = v end
    end
    if parent then o.Parent = parent end
    return o
end

local function tw(o, t, props, style, dir)
    local tt = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tt:Play()
    return tt
end

local function corner(obj, r)
    return new("UICorner", {CornerRadius = (r == "full") and UDim.new(1, 0) or UDim.new(0, r or 12), Parent = obj})
end
local function KP(t, v) return NumberSequenceKeypoint.new(t, v) end

local RIM_SEQ = NumberSequence.new({KP(0, 0.05), KP(0.3, 0.75), KP(0.7, 0.85), KP(1, 0.35)})
local function rim(obj, thickness, transparency)
    local s = new("UIStroke", {
        Color = Glass.White, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = obj,
    })
    new("UIGradient", {Rotation = 125, Transparency = RIM_SEQ, Parent = s})
    return s
end

local function sheen(obj, r, amount)
    local f = new("Frame", {
        Name = "Sheen", Size = UDim2.new(1, 0, 0.6, 0), BackgroundColor3 = Glass.White,
        BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 0, Parent = obj,
    })
    corner(f, r)
    new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({KP(0, 1 - (amount or 0.1)), KP(1, 1)}), Parent = f})
    return f
end

local function liquid(obj, o)
    o = o or {}
    local r = o.radius or 16
    obj.BackgroundColor3 = o.tint or Glass.White
    obj.BackgroundTransparency = o.transparency or 0.9
    obj.BorderSizePixel = 0
    corner(obj, r)
    new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Glass.White, Color3.fromRGB(150, 160, 185)), Parent = obj})
    local stroke = rim(obj, o.stroke or 1.2, o.rimT or 0)

    if o.fringe ~= false then
        local function fr(color, off, rot)
            local f = new("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(off, off), Size = UDim2.fromScale(1, 1), ZIndex = 0, Parent = obj})
            corner(f, r)
            local s = new("UIStroke", {Color = color, Thickness = 1, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f})
            new("UIGradient", {Rotation = rot, Transparency = NumberSequence.new({KP(0, 0.15), KP(0.4, 1), KP(1, 1)}), Parent = s})
        end
        fr(Color3.fromRGB(255, 120, 210), -1, 45)
        fr(Color3.fromRGB(110, 220, 255), 1, 225)
    end
    if o.lens ~= false then
        local lens = new("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), ZIndex = 0, Parent = obj})
        corner(lens, (r == "full") and "full" or math.max(r - 2, 0))
        local ls = new("UIStroke", {Color = Color3.fromRGB(0, 0, 25), Thickness = 2, Transparency = 0.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = lens})
        new("UIGradient", {Rotation = 270, Transparency = NumberSequence.new({KP(0, 0), KP(0.45, 1), KP(1, 1)}), Parent = ls})
    end
    if o.glint ~= false then
        local g = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.42, 0, 0, 2), Size = UDim2.new(0.5, 0, 0, 2),
            BackgroundColor3 = Glass.White, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 0, Parent = obj,
        })
        corner(g, "full")
        new("UIGradient", {Transparency = NumberSequence.new({KP(0, 1), KP(0.5, 0.1), KP(1, 1)}), Parent = g})
    end
    if o.sheen ~= false then sheen(obj, r, o.sheenAmount or 0.12) end
    return stroke
end

local function soft(obj, o)
    o = o or {}
    obj.BackgroundColor3 = o.tint or Glass.White
    obj.BackgroundTransparency = o.transparency or 0.95
    obj.BorderSizePixel = 0
    corner(obj, o.radius or 16)
    if o.sheen ~= false then sheen(obj, o.radius or 16, o.sheenAmount or 0.04) end
end

local orderCounter = 0
local function nextOrder() orderCounter += 1; return orderCounter end

local SFX = {sounds = {}, folder = new("Folder", {Name = "WannacrySFX", Parent = SoundService})}
do
    local RATE = 44100
    local function u16(n) return string.char(n % 256, math.floor(n / 256) % 256) end
    local function u32(n) return string.char(n % 256, math.floor(n / 256) % 256, math.floor(n / 65536) % 256, math.floor(n / 16777216) % 256) end

    local function synth(len, voices, air)
        local N = math.floor(len * RATE)
        local buf = table.create(N, 0)
        local TWO_PI = math.pi * 2
        for _, v in ipairs(voices) do
            local s0, n = math.floor(v[1] * RATE), math.floor(v[3] * RATE)
            local w1, w2, w3 = TWO_PI * v[2] / RATE, TWO_PI * v[2] * 2.76 / RATE, TWO_PI * v[2] * 5.4 / RATE
            local decay = 5 / v[3]
            for i = 0, n - 1 do
                local idx = s0 + i + 1
                if idx > N then break end
                local t = i / RATE
                local env = math.min(t / 0.004, 1) * math.exp(-t * decay)
                local x = math.sin(w1 * i) + 0.22 * math.sin(w2 * i) * math.exp(-t * 18) + 0.07 * math.sin(w3 * i) * math.exp(-t * 40)
                buf[idx] += x * env * v[4]
            end
        end
        if air then
            local s0, n = math.floor(air[1] * RATE), math.floor(air[2] * RATE)
            local lp, rng = 0, Random.new(7)
            for i = 0, n - 1 do
                local idx = s0 + i + 1
                if idx > N then break end
                local e = math.sin(math.pi * i / n)
                lp += (rng:NextNumber(-1, 1) - lp) * 0.07
                buf[idx] += lp * e * e * air[3]
            end
        end
        local parts = table.create(N)
        local fade = math.floor(0.01 * RATE)
        for i = 1, N do
            local x = buf[i]
            x = x / (1 + math.abs(x)) * 1.6
            if i > N - fade then x *= (N - i) / fade end
            local v = math.floor(math.clamp(x, -1, 1) * 32767)
            if v < 0 then v += 65536 end
            parts[i] = string.char(v % 256, math.floor(v / 256))
        end
        local data = table.concat(parts)
        return "RIFF" .. u32(36 + #data) .. "WAVEfmt " .. u32(16) .. u16(1) .. u16(1) .. u32(RATE) .. u32(RATE * 2) .. u16(2) .. u16(16) .. "data" .. u32(#data) .. data
    end

    local DEFS = {
        on    = {len = 0.4,  voices = {{0, 1318.5, 0.22, 0.30}, {0.05, 1975.5, 0.30, 0.24}}},
        off   = {len = 0.4,  voices = {{0, 1568.0, 0.22, 0.28}, {0.05, 1046.5, 0.30, 0.24}}},
        open  = {len = 1.15, voices = {{0, 659.25, 0.9, 0.18}, {0.06, 987.77, 0.85, 0.16}, {0.12, 1318.5, 0.8, 0.14}, {0.18, 1975.5, 0.7, 0.10}}, air = {0, 0.45, 0.10}},
        close = {len = 0.65, voices = {{0, 1318.5, 0.45, 0.16}, {0.05, 987.77, 0.45, 0.15}, {0.10, 659.25, 0.5, 0.15}}, air = {0, 0.25, 0.07}},
    }
    local FALLBACK = {on = 1.3, off = 1.0, open = 0.9, close = 0.75}
    local canFile = type(writefile) == "function" and type(isfile) == "function" and type(getcustomasset) == "function"

    for name in pairs(DEFS) do
        SFX.sounds[name] = new("Sound", {
            Name = name, Volume = 0.55, SoundId = "rbxasset://sounds/electronicpingshort.wav",
            PlaybackSpeed = FALLBACK[name], Parent = SFX.folder,
        })
    end
    task.spawn(function()
        if not canFile then return end
        pcall(function() if type(isfolder) == "function" and not isfolder("WannacryAssets") then makefolder("WannacryAssets") end end)
        for name, d in pairs(DEFS) do
            local ok = pcall(function()
                local path = "WannacryAssets/sfx_v1_" .. name .. ".wav"
                if not isfile(path) then writefile(path, synth(d.len, d.voices, d.air)) end
                local id = getcustomasset(path)
                if id and id ~= "" then
                    SFX.sounds[name].SoundId = id
                    SFX.sounds[name].PlaybackSpeed = 1
                end
            end)
            if not ok then break end
            task.wait()
        end
    end)
end
function SFX.play(name)
    if not State.UISoundsEnabled or ScriptUnloaded then return end
    local s = SFX.sounds[name]
    if s and s.Parent then s.TimePosition = 0; s:Play() end
end

local CoreSaved = nil
function Features.applyCoreHud(hide)
    if hide then
        if not CoreSaved then
            CoreSaved = {}
            for _, t in ipairs(Enum.CoreGuiType:GetEnumItems()) do
                if t ~= Enum.CoreGuiType.All then
                    local ok, v = pcall(function() return StarterGui:GetCoreGuiEnabled(t) end)
                    CoreSaved[t] = (not ok) or v
                end
            end
        end
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
    elseif CoreSaved then
        for t, v in pairs(CoreSaved) do pcall(function() StarterGui:SetCoreGuiEnabled(t, v) end) end
        CoreSaved = nil
    end
end
do
    local acc = 0
    connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 1 or ScriptUnloaded then return end
        acc = 0
        if State.HudEnabled then Features.applyCoreHud(true) end
    end)
end

local HUD_Gui = new("ScreenGui", {
    Name = "WannacryHUD", ResetOnSpawn = false, IgnoreGuiInset = false, DisplayOrder = 998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parentGui,
})
local HUD_Root = new("Frame", {
    Name = "Watermark", Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(0, 0),
    AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Visible = false, Parent = HUD_Gui,
})
new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = HUD_Root})

local HUD = {}
do
    local function pill(order)
        local p = new("Frame", {Size = UDim2.fromOffset(60, 32), LayoutOrder = order, Parent = HUD_Root})
        liquid(p, {radius = "full", transparency = 0.86})
        local inner = new("Frame", {Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 2, Parent = p})
        inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            p.Size = UDim2.fromOffset(inner.AbsoluteSize.X, 32)
        end)
        new("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = inner})
        new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = inner})
        return inner
    end
    local function item(parent, text, color, order, fnt)
        return new("TextLabel", {
            Text = text, Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X,
            TextColor3 = color or Glass.Text, TextSize = 13, FontFace = fnt or F.Semi,
            TextStrokeColor3 = Glass.Black, TextStrokeTransparency = 0.7,
            BackgroundTransparency = 1, LayoutOrder = order, ZIndex = 3, Parent = parent,
        })
    end
    local function sep(parent, order)
        return new("Frame", {Size = UDim2.fromOffset(1, 14), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.6, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 3, Parent = parent})
    end
    local row1, row2 = pill(1), pill(2)
    item(row1, "wannacry", Glass.Text, 1, F.Heavy)
    sep(row1, 2)
    item(row1, player.Name, Glass.Text, 3)
    sep(row1, 4)
    HUD.fps  = item(row1, "0 fps", Glass.Text, 5)
    HUD.ping = item(row1, "0ms", Glass.Text, 6)
    HUD.time = item(row1, "00:00:00", Glass.Text, 7)
    HUD.pos  = item(row2, "x0 y0 z0", Glass.Text, 1)
    sep(row2, 2)
    HUD.spd  = item(row2, "0.0 bps", Glass.Text, 3)

    local acc, frames = 0, 0
    connect(RunService.RenderStepped, function(dt)
        if ScriptUnloaded or not State.HudEnabled then return end
        acc += dt; frames += 1
        if acc < 0.25 then return end
        HUD.fps.Text = math.floor(frames / acc + 0.5) .. " fps"
        acc, frames = 0, 0
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        HUD.ping.Text = (ok and math.floor(ping) or 0) .. "ms"
        HUD.time.Text = os.date("%H:%M:%S")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p, v = hrp.Position, hrp.AssemblyLinearVelocity
            HUD.pos.Text = string.format("x%d y%d z%d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
            HUD.spd.Text = string.format("%.1f bps", Vector3.new(v.X, 0, v.Z).Magnitude)
        end
    end)
end

local ScreenGui = new("ScreenGui", {
    Name = "WannacryUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parentGui,
})
local GlassBlur = new("BlurEffect", {Name = "WCGlassBlur", Size = 0, Parent = Lighting})

local WIN_W, WIN_H = 800, 560
local Holder = new("Frame", {
    Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 1, Visible = false, Parent = ScreenGui,
})
local HolderScale = new("UIScale", {Scale = 1, Parent = Holder})

local MainFrame = new("Frame", {
    Name = "MainFrame", Size = UDim2.fromScale(1, 1), ClipsDescendants = true,
    BackgroundColor3 = Glass.Bg, BackgroundTransparency = 0.04, BorderSizePixel = 0, Parent = Holder,
})
corner(MainFrame, 28)
rim(MainFrame, 1, 0.55)
new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 165)), Parent = MainFrame})

local BgImage = new("ImageLabel", {
    Name = "Background", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "",
    ScaleType = Enum.ScaleType.Crop, Visible = false, ZIndex = 1, Parent = MainFrame,
})
corner(BgImage, 28)
local BgDim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Glass.Bg, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 2, Parent = BgImage})
corner(BgDim, 28)

local function windowScale() return math.max(MainFrame.AbsoluteSize.X / WIN_W, 0.01) end
local function toWindow(p) return (p - MainFrame.AbsolutePosition) / windowScale() end

local Sidebar = new("Frame", {Name = "Sidebar", Position = UDim2.fromOffset(12, 12), Size = UDim2.new(0, 206, 1, -24), ZIndex = 3, Parent = MainFrame})
liquid(Sidebar, {radius = 22, transparency = 0.955, rimT = 0.45, fringe = false, glint = false, sheenAmount = 0.05})

local LogoImage = new("ImageLabel", {
    Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(14, 14), BackgroundColor3 = Glass.White,
    BackgroundTransparency = 0.9, Image = logoAsset, ScaleType = Enum.ScaleType.Crop, ZIndex = 2, Parent = Sidebar,
})
corner(LogoImage, 13)
local LogoFallback = new("TextLabel", {
    Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(14, 14), Text = "W", FontFace = F.Heavy, TextSize = 24,
    TextColor3 = Glass.White, ZIndex = 2, Parent = Sidebar,
})
liquid(LogoFallback, {radius = 13, transparency = 0.85, sheen = false, glint = false})
if logoAsset ~= "" then LogoFallback.Visible = false else LogoImage.Visible = false end

new("TextLabel", {
    Size = UDim2.new(1, -76, 0, 42), Position = UDim2.fromOffset(66, 14), BackgroundTransparency = 1,
    Text = "wannacry", TextColor3 = Glass.Text, TextSize = 19, FontFace = F.Bold,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = Sidebar,
})
local SidebarDrag = new("Frame", {Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, ZIndex = 4, Parent = Sidebar})

local TABS = {
    {id = "Visuals",   title = "Visuals",   sub = "Мир, небо, свет и эффекты"},
    {id = "ESP",       title = "ESP",       sub = "Подсветка игроков и NPC"},
    {id = "Movement",  title = "Movement",  sub = "Strafe, Fly и другие движения"},
    {id = "Cosmetics", title = "Cosmetics", sub = "Внешний вид персонажа"},
    {id = "Community", title = "Community", sub = "Global Chat, юзеры скрипта и админ-чат"},
    {id = "Troll",     title = "Troll",     sub = "Шалости и выбросы"},
    {id = "Background", title = "Background", sub = "Фон меню: картинка и прозрачность"},
    {id = "Settings",  title = "Settings",  sub = "Клавиша меню, кнопка-логотип и конфиги"},
    {id = "Info",      title = "Info",      sub = "Экзекьютор, версия и апдейт-лист"},
}
local TAB_ORDER = {"Visuals", "ESP", "Movement", "Cosmetics", "Community", "Troll", "Background", "Settings", "Info"}
local TAB_Y0, TAB_STEP, TAB_H = 78, 42, 38

local TabHighlight = new("Frame", {Size = UDim2.new(1, -16, 0, TAB_H), Position = UDim2.fromOffset(8, TAB_Y0), Visible = false, ZIndex = 2, Parent = Sidebar})
liquid(TabHighlight, {radius = 14, transparency = 0.88})
local TabHighlightScale = new("UIScale", {Parent = TabHighlight})

local TabButtons = {}
for i, t in ipairs(TABS) do
    local b = new("TextButton", {
        Name = t.id .. "TabButton", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, TAB_H), Position = UDim2.fromOffset(8, TAB_Y0 + (i - 1) * TAB_STEP), ZIndex = 3, Parent = Sidebar,
    })
    local label = new("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
        Text = t.title, FontFace = F.Semi, TextSize = 15, TextColor3 = Glass.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = b,
    })
    TabButtons[t.id] = {button = b, label = label, index = i, def = t}
end

local ProfileFrame = new("Frame", {Position = UDim2.new(0, 8, 1, -72), Size = UDim2.new(1, -16, 0, 64), ZIndex = 2, Parent = Sidebar})
soft(ProfileFrame, {radius = 18, transparency = 0.94})

local AvatarButton = new("TextButton", {
    Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 10, 0.5, -22), Text = "", AutoButtonColor = false, ZIndex = 3, Parent = ProfileFrame,
})
liquid(AvatarButton, {radius = "full", transparency = 0.85, sheen = false, glint = false, lens = false})
local AvatarImage = new("ImageLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = defaultAvatarAsset or "",
    ScaleType = Enum.ScaleType.Crop, ZIndex = 4, Parent = AvatarButton,
})
corner(AvatarImage, "full")
new("TextLabel", {
    Size = UDim2.new(1, -66, 0, 18), Position = UDim2.fromOffset(62, 13), BackgroundTransparency = 1,
    Text = player.DisplayName, TextColor3 = Glass.Text, TextSize = 14, FontFace = F.Semi,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = ProfileFrame,
})
new("TextLabel", {
    Size = UDim2.new(1, -66, 0, 16), Position = UDim2.fromOffset(62, 32), BackgroundTransparency = 1,
    Text = "365 days left", TextColor3 = Glass.Green, TextSize = 12, FontFace = F.Medium,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = ProfileFrame,
})

local AvatarPopup = new("Frame", {
    Position = UDim2.new(0, 8, 1, -80), AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(1, -16, 0, 0),
    ClipsDescendants = true, Visible = false, ZIndex = 6, Parent = Sidebar,
})
liquid(AvatarPopup, {radius = 18, transparency = 0.82, tint = Color3.fromRGB(30, 32, 40), sheen = false, glint = false, fringe = false, lens = false})
local AvatarRow = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 7, Parent = AvatarPopup})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
    HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = AvatarRow,
})
for _, imgAsset in ipairs(LoadedAvatars) do
    if imgAsset ~= "" then
        local mini = new("ImageButton", {
            Size = UDim2.fromOffset(34, 34), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.85,
            Image = imgAsset, ScaleType = Enum.ScaleType.Crop, AutoButtonColor = false, ZIndex = 8, Parent = AvatarRow,
        })
        corner(mini, "full"); rim(mini, 1, 0.2)
        local sc = new("UIScale", {Parent = mini})
        mini.MouseEnter:Connect(function() tw(sc, 0.25, {Scale = 1.12}, Enum.EasingStyle.Back) end)
        mini.MouseLeave:Connect(function() tw(sc, 0.25, {Scale = 1}) end)
        mini.MouseButton1Click:Connect(function() AvatarImage.Image = imgAsset end)
    end
end
local isPopupOpen = false
AvatarButton.MouseButton1Click:Connect(function()
    isPopupOpen = not isPopupOpen
    if isPopupOpen then
        AvatarPopup.Visible = true
        tw(AvatarPopup, 0.4, {Size = UDim2.new(1, -16, 0, 54)}, Enum.EasingStyle.Back)
    else
        tw(AvatarPopup, 0.2, {Size = UDim2.new(1, -16, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.2, function() if not isPopupOpen then AvatarPopup.Visible = false end end)
    end
end)

local ContentFrame = new("Frame", {Name = "Content", Position = UDim2.fromOffset(232, 12), Size = UDim2.new(1, -244, 1, -24), BackgroundTransparency = 1, ZIndex = 3, Parent = MainFrame})

local HeaderTitle = new("TextLabel", {
    Size = UDim2.new(1, -200, 0, 30), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1,
    Text = "wannacry", TextColor3 = Glass.Text, TextSize = 24, FontFace = F.Bold,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = ContentFrame,
})
local HeaderSub = new("TextLabel", {
    Size = UDim2.new(1, -200, 0, 18), Position = UDim2.fromOffset(4, 34), BackgroundTransparency = 1,
    Text = "Выбери вкладку слева или свайпни", TextColor3 = Glass.TextMute, TextSize = 13, FontFace = F.Medium,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = ContentFrame,
})
local HeaderDrag = new("Frame", {Size = UDim2.new(1, -150, 0, 56), BackgroundTransparency = 1, ZIndex = 3, Parent = ContentFrame})

local function glassButton(parent, text, props, o)
    local b = new("TextButton", {Text = "", AutoButtonColor = false, ZIndex = props.ZIndex or 4, Parent = parent})
    for k, v in pairs(props) do b[k] = v end
    liquid(b, o or {radius = "full", transparency = 0.9})
    local l = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = text, FontFace = (o and o.font) or F.Semi,
        TextSize = (o and o.textSize) or 13, TextColor3 = (o and o.textColor) or Glass.Text,
        TextStrokeColor3 = Glass.Black, TextStrokeTransparency = 0.85, ZIndex = 5, Parent = b,
    })
    local base = b.BackgroundTransparency
    b.MouseEnter:Connect(function() tw(b, 0.2, {BackgroundTransparency = math.max(base - 0.06, 0)}) end)
    b.MouseLeave:Connect(function() tw(b, 0.25, {BackgroundTransparency = base}) end)
    return b, l
end

local CloseButton = glassButton(ContentFrame, "×", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 10), Size = UDim2.fromOffset(34, 34)},
    {radius = "full", transparency = 0.9, textSize = 20})
local UnloadButton = glassButton(ContentFrame, "Выгрузить", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -44, 0, 10), Size = UDim2.fromOffset(104, 34)},
    {radius = "full", transparency = 0.9, textColor = Color3.fromRGB(255, 140, 130)})

local Pages = new("Frame", {Name = "Pages", Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 1, -64), BackgroundTransparency = 1, ClipsDescendants = true, Parent = ContentFrame})

local PlaceholderText = new("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Text = "Здесь пока что ничего нет,\nоткрой вкладку!", TextColor3 = Glass.TextMute, TextSize = 18, FontFace = F.Medium, Parent = Pages,
})

local function makeScrollPage(parent)
    local s = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Glass.White, ScrollBarImageTransparency = 0.6,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = parent,
    })
    new("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 8), Parent = s})
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = s})
    return s
end

local VisualsTab   = new("Frame", {Name = "VisualsTab",   Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local ESPTab       = new("Frame", {Name = "ESPTab",       Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local MovementTab  = new("Frame", {Name = "MovementTab",  Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local CosmeticsTab = new("Frame", {Name = "CosmeticsTab", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local CommunityTab = new("Frame", {Name = "CommunityTab", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local TrollTab     = new("Frame", {Name = "TrollTab",     Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local BackgroundTab = new("Frame", {Name = "BackgroundTab", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local SettingsTab = new("Frame", {Name = "SettingsTab", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})
local InfoTab = new("Frame", {Name = "InfoTab", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = Pages})

local PageFrames = {Visuals = VisualsTab, ESP = ESPTab, Movement = MovementTab, Cosmetics = CosmeticsTab, Community = CommunityTab, Troll = TrollTab, Background = BackgroundTab, Settings = SettingsTab, Info = InfoTab}
local VisualsScroll = makeScrollPage(VisualsTab)

local KNOB = 24
local function makeSwitch(parent, init, onChange, pos, anchor)
    local track = new("TextButton", {
        Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(50, 30),
        Position = pos or UDim2.new(1, -14, 0.5, 0), AnchorPoint = anchor or Vector2.new(1, 0.5), ZIndex = 4, Parent = parent,
    })
    liquid(track, {radius = "full", transparency = 0.88, glint = false, sheenAmount = 0.1})
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(KNOB, KNOB), Position = UDim2.new(0, 3 + KNOB / 2, 0.5, 0),
        BackgroundColor3 = Glass.White, BorderSizePixel = 0, ZIndex = 6, Parent = track,
    })
    corner(knob, "full")
    new("UIStroke", {Color = Glass.Black, Transparency = 0.82, Thickness = 1, Parent = knob})
    new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Glass.White, Color3.fromRGB(220, 224, 236)), Parent = knob})

    local self = {state = init and true or false, onChange = onChange}
    local onPos, offPos = UDim2.new(1, -(3 + KNOB / 2), 0.5, 0), UDim2.new(0, 3 + KNOB / 2, 0.5, 0)
    local function render(instant)
        local on = self.state
        local bg, bt = on and Glass.Green or Glass.White, on and 0.15 or 0.88
        if instant then
            knob.Position = on and onPos or offPos; track.BackgroundColor3 = bg; track.BackgroundTransparency = bt
            return
        end
        tw(track, 0.25, {BackgroundColor3 = bg, BackgroundTransparency = bt})
        tw(knob, 0.42, {Position = on and onPos or offPos}, Enum.EasingStyle.Back)
        tw(knob, 0.14, {Size = UDim2.fromOffset(KNOB + 10, KNOB - 2)}).Completed:Connect(function()
            tw(knob, 0.28, {Size = UDim2.fromOffset(KNOB, KNOB)}, Enum.EasingStyle.Back)
        end)
    end
    function self.set(v, silent)
        v = v and true or false
        if v == self.state then return end
        self.state = v
        render(false)
        if not silent then
            SFX.play(v and "on" or "off")
            if self.onChange then
                local ok, err = pcall(self.onChange, v)
                if not ok then warn("[wannacry] toggle error: " .. tostring(err)) end
            end
        end
    end
    function self.toggle() self.set(not self.state) end
    track.MouseButton1Click:Connect(guarded(self.toggle))
    render(true)
    self.button = track
    return self
end

local function rowLabel(parent, text, h)
    return new("TextLabel", {
        Text = text, FontFace = F.Medium, TextSize = 13, TextColor3 = Glass.TextDim, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, h or 16), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
    })
end

local function makeSlider(parent, label, minV, maxV, initV, cb, decimals)
    decimals = decimals or (((maxV - minV) >= 10) and 0 or 2)
    local fmt = "%." .. decimals .. "f"
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = parent})
    rowLabel(f, label)
    local valPill = new("TextLabel", {
        Text = string.format(fmt, initV), FontFace = F.Semi, TextSize = 12, TextColor3 = Glass.Text,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, -3), Size = UDim2.fromOffset(56, 22), ZIndex = 2, Parent = f,
    })
    liquid(valPill, {radius = "full", transparency = 0.9, sheen = false, glint = false, lens = false})
    local track = new("Frame", {Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.86, BorderSizePixel = 0, Parent = f})
    corner(track, "full")
    local ratio = math.clamp((initV - minV) / (maxV - minV), 0, 1)
    local fill = new("Frame", {Size = UDim2.new(ratio, 0, 1, 0), BackgroundColor3 = Glass.White, BorderSizePixel = 0, Parent = track})
    corner(fill, "full")
    new("UIGradient", {Color = ColorSequence.new(Glass.AccentSoft, Glass.Accent), Parent = fill})
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(ratio, 0, 0.5, 0), Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = Glass.White, BorderSizePixel = 0, ZIndex = 3, Parent = track,
    })
    corner(knob, "full")
    new("UIStroke", {Color = Glass.Black, Transparency = 0.8, Thickness = 1, Parent = knob})
    local hit = new("TextButton", {Text = "", BackgroundTransparency = 1, Position = UDim2.fromOffset(-8, 18), Size = UDim2.new(1, 16, 0, 28), ZIndex = 5, Parent = f})

    local dragging = false
    local function upd(x)
        local r = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local v = minV + (maxV - minV) * r
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        valPill.Text = string.format(fmt, v)
        cb(v)
    end
    hit.InputBegan:Connect(function(i)
        if isPress(i) then
            dragging = true; UI.dragLock = true
            tw(knob, 0.18, {Size = UDim2.fromOffset(34, 24)})
            upd(pointerPos(i).X)
        end
    end)
    connect(UserInputService.InputChanged, function(i)
        if dragging and isMove(i) then upd(pointerPos(i).X) end
    end)
    connect(UserInputService.InputEnded, function(i)
        if dragging and isPress(i) then
            dragging = false; UI.dragLock = false
            tw(knob, 0.35, {Size = UDim2.fromOffset(22, 22)}, Enum.EasingStyle.Back)
        end
    end)
    return f
end

local function makeToggle(parent, label, init, cb)
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = parent})
    rowLabel(f, label, 32)
    return makeSwitch(f, init, cb, UDim2.new(1, 0, 0.5, 0))
end

local function makeSegmented(parent, label, opts, init, cb)
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = parent})
    rowLabel(f, label)
    local bar = new("Frame", {Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 36), Parent = f})
    liquid(bar, {radius = "full", transparency = 0.93, glint = false, sheen = false})
    local n = #opts
    local idx = table.find(opts, init) or 1
    local pill = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1 / n, -6, 1, -6), Position = UDim2.new((idx - 0.5) / n, 0, 0.5, 0), ZIndex = 2, Parent = bar,
    })
    liquid(pill, {radius = "full", transparency = 0.8, sheenAmount = 0.14})
    local btns = {}
    for i, o in ipairs(opts) do
        local b = new("TextButton", {
            Text = o, FontFace = F.Semi, TextSize = 12, TextColor3 = (i == idx) and Glass.Text or Glass.TextDim,
            BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1 / n, 0, 1, 0),
            Position = UDim2.new((i - 1) / n, 0, 0, 0), ZIndex = 3, Parent = bar,
        })
        btns[i] = b
        b.MouseButton1Click:Connect(guarded(function()
            if i == idx then return end
            idx = i
            tw(pill, 0.45, {Position = UDim2.new((i - 0.5) / n, 0, 0.5, 0)}, Enum.EasingStyle.Back)
            tw(pill, 0.15, {Size = UDim2.new(1 / n, 10, 1, -3)}).Completed:Connect(function()
                tw(pill, 0.3, {Size = UDim2.new(1 / n, -6, 1, -6)}, Enum.EasingStyle.Back)
            end)
            for j, bb in ipairs(btns) do tw(bb, 0.2, {TextColor3 = (j == i) and Glass.Text or Glass.TextDim}) end
            cb(o, i)
        end))
    end
    return f
end

local function makeCycler(parent, label, opts, init, cb)
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = parent})
    rowLabel(f, label)
    local idx = table.find(opts, init) or 1
    local counter = new("TextLabel", {
        Text = idx .. "/" .. #opts, FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.TextMute,
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(60, 16), TextXAlignment = Enum.TextXAlignment.Right, Parent = f,
    })
    local bar = new("Frame", {Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true, Parent = f})
    liquid(bar, {radius = "full", transparency = 0.93, glint = false, sheen = false})
    local valueL = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1, Text = opts[idx], FontFace = F.Semi, TextSize = 14, TextColor3 = Glass.Text, ZIndex = 2, Parent = bar,
    })
    local function arrow(txt, left)
        return glassButton(bar, txt, {
            AnchorPoint = Vector2.new(left and 0 or 1, 0.5), Position = UDim2.new(left and 0 or 1, left and 3 or -3, 0.5, 0),
            Size = UDim2.fromOffset(44, 30), ZIndex = 3,
        }, {radius = "full", transparency = 0.86, textSize = 20, font = F.Bold, glint = false})
    end
    local prev, nxt = arrow("‹", true), arrow("›", false)
    local self = {}
    local function show(dir)
        valueL.Text = opts[idx]
        counter.Text = idx .. "/" .. #opts
        valueL.Position = UDim2.new(0.5, dir * 26, 0.5, 0)
        valueL.TextTransparency = 1
        tw(valueL, 0.35, {Position = UDim2.fromScale(0.5, 0.5), TextTransparency = 0})
    end
    function self.set(i, silent)
        if i == idx then return end
        local dir = (i > idx) and 1 or -1
        idx = i; show(dir)
        if not silent then cb(opts[idx], idx) end
    end
    prev.MouseButton1Click:Connect(guarded(function() idx = (idx - 2) % #opts + 1; show(-1); cb(opts[idx], idx) end))
    nxt.MouseButton1Click:Connect(guarded(function() idx = idx % #opts + 1; show(1); cb(opts[idx], idx) end))
    return self
end

local function makeInput(parent, label, placeholder, init, cb)
    local f = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = parent})
    rowLabel(f, label)
    local box = new("TextBox", {
        Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 34),
        Text = init or "", PlaceholderText = placeholder or "", PlaceholderColor3 = Glass.TextMute,
        TextColor3 = Glass.Text, FontFace = F.Medium, TextSize = 13,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2, Parent = f,
    })
    box.BackgroundColor3 = Glass.White
    box.BackgroundTransparency = 0.93
    box.BorderSizePixel = 0
    corner(box, "full")
    local st = new("UIStroke", {Color = Glass.White, Thickness = 1.2, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = box})
    
    new("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = box})
    box.Focused:Connect(function() tw(st, 0.2, {Thickness = 2}) end)
    box.FocusLost:Connect(function()
        tw(st, 0.2, {Thickness = 1.2})
        cb(box.Text)
    end)
    return box
end

local function makeSection(parent, text)
    return new("TextLabel", {
        Text = text, FontFace = F.Bold, TextSize = 12, TextColor3 = Glass.TextMute, BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 28), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom,
        LayoutOrder = nextOrder(), Parent = parent,
    })
end

local CARD_H = 60
local function createCard(parent, o)
    local wrapper = new("Frame", {Size = UDim2.new(1, -4, 0, CARD_H), BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = nextOrder(), Parent = parent})
    local card = new("TextButton", {Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, CARD_H), Parent = wrapper})
    soft(card, {radius = 18, transparency = 0.95})

    local dot = new("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 16, 0.5, -4), BackgroundColor3 = Glass.TextMute, BorderSizePixel = 0, ZIndex = 2, Parent = card})
    corner(dot, "full")
    new("TextLabel", {
        Text = o.title, FontFace = F.Semi, TextSize = 15, TextColor3 = Glass.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(34, o.desc and 11 or 0),
        Size = UDim2.new(1, -160, o.desc and 0 or 1, o.desc and 20 or 0), ZIndex = 2, Parent = card,
    })
    if o.desc then
        new("TextLabel", {
            Text = o.desc, FontFace = F.Regular, TextSize = 12, TextColor3 = Glass.TextDim, BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(34, 31), Size = UDim2.new(1, -160, 0, 16),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = card,
        })
    end

    local init = o.init
    if init == nil and o.key then init = State[o.key] end
    local function paintActive(on)
        tw(dot, 0.3, {BackgroundColor3 = on and Glass.Green or Glass.TextMute})
    end
    local sw = makeSwitch(card, init, function(v)
        if o.key then State[o.key] = v end
        paintActive(v)
        if o.onToggle then o.onToggle(v) end
    end)
    paintActive(init)

    local chevron, panel, layout
    local expanded = false
    local function relayout()
        local h = expanded and (layout.AbsoluteContentSize.Y + 24) or 0
        tw(panel, 0.4, {Size = UDim2.new(1, 0, 0, h)})
        tw(wrapper, 0.4, {Size = UDim2.new(1, -4, 0, CARD_H + (expanded and (h + 6) or 0))})
    end
    local function toggleSettings()
        if not o.settings then return end
        expanded = not expanded
        relayout()
        tw(chevron, 0.4, {Rotation = expanded and 90 or 0}, Enum.EasingStyle.Back)
    end
    if o.settings then
        chevron = glassButton(card, "›", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -74, 0.5, 0), Size = UDim2.fromOffset(32, 32), ZIndex = 4,
        }, {radius = "full", transparency = 0.9, textSize = 20, font = F.Bold, glint = false})
        panel = new("Frame", {Position = UDim2.fromOffset(0, CARD_H + 6), Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, Parent = wrapper})
        soft(panel, {radius = 16, transparency = 0.965, sheen = false})
        local inner = new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 2, Parent = panel})
        new("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = inner})
        layout = new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = inner})
        o.settings(inner)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() if expanded then relayout() end end)
        chevron.MouseButton1Click:Connect(guarded(toggleSettings))
    end
    
    card.MouseButton2Click:Connect(toggleSettings)
    card.MouseButton1Click:Connect(guarded(function()
        sw.toggle()
    end))
    
    card.MouseEnter:Connect(function() tw(card, 0.2, {BackgroundTransparency = 0.925}) end)
    card.MouseLeave:Connect(function() tw(card, 0.25, {BackgroundTransparency = 0.95}) end)
    if o.key then table.insert(WC_CFG.cards, {key = o.key, sw = sw, onToggle = o.onToggle}) end
    return {switch = sw, wrapper = wrapper}
end

local ToastHolder = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 16), Size = UDim2.fromOffset(340, 300),
    BackgroundTransparency = 1, ZIndex = 50, Parent = ScreenGui,
})
new("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = ToastHolder})
local function notify(title, text)
    local holder = new("Frame", {Size = UDim2.fromOffset(310, 0), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 50, Parent = ToastHolder})
    local t = new("Frame", {Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 50, Parent = holder})
    liquid(t, {radius = 22, transparency = 0.88, sheenAmount = 0.16, stroke = 1.4})
    local sc = new("UIScale", {Scale = 0.85, Parent = t})
    local sweep = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(-0.4, 0.5), Size = UDim2.new(0.35, 0, 2.5, 0), Rotation = 18,
        BackgroundColor3 = Glass.White, BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 51, Parent = t,
    })
    new("UIGradient", {Transparency = NumberSequence.new({KP(0, 1), KP(0.5, 0.2), KP(1, 1)}), Parent = sweep})
    local function lbl(txt, y, size, fnt, col)
        return new("TextLabel", {
            Text = txt, FontFace = fnt, TextSize = size, TextColor3 = col, BackgroundTransparency = 1,
            TextStrokeColor3 = Glass.Black, TextStrokeTransparency = 0.65,
            Position = UDim2.fromOffset(18, y), Size = UDim2.new(1, -36, 0, size + 4), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 52, Parent = t,
        })
    end
    lbl(title, 10, 15, F.Bold, Glass.Text)
    lbl(text, 31, 12, F.Medium, Color3.fromRGB(225, 228, 238))
    tw(holder, 0.45, {Size = UDim2.fromOffset(310, 56)}, Enum.EasingStyle.Back)
    tw(sc, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
    task.delay(0.15, function() tw(sweep, 1.1, {Position = UDim2.fromScale(1.4, 0.5)}, Enum.EasingStyle.Sine) end)
    task.delay(3, function()
        if not holder.Parent then return end
        tw(sc, 0.25, {Scale = 0.85}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tw(holder, 0.25, {Size = UDim2.fromOffset(310, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.3, function() if holder.Parent then holder:Destroy() end end)
    end)
end
-- ================= ВКЛАДКА VISUALS =================
makeSection(VisualsScroll, "НЕБО И ПОГОДА")

createCard(VisualsScroll, {title = "Sky", desc = #SKIES .. " скайбоксов + свой ID", key = "SkyEnabled",
    onToggle = function() Features.applySky() end,
    settings = function(p)
        local cyc
        cyc = makeCycler(p, "Скайбокс", SKY_NAMES, SKY_NAMES[State.SkyIndex], function(_, i)
            State.SkyIndex = i
            Features.applySky()
        end)
        makeToggle(p, "Солнце и луна (у космоса скрыты всегда)", State.SkyCelestial, function(v) State.SkyCelestial = v; Features.applySky() end)
        makeInput(p, "Свой ID — одна картинка на все 6 сторон", "например 1234567890", State.SkyCustomId, function(text)
            State.SkyCustomId = text
            if text:match("%d+") then
                State.SkyIndex = #SKIES + 1
                cyc.set(#SKY_NAMES, true)
                Features.applySky()
                if not State.SkyEnabled then notify("Sky", "ID сохранён — включи карточку Sky") end
            end
        end)
    end})

createCard(VisualsScroll, {title = "Fog", desc = "Объёмный туман", key = "FogEnabled",
    onToggle = function() Features.applyFog() end,
    settings = function(p)
        makeSlider(p, "Плотность", 0, 1, State.FogSettings.Density, function(v) State.FogSettings.Density = v; Features.applyFog() end)
        makeSlider(p, "Смещение", -1, 1, State.FogSettings.Offset, function(v) State.FogSettings.Offset = v; Features.applyFog() end)
    end})

createCard(VisualsScroll, {title = "Atmosphere", desc = "Снег и листопад", key = "AtmosphereEnabled",
    onToggle = function() Features.applyAtmosphere() end,
    settings = function(p)
        makeSegmented(p, "Погода", {"Зима", "Осень", "Нет"}, State.AtmosphereType, function(opt)
            State.AtmosphereType = opt
            if State.AtmosphereEnabled then Features.applyAtmosphere() end
        end)
        makeSlider(p, "Разброс", 0, 100, State.AtmosphereSpread, function(v)
            State.AtmosphereSpread = v
            Features.updateAtmosphereSpread()
        end)
    end})

createCard(VisualsScroll, {title = "Custom Time", desc = "Время суток", key = "CustomTimeEnabled",
    onToggle = function() Features.applyCustomTime() end,
    settings = function(p)
        local times = {["Утро"] = 6, ["День"] = 14, ["Закат"] = 18, ["Ночь"] = 22, ["Полночь"] = 0}
        makeSegmented(p, "Время", {"Утро", "День", "Закат", "Ночь", "Полночь"}, "День", function(opt)
            State.CustomTimeValue = times[opt] or 14
            Features.applyCustomTime()
        end)
    end})

makeSection(VisualsScroll, "СВЕТ И ЦВЕТ")

createCard(VisualsScroll, {title = "Fullbright", desc = "Всё светло, без теней", key = "FullbrightEnabled",
    onToggle = function() Features.applyFullbright() end,
    settings = function(p)
        makeSlider(p, "Яркость", 1, 10, State.FullbrightBrightness, function(v)
            State.FullbrightBrightness = v
            if State.FullbrightEnabled then Features.applyFullbright() end
        end, 1)
    end})

createCard(VisualsScroll, {title = "World", desc = "Цветокоррекция мира", key = "WorldEnabled",
    onToggle = function() Features.applyWorld() end,
    settings = function(p)
        makeSlider(p, "Насыщенность", -1, 1, State.WorldSettings.Saturation, function(v) State.WorldSettings.Saturation = v; Features.applyWorld() end)
        makeSlider(p, "Контраст", -1, 1, State.WorldSettings.Contrast, function(v) State.WorldSettings.Contrast = v; Features.applyWorld() end)
        makeSlider(p, "Яркость", -0.5, 0.5, State.WorldSettings.Brightness, function(v) State.WorldSettings.Brightness = v; Features.applyWorld() end)
    end})

makeSection(VisualsScroll, "КАМЕРА")

createCard(VisualsScroll, {title = "Aspect", desc = "Растянутое разрешение", key = "AspectEnabled",
    settings = function(p)
        makeSlider(p, "Сила", 0.5, 1.5, State.AspectValue, function(v) State.AspectValue = v end)
        makeSlider(p, "Поправка ESP (1 — по умолчанию)", -1, 3, State.AspectComp, function(v) State.AspectComp = v; WC_PROJ.calibUntil = os.clock() + 2.5 end, 2)
    end})

createCard(VisualsScroll, {title = "Motion Blur", desc = "Размытие движения: даль, рывки, края", key = "MotionBlurEnabled",
    settings = function(p)
        makeSlider(p, "Сила", 0, 100, State.MotionBlurStrength, function(v) State.MotionBlurStrength = v end)
    end})

makeSection(VisualsScroll, "ПЕРСОНАЖ")

createCard(VisualsScroll, {title = "DBD Animation Pack", desc = "Анимации в стиле Dead by Daylight", key = "DBDAnimationEnabled",
    onToggle = function(s) Features.applyDBDAnimations(s) end})

createCard(VisualsScroll, {title = "No Anim", desc = "Отключает все анимации", key = "AnimationPackEnabled",
    onToggle = function(s) Features.applyAnimationPack(s) end})

createCard(VisualsScroll, {title = "Trails", desc = "Шлейф за персонажем", key = "TrailsEnabled",
    onToggle = function() Features.applyTrails() end})

createCard(VisualsScroll, {title = "Particles", desc = "Светящиеся частицы вокруг", key = "ParticlesEnabled",
    onToggle = function() Features.applyParticles() end})

createCard(VisualsScroll, {title = "Jump Circle", desc = "Волна при прыжке", key = "JumpCircleEnabled",
    onToggle = function(s) if s then Features.setupJumpCircle() else Features.resetJumpCircle() end end,
    settings = function(p)
        local styleMap = {["Палочки"] = "segments", ["Круг"] = "circle", ["Квадрат"] = "square"}
        makeSegmented(p, "Стиль", {"Палочки", "Круг", "Квадрат"}, "Палочки", function(opt) State.JumpCircleStyle = styleMap[opt] or "segments" end)
        makeToggle(p, "Свечение", State.JumpCircleGlow, function(v) State.JumpCircleGlow = v end)
    end})

makeSection(VisualsScroll, "ИНТЕРФЕЙС")

createCard(VisualsScroll, {title = "HUD", desc = "Watermark + скрывает HUD Roblox", key = "HudEnabled",
    onToggle = function(s)
        HUD_Root.Visible = s
        Features.applyCoreHud(s)
    end})

createCard(VisualsScroll, {title = "Звуки", desc = "Мягкие звуки интерфейса", key = "UISoundsEnabled"})

-- ================= ВКЛАДКА ESP =================
local ESPList = makeScrollPage(new("Frame", {Size = UDim2.new(0, 300, 1, 0), BackgroundTransparency = 1, Parent = ESPTab}))

local ESPGui = new("ScreenGui", {
    Name = "WannacryESP", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 997,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parentGui,
})
pcall(function() ESPGui.ScreenInsets = Enum.ScreenInsets.None end)
local activeESPs = {}
local currentHue, currentSat, currentVal = currentESPColor:ToHSV()
local previewStroke, PreviewNameLabel
local ESPColorDot

local function applyESPColor()
    currentESPColor = Color3.fromHSV(currentHue, currentSat, currentVal)
    for _, d in pairs(activeESPs) do
        d.stroke.Color = currentESPColor
        d.nameLabel.TextColor3 = currentESPColor
    end
    if previewStroke then previewStroke.Color = currentESPColor end
    if PreviewNameLabel then PreviewNameLabel.TextColor3 = currentESPColor end
    if ESPColorDot then ESPColorDot.BackgroundColor3 = currentESPColor end
end

local RefreshAllESPs = function() end

createCard(ESPList, {title = "ESP", desc = "Боксы, имена, дистанция", key = "EspEnabled",
    onToggle = function(s) espEnabled = s; RefreshAllESPs() end})
    
createCard(ESPList, {title = "Health Bar", desc = "Полоска здоровья", key = "EspHpEnabled",
    onToggle = function(s) espHPEnabled = s end})

do -- карточка цвета
    local cc = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = ESPList})
    soft(cc, {radius = 18, transparency = 0.95, sheen = false})
    new("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = cc})
    new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = cc})

    local head = new("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 2, Parent = cc})
    new("TextLabel", {Text = "Цвет ESP", FontFace = F.Semi, TextSize = 15, TextColor3 = Glass.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = head})
    ESPColorDot = new("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24), ZIndex = 2, Parent = head})
    liquid(ESPColorDot, {radius = "full", tint = currentESPColor, transparency = 0.1, sheen = false, lens = false, glint = false})

    local pick = new("Frame", {Size = UDim2.new(1, 0, 0, 110), BackgroundColor3 = Glass.White, BorderSizePixel = 0, LayoutOrder = nextOrder(), ZIndex = 2, Parent = cc})
    corner(pick, 12)
    local hueKeys = {}
    for i = 0, 6 do hueKeys[#hueKeys + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)) end
    new("UIGradient", {Color = ColorSequence.new(hueKeys), Parent = pick})
    local whiteOv = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Glass.White, BorderSizePixel = 0, ZIndex = 3, Parent = pick})
    corner(whiteOv, 12)
    new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(0, 1), Parent = whiteOv})
    local darkOv = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Glass.Black, BackgroundTransparency = currentVal, BorderSizePixel = 0, ZIndex = 4, Parent = pick})
    corner(darkOv, 12)
    local cursor = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(18, 18), Position = UDim2.fromScale(currentHue, currentSat), ZIndex = 6, Parent = pick})
    liquid(cursor, {radius = "full", transparency = 0.75, sheen = false, glint = false, stroke = 2.5})
    local pickHit = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 7, Parent = pick})

    local dragging = false
    local function fromPos(p)
        local ap, as = pick.AbsolutePosition, pick.AbsoluteSize
        currentHue = math.clamp((p.X - ap.X) / as.X, 0, 0.999)
        currentSat = math.clamp((p.Y - ap.Y) / as.Y, 0, 1)
        cursor.Position = UDim2.fromScale(currentHue, currentSat)
        applyESPColor()
    end
    pickHit.InputBegan:Connect(function(i)
        if isPress(i) then
            dragging = true; UI.dragLock = true
            tw(cursor, 0.2, {Size = UDim2.fromOffset(26, 26)})
            fromPos(pointerPos(i))
        end
    end)
    connect(UserInputService.InputChanged, function(i) if dragging and isMove(i) then fromPos(pointerPos(i)) end end)
    connect(UserInputService.InputEnded, function(i)
        if dragging and isPress(i) then
            dragging = false; UI.dragLock = false
            tw(cursor, 0.3, {Size = UDim2.fromOffset(18, 18)}, Enum.EasingStyle.Back)
        end
    end)

    makeSlider(cc, "Яркость цвета", 0.2, 1, currentVal, function(v)
        currentVal = v
        darkOv.BackgroundTransparency = v
        applyESPColor()
    end)

    local sw = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 2, Parent = cc})
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), VerticalAlignment = Enum.VerticalAlignment.Center, Parent = sw})
    for _, col in ipairs({
        Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 69, 58), Color3.fromRGB(255, 159, 10),
        Color3.fromRGB(255, 214, 10), Color3.fromRGB(48, 209, 88), Color3.fromRGB(100, 210, 255),
        Color3.fromRGB(10, 132, 255), Color3.fromRGB(191, 90, 242),
    }) do
        local b = new("TextButton", {Text = "", Size = UDim2.fromOffset(26, 26), AutoButtonColor = false, ZIndex = 3, Parent = sw})
        liquid(b, {radius = "full", tint = col, transparency = 0.15, lens = false, glint = false, sheenAmount = 0.3})
        local sc = new("UIScale", {Parent = b})
        b.MouseEnter:Connect(function() tw(sc, 0.25, {Scale = 1.15}, Enum.EasingStyle.Back) end)
        b.MouseLeave:Connect(function() tw(sc, 0.2, {Scale = 1}) end)
        b.MouseButton1Click:Connect(guarded(function()
            currentHue, currentSat, currentVal = col:ToHSV()
            cursor.Position = UDim2.fromScale(currentHue, currentSat)
            darkOv.BackgroundTransparency = currentVal
            applyESPColor()
        end))
    end
end

local ESPPreviewFrame = new("Frame", {Name = "Preview", Position = UDim2.fromOffset(310, 2), Size = UDim2.new(1, -312, 1, -4), ClipsDescendants = true, Parent = ESPTab})
soft(ESPPreviewFrame, {radius = 20, transparency = 0.96, sheen = false})

local ESPViewport = new("ViewportFrame", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Ambient = Color3.fromRGB(170, 175, 190),
    LightColor = Glass.White, LightDirection = Vector3.new(-0.4, -1, -0.6), ZIndex = 2, Parent = ESPPreviewFrame,
})
local ESPViewportCam = new("Camera", {FieldOfView = 40, Parent = ESPViewport})
ESPViewport.CurrentCamera = ESPViewportCam
local ESPWorldModel = new("WorldModel", {Parent = ESPViewport})

local PreviewESPOverlay = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = ESPPreviewFrame})
local PreviewESPBox = new("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 3, Parent = PreviewESPOverlay})
previewStroke = new("UIStroke", {Color = currentESPColor, Thickness = 2, Parent = PreviewESPBox})
new("UIStroke", {Color = Glass.Black, Thickness = 4, Transparency = 0.5, Parent = PreviewESPBox})
PreviewNameLabel = new("TextLabel", {
    BackgroundTransparency = 1, Text = player.DisplayName, TextColor3 = currentESPColor, TextStrokeTransparency = 0,
    TextStrokeColor3 = Glass.Black, FontFace = F.Bold, TextSize = 14, Visible = false, AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(200, 20), ZIndex = 3, Parent = PreviewESPOverlay,
})
local PreviewHPBarBg = new("Frame", {BackgroundColor3 = Glass.Black, BackgroundTransparency = 0.5, BorderSizePixel = 0, Visible = false, ZIndex = 3, Parent = PreviewESPOverlay})
new("Frame", {BackgroundColor3 = Color3.fromRGB(0, 255, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = PreviewHPBarBg})

local hint = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), Size = UDim2.fromOffset(190, 26),
    Text = "Потяни, чтобы повернуть", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.Text, ZIndex = 4, Parent = ESPPreviewFrame,
})
liquid(hint, {radius = "full", transparency = 0.9, sheen = false, glint = false, lens = false})

local ESPPreviewClone = nil
local previewAngle = 180

local function CreateCharacterPreview()
    local char = player.Character
    if not char then return end
    for _, v in ipairs(ESPWorldModel:GetChildren()) do v:Destroy() end
    local oldArchivable = char.Archivable
    char.Archivable = true
    local clone = char:Clone()
    char.Archivable = oldArchivable
    if not clone then return end
    for _, v in ipairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") or v:IsA("Sound") then v:Destroy()
        elseif v:IsA("BasePart") then v.Anchored = true end
    end
    local hrp = clone:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Transparency = 1 end
    clone.Parent = ESPWorldModel
    clone:PivotTo(CFrame.Angles(0, math.rad(previewAngle), 0))
    local focusPos = Vector3.new(0, 1.5, 0)
    ESPViewportCam.CFrame = CFrame.lookAt(focusPos + Vector3.new(0, 0.5, 18), focusPos)
    ESPPreviewClone = clone
end

local function UpdatePreviewESP()
    if not espEnabled or not ESPTab.Visible or not isOpen then
        PreviewESPBox.Visible = false; PreviewNameLabel.Visible = false; PreviewHPBarBg.Visible = false
        return
    end
    local w, h = ESPPreviewFrame.AbsoluteSize.X, ESPPreviewFrame.AbsoluteSize.Y
    local s = windowScale()
    w, h = w / s, h / s
    local boxW, boxH = math.min(w * 0.6, h * 0.42), h * 0.62
    local x, y = (w - boxW) / 2, (h - boxH) / 2 + h * 0.02
    PreviewESPBox.Position = UDim2.fromOffset(x, y)
    PreviewESPBox.Size = UDim2.fromOffset(boxW, boxH)
    PreviewESPBox.Visible = true
    PreviewNameLabel.Position = UDim2.fromOffset(x + boxW / 2, y - 14)
    PreviewNameLabel.Visible = true
    PreviewHPBarBg.Visible = espHPEnabled
    if espHPEnabled then
        PreviewHPBarBg.Position = UDim2.fromOffset(x - 7, y)
        PreviewHPBarBg.Size = UDim2.fromOffset(3, boxH)
    end
end
connect(RunService.RenderStepped, function() if not ScriptUnloaded then UpdatePreviewESP() end end)

do
    local rotating, lastX = false, 0
    ESPViewport.InputBegan:Connect(function(i)
        if isPress(i) then rotating = true; UI.dragLock = true; lastX = pointerPos(i).X end
    end)
    connect(UserInputService.InputEnded, function(i)
        if rotating and isPress(i) then rotating = false; UI.dragLock = false end
    end)
    connect(UserInputService.InputChanged, function(i)
        if rotating and isMove(i) then
            local x = pointerPos(i).X
            previewAngle = previewAngle + (x - lastX) * 0.5
            lastX = x
            if ESPPreviewClone and ESPPreviewClone.Parent then
                ESPPreviewClone:PivotTo(CFrame.Angles(0, math.rad(previewAngle), 0))
            end
        end
    end)
end

-- ================= РЕНДЕР ESP (РУЧНАЯ ПРОЕКЦИЯ) =================
local function CheckIfPlayer(obj)
    local char = player.Character
    return char ~= nil and (obj == char or obj:IsDescendantOf(char))
end

-- Проекция через движок Roblox: верна при любом разрешении, аспект-ратио, FOV и
-- инсете топбара. Из координат вьюпорта вычитаем реальное смещение ESP-GUI на экране.
local function WorldToScreen(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then return nil, false end
    local sp = WC_PROJ.toScreen(worldPos)
    if not sp then return nil, false end
    local origin = ESPGui.AbsolutePosition
    return Vector2.new(sp.X - origin.X, sp.Y - origin.Y), true
end

local function hideESP(d)
    d.box.Visible = false; d.nameLabel.Visible = false; d.hpBarBg.Visible = false
end

local function CreateESPForModel(model)
    if not model or activeESPs[model] or CheckIfPlayer(model) then return end
    if not model:FindFirstChildOfClass("Humanoid") and not model:FindFirstChild("HumanoidRootPart") then return end
    local d = {}
    d.box = new("Frame", {Name = "ESPBox", BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 1, Parent = ESPGui})
    d.stroke = new("UIStroke", {Color = currentESPColor, Thickness = 2, Parent = d.box})
    new("UIStroke", {Color = Glass.Black, Thickness = 4, Transparency = 0.5, Parent = d.box})
    d.nameLabel = new("TextLabel", {
        Name = "ESPName", BackgroundTransparency = 1, TextColor3 = currentESPColor, TextStrokeTransparency = 0,
        TextStrokeColor3 = Glass.Black, FontFace = F.Bold, TextSize = 14, Visible = false, ZIndex = 2,
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(240, 20), Parent = ESPGui,
    })
    local plr = Players:GetPlayerFromCharacter(model)
    d.baseName = plr and plr.DisplayName or model.Name
    d.hpBarBg = new("Frame", {Name = "HPBarBg", BackgroundColor3 = Glass.Black, BackgroundTransparency = 0.5, BorderSizePixel = 0, Visible = false, ZIndex = 1, Parent = ESPGui})
    d.hpBarFill = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 255, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), ZIndex = 2, Parent = d.hpBarBg,
    })
    activeESPs[model] = d
end

local function RemoveESP(model)
    local d = activeESPs[model]
    if not d then return end
    d.box:Destroy(); d.nameLabel:Destroy(); d.hpBarBg:Destroy()
    activeESPs[model] = nil
end

local function updateESP(model, d)
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then hideESP(d); return end
    
    local minV = Vector3.new(math.huge, math.huge, math.huge)
    local maxV = Vector3.new(-math.huge, -math.huge, -math.huge)
    
    for _, partName in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso", "Torso"}) do
        local p = model:FindFirstChild(partName)
        if p and p:IsA("BasePart") then
            local sz, pos = p.Size, p.Position
            minV = Vector3.new(math.min(minV.X, pos.X - sz.X/2), math.min(minV.Y, pos.Y - sz.Y/2), math.min(minV.Z, pos.Z - sz.Z/2))
            maxV = Vector3.new(math.max(maxV.X, pos.X + sz.X/2), math.max(maxV.Y, pos.Y + sz.Y/2), math.max(maxV.Z, pos.Z + sz.Z/2))
        end
    end
    
    if minV.X == math.huge then
        local sz, pos = hrp.Size, hrp.Position
        minV = pos - sz/2; maxV = pos + sz/2
    end
    
    local corners = {}
    local allOnScreen = true
    for xi = 0, 1 do
        for yi = 0, 1 do
            for zi = 0, 1 do
                local v = Vector3.new(xi == 0 and minV.X or maxV.X, yi == 0 and minV.Y or maxV.Y, zi == 0 and minV.Z or maxV.Z)
                local sp, onScreen = WorldToScreen(v)
                if not onScreen or not sp then allOnScreen = false; break end
                table.insert(corners, sp)
            end
            if not allOnScreen then break end
        end
        if not allOnScreen then break end
    end
    
    if allOnScreen and #corners == 8 then
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        for _, sp in ipairs(corners) do
            minX = math.min(minX, sp.X); maxX = math.max(maxX, sp.X)
            minY = math.min(minY, sp.Y); maxY = math.max(maxY, sp.Y)
        end
        
        d.box.Position = UDim2.fromOffset(minX, minY)
        d.box.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
        d.box.Visible = true
        
        local dist = 0
        local myChar = player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then dist = (myRoot.Position - hrp.Position).Magnitude end
        
        d.nameLabel.Text = string.format("%s  [%dm]", d.baseName, math.floor(dist + 0.5))
        d.nameLabel.Position = UDim2.fromOffset(minX + (maxX - minX) / 2, minY - 14)
        d.nameLabel.Visible = true
        
        if espHPEnabled and hum then
            local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            d.hpBarBg.Position = UDim2.fromOffset(minX - 7, minY)
            d.hpBarBg.Size = UDim2.fromOffset(3, maxY - minY)
            d.hpBarFill.Size = UDim2.fromScale(1, hp)
            if hp > 0.5 then
                d.hpBarFill.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - (hp - 0.5) * 2)), 255, 0)
            else
                d.hpBarFill.BackgroundColor3 = Color3.fromRGB(255, math.floor(255 * hp * 2), 0)
            end
            d.hpBarBg.Visible = true
        else
            d.hpBarBg.Visible = false
        end
    else
        hideESP(d)
    end
end

local ESP_BIND = "WC_ESP_" .. tostring(math.random(1, 1e6))
if _genv.__WC_ESP_BIND then pcall(function() RunService:UnbindFromRenderStep(_genv.__WC_ESP_BIND) end) end
_genv.__WC_ESP_BIND = ESP_BIND
RunService:BindToRenderStep(ESP_BIND, Enum.RenderPriority.Last.Value, function()
    if ScriptUnloaded then pcall(function() RunService:UnbindFromRenderStep(ESP_BIND) end) return end
    -- пока двигают ползунок поправки — ESP видно даже при открытом меню
    local hideAll = (isOpen and os.clock() > (WC_PROJ.calibUntil or 0)) or not espEnabled
    for model, d in pairs(activeESPs) do
        if not model.Parent then
            RemoveESP(model)
        elseif hideAll then
            hideESP(d)
        else
            updateESP(model, d)
        end
    end
end)

local function scanESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not activeESPs[obj] and (obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("HumanoidRootPart")) then
            CreateESPForModel(obj)
        end
    end
end

RefreshAllESPs = function()
    for model in pairs(activeESPs) do RemoveESP(model) end
    if espEnabled then scanESP() end
end

task.spawn(function()
    while not ScriptUnloaded do
        task.wait(2)
        if espEnabled and not isOpen and not ScriptUnloaded then scanESP() end
    end
end)

-- ================= ВКЛАДКА MOVEMENT =================
local MovementScroll = makeScrollPage(MovementTab)

createCard(MovementScroll, {title = "Strafe", desc = "Быстрый и резкий контроль в воздухе на WASD", key = "StrafeEnabled",
    onToggle = function(s) if s then Features.startStrafe() else Features.stopStrafe() end end,
    settings = function(p)
        makeSlider(p, "Скорость", 20, 160, State.StrafeSpeed, function(v) State.StrafeSpeed = v end, 0)
        makeSlider(p, "Резкость (60 = мгновенно)", 5, 60, State.StrafeSharp, function(v) State.StrafeSharp = v end, 0)
        makeToggle(p, "Bhop — авто-прыжок при движении", State.StrafeBhop, function(v) State.StrafeBhop = v end)
        makeToggle(p, "Работать и на земле", State.StrafeGround, function(v) State.StrafeGround = v end)
    end})

createCard(MovementScroll, {title = "Fly", desc = "Кастомный полет с обходом античитов", key = "FlyEnabled",
    onToggle = function(s) if s then Features.startFly() else Features.stopFly() end end,
    settings = function(p)
        makeSlider(p, "Скорость полета", 10, 200, 50, function(v)
            if _genv.WC_Fly then _genv.WC_Fly.speed = v end
        end, 0)
    end})


-- =====================================================================
-- =====================  COSMETICS: ДВИЖОК  ============================
-- =====================================================================
-- Каждая косметика описывается функцией build(R), которая собирает модель
-- из деталей в локальных координатах точки крепления. Детали разбиты на
-- группы; анимированные группы двигаются через R.pose[имя] каждый кадр.
-- Одна и та же сборка используется и на персонаже (сварки), и в превью.
local Cos = {list = {}, byId = {}, active = {}, folder = nil, onChanged = nil}
do (function()
    local PI, TAU = math.pi, math.pi * 2
    local rad, sin, cos, abs = math.rad, math.sin, math.cos, math.abs
    local V3, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
    local C3 = Color3.fromRGB
    local IDENT = CFrame.identity
    local M = Enum.Material
    local N = Enum.NormalId
    local FRONT, BACK, TOP, BOTTOM = N.Front, N.Back, N.Top, N.Bottom
    local ALL = {N.Front, N.Back, N.Top, N.Bottom, N.Left, N.Right}
    local function mix(a, b, t) return a + (b - a) * t end
    local function mixC(a, b, t) return a:Lerp(b, t) end

    -- ---------- строительные блоки ----------
    local function G(R, name, base, animated)
        local g = {name = name, base = base or IDENT, items = {}, animated = animated and true or false}
        R.groups[name] = g
        table.insert(R.list, g)
        return g
    end
    local function P(g, kind, size, cf, color, mat, props)
        local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
        if kind == "ball" then p.Shape = Enum.PartType.Ball
        elseif kind == "cyl" then p.Shape = Enum.PartType.Cylinder end
        p.Size = size
        p.Color = color or C3(255, 255, 255)
        p.Material = mat or M.SmoothPlastic
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.Massless = true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        if props then for k, v in pairs(props) do p[k] = v end end
        table.insert(g.items, {p = p, off = cf})
        return p
    end
    local function ell(g, size, cf, color, mat, props)
        local p = P(g, "block", size, cf, color, mat, props)
        local m = Instance.new("SpecialMesh")
        m.MeshType = Enum.MeshType.Sphere
        m.Parent = p
        return p
    end
    local function vcyl(g, h, d, cf, color, mat, props)
        return P(g, "cyl", V3(h, d, d), cf * ANG(0, 0, PI / 2), color, mat, props)
    end
    local function seg(g, a, b, d, color, mat, props, stretch)
        local dir = b - a
        local len = dir.Magnitude
        if len < 1e-3 then return nil end
        local up = (abs(dir.Unit.Y) > 0.98) and Vector3.xAxis or Vector3.yAxis
        local cf = CFrame.lookAt((a + b) / 2, b, up) * ANG(0, PI / 2, 0)
        return P(g, "cyl", V3(len * (stretch or 1.04), d, d), cf, color, mat, props)
    end
    -- треугольник в плоскости XY (основание w снизу, вершина вверху), толщина по Z
    local function tri(g, w, h, th, cf, color, mat, props)
        local L = cf * ANG(0, -PI / 2, 0)
        local a = P(g, "wedge", V3(th, h, w / 2), L * CF(0, 0, -w / 4), color, mat, props)
        local b = P(g, "wedge", V3(th, h, w / 2), L * CF(0, 0, w / 4) * ANG(0, PI, 0), color, mat, props)
        return a, b
    end
    local function tex(p, name, su, sv, tint, faces, transp, offV)
        local id = name and Tex.get(name)
        if not id or not p then return false end
        for _, f in ipairs(faces or ALL) do
            local t = Instance.new("Texture")
            t.Texture = id
            t.Face = f
            t.StudsPerTileU = su
            t.StudsPerTileV = sv
            if offV then t.OffsetStudsV = offV end
            if tint then t.Color3 = tint end
            if transp then t.Transparency = transp end
            t.Parent = p
        end
        return true
    end
    -- decal; cutout = деталь прозрачная, видно только картинку; hide = без текстуры прятать деталь
    local function decal(p, name, faces, tint, cutout, hide, transp)
        local id = Tex.get(name)
        if not id then
            if hide then p.Transparency = 1 end
            return false
        end
        for _, f in ipairs(faces) do
            local d = Instance.new("Decal")
            d.Texture = id
            d.Face = f
            if tint then d.Color3 = tint end
            if transp then d.Transparency = transp end
            d.Parent = p
        end
        if cutout then p.Transparency = 1 end
        return true
    end
    -- двусторонняя панель с зеркальной картинкой с обратной стороны (крылья)
    local function panel(g, size, cf, texN, texM, side, tint, fallback)
        local p = P(g, "block", size, cf, fallback, M.SmoothPlastic)
        local idN, idM = Tex.get(texN), Tex.get(texM)
        if idN and idM then
            p.Transparency = 1
            local back, front = idN, idM
            if side < 0 then back, front = idM, idN end
            for _, pair in ipairs({{BACK, back}, {FRONT, front}}) do
                local d = Instance.new("Decal")
                d.Texture = pair[2]
                d.Face = pair[1]
                if tint then d.Color3 = tint end
                d.Parent = p
            end
        end
        return p
    end
    local function light(p, color, range, bright)
        local l = Instance.new("PointLight")
        l.Color = color
        l.Range = range or 8
        l.Brightness = bright or 0.8
        l.Shadows = false
        l.Parent = p
        return l
    end
    local function sparkles(p, color, rate, size, texName)
        local id = Tex.get(texName or "sparkle")
        local e = Instance.new("ParticleEmitter")
        e.Texture = id or "rbxasset://textures/particles/sparkles_main.dds"
        e.Color = ColorSequence.new(color)
        e.LightEmission = 1
        e.LightInfluence = 0
        e.Rate = rate or 3
        e.Lifetime = NumberRange.new(0.7, 1.3)
        e.Speed = NumberRange.new(0.2, 0.8)
        e.SpreadAngle = Vector2.new(180, 180)
        e.Rotation = NumberRange.new(0, 360)
        e.RotSpeed = NumberRange.new(-90, 90)
        e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, size or 0.22), NumberSequenceKeypoint.new(1, 0)})
        e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
        e.Parent = p
        return e
    end
    local function fxPart(g, cf)
        return P(g, "block", V3(0.1, 0.1, 0.1), cf or IDENT, nil, nil, {Transparency = 1})
    end
    local function D(d)
        table.insert(Cos.list, d)
        Cos.byId[d.id] = d
    end

    -- ---------- общие анимации ----------
    local function smoothTo(R, key, target, dt, speed)
        local cur = R.data[key]
        if cur == nil then cur = target end
        cur = cur + (target - cur) * math.min(dt * (speed or 4), 1)
        R.data[key] = cur
        return cur
    end
    local function wingAnim(ampMul, spdMul, sweep, lift)
        return function(R, t, dt, ctx)
            local A = smoothTo(R, "amp", ctx.air and 1 or 0.32, dt, 3) * (ampMul or 1)
            R.data.ph = (R.data.ph or 0) + dt * (ctx.air and 7.5 or 2.3) * (spdMul or 1)
            local f = sin(R.data.ph)
            local ys, zs = rad(sweep or 12), rad(lift or 10)
            R.pose.wR = ANG(0, -ys * A * (f + 0.3), zs * A * f)
            R.pose.wL = ANG(0, ys * A * (f + 0.3), -zs * A * f)
        end
    end

    -- =========================== КРЫЛЬЯ ===========================
    local function featherWing(R, s, o)
        local g = G(R, s > 0 and "wR" or "wL", CF(s * 0.22, 0.32, 0.1) * ANG(0, -s * rad(18), 0), true)
        local span = o.span or 1.9
        local function arm(a)
            return V3(s * span * a, 0.08 + 1.55 * sin(a * PI * 0.5), 0)
        end
        for i = 0, 5 do
            local a0, a1 = i / 6, (i + 1) / 6
            local p = seg(g, arm(a0), arm(a1), mix(0.3, 0.14, a0), o.fb1, M.SmoothPlastic)
            tex(p, o.armTex or "fur", 0.4, 0.4, o.armTint)
        end
        local layers = {
            {n = 13, a0 = 0.0, a1 = 1.0, len0 = 1.35, len1 = 2.7, wid = 0.58, ang0 = 4, ang1 = 52, z = 0.0, tint = o.tint1, fb = o.fb1, dy = 0},
            {n = 11, a0 = 0.02, a1 = 0.95, len0 = 0.85, len1 = 1.45, wid = 0.52, ang0 = 2, ang1 = 44, z = 0.06, tint = o.tint2, fb = o.fb2, dy = -0.05},
            {n = 9, a0 = 0.02, a1 = 0.9, len0 = 0.5, len1 = 0.8, wid = 0.44, ang0 = 0, ang1 = 36, z = 0.12, tint = o.tint3, fb = o.fb3, dy = -0.03},
        }
        for li, L in ipairs(layers) do
            for i = 1, L.n do
                local k = (i - 1) / (L.n - 1)
                local a = L.a0 + (L.a1 - L.a0) * k
                local len = L.len0 + (L.len1 - L.len0) * (k ^ 1.25)
                local th = s * rad(L.ang0 + (L.ang1 - L.ang0) * (k ^ 1.35))
                local dir = V3(sin(th), -cos(th), 0)
                local base = arm(a) + V3(0, L.dy, 0)
                local c = base + dir * (len / 2) + V3(0, 0, L.z + (L.n - i) * 0.004)
                local p = P(g, "block", V3(L.wid, len, 0.02), CF(c) * ANG(0, 0, th), L.fb, M.SmoothPlastic)
                decal(p, o.tex, {FRONT, BACK}, L.tint, true)
                if o.sparkle and li == 1 and i % 4 == 0 then sparkles(p, o.sparkle, 1.2, 0.2) end
            end
        end
    end
    local function batWing(R, s, o)
        local W, H = o.w or 3.4, o.h or 2.7
        local g = G(R, s > 0 and "wR" or "wL", CF(s * 0.3, 0.45, 0.14) * ANG(0, -s * rad(24), s * rad(16)), true)
        local function L(u, v, z) return V3(s * u * W, (0.09 - v) * H, z or 0) end
        panel(g, V3(W, H, 0.02), CF(s * W / 2, -0.41 * H, 0), "batwing", "batwing_m", s, o.tint, o.fb)
        local root, wrist, tip = L(0, 0.09), L(0.5, 0.07), L(0.99, 0.03)
        for _, sg in ipairs({{root, wrist, 0.17}, {wrist, tip, 0.11}}) do
            tex(seg(g, sg[1], sg[2], sg[3], o.bone), "horn", 0.3, 0.3, o.boneTint)
        end
        for _, f in ipairs({{0.97, 0.50}, {0.74, 0.84}, {0.43, 0.97}}) do
            tex(seg(g, wrist, L(f[1], f[2]), 0.07, o.bone), "horn", 0.3, 0.3, o.boneTint)
        end
        P(g, "ball", V3(0.24, 0.24, 0.24), CF(wrist), o.bone)
        -- коготь на сгибе и шип на кончике
        tri(g, 0.12, 0.3, 0.06, CF(wrist + V3(0, 0.2, 0)), o.claw or o.bone)
        tri(g, 0.08, 0.22, 0.05, CF(tip + V3(s * 0.08, 0.02, 0)) * ANG(0, 0, -s * rad(70)), o.claw or o.bone)
        if o.spikes then
            for i = 1, 4 do
                local p = root:Lerp(wrist, i / 5)
                tri(g, 0.14, 0.2, 0.05, CF(p + V3(0, 0.12, 0)) * ANG(0, 0, -s * rad(25)), o.claw or o.bone)
            end
        end
        if o.ember then sparkles(fxPart(g, CF(L(0.5, 0.5))), o.ember, 3, 0.25, "glow") end
    end
    local function iceWing(R, s)
        local g = G(R, s > 0 and "wR" or "wL", CF(s * 0.25, 0.4, 0.15) * ANG(0, -s * rad(22), s * rad(10)), true)
        local ice, core = C3(170, 225, 255), C3(90, 220, 255)
        local function shard(k, scale, z, nlayer)
            local th = s * rad(mix(18, 104, k))
            local len = mix(1.4, 2.9, sin(k * PI * 0.85)) * scale
            local w = mix(0.42, 0.68, k) * scale
            local dir = V3(sin(th), -cos(th), 0)
            local base = V3(s * 0.18 * k, 0.25 * k, z)
            local cf = CF(base + dir * (len / 2)) * ANG(0, 0, th)
            local props = {Transparency = 0.18, Reflectance = 0.15}
            local a, b = tri(g, w, len * 0.3, 0.07, cf * CF(0, len * 0.35, 0), ice, M.Glass, props)
            local c, d = tri(g, w, len * 0.7, 0.07, cf * CF(0, -len * 0.15, 0) * ANG(0, 0, PI), ice, M.Glass, props)
            for _, p in ipairs({a, b, c, d}) do tex(p, "ice", 0.6, 0.6, nil, nil, 0.25) end
            P(g, "block", V3(0.045, len * 0.85, 0.09), cf * CF(0, -len * 0.05, 0), core, M.Neon)
            if nlayer == 1 and k > 0.4 and k < 0.8 then sparkles(fxPart(g, cf), C3(200, 240, 255), 3, 0.18) end
        end
        for i = 1, 7 do shard((i - 1) / 6, 1, (7 - i) * 0.012, 1) end
        for i = 1, 5 do shard((i - 1) / 4 * 0.8, 0.55, 0.12 + (5 - i) * 0.01, 2) end
        tex(seg(g, V3(0, 0, 0), V3(s * 0.3, 0.3, 0), 0.22, ice, M.Glass, {Transparency = 0.1}), "ice", 0.5, 0.5)
    end
    local function bflyWing(R, s)
        local g = G(R, s > 0 and "wR" or "wL", CF(s * 0.1, 0.25, 0.2) * ANG(0, -s * rad(12), 0), true)
        local UW, UH = 2.4, 2.0
        panel(g, V3(UW, UH, 0.02), CF(s * (0.5 - 0.02) * UW, 0.1 + 0.12 * UH, 0.01), "bfly_up", "bfly_up_m", s, nil, C3(40, 120, 255))
        local LW, LH = 1.85, 1.65
        panel(g, V3(LW, LH, 0.02), CF(s * (0.5 - 0.02) * LW, -0.05 - 0.22 * LH, -0.01), "bfly_lo", "bfly_lo_m", s, nil, C3(30, 90, 220))
    end

    D({id = "angel", name = "Angel Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Три слоя перьев, мягкое золотое сияние и искры",
        build = function(R)
            local o = {tex = "feather", tint1 = C3(255, 255, 255), tint2 = C3(252, 250, 244), tint3 = C3(255, 250, 236),
                fb1 = C3(250, 250, 250), fb2 = C3(244, 242, 236), fb3 = C3(236, 232, 222), armTint = C3(255, 255, 255), sparkle = C3(255, 236, 170)}
            featherWing(R, 1, o); featherWing(R, -1, o)
            light(fxPart(G(R, "fx"), CF(0, 0.5, 0.4)), C3(255, 236, 190), 9, 0.7)
        end,
        anim = wingAnim(1, 1)})

    D({id = "galaxy_wings", name = "Galaxy Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Перья из туманностей и звёзд",
        build = function(R)
            local w = C3(255, 255, 255)
            local o = {tex = "feather_galaxy", tint1 = w, tint2 = C3(235, 225, 255), tint3 = C3(220, 210, 255),
                fb1 = C3(95, 50, 190), fb2 = C3(70, 40, 150), fb3 = C3(50, 30, 110), armTex = "galaxy", armTint = w, sparkle = C3(200, 150, 255)}
            featherWing(R, 1, o); featherWing(R, -1, o)
            light(fxPart(G(R, "fx"), CF(0, 0.5, 0.4)), C3(170, 120, 255), 10, 0.9)
        end,
        anim = wingAnim(1, 1.05)})

    D({id = "demon", name = "Demon Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Перепонки с венами, костяные пальцы и угли",
        build = function(R)
            local o = {tint = C3(165, 25, 40), fb = C3(110, 15, 25), bone = C3(45, 30, 35), boneTint = C3(110, 80, 85), claw = C3(25, 18, 20), ember = C3(255, 90, 40)}
            batWing(R, 1, o); batWing(R, -1, o)
            light(fxPart(G(R, "fx"), CF(0, 0.3, 0.5)), C3(255, 60, 40), 7, 0.6)
        end,
        anim = wingAnim(1.25, 0.85, 10, 14)})

    D({id = "dragon", name = "Dragon Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Изумрудные крылья с шипами и роговыми костями",
        build = function(R)
            local o = {w = 3.8, h = 3.0, tint = C3(80, 205, 120), fb = C3(40, 120, 60), bone = C3(30, 70, 45), boneTint = C3(120, 170, 110), claw = C3(230, 220, 170), spikes = true}
            batWing(R, 1, o); batWing(R, -1, o)
        end,
        anim = wingAnim(1.3, 0.75, 10, 15)})

    D({id = "butterfly", name = "Morpho Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Переливающиеся крылья бабочки-морфо",
        build = function(R)
            bflyWing(R, 1); bflyWing(R, -1)
            local b = G(R, "body")
            ell(b, V3(0.24, 1.0, 0.24), CF(0, 0.15, 0.24), C3(25, 25, 40))
            for _, s in ipairs({1, -1}) do
                seg(b, V3(s * 0.04, 0.6, 0.24), V3(s * 0.3, 1.2, 0.3), 0.03, C3(25, 25, 40))
                P(b, "ball", V3(0.08, 0.08, 0.08), CF(s * 0.3, 1.2, 0.3), C3(90, 200, 255), M.Neon)
            end
            sparkles(fxPart(b, CF(0, 0.3, 0.4)), C3(120, 210, 255), 4, 0.2)
        end,
        anim = function(R, t, dt, ctx)
            R.data.ph = (R.data.ph or 0) + dt * (ctx.air and 11 or 4)
            local open = rad(8 + 34 * (0.5 + 0.5 * sin(R.data.ph)))
            R.pose.wR = ANG(0, -open, 0)
            R.pose.wL = ANG(0, open, 0)
        end})

    D({id = "ice", name = "Frost Crystal Wings", cat = "Wings", anchor = "back", view = "back",
        desc = "Ледяные осколки с неоновыми жилами",
        build = function(R)
            iceWing(R, 1); iceWing(R, -1)
            light(fxPart(G(R, "fx"), CF(0, 0.5, 0.5)), C3(120, 210, 255), 9, 0.9)
        end,
        anim = wingAnim(0.7, 0.9, 8, 8)})

    -- =========================== ШАПКИ ===========================
    local GOLD = C3(255, 198, 70)
    local function goldTex(p, s) tex(p, "gold", s or 0.6, s or 0.6) end

    D({id = "crown", name = "Royal Crown", cat = "Hats", anchor = "hat", view = "front",
        desc = "Золото, бархат и драгоценные камни",
        build = function(R)
            local g = G(R, "c", CF(0, -0.06, 0) * ANG(rad(-4), 0, rad(4)))
            local r, n = 0.6, 14
            local gems = {C3(40, 110, 255), C3(30, 210, 120), C3(235, 30, 70)}
            for i = 0, n - 1 do
                local rot = ANG(0, i / n * TAU, 0)
                local p = P(g, "block", V3(TAU * r / n * 1.1, 0.34, 0.07), rot * CF(0, 0, -r), GOLD, M.SmoothPlastic, {Reflectance = 0.25})
                goldTex(p)
                P(g, "block", V3(TAU * (r + 0.03) / n * 1.12, 0.06, 0.12), rot * CF(0, 0.18, -r), C3(235, 170, 50), M.SmoothPlastic, {Reflectance = 0.3})
                P(g, "block", V3(TAU * (r + 0.03) / n * 1.12, 0.07, 0.12), rot * CF(0, -0.17, -r), C3(225, 160, 45), M.SmoothPlastic, {Reflectance = 0.3})
                if i % 2 == 0 then
                    goldTex(P(g, "block", V3(0.24, 0.24, 0.05), rot * CF(0, 0.2, -r) * ANG(0, 0, PI / 4), GOLD, M.SmoothPlastic, {Reflectance = 0.25}))
                    P(g, "ball", V3(0.12, 0.12, 0.12), rot * CF(0, 0.4, -r), gems[(i / 2) % 3 + 1], M.Neon)
                else
                    P(g, "ball", V3(0.1, 0.1, 0.1), rot * CF(0, 0, -r - 0.04), gems[(i % 3) + 1], M.Glass, {Reflectance = 0.4})
                end
            end
            local cap = ell(g, V3(1.1, 0.6, 1.1), CF(0, 0.06, 0), C3(140, 15, 40), M.Fabric)
            P(g, "ball", V3(0.17, 0.17, 0.17), CF(0, 0.36, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.3})
            P(g, "block", V3(0.05, 0.24, 0.05), CF(0, 0.52, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.3})
            P(g, "block", V3(0.17, 0.05, 0.05), CF(0, 0.56, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.3})
            P(g, "ball", V3(0.18, 0.18, 0.18), CF(0, 0, -r - 0.05), C3(230, 20, 60), M.Glass, {Reflectance = 0.4})
            light(fxPart(g, CF(0, 0.3, 0)), C3(255, 220, 140), 5, 0.4)
            return cap
        end})

    D({id = "halo", name = "Divine Halo", cat = "Hats", anchor = "hat", view = "front",
        desc = "Парящий светящийся нимб",
        build = function(R)
            local g = G(R, "h", CF(0, 0.55, 0.06) * ANG(rad(-14), 0, 0), true)
            local r, n, col = 0.62, 24, C3(255, 226, 140)
            for i = 0, n - 1 do
                local a0, a1 = i / n * TAU, (i + 1) / n * TAU
                seg(g, V3(r * cos(a0), 0, r * sin(a0)), V3(r * cos(a1), 0, r * sin(a1)), 0.085, col, M.Neon, nil, 1.08)
            end
            local disc = P(g, "block", V3(1.9, 0.02, 1.9), IDENT, col, M.SmoothPlastic)
            decal(disc, "ring", {TOP, BOTTOM}, C3(255, 236, 170), true, true)
            light(disc, C3(255, 230, 160), 7, 1)
            sparkles(fxPart(g, CF(r, 0, 0)), C3(255, 240, 190), 2, 0.15)
        end,
        anim = function(R, t)
            R.pose.h = CF(0, 0.07 * sin(t * 2.2), 0) * ANG(0, t * 0.8, 0)
        end})

    D({id = "tophat", name = "Gentleman Top Hat", cat = "Hats", anchor = "hat", view = "front",
        desc = "Фетр, атласная лента, пряжка и перо",
        build = function(R)
            local g = G(R, "t", CF(0, -0.12, 0) * ANG(rad(-5), 0, rad(7)))
            local black, red = C3(30, 30, 36), C3(150, 20, 35)
            tex(vcyl(g, 0.07, 2.0, IDENT, black), "fabric", 0.35, 0.35, C3(70, 70, 82))
            tex(vcyl(g, 1.05, 1.22, CF(0, 0.56, 0), black), "fabric", 0.35, 0.35, C3(70, 70, 82))
            tex(vcyl(g, 0.2, 1.26, CF(0, 0.135, 0), red), "fabric", 0.25, 0.25, C3(230, 50, 70))
            vcyl(g, 0.02, 1.18, CF(0, 1.09, 0), C3(42, 42, 50))
            P(g, "block", V3(0.3, 0.17, 0.04), CF(0, 0.135, -0.635), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
            P(g, "block", V3(0.18, 0.08, 0.045), CF(0, 0.135, -0.64), red)
            local f = P(g, "block", V3(0.3, 0.9, 0.02), CF(0.5, 0.5, -0.38) * ANG(0, rad(-40), rad(-18)) * ANG(0, 0, PI), C3(220, 40, 60))
            decal(f, "feather", {FRONT, BACK}, C3(235, 45, 70), true)
        end})

    D({id = "witch", name = "Witch Hat", cat = "Hats", anchor = "hat", view = "front",
        desc = "Изогнутый колпак со звёздами и луной",
        build = function(R)
            local g = G(R, "w", CF(0, -0.12, 0) * ANG(rad(-4), 0, rad(-6)))
            local purple = C3(70, 25, 110)
            tex(vcyl(g, 0.06, 2.4, IDENT, purple), "witch", 0.8, 0.8)
            vcyl(g, 0.2, 1.27, CF(0, 0.13, 0), C3(30, 10, 45))
            for _, b in ipairs({{0, 0.075, 0.3, 0.04}, {0, 0.185, 0.3, 0.04}, {-0.13, 0.13, 0.04, 0.15}, {0.13, 0.13, 0.04, 0.15}}) do
                P(g, "block", V3(b[3], b[4], 0.04), CF(b[1], b[2], -0.64), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
            end
            local cur, Nn, Ht = CF(0, 0.03, 0), 12, 1.95
            for i = 1, Nn do
                local k = (i - 1) / (Nn - 1)
                local h = Ht / Nn
                tex(vcyl(g, h * 1.08, mix(1.22, 0.1, k ^ 0.9), cur * CF(0, h / 2, 0), purple), "witch", 0.7, 0.7)
                cur = cur * CF(0, h, 0) * ANG(i > 6 and rad(10) or 0, 0, i > 8 and rad(5) or 0)
            end
            local star = P(g, "ball", V3(0.15, 0.15, 0.15), cur * CF(0, 0.04, 0), C3(255, 220, 90), M.Neon)
            sparkles(star, C3(255, 230, 120), 2, 0.15)
        end})

    D({id = "neko", name = "Neko Ears", cat = "Hats", anchor = "hat", view = "front",
        desc = "Пушистые ушки на ободке, иногда дёргаются",
        build = function(R)
            local band = G(R, "band")
            local pink = C3(255, 140, 190)
            local pts = {}
            for i = 0, 10 do
                local a = rad(mix(18, 162, i / 10))
                pts[i] = V3(0.66 * cos(a), -0.55 + 0.66 * sin(a), 0.02)
            end
            for i = 0, 9 do seg(band, pts[i], pts[i + 1], 0.09, pink, M.SmoothPlastic, nil, 1.1) end
            for _, s in ipairs({1, -1}) do
                local g = G(R, s > 0 and "eR" or "eL", CF(s * 0.36, -0.02, 0.02) * ANG(rad(-8), 0, -s * rad(18)), true)
                local a, b = tri(g, 0.56, 0.62, 0.12, CF(0, 0.31, 0), C3(45, 40, 52))
                tex(a, "fur", 0.3, 0.3, C3(90, 82, 105)); tex(b, "fur", 0.3, 0.3, C3(90, 82, 105))
                local c, d = tri(g, 0.32, 0.38, 0.04, CF(0, 0.24, -0.07), C3(255, 165, 200))
                tex(c, "fur", 0.25, 0.25, C3(255, 190, 215)); tex(d, "fur", 0.25, 0.25, C3(255, 190, 215))
                P(g, "ball", V3(0.12, 0.12, 0.12), CF(s * 0.05, 0.62, 0), C3(55, 50, 62))
            end
        end,
        anim = function(R, t)
            for _, s in ipairs({1, -1}) do
                local tw = (sin(t * 0.9 + s * 1.7) > 0.93) and sin(t * 38) * rad(12) or 0
                R.pose[s > 0 and "eR" or "eL"] = ANG(tw, 0, s * tw * 0.4)
            end
        end})

    D({id = "horns", name = "Devil Horns", cat = "Hats", anchor = "hat", view = "front",
        desc = "Изогнутые рога с тлеющим основанием",
        build = function(R)
            for _, s in ipairs({1, -1}) do
                local g = G(R, s > 0 and "hR" or "hL", CF(s * 0.32, -0.14, -0.1))
                local cur = ANG(rad(-14), 0, -s * rad(24))
                local L = 0.12
                vcyl(g, 0.05, 0.33, cur * CF(0, 0.02, 0), C3(255, 50, 30), M.Neon)
                for i = 1, 9 do
                    local k = (i - 1) / 8
                    local col = C3(mix(125, 22, k), mix(16, 10, k), mix(22, 12, k))
                    local p = vcyl(g, L * 1.14, mix(0.28, 0.05, k), cur * CF(0, L / 2, 0), col)
                    tex(p, "horn", 0.22, 0.22, C3(mix(255, 70, k), mix(70, 40, k), mix(80, 45, k)))
                    cur = cur * CF(0, L, 0) * ANG(rad(10), 0, s * rad(7))
                end
                P(g, "ball", V3(0.06, 0.06, 0.06), cur, C3(20, 8, 10))
                sparkles(fxPart(g, ANG(0, 0, 0)), C3(255, 80, 30), 2, 0.12, "glow")
            end
        end})

    D({id = "santa", name = "Santa Hat", cat = "Hats", anchor = "hat", view = "front",
        desc = "Бархатный колпак с меховой опушкой и помпоном",
        build = function(R)
            local g = G(R, "s", CF(0, -0.15, 0) * ANG(rad(-6), 0, 0))
            local white, red = C3(246, 246, 246), C3(200, 25, 35)
            tex(vcyl(g, 0.3, 1.42, CF(0, 0.05, 0), white, M.Fabric), "fur", 0.3, 0.3)
            local cur, Nn, Ht = CF(0, 0.2, 0), 10, 1.75
            for i = 1, Nn do
                local k = (i - 1) / (Nn - 1)
                local h = Ht / Nn
                tex(vcyl(g, h * 1.1, mix(1.28, 0.22, k ^ 0.8), cur * CF(0, h / 2, 0), red), "fabric", 0.3, 0.3, C3(235, 50, 60))
                cur = cur * CF(0, h, 0) * ANG(i >= 3 and rad(10) or 0, 0, i >= 4 and rad(-13) or 0)
            end
            tex(P(g, "ball", V3(0.44, 0.44, 0.44), cur * CF(0, 0.12, 0), white, M.Fabric), "fur", 0.25, 0.25)
        end})

    -- =========================== ПИТОМЦЫ ===========================
    local function eye(g, x, y, z, size)
        P(g, "ball", V3(size, size, size), CF(x, y, z), C3(250, 250, 255))
        P(g, "ball", V3(size * 0.58, size * 0.58, size * 0.58), CF(x * 1.05, y, z - size * 0.33), C3(15, 15, 22))
        P(g, "ball", V3(size * 0.2, size * 0.2, size * 0.2), CF(x * 0.95 - size * 0.08, y + size * 0.15, z - size * 0.48), C3(255, 255, 255), M.Neon)
    end
    local function faceDecal(g, size, cf, name)
        local p = P(g, "block", V3(size, size, 0.02), cf, C3(255, 255, 255), M.SmoothPlastic, {Transparency = 1})
        decal(p, name, {FRONT}, nil, true)
        return p
    end

    D({id = "dragon_pet", name = "Mini Dragon", cat = "Pets", anchor = "pet", view = "front",
        desc = "Чешуйчатый дракончик: машет крыльями и хвостом",
        build = function(R)
            local green, belly, dark = C3(70, 175, 95), C3(242, 222, 140), C3(35, 90, 50)
            local sc = C3(150, 255, 170)
            local g = G(R, "body")
            tex(P(g, "ball", V3(0.85, 0.85, 0.85), CF(0, 0, -0.05), green), "scales", 0.3, 0.3, sc)
            tex(P(g, "ball", V3(0.75, 0.75, 0.75), CF(0, -0.06, 0.38), green), "scales", 0.3, 0.3, sc)
            ell(g, V3(0.62, 0.6, 0.85), CF(0, -0.14, 0.12), belly)
            tex(P(g, "ball", V3(0.72, 0.72, 0.72), CF(0, 0.42, -0.42), green), "scales", 0.25, 0.25, sc)
            ell(g, V3(0.46, 0.3, 0.44), CF(0, 0.33, -0.76), green)
            for _, s in ipairs({1, -1}) do
                P(g, "ball", V3(0.05, 0.05, 0.05), CF(s * 0.08, 0.4, -0.97), dark)
                eye(g, s * 0.17, 0.53, -0.66, 0.22)
                local hb = V3(s * 0.16, 0.72, -0.36)
                seg(g, hb, hb + V3(s * 0.06, 0.16, 0.12), 0.09, belly)
                seg(g, hb + V3(s * 0.06, 0.16, 0.12), hb + V3(s * 0.08, 0.24, 0.3), 0.05, belly)
                P(g, "ball", V3(0.24, 0.24, 0.24), CF(s * 0.25, -0.42, -0.15), dark)
                P(g, "ball", V3(0.24, 0.24, 0.24), CF(s * 0.22, -0.42, 0.45), dark)
                local w = G(R, s > 0 and "wR" or "wL", CF(s * 0.2, 0.3, 0.08) * ANG(0, -s * rad(15), s * rad(25)), true)
                panel(w, V3(1.0, 0.8, 0.02), CF(s * 0.5, -0.33, 0), "batwing", "batwing_m", s, C3(110, 230, 140), green)
                seg(w, V3(0, 0, 0), V3(s * 0.5, 0.05, 0), 0.07, dark)
            end
            for _, z in ipairs({0, 0.25, 0.5}) do
                tri(g, 0.16, 0.2, 0.05, CF(0, 0.44 - z * 0.15, z) * ANG(0, PI / 2, 0), belly)
            end
            for i = 1, 5 do
                local k = (i - 1) / 4
                local tg = G(R, "t" .. i, CF(0, -0.05 + i * 0.05, 0.6 + (i - 1) * 0.2), true)
                tex(P(tg, "ball", V3(mix(0.42, 0.15, k), mix(0.42, 0.15, k), mix(0.42, 0.15, k)), IDENT, green), "scales", 0.25, 0.25, sc)
                if i == 5 then tri(tg, 0.22, 0.24, 0.05, CF(0, 0.05, 0.12) * ANG(PI / 2, 0, 0), belly) end
            end
        end,
        anim = function(R, t)
            local f = sin(t * 13)
            R.pose.wR = ANG(0, 0, rad(32) * f)
            R.pose.wL = ANG(0, 0, -rad(32) * f)
            for i = 1, 5 do R.pose["t" .. i] = CF(sin(t * 3 - i * 0.7) * 0.06 * i, 0, 0) end
        end})

    D({id = "ghost", name = "Boo Ghost", cat = "Pets", anchor = "pet", view = "front",
        desc = "Полупрозрачный призрак с волнистым подолом",
        build = function(R)
            local white = C3(240, 244, 255)
            local tp = {Transparency = 0.12}
            local g = G(R, "body")
            P(g, "ball", V3(1, 1, 1), CF(0, 0.15, 0), white, M.SmoothPlastic, tp)
            vcyl(g, 0.5, 1.0, CF(0, -0.2, 0), white, M.SmoothPlastic, tp)
            faceDecal(g, 0.72, CF(0, 0.12, -0.49), "face_ghost")
            light(fxPart(g), C3(190, 210, 255), 6, 0.7)
            sparkles(fxPart(g, CF(0, -0.4, 0)), C3(200, 220, 255), 3, 0.15, "glow")
            local sk = G(R, "skirt", CF(0, -0.45, 0), true)
            for i = 0, 7 do
                local a = i / 8 * TAU
                P(sk, "ball", V3(0.3, 0.3, 0.3), CF(0.36 * cos(a), 0, 0.36 * sin(a)), white, M.SmoothPlastic, tp)
            end
            for _, s in ipairs({1, -1}) do
                local a = G(R, s > 0 and "aR" or "aL", CF(s * 0.47, -0.05, 0), true)
                ell(a, V3(0.22, 0.34, 0.22), ANG(0, 0, s * rad(35)) * CF(0, -0.08, 0), white, M.SmoothPlastic, tp)
            end
        end,
        anim = function(R, t)
            R.pose.skirt = ANG(0, t * 1.6, 0) * CF(0, 0.03 * sin(t * 5), 0)
            R.pose.aR = ANG(0, 0, rad(18) * sin(t * 3))
            R.pose.aL = ANG(0, 0, -rad(18) * sin(t * 3 + 1))
        end})

    D({id = "cat", name = "Ginger Cat", cat = "Pets", anchor = "pet", view = "front",
        desc = "Рыжий пушистый кот с румяной мордочкой",
        build = function(R)
            local orange, white, pink = C3(245, 160, 70), C3(255, 250, 245), C3(255, 170, 190)
            local ft = C3(255, 200, 130)
            local g = G(R, "body")
            tex(P(g, "ball", V3(0.72, 0.72, 0.72), CF(0, -0.05, 0), orange), "fur", 0.3, 0.3, ft)
            tex(P(g, "ball", V3(0.68, 0.68, 0.68), CF(0, -0.1, 0.36), orange), "fur", 0.3, 0.3, ft)
            ell(g, V3(0.5, 0.45, 0.7), CF(0, -0.2, 0.15), white)
            tex(P(g, "ball", V3(0.74, 0.74, 0.74), CF(0, 0.38, -0.3), orange), "fur", 0.3, 0.3, ft)
            for _, s in ipairs({1, -1}) do
                ell(g, V3(0.3, 0.2, 0.2), CF(s * 0.12, 0.23, -0.6), white)
                local a, b = tri(g, 0.3, 0.32, 0.08, CF(s * 0.2, 0.74, -0.3) * ANG(0, 0, -s * rad(14)), orange)
                tex(a, "fur", 0.2, 0.2, ft); tex(b, "fur", 0.2, 0.2, ft)
                tri(g, 0.17, 0.19, 0.03, CF(s * 0.2, 0.71, -0.345) * ANG(0, 0, -s * rad(14)), pink)
                for k = -1, 1 do
                    P(g, "block", V3(0.34, 0.012, 0.012), CF(s * 0.36, 0.26 + k * 0.04, -0.6) * ANG(0, 0, s * k * rad(10)), white)
                end
                vcyl(g, 0.3, 0.17, CF(s * 0.18, -0.36, -0.05), orange)
                vcyl(g, 0.3, 0.17, CF(s * 0.18, -0.38, 0.42), orange)
                P(g, "ball", V3(0.2, 0.2, 0.2), CF(s * 0.18, -0.52, -0.07), white)
                P(g, "ball", V3(0.2, 0.2, 0.2), CF(s * 0.18, -0.54, 0.42), white)
            end
            ell(g, V3(0.09, 0.06, 0.06), CF(0, 0.33, -0.69), pink)
            faceDecal(g, 0.7, CF(0, 0.44, -0.66), "face_cute")
            for i = 1, 6 do
                local tg = G(R, "t" .. i, CF(0, -0.02 + i * 0.11, 0.62 + i * 0.07), true)
                local d = mix(0.2, 0.16, i / 6)
                local p = P(tg, "ball", V3(d, d, d), IDENT, i == 6 and white or orange)
                tex(p, "fur", 0.2, 0.2, i == 6 and nil or ft)
            end
        end,
        anim = function(R, t)
            for i = 1, 6 do R.pose["t" .. i] = CF(sin(t * 2.5 - i * 0.5) * 0.05 * i, 0, 0) end
        end})

    D({id = "slime", name = "Jelly Slime", cat = "Pets", anchor = "pet", view = "front",
        desc = "Желейный слайм с ростком — прыгает",
        build = function(R)
            local g = G(R, "body", IDENT, true)
            P(g, "ball", V3(1, 1, 1), IDENT, C3(100, 235, 150), M.Glass, {Transparency = 0.3, Reflectance = 0.1})
            P(g, "ball", V3(0.45, 0.45, 0.45), CF(0, -0.05, 0.05), C3(60, 210, 120), M.Neon, {Transparency = 0.25})
            faceDecal(g, 0.7, CF(0, 0.02, -0.49), "face_cute")
            ell(g, V3(0.22, 0.12, 0.1), CF(-0.22, 0.3, -0.36) * ANG(0, 0, rad(25)), C3(255, 255, 255), M.Neon, {Transparency = 0.3})
            seg(g, V3(0, 0.48, 0), V3(0.02, 0.68, 0), 0.05, C3(60, 150, 60))
            tri(g, 0.14, 0.22, 0.03, CF(0.1, 0.7, 0) * ANG(0, 0, rad(-60)), C3(90, 200, 90))
            tri(g, 0.12, 0.2, 0.03, CF(-0.07, 0.69, 0) * ANG(0, 0, rad(55)), C3(90, 200, 90))
            light(fxPart(g), C3(120, 255, 170), 5, 0.6)
        end,
        anim = function(R, t)
            local b = abs(sin(t * 3.2))
            R.pose.body = CF(0, b * 0.3 - 0.12, 0) * ANG(0, 0, sin(t * 3.2) * 0.06)
        end})

    D({id = "spirit", name = "Star Spirit", cat = "Pets", anchor = "pet", view = "front",
        desc = "Звёздный дух: ядро, кольцо и спутники",
        build = function(R)
            local core = G(R, "core", IDENT, true)
            P(core, "ball", V3(0.36, 0.36, 0.36), IDENT, C3(255, 245, 205), M.Neon)
            local shell = P(core, "ball", V3(0.78, 0.78, 0.78), IDENT, C3(150, 120, 255), M.Glass, {Transparency = 0.55})
            tex(shell, "galaxy", 0.6, 0.6, nil, nil, 0.35)
            light(shell, C3(200, 170, 255), 8, 1)
            sparkles(fxPart(core), C3(220, 200, 255), 5, 0.18)
            local orb = G(R, "orbit", IDENT, true)
            local cols = {C3(255, 120, 200), C3(110, 220, 255), C3(255, 230, 120)}
            for i = 1, 3 do
                local a = i / 3 * TAU
                P(orb, "ball", V3(0.14, 0.14, 0.14), CF(cos(a) * 0.68, sin(a * 2) * 0.12, sin(a) * 0.68), cols[i], M.Neon)
            end
            local ring = G(R, "ring", ANG(rad(70), 0, rad(20)), true)
            for i = 0, 17 do
                local a0, a1 = i / 18 * TAU, (i + 1) / 18 * TAU
                seg(ring, V3(cos(a0) * 0.55, 0, sin(a0) * 0.55), V3(cos(a1) * 0.55, 0, sin(a1) * 0.55), 0.03, C3(220, 210, 255), M.Neon, nil, 1.08)
            end
            for _, s in ipairs({1, -1}) do
                local w = G(R, s > 0 and "wR" or "wL", CF(s * 0.12, 0.12, 0.28) * ANG(0, -s * rad(20), 0), true)
                for j, ang in ipairs({140, 110}) do
                    local th = s * rad(ang)
                    local len = j == 1 and 0.75 or 0.55
                    local dir = V3(sin(th), -cos(th), 0)
                    local p = P(w, "block", V3(0.3, len, 0.02), CF(dir * len / 2 + V3(0, 0, j * 0.01)) * ANG(0, 0, th), C3(190, 230, 255))
                    decal(p, "feather", {FRONT, BACK}, C3(190, 230, 255), true, false, 0.15)
                end
            end
        end,
        anim = function(R, t)
            local bob = CF(0, 0.08 * sin(t * 2.5), 0)
            R.pose.core = bob
            R.pose.orbit = bob * ANG(0, t * 2, 0)
            R.pose.ring = bob * ANG(0, t * 1.3, 0)
            local f = sin(t * 16) * rad(28)
            R.pose.wR = bob * ANG(0, -f, 0)
            R.pose.wL = bob * ANG(0, f, 0)
        end})

    -- =========================== РЮКЗАКИ ===========================
    local function shoulderStraps(g, col, texName, tint)
        for _, s in ipairs({1, -1}) do
            tex(P(g, "block", V3(0.2, 0.06, 1.1), CF(s * 0.5, 0.72, -0.5), col), texName, 0.4, 0.4, tint)
            tex(P(g, "block", V3(0.2, 1.25, 0.06), CF(s * 0.5, 0.1, -1.04), col), texName, 0.4, 0.4, tint)
        end
    end

    D({id = "jetpack", name = "Rocket Jetpack", cat = "Backpacks", anchor = "back", view = "back",
        desc = "Баки, сопла и пламя, когда ты в воздухе",
        build = function(R)
            local g = G(R, "j")
            local steel, red, dark = C3(150, 155, 168), C3(205, 45, 45), C3(45, 45, 52)
            tex(P(g, "block", V3(1.0, 1.3, 0.36), CF(0, 0, 0.2), steel, M.SmoothPlastic, {Reflectance = 0.1}), "metal", 0.65, 0.65)
            R.data.emitters, R.data.lights = {}, {}
            for _, s in ipairs({1, -1}) do
                local x = s * 0.48
                tex(vcyl(g, 1.45, 0.56, CF(x, -0.05, 0.42), red, M.SmoothPlastic, {Reflectance = 0.15}), "metal", 0.5, 0.5, C3(255, 130, 130))
                tex(P(g, "ball", V3(0.56, 0.56, 0.56), CF(x, 0.67, 0.42), red, M.SmoothPlastic, {Reflectance = 0.15}), "metal", 0.5, 0.5, C3(255, 130, 130))
                vcyl(g, 0.06, 0.6, CF(x, 0.35, 0.42), dark)
                vcyl(g, 0.06, 0.6, CF(x, -0.45, 0.42), dark)
                vcyl(g, 0.22, 0.46, CF(x, -0.86, 0.42), dark)
                vcyl(g, 0.16, 0.38, CF(x, -1.04, 0.42), C3(75, 75, 85))
                vcyl(g, 0.03, 0.3, CF(x, -1.125, 0.42), C3(255, 150, 40), M.Neon)
                tri(g, 0.3, 0.55, 0.05, CF(x + s * 0.34, -0.55, 0.42), red)
                local fp = fxPart(g, CF(x, -1.16, 0.42))
                local e = Instance.new("ParticleEmitter")
                e.Texture = Tex.get("glow") or "rbxasset://textures/particles/fire_main.dds"
                e.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C3(255, 240, 170)), ColorSequenceKeypoint.new(0.4, C3(255, 130, 30)), ColorSequenceKeypoint.new(1, C3(180, 30, 20))})
                e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.38), NumberSequenceKeypoint.new(1, 0.05)})
                e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                e.Lifetime = NumberRange.new(0.18, 0.32)
                e.Speed = NumberRange.new(8, 11)
                e.SpreadAngle = Vector2.new(8, 8)
                e.EmissionDirection = Enum.NormalId.Bottom
                e.LightEmission = 1
                e.Rate = 0
                e.Parent = fp
                table.insert(R.data.emitters, e)
                local l = light(fp, C3(255, 140, 40), 8, 1.5)
                l.Enabled = false
                table.insert(R.data.lights, l)
            end
            P(g, "ball", V3(0.2, 0.2, 0.2), CF(0, 0.38, 0.38), C3(235, 235, 240))
            P(g, "block", V3(0.02, 0.09, 0.03), CF(0.03, 0.4, 0.48) * ANG(0, 0, rad(-30)), red)
            P(g, "block", V3(0.55, 0.05, 0.02), CF(0, -0.3, 0.385), C3(80, 220, 255), M.Neon)
            P(g, "block", V3(0.55, 0.05, 0.02), CF(0, -0.42, 0.385), C3(80, 220, 255), M.Neon)
            shoulderStraps(g, dark, "leather", C3(90, 90, 100))
        end,
        anim = function(R, t, dt, ctx)
            local rate = ctx.air and 90 or ((ctx.speed > 2) and 8 or 0)
            for _, e in ipairs(R.data.emitters or {}) do e.Rate = rate end
            for _, l in ipairs(R.data.lights or {}) do l.Enabled = ctx.air end
        end})

    D({id = "rucksack", name = "Explorer Rucksack", cat = "Backpacks", anchor = "back", view = "back",
        desc = "Походный рюкзак: карманы, ремни и спальник",
        build = function(R)
            local g = G(R, "r")
            local olive, oliveT, brown, brownT = C3(80, 110, 70), C3(140, 180, 120), C3(110, 70, 40), C3(170, 120, 80)
            tex(P(g, "block", V3(1.3, 1.5, 0.6), CF(0, -0.05, 0.32), olive), "fabric", 0.3, 0.3, oliveT)
            tex(P(g, "cyl", V3(1.3, 0.6, 0.6), CF(0, 0.7, 0.32), olive), "fabric", 0.3, 0.3, oliveT)
            tex(P(g, "block", V3(1.0, 0.62, 0.22), CF(0, -0.38, 0.73), C3(70, 95, 60)), "fabric", 0.3, 0.3, C3(120, 160, 105))
            tex(P(g, "block", V3(1.04, 0.24, 0.25), CF(0, -0.05, 0.74), brown), "leather", 0.4, 0.4, brownT)
            P(g, "block", V3(0.14, 0.1, 0.03), CF(0, -0.12, 0.875), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
            for _, s in ipairs({1, -1}) do
                tex(P(g, "block", V3(0.2, 0.6, 0.45), CF(s * 0.74, -0.38, 0.32), C3(70, 95, 60)), "fabric", 0.3, 0.3, C3(120, 160, 105))
                tex(P(g, "block", V3(0.1, 1.3, 0.03), CF(s * 0.4, 0.05, 0.635), brown), "leather", 0.3, 0.3, brownT)
                P(g, "block", V3(0.14, 0.1, 0.04), CF(s * 0.4, 0.45, 0.65), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
                vcyl(g, 0.07, 0.53, CF(s * 0.45, 1.2, 0.34) * ANG(0, 0, PI / 2), brown)
            end
            tex(P(g, "cyl", V3(1.6, 0.5, 0.5), CF(0, 1.2, 0.34), C3(160, 30, 30)), "plaid", 0.5, 0.5)
            vcyl(g, 0.3, 0.24, CF(0.82, -0.1, 0.32), C3(170, 175, 185), M.SmoothPlastic, {Reflectance = 0.3})
            shoulderStraps(g, brown, "leather", brownT)
        end})

    D({id = "katanas", name = "Twin Katanas", cat = "Backpacks", anchor = "back", view = "back",
        desc = "Две катаны крест-накрест: лак, цуба и обмотка",
        build = function(R)
            local g = G(R, "k")
            local lac, red = C3(18, 16, 22), C3(170, 25, 35)
            local function sword(cf, sheath)
                P(g, "block", V3(0.17, 2.5, 0.11), cf * CF(0, -0.35, 0), sheath, M.SmoothPlastic, {Reflectance = 0.35})
                P(g, "block", V3(0.19, 0.18, 0.13), cf * CF(0, -1.62, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
                P(g, "block", V3(0.19, 0.08, 0.13), cf * CF(0, 0.86, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
                P(g, "block", V3(0.21, 0.07, 0.14), cf * CF(0, 0.6, 0), red)
                P(g, "block", V3(0.21, 0.07, 0.14), cf * CF(0, 0.48, 0), red)
                goldTex(vcyl(g, 0.05, 0.44, cf * CF(0, 0.93, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.3}), 0.3)
                P(g, "block", V3(0.15, 0.08, 0.1), cf * CF(0, 0.99, 0), GOLD)
                tex(P(g, "block", V3(0.15, 0.85, 0.12), cf * CF(0, 1.45, 0), C3(30, 30, 36)), "wrap", 0.15, 0.3)
                P(g, "block", V3(0.17, 0.09, 0.14), cf * CF(0, 1.9, 0), GOLD, M.SmoothPlastic, {Reflectance = 0.4})
            end
            sword(CF(0.05, 0.1, 0.12) * ANG(0, 0, rad(-32)), lac)
            sword(CF(-0.05, 0.1, 0.26) * ANG(0, 0, rad(32)), C3(110, 15, 25))
            tex(P(g, "block", V3(2.2, 0.16, 0.06), CF(0, -0.15, 0.04) * ANG(0, 0, rad(36)), C3(90, 60, 40)), "leather", 0.4, 0.4, C3(160, 120, 90))
        end})

    D({id = "cyber", name = "Cyber Core Pack", cat = "Backpacks", anchor = "back", view = "back",
        desc = "Неоновые схемы, вращающееся ядро и парящие плавники",
        build = function(R)
            local g = G(R, "b")
            local dark, cyan, mag = C3(22, 24, 36), C3(60, 230, 255), C3(255, 60, 200)
            tex(P(g, "block", V3(1.05, 1.35, 0.32), CF(0, 0, 0.18), dark, M.SmoothPlastic, {Reflectance = 0.2}), "cyber", 0.6, 0.6, nil, {BACK})
            for _, s in ipairs({1, -1}) do
                P(g, "block", V3(0.28, 1.1, 0.25), CF(s * 0.6, 0, 0.16) * ANG(0, s * rad(25), 0), dark, M.SmoothPlastic, {Reflectance = 0.2})
                P(g, "block", V3(0.04, 1.25, 0.04), CF(s * 0.5, 0, 0.35), cyan, M.Neon)
            end
            P(g, "block", V3(0.9, 0.04, 0.04), CF(0, 0.66, 0.35), cyan, M.Neon)
            P(g, "block", V3(0.9, 0.04, 0.04), CF(0, -0.66, 0.35), cyan, M.Neon)
            for i = 1, 3 do P(g, "block", V3(0.5, 0.03, 0.02), CF(0, -0.42 - i * 0.06, 0.345), mag, M.Neon) end
            shoulderStraps(g, dark)
            local core = G(R, "core", CF(0, 0.08, 0.62), true)
            P(core, "ball", V3(0.24, 0.24, 0.24), IDENT, mag, M.Neon)
            P(core, "ball", V3(0.46, 0.46, 0.46), IDENT, cyan, M.Glass, {Transparency = 0.6})
            for i = 0, 5 do
                local a = i / 6 * TAU
                P(core, "block", V3(0.06, 0.2, 0.05), ANG(0, 0, a) * CF(0.34, 0, 0), cyan, M.Neon)
            end
            light(fxPart(core), C3(120, 220, 255), 8, 1)
            local fins = G(R, "fins", IDENT, true)
            for _, s in ipairs({1, -1}) do
                P(fins, "block", V3(0.6, 0.08, 0.04), CF(s * 0.88, 0.38, 0.3) * ANG(0, 0, s * rad(25)), cyan, M.Neon)
                P(fins, "block", V3(0.45, 0.06, 0.04), CF(s * 0.82, 0.12, 0.3) * ANG(0, 0, s * rad(12)), mag, M.Neon)
            end
        end,
        anim = function(R, t)
            R.pose.core = CF(0, 0.04 * sin(t * 3), 0) * ANG(0, 0, t * 1.5)
            R.pose.fins = CF(0, 0.05 * sin(t * 2.4), 0)
        end})

    -- =========================== ПЛАЩИ ===========================
    local CAPE_N, CAPE_H = 9, 0.36
    local function buildCape(R, o)
        R.data.N, R.data.H = CAPE_N, CAPE_H
        for i = 0, CAPE_N - 1 do
            local g = G(R, "c" .. i, IDENT, true)
            local w = 2.05 + i * 0.05
            local p = P(g, "block", V3(w, CAPE_H + 0.03, 0.05), CF(0, -CAPE_H / 2, 0), o.lining)
            if not tex(p, o.tex, o.su or w, o.sv or CAPE_H, nil, {BACK}, nil, o.continuous and (i * CAPE_H) or nil) then
                p.Color = o.fb
            end
            if i == CAPE_N - 1 then
                P(g, "block", V3(w + 0.02, 0.08, 0.08), CF(0, -CAPE_H, 0), o.trim, o.trimMat or M.SmoothPlastic, {Reflectance = 0.2})
            end
            if o.sparkle and i % 3 == 1 then sparkles(p, o.sparkle, 1.5, 0.15) end
        end
        local cl = G(R, "clasp")
        for _, s in ipairs({1, -1}) do
            P(cl, "ball", V3(0.2, 0.2, 0.2), CF(s * 0.62, -0.02, -0.04), o.clasp, M.SmoothPlastic, {Reflectance = 0.4})
        end
        seg(cl, V3(-0.6, -0.05, -0.08), V3(0.6, -0.05, -0.08), 0.04, o.clasp, M.SmoothPlastic, {Reflectance = 0.4})
        return cl
    end
    local function capeAnim(R, t, dt, ctx)
        local target = math.clamp(ctx.speed / 22, 0, 1)
        if ctx.air then target = math.max(target, 0.55) end
        local s = smoothTo(R, "sp", target, dt, 3)
        local cf = ANG(-(0.06 + s * 0.6), 0, 0)
        for i = 0, (R.data.N or CAPE_N) - 1 do
            R.pose["c" .. i] = cf
            local wave = sin(t * (2.2 + s * 4) - i * 0.6) * (0.02 + 0.07 * s) * (0.4 + i / 8)
            cf = cf * CF(0, -(R.data.H or CAPE_H), 0) * ANG(0.012 - s * 0.05 - wave, 0, 0.015 * sin(t * 1.7 - i * 0.4))
        end
    end

    D({id = "royal_cape", name = "Royal Cape", cat = "Capes", anchor = "cape", view = "back",
        desc = "Бархат с дамаском, золотая кайма, мех горностая",
        build = function(R)
            local cl = buildCape(R, {tex = "cape_royal", lining = C3(200, 160, 60), fb = C3(140, 15, 30), trim = GOLD, clasp = GOLD})
            local col = P(cl, "cyl", V3(2.2, 0.3, 0.3), CF(0, -0.02, 0.02), C3(250, 250, 250), M.Fabric)
            tex(col, "fur", 0.3, 0.3)
            for i = -2, 2 do P(cl, "block", V3(0.05, 0.08, 0.03), CF(i * 0.38, -0.05, 0.17), C3(20, 20, 20)) end
        end,
        anim = capeAnim})

    D({id = "galaxy_cape", name = "Galaxy Cape", cat = "Capes", anchor = "cape", view = "back",
        desc = "Плащ из звёздного неба с неоновой каймой",
        build = function(R)
            buildCape(R, {tex = "galaxy", su = 1.4, sv = 1.4, continuous = true, lining = C3(25, 10, 45), fb = C3(45, 20, 90),
                trim = C3(170, 100, 255), trimMat = M.Neon, clasp = C3(190, 160, 255), sparkle = C3(210, 180, 255)})
        end,
        anim = capeAnim})

    -- ---------- монтаж на персонажа ----------
    local function charAnchor(char, kind)
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if kind == "hat" then
            local head = char:FindFirstChild("Head")
            if not head then return nil end
            local top = head.Size.Y * 0.5
            local sm = head:FindFirstChildOfClass("SpecialMesh")
            if sm then top *= sm.Scale.Y end
            return head, CF(0, top - 0.1, 0)
        end
        if not torso then return nil end
        local sz = torso.Size
        if kind == "cape" then return torso, CF(0, sz.Y / 2 - 0.05, sz.Z / 2 + 0.04) end
        return torso, CF(0, sz.Y * 0.15, sz.Z / 2)
    end

    local function rigParts(R)
        local out = {}
        for _, g in ipairs(R.list) do for _, it in ipairs(g.items) do table.insert(out, it.p) end end
        return out
    end
    function Cos.newRig(def)
        local R = {groups = {}, list = {}, pose = {}, data = {}, t = 0, def = def}
        def.build(R)
        return R
    end
    function Cos.placeRig(R, root, onlyAnimated)
        for _, g in ipairs(R.list) do
            if g.animated or not onlyAnimated then
                local gcf = root * g.base * (R.pose[g.name] or IDENT)
                for _, it in ipairs(g.items) do it.p.CFrame = gcf * it.off end
            end
        end
    end

    local function newWeld(p0, p1, c0)
        local w = Instance.new("Weld")
        w.Part0 = p0
        w.Part1 = p1
        w.C0 = c0
        w.Parent = p1
        return w
    end
    local function mountAttached(e, char)
        local body, acf = charAnchor(char, e.def.anchor)
        if not body then return false end
        local model = Instance.new("Model")
        model.Name = "WC_Cos_" .. e.def.id
        for _, g in ipairs(e.R.list) do
            if g.animated then
                local pv = Instance.new("Part")
                pv.Name = "Pivot"
                pv.Size = V3(0.05, 0.05, 0.05)
                pv.Transparency = 1
                pv.CanCollide = false; pv.CanQuery = false; pv.CanTouch = false; pv.Massless = true; pv.CastShadow = false
                pv.CFrame = body.CFrame * acf * g.base
                pv.Parent = model
                g.weld = newWeld(body, pv, acf * g.base)
                for _, it in ipairs(g.items) do
                    it.p.Anchored = false
                    it.p.CFrame = pv.CFrame * it.off
                    newWeld(pv, it.p, it.off)
                    it.p.Parent = model
                end
            else
                for _, it in ipairs(g.items) do
                    it.p.Anchored = false
                    it.p.CFrame = body.CFrame * acf * g.base * it.off
                    newWeld(body, it.p, acf * g.base * it.off)
                    it.p.Parent = model
                end
            end
        end
        e.body, e.acf, e.model = body, acf, model
        model.Parent = char
        return true
    end

    local function ensureFolder()
        if not Cos.folder or not Cos.folder.Parent then
            Cos.folder = Instance.new("Folder")
            Cos.folder.Name = "WCCosmetics"
            Cos.folder.Parent = Workspace
        end
        return Cos.folder
    end

    local function destroyEntry(e)
        if not e then return end
        if e.model then pcall(function() e.model:Destroy() end) end
        for _, p in ipairs(rigParts(e.R)) do pcall(function() p:Destroy() end) end
    end
    -- собрать косметику id на персонаже char (свой или чужой)
    local function buildEntry(id, char)
        local def = Cos.byId[id]
        if not def or not char or ScriptUnloaded then return nil end
        local ok, R = pcall(Cos.newRig, def)
        if not ok then warn("[wannacry] cosmetic " .. id .. ": " .. tostring(R)); return nil end
        local e = {def = def, R = R, id = id, char = char}
        if def.anchor == "pet" then
            local model = Instance.new("Model")
            model.Name = "WC_Pet_" .. id
            for _, p in ipairs(rigParts(R)) do p.Parent = model end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                e.pos = hrp.Position + V3(0, 2, 2)
                Cos.placeRig(R, CF(e.pos), false)
            end
            model.Parent = ensureFolder()
            e.model = model
        elseif not mountAttached(e, char) then
            destroyEntry(e)
            return nil
        end
        return e
    end
    function Cos.unmount(id)
        local e = Cos.active[id]
        if not e then return end
        Cos.active[id] = nil
        destroyEntry(e)
    end
    function Cos.unmountAll()
        for id in pairs(Cos.active) do Cos.unmount(id) end
    end
    function Cos.mount(id)
        local char = player.Character
        if not Cos.byId[id] or not char or ScriptUnloaded then return end
        Cos.unmount(id)
        local e = buildEntry(id, char)
        if e then Cos.active[id] = e end
    end

    -- ---------- косметика других юзеров скрипта (с сервера-хаба) ----------
    -- Cos.remote[userId] = {player, char, want = {id=true}, entries = {id=e}, body = {}, tag}
    Cos.remote = {}
    -- метка «wannacry» над головой: 2D-плашка на оверлее, позиция считается каждый кадр
    -- общей проекцией (учитывает Aspect) — стоит ровно над персонажем, не «съезжает».
    -- Снизу 26 px оставлены под ESP-ник.
    local function makeTag(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local head = char:FindFirstChild("Head")
        local top = 2.5
        if head and head:IsA("BasePart") then
            top = (head.Position.Y + head.Size.Y / 2) - hrp.Position.Y
        end
        top = math.clamp(top, 1.2, 10)
        local pill = Instance.new("Frame")
        pill.Name = "WC_UserTag"
        pill.Size = UDim2.fromOffset(0, 22)
        pill.AutomaticSize = Enum.AutomaticSize.X
        pill.BackgroundColor3 = C3(18, 18, 26)
        pill.BackgroundTransparency = 0.25
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = pill
        local st = Instance.new("UIStroke"); st.Color = C3(190, 160, 255); st.Transparency = 0.45; st.Thickness = 1; st.Parent = pill
        local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 9); pad.Parent = pill
        local lay = Instance.new("UIListLayout")
        lay.FillDirection = Enum.FillDirection.Horizontal
        lay.VerticalAlignment = Enum.VerticalAlignment.Center
        lay.Padding = UDim.new(0, 5)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Parent = pill
        local ic = WC_ICON.make("sparkles", {Size = UDim2.fromOffset(14, 14), ImageColor3 = C3(205, 180, 255), LayoutOrder = 1})
        ic.Parent = pill
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.fromOffset(0, 22)
        l.AutomaticSize = Enum.AutomaticSize.X
        l.Text = "wannacry"
        l.TextColor3 = C3(225, 212, 255)
        l.TextSize = 13
        l.Font = Enum.Font.GothamBold
        l.LayoutOrder = 2
        l.Parent = pill
        return WC_PROJ.attach(pill, hrp, top + 0.25, 26, 120)
    end
    local function dropRemoteVisuals(r)
        for id, e in pairs(r.entries) do destroyEntry(e); r.entries[id] = nil end
        if r.tag then pcall(function() r.tag:Destroy() end); r.tag = nil end
        if Features.applyBodyTo then pcall(Features.applyBodyTo, nil, r.body, false, false) end
    end
    function Cos.syncRemote(r)
        if ScriptUnloaded then return end
        local char = r.player and r.player.Character
        if char ~= r.char then
            dropRemoteVisuals(r)
            r.char = char
            r.bodySig = nil
        end
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        for id, e in pairs(r.entries) do
            if not r.want[id] then destroyEntry(e); r.entries[id] = nil end
        end
        for id in pairs(r.want) do
            if not r.entries[id] then
                local e = buildEntry(id, char)
                if e then r.entries[id] = e end
            end
        end
        if not r.tag or not r.tag.Parent then
            local ok, tag = pcall(makeTag, char)
            if ok then r.tag = tag else warn("[wannacry] tag: " .. tostring(tag)) end
        end
        local sig = tostring(r.korblox) .. tostring(r.headless)
        if sig ~= r.bodySig and Features.applyBodyTo then
            r.bodySig = sig
            pcall(Features.applyBodyTo, char, r.body, r.korblox, r.headless)
        end
    end
    function Cos.setRemote(plr, ids, korblox, headless)
        if not plr or plr == player then return end
        local r = Cos.remote[plr.UserId]
        if not r then
            r = {player = plr, want = {}, entries = {}, body = {}}
            Cos.remote[plr.UserId] = r
        end
        local want, n = {}, 0
        for _, id in ipairs(ids or {}) do
            if type(id) == "string" and Cos.byId[id] and n < 12 then want[id] = true; n += 1 end
        end
        r.want, r.korblox, r.headless = want, korblox == true, headless == true
        Cos.syncRemote(r)
    end
    function Cos.clearRemote(uid)
        local r = Cos.remote[uid]
        if not r then return end
        Cos.remote[uid] = nil
        dropRemoteVisuals(r)
    end
    function Cos.clearAllRemote()
        for uid in pairs(Cos.remote) do Cos.clearRemote(uid) end
    end
    function Cos.refreshAll()
        Cos.unmountAll()
        if ScriptUnloaded then return end
        for _, d in ipairs(Cos.list) do
            if State.Cos[d.id] then Cos.mount(d.id) end
        end
    end

    -- ---------- надеть / снять ----------
    local SAVE_FILE = "WannacryAssets/cosmetics_v1.json"
    local HttpService = game:GetService("HttpService")
    function Cos.save()
        if type(writefile) ~= "function" then return end
        pcall(function()
            local ids = {}
            for id, on in pairs(State.Cos) do if on then table.insert(ids, id) end end
            writefile(SAVE_FILE, HttpService:JSONEncode(ids))
        end)
    end
    function Cos.load()
        if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
        pcall(function()
            if not isfile(SAVE_FILE) then return end
            local ids = HttpService:JSONDecode(readfile(SAVE_FILE))
            for _, id in ipairs(ids) do if Cos.byId[id] then State.Cos[id] = true end end
        end)
    end
    Cos.petOrder = {}
    function Cos.setEquipped(id, on)
        local def = Cos.byId[id]
        if not def then return end
        if on then
            if def.cat == "Pets" then
                table.insert(Cos.petOrder, id)
                local n = 0
                for _, d in ipairs(Cos.list) do if d.cat == "Pets" and State.Cos[d.id] and d.id ~= id then n += 1 end end
                if n >= 3 then
                    for _, old in ipairs(Cos.petOrder) do
                        if old ~= id and State.Cos[old] then State.Cos[old] = nil; Cos.unmount(old); break end
                    end
                end
            else
                for _, d in ipairs(Cos.list) do
                    if d.cat == def.cat and d.id ~= id and State.Cos[d.id] then State.Cos[d.id] = nil; Cos.unmount(d.id) end
                end
            end
            State.Cos[id] = true
            task.spawn(function()
                Tex.await()
                if State.Cos[id] and not ScriptUnloaded and not Cos.active[id] then Cos.mount(id) end
            end)
        else
            State.Cos[id] = nil
            for i = #Cos.petOrder, 1, -1 do if Cos.petOrder[i] == id then table.remove(Cos.petOrder, i) end end
            Cos.unmount(id)
        end
        Cos.save()
        if Cos.onChanged then pcall(Cos.onChanged) end
    end
    function Cos.unequipAll()
        for id in pairs(State.Cos) do State.Cos[id] = nil end
        Cos.unmountAll()
        Cos.save()
        if Cos.onChanged then pcall(Cos.onChanged) end
    end
    function Cos.equippedCount()
        local n = 0
        for _, on in pairs(State.Cos) do if on then n += 1 end end
        return n
    end

    -- ---------- кадр: анимация + питомцы ----------
    local PET_SLOTS = {V3(2.6, 1.3, 2.2), V3(-2.6, 1.3, 2.2), V3(0, 2.6, 3.4)}
    local ctx = {speed = 0, air = false}
    Cos.ctx = ctx
    local function readCtx(c, char, isLocal)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v = hrp.AssemblyLinearVelocity
            c.speed = V3(v.X, 0, v.Z).Magnitude
            if isLocal then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local st = hum and hum:GetState()
                c.air = State.FlyEnabled or st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Flying
            else
                c.air = abs(v.Y) > 3
            end
        else
            c.speed, c.air = 0, false
        end
        return hrp
    end
    local function stepEntries(entries, hrp, c, dt, bulkP, bulkC)
        local petIdx = 0
        for _, def in ipairs(Cos.list) do
            local e = entries[def.id]
            if e then
                local R = e.R
                R.t += dt
                if def.anim then pcall(def.anim, R, R.t, dt, c) end
                if def.anchor == "pet" then
                    petIdx += 1
                    if hrp then
                        local slot = PET_SLOTS[petIdx] or PET_SLOTS[1]
                        local target = (hrp.CFrame * CF(slot)).Position + V3(0, sin(R.t * 2 + petIdx) * 0.22, 0)
                        if not e.pos or (e.pos - target).Magnitude > 60 then e.pos = target end
                        e.pos = e.pos:Lerp(target, 1 - math.exp(-dt * 6))
                        local look = hrp.CFrame.LookVector
                        local tyaw = math.atan2(-look.X, -look.Z)
                        e.yaw = e.yaw or tyaw
                        local d = (tyaw - e.yaw + PI) % TAU - PI
                        e.yaw += d * (1 - math.exp(-dt * 8))
                        local tilt = -math.clamp(c.speed / 40, 0, 0.3)
                        local pcf = CF(e.pos) * ANG(0, e.yaw, 0) * ANG(tilt, 0, 0)
                        for _, g in ipairs(R.list) do
                            local gcf = pcf * g.base * (R.pose[g.name] or IDENT)
                            for _, it in ipairs(g.items) do
                                bulkP[#bulkP + 1] = it.p
                                bulkC[#bulkC + 1] = gcf * it.off
                            end
                        end
                    end
                elseif e.body and e.body.Parent then
                    for _, g in ipairs(R.list) do
                        if g.weld then g.weld.C0 = e.acf * g.base * (R.pose[g.name] or IDENT) end
                    end
                end
            end
        end
    end
    local rctx = {speed = 0, air = false}
    connect(RunService.RenderStepped, function(dt)
        if ScriptUnloaded then return end
        local bulkP, bulkC = {}, {}
        if next(Cos.active) ~= nil then
            local hrp = readCtx(ctx, player.Character, true)
            stepEntries(Cos.active, hrp, ctx, dt, bulkP, bulkC)
        end
        for _, r in pairs(Cos.remote) do
            local char = r.player and r.player.Character
            if char ~= r.char then
                task.defer(Cos.syncRemote, r)
            elseif next(r.entries) ~= nil then
                local hrp = readCtx(rctx, char, false)
                stepEntries(r.entries, hrp, rctx, dt, bulkP, bulkC)
            end
        end
        if #bulkP > 0 then
            pcall(function() Workspace:BulkMoveTo(bulkP, bulkC, Enum.BulkMoveMode.FireCFrameChanged) end)
        end
    end)

    -- ---------- превью ----------
    local PREVIEW_ROOT = {back = CF(0, 0.3, 0.5), cape = CF(0, 0.95, 0.54), hat = CF(0, 2.03, 0), pet = IDENT}
    function Cos.previewCtx(def)
        return {speed = (def.cat == "Capes") and 9 or 0, air = (def.cat == "Wings")}
    end
    function Cos.mannequin(parent)
        local col = C3(196, 202, 216)
        local g = {items = {}}
        local props = {Transparency = 0.2}
        P(g, "block", V3(2, 2, 1), CF(0, 0, 0), col, M.SmoothPlastic, props)
        P(g, "ball", V3(1.25, 1.25, 1.25), CF(0, 1.5, 0), col, M.SmoothPlastic, props)
        for _, s in ipairs({1, -1}) do
            P(g, "block", V3(1, 2, 1), CF(s * 1.5, 0, 0), col, M.SmoothPlastic, props)
            P(g, "block", V3(1, 2, 1), CF(s * 0.5, -2, 0), col, M.SmoothPlastic, props)
        end
        for _, it in ipairs(g.items) do it.p.CFrame = it.off; it.p.Parent = parent end
    end
    function Cos.buildPreview(def, parent, withMannequin)
        local R = Cos.newRig(def)
        local model = Instance.new("Model")
        model.Name = "Preview_" .. def.id
        for _, p in ipairs(rigParts(R)) do p.Anchored = true; p.Parent = model end
        local root = PREVIEW_ROOT[def.anchor] or IDENT
        if def.anim then pcall(def.anim, R, 0.7, 0, Cos.previewCtx(def)) end
        Cos.placeRig(R, root, false)
        if withMannequin and def.anchor ~= "pet" then Cos.mannequin(model) end
        model.Parent = parent
        return R, model, root
    end
    function Cos.frame(model)
        local ok, cf, size = pcall(function() return model:GetBoundingBox() end)
        if not ok then return Vector3.zero, 4 end
        return cf.Position, math.max(size.Magnitude * 0.5, 0.8)
    end
    function Cos.cameraCF(center, radius, yaw, pitch, fov)
        local dist = radius / math.tan(math.rad(fov / 2)) * 1.08
        local off = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0) * V3(0, 0, dist)
        return CFrame.lookAt(center + off, center)
    end
end)() end
-- ================= ВКЛАДКА COSMETICS =================
local CosmeticsScroll = makeScrollPage(CosmeticsTab)
do (function()
    local CAT_RU = {Wings = "Крылья", Hats = "Шапки", Pets = "Питомцы", Backpacks = "Рюкзаки", Capes = "Плащи"}
    local CAT_ORDER = {"Все", "Крылья", "Шапки", "Питомцы", "Рюкзаки", "Плащи"}
    local FOV = 34

    -- ---------- ТЕЛО: Korblox / Headless (без превью) ----------
    makeSection(CosmeticsScroll, "ТЕЛО")
    createCard(CosmeticsScroll, {title = "Korblox", desc = "Правая нога — чёрная игла с синим кончиком", key = "KorbloxEnabled",
        onToggle = function(v) Features.applyKorblox(v) end})
    createCard(CosmeticsScroll, {title = "Headless", desc = "Убирает голову и лицо (аксессуары остаются)", key = "HeadlessEnabled",
        onToggle = function(v) Features.applyHeadless(v) end})

    makeSection(CosmeticsScroll, "КОСМЕТИКА  ·  " .. #Cos.list .. " ПРЕДМЕТОВ")

    -- ---------- большое превью ----------
    local FP = {def = nil, R = nil, model = nil, root = CFrame.identity, yaw = 0.5, pitch = -0.18, center = Vector3.zero, radius = 4, dragging = false, ctx = nil}
    local feat = new("Frame", {Size = UDim2.new(1, -4, 0, 260), LayoutOrder = nextOrder(), Parent = CosmeticsScroll})
    soft(feat, {radius = 20, transparency = 0.95})
    local pv = new("Frame", {Position = UDim2.fromOffset(10, 10), Size = UDim2.new(0.56, -10, 1, -20), ClipsDescendants = true, ZIndex = 2, Parent = feat})
    soft(pv, {radius = 16, transparency = 0.965, sheen = false})
    new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 130, 170)), Parent = pv})
    local vp = new("ViewportFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Ambient = Color3.fromRGB(165, 170, 190),
        LightColor = Glass.White, LightDirection = Vector3.new(-0.4, -1, -0.7), ZIndex = 3, Parent = pv,
    })
    local cam = new("Camera", {FieldOfView = FOV, Parent = vp})
    vp.CurrentCamera = cam
    local loadingL = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Генерация текстур…", FontFace = F.Medium, TextSize = 13, TextColor3 = Glass.TextMute, ZIndex = 4, Parent = pv})
    local hint3 = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.fromOffset(170, 22),
        Text = "Потяни, чтобы повернуть", FontFace = F.Medium, TextSize = 11, TextColor3 = Glass.Text, ZIndex = 5, Parent = pv,
    })
    liquid(hint3, {radius = "full", transparency = 0.9, sheen = false, glint = false, lens = false})

    local info = new("Frame", {Position = UDim2.new(0.56, 8, 0, 14), Size = UDim2.new(0.44, -22, 1, -28), BackgroundTransparency = 1, ZIndex = 2, Parent = feat})
    local nameL = new("TextLabel", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "—", FontFace = F.Bold, TextSize = 19, TextColor3 = Glass.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = info})
    local chip = new("TextLabel", {Position = UDim2.fromOffset(0, 32), Size = UDim2.fromOffset(84, 22), Text = "", FontFace = F.Semi, TextSize = 11, TextColor3 = Glass.Text, ZIndex = 3, Parent = info})
    liquid(chip, {radius = "full", transparency = 0.86, sheen = false, glint = false, lens = false})
    local descL = new("TextLabel", {Position = UDim2.fromOffset(0, 62), Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1, Text = "", FontFace = F.Regular, TextSize = 12, TextColor3 = Glass.TextDim, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 3, Parent = info})
    local eqRow = new("Frame", {Position = UDim2.fromOffset(0, 124), Size = UDim2.new(1, 0, 0, 40), ZIndex = 3, Parent = info})
    soft(eqRow, {radius = 14, transparency = 0.94, sheen = false})
    new("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Text = "Надеть", FontFace = F.Semi, TextSize = 14, TextColor3 = Glass.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = eqRow})
    local eqSwitch
    eqSwitch = makeSwitch(eqRow, false, function(v)
        if FP.def then Cos.setEquipped(FP.def.id, v) end
    end, UDim2.new(1, -6, 0.5, 0))
    local countL = new("TextLabel", {Position = UDim2.fromOffset(2, 172), Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "Надето: 0", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.TextMute, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = info})
    local offAll = glassButton(info, "Снять всё", {Position = UDim2.fromOffset(0, 198), Size = UDim2.fromOffset(110, 30), ZIndex = 4},
        {radius = "full", transparency = 0.9, textColor = Color3.fromRGB(255, 150, 140)})
    offAll.MouseButton1Click:Connect(guarded(function() Cos.unequipAll(); SFX.play("off") end))

    local function updateCam()
        cam.CFrame = Cos.cameraCF(FP.center, FP.radius, FP.yaw, FP.pitch, FOV)
    end
    local function showFeatured(def)
        if FP.model then FP.model:Destroy(); FP.model = nil end
        FP.def, FP.R = def, nil
        nameL.Text = def.name
        chip.Text = CAT_RU[def.cat] or def.cat
        descL.Text = def.desc or ""
        eqSwitch.set(State.Cos[def.id] == true, true)
        task.spawn(function()
            Tex.await()
            if FP.def ~= def or ScriptUnloaded then return end
            local ok, R, model, root = pcall(Cos.buildPreview, def, vp, true)
            if not ok then warn("[wannacry] preview: " .. tostring(R)); return end
            if FP.def ~= def then model:Destroy(); return end
            loadingL.Visible = false
            FP.R, FP.model, FP.root, FP.ctx = R, model, root, Cos.previewCtx(def)
            FP.center, FP.radius = Cos.frame(model)
            FP.yaw = (def.view == "front") and (math.pi + 0.5) or 0.5
            updateCam()
        end)
    end

    vp.InputBegan:Connect(function(i)
        if isPress(i) then FP.dragging = true; UI.dragLock = true; FP.last = pointerPos(i) end
    end)
    connect(UserInputService.InputChanged, function(i)
        if not FP.dragging or not isMove(i) then return end
        local cur = pointerPos(i)
        local d = cur - FP.last
        FP.last = cur
        FP.yaw -= d.X * 0.012
        FP.pitch = math.clamp(FP.pitch - d.Y * 0.01, -1.2, 1.0)
        updateCam()
    end)
    connect(UserInputService.InputEnded, function(i)
        if FP.dragging and isPress(i) then FP.dragging = false; UI.dragLock = false end
    end)

    -- ---------- фильтр ----------
    local tiles = {}
    local function applyFilter(catRu)
        for _, t in ipairs(tiles) do
            t.frame.Visible = (catRu == "Все") or (CAT_RU[t.def.cat] == catRu)
        end
    end
    makeSegmented(CosmeticsScroll, "Категория", CAT_ORDER, "Все", function(opt) applyFilter(opt) end)

    -- ---------- сетка карточек ----------
    local grid = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = CosmeticsScroll})
    new("UIGridLayout", {CellSize = UDim2.new(1 / 3, -6, 0, 152), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid})
    local selected, hovered = nil, nil
    local function refreshTiles()
        for _, t in ipairs(tiles) do
            local on = State.Cos[t.def.id] == true
            t.badge.Visible = on
            tw(t.stroke, 0.25, {Transparency = (selected == t) and 0.05 or 0.75, Thickness = (selected == t) and 2 or 1})
        end
        countL.Text = "Надето: " .. Cos.equippedCount()
        if FP.def then eqSwitch.set(State.Cos[FP.def.id] == true, true) end
    end
    Cos.onChanged = refreshTiles

    for i, def in ipairs(Cos.list) do
        local f = new("TextButton", {Text = "", AutoButtonColor = false, LayoutOrder = i, ClipsDescendants = true, Parent = grid})
        soft(f, {radius = 16, transparency = 0.95})
        local stroke = new("UIStroke", {Color = Glass.White, Thickness = 1, Transparency = 0.75, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f})
        local sc = new("UIScale", {Parent = f})
        local tv = new("ViewportFrame", {
            Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 104), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.96,
            Ambient = Color3.fromRGB(165, 170, 190), LightColor = Glass.White, LightDirection = Vector3.new(-0.4, -1, -0.7), ZIndex = 2, Parent = f,
        })
        corner(tv, 12)
        local tcam = new("Camera", {FieldOfView = FOV, Parent = tv})
        tv.CurrentCamera = tcam
        local wait = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "…", FontFace = F.Bold, TextSize = 18, TextColor3 = Glass.TextMute, ZIndex = 3, Parent = tv})
        new("TextLabel", {Position = UDim2.fromOffset(10, 113), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1, Text = def.name, FontFace = F.Semi, TextSize = 13, TextColor3 = Glass.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = f})
        new("TextLabel", {Position = UDim2.fromOffset(10, 130), Size = UDim2.new(1, -20, 0, 14), BackgroundTransparency = 1, Text = CAT_RU[def.cat] or def.cat, FontFace = F.Medium, TextSize = 11, TextColor3 = Glass.TextMute, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = f})
        local badge = new("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(22, 22), Text = "", BackgroundColor3 = Glass.Green, BackgroundTransparency = 0.1, Visible = false, ZIndex = 5, Parent = f})
        corner(badge, "full")
        WC_ICON.make("check", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), ZIndex = 6, Parent = badge})
        local t = {def = def, frame = f, stroke = stroke, badge = badge, vp = tv, cam = tcam, wait = wait, yaw = (def.view == "front") and (math.pi + 0.5) or 0.5, center = Vector3.zero, radius = 3, built = false}
        tiles[i] = t
        local lastClick = 0
        f.MouseEnter:Connect(function() hovered = t; tw(sc, 0.25, {Scale = 1.03}, Enum.EasingStyle.Back) end)
        f.MouseLeave:Connect(function() if hovered == t then hovered = nil end; tw(sc, 0.2, {Scale = 1}) end)
        f.MouseButton1Click:Connect(guarded(function()
            local now = os.clock()
            if selected == t and now - lastClick < 0.35 then
                Cos.setEquipped(def.id, not State.Cos[def.id])
                SFX.play(State.Cos[def.id] and "on" or "off")
            end
            lastClick = now
            if selected ~= t then
                selected = t
                showFeatured(def)
            end
            refreshTiles()
        end))
        f.MouseButton2Click:Connect(function()
            Cos.setEquipped(def.id, not State.Cos[def.id])
            SFX.play(State.Cos[def.id] and "on" or "off")
        end)
    end

    -- мини-превью строятся по одному за кадр, когда текстуры готовы
    task.spawn(function()
        Tex.await()
        for _, t in ipairs(tiles) do
            if ScriptUnloaded then return end
            local ok, R, model = pcall(Cos.buildPreview, t.def, t.vp, false)
            if ok then
                t.center, t.radius = Cos.frame(model)
                t.cam.CFrame = Cos.cameraCF(t.center, t.radius, t.yaw, -0.2, FOV)
                t.wait.Visible = false
                t.built = true
            else
                t.wait.Text = "×"
                warn("[wannacry] tile " .. t.def.id .. ": " .. tostring(R))
            end
            task.wait()
        end
    end)

    connect(RunService.RenderStepped, function(dt)
        if ScriptUnloaded or not isOpen or not CosmeticsTab.Visible then return end
        if FP.R then
            FP.R.t += dt
            if FP.def.anim then pcall(FP.def.anim, FP.R, FP.R.t, dt, FP.ctx) end
            Cos.placeRig(FP.R, FP.root, true)
            if not FP.dragging then FP.yaw += dt * 0.35 end
            updateCam()
        end
        if hovered and hovered.built then
            hovered.yaw += dt * 1.4
            hovered.cam.CFrame = Cos.cameraCF(hovered.center, hovered.radius, hovered.yaw, -0.2, FOV)
        end
    end)

    selected = tiles[1]
    showFeatured(Cos.list[1])
    refreshTiles()
end)() end
-- ================= ВКЛАДКА COMMUNITY =================
-- Global Chat — твой сервер чата (тот же протокол /send, /poll, что в Global_chat.luau).
-- «На сервере» и Admin Chat — Wispbyte-хаб (wannacry-hub/index.js): кто из этого
-- сервера Roblox юзает скрипт + синхронизация косметики, и закрытый чат админов.
do (function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local NET = WC_NET
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    local isAdmin = table.find(NET.admins, player.Name) ~= nil
    local TOKEN = ""
    pcall(function()
        if isfile and isfile("chat_token.txt") then TOKEN = readfile("chat_token.txt"):gsub("%s+", "") end
    end)

    -- ---------- сеть ----------
    local function call(base, key, method, path, query, body)
        if not req or not base or base == "" then return nil, {} end
        local ok, res = pcall(req, {
            Url = base .. path .. "?key=" .. key .. (query or ""),
            Method = method,
            Headers = {["Content-Type"] = "application/json"},
            Body = body and HttpService:JSONEncode(body) or nil,
        })
        if not ok or type(res) ~= "table" then return nil, {} end
        local okd, data = pcall(HttpService.JSONDecode, HttpService, res.Body or "")
        return res.StatusCode, (okd and type(data) == "table") and data or {}
    end
    local function chatApi(...) return call(NET.chatUrl, NET.chatKey, ...) end
    local function hubApi(...) return call(NET.hubUrl, NET.hubKey, ...) end
    local function enc(s) return HttpService:UrlEncode(tostring(s)) end
    local function esc(s)
        s = tostring(s or "")
        s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
        return s
    end
    local function nameColor(n)
        local h = 0
        for i = 1, #n do h = (h * 31 + n:byte(i)) % 360 end
        return Color3.fromHSV(h / 360, 0.5, 1)
    end
    local function hex(c)
        return ("#%02x%02x%02x"):format(math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
    end
    local function tillText(t)
        if not t or t == 0 then return "навсегда" end
        return "до " .. os.date("%H:%M %d.%m", math.floor(t / 1000))
    end
    local function stamp(t)
        return '<font color="#8a8fa8">' .. os.date("%H:%M", t and math.floor(t / 1000) or os.time()) .. "</font>  "
    end

    -- ---------- каркас вкладки ----------
    local subs = {{id = "global", text = "Global Chat"}, {id = "server", text = "На сервере"}, {id = "admin", text = "Admin"}}
    local curSub = "global"
    local bar = new("Frame", {Size = UDim2.new(1, -8, 0, 38), BackgroundTransparency = 1, Parent = CommunityTab})
    local statusL = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2), Size = UDim2.fromOffset(150, 34), BackgroundTransparency = 1,
        RichText = true, Text = "", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = bar,
    })
    local body = new("Frame", {Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, -6, 1, -48), BackgroundTransparency = 1, Parent = CommunityTab})
    local pages, subBtns = {}, {}
    local unread = {global = 0, admin = 0}
    local refreshStatus

    -- значок непрочитанных на кнопке вкладки в сайдбаре
    local tabBadge = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 18),
        BackgroundColor3 = Color3.fromRGB(255, 90, 110), BackgroundTransparency = 0.1, Text = "", FontFace = F.Bold, TextSize = 11,
        TextColor3 = Glass.White, Visible = false, ZIndex = 5, Parent = TabButtons.Community.button,
    })
    corner(tabBadge, "full")
    local function updateBadges()
        local total = unread.global + unread.admin
        tabBadge.Visible = total > 0
        tabBadge.Text = total > 99 and "99+" or tostring(total)
        for _, sdef in ipairs(subs) do
            local sb = subBtns[sdef.id]
            local n = unread[sdef.id] or 0
            sb.l.Text = sdef.text .. ((n > 0) and ("  · " .. n) or "")
        end
    end
    local function subVisible(id)
        return isOpen and CommunityTab.Visible and curSub == id
    end
    local function showSub(id)
        curSub = id
        for sid, pg in pairs(pages) do pg.Visible = (sid == id) end
        for sid, sb in pairs(subBtns) do
            tw(sb.l, 0.2, {TextColor3 = (sid == id) and Glass.Text or Glass.TextMute})
            sb.l.FontFace = (sid == id) and F.Bold or F.Semi
        end
        if unread[id] then unread[id] = 0 end
        updateBadges()
        if refreshStatus then refreshStatus() end
    end
    for i, sdef in ipairs(subs) do
        local b, l = glassButton(bar, sdef.text, {Position = UDim2.fromOffset((i - 1) * 126, 2), Size = UDim2.fromOffset(118, 34)},
            {radius = "full", transparency = 0.92, textSize = 12})
        subBtns[sdef.id] = {b = b, l = l}
        pages[sdef.id] = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = body})
        b.MouseButton1Click:Connect(guarded(function() showSub(sdef.id) end))
    end
    subBtns.admin.b.Visible = isAdmin
    -- при открытии вкладки сбросить непрочитанные текущего чата
    CommunityTab:GetPropertyChangedSignal("Visible"):Connect(function()
        if CommunityTab.Visible and unread[curSub] then unread[curSub] = 0; updateBadges() end
    end)

    -- ---------- переиспользуемое окно чата ----------
    local function makeChatView(parent, placeholder, onSubmit)
        local v = {msgs = {}, ids = {}, order = 0, localId = 0}
        local pin = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(255, 196, 70), BackgroundTransparency = 0.82,
            RichText = true, Text = "", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.Text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Visible = false, Parent = parent,
        })
        corner(pin, 12)
        new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = pin})
        local scroll = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, -52), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Glass.White, ScrollBarImageTransparency = 0.6,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = parent,
        })
        new("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4), Parent = scroll})
        new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll})
        local inputF = new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 44), Parent = parent})
        liquid(inputF, {radius = "full", transparency = 0.9, glint = false})
        local box = new("TextBox", {
            Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -66, 1, 0), BackgroundTransparency = 1,
            Text = "", PlaceholderText = placeholder, PlaceholderColor3 = Glass.TextMute, TextColor3 = Glass.Text,
            FontFace = F.Medium, TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true, ZIndex = 5, Parent = inputF,
        })
        local sendB = glassButton(inputF, "", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.fromOffset(36, 36), ZIndex = 6},
            {radius = "full", transparency = 0.8, textSize = 15})
        WC_ICON.make("send", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), ImageColor3 = Glass.Text, ZIndex = 7, Parent = sendB})
        v.box = box

        local function nearBottom()
            local maxY = scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y
            return scroll.CanvasPosition.Y >= maxY - 40
        end
        function v.scrollDown() scroll.CanvasPosition = Vector2.new(0, 1e7) end
        function v.setPinned(text)
            if text and text ~= "" then
                pin.Visible = true
                pin.Text = "📌 " .. esc(text)
                scroll.Position = UDim2.fromOffset(0, 34)
                scroll.Size = UDim2.new(1, 0, 1, -86)
            else
                pin.Visible = false
                scroll.Position = UDim2.fromOffset(0, 0)
                scroll.Size = UDim2.new(1, 0, 1, -52)
            end
        end
        function v.remove(id)
            local e = v.msgs[id]
            if e then e.label:Destroy(); v.msgs[id] = nil end
        end
        -- staff: показать ✕ у сообщений (удаление на сервере)
        function v.setStaff(on)
            v.staff = on
            for _, e in pairs(v.msgs) do
                if e.x then e.x.Visible = on; e.pad.PaddingRight = UDim.new(0, on and 34 or 12) end
            end
        end
        function v.clear()
            for id in pairs(v.msgs) do v.remove(id) end
            v.ids = {}
        end
        -- kind: "msg" | "sys" | "announce" | "mention"
        function v.add(id, rich, kind)
            local stick = nearBottom()
            v.order += 1
            if not id then v.localId -= 1; id = v.localId end
            if v.msgs[id] then return end
            local sys = kind == "sys"
            local l = new("TextLabel", {
                LayoutOrder = v.order, Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Glass.White, BackgroundTransparency = sys and 1 or 0.94,
                TextWrapped = true, RichText = true, Text = rich, FontFace = F.Medium, TextSize = 13,
                TextColor3 = sys and Glass.TextMute or Glass.Text,
                TextXAlignment = sys and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top, Parent = scroll,
            })
            corner(l, 12)
            local pd = new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = l})
            local x
            if v.onDelete and type(id) == "number" and id > 0 then
                x = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 28, 0, -1), Size = UDim2.fromOffset(20, 20),
                    Text = "", AutoButtonColor = false,
                    BackgroundColor3 = Color3.fromRGB(210, 60, 85), BackgroundTransparency = 0.3, Visible = v.staff == true, ZIndex = 3, Parent = l,
                })
                corner(x, 6)
                WC_ICON.make("x", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 4, Parent = x})
                x.MouseButton1Click:Connect(function() task.spawn(v.onDelete, id) end)
                if v.staff then pd.PaddingRight = UDim.new(0, 34) end
            end
            if kind == "announce" then
                l.BackgroundColor3 = Color3.fromRGB(255, 196, 70); l.BackgroundTransparency = 0.8
            elseif kind == "mention" then
                l.BackgroundColor3 = Color3.fromRGB(130, 120, 255); l.BackgroundTransparency = 0.72
            end
            v.msgs[id] = {label = l, x = x, pad = pd}
            table.insert(v.ids, id)
            if #v.ids > 120 then v.remove(table.remove(v.ids, 1)) end
            if stick then task.defer(v.scrollDown) end
        end
        function v.sys(text) v.add(nil, "<i>" .. esc(text) .. "</i>", "sys") end
        local function submit()
            local t = box.Text
            if t == "" then return end
            box.Text = ""
            task.spawn(onSubmit, t)
            task.defer(v.scrollDown)
        end
        box.FocusLost:Connect(function(enter) if enter then submit() end end)
        sendB.MouseButton1Click:Connect(guarded(submit))
        return v
    end

    -- =========================== GLOBAL CHAT ===========================
    local G = {online = 0, banned = false, locked = false, ok = false, role = "user", slow = 1}
    local function isStaff() return G.role == "owner" or G.role == "admin" end
    local TAG = {
        owner = '<font color="#ff7a7a"><b>[OWNER]</b></font> ',
        admin = '<font color="#7ab4ff"><b>[ADMIN]</b></font> ',
    }
    local HELP = "Команды: /me действие · /roll [N] · /flip · /clear (очистить у себя). Упомяни ник — сообщение подсветится."
    local gView
    local function gSend(text)
        if text == "/help" then gView.sys(HELP); return end
        if text == "/clear" then gView.clear(); return end
        if not req then gView.sys("⚠ Экзекьютор не поддерживает HTTP-запросы"); return end
        local code, d = chatApi("POST", "/send", nil, {name = player.Name, userId = player.UserId, jid = game.JobId, pid = game.PlaceId, text = text, token = TOKEN})
        if code == 200 then return end
        local e = d.error
        local msgs = {
            spam = "🤖 Антиспам: вы замучены — " .. tillText(d.till), busy = "⏳ Чат перегружен, попробуйте через пару секунд",
            dupe = "♻ Не повторяйте одно и то же сообщение", links = "🔗 Ссылки в чате запрещены", slow = "⏱ Не так быстро",
            muted = "🔇 Вы в муте — " .. tillText(d.till), banned = "🚫 Вы забанены — " .. tillText(d.till),
            locked = "🔒 Чат закрыт админами", reserved = "⛔ Этот ник зарезервирован", ["bad key"] = "⛔ Неверный ключ чата",
        }
        gView.sys(msgs[e] or "⚠ Не удалось отправить сообщение")
    end
    gView = makeChatView(pages.global, "Напиши сообщение… (/help)", gSend)

    local function gFormat(m)
        local t = m.type or "msg"
        if t == "sys" then return "<i>" .. esc(m.text) .. "</i>", "sys" end
        local tag = TAG[m.role] or ""
        if t == "announce" then return stamp(m.t) .. "📢 <b>" .. tag .. esc(m.name) .. ":</b> " .. esc(m.text), "announce" end
        local nc = hex(nameColor(tostring(m.name or "?")))
        local srv = (m.ghost and "👻 " or "") .. '<font color="#8a8fa8">[' .. esc(m.server or "?") .. "]</font> "
        local kind = "msg"
        if m.name ~= player.Name and tostring(m.text or ""):lower():find(player.Name:lower(), 1, true) then kind = "mention" end
        if t == "me" then
            return stamp(m.t) .. srv .. tag .. '<i>* <font color="' .. nc .. '">' .. esc(m.name) .. "</font> " .. esc(m.text) .. "</i>", kind
        end
        return stamp(m.t) .. srv .. tag .. '<font color="' .. nc .. '"><b>' .. esc(m.name) .. "</b></font>  " .. esc(m.text), kind
    end
    local function gPlaceholder()
        if G.banned then gView.box.PlaceholderText = "🚫 Вы забанены"
        elseif G.locked then gView.box.PlaceholderText = "🔒 Чат закрыт (пишут только админы)"
        else gView.box.PlaceholderText = "Напиши сообщение… (/help)" end
        gView.box.TextEditable = not G.banned
    end

    -- ---------- облачко над тем, кто написал (если он в этом сервере Roblox) ----------
    local TextService = game:GetService("TextService")
    local bubbles = {}
    local BUBBLE_FONT, BUBBLE_SIZE, BUBBLE_MAXW = Enum.Font.GothamMedium, 14, 220
    local function showBubble(m)
        local kind = m.type or "msg"
        if kind ~= "msg" and kind ~= "me" then return end
        local plr = Players:FindFirstChild(tostring(m.name or ""))
        if not plr or not plr:IsA("Player") then return end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local head = char:FindFirstChild("Head")
        local top = 2.5
        if head and head:IsA("BasePart") then top = (head.Position.Y + head.Size.Y / 2) - hrp.Position.Y end
        top = math.clamp(top, 1.2, 10)

        local text = tostring(m.text or "")
        if (utf8.len(text) or 0) > 140 then text = text:sub(1, (utf8.offset(text, 138) or 138) - 1) .. "..." end
        if kind == "me" then text = "* " .. plr.DisplayName .. " " .. text end

        local old = bubbles[plr]
        if old then old:Destroy() end
        local ok, sz = pcall(function()
            return TextService:GetTextSize(text, BUBBLE_SIZE, BUBBLE_FONT, Vector2.new(BUBBLE_MAXW, 1000))
        end)
        if not ok then sz = Vector2.new(BUBBLE_MAXW, BUBBLE_SIZE * 2) end
        local w, h = math.ceil(sz.X) + 26, math.ceil(sz.Y) + 16

        -- 2D-облачко на оверлее, общей проекцией (учитывает Aspect); снизу отступ под ESP-ник и метку
        local rr = Cos.remote[plr.UserId]
        local hasTag = rr and rr.tag and rr.tag.Parent ~= nil
        local gap = hasTag and 56 or 28
        local f = Instance.new("Frame")
        f.Name = "WC_ChatBubble"
        f.Size = UDim2.fromOffset(w, h)
        f.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        f.BackgroundTransparency = 1
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = f
        local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(190, 160, 255); st.Thickness = 1; st.Transparency = 1; st.Parent = f
        local sc = Instance.new("UIScale"); sc.Scale = 0.8; sc.Parent = f
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, -26, 1, -16)
        l.Position = UDim2.fromOffset(13, 8)
        l.Font = BUBBLE_FONT
        l.TextSize = BUBBLE_SIZE
        l.TextWrapped = true
        l.TextColor3 = Color3.fromRGB(240, 240, 248)
        l.TextTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.Text = text
        l.Parent = f
        local bb = WC_PROJ.attach(f, hrp, top + 0.25, gap, 100)
        bubbles[plr] = bb

        -- появление
        tw(f, 0.25, {BackgroundTransparency = 0.18})
        tw(st, 0.25, {Transparency = 0.45})
        tw(l, 0.25, {TextTransparency = 0})
        tw(sc, 0.35, {Scale = 1}, Enum.EasingStyle.Back)
        -- держится ~2.5 с, потом плавно исчезает
        task.delay(2.6, function()
            if bubbles[plr] ~= bb or not bb.Parent then return end
            tw(f, 0.4, {BackgroundTransparency = 1})
            tw(st, 0.4, {Transparency = 1})
            tw(l, 0.4, {TextTransparency = 1})
            tw(sc, 0.4, {Scale = 0.9})
            task.delay(0.42, function()
                if bubbles[plr] == bb then bubbles[plr] = nil end
                bb:Destroy()
            end)
        end)
    end

    gView.sys("Подключение к Global Chat…")
    task.spawn(function()
        local last, dseq, first, pinnedText = 0, 0, true, nil
        while not ScriptUnloaded do
            if req and NET.chatUrl ~= "" then
                local q = ("&after=%d&dseq=%d&name=%s&uid=%d&jid=%s&pid=%d&token=%s"):format(last, dseq, enc(player.Name), player.UserId, enc(game.JobId), game.PlaceId, enc(TOKEN))
                local code, d = chatApi("GET", "/poll", q)
                if code == 200 then
                    if not G.ok and first then gView.sys("✅ Подключено ко всем серверам") end
                    G.ok = true
                    if G.banned then G.banned = false; gView.sys("✅ Бан снят") end
                    if type(d.settings) == "table" then G.locked = d.settings.locked == true; G.slow = d.settings.slow or G.slow end
                    local newRole = (d.role == "owner" or d.role == "admin") and d.role or "user"
                    if newRole ~= G.role then
                        G.role = newRole
                        gView.setStaff(isStaff())
                        subBtns.admin.b.Visible = isAdmin or isStaff()
                        if isStaff() then gView.sys("🛡 Вы вошли как " .. newRole:upper() .. ". В Community появилась вкладка Admin, красная кнопка у сообщения — удалить.") end
                        if not subBtns.admin.b.Visible and curSub == "admin" then showSub("global") end
                    end
                    G.online = tonumber(d.online) or 0
                    local pn = type(d.pinned) == "table" and d.pinned.text or nil
                    if pn ~= pinnedText then pinnedText = pn; gView.setPinned(pn) end
                    for _, m in ipairs(d.messages or {}) do
                        local rich, kind = gFormat(m)
                        gView.add(m.id, rich, kind)
                        if not first then pcall(showBubble, m) end
                        if not first and kind ~= "sys" and not subVisible("global") then
                            unread.global += 1
                            if kind == "mention" then notify("Global Chat · " .. tostring(m.name), tostring(m.text)) end
                        end
                    end
                    for _, id in ipairs(d.deleted or {}) do gView.remove(id) end
                    last, dseq = tonumber(d.last) or last, tonumber(d.dseq) or dseq
                    if first then task.defer(gView.scrollDown) end
                    first = false
                    updateBadges()
                elseif code == 403 and d.error == "banned" then
                    G.ok = true
                    if not G.banned then
                        G.banned = true
                        local why = (d.reason and d.reason ~= "") and (". Причина: " .. tostring(d.reason)) or ""
                        gView.sys("🚫 Вы забанены — " .. tillText(d.till) .. why)
                    end
                else
                    G.ok = false
                end
                gPlaceholder()
                if refreshStatus then refreshStatus() end
            elseif not req then
                gView.sys("⚠ Экзекьютор не поддерживает HTTP-запросы (request)")
                return
            end
            task.wait(G.banned and 10 or (subVisible("global") and 1.5 or 4))
        end
    end)

    -- =========================== НА СЕРВЕРЕ (хаб) ===========================
    local H = {ok = false, total = 0, users = {}, sig = ""}
    local serverScroll = makeScrollPage(pages.server)
    local hubInfo = new("TextLabel", {
        Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Glass.White, BackgroundTransparency = 0.95,
        RichText = true, TextWrapped = true, Text = "", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, Parent = serverScroll,
    })
    corner(hubInfo, 14)
    new("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = hubInfo})
    local rows = {}
    local thumbs = {}
    local function thumb(uid)
        if thumbs[uid] then return thumbs[uid] end
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        thumbs[uid] = ok and img or ""
        return thumbs[uid]
    end
    local function cosNames(ids, korblox, headless)
        local out = {}
        if korblox then table.insert(out, "Korblox") end
        if headless then table.insert(out, "Headless") end
        for _, id in ipairs(ids or {}) do
            local d = Cos.byId[id]
            if d then table.insert(out, d.name) end
        end
        return (#out > 0) and table.concat(out, ", ") or "без косметики"
    end
    local function myIds()
        local ids = {}
        for _, d in ipairs(Cos.list) do if State.Cos[d.id] then table.insert(ids, d.id) end end
        return ids
    end
    local function renderServerList()
        if NET.hubUrl == "" then
            hubInfo.Text = "<b>Хаб не подключён.</b>\nВпиши адрес своего Wispbyte-сервера в <font color=\"#c8b4ff\">WC_NET.hubUrl</font> в начале скрипта — тогда тут будет видно, кто на этом сервере тоже юзает wannacry, и ты увидишь их косметику."
        elseif not H.ok then
            hubInfo.Text = "<b>Нет связи с хабом</b> · повторная попытка…"
        else
            hubInfo.Text = ("<b>%d</b> юзеров wannacry на этом сервере  ·  <b>%d</b> онлайн во всех играх\nИх косметику видишь только ты (и они — твою)."):format(#H.users + 1, H.total)
        end
        for _, r in ipairs(rows) do r:Destroy() end
        rows = {}
        local list = {{userId = player.UserId, name = player.Name, display = player.DisplayName, cos = myIds(), korblox = State.KorbloxEnabled, headless = State.HeadlessEnabled, me = true}}
        for _, u in ipairs(H.users) do table.insert(list, u) end
        for i, u in ipairs(list) do
            local row = new("Frame", {Size = UDim2.new(1, -4, 0, 58), LayoutOrder = i, Parent = serverScroll})
            soft(row, {radius = 16, transparency = 0.95})
            local av = new("ImageLabel", {Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(40, 40), BackgroundColor3 = nameColor(tostring(u.name)), BackgroundTransparency = 0.6, Image = "", ZIndex = 2, Parent = row})
            corner(av, "full")
            task.spawn(function() local img = thumb(tonumber(u.userId) or 0); if av.Parent then av.Image = img end end)
            local title = esc(u.display or u.name)
            if u.display and u.display ~= u.name then title ..= ' <font color="#8a8fa8">@' .. esc(u.name) .. "</font>" end
            if u.me then title ..= '  <font color="#8affb0">· это ты</font>' end
            if table.find(NET.admins, tostring(u.name)) then title ..= '  <font color="#7ab4ff"><b>[ADMIN]</b></font>' end
            new("TextLabel", {Position = UDim2.fromOffset(60, 9), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1, RichText = true, Text = title, FontFace = F.Semi, TextSize = 14, TextColor3 = Glass.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = row})
            new("TextLabel", {Position = UDim2.fromOffset(60, 30), Size = UDim2.new(1, -70, 0, 18), BackgroundTransparency = 1, Text = cosNames(u.cos, u.korblox, u.headless), FontFace = F.Regular, TextSize = 12, TextColor3 = Glass.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = row})
            table.insert(rows, row)
        end
    end
    renderServerList()

    local function applyPresence(d)
        local seen, users = {}, {}
        for _, u in ipairs(type(d.users) == "table" and d.users or {}) do
            local uid = tonumber(u.userId)
            local plr = uid and Players:GetPlayerByUserId(uid)
            if plr and plr ~= player then
                seen[uid] = true
                local cos = type(u.cos) == "table" and u.cos or {}
                Cos.setRemote(plr, cos, u.korblox == true, u.headless == true)
                table.insert(users, {userId = uid, name = plr.Name, display = plr.DisplayName, cos = cos, korblox = u.korblox == true, headless = u.headless == true})
            end
        end
        for uid in pairs(Cos.remote) do
            if not seen[uid] then Cos.clearRemote(uid) end
        end
        H.users = users
        H.total = tonumber(d.total) or 0
    end
    connect(Players.PlayerRemoving, function(plr) Cos.clearRemote(plr.UserId) end)

    task.spawn(function()
        Tex.await()
        local lastSent, lastSig, lastList = -100, "", ""
        while not ScriptUnloaded do
            if req and NET.hubUrl ~= "" then
                local ids = myIds()
                local sig = table.concat(ids, ",") .. "|" .. tostring(State.KorbloxEnabled) .. tostring(State.HeadlessEnabled)
                if sig ~= lastSig or os.clock() - lastSent > 8 then
                    lastSig, lastSent = sig, os.clock()
                    local code, d = hubApi("POST", "/presence", nil, {
                        userId = player.UserId, name = player.Name, jobId = game.JobId, placeId = game.PlaceId,
                        cos = ids, korblox = State.KorbloxEnabled == true, headless = State.HeadlessEnabled == true,
                    })
                    H.ok = code == 200
                    if H.ok then applyPresence(d) end
                    local listSig = sig .. tostring(H.ok) .. H.total
                    for _, u in ipairs(H.users) do listSig = listSig .. "/" .. u.userId .. ":" .. table.concat(u.cos, ",") .. tostring(u.korblox) .. tostring(u.headless) end
                    if listSig ~= lastList then lastList = listSig; renderServerList() end
                    if refreshStatus then refreshStatus() end
                end
            end
            task.wait(1)
        end
    end)

    -- =========================== ADMIN: панель модерации + чат админов ===========================
    -- Панель — порт твоего admin-клиента (/admin на сервере Global Chat, роль owner/admin
    -- приходит в /poll по токену). Каждое действие проверяет сервер, UI тут ничего не решает.
    -- «Чат» — закрытый чат админов на Wispbyte-хабе.
    local A = {ok = false, admins = {}}
    local TeleportService = game:GetService("TeleportService")
    local clip = setclipboard or toclipboard or (syn and syn.write_clipboard)
    local RED, GREEN, AMBER, BLUE, ACC = Color3.fromRGB(235, 90, 105), Color3.fromRGB(70, 200, 120), Color3.fromRGB(240, 170, 60), Color3.fromRGB(90, 150, 230), Color3.fromRGB(130, 120, 255)
    local ap = pages.admin

    local function field(parent, ph, pos, size)
        local f = new("Frame", {Position = pos, Size = size, Parent = parent})
        liquid(f, {radius = 12, transparency = 0.92, glint = false, sheen = false, lens = false})
        return new("TextBox", {
            Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = "",
            PlaceholderText = ph, PlaceholderColor3 = Glass.TextMute, TextColor3 = Glass.Text, FontFace = F.Medium, TextSize = 12,
            ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, ZIndex = 5, Parent = f,
        })
    end
    local function cbtn(parent, text, props, color)
        return glassButton(parent, text, props, {radius = 10, transparency = color and 0.5 or 0.88, tint = color, textSize = 12, font = F.Bold, sheen = false, glint = false, lens = false})
    end

    -- верхняя карточка: цель / минуты / причина + быстрые наказания
    local top = new("Frame", {Size = UDim2.new(1, 0, 0, 84), Parent = ap})
    soft(top, {radius = 16, transparency = 0.95})
    local targetBox = field(top, "Ник игрока", UDim2.fromOffset(8, 8), UDim2.new(0.3, -8, 0, 30))
    local minBox = field(top, "Мин", UDim2.new(0.3, 6, 0, 8), UDim2.new(0, 56, 0, 30))
    local reasonBox = field(top, "Причина (необязательно)", UDim2.new(0.3, 68, 0, 8), UDim2.new(0.7, -76, 0, 30))
    local actRow = new("Frame", {Position = UDim2.fromOffset(8, 46), Size = UDim2.new(1, -16, 0, 30), BackgroundTransparency = 1, Parent = top})
    local function actBtn(i, text, color)
        return cbtn(actRow, text, {Position = UDim2.new((i - 1) * 0.25, 2, 0, 0), Size = UDim2.new(0.25, -4, 1, 0)}, color)
    end
    local bMute, bUnmute, bBan, bUnban = actBtn(1, "Mute", AMBER), actBtn(2, "Unmute", GREEN), actBtn(3, "Ban", RED), actBtn(4, "Unban", BLUE)

    -- подвкладки
    local SUBS = {}
    if isAdmin then table.insert(SUBS, {"chat", "Чат"}) end
    for _, t in ipairs({{"players", "Игроки"}, {"pun", "Наказ."}, {"troll", "Тролль"}, {"spam", "Защита"}, {"adm", "Админы"}, {"misc", "Ещё"}}) do table.insert(SUBS, t) end
    local seg = new("Frame", {Position = UDim2.fromOffset(0, 92), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = ap})
    local segBtns, subTab = {}, SUBS[1][1]
    for i, t in ipairs(SUBS) do
        local b, l = glassButton(seg, t[2], {Position = UDim2.new((i - 1) / #SUBS, 2, 0, 0), Size = UDim2.new(1 / #SUBS, -4, 1, 0)},
            {radius = "full", transparency = 0.92, textSize = 11})
        segBtns[t[1]] = {b = b, l = l}
    end
    local content = new("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 128), Size = UDim2.new(1, 0, 1, -152), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Glass.White, ScrollBarImageTransparency = 0.6,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = ap,
    })
    new("UIPadding", {PaddingRight = UDim.new(0, 6), Parent = content})
    new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content})
    local statusLbl = new("TextLabel", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 6, 1, 0), Size = UDim2.new(1, -12, 0, 20), BackgroundTransparency = 1,
        Text = "Минуты: пусто = по умолчанию (мут 10, бан 60), 0 = навсегда", TextColor3 = Glass.TextMute,
        FontFace = F.Medium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = ap,
    })
    local function status(text, good)
        statusLbl.Text = text
        statusLbl.TextColor3 = (good == true and GREEN) or (good == false and RED) or Glass.TextMute
    end
    local chatFrame = new("Frame", {Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 1, -36), BackgroundTransparency = 1, Visible = false, Parent = ap})

    -- строки списка
    local rowOrder = 0
    local function clearContent()
        rowOrder = 0
        for _, c in ipairs(content:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
    end
    -- buttons = { {текст, функция(btn, label), ширина, [цвет]}, ... }
    local function addRow(text, buttons, onRow)
        rowOrder += 1
        local f = new("Frame", {LayoutOrder = rowOrder, Size = UDim2.new(1, -2, 0, 32), Parent = content})
        soft(f, {radius = 10, transparency = 0.95, sheen = false})
        local total = 0
        for _, b in ipairs(buttons or {}) do total += b[3] + 4 end
        local t = new("TextButton", {
            Size = UDim2.new(1, -total - 4, 1, 0), BackgroundTransparency = 1, Text = text, RichText = true, AutoButtonColor = false,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = F.Medium, TextSize = 12,
            TextColor3 = Glass.Text, ZIndex = 3, Parent = f,
        })
        new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = t})
        if onRow then t.MouseButton1Click:Connect(onRow) end
        local x = -4
        for i = #(buttons or {}), 1, -1 do
            local b = buttons[i]
            local btn, lbl = cbtn(f, b[1], {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(b[3], 24)}, b[4])
            btn.MouseButton1Click:Connect(function() task.spawn(b[2], btn, lbl) end)
            x = x - b[3] - 4
        end
        return f
    end
    local function formRow(ph, btnText, cb)
        rowOrder += 1
        local f = new("Frame", {LayoutOrder = rowOrder, Size = UDim2.new(1, -2, 0, 32), BackgroundTransparency = 1, Parent = content})
        local tb = field(f, ph, UDim2.fromOffset(0, 0), UDim2.new(1, -94, 1, 0))
        local b = cbtn(f, btnText, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(88, 32)}, ACC)
        b.MouseButton1Click:Connect(function()
            local txt = tb.Text
            tb.Text = ""
            task.spawn(cb, txt)
        end)
    end
    local function formRow2(ph1, ph2, btnText, cb)
        rowOrder += 1
        local f = new("Frame", {LayoutOrder = rowOrder, Size = UDim2.new(1, -2, 0, 32), BackgroundTransparency = 1, Parent = content})
        local tb1 = field(f, ph1, UDim2.fromOffset(0, 0), UDim2.new(0, 100, 1, 0))
        local tb2 = field(f, ph2, UDim2.fromOffset(106, 0), UDim2.new(1, -200, 1, 0))
        local b = cbtn(f, btnText, {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(88, 32)}, ACC)
        b.MouseButton1Click:Connect(function()
            local a, t = tb1.Text, tb2.Text
            tb2.Text = ""
            task.spawn(cb, a, t)
        end)
    end
    local function copyText(txt)
        if clip then clip(txt); status("📋 Скопировано: " .. txt, true) else status("Токен: " .. txt, true) end
    end
    local function target() return (targetBox.Text:gsub("%s", "")) end
    local function minutesOr(def)
        local m = tonumber(minBox.Text)
        if m == nil then return def end
        return m
    end

    local adminData = {players = {}, bans = {}, mutes = {}, shadows = {}, fx = {}, admins = {}, audit = {}}
    local adminCall, refreshPanel, renderSub

    local function joinPlayer(p)
        local code, d = adminCall("join", {target = p.name})
        if code ~= 200 then return end
        if d.jid == game.JobId then status("Вы уже на этом сервере", true) return end
        status("Телепорт на сервер " .. tostring(p.server) .. "…", true)
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(tonumber(d.pid) or game.PlaceId, d.jid, player)
        end)
        if not ok then status("Ошибка: " .. tostring(err), false) end
    end
    local function punRows(title, color, label, list, unact)
        addRow("<b>" .. title .. "</b>")
        if #(list or {}) == 0 then addRow('<font color="#8a8fa8">пусто</font>') end
        for _, p in ipairs(list or {}) do
            addRow('<font color="' .. color .. '">' .. label .. "</font> " .. esc(p.name) .. ' <font color="#8a8fa8">'
                .. (p.mode and (esc(p.mode) .. " · ") or "") .. tillText(p.till) .. (p.by and (" · " .. esc(p.by)) or "") .. "</font>",
                {{"Снять", function() adminCall(unact, {target = p.name}) end, 60}},
                function() targetBox.Text = p.name end)
        end
    end

    renderSub = function()
        local chatMode = subTab == "chat"
        top.Visible = not chatMode
        content.Visible = not chatMode
        statusLbl.Visible = not chatMode
        chatFrame.Visible = chatMode
        seg.Position = UDim2.fromOffset(0, chatMode and 0 or 92)
        for k, b in pairs(segBtns) do
            tw(b.l, 0.2, {TextColor3 = (k == subTab) and Glass.Text or Glass.TextMute})
            b.l.FontFace = (k == subTab) and F.Bold or F.Semi
        end
        if chatMode then return end
        clearContent()
        if not isStaff() then
            addRow('<font color="#ff8a8a">Нет прав.</font> Сервер чата не подтвердил роль ADMIN/OWNER для этого ника и токена.')
            addRow('<font color="#8a8fa8">Токен лежит в chat_token.txt — тот же, что для твоего admin-лоадера.</font>')
            return
        end
        local d = adminData
        if subTab == "players" then
            local n = 0
            for _, p in ipairs(d.players or {}) do
                n += 1
                local tag = (p.role == "owner" and ' <font color="#ff7a7a">[OWNER]</font>') or (p.role == "admin" and ' <font color="#7ab4ff">[ADMIN]</font>') or ""
                local dotc = p.online and '<font color="#5be38a">●</font> ' or '<font color="#5b6078">●</font> '
                local btns
                if tostring(p.name):lower() ~= player.Name:lower() then
                    btns = {{"Join", function() joinPlayer(p) end, 50, ACC}}
                end
                addRow(dotc .. esc(p.name) .. tag .. ' <font color="#8a8fa8">[' .. esc(p.server or "?") .. "]</font>", btns,
                    function() targetBox.Text = p.name end)
            end
            if n == 0 then addRow('<font color="#8a8fa8">Пока никого нет</font>') end
        elseif subTab == "pun" then
            punRows("Муты", "#fbbf24", "MUTE", d.mutes, "unmute")
            punRows("Баны", "#f87171", "BAN", d.bans, "unban")
            punRows("Shadow-mute", "#a78bfa", "SHADOW", d.shadows, "unshadow")
            punRows("Эффекты текста", "#34d399", "FX", d.fx, "unfx")
        elseif subTab == "troll" then
            addRow("<b>Писать от имени игрока</b>")
            formRow2("Ник", "Текст сообщения", "Отправить", function(a, b)
                a = a:gsub("%s", "")
                if a ~= "" and b ~= "" then adminCall("say", {as = a, text = b}) end
            end)
            addRow('<b>Цель — ник в поле сверху</b> <font color="#8a8fa8">(минуты — тоже сверху)</font>')
            addRow("👻 Shadow-mute (видит только он)", {
                {"Вкл", function() adminCall("shadow", {target = target(), minutes = minutesOr(10)}) end, 44, GREEN},
                {"Выкл", function() adminCall("unshadow", {target = target()}) end, 50},
            })
            local function fx(mode)
                return function() adminCall("fx", {target = target(), mode = mode, minutes = minutesOr(10)}) end
            end
            addRow("🎭 Эффект", {
                {"Реверс", fx("reverse"), 58}, {"UwU", fx("uwu"), 44}, {"CAPS", fx("caps"), 48},
                {"🤡", fx("clown"), 34}, {"Снять", function() adminCall("unfx", {target = target()}) end, 54},
            })
            addRow("🎪 Фейк-сообщение в чат", {
                {"Бан", function() adminCall("fakeban", {target = target(), minutes = minutesOr(60), reason = reasonBox.Text}) end, 46},
                {"Админ", function() adminCall("fakeadmin", {target = target()}) end, 58},
            })
        elseif subTab == "spam" then
            local sp = (d.settings and d.settings.spam) or {}
            local function sw(label, key)
                addRow(label, {{sp[key] and "ВКЛ" or "ВЫКЛ", function() adminCall("spam", {set = {[key] = not sp[key]}}) end, 56, sp[key] and GREEN or nil}})
            end
            local function numRow(ph, key)
                formRow(ph, "Задать", function(txt)
                    local n = tonumber(txt)
                    if n then adminCall("spam", {set = {[key] = n}}) end
                end)
            end
            sw("🛡 Защита от спама (всё)", "enabled")
            sw("♻ Блок одинаковых сообщений", "dupe")
            sw("🔗 Блок ссылок", "links")
            sw("🔠 Анти-CAPS", "caps")
            sw("Сжатие повторов (ааааа)", "repeat")
            sw("🤬 Фильтр слов", "wordFilter")
            numRow("Лимит за 10 сек (сейчас " .. tostring(sp.rate or "?") .. ")", "rate")
            numRow("Авто-мут, сек (сейчас " .. tostring(sp.autoMute or "?") .. ")", "autoMute")
            numRow("Общий лимит/10с, 0=выкл (" .. tostring(sp.globalMax or "?") .. ")", "globalMax")
            formRow("Слоумод, сек (сейчас " .. tostring(G.slow) .. ")", "Задать", function(txt)
                local n = tonumber(txt)
                if n then adminCall("settings", {slow = n}) end
            end)
            formRow("Запретное слово", "Добавить", function(txt)
                if txt ~= "" then adminCall("addword", {word = txt}) end
            end)
            for _, w in ipairs(sp.words or {}) do
                addRow("🚫 " .. esc(w), {{"Удалить", function() adminCall("delword", {word = w}) end, 70, RED}})
            end
            if d.ipStats then
                addRow('<font color="#8a8fa8">IP онлайн: ' .. tostring(d.ipStats.unique) .. " уникальных из " .. tostring(d.ipStats.total) .. "</font>")
            end
        elseif subTab == "adm" then
            if G.role == "owner" then
                formRow("Ник нового админа", "Добавить", function(txt)
                    local code, res = adminCall("addadmin", {target = txt})
                    if code == 200 and res.token then copyText(res.token) end
                end)
            end
            for _, a in ipairs(d.admins or {}) do
                local btns
                if G.role == "owner" then
                    btns = {
                        {"Токен", function() copyText(a.token or "?") end, 58},
                        {"Убрать", function() adminCall("removeadmin", {target = a.name}) end, 62, RED},
                    }
                end
                addRow('<font color="#7ab4ff">[ADMIN]</font> ' .. esc(a.name), btns)
            end
            if #(d.admins or {}) == 0 then addRow('<font color="#8a8fa8">Админов пока нет</font>') end
        elseif subTab == "misc" then
            formRow("Текст объявления", "Объявить", function(txt)
                if txt ~= "" then adminCall("announce", {text = txt}) end
            end)
            formRow("Закреплённое сообщение", "Закрепить", function(txt)
                if txt ~= "" then adminCall("pin", {text = txt}) end
            end)
            addRow("📌 Снять закреплённое сообщение", {{"Снять", function() adminCall("unpin") end, 60}})
            addRow(G.locked and "🔒 Чат закрыт (пишут только админы)" or "🔓 Чат открыт для всех",
                {{G.locked and "Открыть" or "Закрыть", function() adminCall("settings", {locked = not G.locked}) end, 74}})
            addRow("🧹 Очистить чат у всех (логи сохранятся)", {{"Очистить", function(btn, lbl)
                if lbl.Text ~= "Точно?" then
                    lbl.Text = "Точно?"
                    task.delay(3, function() if lbl.Parent then lbl.Text = "Очистить" end end)
                else
                    adminCall("clear")
                end
            end, 74, RED}})
            addRow("<b>Журнал действий</b>")
            for _, line in ipairs(d.audit or {}) do
                addRow('<font color="#8a8fa8">' .. esc(line) .. "</font>")
            end
        end
    end
    for _, t in ipairs(SUBS) do
        segBtns[t[1]].b.MouseButton1Click:Connect(guarded(function()
            subTab = t[1]
            renderSub()
            if subTab ~= "chat" and isStaff() then task.spawn(refreshPanel) end
        end))
    end

    refreshPanel = function()
        if not isStaff() then return end
        local code, d = chatApi("POST", "/admin", nil, {name = player.Name, token = TOKEN, action = "list"})
        if code == 200 then
            adminData = d
            if type(d.settings) == "table" then
                G.slow = d.settings.slow or G.slow
                G.locked = d.settings.locked == true
                gPlaceholder()
            end
            if subTab ~= "chat" then renderSub() end
        end
    end
    adminCall = function(action, extra)
        local b = extra or {}
        b.name, b.token, b.action = player.Name, TOKEN, action
        local code, d = chatApi("POST", "/admin", nil, b)
        if code == 200 then status("Готово: " .. action, true) else status("Ошибка: " .. tostring(d.error or code or "нет связи"), false) end
        if subVisible("admin") and subTab ~= "chat" then task.spawn(refreshPanel) end
        return code, d
    end
    local function punish(name, defMins)
        adminCall(name, {target = target(), minutes = minutesOr(defMins), reason = reasonBox.Text})
    end
    bMute.MouseButton1Click:Connect(function() task.spawn(punish, "mute", 10) end)
    bBan.MouseButton1Click:Connect(function() task.spawn(punish, "ban", 60) end)
    bUnmute.MouseButton1Click:Connect(function() task.spawn(adminCall, "unmute", {target = target()}) end)
    bUnban.MouseButton1Click:Connect(function() task.spawn(adminCall, "unban", {target = target()}) end)
    -- staff может удалять сообщения в Global Chat
    gView.onDelete = function(id) adminCall("delete", {id = id}) end

    -- автообновление списков (только вкладки без полей ввода)
    task.spawn(function()
        while not ScriptUnloaded do
            task.wait(4)
            if subVisible("admin") and isStaff() and (subTab == "players" or subTab == "pun") then refreshPanel() end
        end
    end)
    CommunityTab:GetPropertyChangedSignal("Visible"):Connect(function()
        if CommunityTab.Visible and curSub == "admin" and subTab ~= "chat" then task.spawn(refreshPanel) end
    end)
    subBtns.admin.b.MouseButton1Click:Connect(function()
        if subTab ~= "chat" then task.spawn(refreshPanel) end
        renderSub()
    end)

    -- закрытый чат админов (Wispbyte-хаб)
    if isAdmin then
        local aView
        aView = makeChatView(chatFrame, "Сообщение админам…", function(text)
            if text == "/clear" then aView.clear(); return end
            if NET.hubUrl == "" then aView.sys("Хаб не подключён: впиши WC_NET.hubUrl"); return end
            local code, d = hubApi("POST", "/admin/send", nil, {name = player.Name, token = TOKEN, text = text})
            if code ~= 200 then aView.sys((code == 403) and "⛔ Доступ запрещён: проверь токен в chat_token.txt" or ("⚠ Не отправлено" .. (d.error and (": " .. tostring(d.error)) or ""))) end
        end)
        if TOKEN == "" then aView.sys('Нет токена. Один раз выполни: writefile("chat_token.txt", "ТВОЙ_ТОКЕН") и перезапусти скрипт') end
        if NET.hubUrl == "" then aView.sys("Хаб не подключён: впиши адрес Wispbyte-сервера в WC_NET.hubUrl") end
        task.spawn(function()
            local last, first, denied = 0, true, false
            while not ScriptUnloaded and TOKEN ~= "" do
                if req and NET.hubUrl ~= "" then
                    local code, d = hubApi("GET", "/admin/poll", ("&name=%s&token=%s&after=%d"):format(enc(player.Name), enc(TOKEN), last))
                    if code == 200 then
                        A.ok = true
                        A.admins = type(d.admins) == "table" and d.admins or {}
                        H.total = tonumber(d.users) or H.total
                        for _, m in ipairs(d.messages or {}) do
                            local nc = hex(nameColor(tostring(m.name or "?")))
                            aView.add(m.id, stamp(m.t) .. '<font color="#7ab4ff"><b>[ADMIN]</b></font> <font color="' .. nc .. '"><b>' .. esc(m.name) .. "</b></font>  " .. esc(m.text), "msg")
                            if not first and m.name ~= player.Name and not (subVisible("admin") and subTab == "chat") then
                                unread.admin += 1
                                notify("Admin Chat · " .. tostring(m.name), tostring(m.text))
                            end
                        end
                        last = tonumber(d.last) or last
                        if first then task.defer(aView.scrollDown) end
                        first = false
                        updateBadges()
                    elseif code == 403 then
                        A.ok = false
                        if not denied then denied = true; aView.sys("⛔ Хаб отклонил доступ: ник или токен не совпадают с config.json хаба") end
                    else
                        A.ok = false
                    end
                    if refreshStatus then refreshStatus() end
                end
                task.wait(subVisible("admin") and 1.5 or 4)
            end
        end)
    end
    renderSub()

    -- ---------- статус справа ----------
    refreshStatus = function()
        local dot = function(ok) return ok and '<font color="#5be38a">●</font> ' or '<font color="#ff6b6b">●</font> ' end
        if curSub == "global" then
            statusL.Text = dot(G.ok) .. G.online .. " online"
        elseif curSub == "server" then
            statusL.Text = (NET.hubUrl == "") and "хаб не подключён" or (dot(H.ok) .. (#H.users + 1) .. " тут · " .. H.total .. " всего")
        else
            statusL.Text = isStaff() and ('<font color="#7ab4ff"><b>' .. G.role:upper() .. "</b></font>") or (dot(A.ok) .. "админов: " .. #A.admins)
        end
    end
    showSub("global")
end)() end

-- ================= ВКЛАДКА TROLL =================
local TrollScroll = makeScrollPage(TrollTab)

createCard(TrollScroll, {title = "Throwing Out (Fling Loop)", desc = "Выкидывает игроков по очереди, оставаясь на месте", init = false,
    onToggle = function(s)
        if s then
            Features.startThrowingOut()
            notify("Troll", "Fling Loop активирован. Будь осторожен!")
        else
            Features.stopThrowingOut()
            notify("Troll", "Fling Loop выключен")
        end
    end})

-- ================= ВКЛАДКА BACKGROUND =================
local BACKGROUNDS = {
    {name = "Бойкиссер",   url = "https://i.pinimg.com/736x/18/2e/ac/182eac29fc3f925e6ecfb0e772734475.jpg", file = "WannacryAssets/bg_boykisser.png"},
    {name = "Бойкиссер 2", url = "https://i.pinimg.com/736x/e2/e0/7c/e2e07c7ffd56efd84b5cfcf62ff0f517.jpg", file = "WannacryAssets/bg_boykisser2.png"},
    {name = "Шрек",        url = "https://kartinkof.club/uploads/posts/2022-03/1648288029_6-kartinkof-club-p-oboi-na-pk-memi-7.png", file = "WannacryAssets/bg_shrek.png"},
    {name = "Котость",     url = "https://i.pinimg.com/736x/e5/b3/58/e5b358bd5d5d90b760c47a718ed6d22f.jpg", file = "WannacryAssets/bg_kotost.png"},
    {name = "Котик в небе", url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROIwfFB6qto_Pq-sPFWfe1uYhEfLKiZMmvxPnAbW08mLRZZw3PJ8WPMLg&s=10", file = "WannacryAssets/bg_new.png"},
}
local BgCustomAsset = ""
local BgUI = {}

local function currentBgAsset()
    if State.BgIndex == 0 then return BgCustomAsset end
    local b = BACKGROUNDS[State.BgIndex]
    return (b and b.asset) or ""
end

local function applyBackground()
    local a = currentBgAsset()
    local on = State.BgEnabled and a ~= ""
    BgImage.Image = a
    BgImage.ImageTransparency = State.BgTransparency
    BgImage.Visible = on
    BgDim.BackgroundTransparency = 1 - State.BgDim
    if BgUI.pvImg then
        BgUI.pvImg.Image = a
        BgUI.pvImg.ImageTransparency = State.BgTransparency
        BgUI.pvImg.Visible = a ~= ""
        BgUI.pvDim.BackgroundTransparency = 1 - State.BgDim
        BgUI.pvEmpty.Visible = a == ""
        BgUI.pvEmpty.Text = (State.BgIndex ~= 0 and BACKGROUNDS[State.BgIndex] and not BACKGROUNDS[State.BgIndex].loaded) and "Загрузка картинки…" or "Картинка не выбрана"
    end
    for i, th in ipairs(BgUI.thumbs or {}) do
        local sel = State.BgIndex == i
        tw(th.stroke, 0.25, {Thickness = sel and 2.5 or 1, Transparency = sel and 0 or 0.55})
    end
end

do
    local scroll = makeScrollPage(BackgroundTab)
    local card = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = scroll})
    soft(card, {radius = 20, transparency = 0.95, sheen = false})
    new("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = card})
    new("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card})

    local head = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 2, Parent = card})
    new("TextLabel", {Text = "Фон меню", FontFace = F.Bold, TextSize = 16, TextColor3 = Glass.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = head})
    new("TextLabel", {Text = "Картинка на заднем плане окна", FontFace = F.Regular, TextSize = 12, TextColor3 = Glass.TextDim, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, -80, 0, 16), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = head})
    BgUI.switch = makeSwitch(head, State.BgEnabled, function(v)
        State.BgEnabled = v
        applyBackground()
    end, UDim2.new(1, 0, 0.5, 0))

    local pv = new("Frame", {Size = UDim2.new(1, 0, 0, 210), BackgroundColor3 = Glass.Bg, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = nextOrder(), ZIndex = 2, Parent = card})
    corner(pv, 16)
    rim(pv, 1, 0.55)
    BgUI.pvImg = new("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, Visible = false, ZIndex = 3, Parent = pv})
    corner(BgUI.pvImg, 16)
    BgUI.pvDim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Glass.Bg, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 4, Parent = pv})
    corner(BgUI.pvDim, 16)
    local mockSide = new("Frame", {Position = UDim2.fromOffset(10, 10), Size = UDim2.new(0.22, 0, 1, -20), ZIndex = 5, Parent = pv})
    soft(mockSide, {radius = 10, transparency = 0.93, sheen = false})
    new("Frame", {Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 0, 14), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 6, Parent = mockSide})
    for i = 0, 3 do
        local c = new("Frame", {Position = UDim2.new(0.22, 20, 0, 14 + i * 34), Size = UDim2.new(0.78, -30, 0, 26), ZIndex = 5, Parent = pv})
        soft(c, {radius = 8, transparency = 0.94, sheen = false})
    end
    BgUI.pvEmpty = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.61, 0, 0.82, 0), Size = UDim2.fromOffset(200, 20),
        BackgroundTransparency = 1, Text = "Картинка не выбрана", FontFace = F.Medium, TextSize = 13, TextColor3 = Glass.TextMute, ZIndex = 6, Parent = pv,
    })
    local tag = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, -10), Size = UDim2.fromOffset(110, 24),
        Text = "Предпросмотр", FontFace = F.Medium, TextSize = 12, TextColor3 = Glass.Text, ZIndex = 7, Parent = pv,
    })
    liquid(tag, {radius = "full", transparency = 0.88, sheen = false, glint = false, lens = false})

    rowLabel(new("Frame", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = card}), "Картинка")
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 76), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 2, Parent = card})
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
    BgUI.thumbs = {}
    for i, bg in ipairs(BACKGROUNDS) do
        local th = new("ImageButton", {
            Size = UDim2.new(1 / #BACKGROUNDS, -6, 1, 0), BackgroundColor3 = Glass.White, BackgroundTransparency = 0.92,
            Image = "", ScaleType = Enum.ScaleType.Crop, AutoButtonColor = false, LayoutOrder = i, ZIndex = 3, Parent = row,
        })
        corner(th, 12)
        local st = rim(th, 1, 0.55)
        local shade = new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Glass.Black, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 4, Parent = th})
        corner(shade, 12)
        new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({KP(0, 1), KP(1, 0)}), Parent = shade})
        new("TextLabel", {
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -4), Size = UDim2.new(1, -16, 0, 16), BackgroundTransparency = 1,
            Text = bg.name, FontFace = F.Semi, TextSize = 12, TextColor3 = Glass.White, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = th,
        })
        local loading = new("TextLabel", {Size = UDim2.new(1, 0, 1, -20), BackgroundTransparency = 1, Text = "…", FontFace = F.Bold, TextSize = 18, TextColor3 = Glass.TextMute, ZIndex = 4, Parent = th})
        local sc = new("UIScale", {Parent = th})
        th.MouseEnter:Connect(function() tw(sc, 0.25, {Scale = 1.04}, Enum.EasingStyle.Back) end)
        th.MouseLeave:Connect(function() tw(sc, 0.2, {Scale = 1}) end)
        th.MouseButton1Click:Connect(guarded(function()
            State.BgIndex = i
            if not State.BgEnabled then BgUI.switch.set(true) else applyBackground() end
            applyBackground()
        end))
        BgUI.thumbs[i] = {button = th, stroke = st, loading = loading}
    end

    makeSlider(card, "Прозрачность картинки", 0, 0.95, State.BgTransparency, function(v) State.BgTransparency = v; applyBackground() end)
    makeSlider(card, "Затемнение", 0, 0.9, State.BgDim, function(v) State.BgDim = v; applyBackground() end)

    makeInput(card, "Своя картинка — ссылка на jpg/png", "https://...", "", function(url)
        url = (url or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if not url:match("^https?://") then return end
        task.spawn(function()
            local h = 0
            for i = 1, #url do h = (h * 31 + url:byte(i)) % 2147483647 end
            local asset = LoadCustomAsset(url, "WannacryAssets/bg_custom_" .. h .. ".png")
            if ScriptUnloaded then return end
            if asset == "" then notify("Background", "Не удалось загрузить картинку") return end
            BgCustomAsset = asset
            State.BgIndex = 0
            if not State.BgEnabled then BgUI.switch.set(true) end
            applyBackground()
            notify("Background", "Своя картинка установлена")
        end)
    end)

    task.spawn(function()
        for i, bg in ipairs(BACKGROUNDS) do
            if ScriptUnloaded then return end
            bg.asset = LoadCustomAsset(bg.url, bg.file)
            bg.loaded = true
            local th = BgUI.thumbs[i]
            if th and th.button.Parent then
                th.button.Image = bg.asset
                th.loading.Text = (bg.asset == "") and "×" or ""
            end
            applyBackground()
        end
    end)
    applyBackground()
end

-- ================= ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК =================
local activeTab = nil
local function pageWidth() return Pages.AbsoluteSize.X / windowScale() end

local function switchTab(id, dir)
    if activeTab == id then return end
    local oldId = activeTab
    if not dir then
        local a = oldId and table.find(TAB_ORDER, oldId) or 0
        local b = table.find(TAB_ORDER, id) or 1
        dir = (b >= a) and 1 or -1
    end
    activeTab = id
    PlaceholderText.Visible = false
    local info = TabButtons[id]
    HeaderTitle.Text = info.def.title
    HeaderSub.Text = info.def.sub

    local W = pageWidth()
    local newPage = PageFrames[id]
    local oldPage = oldId and PageFrames[oldId]
    if oldPage then
        tw(oldPage, 0.45, {Position = UDim2.fromOffset(-dir * W, 0)}).Completed:Connect(function()
            if activeTab ~= oldId then oldPage.Visible = false end
        end)
    end
    newPage.Visible = true
    newPage.Position = UDim2.fromOffset(dir * W * (oldPage and 1 or 0.08), 0)
    tw(newPage, 0.45, {Position = UDim2.fromOffset(0, 0)})

    for tid, t in pairs(TabButtons) do
        tw(t.label, 0.25, {TextColor3 = (tid == id) and Glass.Text or Glass.TextDim})
    end
    local targetPos = UDim2.fromOffset(8, TAB_Y0 + (info.index - 1) * TAB_STEP)
    if not TabHighlight.Visible then
        TabHighlight.Visible = true
        TabHighlight.Position = targetPos
        TabHighlightScale.Scale = 0.8
        tw(TabHighlightScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
    else
        tw(TabHighlight, 0.5, {Position = targetPos}, Enum.EasingStyle.Back)
        tw(TabHighlight, 0.16, {Size = UDim2.new(1, -8, 0, TAB_H + 8)}).Completed:Connect(function()
            tw(TabHighlight, 0.35, {Size = UDim2.new(1, -16, 0, TAB_H)}, Enum.EasingStyle.Back)
        end)
    end
end
for id, t in pairs(TabButtons) do
    t.button.MouseButton1Click:Connect(function() switchTab(id) end)
    t.button.MouseEnter:Connect(function() if activeTab ~= id then tw(t.label, 0.2, {TextColor3 = Glass.Text}) end end)
    t.button.MouseLeave:Connect(function() if activeTab ~= id then tw(t.label, 0.2, {TextColor3 = Glass.TextDim}) end end)
end

switchTab("Visuals")

-- ================= СВАЙПЫ МЕЖДУ ВКЛАДКАМИ =================
do
    local sw = {active = false, engaged = false, start = nil, dx = 0, t0 = 0}
    local function inPages(p)
        local a, s = Pages.AbsolutePosition, Pages.AbsoluteSize
        return p.X >= a.X and p.Y >= a.Y and p.X <= a.X + s.X and p.Y <= a.Y + s.Y
    end
    connect(UserInputService.InputBegan, function(input)
        if not isOpen or not isPress(input) then return end
        local p = pointerPos(input)
        if not inPages(p) then return end
        sw.active, sw.engaged, sw.start, sw.dx, sw.t0 = true, false, p, 0, os.clock()
    end)
    connect(UserInputService.InputChanged, function(input)
        if not sw.active or not isMove(input) then return end
        if UI.dragLock then sw.active = false; return end
        local d = pointerPos(input) - sw.start
        if not sw.engaged then
            if math.abs(d.X) > 14 and math.abs(d.X) > math.abs(d.Y) * 1.4 then
                sw.engaged = true; UI.swiping = true
            elseif math.abs(d.Y) > 14 then
                sw.active = false
                return
            else
                return
            end
        end
        sw.dx = d.X / windowScale()
        local page = activeTab and PageFrames[activeTab]
        if page then
            local idx = table.find(TAB_ORDER, activeTab)
            local hasNext = (sw.dx < 0 and idx < #TAB_ORDER) or (sw.dx > 0 and idx > 1)
            page.Position = UDim2.fromOffset(sw.dx * (hasNext and 0.6 or 0.18), 0)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if not isPress(input) or not sw.active then return end
        sw.active = false
        if not sw.engaged then return end
        local vel = sw.dx / math.max(os.clock() - sw.t0, 0.05)
        local idx = activeTab and table.find(TAB_ORDER, activeTab) or 0
        local dir = 0
        if sw.dx < -60 or vel < -700 then dir = 1 elseif sw.dx > 60 or vel > 700 then dir = -1 end
        local target = TAB_ORDER[idx + dir]
        if dir ~= 0 and target then
            switchTab(target, dir)
        elseif activeTab then
            tw(PageFrames[activeTab], 0.45, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back)
        end
        task.delay(0.08, function() UI.swiping = false end)
    end)
end

-- ================= ЭФФЕКТ КЛИКА =================
local function clickRipple(p)
    local ring = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y), Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Glass.White, BackgroundTransparency = 0.82, ZIndex = 60, Parent = ScreenGui,
    })
    corner(ring, "full")
    local st = rim(ring, 1.6, 0)
    local ring2 = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y), Size = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1, ZIndex = 60, Parent = ScreenGui,
    })
    corner(ring2, "full")
    local st2 = new("UIStroke", {Color = Color3.fromRGB(180, 225, 255), Thickness = 1, Transparency = 0.3, Parent = ring2})
    tw(ring, 0.6, {Size = UDim2.fromOffset(96, 96), BackgroundTransparency = 1})
    tw(st, 0.6, {Transparency = 1, Thickness = 0.5})
    tw(ring2, 0.4, {Size = UDim2.fromOffset(54, 54)})
    tw(st2, 0.4, {Transparency = 1})
    task.delay(0.65, function() ring:Destroy(); ring2:Destroy() end)
end
connect(UserInputService.InputBegan, function(input)
    if not isOpen or ScriptUnloaded or not isPress(input) then return end
    local p = pointerPos(input)
    clickRipple(p)
end)

-- ================= ОТКРЫТИЕ / ЗАКРЫТИЕ =================
local baseScale = 1
local function updateBaseScale()
    local vp = ScreenGui.AbsoluteSize
    if vp.X <= 0 or vp.Y <= 0 then return end
    baseScale = math.clamp(math.min((vp.X - 24) / WIN_W, (vp.Y - 24) / WIN_H), 0.45, 1)
    if isOpen then HolderScale.Scale = baseScale end
end
connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), updateBaseScale)

local function setMenuOpen(v)
    if v == isOpen then return end
    isOpen = v
    SFX.play(v and "open" or "close")
    if v then
        updateBaseScale()
        Holder.Visible = true
        HolderScale.Scale = baseScale * 0.86
        tw(HolderScale, 0.5, {Scale = baseScale}, Enum.EasingStyle.Back)
        tw(GlassBlur, 0.35, {Size = 14})
    else
        tw(GlassBlur, 0.25, {Size = 0})
        local t = tw(HolderScale, 0.2, {Scale = baseScale * 0.88}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        t.Completed:Connect(function() if not isOpen then Holder.Visible = false end end)
    end
end
local function ToggleMenu() setMenuOpen(not isOpen) end

CloseButton.MouseButton1Click:Connect(function() setMenuOpen(false) end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if not WC_CFG.capturing and input.KeyCode == WC_CFG.menuKeyCode() then ToggleMenu() end
end)

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not WC_CFG.settings.logoButton then
    local fab = glassButton(ScreenGui, "W", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(46, 46), ZIndex = 40,
    }, {radius = "full", transparency = 0.86, textSize = 20, font = F.Heavy})
    fab.MouseButton1Click:Connect(ToggleMenu)
end

-- ================= ПЕРЕТАСКИВАНИЕ =================
local function makeDraggable(handle)
    local dragging, startInput, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            startInput = pointerPos(input)
            startPos = Holder.Position
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and isMove(input) then
            local d = pointerPos(input) - startInput
            Holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if isPress(input) then dragging = false end
    end)
end
makeDraggable(HeaderDrag)
makeDraggable(SidebarDrag)

-- ================= ВЫГРУЗКА =================
local function Unload()
    if ScriptUnloaded then return end
    for k, v in pairs(State) do
        if type(v) == "boolean" and k:match("Enabled$") and k ~= "UISoundsEnabled" then State[k] = false end
    end
    for _, fn in ipairs({
        Features.applyFog, Features.applySky, Features.applyFullbright, Features.applyWorld,
        Features.applyCustomTime, Features.applyAtmosphere, Features.applyParticles, Features.applyTrails,
        Features.resetJumpCircle, Features.destroyMotionBlur
    }) do pcall(fn) end
    pcall(Features.applyAnimationPack, false)
    pcall(Features.applyDBDAnimations, false)
    pcall(Cos.unmountAll)
    pcall(Cos.clearAllRemote)
    pcall(function() if WC_PROJ.gui then WC_PROJ.gui:Destroy() end end)
    pcall(function() if Cos.folder then Cos.folder:Destroy() end end)
    pcall(Features.applyKorblox, false)
    pcall(Features.applyHeadless, false)
    pcall(Features.stopThrowingOut)
    pcall(Features.stopStrafe)
    pcall(Features.stopFly)
    pcall(Features.applyCoreHud, false)

    ScriptUnloaded = true
    for k in pairs(State.Cos) do State.Cos[k] = nil end
    espEnabled = false
    for model in pairs(activeESPs) do pcall(RemoveESP, model) end
    pcall(function() RunService:UnbindFromRenderStep(_genv.__WC_ASPECT_BIND) end)
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    table.clear(Conns)
    for _, g in ipairs({ScreenGui, HUD_Gui, ESPGui, GlassBlur, SFX.folder}) do pcall(function() g:Destroy() end) end
    _genv.__WC_UNLOAD = nil
end
_genv.__WC_UNLOAD = Unload
UnloadButton.MouseButton1Click:Connect(Unload)

-- ================= ПЕРЕ-ПРИМЕНЕНИЕ ПРИ РЕСПАВНЕ =================
connect(player.CharacterAdded, function()
    task.delay(0.7, function()
        if ScriptUnloaded then return end
        if State.TrailsEnabled then Features.applyTrails() end
        if State.JumpCircleEnabled then Features.setupJumpCircle() end
        if State.AnimationPackEnabled then Features.applyAnimationPack(true) end
        if State.AtmosphereEnabled then Features.applyAtmosphere() end
        if State.DBDAnimationEnabled then Features.applyDBDAnimations(true) end
        Cos.refreshAll()
        if State.KorbloxEnabled then Features.applyKorblox(true) end
        if State.HeadlessEnabled then Features.applyHeadless(true) end
        if State.StrafeEnabled then Features.startStrafe() end
        if State.FlyEnabled then Features.stopFly(); Features.startFly() end
        CreateCharacterPreview()
    end)
end)

task.spawn(function()
    if not player.Character then player.CharacterAdded:Wait(); task.wait(0.5) end
    if not ScriptUnloaded then CreateCharacterPreview() end
end)

if not WC_CFG.autoloaded then Cos.load() end
if Cos.onChanged then pcall(Cos.onChanged) end
task.spawn(function()
    Tex.await()
    if not player.Character then player.CharacterAdded:Wait(); task.wait(0.7) end
    if not ScriptUnloaded and next(Cos.active) == nil then Cos.refreshAll() end
end)

updateBaseScale()
-- ================= ВКЛАДКА SETTINGS + КНОПКА-ЛОГОТИП =================
do (function()
    local S = WC_CFG.settings
    local scroll = makeScrollPage(SettingsTab)

    -- ---------- кнопка-логотип под HUD: открывает/закрывает меню ----------
    local logoBtn = new("TextButton", {
        Name = "WCLogoButton", Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(44, 44),
        Position = UDim2.fromOffset(12, 10), ZIndex = 5, Visible = S.logoButton, Parent = HUD_Gui,
    })
    liquid(logoBtn, {radius = "full", transparency = 0.86})
    local logoImg = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1, Image = logoAsset or "", ScaleType = Enum.ScaleType.Crop, ZIndex = 6, Parent = logoBtn,
    })
    corner(logoImg, "full")
    if not logoAsset or logoAsset == "" then
        logoImg.Visible = false
        new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "W", FontFace = F.Heavy, TextSize = 20, TextColor3 = Glass.Text, ZIndex = 6, Parent = logoBtn})
    end
    local ring = new("UIStroke", {Color = Glass.White, Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = logoBtn})
    local lsc = new("UIScale", {Parent = logoBtn})
    logoBtn.MouseEnter:Connect(function() tw(lsc, 0.25, {Scale = 1.08}, Enum.EasingStyle.Back) end)
    logoBtn.MouseLeave:Connect(function() tw(lsc, 0.2, {Scale = 1}) end)
    logoBtn.MouseButton1Down:Connect(function() tw(lsc, 0.1, {Scale = 0.92}) end)
    logoBtn.MouseButton1Up:Connect(function() tw(lsc, 0.25, {Scale = 1.05}, Enum.EasingStyle.Back) end)
    logoBtn.MouseButton1Click:Connect(function() ToggleMenu() end)

    -- позиция: сразу под плашками HUD, а если HUD выключен — на их месте
    local function placeLogo()
        if HUD_Root.Visible then
            logoBtn.Position = UDim2.fromOffset(12, 10 + HUD_Root.AbsoluteSize.Y + 8)
        else
            logoBtn.Position = UDim2.fromOffset(12, 10)
        end
    end
    connect(HUD_Root:GetPropertyChangedSignal("Visible"), placeLogo)
    connect(HUD_Root:GetPropertyChangedSignal("AbsoluteSize"), placeLogo)
    placeLogo()
    -- кольцо-индикатор, когда меню открыто
    local lastOpen = nil
    connect(RunService.RenderStepped, function()
        if isOpen ~= lastOpen then
            lastOpen = isOpen
            tw(ring, 0.3, {Transparency = isOpen and 0.25 or 1})
        end
    end)

    -- ---------- раздел МЕНЮ ----------
    makeSection(scroll, "МЕНЮ")
    local keyRow = new("Frame", {Size = UDim2.new(1, -4, 0, 60), LayoutOrder = nextOrder(), Parent = scroll})
    soft(keyRow, {radius = 18, transparency = 0.95})
    new("TextLabel", {Position = UDim2.fromOffset(18, 11), Size = UDim2.new(1, -170, 0, 20), BackgroundTransparency = 1, Text = "Клавиша меню", FontFace = F.Semi, TextSize = 15, TextColor3 = Glass.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = keyRow})
    new("TextLabel", {Position = UDim2.fromOffset(18, 31), Size = UDim2.new(1, -170, 0, 16), BackgroundTransparency = 1, Text = "Нажми на кнопку, потом нужную клавишу (Esc — отмена)", FontFace = F.Regular, TextSize = 12, TextColor3 = Glass.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = keyRow})
    local keyBtn, keyLbl = glassButton(keyRow, S.menuKey, {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(140, 36)},
        {radius = "full", transparency = 0.86, textSize = 13, font = F.Bold})
    keyBtn.MouseButton1Click:Connect(function()
        if WC_CFG.capturing then return end
        WC_CFG.capturing = true
        keyLbl.Text = "Нажми клавишу…"
        keyLbl.TextColor3 = Color3.fromRGB(255, 210, 120)
    end)
    connect(UserInputService.InputBegan, function(input)
        if not WC_CFG.capturing or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        if kc ~= Enum.KeyCode.Escape then
            S.menuKey = kc.Name
            WC_CFG.saveSettings()
            notify("Клавиша меню", "Теперь меню открывается на " .. kc.Name)
        end
        keyLbl.Text = S.menuKey
        keyLbl.TextColor3 = Glass.Text
        -- отпускаем флаг в следующем кадре, чтобы это же нажатие не открыло/закрыло меню
        task.defer(function() WC_CFG.capturing = false end)
    end)

    makeToggle(scroll, "Кнопка-логотип под HUD (открыть / закрыть меню)", S.logoButton, function(v)
        S.logoButton = v
        logoBtn.Visible = v
        WC_CFG.saveSettings()
    end)

    -- ---------- раздел КОНФИГИ ----------
    makeSection(scroll, "КОНФИГИ")
    if not WC_CFG.canFile then
        new("TextLabel", {Size = UDim2.new(1, -4, 0, 40), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Text = "Экзекьютор не умеет работать с файлами — конфиги недоступны.", FontFace = F.Medium, TextSize = 13, TextColor3 = Glass.TextMute, TextWrapped = true, Parent = scroll})
        return
    end
    local nameBox = makeInput(scroll, "Имя конфига", "например: legit, красиво, pvp", "", function() end)
    local actions = new("Frame", {Size = UDim2.new(1, -4, 0, 38), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = scroll})
    local saveBtn = glassButton(actions, "Сохранить текущие настройки", {Size = UDim2.new(0.62, -4, 1, 0)}, {radius = "full", transparency = 0.82, textSize = 13, font = F.Bold})
    local refreshBtn = glassButton(actions, "Обновить список", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.38, -4, 1, 0)}, {radius = "full", transparency = 0.9, textSize = 12})
    local listHolder = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = scroll})
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listHolder})
    new("TextLabel", {Size = UDim2.new(1, -4, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Text = "★ — конфиг загружается автоматически при запуске скрипта. В конфиг попадают визуалы, движение, ESP и косметика.", FontFace = F.Regular, TextSize = 11, TextColor3 = Glass.TextMute, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = scroll})

    -- применить загруженный конфиг на лету
    local function applyLoaded(d)
        local before = {}
        for i, c in ipairs(WC_CFG.cards) do before[i] = State[c.key] == true end
        WC_CFG.applyToState(d)
        for i, c in ipairs(WC_CFG.cards) do
            local now = State[c.key] == true
            pcall(c.sw.set, now, true)
            if c.onToggle then
                if before[i] and now then
                    pcall(c.onToggle, false); pcall(c.onToggle, true)  -- переприменить с новыми параметрами
                elseif before[i] ~= now then
                    pcall(c.onToggle, now)
                end
            end
        end
        pcall(function()
            currentHue, currentSat, currentVal = currentESPColor:ToHSV()
            applyESPColor()
        end)
        pcall(Cos.refreshAll)
        pcall(Cos.save)
        if Cos.onChanged then pcall(Cos.onChanged) end
    end

    local renderList
    renderList = function()
        for _, c in ipairs(listHolder:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        local names = WC_CFG.list()
        if #names == 0 then
            new("TextLabel", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "Сохранённых конфигов пока нет", FontFace = F.Medium, TextSize = 13, TextColor3 = Glass.TextMute, Parent = listHolder})
            return
        end
        for i, name in ipairs(names) do
            local row = new("Frame", {Size = UDim2.new(1, 0, 0, 50), LayoutOrder = i, Parent = listHolder})
            soft(row, {radius = 16, transparency = 0.95})
            local isAuto = S.autoload == name
            new("TextLabel", {Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -392, 1, 0), BackgroundTransparency = 1, RichText = true,
                Text = (isAuto and '<font color="#ffd166">★</font> ' or "") .. name, FontFace = F.Semi, TextSize = 14, TextColor3 = Glass.Text,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = row})
            local function btn(text, w, x, o)
                return glassButton(row, text, {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(w, 32)}, o or {radius = "full", transparency = 0.88, textSize = 12})
            end
            local delB, delL = btn("Удалить", 82, -8, {radius = "full", transparency = 0.88, textSize = 12, textColor = Color3.fromRGB(255, 140, 130)})
            local autoB = btn(isAuto and "★ Авто" or "☆ Авто", 76, -96)
            local saveB = btn("Перезаписать", 102, -178)
            local loadB = btn("Загрузить", 88, -286, {radius = "full", transparency = 0.8, textSize = 12, font = F.Bold})
            row.Size = UDim2.new(1, 0, 0, 50)
            loadB.MouseButton1Click:Connect(guarded(function()
                local d = WC_CFG.read(name)
                if not d then notify("Конфиги", "Не удалось прочитать «" .. name .. "»"); return end
                applyLoaded(d)
                notify("Конфиг загружен", name .. " — функции и переключатели применены")
            end))
            saveB.MouseButton1Click:Connect(guarded(function()
                local ok, res = WC_CFG.save(name)
                notify("Конфиги", ok and ("Перезаписан: " .. name) or ("Ошибка: " .. tostring(res)))
            end))
            autoB.MouseButton1Click:Connect(guarded(function()
                S.autoload = (S.autoload == name) and "" or name
                WC_CFG.saveSettings()
                renderList()
            end))
            delB.MouseButton1Click:Connect(guarded(function()
                if delL.Text ~= "Точно?" then
                    delL.Text = "Точно?"
                    task.delay(3, function() if delL.Parent then delL.Text = "Удалить" end end)
                    return
                end
                if WC_CFG.delete(name) then
                    if S.autoload == name then S.autoload = ""; WC_CFG.saveSettings() end
                    notify("Конфиги", "Удалён: " .. name)
                else
                    notify("Конфиги", "Экзекьютор не умеет удалять файлы")
                end
                renderList()
            end))
        end
    end
    saveBtn.MouseButton1Click:Connect(guarded(function()
        local name = WC_CFG.safeName(nameBox.Text)
        if name == "" then notify("Конфиги", "Впиши имя конфига (буквы, цифры, - _ пробел)"); return end
        local ok, res = WC_CFG.save(name)
        if ok then
            nameBox.Text = ""
            notify("Конфиг сохранён", res)
            renderList()
        else
            notify("Конфиги", "Ошибка: " .. tostring(res))
        end
    end))
    refreshBtn.MouseButton1Click:Connect(guarded(renderList))
    renderList()
end)() end

-- автозагруженный конфиг: включить функции, которые в нём были включены
if WC_CFG.autoloaded then
    task.spawn(function()
        if not player.Character then player.CharacterAdded:Wait(); task.wait(0.5) end
        for _, c in ipairs(WC_CFG.cards) do
            if State[c.key] == true and c.onToggle then pcall(c.onToggle, true) end
        end
        notify("Конфиг загружен", "Автозагрузка: " .. WC_CFG.settings.autoload)
    end)
end

-- ================= ВКЛАДКА INFO: экзекьютор + апдейт-лист =================
do (function()
    local VERSION = "2.7.4"
    local LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/sergeydb-wq/scripts/wannaclient/wannacry.lua"))()'
    local CHANGELOG = {
        {v = "2.7.4", date = "18.11.2026", items = {
            "Aspect: ESP и метки сжимаются к центру ровно как картинка Roblox (правильное направление по умолчанию)",
        }},
        {v = "2.7.3", date = "18.11.2026", items = {
            "Aspect: ползунок «Поправка ESP» — подгони один раз, и ESP/метки совпадут с картинкой при любой силе",
            "ESP и метки считаются по нормальной камере, растяжение Aspect применяется отдельно",
        }},
        {v = "2.7.2", date = "18.11.2026", items = {
            "ESP и метки считаются по фактической матрице камеры в самом конце кадра — точно совпадают с картинкой при любом Aspect",
            "Повторный запуск скрипта больше не растягивает экран дважды (старый Aspect снимается)",
        }},
        {v = "2.7.1", date = "17.11.2026", items = {
            "Исправлено: при включённом Aspect ESP, ники и метки снова стоят ровно на персонаже",
        }},
        {v = "2.7", date = "17.11.2026", items = {
            "Вкладка Info: экзекьютор, поддержка функций, апдейт-лист",
        }},
        {v = "2.6", date = "17.11.2026", items = {
            "ESP, ники, метки «wannacry» и облачка чата больше не съезжают при Aspect",
            "Единая проекция мир → экран для любого разрешения и аспект-ратио",
        }},
        {v = "2.5", date = "17.11.2026", items = {
            "Вкладка Settings: своя клавиша меню",
            "Кнопка-логотип под HUD — открывает и закрывает меню",
            "Конфиги: сохранить, загрузить, перезаписать, удалить, автозагрузка ★",
        }},
        {v = "2.4", date = "17.11.2026", items = {
            "Облачко с сообщением над игроком, который написал в Global Chat",
            "Метка «wannacry» над юзерами скрипта",
            "Иконки Lucide вместо символов, которые Roblox не отображал",
        }},
        {v = "2.3", date = "17.11.2026", items = {
            "Вкладка Community: Global Chat в стиле меню",
            "«На сервере»: видно юзеров скрипта и их косметику (хаб на Wispbyte)",
            "Админ-панель: муты, баны, тролль, защита, админы + закрытый чат админов",
        }},
        {v = "2.2", date = "17.11.2026", items = {
            "24 косметики с 3D-превью: крылья, шапки, питомцы, рюкзаки, плащи",
            "Текстуры косметики рисуются кодом (PNG) и кэшируются",
            "KorBlox — чёрная игла с синим кончиком, исправлен звук включения",
            "Strafe быстрее и резче: скорость, резкость, Bhop",
            "Исправлены баги: ESP после выгрузки, HUD Roblox, Fly после респавна, Fling",
        }},
    }

    local scroll = makeScrollPage(InfoTab)
    local GREEN, RED = Color3.fromRGB(90, 220, 130), Color3.fromRGB(255, 110, 110)

    local function card(h)
        local f = new("Frame", {Size = UDim2.new(1, -4, 0, h), LayoutOrder = nextOrder(), Parent = scroll})
        soft(f, {radius = 18, transparency = 0.95})
        return f
    end
    local function text(parent, t, x, y, w, h, size, font, color, rich)
        return new("TextLabel", {
            Position = UDim2.fromOffset(x, y), Size = UDim2.new(w, w == 1 and -x - 14 or 0, 0, h), BackgroundTransparency = 1,
            Text = t, RichText = rich or false, FontFace = font or F.Medium, TextSize = size or 13, TextColor3 = color or Glass.Text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = parent,
        })
    end

    -- ---------- шапка ----------
    local head = card(78)
    local logo = new("ImageLabel", {Position = UDim2.fromOffset(16, 15), Size = UDim2.fromOffset(48, 48), BackgroundTransparency = 0.9, BackgroundColor3 = Glass.White, Image = logoAsset or "", ScaleType = Enum.ScaleType.Crop, ZIndex = 2, Parent = head})
    corner(logo, 14)
    text(head, "wannacry", 78, 16, 1, 24, 20, F.Bold)
    text(head, "версия " .. VERSION .. "  ·  " .. CHANGELOG[1].date, 78, 42, 1, 18, 12, F.Medium, Glass.TextDim)
    local copyB = glassButton(head, "Копировать loadstring", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(170, 34)},
        {radius = "full", transparency = 0.86, textSize = 12})
    copyB.MouseButton1Click:Connect(guarded(function()
        local clip = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if clip then clip(LOADSTRING); notify("Скопировано", "Loadstring wannacry в буфере обмена")
        else notify("Не получилось", "Экзекьютор не умеет копировать в буфер") end
    end))

    -- ---------- экзекьютор ----------
    makeSection(scroll, "ЭКЗЕКЬЮТОР")
    local exName, exVer = "Неизвестно", ""
    pcall(function()
        if identifyexecutor then
            local a, b = identifyexecutor()
            exName, exVer = tostring(a or exName), tostring(b or "")
        elseif getexecutorname then
            exName = tostring(getexecutorname())
        end
    end)
    local level = "?"
    pcall(function()
        local f = getthreadidentity or getidentity or get_thread_identity or (syn and syn.get_thread_identity)
        if f then level = tostring(f()) end
    end)
    local ex = card(64)
    text(ex, exName .. ((exVer ~= "" and exVer ~= "nil") and ('  <font color="#8a8fa8">' .. exVer .. "</font>") or ""), 18, 12, 1, 22, 16, F.Bold, Glass.Text, true)
    text(ex, "Уровень доступа (identity): " .. level, 18, 36, 1, 16, 12, F.Medium, Glass.TextDim)

    local req = (syn and syn.request) or (http and http.request) or http_request or request
    local checks = {
        {"HTTP-запросы (request)", req ~= nil, "Global Chat, хаб, админ-панель"},
        {"Файлы (writefile / readfile)", type(writefile) == "function" and type(readfile) == "function", "конфиги, кэш текстур"},
        {"getcustomasset", type(getcustomasset) == "function", "текстуры косметики, логотип"},
        {"listfiles", type(listfiles) == "function", "список конфигов"},
        {"delfile", type(delfile) == "function", "удаление конфигов"},
        {"gethui", type(gethui) == "function", "спрятанный от игры интерфейс"},
        {"setclipboard", (setclipboard or toclipboard) ~= nil, "копирование loadstring и токенов"},
    }
    local okCount = 0
    for _, c in ipairs(checks) do if c[2] then okCount += 1 end end
    local sup = card(30 + #checks * 26)
    text(sup, ("Поддерживается %d из %d функций"):format(okCount, #checks), 18, 8, 1, 18, 13, F.Semi,
        okCount == #checks and GREEN or Glass.Text)
    for i, c in ipairs(checks) do
        local y = 30 + (i - 1) * 26
        local dot = new("Frame", {Position = UDim2.fromOffset(18, y + 2), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = c[2] and GREEN or RED, BackgroundTransparency = 0.75, ZIndex = 2, Parent = sup})
        corner(dot, "full")
        WC_ICON.make(c[2] and "check" or "x", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ImageColor3 = c[2] and GREEN or RED, ZIndex = 3, Parent = dot})
        text(sup, c[1] .. '  <font color="#8a8fa8">— ' .. c[3] .. "</font>", 46, y, 1, 22, 12, F.Medium, Glass.Text, true)
    end

    -- ---------- игра ----------
    makeSection(scroll, "ИГРА")
    local gm = card(64)
    local placeL = text(gm, "Place " .. tostring(game.PlaceId), 18, 12, 1, 20, 14, F.Semi)
    text(gm, ("Игроков на сервере: %d  ·  JobId: %s"):format(#Players:GetPlayers(), game.JobId ~= "" and game.JobId:sub(1, 8) .. "…" or "—"), 18, 36, 1, 16, 12, F.Medium, Glass.TextDim)
    task.spawn(function()
        local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
        if ok and type(info) == "table" and info.Name and placeL.Parent then
            placeL.Text = tostring(info.Name) .. "  ·  " .. tostring(game.PlaceId)
        end
    end)

    -- ---------- апдейт-лист ----------
    makeSection(scroll, "АПДЕЙТ-ЛИСТ")
    for idx, e in ipairs(CHANGELOG) do
        local h = 40 + #e.items * 20
        local c = card(h)
        text(c, "v" .. e.v .. (idx == 1 and '  <font color="#5be38a">· новое</font>' or ""), 18, 10, 1, 20, 15, F.Bold, Glass.Text, true)
        text(c, e.date, 18, 10, 1, 20, 12, F.Medium, Glass.TextMute).TextXAlignment = Enum.TextXAlignment.Right
        for i, it in ipairs(e.items) do
            text(c, "•  " .. it, 22, 32 + (i - 1) * 20, 1, 18, 12, F.Regular, Glass.TextDim)
        end
    end
end)() end

notify("wannacry загружен", UserInputService.KeyboardEnabled and (WC_CFG.settings.menuKey .. " или логотип слева сверху — меню") or "Нажми на логотип слева сверху, чтобы открыть меню")