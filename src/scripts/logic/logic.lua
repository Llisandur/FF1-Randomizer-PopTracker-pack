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

function checkLocationVisible(code, locationMap)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print(string.format("Called checkLocationVisible: %s, %s", code, locationMap))
  end
  if Tracker:FindObjectForCode("showAllChests").CurrentStage == 0 then
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
  else
    Tracker:FindObjectForCode(code).Active = true
  end
end

function visibleLocations()
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Called visibleLocations")
  end
  checkLocationVisible("MatoyasCave_Chest1", 299)
  checkLocationVisible("MatoyasCave_Chest2", 301)
  checkLocationVisible("MatoyasCave_Chest3", 300)
  checkLocationVisible("DwarfCave_Entrance1", 289)
  checkLocationVisible("DwarfCave_Entrance2", 290)
  checkLocationVisible("DwarfCave_Treasury1", 291)
  checkLocationVisible("DwarfCave_Treasury2", 292)
  checkLocationVisible("DwarfCave_Treasury3", 295)
  checkLocationVisible("DwarfCave_Treasury4", 293)
  checkLocationVisible("DwarfCave_Treasury5", 294)
  checkLocationVisible("DwarfCave_Treasury6", 296)
  checkLocationVisible("DwarfCave_Treasury7", 297)
  checkLocationVisible("DwarfCave_Treasury8", 298)
  checkLocationVisible("ConeriaCastle_Treasury1", 257)
  checkLocationVisible("ConeriaCastle_Treasury2", 258)
  checkLocationVisible("ConeriaCastle_Treasury3", 260)
  checkLocationVisible("ConeriaCastle_Treasury4", 261)
  checkLocationVisible("ConeriaCastle_Treasury5", 262)
  checkLocationVisible("ConeriaCastle_TreasuryMajor", 259)
  checkLocationVisible("ElflandCastle_Treasury1", 269)
  checkLocationVisible("ElflandCastle_Treasury2", 270)
  checkLocationVisible("ElflandCastle_Treasury3", 271)
  checkLocationVisible("ElflandCastle_Treasury4", 272)

  checkLocationVisible("TempleOfFiends_UnlockedDuo1", 263)
  checkLocationVisible("TempleOfFiends_UnlockedDuo2", 264)
  checkLocationVisible("TempleOfFiends_UnlockedSingle", 265)
  checkLocationVisible("TempleOfFiends_LockedSingle", 266)
  checkLocationVisible("TempleOfFiends_LockedDuo1", 267)
  checkLocationVisible("TempleOfFiends_LockedDuo2", 268)
  checkLocationVisible("NorthwestCastle_Treasury1", 273)
  checkLocationVisible("NorthwestCastle_Treasury3", 274)
  checkLocationVisible("NorthwestCastle_Treasury2", 275)
  checkLocationVisible("MarshCave_Bottom_B2_Distant", 276)
  checkLocationVisible("MarshCave_Bottom_B2_TetrisZFirst", 277)
  checkLocationVisible("MarshCave_Bottom_B2_TetrisZMiddle1", 278)
  checkLocationVisible("MarshCave_Bottom_B2_TetrisZLast", 279)
  checkLocationVisible("MarshCave_Top_B1_Duo2", 280)
  checkLocationVisible("MarshCave_Top_B1_Duo1", 281)
  checkLocationVisible("MarshCave_Top_B1_Corner", 282)
  checkLocationVisible("MarshCave_Top_B1_Single", 283)
  checkLocationVisible("MarshCave_Bottom_B2_TetrisZIncentive", 284)
  checkLocationVisible("MarshCave_Bottom_B2_TetrisZMiddle2", 285)
  checkLocationVisible("MarshCave_Bottom_B2_LockedCorner", 286)
  checkLocationVisible("MarshCave_Bottom_B2_LockedMiddle", 287)
  checkLocationVisible("MarshCave_Bottom_B2_LockedIncentive", 288)
  checkLocationVisible("EarthCave_GiantsFloor_B1_Appendix1", 302)
  checkLocationVisible("EarthCave_GiantsFloor_B1_Appendix2", 303)
  checkLocationVisible("EarthCave_GiantsFloor_B1_SidePath1", 304)
  checkLocationVisible("EarthCave_GiantsFloor_B1_SidePath2", 305)
  checkLocationVisible("EarthCave_GiantsFloor_B1_Single", 306)
  checkLocationVisible("EarthCave_B2_SideRoom1", 307)
  checkLocationVisible("EarthCave_B2_SideRoom2", 308)
  checkLocationVisible("EarthCave_B2_SideRoom3", 309)
  checkLocationVisible("EarthCave_B2_Guarded1", 310)
  checkLocationVisible("EarthCave_B2_Guarded2", 311)
  checkLocationVisible("EarthCave_B2_Guarded3", 312)
  checkLocationVisible("EarthCave_VampireFloor_B3_VampiresCloset", 313)
  checkLocationVisible("EarthCave_VampireFloor_B3_AsherTrunk", 314)
  checkLocationVisible("EarthCave_VampireFloor_B3_SideRoom", 315)
  checkLocationVisible("EarthCave_VampireFloor_B3_TFC", 316)
  checkLocationVisible("EarthCave_VampireFloor_B3_Incentive", 317)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_LichsCloset1", 318)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_LichsCloset2", 319)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_LichsCloset3", 320)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_Armory1", 321)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_Armory2", 322)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_Armory4", 323)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_Armory5", 324)
  checkLocationVisible("EarthCave_RodLockedFloor_B4_Armory3", 325)
  checkLocationVisible("TitansTunnel_Major", 326)
  checkLocationVisible("TitansTunnel_Chest1", 327)
  checkLocationVisible("TitansTunnel_Chest2", 328)
  checkLocationVisible("TitansTunnel_Chest3", 329)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory2", 330)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory3", 331)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory6", 332)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory7", 333)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory8", 334)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory5", 335)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory10", 336)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory4", 337)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory1", 338)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory12", 339)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory11", 340)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Armory9", 341)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Vertpins1", 342)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Vertpins2", 343)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Hairpins", 344)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Shortpins", 345)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Guarded", 346)
  checkLocationVisible("GurguVolcano_ArmoryFloor_B2_Center", 347)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_Entrance2", 348)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_Entrance1", 349)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_FirstGreed", 350)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_GrindRoom1", 351)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_GrindRoom2", 352)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_SecondGreed1", 353)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_SecondGreed2", 354)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_SideRoom1", 355)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_SideRoom2", 356)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_WormRoom4", 357)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_WormRoom5", 358)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_WormRoom2", 359)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_WormRoom3", 360)
  checkLocationVisible("GurguVolcano_AgamaFloor_B4_WormRoom1", 361)
  checkLocationVisible("GurguVolcano_KaryFloor_B5_Incentive", 362)
  checkLocationVisible("IceCave_ExitFloor_B1_GreedsChecks1", 363)
  checkLocationVisible("IceCave_ExitFloor_B1_GreedsChecks2", 364)
  checkLocationVisible("IceCave_ExitFloor_B1_DropRoom1", 365)
  checkLocationVisible("IceCave_ExitFloor_B1_DropRoom2", 366)
  checkLocationVisible("IceCave_ExitFloor_B1_DropRoom3", 367)
  checkLocationVisible("IceCave_IncentiveFloor_B2_Chest1", 368)
  checkLocationVisible("IceCave_IncentiveFloor_B2_Chest2", 369)
  checkLocationVisible("IceCave_IncentiveFloor_B2_Major", 370)
  checkLocationVisible("IceCave_Bottom_B3_SixPack1", 371)
  checkLocationVisible("IceCave_Bottom_B3_SixPack2", 372)
  checkLocationVisible("IceCave_Bottom_B3_SixPack4", 373)
  checkLocationVisible("IceCave_Bottom_B3_SixPack5", 374)
  checkLocationVisible("IceCave_Bottom_B3_SixPack3", 375)
  checkLocationVisible("IceCave_Bottom_B3_SixPack6", 376)
  checkLocationVisible("IceCave_Bottom_B3_IceDRoom1", 377)
  checkLocationVisible("IceCave_Bottom_B3_IceDRoom2", 378)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_FourPack1", 379)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_FourPack2", 380)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_FourPack3", 381)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_FourPack4", 382)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_ThreePack1", 383)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_ThreePack2", 384)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_ThreePack3", 385)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_Single", 386)
  checkLocationVisible("CastleOfOrdeals_TopFloor_3F_Incentive", 387)
  checkLocationVisible("CardiaForestIsland_Entrance2", 388)
  checkLocationVisible("CardiaForestIsland_Entrance1", 389)
  checkLocationVisible("CardiaForestIsland_Entrance3", 390)
  checkLocationVisible("CardiaForestIsland_IncentiveMajor", 391)
  checkLocationVisible("CardiaForestIsland_Incentive3", 392)
  checkLocationVisible("CardiaSwampIsland_Chest1", 393)
  checkLocationVisible("CardiaSwampIsland_Chest3", 394)
  checkLocationVisible("CardiaSwampIsland_Chest2", 395)
  checkLocationVisible("CardiaGrassIsland_DuoRoom1", 396)
  checkLocationVisible("CardiaGrassIsland_DuoRoom2", 397)
  checkLocationVisible("CardiaGrassIsland_Entrance", 398)
  checkLocationVisible("CardiaForestIsland_Incentive2", 399)
  checkLocationVisible("CardiaForestIsland_Incentive1", 400)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_GreedRoom1", 405)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_GreedRoom2", 406)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_GreedRoom3", 407)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_GreedRoom4", 408)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_Dengbait1", 409)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_Dengbait2", 410)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_SideCorner1", 411)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_SideCorner2", 412)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_SideCorner3", 413)
  checkLocationVisible("SeaShrine_SharknadoFloor_B4_Exit", 414)
  checkLocationVisible("SeaShrine_SplitFloor_B3_KrakenSide", 415)
  checkLocationVisible("SeaShrine_SplitFloor_B3_MermaidSide", 416)
  checkLocationVisible("SeaShrine_GreedFloor_B3_Chest2", 417)
  checkLocationVisible("SeaShrine_GreedFloor_B3_Chest1", 418)
  checkLocationVisible("SeaShrine_TFCFloor_B2_SideCorner", 419)
  checkLocationVisible("SeaShrine_TFCFloor_B2_TFCNorth", 420)
  checkLocationVisible("SeaShrine_TFCFloor_B2_TFC", 421)
  checkLocationVisible("SeaShrine_TFCFloor_B2_FirstGreed", 422)
  checkLocationVisible("SeaShrine_TFCFloor_B2_SecondGreed", 423)
  checkLocationVisible("SeaShrine_Mermaids_B1_Entrance1", 424)
  checkLocationVisible("SeaShrine_Mermaids_B1_Entrance2", 425)
  checkLocationVisible("SeaShrine_Mermaids_B1_Entrance3", 426)
  checkLocationVisible("SeaShrine_Mermaids_B1_Passby", 427)
  checkLocationVisible("SeaShrine_Mermaids_B1_Bubbles1", 428)
  checkLocationVisible("SeaShrine_Mermaids_B1_Bubbles2", 429)
  checkLocationVisible("SeaShrine_Mermaids_B1_FourCornerFirst", 430)
  checkLocationVisible("SeaShrine_Mermaids_B1_FourCornerSecond", 431)
  checkLocationVisible("SeaShrine_Mermaids_B1_FourCornerThird", 432)
  checkLocationVisible("SeaShrine_Mermaids_B1_FourCornerFourth", 433)
  checkLocationVisible("SeaShrine_Mermaids_B1_Incentive1", 434)
  checkLocationVisible("SeaShrine_Mermaids_B1_Incentive2", 435)
  checkLocationVisible("SeaShrine_Mermaids_B1_IncentiveMajor", 436)
  checkLocationVisible("WaterfallCave_Chest1", 437)
  checkLocationVisible("WaterfallCave_Chest2", 438)
  checkLocationVisible("WaterfallCave_Chest3", 439)
  checkLocationVisible("WaterfallCave_Chest4", 440)
  checkLocationVisible("WaterfallCave_Chest5", 441)
  checkLocationVisible("WaterfallCave_Chest6", 442)
  checkLocationVisible("MirageTower_1F_Chest2", 452)
  checkLocationVisible("MirageTower_1F_Chest3", 453)
  checkLocationVisible("MirageTower_1F_Chest5", 454)
  checkLocationVisible("MirageTower_1F_Chest4", 455)
  checkLocationVisible("MirageTower_1F_Chest1", 456)
  checkLocationVisible("MirageTower_1F_Chest7", 457)
  checkLocationVisible("MirageTower_1F_Chest8", 458)
  checkLocationVisible("MirageTower_1F_Chest6", 459)
  checkLocationVisible("MirageTower_2F_Greater1", 460)
  checkLocationVisible("MirageTower_2F_Greater2", 461)
  checkLocationVisible("MirageTower_2F_Greater3", 462)
  checkLocationVisible("MirageTower_2F_Greater4", 463)
  checkLocationVisible("MirageTower_2F_Greater5", 464)
  checkLocationVisible("MirageTower_2F_Lesser5", 465)
  checkLocationVisible("MirageTower_2F_Lesser4", 466)
  checkLocationVisible("MirageTower_2F_Lesser3", 467)
  checkLocationVisible("MirageTower_2F_Lesser2", 468)
  checkLocationVisible("MirageTower_2F_Lesser1", 469)
  checkLocationVisible("SkyFortress_Plus_1F_FourPack1", 470)
  checkLocationVisible("SkyFortress_Plus_1F_FourPack2", 471)
  checkLocationVisible("SkyFortress_Plus_1F_FourPack3", 472)
  checkLocationVisible("SkyFortress_Plus_1F_FourPack4", 473)
  checkLocationVisible("SkyFortress_Plus_1F_FivePack1", 474)
  checkLocationVisible("SkyFortress_Plus_1F_FivePack2", 475)
  checkLocationVisible("SkyFortress_Plus_1F_FivePack3", 476)
  checkLocationVisible("SkyFortress_Plus_1F_FivePack4", 477)
  checkLocationVisible("SkyFortress_Plus_1F_FivePack5", 478)
  checkLocationVisible("SkyFortress_Plus_1F_Solo", 479)
  checkLocationVisible("SkyFortress_Spider_2F_Wardrobe1", 480)
  checkLocationVisible("SkyFortress_Spider_2F_Wardrobe2", 481)
  checkLocationVisible("SkyFortress_Spider_2F_RibbonRoom1", 482)
  checkLocationVisible("SkyFortress_Spider_2F_GauntletRoom", 483)
  checkLocationVisible("SkyFortress_Spider_2F_RibbonRoom2", 484)
  checkLocationVisible("SkyFortress_Spider_2F_CheapRoom1", 485)
  checkLocationVisible("SkyFortress_Spider_2F_CheapRoom2", 486)
  checkLocationVisible("SkyFortress_Spider_2F_Vault1", 487)
  checkLocationVisible("SkyFortress_Spider_2F_Vault2", 488)
  checkLocationVisible("SkyFortress_Spider_2F_Incentive", 489)
  checkLocationVisible("SkyFortress_Provides_3F_Greed2", 490)
  checkLocationVisible("SkyFortress_Provides_3F_Greed1", 491)
  checkLocationVisible("SkyFortress_Provides_3F_Greed3", 492)
  checkLocationVisible("SkyFortress_Provides_3F_Greed4", 493)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack3", 494)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack2", 495)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack5", 496)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack4", 497)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack1", 498)
  checkLocationVisible("SkyFortress_Provides_3F_SixPack6", 499)
  checkLocationVisible("SkyFortress_Provides_3F_CCsGambit1", 500)
  checkLocationVisible("SkyFortress_Provides_3F_CCsGambit2", 501)
  checkLocationVisible("SkyFortress_Provides_3F_CCsGambit3", 502)
  checkLocationVisible("SkyFortress_Provides_3F_CCsGambit4", 503)
  checkLocationVisible("TempleOfFiendsRevisited_TiamatFloor_8F_MasamuneChest", 504)
  checkLocationVisible("TempleOfFiendsRevisited_KaryFloor_6F_Vault", 505)
  checkLocationVisible("TempleOfFiendsRevisited_KaryFloor_6F_KatanaChest", 506)
  checkLocationVisible("TempleOfFiendsRevisited_KaryFloor_6F_GreedChecks1", 507)
  checkLocationVisible("TempleOfFiendsRevisited_KaryFloor_6F_GreedChecks2", 508)
  checkLocationVisible("TempleOfFiendsRevisited_3F_Validation1", 509)
  checkLocationVisible("TempleOfFiendsRevisited_3F_Validation2", 510)
