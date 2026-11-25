local ADDON_NAME = ...

local TITLE = "|cff33ff99Roll Window Mover|r"
local MOVER_WIDTH, MOVER_HEIGHT = 280, 72
local MIN_SCALE, MAX_SCALE, SCALE_STEP = 0.5, 2, 0.05
local DEFAULT_X, DEFAULT_Y = 0, 200
local TEST_ROLL_TIME = 60000
local TEST_ITEMS = {
    {
        rollID = 987651,
        id = 19019,
        name = "Thunderfury, Blessed Blade of the Windseeker",
        quality = 5,
        icon = "Interface\\Icons\\INV_Sword_39",
    },
    {
        rollID = 987652,
        id = 19364,
        name = "Ashkandi, Greatsword of the Brotherhood",
        quality = 4,
        icon = "Interface\\Icons\\INV_Sword_24",
    },
    {
        rollID = 987653,
        id = 13335,
        name = "Deathcharger's Reins",
        quality = 4,
        icon = "Interface\\Icons\\Spell_Nature_Swiftness",
    },
    {
        rollID = 987654,
        id = 13965,
        name = "Blackhand's Breadth",
        quality = 3,
        icon = "Interface\\Icons\\INV_Misc_Monsterclaw_04",
    },
    {
        rollID = 987655,
        id = 13446,
        name = "Major Healing Potion",
        quality = 2,
        icon = "Interface\\Icons\\INV_Potion_52",
    },
    {
        rollID = 987656,
        id = 17182,
        name = "Sulfuras, Hand of Ragnaros",
        quality = 5,
        icon = "Interface\\Icons\\INV_Hammer_Unique_Sulfuras",
    },
    {
        rollID = 987657,
        id = 32837,
        name = "Warglaive of Azzinoth",
        quality = 5,
        icon = "Interface\\Icons\\INV_Weapon_Glave_01",
    },
    {
        rollID = 987658,
        id = 22691,
        name = "Corrupted Ashbringer",
        quality = 4,
        icon = "Interface\\Icons\\INV_Sword_24",
    },
    {
        rollID = 987659,
        id = 50818,
        name = "Invincible's Reins",
        quality = 4,
        icon = "Interface\\Icons\\Ability_Mount_Pegasus",
    },
    {
        rollID = 987660,
        id = 45693,
        name = "Mimiron's Head",
        quality = 4,
        icon = "Interface\\Icons\\INV_Misc_Head_ClockworkGoblin_01",
    },
}

local testItemsByRollID = {}
for _, item in ipairs(TEST_ITEMS) do
    testItemsByRollID[item.rollID] = item
end

local db
local mover
local minimapBtn
local settingsFrame
local combatHidden = false
local stoppingTest = false
local rollQueue = {}
local applying = false
local hooked = {}
local blizzardPoints = {}
local testActive = false
local testStarted
local realGetLootRollItemInfo
local realGetLootRollTimeLeft
local realGetLootRollItemLink
local realRollOnLoot
local dismissing = {}
local events

local function Print(message)
    print(TITLE .. ": " .. message)
end

local function Pack(...)
    return { n = select("#", ...), ... }
end

local function Contains(list, value)
    for _, item in ipairs(list) do
        if item == value then
            return true
        end
    end
    return false
end

local function IsTestRoll(rollID)
    local num = tonumber(rollID)
    return num ~= nil and testItemsByRollID[num] ~= nil
end

local HookFrameLifecycle

local function AddSlotBorder(slotFrame, r, g, b, a)
    local top = slotFrame:CreateTexture(nil, "BORDER")
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(1)
    top:SetColorTexture(r, g, b, a)

    local bottom = slotFrame:CreateTexture(nil, "BORDER")
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
    bottom:SetColorTexture(r, g, b, a)

    local left = slotFrame:CreateTexture(nil, "BORDER")
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(1)
    left:SetColorTexture(r, g, b, a)

    local right = slotFrame:CreateTexture(nil, "BORDER")
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(1)
    right:SetColorTexture(r, g, b, a)

    slotFrame.borders = { top, bottom, left, right }
end

local function SetSlotBorderColor(slotFrame, r, g, b, a)
    if slotFrame and slotFrame.borders then
        for _, tex in ipairs(slotFrame.borders) do
            tex:SetColorTexture(r, g, b, a or 1)
        end
    end
end

local function SetButtonEnabled(btn, enabled)
    if enabled then
        btn:Enable()
        btn:SetAlpha(1)
    else
        btn:Disable()
        btn:SetAlpha(0.35)
    end
end

