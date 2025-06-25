-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

print("-- Example Tracker --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Utility Script for helper functions etc.
ScriptHost:LoadScript("scripts/utils.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")

-- Custom Items
ScriptHost:LoadScript("scripts/custom_items/class.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlus.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlusWrapper.lua")

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/checks.json")
Tracker:AddItems("items/flags.json")
Tracker:AddItems("items/locations.json")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")
    -- Locations
    Tracker:AddLocations("locations/locations.json")
    Tracker:AddLocations("locations/coneria_castle.json")
    Tracker:AddLocations("locations/temple_of_fiends_present.json")
    Tracker:AddLocations("locations/matoyas_cave.json")
    Tracker:AddLocations("locations/dwarf_cave.json")
    Tracker:AddLocations("locations/elfland_castle.json")
    Tracker:AddLocations("locations/marsh_cave.json")
    Tracker:AddLocations("locations/earth_cave.json")
    Tracker:AddLocations("locations/gurgu_volcano.json")
    Tracker:AddLocations("locations/ice_cave.json")
    Tracker:AddLocations("locations/castle_of_ordeals.json")
    Tracker:AddLocations("locations/sea_shrine.json")
    Tracker:AddLocations("locations/waterfall.json")
    Tracker:AddLocations("locations/mirage_tower.json")
    Tracker:AddLocations("locations/sky_castle.json")
end

-- Layout
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- Default Flags
Tracker:FindObjectForCode("progressionFlag").CurrentStage = 1
Tracker:FindObjectForCode("npcsAreIncentive").Active = true
Tracker:FindObjectForCode("fetchQuestsAreIncentive").Active = true
Tracker:FindObjectForCode("northernDocks").Active = false
Tracker:FindObjectForCode("gaiaMountain").Active = false
Tracker:FindObjectForCode("lefeinRiver").Active = false
Tracker:FindObjectForCode("cardiaDock").Active = true
Tracker:FindObjectForCode("iceCaveIsIncentive").Active = true
Tracker:FindObjectForCode("ordealsIsIncentive").Active = true
Tracker:FindObjectForCode("marshIsIncentive").Active = true
Tracker:FindObjectForCode("titansTroveIsIncentive").Active = true
Tracker:FindObjectForCode("earthIsIncentive").Active = true
Tracker:FindObjectForCode("volcanoIsIncentive").Active = true
Tracker:FindObjectForCode("seaIsIncentive").Active = true
Tracker:FindObjectForCode("skyIsIncentive").Active = true
Tracker:FindObjectForCode("coneriaLockedIsIncentive").Active = true
Tracker:FindObjectForCode("marshLockedIsIncentive").Active = true
Tracker:FindObjectForCode("cardiaIsIncentive").CurrentStage = 2
Tracker:FindObjectForCode("showAllChests").CurrentStage = 0

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