end

function updateOverworldChestCount(locationRefList, chestRefList, callback)
  if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Called updateOverworldChestCount")
  end
  for h,locationRef in pairs(locationRefList) do
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
      -- Do not auto-track this the user has manually modified it
      if location.Owner.ModifiedByUser then
          return
      end
      if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print(string.format("updateOverworldChestCount: locationRef %s, location.AvailableChestCount %s/%s", locationRef, location.AvailableChestCount, location.ChestCount))
      end

      local clearedCount = 0
--      print(string.format("updateOverworldChestCount: chestRefList:\n%s", dump_table(chestRefList)))
      for _, chestRef in pairs(chestRefList) do
        local chestLoc  = Tracker:FindObjectForCode(chestRef[1])
        local chestCode = Tracker:FindObjectForCode(chestRef[2])
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
          print(string.format("updateOverworldChestCount: chestRefList %s, chestLoc.AvailableChestCount %s, chestCode.Active %s", chestRefList[_][1], chestLoc.AvailableChestCount, chestCode.Active))
        end
        if chestLoc.AvailableChestCount == 0 or chestCode.Active == false then
          clearedCount = clearedCount + 1
          if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(string.format("updateOverworldChestCount: clearedCount %s", clearedCount))
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
  updateOverworldChestCount({"@Aldi Sea/Matoya's Cave/Chests"}, {{"@Matoya's Cave/Chest 1/","MatoyasCave_Chest1"},{"@Matoya's Cave/Chest 2/","MatoyasCave_Chest2"},{"@Matoya's Cave/Chest 3/","MatoyasCave_Chest3"}})
  updateOverworldChestCount({"@Aldi Sea/Dwarf Cave/Entrance"}, {{"@Dwarf Cave/Entrance 1/","DwarfCave_Entrance1"},{"@Dwarf Cave/Entrance 2/","DwarfCave_Entrance2"}})
  updateOverworldChestCount({"@Aldi Sea/Dwarf Cave/Treasury"}, {{"@Dwarf Cave/Treasury 1/","DwarfCave_Treasury1"},{"@Dwarf Cave/Treasury 2/","DwarfCave_Treasury2"},{"@Dwarf Cave/Treasury 3/","DwarfCave_Treasury3"},{"@Dwarf Cave/Treasury 4/","DwarfCave_Treasury4"},{"@Dwarf Cave/Treasury 5/","DwarfCave_Treasury5"},{"@Dwarf Cave/Treasury 6/","DwarfCave_Treasury6"},{"@Dwarf Cave/Treasury 7/","DwarfCave_Treasury7"},{"@Dwarf Cave/Treasury 8/","DwarfCave_Treasury8"}})
  updateOverworldChestCount({"@Aldi Sea/Coneria Castle/Treasury"}, {{"@Coneria Castle/Treasury 1/","ConeriaCastle_Treasury1"},{"@Coneria Castle/Treasury 2/","ConeriaCastle_Treasury2"},{"@Coneria Castle/Treasury 3/","ConeriaCastle_Treasury3"},{"@Coneria Castle/Treasury 4/","ConeriaCastle_Treasury4"},{"@Coneria Castle/Treasury 5/","ConeriaCastle_Treasury5"}})
  updateOverworldChestCount({"@Aldi Sea/Elf Castle/Treasury"}, {{"@Elf Castle/Treasury 1/","ElflandCastle_Treasury1"},{"@Elf Castle/Treasury 2/","ElflandCastle_Treasury2"},{"@Elf Castle/Treasury 3/","ElflandCastle_Treasury3"},{"@Elf Castle/Treasury 4/","ElflandCastle_Treasury4"}})
end

--ScriptHost:AddOnLocationSectionChangedHandler("overworldChestWatcher", updateOverworld)
ScriptHost:AddWatchForCode("locationVisibleWatcher", "showAllChests", visibleLocations)
