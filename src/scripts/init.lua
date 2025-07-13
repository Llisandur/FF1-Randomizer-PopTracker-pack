-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

print("-- FF1 Randomizer Tracker --")
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
Tracker:AddItems("items/items.jsonc")
Tracker:AddItems("items/checks.jsonc")
Tracker:AddItems("items/settings.jsonc")
Tracker:AddItems("items/locations.jsonc")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
  -- Maps
  Tracker:AddMaps("maps/maps.jsonc")
  -- Locations
  Tracker:AddLocations("locations/locations.jsonc")
  Tracker:AddLocations("locations/dungeons/matoyas_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/dwarf_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/coneria_castle.jsonc")
  Tracker:AddLocations("locations/dungeons/elf_castle.jsonc")
  Tracker:AddLocations("locations/dungeons/northwest_castle.jsonc")
  Tracker:AddLocations("locations/dungeons/titans_tunnel.jsonc")
  Tracker:AddLocations("locations/dungeons/cardia_islands.jsonc")
  Tracker:AddLocations("locations/dungeons/temple_of_fiends.jsonc")
  Tracker:AddLocations("locations/dungeons/marsh_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/earth_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/gurgu_volcano.jsonc")
  Tracker:AddLocations("locations/dungeons/ice_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/castle_of_ordeals.jsonc")
  Tracker:AddLocations("locations/dungeons/sea_shrine.jsonc")
  Tracker:AddLocations("locations/dungeons/waterfall_cave.jsonc")
  Tracker:AddLocations("locations/dungeons/mirage_tower.jsonc")
  Tracker:AddLocations("locations/dungeons/sky_fortress.jsonc")
end

-- Layout
Tracker:AddLayouts("layouts/items.jsonc")
Tracker:AddLayouts("layouts/tracker.jsonc")
--Tracker:AddLayouts("layouts/broadcast.jsonc")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.26.0" then
  ScriptHost:LoadScript("scripts/autotracking.lua")
end
