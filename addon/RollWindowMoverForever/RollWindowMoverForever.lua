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
}

local testItemsByRollID = {}
for _, item in ipairs(TEST_ITEMS) do
    testItemsByRollID[item.rollID] = item
end

local db
local mover
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
    if not _G.GroupLootContainer then
        local index = 2
        local frame = _G["GroupLootFrame" .. index]
        while frame do
            frame:SetScale(db.scale)
            index = index + 1
            frame = _G["GroupLootFrame" .. index]
        end
    end
end

local function ResizeMover()
    local w = MOVER_WIDTH * db.scale
    local h = MOVER_HEIGHT * db.scale
    local spacing = 3 * db.scale
    mover:SetSize(w, h)
    if mover.slots then
        for i = 2, 4 do
            local slot = mover.slots[i]
            if slot then
                slot:SetSize(w, h)
                slot:ClearAllPoints()
                local prev = (i == 2) and mover or mover.slots[i - 1]
                slot:SetPoint("BOTTOM", prev, "TOP", 0, spacing)
            end
        end
    end
    local extraHeight = 3 * (h + spacing)
    mover:SetClampRectInsets(0, 0, extraHeight, 0)
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
    Print("unlocked. Drag any box, scroll to resize, right-click or /rollmove lock to save.")
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
    if not _G.GroupLootContainer then
        local index = 2
        local frame = _G["GroupLootFrame" .. index]
        while frame do
            frame:SetScale(1)
            index = index + 1
            frame = _G["GroupLootFrame" .. index]
        end
    end
    Print("reset to the default Blizzard position.")
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

