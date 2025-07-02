-- put logic functions here using the Lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
-- don't be afraid to use custom logic functions. it will make many things a lot easier to maintain, for example by adding logging.
-- to see how this function gets called, check: locations/locations.json
-- example:
function has_more_then_n_consumable(n)
  local count = Tracker:ProviderCountForCode('consumable')
  local val = (count > tonumber(n))
  if ENABLE_DEBUG_LOG then
    print(string.format("called has_more_then_n_consumable: count: %s, n: %s, val: %s", count, n, val))
  end
  if val then
    return 1 -- 1 => access is in logic
  end
  return 0 -- 0 => no access
end
function hasEnoughShards()
    local shardCountItem = Tracker:FindObjectForCode("shards")
    local shardCountMax = Tracker:FindObjectForCode("shardsRequired")
    local goalShardCount = shardCountMax.CurrentStage + 16
    if shardCountItem.CurrentStage >= goalShardCount then
      return 1
    else
      return 0
    end
end

function canBreakOrb()
  if Tracker.ActiveVariantUID == "shardHunt" then
    return hasEnoughShards()
  else
    return Tracker:FindObjectForCode("earthorb").CurrentStage > 0 and Tracker:FindObjectForCode("fireorb").CurrentStage > 0 and Tracker:FindObjectForCode("waterorb").CurrentStage > 0 and Tracker:FindObjectForCode("airorb").CurrentStage > 0
  end
end

function checkLocationVisible(locationMap)
  if AutoTracker:GetConnectionState("AP") == 3 then
    local result = false
    for _, v in pairs(Archipelago.MissingLocations) do
      if v == locationMap then
        result = true
      end
    end
    for _, v in pairs(Archipelago.CheckedLocations) do
      if v == locationMap then
        result = true
      end
    end
    return result
  else
    return true
  end
end

function updateOverworldChestCount(locationRefList, chestRefList, callback)
  for h,locationRef in pairs(locationRefList) do
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
      if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print(string.format("%s, %s", locationRef, location.AvailableChestCount))
      end

      local clearedCount = 0
      for _, chestRef in pairs(chestRefList) do
        local chest = Tracker:FindObjectForCode(chestRef)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
          print(string.format("%s, %s, %s, %s", locationRef, location.AvailableChestCount, chestRef, chest.AvailableChestCount))
        end
        if chest.AvailableChestCount == 0 then
          clearedCount = clearedCount + 1
          if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(string.format("clearedCount %s", clearedCount))
          end
        end
      end

      location.AvailableChestCount = location.ChestCount - clearedCount

      if callback then
        callback(clearedCount > 0)
      end
    end
  end
end

function updateOverworld()
  print("Called updateOverworld")
  updateOverworldChestCount({"@Aldi Sea/Matoya's Cave/Chests"}, {"@Matoya's Cave/Chest 1/","@Matoya's Cave/Chest 2/","@Matoya's Cave/Chest 3/"})
end

ScriptHost:AddOnLocationSectionChangedHandler("overworldChestWatcher", updateOverworld)