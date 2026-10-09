local ADDON_NAME = ...

local TITLE = "|cff33ff99Roll Window Mover|r"
local MOVER_WIDTH, MOVER_HEIGHT = 280, 72
local MIN_SCALE, MAX_SCALE, SCALE_STEP = 0.5, 2, 0.05
local DEFAULT_X, DEFAULT_Y = 0, 200

local db
local mover
local applying = false
local hooked = {}
local blizzardPoints = {}

local function Print(message)
    print(TITLE .. ": " .. message)
end

local function Pack(...)
    return { n = select("#", ...), ... }
end

local function Targets()
    local list = {}
    if _G.GroupLootContainer then
        list[#list + 1] = _G.GroupLootContainer
    elseif _G.GroupLootFrame1 then
        list[#list + 1] = _G.GroupLootFrame1
    end
    return list
end

local function Anchor(frame)
    if applying or not db.point then
        return
    end
    applying = true
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOM", mover, "BOTTOM", 0, 0)
    applying = false
end

local function Hook(frame)
    if hooked[frame] then
        return
    end
    hooked[frame] = true
    if frame:GetNumPoints() > 0 then
        blizzardPoints[frame] = Pack(frame:GetPoint(1))
    end
    hooksecurefunc(frame, "SetPoint", function(self, ...)
        if applying then
            return
        end
        blizzardPoints[self] = Pack(...)
        Anchor(self)
    end)
end

local function ApplyAll()
    for _, frame in ipairs(Targets()) do
        Hook(frame)
        frame:SetScale(db.scale)
        Anchor(frame)
    end
end

local function ResizeMover()
    mover:SetSize(MOVER_WIDTH * db.scale, MOVER_HEIGHT * db.scale)
end

local function PlaceMover()
    mover:ClearAllPoints()
    if db.point then
        mover:SetPoint(db.point, UIParent, db.relativePoint, db.x, db.y)
        return
    end
    local target = Targets()[1]
    local x = target and target:GetCenter()
    local bottom = target and target:GetBottom()
    if x and bottom then
        local ratio = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
        mover:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x * ratio, bottom * ratio)
    else
        mover:SetPoint("BOTTOM", UIParent, "BOTTOM", DEFAULT_X, DEFAULT_Y)
    end
end

local function SavePosition()
    local point, _, relativePoint, x, y = mover:GetPoint(1)
    db.point, db.relativePoint, db.x, db.y = point, relativePoint, x, y
    ApplyAll()
end

local function SetScale(value)
    value = math.floor(math.min(MAX_SCALE, math.max(MIN_SCALE, value)) * 100 + 0.5) / 100
    db.scale = value
    ResizeMover()
    ApplyAll()
    return value
end

local function Unlock()
    if not db.point then
        PlaceMover()
    end
    mover:Show()
    Print("unlocked. Drag the blue box, scroll to resize, right-click or /rollmove lock to save.")
end

local function Lock()
    if not mover:IsShown() then
        return
    end
    mover:Hide()
    SavePosition()
    Print("locked. Position saved.")
end

local function Reset()
    db.point, db.relativePoint, db.x, db.y = nil, nil, nil, nil
    db.scale = 1
    mover:Hide()
    ResizeMover()
    for _, frame in ipairs(Targets()) do
        frame:SetScale(1)
        local saved = blizzardPoints[frame]
        if saved then
            applying = true
            frame:ClearAllPoints()
            frame:SetPoint(unpack(saved, 1, saved.n))
            applying = false
        end
    end
    Print("reset to the default Blizzard position.")
end

local function CreateMover()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:RegisterForDrag("LeftButton")

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.1, 0.55, 1, 0.35)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    label:SetText("Loot roll window\nDrag to move, scroll to resize\nRight-click to lock")

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            Lock()
        end
    end)
    frame:SetScript("OnMouseWheel", function(_, delta)
        SetScale(db.scale + delta * SCALE_STEP)
    end)
    frame:Hide()
    return frame
end

local function PrintHelp()
    Print("commands:")
    print("  /rollmove - unlock or lock the loot roll window")
    print("  /rollmove scale 0.5-2 - set the window scale")
    print("  /rollmove reset - restore the default position and scale")
end

SLASH_ROLLWINDOWMOVERFOREVER1 = "/rollmove"
SlashCmdList.ROLLWINDOWMOVERFOREVER = function(input)
    if not db then
        return
    end
    local command, value = strsplit(" ", strtrim((input or ""):lower()), 2)
    if command == "" then
        if mover:IsShown() then
            Lock()
        else
            Unlock()
        end
    elseif command == "unlock" then
        Unlock()
    elseif command == "lock" then
        Lock()
    elseif command == "reset" then
        Reset()
    elseif command == "scale" and tonumber(value) then
        Print("scale set to " .. SetScale(tonumber(value)) .. ".")
    else
        PrintHelp()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("START_LOOT_ROLL")
events:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= ADDON_NAME then
            return
        end
        self:UnregisterEvent("ADDON_LOADED")
        RollWindowMoverForeverDB = RollWindowMoverForeverDB or {}
        db = RollWindowMoverForeverDB
        if type(db.scale) ~= "number" then
            db.scale = 1
        end
        mover = CreateMover()
        ResizeMover()
        PlaceMover()
    end
    if db then
        ApplyAll()
    end
end)
