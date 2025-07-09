ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

-- resets an item to its initial state
function resetItem(item_code, item_type, keep_stage)
  local obj = Tracker:FindObjectForCode(item_code)
  if obj then
    item_type = item_type or obj.Type
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("resetItem: resetting item %s of type %s", item_code, item_type))
    end
    if item_type == "toggle" or item_type == "toggle_badged" then
      obj.Active = false
    elseif item_type == "progressive" or item_type == "progressive_toggle" then
      if not keep_stage then
      obj.CurrentStage = 0
      end
      obj.Active = false
    elseif item_type == "consumable" then
      obj.AcquiredCount = 0
    elseif item_type == "custom" then
      -- your code for your custom lua items goes here
    elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("resetItem: tried to reset static item %s", item_code))
    elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format(
        "resetItem: tried to reset composite_toggle item %s but composite_toggle cannot be accessed via lua." ..
        "Please use the respective left/right toggle item codes instead.", item_code))
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("resetItem: unknown item type %s for code %s", item_type, item_code))
    end
  elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("resetItem: could not find item object for code %s", item_code))
  end
end

-- advances the state of an item
function incrementItem(item_code, item_type, keep_stage)
  local obj = Tracker:FindObjectForCode(item_code)
  if obj then
    item_type = item_type or obj.Type
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("incrementItem: code: %s, type %s", item_code, item_type))
    end
    if item_type == "toggle" or item_type == "toggle_badged" then
      obj.Active = true
    elseif item_type == "progressive" or item_type == "progressive_toggle" then
      if obj.Active and not keep_stage then
        obj.CurrentStage = obj.CurrentStage + 1
      else
        obj.Active = true
      end
    elseif item_type == "consumable" then
      obj.AcquiredCount = obj.AcquiredCount + obj.Increment
    elseif item_type == "custom" then
      -- your code for your custom lua items goes here
    elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("incrementItem: tried to increment static item %s", item_code))
    elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format(
        "incrementItem: tried to increment composite_toggle item %s but composite_toggle cannot be access via lua." ..
        "Please use the respective left/right toggle item codes instead.", item_code))
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("incrementItem: unknown item type %s for code %s", item_type, item_code))
    end
  elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("incrementItem: could not find object for code %s", item_code))
  end
end

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
  -- put any code here that slot_data should affect (toggling setting items for example)
end

