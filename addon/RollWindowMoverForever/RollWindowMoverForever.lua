local ADDON_NAME = ...

local isRu = (GetLocale and GetLocale() == "ruRU")

local L = {
    TITLE = "|cff33ff99Roll Window Mover|r",
    SETTINGS_TITLE = isRu and "|cff33ff99Roll Window Mover|r — Настройки" or "|cff33ff99Roll Window Mover|r Settings",
    ANCHOR_HINT = isRu and "Предмет 1 (базовый якорь)\nТащите для переноса, колесо — масштаб\nПКМ — закрепить"
        or "Item 1 (Base Anchor)\nDrag to move, scroll to resize\nRight-click to lock",
    ITEM_N = isRu and "Предмет %d" or "Item %d",
    ITEM_GROWS_UP = isRu and "Предмет %d  ▲ Растёт вверх ▲" or "Item %d  ▲ Grows upwards ▲",
    LOCK_ANCHOR = isRu and "Закрепить якорь" or "Lock Anchor",
    UNLOCK_ANCHOR = isRu and "Разблокировать" or "Unlock Anchor",
    RESET_DEFAULTS = isRu and "Сбросить всё" or "Reset Defaults",
    WINDOW_SCALE = isRu and "Масштаб окон: %d%%" or "Window Scale: %d%%",
    MAX_ITEMS = isRu and "Макс. видимых роллов: %d" or "Max Visible Items: %d",
    MAX_HINT = isRu and "Лишние предметы ждут в очереди, пока освободится место."
        or "Extra items wait in queue until active rolls finish.",
    HIDE_COMBAT = isRu and "Скрывать окна ролла в бою" or "Hide loot roll windows while in combat",
    SHOW_MINIMAP = isRu and "Показывать кнопку у миникарты" or "Show Minimap button",
    GROUP_CHAT = isRu and "Группировать спам роллов в одно сообщение" or "Group roll spam into one expandable chat line",
    CHAT_BUTTON = isRu and "Кнопка [Роллы] в чате для открытия сводки" or "Add clickable [Rolls] button on loot roll messages",
    PREVIEW_ROLLS = isRu and "Тест окон ролла:" or "Preview Test Rolls:",
    ITEM_1 = isRu and "1 предмет" or "1 Item",
    ITEM_4 = isRu and "4 предмета" or "4 Items",
    ITEM_10 = isRu and "10 предметов" or "10 Items",
    STOP_TEST = isRu and "Стоп тест" or "Stop Test",
    OPEN_HISTORY = isRu and "Сводка роллов" or "Roll History",
    HISTORY_TITLE = isRu and "|cff33ff99Сводка роллов|r (кто сколько выбросил)" or "|cff33ff99Roll History|r (Roll Ledger)",
    CLEAR_HISTORY = isRu and "Очистить" or "Clear",
    NO_HISTORY = isRu and "Пока нет записанных роллов.\nЗапустите /rollmove test или соберите добычу в группе."
        or "No loot rolls recorded yet.\nRun /rollmove test or roll on loot in a group.",
    SELECT_ROLL = isRu and "Выберите предмет слева" or "Select an item on the left",
    WON_BY = isRu and "Победил: %s" or "Won by: %s",
    YOU_WON = isRu and "Вы выиграли" or "You won",
    ALL_PASSED = isRu and "Все отказались" or "All passed",
    IN_PROGRESS = isRu and "Идёт розыгрыш..." or "Roll in progress...",
    NO_PARTICIPANTS = isRu and "Подробные ставки не зафиксированы (включите подробный лут или C_LootHistory)."
        or "No individual roll details recorded.",
    ROLLS_BTN = isRu and "Роллы" or "Rolls",
    DETAILS_BTN = isRu and "Подробнее" or "Details",
    CHOICE_NEED = isRu and "Нужно" or "Need",
    CHOICE_GREED = isRu and "Не откажусь" or "Greed",
    CHOICE_DE = isRu and "Распылить" or "Disenchant",
    CHOICE_TRANSMOG = isRu and "Трансмог" or "Transmog",
    CHOICE_PASS = isRu and "Пас" or "Pass",
    CHOICE_UNKNOWN = isRu and "Ролл" or "Roll",
    MINIMAP_LCLICK = isRu and "ЛКМ: Разблокировать / Закрепить якорь" or "Left-click: Unlock / Lock anchor",
    MINIMAP_RCLICK = isRu and "ПКМ: Открыть настройки" or "Right-click: Open Settings",
    MINIMAP_SHIFT_L = isRu and "Shift + ЛКМ: Тестовые роллы" or "Shift + Left-click: Toggle test rolls",
    MINIMAP_SHIFT_R = isRu and "Shift + ПКМ: Сводка роллов" or "Shift + Right-click: Roll History",
    MINIMAP_DRAG = isRu and "Перетаскивание: Вокруг миникарты" or "Drag: Move around Minimap",
    TOOLTIP_CLICK_TOGGLE = isRu and "ЛКМ: свернуть/развернуть в чате" or "Left-click: expand/collapse in chat",
    TOOLTIP_CLICK_OPEN = isRu and "ЛКМ: открыть подробную сводку" or "Left-click: open roll details window",
    UNLOCKED_MSG = isRu and "разблокировано. Перетащите, прокрутите колесо для масштаба, ПКМ или /rollmove lock для сохранения."
        or "unlocked. Drag any box, scroll to resize, right-click or /rollmove lock to save.",
    LOCKED_MSG = isRu and "закреплено. Позиция сохранена." or "locked. Position saved.",
    RESET_MSG = isRu and "позиция и настройки сброшены по умолчанию." or "reset to the default Blizzard position and settings.",
    VERSION_FOOTER = isRu and "Roll Window Mover Forever v1.3.1 | /rollmove help"
        or "Roll Window Mover Forever v1.3.1 | Type /rollmove help",
}

local TITLE = L.TITLE
local MOVER_WIDTH, MOVER_HEIGHT = 280, 72
local MIN_SCALE, MAX_SCALE, SCALE_STEP = 0.5, 2, 0.05
local DEFAULT_X, DEFAULT_Y = 0, 200
local MAX_HISTORY = 60
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
local historyFrame
local selectedHistoryId
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
local historyById = {}
local activeRollEntries = {}
local lootHistoryEntries = {}
local runtimeChatIds = {}
local chatLineCache = {}
local chatLineOrder = {}
local rollPatterns
local chatFilterInstalled = false
local chattynatorModifierInstalled = false
local hyperlinkHookInstalled = false
local rollOnLootHooked = false

local function Print(message)
    print(TITLE .. ": " .. message)
end

local function Plain(value)
    if issecretvalue and issecretvalue(value) then
        return nil
    end
    return value
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
local OpenRollDetails
local RefreshHistoryUI

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

local function ApplyCombatVisibility(frame)
    if not frame then
        return
    end
    if combatHidden then
        frame:SetAlpha(0)
        if frame.EnableMouse then
            frame:EnableMouse(false)
        end
    else
        frame:SetAlpha(1)
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
    end
end

local function ApplyAll()
    local scale = (db and db.scale) or 1
    for _, frame in ipairs(Targets()) do
        Hook(frame)
        frame:SetScale(scale)
        Anchor(frame)
        ApplyCombatVisibility(frame)
    end
    for _, frame in ipairs(AllGroupLootFrames()) do
        ApplyFrameScale(frame, scale)
        ApplyCombatVisibility(frame)
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
                        slot.text:SetText(string.format(L.ITEM_GROWS_UP, i))
                    else
                        slot.text:SetText(string.format(L.ITEM_N, i))
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
    Print(L.UNLOCKED_MSG)
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
    Print(L.LOCKED_MSG)
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
    db.groupRollChat = true
    db.chatRollButton = true
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
    Print(L.RESET_MSG)
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
                if not testActive then
                    return
                end
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

local RecordTestRollResult
local RecordStartLootRoll
local SyncAllLootHistory
local InstallChatIntegrations
local ToggleHistoryWindow