local function CreateFallbackGroupLootFrame(name, id)
    local ref = _G.GroupLootFrame1
    local w, h = 243, 84
    if ref and ref.GetSize then
        local rw, rh = ref:GetSize()
        if rw and rw > 50 and rh and rh > 30 then
            w, h = rw, rh
        end
    end

    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetID(id)
    frame:SetSize(w, h)
    frame:SetFrameStrata((ref and ref.GetFrameStrata and ref:GetFrameStrata()) or "DIALOG")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    frame.isFallbackRollFrame = true

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.06, 0.07, 0.09, 0.92)
    AddSlotBorder(frame, 0.5, 0.5, 0.5, 1)

    local iconFrame = CreateFrame("Button", name .. "IconFrame", frame)
    iconFrame:SetSize(36, 36)
    iconFrame:SetPoint("LEFT", frame, "LEFT", 10, 4)
    local iconTex = iconFrame:CreateTexture(nil, "ARTWORK")
    iconTex:SetAllPoints()
    iconFrame.Icon = iconTex
    frame.IconFrame = iconFrame

    iconFrame:SetScript("OnEnter", function(self)
        local rollID = frame.rollID
        if not rollID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if IsTestRoll(rollID) then
            local item = testItemsByRollID[tonumber(rollID)]
            local link = item and item.resolvedLink
            if link then
                GameTooltip:SetHyperlink(link)
            end
        elseif GameTooltip.SetLootRollItem then
            pcall(GameTooltip.SetLootRollItem, GameTooltip, rollID)
        end
        GameTooltip:Show()
    end)
    iconFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local function MakeRollButton(suffix, size, normalTex, pushTex, highlightTex, rollType, label)
        local btn = CreateFrame("Button", name .. suffix, frame)
        btn:SetSize(size, size)
        btn:SetNormalTexture(normalTex)
        btn:SetPushedTexture(pushTex)
        btn:SetHighlightTexture(highlightTex, "ADD")
        btn.rollType = rollType
        btn:SetScript("OnClick", function()
            if RollOnLoot and frame.rollID then
                RollOnLoot(frame.rollID, rollType)
            end
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        return btn
    end

    local passBtn = MakeRollButton(
        "PassButton",
        24,
        "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
        "Interface\\Buttons\\UI-GroupLoot-Pass-Down",
        "Interface\\Buttons\\UI-GroupLoot-Pass-Highlight",
        0,
        PASS or "Pass"
    )
    passBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)

    local needBtn = MakeRollButton(
        "NeedButton",
        28,
        "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
        "Interface\\Buttons\\UI-GroupLoot-Dice-Down",
        "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight",
        1,
        NEED or "Need"
    )
    needBtn:SetPoint("RIGHT", passBtn, "LEFT", -2, 0)

    local greedBtn = MakeRollButton(
        "GreedButton",
        28,
        "Interface\\Buttons\\UI-GroupLoot-Coin-Up",
        "Interface\\Buttons\\UI-GroupLoot-Coin-Down",
        "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight",
        2,
        GREED or "Greed"
    )
    greedBtn:SetPoint("TOP", needBtn, "BOTTOM", 0, 2)

    local deBtn = MakeRollButton(
        "DisenchantButton",
        28,
        "Interface\\Buttons\\UI-GroupLoot-DE-Up",
        "Interface\\Buttons\\UI-GroupLoot-DE-Down",
        "Interface\\Buttons\\UI-GroupLoot-DE-Highlight",
        3,
        ROLL_DISENCHANT or "Disenchant"
    )
    deBtn:SetPoint("TOP", passBtn, "BOTTOM", 0, 2)

    frame.PassButton = passBtn
    frame.NeedButton = needBtn
    frame.GreedButton = greedBtn
    frame.DisenchantButton = deBtn

    local nameText = frame:CreateFontString(name .. "Name", "ARTWORK", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", iconFrame, "RIGHT", 8, 2)
    nameText:SetPoint("RIGHT", needBtn, "LEFT", -6, 2)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(true)
    frame.Name = nameText

    local timer = CreateFrame("StatusBar", name .. "Timer", frame)
    timer:SetHeight(7)
    timer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 6)
    timer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 6)
    timer:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    timer:SetStatusBarColor(1, 0.85, 0)
    local timerBg = timer:CreateTexture(nil, "BACKGROUND")
    timerBg:SetAllPoints()
    timerBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
    frame.Timer = timer

    frame:SetScript("OnShow", function(self)
        local rollID = self.rollID
        if not rollID or not GetLootRollItemInfo then
            self:Hide()
            return
        end
        local texture, itemName, _, quality, _, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
        if not itemName then
            self:Hide()
            return
        end
        iconTex:SetTexture(texture)
        nameText:SetText(itemName)
        local r, g, b = 1, 1, 1
        if GetItemQualityColor and quality then
            r, g, b = GetItemQualityColor(quality)
        elseif ITEM_QUALITY_COLORS and quality and ITEM_QUALITY_COLORS[quality] then
            local c = ITEM_QUALITY_COLORS[quality]
            r, g, b = c.r, c.g, c.b
        end
        nameText:SetTextColor(r, g, b)
        SetSlotBorderColor(self, r, g, b, 1)
        SetButtonEnabled(needBtn, canNeed ~= false)
        SetButtonEnabled(greedBtn, canGreed ~= false)
        if canDisenchant then
            deBtn:Show()
            SetButtonEnabled(deBtn, true)
        else
            deBtn:Hide()
        end
        local total = self.rollTime or TEST_ROLL_TIME
        local left = (GetLootRollTimeLeft and GetLootRollTimeLeft(rollID)) or total
        if left > total then
            total = left
        end
        timer:SetMinMaxValues(0, math.max(1, total))
        timer:SetValue(math.max(0, left))
    end)

    frame:SetScript("OnUpdate", function(self)
        if self.rollID and GetLootRollTimeLeft then
            timer:SetValue(math.max(0, GetLootRollTimeLeft(self.rollID) or 0))
        end
    end)

    frame:RegisterEvent("CANCEL_LOOT_ROLL")
    frame:SetScript("OnEvent", function(self, event, rollID)
        if event == "CANCEL_LOOT_ROLL" and rollID == self.rollID then
            self:Hide()
        end
    end)

    frame:Hide()
    return frame
end

local function EnsureGroupLootFrames(count)
    local targetCount = math.max(4, math.min(10, count or (db and db.maxItems) or 10))
    local objType = (_G.GroupLootFrame1 and _G.GroupLootFrame1.GetObjectType and _G.GroupLootFrame1:GetObjectType()) or "Frame"
    for i = 5, targetCount do
        local name = "GroupLootFrame" .. i
        if not _G[name] then
            local ok, f = pcall(CreateFrame, objType, name, UIParent, "GroupLootFrameTemplate")
            if ok and f then
                f:SetID(i)
            else
                CreateFallbackGroupLootFrame(name, i)
            end
        end
        if _G[name] and HookFrameLifecycle then
            HookFrameLifecycle(_G[name])
        end
    end
    if type(NUM_GROUP_LOOT_FRAMES) == "number" and NUM_GROUP_LOOT_FRAMES < targetCount then
        NUM_GROUP_LOOT_FRAMES = targetCount
    end
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