-- called right after an AP slot is connected
function onClear(slot_data)
  -- use bulk update to pause logic updates until we are done resetting all items/locations
  Tracker.BulkUpdate = true
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
  end
  CUR_INDEX = -1
  -- reset locations
  for location_id, mapping_entry in pairs(LOCATION_MAPPING) do
    for _, location_table in ipairs(mapping_entry) do
      if location_table then
        local location_code = location_table[1]
        if location_code then
          if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: clearing location %s", location_code))
          end
          if location_code:sub(1, 1) == "@" then
            local obj = Tracker:FindObjectForCode(location_code)
            if obj then
              obj.AvailableChestCount = obj.ChestCount
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
              print(string.format("onClear: could not find location object for code %s", location_code))
            end
          else
            -- reset hosted item
            local item_type = location_table[2]
            local keep_stage = location_table[3] or false
            resetItem(location_code, item_type, keep_stage)
          end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
          print(string.format("onClear: skipping location_table (%s) with no location_code", location_table))
        end
      elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onClear: skipping empty location_table"))
      end
    end
    updateHintsClear(location_id)
  end
  -- reset items
  for _, mapping_entry in pairs(ITEM_MAPPING) do
    for _, item_table in ipairs(mapping_entry) do
      if item_table then
        local item_code = item_table[1]
        local item_type = item_table[2]
        local keep_stage = item_table[3] or false
        if item_code then
          resetItem(item_code, item_type, keep_stage)
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
          print(string.format("onClear: skipping item_table with no item_code"))
        end
      elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onClear: skipping empty item_table"))
      end
    end
  end
  apply_slot_data(slot_data)

  visibleLocations()

  PLAYER_NUMBER = Archipelago.PlayerNumber or -1
  TEAM_NUMBER = Archipelago.TeamNumber or 0

  LOCAL_ITEMS = {}
  GLOBAL_ITEMS = {}

  if PLAYER_NUMBER > -1 then
    HINTS_ID = "_read_hints_" .. TEAM_NUMBER .. "_" .. PLAYER_NUMBER
    Archipelago:SetNotify({ HINTS_ID })
    Archipelago:Get({ HINTS_ID })
  end

  Tracker.BulkUpdate = false
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
  end
  if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
    return
  end
  if index <= CUR_INDEX then
    return
  end
  local is_local = player_number == Archipelago.PlayerNumber
  CUR_INDEX = index;
  local mapping_entry = ITEM_MAPPING[item_id]
  if not mapping_entry then
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("onItem: could not find item mapping for id %s", item_id))
    end
    return
  end
  for _, item_table in pairs(mapping_entry) do
    if item_table then
      local item_code = item_table[1]
      local item_type = item_table[2]
      local keep_stage = item_table[3] or false
      if item_code then
        incrementItem(item_code, item_type, keep_stage)
        -- keep track which items we touch are local and which are global
        if is_local then
          if LOCAL_ITEMS[item_code] then
            LOCAL_ITEMS[item_code] = LOCAL_ITEMS[item_code] + 1
          else
            LOCAL_ITEMS[item_code] = 1
          end
        else
          if GLOBAL_ITEMS[item_code] then
            GLOBAL_ITEMS[item_code] = GLOBAL_ITEMS[item_code] + 1
          else
            GLOBAL_ITEMS[item_code] = 1
          end
        end
      elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onClear: skipping item_table with no item_code"))
      end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("onClear: skipping empty item_table"))
    end
  end
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
    print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
  end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("called onLocation: %s, %s", location_id, location_name))
  end
  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return
  end
  local mapping_entry = LOCATION_MAPPING[location_id]
  if not mapping_entry then
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    return
  end
  for _, location_table in pairs(mapping_entry) do
    if location_table then
      local location_code = location_table[1]
      if location_code then
        local obj = Tracker:FindObjectForCode(location_code)
        if obj then
          if location_code:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
          else
            -- increment hosted item
            local item_type = location_table[2]
            local keep_stage = location_table[3] or false
            incrementItem(location_code, item_type, keep_stage)
          end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
          print(string.format("onLocation: could not find object for code %s", location_code))
        end
      elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: skipping location_table (%s) with no location_code", location_table))
      end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
      print(string.format("onLocation: skipping empty location_table"))
    end
  end
  updateOverworld()
end

function GetHighlightFromStatus(status)
  if status == 0 then
    return Highlight.Unspecified
  elseif status == 10 then
    return Highlight.NoPriority
  elseif status == 20 then
    return Highlight.Avoid
  elseif status == 30 then
    return Highlight.Priority
  end
end

function onNotify(key, value, old_value)
  if value ~= old_value and key == HINTS_ID then
    for _, hint in ipairs(value) do
      if hint.finding_player == Archipelago.PlayerNumber then
        if not hint.found then
          updateHints(hint.location, GetHighlightFromStatus(hint.status))
        elseif hint.found then
          updateHints(hint.location, Highlight.None)
        end
      end
    end
  end
end

function onNotifyLaunch(key, value)
  if key == HINTS_ID then
    for _, hint in ipairs(value) do
      if hint.finding_player == Archipelago.PlayerNumber then
        if not hint.found then
          updateHints(hint.location, GetHighlightFromStatus(hint.status))
        elseif hint.found then
          updateHints(hint.location, Highlight.None)
        end
      end
    end
  end
end

function updateHints(locationID, highlight)
  if not Highlight then
    return
  end

  if not LOCATION_MAPPING[locationID] then
    return
  end

  local location_name = LOCATION_MAPPING[locationID][1][1]
  local obj = Tracker:FindObjectForCode(location_name)

  if obj then
    obj.Highlight = highlight
  else
    print(string.format("No object found for code: %s", location_name))
  end
end

function updateHintsClear(locationID)
  if not Highlight then
    return
  end

  if not LOCATION_MAPPING[locationID] then
    return
  end

  local location_name = LOCATION_MAPPING[locationID][1][1]
  local obj = Tracker:FindObjectForCode(location_name)

  if obj then
    obj.Highlight = Highlight.None
  else
    print(string.format("No object found for code: %s", location_name))
  end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
      item_player))
  end
  -- not implemented yet :(
end

-- called when a bounce message is received
function onBounce(json)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
    print(string.format("called onBounce: %s", dump_table(json)))
  end
  -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
  Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
  Archipelago:AddLocationHandler("location handler", onLocation)
end
if Highlight then
  Archipelago:AddSetReplyHandler("notify handler", onNotify)
  Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)
end

-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
