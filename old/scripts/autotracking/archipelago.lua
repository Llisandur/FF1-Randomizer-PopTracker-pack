ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
	end
    SLOT_DATA = slot_data
	CUR_INDEX = -1
	-- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
					if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
					end
            local obj = Tracker:FindObjectForCode(v[1])
						if obj then
                if v[1]:sub(1, 1) == "@" then
							obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
			end
		end
	end
	-- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
			end
		end
	end
	LOCAL_ITEMS = {}
	GLOBAL_ITEMS = {}
    -- manually run snes interface functions after onClear in case we are already ingame
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
		-- add snes interface functions here
	end
	checkVisible()
    checkDoneAntiToggle("bridge", 488)
    checkDoneToggle("garland", 530)
    checkDoneToggle("marshIncentive", 284)
    checkDoneToggle("elfprince", 518)
    checkDoneToggle("coneriaIncentive", 259)
    checkDoneToggle("marshLockedIncentive", 288)
    checkDoneToggle("titansTrove", 326)
    checkDoneToggle("earthCaveIncentive", 317)
    checkDoneToggle("sages", 533)
    checkDoneToggle("VolcanoIncentive", 362)
    checkDoneToggle("iceCaveIncentive", 370)
    checkDoneToggle("castleOfOrdealsIncentive", 387)
    checkDoneToggle("cardiaIncentive", 391)
    checkDoneToggle("shopItem", 767)
    checkDoneToggle("seaShrineIncentive", 436)
    checkDoneToggle("robot", 529)
    checkDoneToggle("skyFortressIncentive", 527)
    checkDoneToggle("unne", 527)
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
    local v = ITEM_MAPPING[item_id]
    if not v then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onItem: could not find item mapping for id %s", item_id))
		end
		return
	end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
			if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
				else
            LOCAL_ITEMS[v[1]] = 1
				end
			else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
				else
            GLOBAL_ITEMS[v[1]] = 1
				end
	end
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
		print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
	end
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
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
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onLocation: could not find location mapping for id %s", location_id))
		end
    if not v[1] then
		return
	end
    local obj = Tracker:FindObjectForCode(v[1])
			if obj then
        if v[1]:sub(1, 1) == "@" then
					obj.AvailableChestCount = obj.AvailableChestCount - 1
				else
            obj.Active = true
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
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
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)

function checkDoneToggle(code, locationMap)
    Tracker:FindObjectForCode(code).Active = false
    for _, v in pairs(Archipelago.CheckedLocations) do
        if v == locationMap then
            Tracker:FindObjectForCode(code).Active = true
        end
    end
end

function checkDoneAntiToggle(code, locationMap)
    Tracker:FindObjectForCode(code).Active = false
    for _, v in pairs(Archipelago.MissingLocations) do
        if v == locationMap then
        else
            Tracker:FindObjectForCode(code).Active = true
        end
    end
end

function checkToggles()
    checkDoneAntiToggle("bridge", 488)
    checkDoneToggle("garland", 530)
    checkDoneToggle("marshIncentive", 284)
    checkDoneToggle("elfprince", 518)
    checkDoneToggle("coneriaIncentive", 259)
    checkDoneToggle("marshLockedIncentive", 288)
    checkDoneToggle("titansTrove", 326)
    checkDoneToggle("earthCaveIncentive", 317)
    checkDoneToggle("sages", 533)
    checkDoneToggle("VolcanoIncentive", 362)
    checkDoneToggle("iceCaveIncentive", 370)
    checkDoneToggle("castleOfOrdealsIncentive", 387)
    checkDoneToggle("cardiaIncentive", 391)
    checkDoneToggle("shopItem", 767)
    checkDoneToggle("seaShrineIncentive", 436)
    checkDoneToggle("robot", 529)
    checkDoneToggle("skyFortressIncentive", 527)
    checkDoneToggle("unne", 527)
end