local function IsDescendantOf(frame, ancestor)
    local current = frame and frame.GetParent and frame:GetParent()
    while current do
        if current == ancestor then
            return true
        end
        current = current.GetParent and current:GetParent()
    end
    return false
end

local function AllGroupLootFrames()
    local list = {}
    local index = 1
    local frame = _G.GroupLootFrame1
    while frame do
        list[#list + 1] = frame
        index = index + 1
        frame = _G["GroupLootFrame" .. index]
    end
    local container = _G.GroupLootContainer
    if container and type(container.rollFrames) == "table" then
        for _, rollFrame in pairs(container.rollFrames) do
            if type(rollFrame) == "table" and not Contains(list, rollFrame) then
                list[#list + 1] = rollFrame
            end
        end
    end
    return list
end

local function ApplyFrameScale(frame, scale)
    local container = _G.GroupLootContainer
    if container and frame ~= container and IsDescendantOf(frame, container) then
        frame:SetScale(1)
    else
        frame:SetScale(scale)
    end
end

local function ApplyAll()
    local scale = (db and db.scale) or 1
    for _, frame in ipairs(Targets()) do
        Hook(frame)
        frame:SetScale(scale)
        Anchor(frame)
    end
    for _, frame in ipairs(AllGroupLootFrames()) do
        ApplyFrameScale(frame, scale)
    end
end

local function ResizeMover()
    local w = MOVER_WIDTH * db.scale
    local h = MOVER_HEIGHT * db.scale
    local spacing = 3 * db.scale
    mover:SetSize(w, h)
    if mover.slots then
        local maxVisible = math.max(1, math.min(10, db.maxItems or 4))
        for i = 2, 10 do
            local slot = mover.slots[i]
            if slot then
                slot:SetSize(w, h)
                slot:ClearAllPoints()
                local prev = (i == 2) and mover or mover.slots[i - 1]
                slot:SetPoint("BOTTOM", prev, "TOP", 0, spacing)
                if slot.text then
                    if i == maxVisible then
                        slot.text:SetText("Item " .. i .. "  ▲ Grows upwards ▲")
                    else
                        slot.text:SetText("Item " .. i)
                    end
                end
                if i <= maxVisible then
                    slot:Show()
                else
                    slot:Hide()
                end
            end
        end
        local extraHeight = (maxVisible - 1) * (h + spacing)
        mover:SetClampRectInsets(0, 0, extraHeight, 0)
    end
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
    if settingsFrame and settingsFrame.Refresh then
        settingsFrame:Refresh()
    end
    return value
end

local function Unlock()
    if not db.point then
        PlaceMover()
    end
    mover:Show()
    ResizeMover()
    Print("unlocked. Drag any box, scroll to resize, right-click or /rollmove lock to save.")
    if settingsFrame and settingsFrame.Refresh then
        settingsFrame:Refresh()
    end
end

local function Lock()
    if not mover:IsShown() then
        return
    end
    mover:Hide()
    SavePosition()
    Print("locked. Position saved.")
    if settingsFrame and settingsFrame.Refresh then
        settingsFrame:Refresh()
    end
end

local function TestFrames()
    local list = {}
    for _, frame in ipairs(AllGroupLootFrames()) do
        if frame.IsShown and frame:IsShown() and frame.rollID and IsTestRoll(frame.rollID) then
            list[#list + 1] = frame
        end
    end
    return list
end

local function ActiveRollFrames()
    local list = {}
    for _, frame in ipairs(AllGroupLootFrames()) do
        if frame.IsShown and frame:IsShown() and frame.rollID then
            list[#list + 1] = frame
        end
    end
    return list
end

local function UpdateTestStackLayout()
    local active = {}
    for i = 1, 10 do
        local frame = _G["GroupLootFrame" .. i]
        if frame and frame:IsShown() and frame.rollID and IsTestRoll(frame.rollID) then
            active[#active + 1] = frame
        end
    end
    local spacing = 3
    local prev = nil
    applying = true
    for _, frame in ipairs(active) do
        frame:ClearAllPoints()
        if not prev then
            frame:SetPoint("BOTTOM", mover, "BOTTOM", 0, 0)
        else
            frame:SetPoint("BOTTOM", prev, "TOP", 0, spacing)
        end
        ApplyFrameScale(frame, db.scale or 1)
        prev = frame
    end
    applying = false
end

local function RestoreRollApi()
    if realRollOnLoot then
        RollOnLoot = realRollOnLoot
        realRollOnLoot = nil
    end
    if not realGetLootRollItemInfo then
        return
    end
    GetLootRollItemInfo = realGetLootRollItemInfo
    GetLootRollTimeLeft = realGetLootRollTimeLeft
    GetLootRollItemLink = realGetLootRollItemLink
    realGetLootRollItemInfo, realGetLootRollTimeLeft, realGetLootRollItemLink = nil, nil, nil
end

local function StopTest()
    if stoppingTest then
        return
    end
    stoppingTest = true
    testActive = false
    rollQueue = {}
    for i = 1, 10 do
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            frame:Hide()
            frame.rollID = nil
        end
    end
    local container = _G.GroupLootContainer
    if container then
        if type(container.rollFrames) == "table" then
            local hasReal = false
            for k, f in pairs(container.rollFrames) do
                if type(f) == "table" and (not f.rollID or IsTestRoll(f.rollID)) then
                    f:Hide()
                    f.rollID = nil
                    container.rollFrames[k] = nil
                elseif f then
                    hasReal = true
                end
            end
            if not hasReal then
                container.maxIndex = 0
            end
        else
            container.maxIndex = 0
        end
        if type(GroupLootContainer_Update) == "function" then
            pcall(GroupLootContainer_Update, container)
        end
    end
    if StaticPopup_Hide then
        pcall(StaticPopup_Hide, "CONFIRM_LOOT_ROLL")
        pcall(StaticPopup_Hide, "LOOT_BIND_CONFIRM")
    end
    RestoreRollApi()
    stoppingTest = false
end

local function Reset()
    db.point, db.relativePoint, db.x, db.y = nil, nil, nil, nil
    db.scale = 1
    db.maxItems = 4
    db.hideInCombat = false
    db.showMinimapButton = true
    mover:Hide()
    StopTest()
    PlaceMover()
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
    for _, frame in ipairs(AllGroupLootFrames()) do
        frame:SetScale(1)
    end
    if minimapBtn then
        minimapBtn:Show()
    end
    if settingsFrame and settingsFrame.Refresh then
        settingsFrame:Refresh()
    end
    Print("reset to the default Blizzard position and settings.")
end

local function GetButtonRollType(btn)
    if not btn then
        return 0
    end
    if type(btn.rollType) == "number" then
        return btn.rollType
    end
    local name = (btn.GetName and btn:GetName()) or ""
    if name:find("Pass") then
        return 0
    elseif name:find("Need") then
        return 1
    elseif name:find("Greed") then
        return 2
    elseif name:find("Disenchant") or name:find("DE") then
        return 3
    elseif name:find("Transmog") then
        return 4
    elseif name:find("RollButton$") then
        return 1
    end
    return 0
end

local function HookTestButtons(frame)
    local buttons = {
        frame.PassButton,
        frame.NeedButton,
        frame.GreedButton,
        frame.DisenchantButton,
        frame.TransmogButton,
    }
    local name = frame.GetName and frame:GetName()
    if name then
        buttons[#buttons + 1] = _G[name .. "PassButton"]
        buttons[#buttons + 1] = _G[name .. "NeedButton"]
        buttons[#buttons + 1] = _G[name .. "GreedButton"]
        buttons[#buttons + 1] = _G[name .. "DisenchantButton"]
        buttons[#buttons + 1] = _G[name .. "TransmogButton"]
        buttons[#buttons + 1] = _G[name .. "RollButton"]
    end
    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            if child and child.IsObjectType and child:IsObjectType("Button") then
                buttons[#buttons + 1] = child
            end
        end
    end
    for _, btn in ipairs(buttons) do
        if btn and type(btn.HookScript) == "function" and not hooked[btn] then
            hooked[btn] = true
            btn:HookScript("OnClick", function(self)
                local current = self
                while current do
                    local rollID = current.rollID
                    if rollID and IsTestRoll(rollID) then
                        local rollType = GetButtonRollType(self)
                        DismissTestRoll(rollID, rollType)
                        return
                    end
                    current = current:GetParent()
                end
                frame:Hide()
                frame.rollID = nil
            end)
        end
    end
end

local origOpenNewFrame

local function ContainerHasFrame(container, frame)
    if not container or type(container.rollFrames) ~= "table" then
        return false
    end
    for _, existing in pairs(container.rollFrames) do
        if existing == frame then
            return true
        end
    end
    return false
end

local function FindRollFrameByRollID(rollID)
    for _, frame in ipairs(AllGroupLootFrames()) do
        if frame.IsShown and frame:IsShown() and frame.rollID == rollID then
            return frame
        end
    end
    return nil
end

local function OpenRealRollInFallbackFrame(rollID, rollTime)
    local maxAllowed = (db and db.maxItems) or 4
    EnsureGroupLootFrames(maxAllowed)
    for i = 1, maxAllowed do
        local frame = _G["GroupLootFrame" .. i]
        if frame and not frame:IsShown() then
            frame.rollID = rollID
            frame.rollTime = rollTime
            local okShow = pcall(frame.Show, frame)
            if (not okShow or not frame:IsShown()) and i >= 5 and not frame.isFallbackRollFrame then
                frame:Hide()
                local fallback = CreateFallbackGroupLootFrame("GroupLootFrame" .. i .. "_Fallback", i)
                _G["GroupLootFrame" .. i] = fallback
                if HookFrameLifecycle then
                    HookFrameLifecycle(fallback)
                end
                fallback.rollID = rollID
                fallback.rollTime = rollTime
                fallback:Show()
                frame = fallback
            end
            if frame:IsShown() then
                local container = _G.GroupLootContainer
                if container and type(GroupLootContainer_AddFrame) == "function" and not ContainerHasFrame(container, frame) then
                    pcall(GroupLootContainer_AddFrame, container, frame)
                end
                return frame
            end
        end
    end
    return nil
end

local CheckRollQueue

local function HookTestFrame(frame)
    HookTestButtons(frame)
    if not hooked["drag" .. tostring(frame)] then
        hooked["drag" .. tostring(frame)] = true
        frame:EnableMouseWheel(true)
        frame:RegisterForDrag("LeftButton")
        frame:HookScript("OnDragStart", function()
            if mover and mover:IsShown() then
                mover:StartMoving()
            end
        end)
        frame:HookScript("OnDragStop", function()
            if mover and mover:IsShown() then
                mover:StopMovingOrSizing()
                SavePosition()
                UpdateTestStackLayout()
            end
        end)
        frame:HookScript("OnMouseWheel", function(_, delta)
            SetScale(db.scale + delta * SCALE_STEP)
            UpdateTestStackLayout()
        end)
    end
    if not hooked["test" .. tostring(frame)] then
        hooked["test" .. tostring(frame)] = true
        frame:HookScript("OnHide", function()
            if stoppingTest or not testActive then
                return
            end
            CheckRollQueue()
            UpdateTestStackLayout()
            if #TestFrames() == 0 and #rollQueue == 0 then
                StopTest()
            end
        end)
    end
end

CheckRollQueue = function()
    local maxAllowed = (db and db.maxItems) or 4
    if testActive then
        while #rollQueue > 0 and #TestFrames() < maxAllowed do
            local nextRoll = table.remove(rollQueue, 1)
            for i = 1, 10 do
                local frame = _G["GroupLootFrame" .. i]
                if frame and not frame:IsShown() then
                    frame.rollID = nextRoll.rollID
                    frame.rollTime = nextRoll.rollTime
                    HookTestFrame(frame)
                    frame:Show()
                    break
                end
            end
        end
        UpdateTestStackLayout()
    else
        while #rollQueue > 0 and #ActiveRollFrames() < maxAllowed do
            local nextRoll = table.remove(rollQueue, 1)
            if nextRoll.isReal then
                if origOpenNewFrame then
                    origOpenNewFrame(nextRoll.rollID, nextRoll.rollTime)
                end
                if not FindRollFrameByRollID(nextRoll.rollID) and #ActiveRollFrames() < maxAllowed then
                    OpenRealRollInFallbackFrame(nextRoll.rollID, nextRoll.rollTime)
                end
            end
        end
    end
end

HookFrameLifecycle = function(frame)
    if not frame or type(frame.HookScript) ~= "function" or hooked["lifecycle" .. tostring(frame)] then
        return
    end
    hooked["lifecycle" .. tostring(frame)] = true
    frame:HookScript("OnShow", function(self)
        if db then
            ApplyFrameScale(self, db.scale or 1)
        end
    end)
    frame:HookScript("OnHide", function(self)
        if not testActive and not stoppingTest then
            local container = _G.GroupLootContainer
            if container and type(GroupLootContainer_RemoveFrame) == "function" and ContainerHasFrame(container, self) then
                pcall(GroupLootContainer_RemoveFrame, container, self)
            end
            CheckRollQueue()
        end
    end)
end

function DismissTestRoll(rollID, rollType)
    local num = tonumber(rollID)
    if not num or not testItemsByRollID[num] or dismissing[num] then
        return
    end
    dismissing[num] = true

    local testItem = testItemsByRollID[num]
    local itemName = (testItem and testItem.resolvedName) or "item"
    rollType = rollType or 0
    if rollType == 1 then
        Print(itemName .. ": Need")
    elseif rollType == 2 then
        Print(itemName .. ": Greed")
    elseif rollType == 3 then
        Print(itemName .. ": Disenchant")
    elseif rollType == 4 then
        Print(itemName .. ": Transmog")
    else
        Print(itemName .. ": Pass")
    end

    if StaticPopup_Hide then
        pcall(StaticPopup_Hide, "CONFIRM_LOOT_ROLL")
        pcall(StaticPopup_Hide, "LOOT_BIND_CONFIRM")
    end

    for _, frame in ipairs(AllGroupLootFrames()) do
        if tonumber(frame.rollID) == num then
            frame:Hide()
            frame.rollID = nil
        end
    end

    dismissing[num] = nil

    CheckRollQueue()
    UpdateTestStackLayout()

    if #TestFrames() == 0 and #rollQueue == 0 then
        StopTest()
    end
end

local function StartTest(count)
    EnsureGroupLootFrames(10)
    count = tonumber(count) or 1
    count = math.floor(math.min(#TEST_ITEMS, math.max(1, count)))
    StopTest()

    local getItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    for i = 1, count do
        local testItem = TEST_ITEMS[i]
        local name, link, quality, icon
        if getItemInfo then
            name, link, quality, _, _, _, _, _, _, icon = getItemInfo(testItem.id)
        end
        testItem.resolvedName = name or testItem.name
        testItem.resolvedQuality = quality or testItem.quality
        testItem.resolvedIcon = icon or testItem.icon
        testItem.resolvedLink = link or ("item:" .. testItem.id)
    end

    local itemInfo, timeLeft, itemLink = GetLootRollItemInfo, GetLootRollTimeLeft, GetLootRollItemLink
    realGetLootRollItemInfo, realGetLootRollTimeLeft, realGetLootRollItemLink = itemInfo, timeLeft, itemLink
    testStarted = GetTime()

    GetLootRollItemLink = function(rollID, ...)
        local testItem = testItemsByRollID[tonumber(rollID)]
        if testItem then
            return testItem.resolvedLink
        end
        return itemLink and itemLink(rollID, ...)
    end

    GetLootRollItemInfo = function(rollID, ...)
        local testItem = testItemsByRollID[tonumber(rollID)]
        if testItem then
            return testItem.resolvedIcon, testItem.resolvedName, 1, testItem.resolvedQuality, true, true, true, false
        end
        return itemInfo and itemInfo(rollID, ...)
    end

    GetLootRollTimeLeft = function(rollID, ...)
        local testItem = testItemsByRollID[tonumber(rollID)]
        if testItem then
            return math.max(0, TEST_ROLL_TIME - (GetTime() - testStarted) * 1000)
        end
        return timeLeft and timeLeft(rollID, ...)
    end

    if not realRollOnLoot and RollOnLoot then
        realRollOnLoot = RollOnLoot
        RollOnLoot = function(rollID, rollType)
            if IsTestRoll(rollID) then
                DismissTestRoll(rollID, rollType)
                return
            end
            return realRollOnLoot(rollID, rollType)
        end
    end

    testActive = true
    local maxAllowed = db.maxItems or 4
    local initialShow = math.min(count, maxAllowed)

    for i = 1, initialShow do
        local testItem = TEST_ITEMS[i]
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            frame.rollID = testItem.rollID
            frame.rollTime = TEST_ROLL_TIME
            HookTestFrame(frame)
            local okShow = pcall(frame.Show, frame)
            if (not okShow or not frame:IsShown()) and i >= 5 and not frame.isFallbackRollFrame then
                frame:Hide()
                local fallback = CreateFallbackGroupLootFrame("GroupLootFrame" .. i .. "_Fallback", i)
                _G["GroupLootFrame" .. i] = fallback
                HookFrameLifecycle(fallback)
                fallback.rollID = testItem.rollID
                fallback.rollTime = TEST_ROLL_TIME
                HookTestFrame(fallback)
                fallback:Show()
            end
        end
    end

    for i = initialShow + 1, count do
        table.insert(rollQueue, { rollID = TEST_ITEMS[i].rollID, rollTime = TEST_ROLL_TIME })
    end

    UpdateTestStackLayout()

    local frames = TestFrames()
    if #frames == 0 and #rollQueue == 0 then
        StopTest()
        Print("could not open test roll window(s).")
        return
    end

    for _, frame in ipairs(frames) do
        HookTestFrame(frame)
    end

    local queuedNotice = (#rollQueue > 0) and (" (" .. #rollQueue .. " in queue)") or ""
    Print("showing " .. #frames .. " test roll window(s)" .. queuedNotice .. ". Click Need/Greed/Pass to test, or /rollmove test to hide.")
end

local function CreateMover()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:RegisterForDrag("LeftButton")

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.1, 0.55, 1, 0.35)
    AddSlotBorder(frame, 0.2, 0.7, 1, 0.6)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    label:SetText("Item 1 (Base Anchor)\nDrag to move, scroll to resize\nRight-click to lock")

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
        UpdateTestStackLayout()
    end)
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            Lock()
        end
    end)
    frame:SetScript("OnMouseWheel", function(_, delta)
        SetScale(db.scale + delta * SCALE_STEP)
        UpdateTestStackLayout()
    end)

    frame.slots = {}
    for i = 2, 10 do
        local slot = CreateFrame("Frame", nil, frame)
        slot:SetFrameStrata("MEDIUM")
        slot:SetFrameLevel(1)
        slot:EnableMouse(true)
        slot:EnableMouseWheel(true)
        slot:RegisterForDrag("LeftButton")

        local alpha = math.max(0.05, 0.26 - (i - 2) * 0.024)
        local bg = slot:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.55, 1, alpha)
        AddSlotBorder(slot, 0.2, 0.7, 1, alpha * 2)

        local txt = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        txt:SetPoint("CENTER")
        txt:SetText("Item " .. i)
        slot.text = txt

        slot:SetScript("OnDragStart", function()
            frame:StartMoving()
        end)
        slot:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
            SavePosition()
            UpdateTestStackLayout()
        end)
        slot:SetScript("OnMouseUp", function(_, button)
            if button == "RightButton" then
                Lock()
            end
        end)
        slot:SetScript("OnMouseWheel", function(_, delta)
            SetScale(db.scale + delta * SCALE_STEP)
            UpdateTestStackLayout()
        end)

        frame.slots[i] = slot
    end

    frame:Hide()
    return frame
end

local function UpdateMinimapButtonPosition()
    if not minimapBtn then
        return
    end
    local angle = math.rad(db.minimapPos or 220)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    minimapBtn:ClearAllPoints()
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    if db.showMinimapButton then
        minimapBtn:Show()
    else
        minimapBtn:Hide()
    end
end

local function MinimapButton_OnUpdate()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale
    local angle = math.deg(math.atan2(py - my, px - mx))
    if angle < 0 then
        angle = angle + 360
    end
    db.minimapPos = math.floor(angle + 0.5)
    UpdateMinimapButtonPosition()
end

local function ToggleSettings()
    if not settingsFrame then
        return
    end
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
        if settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
    end
end

local function CreateMinimapButton()
    local btn = CreateFrame("Button", "RollWindowMoverMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("AnyUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-Button-Highlight")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(19, 19)
    icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
    icon:SetPoint("CENTER", 0, 0)

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", MinimapButton_OnUpdate)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnClick", function(_, button)
        if IsShiftKeyDown() then
            if testActive then
                StopTest()
                Print("test roll window(s) hidden.")
            else
                StartTest(db.maxItems or 4)
            end
        elseif button == "RightButton" then
            ToggleSettings()
        else
            if mover:IsShown() then
                Lock()
            else
                Unlock()
            end
        end
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(TITLE)
        GameTooltip:AddLine("Left-click: Unlock / Lock anchor", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Open Settings", 1, 1, 1)
        GameTooltip:AddLine("Shift + Left-click: Toggle test rolls", 1, 1, 1)
        GameTooltip:AddLine("Drag: Move around Minimap", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return btn
end

local function CreateSettingsUI()
    local frame = CreateFrame("Frame", "RollWindowMoverSettingsFrame", UIParent)
    frame:SetSize(360, 390)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.09, 0.12, 0.96)
    AddSlotBorder(frame, 0.2, 0.6, 1, 0.8)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -14)
    title:SetText(TITLE .. " Settings")

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    local lockBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    lockBtn:SetSize(150, 26)
    lockBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -42)
    lockBtn:SetScript("OnClick", function()
        if mover:IsShown() then
            Lock()
        else
            Unlock()
        end
    end)

    local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 26)
    resetBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -42)
    resetBtn:SetText("Reset Defaults")
    resetBtn:SetScript("OnClick", function()
        Reset()
    end)

    local sep1 = frame:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(1)
    sep1:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -78)
    sep1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -78)
    sep1:SetColorTexture(0.2, 0.4, 0.6, 0.5)

    local scaleSlider = CreateFrame("Slider", "RWMF_ScaleSlider", frame, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -104)
    scaleSlider:SetWidth(310)
    scaleSlider:SetMinMaxValues(MIN_SCALE, MAX_SCALE)
    scaleSlider:SetValueStep(SCALE_STEP)
    scaleSlider:SetObeyStepOnDrag(true)
    _G[scaleSlider:GetName() .. "Low"]:SetText("50%")
    _G[scaleSlider:GetName() .. "High"]:SetText("200%")
    local scaleTitle = _G[scaleSlider:GetName() .. "Text"]
    scaleTitle:SetText("Window Scale: 100%")
    scaleSlider:SetScript("OnValueChanged", function(_, val)
        val = math.floor((val / SCALE_STEP) + 0.5) * SCALE_STEP
        val = math.floor(val * 100 + 0.5) / 100
        if val ~= db.scale then
            SetScale(val)
        end
        scaleTitle:SetText("Window Scale: " .. math.floor(val * 100 + 0.5) .. "%")
    end)

    local maxSlider = CreateFrame("Slider", "RWMF_MaxItemsSlider", frame, "OptionsSliderTemplate")
    maxSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -156)
    maxSlider:SetWidth(310)
    maxSlider:SetMinMaxValues(1, 10)
    maxSlider:SetValueStep(1)
    maxSlider:SetObeyStepOnDrag(true)
    _G[maxSlider:GetName() .. "Low"]:SetText("1")
    _G[maxSlider:GetName() .. "High"]:SetText("10")
    local maxTitle = _G[maxSlider:GetName() .. "Text"]
    maxTitle:SetText("Max Visible Items: 4")
    maxSlider:SetScript("OnValueChanged", function(_, val)
        val = math.floor(val + 0.5)
        db.maxItems = val
        maxTitle:SetText("Max Visible Items: " .. val)
        EnsureGroupLootFrames(val)
        ResizeMover()
        CheckRollQueue()
    end)

    local maxHint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    maxHint:SetPoint("TOPLEFT", maxSlider, "BOTTOMLEFT", 0, -4)
    maxHint:SetText("Extra items wait in queue until active rolls finish.")

    local combatCheck = CreateFrame("CheckButton", "RWMF_CombatCheck", frame, "UICheckButtonTemplate")
    combatCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -208)
    local combatText = _G[combatCheck:GetName() .. "Text"]
    combatText:SetText("Hide loot roll windows while in combat")
    combatCheck:SetScript("OnClick", function(self)
        db.hideInCombat = self:GetChecked() and true or false
    end)

    local minimapCheck = CreateFrame("CheckButton", "RWMF_MinimapCheck", frame, "UICheckButtonTemplate")
    minimapCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -238)
    local minimapText = _G[minimapCheck:GetName() .. "Text"]
    minimapText:SetText("Show Minimap button")
    minimapCheck:SetScript("OnClick", function(self)
        db.showMinimapButton = self:GetChecked() and true or false
        UpdateMinimapButtonPosition()
    end)

    local sep2 = frame:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -274)
    sep2:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -274)
    sep2:SetColorTexture(0.2, 0.4, 0.6, 0.5)

    local testLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -286)
    testLabel:SetText("Preview Test Rolls:")

    local t1Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t1Btn:SetSize(70, 24)
    t1Btn:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -310)
    t1Btn:SetText("1 Item")
    t1Btn:SetScript("OnClick", function()
        StartTest(1)
    end)

    local t4Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t4Btn:SetSize(70, 24)
    t4Btn:SetPoint("LEFT", t1Btn, "RIGHT", 8, 0)
    t4Btn:SetText("4 Items")
    t4Btn:SetScript("OnClick", function()
        StartTest(4)
    end)

    local t10Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t10Btn:SetSize(74, 24)
    t10Btn:SetPoint("LEFT", t4Btn, "RIGHT", 8, 0)
    t10Btn:SetText("10 Items")
    t10Btn:SetScript("OnClick", function()
        StartTest(10)
    end)

    local tStopBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    tStopBtn:SetSize(74, 24)
    tStopBtn:SetPoint("LEFT", t10Btn, "RIGHT", 8, 0)
    tStopBtn:SetText("Stop Test")
    tStopBtn:SetScript("OnClick", function()
        StopTest()
        Print("test roll window(s) hidden.")
    end)

    local authorInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    authorInfo:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
    authorInfo:SetText("Roll Window Mover Forever v1.2.2 | Type /rollmove help")

    function frame:Refresh()
        lockBtn:SetText(mover:IsShown() and "Lock Anchor" or "Unlock Anchor")
        scaleSlider:SetValue(db.scale or 1)
        scaleTitle:SetText("Window Scale: " .. math.floor((db.scale or 1) * 100 + 0.5) .. "%")
        maxSlider:SetValue(db.maxItems or 4)
        maxTitle:SetText("Max Visible Items: " .. (db.maxItems or 4))
        combatCheck:SetChecked(db.hideInCombat and true or false)
        minimapCheck:SetChecked(db.showMinimapButton and true or false)
    end

    frame:Hide()
    return frame
