if ShaguScan.disabled then
    return
end
local utils = ShaguScan.utils
local core = CreateFrame("Frame", nil, WorldFrame)

core.guids = {}

-- Boss combat tracking variables
core.isBossCombat = false
core.currentBosses = {}

-- Boss names (add specific boss names here)
core.bossNames = {
    ["Ragnaros"] = true,
    ["Nefarian"] = true,
    ["Onyxia"] = true,
    ["老杂斑野猪"] = true
}

-- Check if a unit is a boss
core.IsBossUnit = function(unit)
    if not UnitExists(unit) then
        return false
    end

    -- Check by name
    local unitName = UnitName(unit)
    if unitName and core.bossNames[unitName] then
        return true
    end

    -- Check by classification
    local classification = UnitClassification(unit)
    return classification == "worldboss" or classification == "rareelite" or classification == "elite"
end

core.add = function(unit)
    local exists, guid = UnitExists(unit)
    if not exists or not guid then
        if core.guids[guid] then
            core.guids[guid] = nil
        end
        return
    end

    local _, distanceValue = utils.GetDistance(unit)

    -- Check if this unit is a boss
    local isBoss = core.IsBossUnit(unit)

    -- Only add unit if we're already in boss combat or this unit is a boss
    if not core.isBossCombat and not isBoss then
        return
    end

    -- If this is a boss unit, start boss combat
    if isBoss and distanceValue < 100 then
        local isDead = UnitIsDead(unit)
        -- boss已死
        if isDead then
            core.guids = {}  -- Clear all collected data
            core.isBossCombat = false
            core.currentBosses[guid] = false

            -- Immediately hide all UI frames
            if ShaguScan.ui and ShaguScan.ui.frames then
                for caption, root in pairs(ShaguScan.ui.frames) do
                    root:Hide()
                end
            end
        else
            core.isBossCombat = true
            core.currentBosses[guid] = true  -- Track this boss
        end
    end

    core.guids[guid] = { time = GetTime(), distance = distanceValue }
end

-- unitstr
--core:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
--core:RegisterEvent("PLAYER_TARGET_CHANGED")
core:RegisterEvent("PLAYER_ENTERING_WORLD")

-- arg1
core:RegisterEvent("UNIT_COMBAT")
--core:RegisterEvent("UNIT_HAPPINESS")
core:RegisterEvent("UNIT_MODEL_CHANGED")
core:RegisterEvent("UNIT_PORTRAIT_UPDATE")
core:RegisterEvent("UNIT_FACTION")
core:RegisterEvent("UNIT_FLAGS")
core:RegisterEvent("UNIT_AURA")
core:RegisterEvent("UNIT_HEALTH")
core:RegisterEvent("UNIT_MANA")
core:RegisterEvent("UNIT_CASTEVENT")

core:SetScript("OnEvent", function()
    if event == "UPDATE_MOUSEOVER_UNIT" then
        this.add("mouseover")
    elseif event == "PLAYER_ENTERING_WORLD" then
        this.add("player")
    elseif event == "PLAYER_TARGET_CHANGED" then
        this.add("target")
    else
        this.add(arg1)
    end
end)

ShaguScan.core = core