function checkVisible()
    checkVisibleSingle("ConeriaCastle_Treasury1", 257)
    checkVisibleSingle("ConeriaCastle_Treasury2", 258)
    checkVisibleSingle("ConeriaCastle_TreasuryMajor", 259)
    checkVisibleSingle("ConeriaCastle_Treasury3", 260)
    checkVisibleSingle("ConeriaCastle_Treasury4", 261)
    checkVisibleSingle("ConeriaCastle_Treasury5", 262)
    checkVisibleSingle("TempleOfFiends_UnlockedDuo1", 263)
    checkVisibleSingle("TempleOfFiends_UnlockedDuo2", 264)
    checkVisibleSingle("TempleOfFiends_UnlockedSingle", 265)
    checkVisibleSingle("TempleOfFiends_LockedSingle", 266)
    checkVisibleSingle("TempleOfFiends_LockedDuo1", 267)
    checkVisibleSingle("TempleOfFiends_LockedDuo2", 268)
    checkVisibleSingle("ElflandCastle_Treasury1", 269)
    checkVisibleSingle("ElflandCastle_Treasury2", 270)
    checkVisibleSingle("ElflandCastle_Treasury3", 271)
    checkVisibleSingle("ElflandCastle_Treasury4", 272)
    checkVisibleSingle("NorthwestCastle_Treasury1", 273)
    checkVisibleSingle("NorthwestCastle_Treasury3", 274)
    checkVisibleSingle("NorthwestCastle_Treasury2", 275)
    checkVisibleSingle("MarshCave_Bottom_B2_Distant", 276)
    checkVisibleSingle("MarshCave_Bottom_B2_TetrisZFirst", 277)
    checkVisibleSingle("MarshCave_Bottom_B2_TetrisZMiddle1", 278)
    checkVisibleSingle("MarshCave_Bottom_B2_TetrisZLast", 279)
    checkVisibleSingle("MarshCave_Top_B1_Duo2", 280)
    checkVisibleSingle("MarshCave_Top_B1_Duo1", 281)
    checkVisibleSingle("MarshCave_Top_B1_Corner", 282)
    checkVisibleSingle("MarshCave_Top_B1_Single", 283)
    checkVisibleSingle("MarshCave_Bottom_B2_TetrisZIncentive", 284)
    checkVisibleSingle("MarshCave_Bottom_B2_TetrisZMiddle2", 285)
    checkVisibleSingle("MarshCave_Bottom_B2_LockedCorner", 286)
    checkVisibleSingle("MarshCave_Bottom_B2_LockedMiddle", 287)
    checkVisibleSingle("MarshCave_Bottom_B2_LockedIncentive", 288)
    checkVisibleSingle("DwarfCave_Entrance1", 289)
    checkVisibleSingle("DwarfCave_Entrance2", 290)
    checkVisibleSingle("DwarfCave_Treasury1", 291)
    checkVisibleSingle("DwarfCave_Treasury2", 292)
    checkVisibleSingle("DwarfCave_Treasury4", 293)
    checkVisibleSingle("DwarfCave_Treasury5", 294)
    checkVisibleSingle("DwarfCave_Treasury3", 295)
    checkVisibleSingle("DwarfCave_Treasury6", 296)
    checkVisibleSingle("DwarfCave_Treasury7", 297)
    checkVisibleSingle("DwarfCave_Treasury8", 298)
    checkVisibleSingle("MatoyasCave_Chest1", 299)
    checkVisibleSingle("MatoyasCave_Chest3", 300)
    checkVisibleSingle("MatoyasCave_Chest2", 301)
    checkVisibleSingle("EarthCave_GiantsFloor_B1_Appendix1", 302)
    checkVisibleSingle("EarthCave_GiantsFloor_B1_Appendix2", 303)
    checkVisibleSingle("EarthCave_GiantsFloor_B1_SidePath1", 304)
    checkVisibleSingle("EarthCave_GiantsFloor_B1_SidePath2", 305)
    checkVisibleSingle("EarthCave_GiantsFloor_B1_Single", 306)
    checkVisibleSingle("EarthCave_B2_SideRoom1", 307)
    checkVisibleSingle("EarthCave_B2_SideRoom2", 308)
    checkVisibleSingle("EarthCave_B2_SideRoom3", 309)
    checkVisibleSingle("EarthCave_B2_Guarded1", 310)
    checkVisibleSingle("EarthCave_B2_Guarded2", 311)
    checkVisibleSingle("EarthCave_B2_Guarded3", 312)
    checkVisibleSingle("EarthCave_VampireFloor_B3_VampiresCloset", 313)
    checkVisibleSingle("EarthCave_VampireFloor_B3_AsherTrunk", 314)
    checkVisibleSingle("EarthCave_VampireFloor_B3_SideRoom", 315)
    checkVisibleSingle("EarthCave_VampireFloor_B3_TFC", 316)
    checkVisibleSingle("EarthCave_VampireFloor_B3_Incentive", 317)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_LichsCloset1", 318)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_LichsCloset2", 319)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_LichsCloset3", 320)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_Armory1", 321)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_Armory2", 322)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_Armory4", 323)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_Armory5", 324)
    checkVisibleSingle("EarthCave_RodLockedFloor_B4_Armory3", 325)
    checkVisibleSingle("TitansTunnel_Major", 326)
    checkVisibleSingle("TitansTunnel_Chest1", 327)
    checkVisibleSingle("TitansTunnel_Chest2", 328)
    checkVisibleSingle("TitansTunnel_Chest3", 329)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory2", 330)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory3", 331)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory6", 332)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory7", 333)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory8", 334)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory5", 335)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory10", 336)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory4", 337)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory1", 338)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory12", 339)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory11", 340)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Armory9", 341)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Vertpins1", 342)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Vertpins2", 343)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Hairpins", 344)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Shortpins", 345)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Guarded", 346)
    checkVisibleSingle("GurguVolcano_ArmoryFloor_B2_Center", 347)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_Entrance2", 348)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_Entrance1", 349)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_FirstGreed", 350)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_GrindRoom1", 351)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_GrindRoom2", 352)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_SecondGreed1", 353)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_SecondGreed2", 354)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_SideRoom1", 355)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_SideRoom2", 356)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_WormRoom4", 357)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_WormRoom5", 358)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_WormRoom2", 359)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_WormRoom3", 360)
    checkVisibleSingle("GurguVolcano_AgamaFloor_B4_WormRoom1", 361)
    checkVisibleSingle("GurguVolcano_KaryFloor_B5_Incentive", 362)
    checkVisibleSingle("IceCave_ExitFloor_B1_GreedsChecks1", 363)
    checkVisibleSingle("IceCave_ExitFloor_B1_GreedsChecks2", 364)
    checkVisibleSingle("IceCave_ExitFloor_B1_DropRoom1", 365)
    checkVisibleSingle("IceCave_ExitFloor_B1_DropRoom2", 366)
    checkVisibleSingle("IceCave_ExitFloor_B1_DropRoom3", 367)
    checkVisibleSingle("IceCave_IncentiveFloor_B2_Chest1", 368)
    checkVisibleSingle("IceCave_IncentiveFloor_B2_Chest2", 369)
    checkVisibleSingle("IceCave_IncentiveFloor_B2_Major", 370)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack1", 371)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack2", 372)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack4", 373)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack5", 374)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack3", 375)
    checkVisibleSingle("IceCave_Bottom_B3_SixPack6", 376)
    checkVisibleSingle("IceCave_Bottom_B3_IceDRoom1", 377)
    checkVisibleSingle("IceCave_Bottom_B3_IceDRoom2", 378)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_FourPack1", 379)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_FourPack2", 380)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_FourPack3", 381)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_FourPack4", 382)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_ThreePack1", 383)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_ThreePack2", 384)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_ThreePack3", 385)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_Single", 386)
    checkVisibleSingle("CastleOfOrdeals_TopFloor_3F_Incentive", 387)
    checkVisibleSingle("CardiaForestIsland_Entrance2", 388)
    checkVisibleSingle("CardiaForestIsland_Entrance1", 389)
    checkVisibleSingle("CardiaForestIsland_Entrance3", 390)
    checkVisibleSingle("CardiaForestIsland_IncentiveMajor", 391)
    checkVisibleSingle("CardiaForestIsland_Incentive3", 392)
    checkVisibleSingle("CardiaSwampIsland_Chest1", 393)
    checkVisibleSingle("CardiaSwampIsland_Chest3", 394)
    checkVisibleSingle("CardiaSwampIsland_Chest2", 395)
    checkVisibleSingle("CardiaGrassIsland_DuoRoom1", 396)
    checkVisibleSingle("CardiaGrassIsland_DuoRoom2", 397)
    checkVisibleSingle("CardiaGrassIsland_Entrance", 398)
    checkVisibleSingle("CardiaForestIsland_Incentive2", 399)
    checkVisibleSingle("CardiaForestIsland_Incentive1", 400)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_GreedRoom1", 405)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_GreedRoom2", 406)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_GreedRoom3", 407)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_GreedRoom4", 408)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_Dengbait1", 409)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_Dengbait2", 410)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_SideCorner1", 411)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_SideCorner2", 412)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_SideCorner3", 413)
    checkVisibleSingle("SeaShrine_SharknadoFloor_B4_Exit", 414)
    checkVisibleSingle("SeaShrine_SplitFloor_B3_KrakenSide", 415)
    checkVisibleSingle("SeaShrine_SplitFloor_B3_MermaidSide", 416)
    checkVisibleSingle("SeaShrine_GreedFloor_B3_Chest2", 417)
    checkVisibleSingle("SeaShrine_GreedFloor_B3_Chest1", 418)
    checkVisibleSingle("SeaShrine_TFCFloor_B2_SideCorner", 419)
    checkVisibleSingle("SeaShrine_TFCFloor_B2_TFCNorth", 420)
    checkVisibleSingle("SeaShrine_TFCFloor_B2_TFC", 421)
    checkVisibleSingle("SeaShrine_TFCFloor_B2_FirstGreed", 422)
    checkVisibleSingle("SeaShrine_TFCFloor_B2_SecondGreed", 423)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Entrance1", 424)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Entrance2", 425)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Entrance3", 426)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Passby", 427)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Bubbles1", 428)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Bubbles2", 429)
    checkVisibleSingle("SeaShrine_Mermaids_B1_FourCornerFirst", 430)
    checkVisibleSingle("SeaShrine_Mermaids_B1_FourCornerSecond", 431)
    checkVisibleSingle("SeaShrine_Mermaids_B1_FourCornerThird", 432)
    checkVisibleSingle("SeaShrine_Mermaids_B1_FourCornerFourth", 433)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Incentive1", 434)
    checkVisibleSingle("SeaShrine_Mermaids_B1_Incentive2", 435)
    checkVisibleSingle("SeaShrine_Mermaids_B1_IncentiveMajor", 436)
    checkVisibleSingle("WaterfallCave_Chest1", 437)
    checkVisibleSingle("WaterfallCave_Chest2", 438)
    checkVisibleSingle("WaterfallCave_Chest3", 439)
    checkVisibleSingle("WaterfallCave_Chest4", 440)
    checkVisibleSingle("WaterfallCave_Chest5", 441)
    checkVisibleSingle("WaterfallCave_Chest6", 442)
    checkVisibleSingle("MirageTower_1F_Chest2", 452)
    checkVisibleSingle("MirageTower_1F_Chest3", 453)
    checkVisibleSingle("MirageTower_1F_Chest5", 454)
    checkVisibleSingle("MirageTower_1F_Chest4", 455)
    checkVisibleSingle("MirageTower_1F_Chest1", 456)
    checkVisibleSingle("MirageTower_1F_Chest7", 457)
    checkVisibleSingle("MirageTower_1F_Chest8", 458)
    checkVisibleSingle("MirageTower_1F_Chest6", 459)
    checkVisibleSingle("MirageTower_2F_Greater1", 460)
    checkVisibleSingle("MirageTower_2F_Greater2", 461)
    checkVisibleSingle("MirageTower_2F_Greater3", 462)
    checkVisibleSingle("MirageTower_2F_Greater4", 463)
    checkVisibleSingle("MirageTower_2F_Greater5", 464)
    checkVisibleSingle("MirageTower_2F_Lesser5", 465)
    checkVisibleSingle("MirageTower_2F_Lesser4", 466)
    checkVisibleSingle("MirageTower_2F_Lesser3", 467)
    checkVisibleSingle("MirageTower_2F_Lesser2", 468)
    checkVisibleSingle("MirageTower_2F_Lesser1", 469)
    checkVisibleSingle("SkyFortress_Plus_1F_FourPack1", 470)
    checkVisibleSingle("SkyFortress_Plus_1F_FourPack2", 471)
    checkVisibleSingle("SkyFortress_Plus_1F_FourPack3", 472)
    checkVisibleSingle("SkyFortress_Plus_1F_FourPack4", 473)
    checkVisibleSingle("SkyFortress_Plus_1F_FivePack1", 474)
    checkVisibleSingle("SkyFortress_Plus_1F_FivePack2", 475)
    checkVisibleSingle("SkyFortress_Plus_1F_FivePack3", 476)
    checkVisibleSingle("SkyFortress_Plus_1F_FivePack4", 477)
    checkVisibleSingle("SkyFortress_Plus_1F_FivePack5", 478)
    checkVisibleSingle("SkyFortress_Plus_1F_Solo", 479)
    checkVisibleSingle("SkyFortress_Spider_2F_Wardrobe1", 480)
    checkVisibleSingle("SkyFortress_Spider_2F_Wardrobe2", 481)
    checkVisibleSingle("SkyFortress_Spider_2F_RibbonRoom1", 482)
    checkVisibleSingle("SkyFortress_Spider_2F_GauntletRoom", 483)
    checkVisibleSingle("SkyFortress_Spider_2F_RibbonRoom2", 484)
    checkVisibleSingle("SkyFortress_Spider_2F_CheapRoom1", 485)
    checkVisibleSingle("SkyFortress_Spider_2F_CheapRoom2", 486)
    checkVisibleSingle("SkyFortress_Spider_2F_Vault1", 487)
    checkVisibleSingle("SkyFortress_Spider_2F_Vault2", 488)
    checkVisibleSingle("SkyFortress_Spider_2F_Incentive", 489)
    checkVisibleSingle("SkyFortress_Provides_3F_Greed2", 490)
    checkVisibleSingle("SkyFortress_Provides_3F_Greed1", 491)
    checkVisibleSingle("SkyFortress_Provides_3F_Greed3", 492)
    checkVisibleSingle("SkyFortress_Provides_3F_Greed4", 493)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack3", 494)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack2", 495)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack5", 496)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack4", 497)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack1", 498)
    checkVisibleSingle("SkyFortress_Provides_3F_SixPack6", 499)
    checkVisibleSingle("SkyFortress_Provides_3F_CCsGambit1", 500)
    checkVisibleSingle("SkyFortress_Provides_3F_CCsGambit2", 501)
    checkVisibleSingle("SkyFortress_Provides_3F_CCsGambit3", 502)
    checkVisibleSingle("SkyFortress_Provides_3F_CCsGambit4", 503)
    checkVisibleSingle("TempleOfFiendsRevisited_TiamatFloor_8F_MasamuneChest", 504)
    checkVisibleSingle("TempleOfFiendsRevisited_KaryFloor_6F_Vault", 505)
    checkVisibleSingle("TempleOfFiendsRevisited_KaryFloor_6F_KatanaChest", 506)
    checkVisibleSingle("TempleOfFiendsRevisited_KaryFloor_6F_GreedChecks1", 507)
    checkVisibleSingle("TempleOfFiendsRevisited_KaryFloor_6F_GreedChecks2", 508)
    checkVisibleSingle("TempleOfFiendsRevisited_3F_Validation1", 509)
    checkVisibleSingle("TempleOfFiendsRevisited_3F_Validation2", 510)
end

function checkVisibleSingle(code, locationMap)
    Tracker:FindObjectForCode(code).Active = false
    for _, v in pairs(Archipelago.MissingLocations) do
        if v == locationMap then
            Tracker:FindObjectForCode(code).Active = true
        end
    end
    for _, v in pairs(Archipelago.CheckedLocations) do
        if v == locationMap then
            Tracker:FindObjectForCode(code).Active = true
        end
    end
end