end

local function PrintHelp()
    Print("commands:")
    print("  /rollmove - unlock or lock the loot roll anchor")
    print("  /rollmove config - open the settings window")
    print("  /rollmove scale <0.5-2> - set the window scale")
    print("  /rollmove max <1-10> - set max visible simultaneous rolls")
    print("  /rollmove combat - toggle hide in combat")
    print("  /rollmove minimap - toggle minimap button")
    print("  /rollmove test [1-10] - preview test roll windows")
    print("  /rollmove reset - restore default position and settings")
end

SLASH_ROLLWINDOWMOVERFOREVER1 = "/rollmove"
SlashCmdList.ROLLWINDOWMOVERFOREVER = function(input)
    if not db then
        return
    end
    local command, value = strsplit(" ", strtrim((input or ""):lower()), 2)
    local testCount
    local numFromCmd = command:match("^test(%d+)$")
    if numFromCmd then
        testCount = tonumber(numFromCmd)
    elseif command == "test1-10" or command == "test1-5" or command == "test1-4" or (command == "test" and (value == "1-10" or value == "1-5" or value == "1-4" or value == "all")) then
        testCount = 10
    elseif command == "test" then
        if value and value ~= "" then
            local num = tonumber(value)
            if num then
                testCount = num
            end
        else
            testCount = testActive and 0 or (db.maxItems or 4)
        end
    elseif command == "stop" then
        testCount = 0
    end

    if testCount ~= nil then
        if testCount <= 0 then
            StopTest()
            Print("test roll window(s) hidden.")
        else
            StartTest(testCount)
        end
        return
    end

    if command == "" then
        if mover:IsShown() then
            Lock()
        else
            Unlock()
        end
    elseif command == "config" or command == "settings" or command == "menu" or command == "options" then
        ToggleSettings()
    elseif command == "unlock" then
        Unlock()
    elseif command == "lock" then
        Lock()
    elseif command == "reset" then
        Reset()
    elseif command == "combat" then
        db.hideInCombat = not db.hideInCombat
        Print("hide in combat: " .. (db.hideInCombat and "|cff33ff99enabled|r" or "|cffff3333disabled|r"))
        if settingsFrame and settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
    elseif command == "minimap" then
        db.showMinimapButton = not db.showMinimapButton
        UpdateMinimapButtonPosition()
        Print("minimap button: " .. (db.showMinimapButton and "|cff33ff99enabled|r" or "|cffff3333disabled|r"))
        if settingsFrame and settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
    elseif command == "max" and tonumber(value) then
        local maxVal = math.floor(math.min(10, math.max(1, tonumber(value))))
        db.maxItems = maxVal
        EnsureGroupLootFrames(maxVal)
        ResizeMover()
        CheckRollQueue()
        Print("max visible items set to " .. maxVal .. ".")
        if settingsFrame and settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
    elseif command == "scale" and tonumber(value) then
        Print("scale set to " .. SetScale(tonumber(value)) .. ".")
    else
        PrintHelp()
    end