HookFrameLifecycle = function(frame)
    if not frame or type(frame.HookScript) ~= "function" or hooked["lifecycle" .. tostring(frame)] then
        return
    end
    hooked["lifecycle" .. tostring(frame)] = true
    frame:HookScript("OnShow", function(self)
        if db then
            ApplyFrameScale(self, db.scale or 1)
        end
        ApplyCombatVisibility(self)
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
    rollType = rollType or 0
    if RecordTestRollResult then
        RecordTestRollResult(testItem, rollType)
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
    label:SetText(L.ANCHOR_HINT)

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
        txt:SetText(string.format(L.ITEM_N, i))
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

local function PlayerSelfName()
    local ok, name = pcall(UnitName, "player")
    name = ok and Plain(name)
    if type(name) == "string" and name ~= "" then
        return name
    end
    return _G.YOU or "You"
end

local function ShortName(name)
    if type(name) ~= "string" then
        return ""
    end
    return (name:gsub("%-.*$", ""))
end

local function IsSelfPlayer(name)
    if type(name) ~= "string" or name == "" then
        return false
    end
    local you = (_G.YOU or "You"):lower()
    local low = name:lower()
    if low == you then
        return true
    end
    local me = PlayerSelfName():lower()
    return low == me or ShortName(low) == ShortName(me)
end

local function LookupPlayerClass(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    if IsSelfPlayer(name) then
        local ok, _, cls = pcall(UnitClass, "player")
        return ok and Plain(cls) or nil
    end
    local shortTarget = ShortName(name):lower()
    local numRaid = GetNumGroupMembers and GetNumGroupMembers() or 0
    if IsInRaid and IsInRaid() and numRaid > 0 then
        for i = 1, numRaid do
            local unit = "raid" .. i
            local okN, unitName = pcall(UnitName, unit)
            unitName = okN and Plain(unitName)
            if type(unitName) == "string" and (unitName:lower() == name:lower() or ShortName(unitName):lower() == shortTarget) then
                local okC, _, cls = pcall(UnitClass, unit)
                return okC and Plain(cls) or nil
            end
        end
    elseif numRaid > 0 then
        for i = 1, 4 do
            local unit = "party" .. i
            local okN, unitName = pcall(UnitName, unit)
            unitName = okN and Plain(unitName)
            if type(unitName) == "string" and (unitName:lower() == name:lower() or ShortName(unitName):lower() == shortTarget) then
                local okC, _, cls = pcall(UnitClass, unit)
                return okC and Plain(cls) or nil
            end
        end
    end
    return nil
end

local function ClassColorHex(classToken)
    if not classToken then
        return nil
    end
    if C_ClassColor and C_ClassColor.GetClassColor then
        local color = C_ClassColor.GetClassColor(classToken)
        if color and color.GenerateHexColor then
            return color:GenerateHexColor()
        end
    end
    local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    if c then
        if c.colorStr then
            return c.colorStr
        end
        return string.format("ff%02x%02x%02x", math.floor((c.r or 1) * 255 + 0.5), math.floor((c.g or 1) * 255 + 0.5), math.floor((c.b or 1) * 255 + 0.5))
    end
    return nil
end

local function ColorizeName(name, classToken)
    local hex = ClassColorHex(classToken or LookupPlayerClass(name))
    if hex then
        return "|c" .. hex .. name .. "|r"
    end
    return "|cffffffff" .. name .. "|r"
end

local function ItemQualityColor(quality)
    if GetItemQualityColor and quality then
        local r, g, b, hex = GetItemQualityColor(quality)
        if r then
            return r, g, b, hex
        end
    end
    if ITEM_QUALITY_COLORS and quality and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        return c.r or 1, c.g or 1, c.b or 1, c.hex
    end
    return 1, 1, 1, "|cffffffff"
end

local CHOICE_PRIORITY = {
    need = 1,
    greed = 2,
    de = 3,
    transmog = 4,
    pass = 5,
}

local CHOICE_COLORS = {
    need = "ff33ff66",
    greed = "ffffcc00",
    de = "ffcc66ff",
    transmog = "ffff66cc",
    pass = "ff888888",
}

local function ChoiceLabel(choice)
    if choice == "need" then
        return L.CHOICE_NEED
    elseif choice == "greed" then
        return L.CHOICE_GREED
    elseif choice == "de" then
        return L.CHOICE_DE
    elseif choice == "transmog" then
        return L.CHOICE_TRANSMOG
    elseif choice == "pass" then
        return L.CHOICE_PASS
    end
    return L.CHOICE_UNKNOWN
end

local function ChoiceColoredText(choice)
    local hex = CHOICE_COLORS[choice] or "ffcccccc"
    return "|c" .. hex .. ChoiceLabel(choice) .. "|r"
end

local function ExtractItemID(link)
    if type(link) ~= "string" then
        return nil
    end
    return tonumber(link:match("item:(%d+)"))
end

local function ExtractItemName(link)
    if type(link) ~= "string" then
        return nil
    end
    return link:match("%[(.-)%]")
end

local function GetEntryById(entryId)
    local num = tonumber(entryId)
    if not num then
        return nil
    end
    if historyById[num] then
        return historyById[num]
    end
    if db and type(db.history) == "table" then
        for _, e in ipairs(db.history) do
            if e.id == num then
                historyById[num] = e
                return e
            end
        end
    end
    return nil
end

local function TrimHistory()
    if not db or type(db.history) ~= "table" then
        return
    end
    while #db.history > MAX_HISTORY do
        local removed = table.remove(db.history)
        if removed and removed.id then
            historyById[removed.id] = nil
            runtimeChatIds[removed.id] = nil
        end
    end
end

local function AddEntryToHistory(entry)
    if not db then
        return
    end
    db.history = db.history or {}
    if not entry.id then
        db.nextHistoryId = (db.nextHistoryId or 1)
        entry.id = db.nextHistoryId
        db.nextHistoryId = entry.id + 1
    end
    if not historyById[entry.id] then
        table.insert(db.history, 1, entry)
        historyById[entry.id] = entry
        TrimHistory()
    end
end

local function CreateRollEntry(itemLink, rollID, lootHistoryID, icon, quality, itemName)
    local itemID = ExtractItemID(itemLink)
    local resolvedName = itemName or ExtractItemName(itemLink)
    local resolvedQuality = quality
    local resolvedIcon = icon
    if itemLink or itemID then
        local getItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
        if getItemInfo then
            local ok, n, l, q, _, _, _, _, _, _, tex = pcall(getItemInfo, itemLink or itemID)
            if ok and n then
                resolvedName = resolvedName or n
                itemLink = itemLink or l
                resolvedQuality = resolvedQuality or q
                resolvedIcon = resolvedIcon or tex
            end
        end
    end
    local entry = {
        rollID = rollID,
        lootHistoryID = lootHistoryID,
        itemID = itemID,
        itemLink = itemLink or (itemID and ("item:" .. itemID)) or resolvedName or "item",
        itemName = resolvedName or "Item",
        itemQuality = resolvedQuality or 1,
        itemIcon = resolvedIcon or "Interface\\Icons\\INV_Misc_QuestionMark",
        startedAt = time(),
        finished = false,
        allPassed = false,
        expanded = false,
        participants = {},
        participantOrder = 0,
    }
    AddEntryToHistory(entry)
    table.insert(activeRollEntries, entry)
    if lootHistoryID then
        lootHistoryEntries[lootHistoryID] = entry
    end
    return entry
end

local function PruneActiveEntries()
    local now = time()
    for i = #activeRollEntries, 1, -1 do
        local e = activeRollEntries[i]
        if e.finished and now - (e.finishedAt or e.startedAt or now) > 120 then
            table.remove(activeRollEntries, i)
        elseif not e.finished and now - (e.startedAt or now) > 600 then
            table.remove(activeRollEntries, i)
        end
    end
end

local function EntryMatchesItem(entry, itemLink, itemID)
    if itemID and entry.itemID and entry.itemID == itemID then
        return true
    end
    if itemLink and entry.itemLink == itemLink then
        return true
    end
    local name = ExtractItemName(itemLink)
    if name and entry.itemName and name == entry.itemName then
        return true
    end
    return false
end

local function FindOrCreateEntryForChat(itemLink, lootHistoryID, playerName, isRollNumber, isOutcome)
    PruneActiveEntries()
    if lootHistoryID and lootHistoryEntries[lootHistoryID] then
        local e = lootHistoryEntries[lootHistoryID]
        if itemLink and (not e.itemLink or not e.itemLink:find("|Hitem:", 1, true)) then
            e.itemLink = itemLink
            e.itemID = e.itemID or ExtractItemID(itemLink)
            e.itemName = ExtractItemName(itemLink) or e.itemName
        end
        return e
    end
    local itemID = ExtractItemID(itemLink)
    local playerKey = type(playerName) == "string" and ShortName(playerName):lower() or nil
    for _, e in ipairs(activeRollEntries) do
        if not e.finished and EntryMatchesItem(e, itemLink, itemID) then
            local existing = playerKey and e.participants and e.participants[playerKey]
            local skip = false
            if isRollNumber and existing and existing.roll then
                skip = true
            end
            if not skip then
                if lootHistoryID and not e.lootHistoryID then
                    e.lootHistoryID = lootHistoryID
                    lootHistoryEntries[lootHistoryID] = e
                end
                if itemLink and (not e.itemLink or not e.itemLink:find("|Hitem:", 1, true)) then
                    e.itemLink = itemLink
                end
                return e
            end
        end
    end
    if isOutcome then
        for i = #activeRollEntries, 1, -1 do
            local e = activeRollEntries[i]
            if not e.finished and EntryMatchesItem(e, itemLink, itemID) then
                return e
            end
        end
    end
    return CreateRollEntry(itemLink, nil, lootHistoryID)
end

local function RecordParticipant(entry, playerName, choice, rollNumber, isSelf, classToken)
    if not entry then
        return nil
    end
    local resolvedSelf = isSelf or IsSelfPlayer(playerName)
    local displayName = resolvedSelf and PlayerSelfName() or (playerName or "?")
    local key = ShortName(displayName):lower()
    if key == "" then
        return nil
    end
    entry.participants = entry.participants or {}
    local p = entry.participants[key]
    if not p then
        entry.participantOrder = (entry.participantOrder or 0) + 1
        p = {
            name = displayName,
            order = entry.participantOrder,
            isSelf = resolvedSelf,
        }
        entry.participants[key] = p
    else
        if resolvedSelf then
            p.isSelf = true
            p.name = PlayerSelfName()
        elseif #displayName > #p.name then
            p.name = displayName
        end
    end
    if choice then
        p.choice = choice
    end
    if type(rollNumber) == "number" then
        p.roll = rollNumber
    end
    if classToken then
        p.class = classToken
    elseif not p.class then
        p.class = LookupPlayerClass(p.name)
    end
    return p
end

local function SortedParticipants(entry)
    local list = {}
    for _, p in pairs((entry and entry.participants) or {}) do
        list[#list + 1] = p
    end
    table.sort(list, function(a, b)
        local wa = a.isWinner and 1 or 0
        local wb = b.isWinner and 1 or 0
        if wa ~= wb then
            return wa > wb
        end
        local ca = CHOICE_PRIORITY[a.choice] or 9
        local cb = CHOICE_PRIORITY[b.choice] or 9
        if ca ~= cb then
            return ca < cb
        end
        local ra = a.roll or -1
        local rb = b.roll or -1
        if ra ~= rb then
            return ra > rb
        end
        return (a.order or 0) < (b.order or 0)
    end)
    return list
end

local function CountParticipants(entry)
    local n = 0
    for _ in pairs((entry and entry.participants) or {}) do
        n = n + 1
    end
    return n
end

local function MapLootHistoryState(state)
    local s = Enum and Enum.EncounterLootDropRollState
    if s then
        if state == s.NeedMainSpec or state == s.NeedOffSpec then
            return "need"
        elseif state == s.Greed then
            return "greed"
        elseif state == s.Transmog then
            return "transmog"
        elseif state == s.Pass then
            return "pass"
        elseif state == s.Disenchant then
            return "de"
        end
    end
    if state == 1 then
        return "need"
    elseif state == 2 then
        return "greed"
    elseif state == 3 then
        return "de"
    elseif state == 4 then
        return "transmog"
    elseif state == 0 then
        return "pass"
    end
    return nil
end

local function InvalidateEntryInChat(entry)
    if not entry or not entry.id then
        return
    end
    if Chattynator and Chattynator.API and Chattynator.API.InvalidateMessage and runtimeChatIds[entry.id] then
        for msgId in pairs(runtimeChatIds[entry.id]) do
            pcall(Chattynator.API.InvalidateMessage, msgId)
        end
    end
end

local function SyncEntryFromLootHistory(entry)
    if not entry or not C_LootHistory then
        return
    end
    local now = time()
    if C_LootHistory.GetNumItems and C_LootHistory.GetItem and C_LootHistory.GetPlayerInfo then
        local okN, numItems = pcall(C_LootHistory.GetNumItems)
        numItems = okN and tonumber(Plain(numItems))
        if numItems and numItems > 0 then
            for i = 1, math.min(numItems, 30) do
                local okI, itemIdx, link, numPlayers = pcall(C_LootHistory.GetItem, i)
                link = okI and Plain(link)
                numPlayers = okI and tonumber(Plain(numPlayers))
                if okI and link and numPlayers and EntryMatchesItem(entry, link, ExtractItemID(link)) then
                    if entry.lootHistoryID and Plain(itemIdx) and tonumber(Plain(itemIdx)) ~= entry.lootHistoryID then
                        if now - (entry.startedAt or now) > 120 then
                            numPlayers = 0
                        end
                    end
                    for j = 1, math.min(numPlayers, 40) do
                        local okP, name, classToken, rollType, roll, isWinner, isMe = pcall(C_LootHistory.GetPlayerInfo, i, j)
                        if okP then
                            local pname = Plain(name)
                            local pme = Plain(isMe) and true or false
                            local pchoice = MapLootHistoryState(tonumber(Plain(rollType)))
                            local proll = tonumber(Plain(roll))
                            local pclass = Plain(classToken)
                            if pname or pme then
                                local p = RecordParticipant(entry, pname, pchoice, proll, pme, pclass)
                                if p and Plain(isWinner) then
                                    p.isWinner = true
                                    entry.winner = p.name
                                    entry.winnerClass = p.class
                                    entry.winIsSelf = p.isSelf
                                    entry.winType = p.choice or entry.winType
                                    entry.winRoll = p.roll or entry.winRoll
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function SyncDropFromLootHistory(encounterID, lootListID)
    if not (C_LootHistory and C_LootHistory.GetSortedInfoForDrop) or not encounterID or not lootListID then
        return
    end
    local ok, info = pcall(C_LootHistory.GetSortedInfoForDrop, encounterID, lootListID)
    if not ok or type(info) ~= "table" or type(info.rollInfos) ~= "table" then
        return
    end
    local link = Plain(info.itemHyperlink)
    if type(link) ~= "string" then
        return
    end
    local itemID = ExtractItemID(link)
    local targetEntry
    for i = #activeRollEntries, 1, -1 do
        local e = activeRollEntries[i]
        if EntryMatchesItem(e, link, itemID) then
            targetEntry = e
            break
        end
    end
    if not targetEntry and db and type(db.history) == "table" then
        local now = time()
        for _, e in ipairs(db.history) do
            if now - (e.startedAt or now) < 300 and EntryMatchesItem(e, link, itemID) then
                targetEntry = e
                break
            end
        end
    end
    if not targetEntry then
        return
    end
    for _, r in ipairs(info.rollInfos) do
        if type(r) == "table" then
            local pme = Plain(r.isSelf) and true or false
            local pname = Plain(r.playerName)
            local pchoice = MapLootHistoryState(tonumber(Plain(r.state)))
            local proll = tonumber(Plain(r.roll))
            if pname or pme then
                local p = RecordParticipant(targetEntry, pname, pchoice, proll, pme)
                if p and Plain(r.isWinner) then
                    p.isWinner = true
                    targetEntry.winner = p.name
                    targetEntry.winnerClass = p.class
                    targetEntry.winIsSelf = p.isSelf
                    targetEntry.winType = p.choice or targetEntry.winType
                    targetEntry.winRoll = p.roll or targetEntry.winRoll
                end
            end
        end
    end
    InvalidateEntryInChat(targetEntry)
    RefreshHistoryUI()
end

local function StripLootHistoryTag(fmt)
    if type(fmt) ~= "string" then
        return nil
    end
    local s, e = fmt:find("|c%x%x%x%x%x%x%x%x|HlootHistory:.-|h.-|h|r:?%s*")
    if not s then
        s, e = fmt:find("|HlootHistory:.-|h.-|h|?r?:?%s*")
    end
    if not s then
        return fmt
    end
    local tagPos = tonumber(fmt:sub(s, e):match("%%(%d)%$"))
    local rest = fmt:sub(1, s - 1) .. fmt:sub(e + 1)
    if tagPos then
        rest = rest:gsub("%%(%d)%$", function(pos)
            pos = tonumber(pos)
            return "%" .. (pos > tagPos and pos - 1 or pos) .. "$"
        end)
    end
    return rest
end

local function EscapeLuaPattern(text)
    return (text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function FormatToPattern(fmt)
    local stripped = StripLootHistoryTag(fmt)
    if not stripped or stripped == "" then
        return nil
    end
    local parts = { "^" }
    local map = {}
    local types = {}
    local seq = 0
    local pos = 1
    local len = #stripped
    while pos <= len do
        local pStart = stripped:find("%%", pos, true)
        if not pStart then
            parts[#parts + 1] = EscapeLuaPattern(stripped:sub(pos))
            break
        end
        if pStart > pos then
            parts[#parts + 1] = EscapeLuaPattern(stripped:sub(pos, pStart - 1))
        end
        local nextChar = stripped:sub(pStart + 1, pStart + 1)
        if nextChar == "%" then
            parts[#parts + 1] = "%%"
            pos = pStart + 2
        else
            local posIdx, spec = stripped:match("^%%(%d+)%$([sd])", pStart)
            local tokenEnd
            if posIdx then
                tokenEnd = pStart + #posIdx + 2
            else
                spec = stripped:match("^%%([sd])", pStart)
                if spec then
                    tokenEnd = pStart + 1
                end
            end
            if spec then
                local argIdx
                if posIdx then
                    argIdx = tonumber(posIdx)
                else
                    seq = seq + 1
                    argIdx = seq
                end
                map[#map + 1] = argIdx
                types[#types + 1] = spec
                local rest = stripped:sub(tokenEnd + 1)
                if spec == "d" then
                    parts[#parts + 1] = "(%d+)"
                elseif rest == "" then
                    parts[#parts + 1] = "(.+)"
                else
                    parts[#parts + 1] = "(.-)"
                end
                pos = tokenEnd + 1
            else
                parts[#parts + 1] = "%%"
                pos = pStart + 1
            end
        end
    end
    parts[#parts + 1] = "$"
    return {
        regex = table.concat(parts),
        map = map,
        types = types,
    }
end

local function GetRollPatterns()
    if rollPatterns then
        return rollPatterns
    end
    rollPatterns = {}
    local function add(globalName, info)
        local fmt = _G[globalName]
        local compiled = FormatToPattern(fmt)
        if compiled then
            compiled.kind = info.kind
            compiled.choice = info.choice
            compiled.isSelf = info.isSelf
            rollPatterns[#rollPatterns + 1] = compiled
        end
    end

    add("LOOT_ROLL_YOU_WON_NO_SPAM_NEED", { kind = "outcome", choice = "need", isSelf = true })
    add("LOOT_ROLL_WON_NO_SPAM_NEED", { kind = "outcome", choice = "need", isSelf = false })
    add("LOOT_ROLL_YOU_WON_NO_SPAM_GREED", { kind = "outcome", choice = "greed", isSelf = true })
    add("LOOT_ROLL_WON_NO_SPAM_GREED", { kind = "outcome", choice = "greed", isSelf = false })
    add("LOOT_ROLL_YOU_WON_NO_SPAM_DE", { kind = "outcome", choice = "de", isSelf = true })
    add("LOOT_ROLL_WON_NO_SPAM_DE", { kind = "outcome", choice = "de", isSelf = false })
    add("LOOT_ROLL_YOU_WON_NO_SPAM_DISENCHANT", { kind = "outcome", choice = "de", isSelf = true })
    add("LOOT_ROLL_WON_NO_SPAM_DISENCHANT", { kind = "outcome", choice = "de", isSelf = false })
    add("LOOT_ROLL_YOU_WON_NO_SPAM_TRANSMOG", { kind = "outcome", choice = "transmog", isSelf = true })
    add("LOOT_ROLL_WON_NO_SPAM_TRANSMOG", { kind = "outcome", choice = "transmog", isSelf = false })
    add("LOOT_ROLL_YOU_WON", { kind = "outcome", isSelf = true })
    add("LOOT_ROLL_WON", { kind = "outcome", isSelf = false })
    add("LOOT_ROLL_ALL_PASSED", { kind = "allPassed" })

    add("LOOT_ROLL_ROLLED_NEED_ROLE_BONUS", { kind = "roll", choice = "need" })
    add("LOOT_ROLL_ROLLED_NEED", { kind = "roll", choice = "need" })
    add("LOOT_ROLL_ROLLED_GREED", { kind = "roll", choice = "greed" })
    add("LOOT_ROLL_ROLLED_DE", { kind = "roll", choice = "de" })
    add("LOOT_ROLL_ROLLED_DISENCHANT", { kind = "roll", choice = "de" })
    add("LOOT_ROLL_ROLLED_TRANSMOG", { kind = "roll", choice = "transmog" })

    add("LOOT_ROLL_NEED_SELF", { kind = "select", choice = "need", isSelf = true })
    add("LOOT_ROLL_NEED", { kind = "select", choice = "need", isSelf = false })
    add("LOOT_ROLL_GREED_SELF", { kind = "select", choice = "greed", isSelf = true })
    add("LOOT_ROLL_GREED", { kind = "select", choice = "greed", isSelf = false })
    add("LOOT_ROLL_DISENCHANT_SELF", { kind = "select", choice = "de", isSelf = true })
    add("LOOT_ROLL_DISENCHANT", { kind = "select", choice = "de", isSelf = false })
    add("LOOT_ROLL_TRANSMOG_SELF", { kind = "select", choice = "transmog", isSelf = true })
    add("LOOT_ROLL_TRANSMOG", { kind = "select", choice = "transmog", isSelf = false })
    add("LOOT_ROLL_PASSED_SELF", { kind = "select", choice = "pass", isSelf = true })
    add("LOOT_ROLL_PASSED_SELF_AUTO", { kind = "select", choice = "pass", isSelf = true })
    add("LOOT_ROLL_PASSED", { kind = "select", choice = "pass", isSelf = false })
    add("LOOT_ROLL_PASSED_AUTO", { kind = "select", choice = "pass", isSelf = false })
    add("LOOT_ROLL_PASSED_AUTO_FEMALE", { kind = "select", choice = "pass", isSelf = false })
    add("LOOT_ROLL_LOST", { kind = "lost" })
    return rollPatterns
end

local function ProtectLinks(text)
    local saved = {}
    local function stash(link)
        saved[#saved + 1] = link
        return "\001L" .. #saved .. "\001"
    end
    local masked = text:gsub("(|cn[^:]+:|H.-|h%[.-%]|h|r)", stash)
    masked = masked:gsub("(|c%x%x%x%x%x%x%x%x|H.-|h%[.-%]|h|r)", stash)
    masked = masked:gsub("(|H.-|h%[.-%]|h)", stash)
    return masked, saved
end

local function RestoreLinks(val, saved)
    if type(val) ~= "string" then
        return val
    end
    return (val:gsub("\001L(%d+)\001", function(idx)
        return saved[tonumber(idx)] or ""
    end))
end

local function CleanPlayerName(rawName)
    if type(rawName) ~= "string" then
        return nil
    end
    local cleaned = rawName
        :gsub("|Hplayer:[^|]*|h%[?([^%]|]*)%]?|h", "%1")
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|cn[^:]+:", "")
        :gsub("|r", "")
    return strtrim and strtrim(cleaned) or cleaned
end

local function MatchLootRollLine(rawText)
    if type(rawText) ~= "string" or rawText == "" then
        return nil
    end
    local lhStr = rawText:match("|HlootHistory:(%d+)|h")
    local lootHistoryID = lhStr and tonumber(lhStr) or nil
    local cleanText = rawText
        :gsub("|c%x%x%x%x%x%x%x%x|HlootHistory:[^|]*|h.-|h|r:?%s*", "")
        :gsub("|cn[^:]+:|HlootHistory:[^|]*|h.-|h|r:?%s*", "")
        :gsub("|HlootHistory:[^|]*|h.-|h|?r?:?%s*", "")
    local masked, savedLinks = ProtectLinks(cleanText)
    for _, pat in ipairs(GetRollPatterns()) do
        local caps = { masked:match(pat.regex) }
        if #caps > 0 then
            local itemLink, rollNumber, rollArgIdx, playerName
            for i, cap in ipairs(caps) do
                local restored = RestoreLinks(cap, savedLinks)
                local idx = pat.map[i]
                if pat.types[i] == "d" then
                    local num = tonumber(restored)
                    if num and (not rollArgIdx or (idx and idx < rollArgIdx)) then
                        rollNumber = num
                        rollArgIdx = idx
                    end
                elseif restored:find("|Hitem:", 1, true) or restored:find("|h%[") then
                    itemLink = itemLink or restored
                else
                    if idx and not playerName and restored ~= "" then
                        playerName = CleanPlayerName(restored)
                    end
                end
            end
            return pat, lootHistoryID, itemLink, playerName, rollNumber
        end
    end
    return nil
end

local function BuildExpandedLines(entry)
    local sorted = SortedParticipants(entry)
    if #sorted == 0 then
        return "  " .. L.NO_PARTICIPANTS
    end
    local lines = {}
    for _, p in ipairs(sorted) do
        local mark = p.isWinner and "|TInterface\\GroupFrame\\UI-Group-LeaderIcon:12:12|t " or "  "
        local rollPart = p.roll and (" |cffffffff" .. p.roll .. "|r") or ""
        lines[#lines + 1] = "  " .. mark .. ChoiceColoredText(p.choice) .. rollPart .. " — " .. ColorizeName(p.name, p.class)
    end
    return table.concat(lines, "\n")
end

local function FormatEntryBaseLine(entry)
    local count = CountParticipants(entry)
    local arrow = entry.expanded and "-" or "+"
    local toggleLabel = (count > 0) and (arrow .. " " .. L.ROLLS_BTN .. " (" .. count .. ")") or (arrow .. " " .. L.ROLLS_BTN)
    local toggleLink = "|Haddon:rwmf:toggle:" .. entry.id .. "|h|cff33ff99[" .. toggleLabel .. "]|r|h"
    local itemPart = entry.itemLink or entry.itemName or "item"
    local outcomePart
    if entry.allPassed then
        outcomePart = " — |cff999999" .. L.ALL_PASSED .. "|r"
    elseif entry.winner then
        local winnerColored = ColorizeName(entry.winner, entry.winnerClass)
        local winMeta = ""
        if entry.winType or entry.winRoll then
            local bits = {}
            if entry.winType then
                bits[#bits + 1] = ChoiceColoredText(entry.winType)
            end
            if entry.winRoll then
                bits[#bits + 1] = "|cffffffff" .. entry.winRoll .. "|r"
            end
            winMeta = " (" .. table.concat(bits, " ") .. ")"
        end
        if entry.winIsSelf then
            outcomePart = " — |cff33ff99" .. L.YOU_WON .. "|r" .. winMeta
        else
            outcomePart = " — " .. string.format(L.WON_BY, winnerColored) .. winMeta
        end
    else
        outcomePart = " — " .. L.IN_PROGRESS
    end
    local detailsLink = ""
    if db and db.chatRollButton then
        detailsLink = " |Haddon:rwmf:open:" .. entry.id .. "|h|cff66ccff[" .. L.DETAILS_BTN .. "]|r|h"
    end
    return toggleLink .. " " .. itemPart .. outcomePart .. detailsLink
end

local function FormatEntryChatText(entry)
    local base = FormatEntryBaseLine(entry)
    if entry.expanded then
        return base .. "\n" .. BuildExpandedLines(entry)
    end
    return base
end

local function ApplyExpandedToChatText(baseLine, entry)
    local count = CountParticipants(entry)
    local arrow = entry.expanded and "-" or "+"
    local toggleLabel = (count > 0) and (arrow .. " " .. L.ROLLS_BTN .. " (" .. count .. ")") or (arrow .. " " .. L.ROLLS_BTN)
    local updated = baseLine:gsub("(|Haddon:rwmf:toggle:" .. entry.id .. "|h|cff%x%x%x%x%x%x)%[(.-)%](|r|h)", "%1[" .. toggleLabel .. "]%3")
    if entry.expanded then
        return updated .. "\n" .. BuildExpandedLines(entry)
    end
    return updated
end

local function ToggleEntryInChat(entryId)
    local entry = GetEntryById(entryId)
    if not entry then
        return
    end
    entry.expanded = not entry.expanded
    local updatedAny = false
    if Chattynator and Chattynator.API and Chattynator.API.InvalidateMessage and runtimeChatIds[entry.id] then
        for msgId in pairs(runtimeChatIds[entry.id]) do
            pcall(Chattynator.API.InvalidateMessage, msgId)
            updatedAny = true
        end
    end
    local tag = "|Haddon:rwmf:toggle:" .. entry.id .. "|h"
    local numWindows = NUM_CHAT_WINDOWS or 10
    for w = 1, numWindows do
        local cf = _G["ChatFrame" .. w]
        if cf and cf.historyBuffer and cf.historyBuffer.GetNumElements and cf.historyBuffer.GetEntryAtIndex then
            local changed = false
            local total = cf.historyBuffer:GetNumElements()
            for i = 1, total do
                local msgObj = cf.historyBuffer:GetEntryAtIndex(i)
                if msgObj and type(msgObj.message) == "string" and msgObj.message:find(tag, 1, true) then
                    local firstLine = msgObj.message:match("^([^\n]+)") or msgObj.message
                    msgObj.message = ApplyExpandedToChatText(firstLine, entry)
                    changed = true
                    updatedAny = true
                end
            end
            if changed then
                if cf.MarkDisplayDirty then
                    pcall(cf.MarkDisplayDirty, cf)
                end
                if cf.RefreshDisplay then
                    pcall(cf.RefreshDisplay, cf)
                end
            end
        end
    end
    if not updatedAny and entry.expanded and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage((entry.itemLink or entry.itemName) .. ":\n" .. BuildExpandedLines(entry))
    end
end

local fallbackTick = -1
local fallbackDecisions = {}

local function CacheChatDecision(lineID, result)
    if type(lineID) ~= "number" or lineID <= 0 then
        return
    end
    chatLineCache[lineID] = result
    chatLineOrder[#chatLineOrder + 1] = lineID
    if #chatLineOrder > 80 then
        local old = table.remove(chatLineOrder, 1)
        chatLineCache[old] = nil
    end
end

local function ProcessLootChatLine(rawText, lineID)
    if type(lineID) == "number" and lineID > 0 and chatLineCache[lineID] then
        return chatLineCache[lineID]
    end
    local pat, lootHistoryID, itemLink, playerName, rollNumber = MatchLootRollLine(rawText)
    if not pat then
        local res = { action = "pass" }
        CacheChatDecision(lineID, res)
        return res
    end
    if pat.kind == "lost" then
        local res = { action = "intermediate" }
        CacheChatDecision(lineID, res)
        return res
    end
    if pat.kind == "select" or pat.kind == "roll" then
        local entry = FindOrCreateEntryForChat(itemLink, lootHistoryID, playerName, pat.kind == "roll", false)
        RecordParticipant(entry, playerName, pat.choice, rollNumber, pat.isSelf)
        local res = { action = "intermediate", entry = entry }
        CacheChatDecision(lineID, res)
        RefreshHistoryUI()
        return res
    end
    if pat.kind == "allPassed" or pat.kind == "outcome" then
        local entry = FindOrCreateEntryForChat(itemLink, lootHistoryID, playerName, false, true)
        if pat.kind == "allPassed" then
            entry.allPassed = true
            entry.finished = true
            entry.finishedAt = time()
            SyncEntryFromLootHistory(entry)
        else
            local winnerName = pat.isSelf and PlayerSelfName() or (playerName or "?")
            local p = RecordParticipant(entry, winnerName, pat.choice, rollNumber, pat.isSelf)
            SyncEntryFromLootHistory(entry)
            if p then
                p.isWinner = true
                entry.winner = p.name
                entry.winnerClass = p.class
                entry.winIsSelf = p.isSelf
                entry.winType = p.choice or entry.winType
                entry.winRoll = p.roll or entry.winRoll
            else
                entry.winner = winnerName
                entry.winIsSelf = pat.isSelf or IsSelfPlayer(winnerName)
                entry.winType = pat.choice
                entry.winRoll = rollNumber
            end
            entry.finished = true
            entry.finishedAt = time()
        end
        RefreshHistoryUI()
        local res = { action = "outcome", entry = entry }
        CacheChatDecision(lineID, res)
        return res
    end
    local res = { action = "pass" }
    CacheChatDecision(lineID, res)
    return res
end

local function ProcessChatMessageDeduplicated(chatFrame, rawText, lineID)
    if type(lineID) == "number" and lineID > 0 then
        return ProcessLootChatLine(rawText, lineID)
    end
    local now = GetTime and GetTime() or 0
    if now ~= fallbackTick then
        fallbackTick = now
        fallbackDecisions = {}
    end
    local frameKey = chatFrame or "default"
    for _, cached in ipairs(fallbackDecisions) do
        if cached.text == rawText and not cached.frames[frameKey] then
            cached.frames[frameKey] = true
            return cached.res
        end
    end
    local res = ProcessLootChatLine(rawText, nil)
    fallbackDecisions[#fallbackDecisions + 1] = {
        text = rawText,
        res = res,
        frames = { [frameKey] = true },
    }
    return res
end

local function LootChatFilter(chatFrame, _, msg, ...)
    if not db or (not db.groupRollChat and not db.chatRollButton) then
        return false
    end
    if (issecretvalue and issecretvalue(msg)) or (canaccessvalue and not canaccessvalue(msg)) or type(msg) ~= "string" then
        return false
    end
    local lineID = Plain(select(10, ...))
    local ok, res = pcall(ProcessChatMessageDeduplicated, chatFrame, msg, lineID)
    if not ok or not res then
        return false
    end
    if res.action == "intermediate" then
        if db.groupRollChat then
            return true
        end
        return false
    end
    if res.action == "outcome" and res.entry then
        if db.groupRollChat then
            return false, FormatEntryChatText(res.entry), ...
        elseif db.chatRollButton then
            local btn = " |Haddon:rwmf:open:" .. res.entry.id .. "|h|cff66ccff[" .. L.ROLLS_BTN .. "]|r|h"
            return false, msg .. btn, ...
        end
    end
    return false
end

local function ShowRollLinkTooltip(owner, link)
    if type(link) ~= "string" then
        return
    end
    local cmd, idStr = link:match("^addon:rwmf:(%a+):(%d+)$")
    if not cmd then
        return
    end
    local entry = GetEntryById(idStr)
    if not entry then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_CURSOR_RIGHT")
    local r, g, b = ItemQualityColor(entry.itemQuality)
    GameTooltip:AddLine(entry.itemName or "Item", r, g, b)
    if entry.allPassed then
        GameTooltip:AddLine(L.ALL_PASSED, 0.7, 0.7, 0.7)
    elseif entry.winner then
        GameTooltip:AddLine(string.format(L.WON_BY, entry.winner), 0.2, 1, 0.6)
    end
    GameTooltip:AddLine(" ")
    local sorted = SortedParticipants(entry)
    if #sorted == 0 then
        GameTooltip:AddLine(L.NO_PARTICIPANTS, 0.7, 0.7, 0.7, true)
    else
        for _, p in ipairs(sorted) do
            local left = (p.isWinner and "|TInterface\\GroupFrame\\UI-Group-LeaderIcon:12:12|t " or "") .. ColorizeName(p.name, p.class)
            local right = ChoiceColoredText(p.choice) .. (p.roll and (" |cffffffff" .. p.roll .. "|r") or "")
            GameTooltip:AddDoubleLine(left, right)
        end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(cmd == "toggle" and L.TOOLTIP_CLICK_TOGGLE or L.TOOLTIP_CLICK_OPEN, 0.5, 0.8, 1)
    GameTooltip:Show()
end

local function HandleCustomHyperlink(link)
    if type(link) ~= "string" then
        return
    end
    local cmd, idStr = link:match("^addon:rwmf:(%a+):(%d+)$")
    if not cmd then
        return
    end
    local id = tonumber(idStr)
    if cmd == "toggle" then
        ToggleEntryInChat(id)
    elseif cmd == "open" then
        OpenRollDetails(id)
    end
end

InstallChatIntegrations = function()
    if not chatFilterInstalled then
        local addFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
        if type(addFilter) == "function" then
            local ok = pcall(addFilter, "CHAT_MSG_LOOT", LootChatFilter)
            if not ok and ChatFrame_AddMessageEventFilter and addFilter ~= ChatFrame_AddMessageEventFilter then
                ok = pcall(ChatFrame_AddMessageEventFilter, "CHAT_MSG_LOOT", LootChatFilter)
            end
            chatFilterInstalled = ok and true or false
        end
    end
    if not chattynatorModifierInstalled and Chattynator and Chattynator.API and Chattynator.API.AddModifier then
        chattynatorModifierInstalled = true
        Chattynator.API.AddModifier(function(data)
            local text = Plain(data and data.text)
            if type(text) ~= "string" then
                return
            end
            local idStr = text:match("|Haddon:rwmf:toggle:(%d+)|h")
            if not idStr then
                return
            end
            local entry = GetEntryById(idStr)
            if not entry then
                return
            end
            if data.id then
                runtimeChatIds[entry.id] = runtimeChatIds[entry.id] or {}
                runtimeChatIds[entry.id][data.id] = true
            end
            local base = text:match("^([^\n]+)") or text
            data.text = ApplyExpandedToChatText(base, entry)
        end)
        if Chattynator.API.GetHyperlinkHandler then
            local handler = Chattynator.API.GetHyperlinkHandler()
            if handler and handler.HookScript and not hooked["chattynatorHover"] then
                hooked["chattynatorHover"] = true
                handler:HookScript("OnHyperlinkEnter", function(self, link)
                    if type(link) == "string" and link:find("^addon:rwmf:") then
                        ShowRollLinkTooltip(self:GetParent() or self, link)
                    end
                end)
                handler:HookScript("OnHyperlinkLeave", function()
                    GameTooltip:Hide()
                end)
            end
        end
    end
    if not hyperlinkHookInstalled then
        hyperlinkHookInstalled = true
        if EventRegistry and EventRegistry.RegisterCallback then
            EventRegistry:RegisterCallback("SetItemRef", function(_, link)
                HandleCustomHyperlink(link)
            end)
        elseif SetItemRef then
            hooksecurefunc("SetItemRef", function(link)
                HandleCustomHyperlink(link)
            end)
        end
    end
    local numWindows = NUM_CHAT_WINDOWS or 10
    for w = 1, numWindows do
        local cf = _G["ChatFrame" .. w]
        if cf and cf.HookScript and not hooked["chatHover" .. w] then
            hooked["chatHover" .. w] = true
            cf:HookScript("OnHyperlinkEnter", function(self, link)
                if type(link) == "string" and link:find("^addon:rwmf:") then
                    ShowRollLinkTooltip(self, link)
                end
            end)
            cf:HookScript("OnHyperlinkLeave", function()
                if GameTooltip:IsShown() then
                    GameTooltip:Hide()
                end
            end)
        end
    end
end

local function EmitEntryToChat(entry)
    if not entry then
        return
    end
    local info = (ChatTypeInfo and ChatTypeInfo.LOOT) or { r = 0, g = 0.67, b = 0 }
    local text
    if db and db.groupRollChat then
        text = FormatEntryChatText(entry)
    else
        local base = entry.itemLink or entry.itemName
        if entry.winner then
            base = string.format(L.WON_BY, ColorizeName(entry.winner, entry.winnerClass)) .. ": " .. base
        else
            base = L.ALL_PASSED .. ": " .. base
        end
        if db and db.chatRollButton then
            base = base .. " |Haddon:rwmf:open:" .. entry.id .. "|h|cff66ccff[" .. L.ROLLS_BTN .. "]|r|h"
        end
        text = base
    end
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(text, info.r, info.g, info.b)
    else
        print(text)
    end
end

local TEST_NPC_PARTY = {
    { name = "Grommash", class = "WARRIOR" },
    { name = "Tyrande", class = "PRIEST" },
    { name = "Jaina", class = "MAGE" },
    { name = "Valeera", class = "ROGUE" },
}

RecordTestRollResult = function(testItem, rollType)
    if not testItem then
        return
    end
    local typeMap = { [0] = "pass", [1] = "need", [2] = "greed", [3] = "de", [4] = "transmog" }
    local selfChoice = typeMap[rollType] or "pass"
    local entry = CreateRollEntry(
        testItem.resolvedLink or ("item:" .. testItem.id),
        testItem.rollID,
        nil,
        testItem.resolvedIcon or testItem.icon,
        testItem.resolvedQuality or testItem.quality,
        testItem.resolvedName or testItem.name
    )
    entry.isTest = true
    local selfRoll = (selfChoice ~= "pass") and math.random(1, 100) or nil
    local _, selfClass = UnitClass("player")
    RecordParticipant(entry, PlayerSelfName(), selfChoice, selfRoll, true, selfClass)

    local allPassTest = (selfChoice == "pass" and math.random(1, 4) == 1)
    for idx, npc in ipairs(TEST_NPC_PARTY) do
        local npcChoice = "pass"
        local npcRoll = nil
        if not allPassTest then
            local r = math.random(1, 100)
            if selfChoice == "need" then
                npcChoice = (r <= 45 and "need") or (r <= 80 and "greed") or "pass"
            elseif idx <= 2 then
                npcChoice = (r <= 65 and "greed") or (r <= 85 and "de") or "pass"
            else
                npcChoice = (r <= 50 and "greed") or "pass"
            end
            if npcChoice ~= "pass" then
                npcRoll = math.random(1, 100)
            end
        end
        RecordParticipant(entry, npc.name, npcChoice, npcRoll, false, npc.class)
    end

    local sorted = SortedParticipants(entry)
    local best = sorted[1]
    if best and best.choice ~= "pass" then
        best.isWinner = true
        entry.winner = best.name
        entry.winnerClass = best.class
        entry.winIsSelf = best.isSelf
        entry.winType = best.choice
        entry.winRoll = best.roll
    else
        entry.allPassed = true
    end
    entry.finished = true
    entry.finishedAt = time()
    RefreshHistoryUI()
    EmitEntryToChat(entry)
end

local function CreateHistoryUI()
    local frame = CreateFrame("Frame", "RollWindowMoverHistoryFrame", UIParent)
    frame:SetSize(560, 380)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    table.insert(UISpecialFrames, "RollWindowMoverHistoryFrame")

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.07, 0.08, 0.11, 0.96)
    AddSlotBorder(frame, 0.2, 0.6, 1, 0.85)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 16, -12)
    title:SetText(L.HISTORY_TITLE)

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    local dividerV = frame:CreateTexture(nil, "ARTWORK")
    dividerV:SetWidth(1)
    dividerV:SetPoint("TOPLEFT", frame, "TOPLEFT", 224, -36)
    dividerV:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 224, 42)
    dividerV:SetColorTexture(0.2, 0.4, 0.6, 0.5)

    local listScroll = CreateFrame("ScrollFrame", "RWMF_HistoryListScroll", frame, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 10, -40)
    listScroll:SetSize(190, 292)
    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetSize(190, 1)
    listScroll:SetScrollChild(listChild)

    local detailIconBtn = CreateFrame("Button", nil, frame)
    detailIconBtn:SetSize(34, 34)
    detailIconBtn:SetPoint("TOPLEFT", 236, -42)
    local detailIcon = detailIconBtn:CreateTexture(nil, "ARTWORK")
    detailIcon:SetAllPoints()
    detailIconBtn.icon = detailIcon
    detailIconBtn:SetScript("OnEnter", function(self)
        local entry = selectedHistoryId and GetEntryById(selectedHistoryId)
        if entry and entry.itemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(entry.itemLink)
            GameTooltip:Show()
        end
    end)
    detailIconBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    detailIconBtn:SetScript("OnClick", function()
        local entry = selectedHistoryId and GetEntryById(selectedHistoryId)
        if entry and entry.itemLink and IsShiftKeyDown() and ChatEdit_InsertLink then
            ChatEdit_InsertLink(entry.itemLink)
        end
    end)

    local detailItemName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    detailItemName:SetPoint("TOPLEFT", detailIconBtn, "TOPRIGHT", 10, -1)
    detailItemName:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    detailItemName:SetJustifyH("LEFT")
    detailItemName:SetWordWrap(false)

    local detailOutcome = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailOutcome:SetPoint("TOPLEFT", detailItemName, "BOTTOMLEFT", 0, -4)
    detailOutcome:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    detailOutcome:SetJustifyH("LEFT")

    local sepD = frame:CreateTexture(nil, "ARTWORK")
    sepD:SetHeight(1)
    sepD:SetPoint("TOPLEFT", 236, -84)
    sepD:SetPoint("TOPRIGHT", -14, -84)
    sepD:SetColorTexture(0.2, 0.4, 0.6, 0.45)

    local detailScroll = CreateFrame("ScrollFrame", "RWMF_HistoryDetailScroll", frame, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", 234, -92)
    detailScroll:SetSize(296, 240)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetSize(296, 1)
    detailScroll:SetScrollChild(detailChild)

    local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyText:SetPoint("CENTER", 0, 10)
    emptyText:SetWidth(420)
    emptyText:SetText(L.NO_HISTORY)

    local noPlayersText = detailScroll:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    noPlayersText:SetPoint("TOPLEFT", 6, -12)
    noPlayersText:SetWidth(280)
    noPlayersText:SetJustifyH("LEFT")
    noPlayersText:SetText(L.NO_PARTICIPANTS)
    noPlayersText:Hide()

    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(110, 24)
    clearBtn:SetPoint("BOTTOMLEFT", 12, 10)
    clearBtn:SetText(L.CLEAR_HISTORY)
    clearBtn:SetScript("OnClick", function()
        if db then
            db.history = {}
        end
        historyById = {}
        activeRollEntries = {}
        lootHistoryEntries = {}
        selectedHistoryId = nil
        frame:Refresh()
    end)

    local countLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countLabel:SetPoint("LEFT", clearBtn, "RIGHT", 12, 0)

    local itemRows = {}
    local playerRows = {}

    local function GetItemRow(idx)
        if itemRows[idx] then
            return itemRows[idx]
        end
        local row = CreateFrame("Button", nil, listChild)
        row:SetSize(188, 36)
        row:SetPoint("TOPLEFT", 0, -(idx - 1) * 38)
        local bgTex = row:CreateTexture(nil, "BACKGROUND")
        bgTex:SetAllPoints()
        bgTex:SetColorTexture(1, 1, 1, 0.04)
        row.bgTex = bgTex
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(0.2, 0.6, 1, 0.14)
        local ico = row:CreateTexture(nil, "ARTWORK")
        ico:SetSize(28, 28)
        ico:SetPoint("LEFT", 4, 0)
        row.icon = ico
        local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameFS:SetPoint("TOPLEFT", ico, "TOPRIGHT", 6, -1)
        nameFS:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetWordWrap(false)
        row.nameFS = nameFS
        local subFS = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        subFS:SetPoint("TOPLEFT", nameFS, "BOTTOMLEFT", 0, -2)
        subFS:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        subFS:SetJustifyH("LEFT")
        subFS:SetWordWrap(false)
        row.subFS = subFS
        row:SetScript("OnClick", function(self)
            selectedHistoryId = self.entryId
            frame:Refresh()
        end)
        row:SetScript("OnEnter", function(self)
            local entry = self.entryId and GetEntryById(self.entryId)
            if entry and entry.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetHyperlink(entry.itemLink)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        itemRows[idx] = row
        return row
    end

    local function GetPlayerRow(idx)
        if playerRows[idx] then
            return playerRows[idx]
        end
        local row = CreateFrame("Frame", nil, detailChild)
        row:SetSize(290, 24)
        row:SetPoint("TOPLEFT", 2, -(idx - 1) * 25)
        local bgTex = row:CreateTexture(nil, "BACKGROUND")
        bgTex:SetAllPoints()
        bgTex:SetColorTexture(1, 1, 1, (idx % 2 == 0) and 0.03 or 0.06)
        row.bgTex = bgTex
        local star = row:CreateTexture(nil, "OVERLAY")
        star:SetSize(13, 13)
        star:SetPoint("LEFT", 6, 0)
        star:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        star:Hide()
        row.star = star
        local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameFS:SetPoint("LEFT", row, "LEFT", 24, 0)
        nameFS:SetWidth(130)
        nameFS:SetJustifyH("LEFT")
        nameFS:SetWordWrap(false)
        row.nameFS = nameFS
        local choiceFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        choiceFS:SetPoint("LEFT", nameFS, "RIGHT", 6, 0)
        choiceFS:SetWidth(84)
        choiceFS:SetJustifyH("LEFT")
        row.choiceFS = choiceFS
        local rollFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rollFS:SetPoint("RIGHT", -8, 0)
        rollFS:SetWidth(36)
        rollFS:SetJustifyH("RIGHT")
        row.rollFS = rollFS
        playerRows[idx] = row
        return row
    end

    function frame:Refresh()
        local list = (db and db.history) or {}
        countLabel:SetText(#list .. " / " .. MAX_HISTORY)
        local hasItems = #list > 0
        emptyText:SetShown(not hasItems)
        listScroll:SetShown(hasItems)
        detailIconBtn:SetShown(hasItems)
        detailItemName:SetShown(hasItems)
        detailOutcome:SetShown(hasItems)
        sepD:SetShown(hasItems)
        detailScroll:SetShown(hasItems)
        dividerV:SetShown(hasItems)

        if not hasItems then
            for _, r in ipairs(itemRows) do
                r:Hide()
            end
            for _, r in ipairs(playerRows) do
                r:Hide()
            end
            noPlayersText:Hide()
            return
        end

        if not selectedHistoryId or not GetEntryById(selectedHistoryId) then
            selectedHistoryId = list[1].id
        end

        for i, entry in ipairs(list) do
            local row = GetItemRow(i)
            row.entryId = entry.id
            row.icon:SetTexture(entry.itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
            local r, g, b = ItemQualityColor(entry.itemQuality)
            row.nameFS:SetText(entry.itemName or "Item")
            row.nameFS:SetTextColor(r, g, b)
            if entry.allPassed then
                row.subFS:SetText(L.ALL_PASSED)
            elseif entry.winner then
                local suffix = entry.winRoll and (" (" .. entry.winRoll .. ")") or ""
                row.subFS:SetText(entry.winner .. suffix)
            else
                row.subFS:SetText(L.IN_PROGRESS)
            end
            if entry.id == selectedHistoryId then
                row.bgTex:SetColorTexture(0.15, 0.45, 0.8, 0.35)
            else
                row.bgTex:SetColorTexture(1, 1, 1, 0.04)
            end
            row:Show()
        end
        for i = #list + 1, #itemRows do
            itemRows[i]:Hide()
        end
        listChild:SetHeight(math.max(1, #list * 38))

        local selected = GetEntryById(selectedHistoryId)
        if selected then
            detailIconBtn.icon:SetTexture(selected.itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
            local r, g, b = ItemQualityColor(selected.itemQuality)
            detailItemName:SetText(selected.itemLink or selected.itemName or "Item")
            detailItemName:SetTextColor(r, g, b)
            local timeStr = date and date("%H:%M", selected.finishedAt or selected.startedAt or time()) or ""
            if selected.allPassed then
                detailOutcome:SetText(L.ALL_PASSED .. (timeStr ~= "" and (" · " .. timeStr) or ""))
            elseif selected.winner then
                local meta = selected.winType and (" (" .. ChoiceColoredText(selected.winType) .. (selected.winRoll and (" " .. selected.winRoll) or "") .. ")") or ""
                detailOutcome:SetText(string.format(L.WON_BY, ColorizeName(selected.winner, selected.winnerClass)) .. meta .. (timeStr ~= "" and (" · " .. timeStr) or ""))
            else
                detailOutcome:SetText(L.IN_PROGRESS)
            end

            local sorted = SortedParticipants(selected)
            noPlayersText:SetShown(#sorted == 0)
            for i, p in ipairs(sorted) do
                local prow = GetPlayerRow(i)
                prow.star:SetShown(p.isWinner and true or false)
                prow.nameFS:SetText(ColorizeName(p.name, p.class))
                prow.choiceFS:SetText(ChoiceColoredText(p.choice))
                prow.rollFS:SetText(p.roll and tostring(p.roll) or "—")
                if p.isWinner then
                    prow.bgTex:SetColorTexture(0.2, 0.5, 0.25, 0.28)
                    prow.rollFS:SetTextColor(1, 0.85, 0.2)
                else
                    prow.bgTex:SetColorTexture(1, 1, 1, (i % 2 == 0) and 0.03 or 0.06)
                    prow.rollFS:SetTextColor(0.9, 0.9, 0.9)
                end
                prow:Show()
            end
            for i = #sorted + 1, #playerRows do
                playerRows[i]:Hide()
            end
            detailChild:SetHeight(math.max(1, #sorted * 25))
        end
    end

    frame:Hide()
    return frame
end

RefreshHistoryUI = function()
    if historyFrame and historyFrame:IsShown() and historyFrame.Refresh then
        historyFrame:Refresh()
    end
end

OpenRollDetails = function(entryId)
    if not historyFrame then
        return
    end
    if entryId then
        selectedHistoryId = entryId
    end
    historyFrame:Show()
    historyFrame:Refresh()
end

ToggleHistoryWindow = function()
    if not historyFrame then
        return
    end
    if historyFrame:IsShown() then
        historyFrame:Hide()
    else
        OpenRollDetails(selectedHistoryId)
    end
end

RecordStartLootRoll = function(rollID)
    if not rollID or IsTestRoll(rollID) or not GetLootRollItemInfo then
        return
    end
    for _, e in ipairs(activeRollEntries) do
        if e.rollID == rollID then
            return
        end
    end
    local okInfo, texture, itemName, _, quality = pcall(GetLootRollItemInfo, rollID)
    if not okInfo then
        return
    end
    local okLink, itemLink = pcall(GetLootRollItemLink or function() return nil end, rollID)
    CreateRollEntry(okLink and Plain(itemLink) or nil, rollID, nil, Plain(texture), Plain(quality), Plain(itemName))
    RefreshHistoryUI()
end

SyncAllLootHistory = function()
    for _, e in ipairs(activeRollEntries) do
        if time() - (e.startedAt or time()) < 300 then
            SyncEntryFromLootHistory(e)
        end
    end
    RefreshHistoryUI()
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
        if IsShiftKeyDown() and button == "RightButton" then
            ToggleHistoryWindow()
        elseif IsShiftKeyDown() then
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
        GameTooltip:AddLine(L.MINIMAP_LCLICK, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_RCLICK, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_SHIFT_L, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_SHIFT_R, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_DRAG, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return btn
end

local function CreateSettingsUI()
    local frame = CreateFrame("Frame", "RollWindowMoverSettingsFrame", UIParent)
    frame:SetSize(380, 470)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    table.insert(UISpecialFrames, "RollWindowMoverSettingsFrame")

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.09, 0.12, 0.96)
    AddSlotBorder(frame, 0.2, 0.6, 1, 0.8)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -14)
    title:SetText(L.SETTINGS_TITLE)

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    local lockBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    lockBtn:SetSize(160, 26)
    lockBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -42)
    lockBtn:SetScript("OnClick", function()
        if mover:IsShown() then
            Lock()
        else
            Unlock()
        end
    end)

    local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetBtn:SetSize(160, 26)
    resetBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -42)
    resetBtn:SetText(L.RESET_DEFAULTS)
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
    scaleSlider:SetWidth(330)
    scaleSlider:SetMinMaxValues(MIN_SCALE, MAX_SCALE)
    scaleSlider:SetValueStep(SCALE_STEP)
    scaleSlider:SetObeyStepOnDrag(true)
    _G[scaleSlider:GetName() .. "Low"]:SetText("50%")
    _G[scaleSlider:GetName() .. "High"]:SetText("200%")
    local scaleTitle = _G[scaleSlider:GetName() .. "Text"]
    scaleTitle:SetText(string.format(L.WINDOW_SCALE, 100))
    scaleSlider:SetScript("OnValueChanged", function(_, val)
        val = math.floor((val / SCALE_STEP) + 0.5) * SCALE_STEP
        val = math.floor(val * 100 + 0.5) / 100
        if val ~= db.scale then
            SetScale(val)
        end
        scaleTitle:SetText(string.format(L.WINDOW_SCALE, math.floor(val * 100 + 0.5)))
    end)

    local maxSlider = CreateFrame("Slider", "RWMF_MaxItemsSlider", frame, "OptionsSliderTemplate")
    maxSlider:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -156)
    maxSlider:SetWidth(330)
    maxSlider:SetMinMaxValues(1, 10)
    maxSlider:SetValueStep(1)
    maxSlider:SetObeyStepOnDrag(true)
    _G[maxSlider:GetName() .. "Low"]:SetText("1")
    _G[maxSlider:GetName() .. "High"]:SetText("10")
    local maxTitle = _G[maxSlider:GetName() .. "Text"]
    maxTitle:SetText(string.format(L.MAX_ITEMS, 4))
    maxSlider:SetScript("OnValueChanged", function(_, val)
        val = math.floor(val + 0.5)
        db.maxItems = val
        maxTitle:SetText(string.format(L.MAX_ITEMS, val))
        EnsureGroupLootFrames(val)
        ResizeMover()
        CheckRollQueue()
    end)

    local maxHint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    maxHint:SetPoint("TOPLEFT", maxSlider, "BOTTOMLEFT", 0, -4)
    maxHint:SetText(L.MAX_HINT)

    local combatCheck = CreateFrame("CheckButton", "RWMF_CombatCheck", frame, "UICheckButtonTemplate")
    combatCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -206)
    local combatText = _G[combatCheck:GetName() .. "Text"]
    combatText:SetText(L.HIDE_COMBAT)
    combatCheck:SetScript("OnClick", function(self)
        db.hideInCombat = self:GetChecked() and true or false
    end)

    local minimapCheck = CreateFrame("CheckButton", "RWMF_MinimapCheck", frame, "UICheckButtonTemplate")
    minimapCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -234)
    local minimapText = _G[minimapCheck:GetName() .. "Text"]
    minimapText:SetText(L.SHOW_MINIMAP)
    minimapCheck:SetScript("OnClick", function(self)
        db.showMinimapButton = self:GetChecked() and true or false
        UpdateMinimapButtonPosition()
    end)

    local groupChatCheck = CreateFrame("CheckButton", "RWMF_GroupChatCheck", frame, "UICheckButtonTemplate")
    groupChatCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -262)
    local groupChatText = _G[groupChatCheck:GetName() .. "Text"]
    groupChatText:SetText(L.GROUP_CHAT)
    groupChatCheck:SetScript("OnClick", function(self)
        db.groupRollChat = self:GetChecked() and true or false
    end)

    local chatBtnCheck = CreateFrame("CheckButton", "RWMF_ChatBtnCheck", frame, "UICheckButtonTemplate")
    chatBtnCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -290)
    local chatBtnText = _G[chatBtnCheck:GetName() .. "Text"]
    chatBtnText:SetText(L.CHAT_BUTTON)
    chatBtnCheck:SetScript("OnClick", function(self)
        db.chatRollButton = self:GetChecked() and true or false
    end)

    local sep2 = frame:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -324)
    sep2:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -324)
    sep2:SetColorTexture(0.2, 0.4, 0.6, 0.5)

    local testLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -336)
    testLabel:SetText(L.PREVIEW_ROLLS)

    local t1Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t1Btn:SetSize(78, 24)
    t1Btn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -360)
    t1Btn:SetText(L.ITEM_1)
    t1Btn:SetScript("OnClick", function()
        StartTest(1)
    end)

    local t4Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t4Btn:SetSize(78, 24)
    t4Btn:SetPoint("LEFT", t1Btn, "RIGHT", 8, 0)
    t4Btn:SetText(L.ITEM_4)
    t4Btn:SetScript("OnClick", function()
        StartTest(4)
    end)

    local t10Btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    t10Btn:SetSize(82, 24)
    t10Btn:SetPoint("LEFT", t4Btn, "RIGHT", 8, 0)
    t10Btn:SetText(L.ITEM_10)
    t10Btn:SetScript("OnClick", function()
        StartTest(10)
    end)

    local tStopBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    tStopBtn:SetSize(78, 24)
    tStopBtn:SetPoint("LEFT", t10Btn, "RIGHT", 8, 0)
    tStopBtn:SetText(L.STOP_TEST)
    tStopBtn:SetScript("OnClick", function()
        StopTest()
        Print("test roll window(s) hidden.")
    end)

    local historyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    historyBtn:SetSize(340, 26)
    historyBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -396)
    historyBtn:SetText(L.OPEN_HISTORY)
    historyBtn:SetScript("OnClick", function()
        ToggleHistoryWindow()
    end)

    local authorInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    authorInfo:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
    authorInfo:SetText(L.VERSION_FOOTER)

    function frame:Refresh()
        lockBtn:SetText(mover:IsShown() and L.LOCK_ANCHOR or L.UNLOCK_ANCHOR)
        scaleSlider:SetValue(db.scale or 1)
        scaleTitle:SetText(string.format(L.WINDOW_SCALE, math.floor((db.scale or 1) * 100 + 0.5)))
        maxSlider:SetValue(db.maxItems or 4)
        maxTitle:SetText(string.format(L.MAX_ITEMS, db.maxItems or 4))
        combatCheck:SetChecked(db.hideInCombat and true or false)
        minimapCheck:SetChecked(db.showMinimapButton and true or false)
        groupChatCheck:SetChecked(db.groupRollChat and true or false)
        chatBtnCheck:SetChecked(db.chatRollButton and true or false)
    end

    frame:Hide()
    return frame
end

local function PrintHelp()
    Print("commands:")
    print("  /rollmove - unlock or lock the loot roll anchor")
    print("  /rollmove config - open the settings window")
    print("  /rollmove history - open the roll history & details ledger")
    print("  /rollmove chatgroup - toggle grouping roll spam in chat")
    print("  /rollmove chatbtn - toggle clickable [Rolls] button in chat")
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
    elseif command == "history" or command == "log" or command == "rolls" then
        ToggleHistoryWindow()
    elseif command == "chatgroup" then
        db.groupRollChat = not db.groupRollChat
        Print("group roll spam: " .. (db.groupRollChat and "|cff33ff99enabled|r" or "|cffff3333disabled|r"))
        if settingsFrame and settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
    elseif command == "chatbtn" then
        db.chatRollButton = not db.chatRollButton
        Print("chat roll button: " .. (db.chatRollButton and "|cff33ff99enabled|r" or "|cffff3333disabled|r"))
        if settingsFrame and settingsFrame.Refresh then
            settingsFrame:Refresh()
        end
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
                RecordStartLootRoll(rollID)
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
    if not rollOnLootHooked and type(RollOnLoot) == "function" and hooksecurefunc then
        rollOnLootHooked = true
        hooksecurefunc("RollOnLoot", function(rollID, rollType)
            if not rollID or IsTestRoll(rollID) then
                return
            end
            local typeMap = { [0] = "pass", [1] = "need", [2] = "greed", [3] = "de", [4] = "transmog" }
            local choice = typeMap[rollType]
            if choice then
                for _, e in ipairs(activeRollEntries) do
                    if e.rollID == rollID then
                        RecordParticipant(e, PlayerSelfName(), choice, nil, true)
                        RefreshHistoryUI()
                        break
                    end
                end
            end
        end)
    end
end

local function SafeRegisterEvent(frame, eventName)
    if C_EventUtils and C_EventUtils.IsEventValid then
        if C_EventUtils.IsEventValid(eventName) then
            frame:RegisterEvent(eventName)
        end
    else
        pcall(frame.RegisterEvent, frame, eventName)
    end
end

events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("START_LOOT_ROLL")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
SafeRegisterEvent(events, "LOOT_HISTORY_ROLL_CHANGED")
SafeRegisterEvent(events, "LOOT_HISTORY_ROLL_COMPLETE")
SafeRegisterEvent(events, "LOOT_HISTORY_UPDATE_DROP")
events:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 == "Chattynator" and db then
            InstallChatIntegrations()
            return
        end
        if arg1 ~= ADDON_NAME then
            return
        end
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
        if type(db.groupRollChat) ~= "boolean" then
            db.groupRollChat = true
        end
        if type(db.chatRollButton) ~= "boolean" then
            db.chatRollButton = true
        end
        if type(db.history) ~= "table" then
            db.history = {}
        end
        if type(db.nextHistoryId) ~= "number" then
            db.nextHistoryId = 1
        end
        for _, entry in ipairs(db.history) do
            if type(entry) == "table" and entry.id then
                historyById[entry.id] = entry
                if entry.id >= db.nextHistoryId then
                    db.nextHistoryId = entry.id + 1
                end
            end
        end

        EnsureGroupLootFrames(10)
        mover = CreateMover()
        ResizeMover()
        PlaceMover()
        minimapBtn = CreateMinimapButton()
        UpdateMinimapButtonPosition()
        settingsFrame = CreateSettingsUI()
        historyFrame = CreateHistoryUI()

        InstallOpenNewFrameHook()
        InstallChatIntegrations()

        for i = 1, 10 do
            HookFrameLifecycle(_G["GroupLootFrame" .. i])
        end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        InstallOpenNewFrameHook()
        InstallChatIntegrations()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if db and db.hideInCombat then
            combatHidden = true
            for _, frame in ipairs(AllGroupLootFrames()) do
                ApplyCombatVisibility(frame)
            end
            if _G.GroupLootContainer then
                _G.GroupLootContainer:SetAlpha(0)
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if combatHidden then
            combatHidden = false
            for _, frame in ipairs(AllGroupLootFrames()) do
                ApplyCombatVisibility(frame)
            end
            if _G.GroupLootContainer then
                _G.GroupLootContainer:SetAlpha(1)
            end
        end
    elseif event == "START_LOOT_ROLL" then
        local rollID = arg1
        local rollTime = arg2
        if rollID and not IsTestRoll(rollID) then
            RecordStartLootRoll(rollID)
            if not FindRollFrameByRollID(rollID) then
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
    elseif event == "LOOT_HISTORY_ROLL_CHANGED" or event == "LOOT_HISTORY_ROLL_COMPLETE" then
        SyncAllLootHistory()
    elseif event == "LOOT_HISTORY_UPDATE_DROP" then
        SyncDropFromLootHistory(arg1, arg2)
        SyncAllLootHistory()
    end
    if db then
        ApplyAll()
    end
end)