local function TestFrames()
    local list = {}
    for _, frame in ipairs(AllGroupLootFrames()) do
        if frame.IsShown and frame:IsShown() and frame.rollID and IsTestRoll(frame.rollID) then
            list[#list + 1] = frame
        end
    end
    return list
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
    testActive = false
    for _, frame in ipairs(AllGroupLootFrames()) do
        if frame.rollID and IsTestRoll(frame.rollID) or frame.rollID == 987654 then
            frame:Hide()
            frame.rollID = nil
        end
    end
    local container = _G.GroupLootContainer
    if container then
        if type(GroupLootContainer_RemoveRoll) == "function" then
            for _, item in ipairs(TEST_ITEMS) do
                pcall(GroupLootContainer_RemoveRoll, container, item.rollID)
            end
            pcall(GroupLootContainer_RemoveRoll, container, 987654)
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
end

local function DismissTestRoll(rollID, rollType)
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

    for _, f in ipairs({ GetFramesRegisteredForEvent("CANCEL_LOOT_ROLL") }) do
        local handler = f ~= events and f:GetScript("OnEvent")
        if handler then
            pcall(handler, f, "CANCEL_LOOT_ROLL", num)
        end
    end

    local container = _G.GroupLootContainer
    if container and type(GroupLootContainer_RemoveRoll) == "function" then
        pcall(GroupLootContainer_RemoveRoll, container, num)
    end

    for _, frame in ipairs(AllGroupLootFrames()) do
        if tonumber(frame.rollID) == num then
            frame:Hide()
            frame.rollID = nil
        end
    end

    if container and type(GroupLootContainer_Update) == "function" then
        pcall(GroupLootContainer_Update, container)
    end

    if #TestFrames() == 0 then
        StopTest()
    end
    dismissing[num] = nil
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

local function StartTest(count)
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

    for i = 1, count do
        local testItem = TEST_ITEMS[i]
        local frame = _G["GroupLootFrame" .. i]
        if frame then
            frame.rollID = testItem.rollID
            frame.rollTime = TEST_ROLL_TIME
            HookTestButtons(frame)
            frame:Show()
            if _G.GroupLootContainer and type(GroupLootContainer_AddFrame) == "function" then
                pcall(GroupLootContainer_AddFrame, _G.GroupLootContainer, frame)
            end
        else
            local open = GroupLootContainer_AddRoll or GroupLootContainer_OpenNewFrame or GroupLootFrame_OpenNewFrame
            if open then
                pcall(open, testItem.rollID, TEST_ROLL_TIME)
            else
                for _, f in ipairs({ GetFramesRegisteredForEvent("START_LOOT_ROLL") }) do
                    local handler = f ~= events and f:GetScript("OnEvent")
                    if handler then
                        pcall(handler, f, "START_LOOT_ROLL", testItem.rollID, TEST_ROLL_TIME)
                    end
                end
            end
        end
    end

    if _G.GroupLootContainer and type(GroupLootContainer_Update) == "function" then
        pcall(GroupLootContainer_Update, _G.GroupLootContainer)
    end

    local frames = TestFrames()
    if #frames == 0 then
        StopTest()
        Print("could not open test roll window(s).")
        return
    end

    for _, frame in ipairs(frames) do
        HookTestButtons(frame)
        if not hooked["drag" .. tostring(frame)] then
            hooked["drag" .. tostring(frame)] = true
            frame:EnableMouseWheel(true)
            frame:RegisterForDrag("LeftButton")
            frame:HookScript("OnDragStart", function(self)
                if IsTestRoll(self.rollID) or (mover and mover:IsShown()) then
                    if mover then
                        mover:StartMoving()
                    end
                end
            end)
            frame:HookScript("OnDragStop", function(self)
                if mover then
                    mover:StopMovingOrSizing()
                    SavePosition()
                end
            end)
            frame:HookScript("OnMouseWheel", function(self, delta)
                if IsTestRoll(self.rollID) or (mover and mover:IsShown()) then
                    SetScale(db.scale + delta * SCALE_STEP)
                end
            end)
        end
        if not hooked["test" .. tostring(frame)] then
            hooked["test" .. tostring(frame)] = true
            frame:HookScript("OnHide", function()
                if #TestFrames() == 0 then
                    StopTest()
                end
            end)
        end
    end

    ApplyAll()
    Print("showing " .. #frames .. " test roll window(s). Click Need/Greed/Pass to test, or /rollmove test to hide.")
end

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
    end)
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            Lock()
        end
    end)
    frame:SetScript("OnMouseWheel", function(_, delta)
        SetScale(db.scale + delta * SCALE_STEP)
    end)

    frame.slots = {}
    local slotData = {
        [2] = { alpha = 0.22, text = "Item 2" },
        [3] = { alpha = 0.16, text = "Item 3" },
        [4] = { alpha = 0.10, text = "Item 4  ▲ Grows upwards ▲" },
    }

    for i = 2, 4 do
        local slot = CreateFrame("Frame", nil, frame)
        slot:SetFrameStrata("MEDIUM")
        slot:SetFrameLevel(1)
        slot:EnableMouse(true)
        slot:EnableMouseWheel(true)
        slot:RegisterForDrag("LeftButton")

        local bg = slot:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.55, 1, slotData[i].alpha)
        AddSlotBorder(slot, 0.2, 0.7, 1, slotData[i].alpha * 2)

        local txt = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        txt:SetPoint("CENTER")
        txt:SetText(slotData[i].text)

        slot:SetScript("OnDragStart", function()
            frame:StartMoving()
        end)
        slot:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
            SavePosition()
        end)
        slot:SetScript("OnMouseUp", function(_, button)
            if button == "RightButton" then
                Lock()
            end
        end)
        slot:SetScript("OnMouseWheel", function(_, delta)
            SetScale(db.scale + delta * SCALE_STEP)
        end)

        frame.slots[i] = slot
    end

    frame:Hide()
    return frame
end

local function PrintHelp()
    Print("commands:")
    print("  /rollmove - unlock or lock the loot roll window")
    print("  /rollmove scale <0.5-2> - set the window scale")
    print("  /rollmove test [1-5] - show 1 to 5 test roll windows")
    print("  /rollmove reset - restore the default position and scale")
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
    elseif command == "test1-5" or command == "test1-4" or (command == "test" and (value == "1-5" or value == "1-4" or value == "all")) then
        testCount = 4
    elseif command == "test" then
        if value and value ~= "" then
            local num = tonumber(value)
            if num then
                testCount = num
            end
        else
            testCount = testActive and 0 or 1
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

events = CreateFrame("Frame")
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