end

local function IsRollQueued(rollID)
    for _, entry in ipairs(rollQueue) do
        if entry.rollID == rollID then
            return true
        end
    end
    return false
end

local function InstallOpenNewFrameHook()
    if type(GroupLootFrame_OpenNewFrame) == "function" and not origOpenNewFrame then
        origOpenNewFrame = GroupLootFrame_OpenNewFrame
        GroupLootFrame_OpenNewFrame = function(rollID, rollTime)
            if not IsTestRoll(rollID) and db then
                local maxAllowed = db.maxItems or 4
                if #ActiveRollFrames() >= maxAllowed then
                    if not IsRollQueued(rollID) then
                        table.insert(rollQueue, { rollID = rollID, rollTime = rollTime, isReal = true })
                    end
                    return
                end
            end
            local result = origOpenNewFrame(rollID, rollTime)
            if not IsTestRoll(rollID) and db and not FindRollFrameByRollID(rollID) then
                local maxAllowed = db.maxItems or 4
                if #ActiveRollFrames() < maxAllowed then
                    OpenRealRollInFallbackFrame(rollID, rollTime)
                end
            end
            if db then
                ApplyAll()
            end
            return result
        end
    end
end

events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("START_LOOT_ROLL")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then
            return
        end
        self:UnregisterEvent("ADDON_LOADED")
        RollWindowMoverForeverDB = RollWindowMoverForeverDB or {}
        db = RollWindowMoverForeverDB
        if type(db.scale) ~= "number" then
            db.scale = 1
        end
        if type(db.maxItems) ~= "number" then
            db.maxItems = 4
        end
        if type(db.hideInCombat) ~= "boolean" then
            db.hideInCombat = false
        end
        if type(db.showMinimapButton) ~= "boolean" then
            db.showMinimapButton = true
        end
        if type(db.minimapPos) ~= "number" then
            db.minimapPos = 220
        end

        EnsureGroupLootFrames(10)
        mover = CreateMover()
        ResizeMover()
        PlaceMover()
        minimapBtn = CreateMinimapButton()
        UpdateMinimapButtonPosition()
        settingsFrame = CreateSettingsUI()

        InstallOpenNewFrameHook()

        for i = 1, 10 do
            HookFrameLifecycle(_G["GroupLootFrame" .. i])
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        InstallOpenNewFrameHook()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if db and db.hideInCombat then
            combatHidden = true
            for _, frame in ipairs(AllGroupLootFrames()) do
                frame:SetAlpha(0)
                frame:EnableMouse(false)
            end
            if _G.GroupLootContainer then
                _G.GroupLootContainer:SetAlpha(0)
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if combatHidden then
            combatHidden = false
            for _, frame in ipairs(AllGroupLootFrames()) do
                frame:SetAlpha(1)
                frame:EnableMouse(true)
            end
            if _G.GroupLootContainer then
                _G.GroupLootContainer:SetAlpha(1)
            end
        end
    elseif event == "START_LOOT_ROLL" then
        local rollID = arg1
        local rollTime = arg2
        if rollID and not IsTestRoll(rollID) and not FindRollFrameByRollID(rollID) then
            local maxAllowed = (db and db.maxItems) or 4
            if #ActiveRollFrames() >= maxAllowed then
                if not IsRollQueued(rollID) then
                    table.insert(rollQueue, { rollID = rollID, rollTime = rollTime, isReal = true })
                end
            elseif not origOpenNewFrame then
                OpenRealRollInFallbackFrame(rollID, rollTime)
            end
        end
    end
    if db then
        ApplyAll()
    end
end)
