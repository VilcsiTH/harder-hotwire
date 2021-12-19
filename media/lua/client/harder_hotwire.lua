-- author: rez
-- version: 0.2 (2020-07-13)
-- based on: 40.43

--[[
	Increases hotwire difficulty.
	Adds ability to un-hotwire engine and craft car key with timed
	actions that are intentionally slow.
	
	COPYRIGHT:
	The idea, artwork, placement, English and Russian translations,
	code and other things introduced in this mod are copyrighted 
	to Rez.
	Localizations are copyrighted to steam users who provided them
	(see localization files).
	Base game functions are copyrighted to The Indie Stone.
]]--

local hotwire_electrical = 1;
local hotwire_mechanics = 2;
local unhotwire_electrical = 2;
local unhotwire_mechanics = 3;
local key_electrical = 1;
local key_mechanics = 2;
local key_metalworking = 3;


function onUnHotwire(playerObj)
	ISTimedActionQueue.add(unhotwire:new(playerObj));
end

function onGetKey(playerObj)
	ISTimedActionQueue.add(get_key:new(playerObj));
end

function harder_hotwire_showRadialMenu(playerObj)
	--[[	Basically the same function from devs code.
		Should be actively maintained for every PZ release.	]]--
		
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0;
	if isPaused then return end

	local vehicle = playerObj:getVehicle();
	if not vehicle then
		ISVehicleMenu.showRadialMenuOutside(playerObj);
		return
	end

	local menu = getPlayerRadialMenu(playerObj:getPlayerNum());
	menu:clear();

	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil);
		end
		menu:undisplay();
		return
	end

	menu:setX(getPlayerScreenLeft(playerObj:getPlayerNum()) + getPlayerScreenWidth(playerObj:getPlayerNum()) / 2 - menu:getWidth() / 2);
	menu:setY(getPlayerScreenTop(playerObj:getPlayerNum()) + getPlayerScreenHeight(playerObj:getPlayerNum()) / 2 - menu:getHeight() / 2);

	local seat = vehicle:getSeat(playerObj);
	menu:addSlice(getText("IGUI_SwitchSeat"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISVehicleMenu.onShowSeatUI, playerObj, vehicle);

	if vehicle:isDriver(playerObj) and vehicle:isEngineWorking() then
		if vehicle:isEngineRunning() then
			menu:addSlice(getText("ContextMenu_VehicleShutOff"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), ISVehicleMenu.onShutOff, playerObj);
		else
			if not vehicle:isEngineStarted() then
				if SandboxVars.VehicleEasyUse then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, playerObj);
				elseif not vehicle:isHotwired() and (playerObj:getInventory():haveThisKeyId(vehicle:getKeyId()) or vehicle:isKeysInIgnition()) then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, playerObj);
				elseif vehicle:isHotwired() then
					menu:addSlice(getText("ContextMenu_VehicleStartEngine"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onStartEngine, playerObj);
				end
			end
		end
	end

	-- hotwire, un-hotwire and get key
	if vehicle:isDriver(playerObj) and
		not vehicle:isEngineStarted() and
		not vehicle:isEngineRunning() and
		not SandboxVars.VehicleEasyUse and
		not vehicle:isKeysInIgnition() and
		not playerObj:getInventory():haveThisKeyId(vehicle:getKeyId()) then
			if vehicle:isHotwired() then
				-- un-hotwire
				if playerObj:getPerkLevel(Perks.Electricity) >= unhotwire_electrical and
					playerObj:getPerkLevel(Perks.Mechanics) >= unhotwire_mechanics then
						menu:addSlice(getText("ContextMenu_VehicleUnhotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), onUnHotwire, playerObj);
				else
					menu:addSlice(getText("ContextMenu_VehicleUnhotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj);
				end
			else
				-- hotwire
				if playerObj:getPerkLevel(Perks.Electricity) >= hotwire_electrical and
					playerObj:getPerkLevel(Perks.Mechanics) >= hotwire_mechanics then
						menu:addSlice(getText("ContextMenu_VehicleHotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), ISVehicleMenu.onHotwire, playerObj);
				else
					menu:addSlice(getText("ContextMenu_VehicleHotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj);
				end
			
				-- get key
				if playerObj:getPerkLevel(Perks.Electricity) >= key_electrical and
					playerObj:getPerkLevel(Perks.Mechanics) >= key_mechanics and
					playerObj:getPerkLevel(Perks.MetalWelding) >= key_metalworking then
						menu:addSlice(getText("ContextMenu_VehicleGetKey"), getTexture("media/ui/vehicles/vehicle_add_key.png"), onGetKey, playerObj);
				else
					menu:addSlice(getText("ContextMenu_VehicleGetKeySkill"), getTexture("media/ui/vehicles/vehicle_add_key_fail.png"), nil, playerObj);
				end
			end
	end

	if vehicle:isDriver(playerObj) and vehicle:hasHeadlights() then
		if vehicle:getHeadlightsOn() then
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOff"), getTexture("media/ui/vehicles/vehicle_lightsOFF.png"), ISVehicleMenu.onToggleHeadlights, playerObj);
		else
			menu:addSlice(getText("ContextMenu_VehicleHeadlightsOn"), getTexture("media/ui/vehicles/vehicle_lightsON.png"), ISVehicleMenu.onToggleHeadlights, playerObj);
		end
	end

	if vehicle:getPartById("Heater") then
		local tex = getTexture("media/ui/vehicles/vehicle_temperatureHOT.png");
		if (vehicle:getPartById("Heater"):getModData().temperature or 0) < 0 then
			tex = getTexture("media/ui/vehicles/vehicle_temperatureCOLD.png");
		end
		if vehicle:getPartById("Heater"):getModData().active then
			menu:addSlice(getText("ContextMenu_VehicleHeaterOff"), tex, ISVehicleMenu.onToggleHeater, playerObj);
		else
			menu:addSlice(getText("ContextMenu_VehicleHeaterOn"), tex, ISVehicleMenu.onToggleHeater, playerObj);
		end
	end
	
	if vehicle:isDriver(playerObj) and vehicle:hasHorn() then
		menu:addSlice(getText("ContextMenu_VehicleHorn"), getTexture("media/ui/vehicles/vehicle_horn.png"), ISVehicleMenu.onHorn, playerObj);
	end
	
	if vehicle:hasLightbar() then
		menu:addSlice(getText("ContextMenu_VehicleLightbar"), getTexture("media/ui/vehicles/vehicle_lightbar.png"), ISVehicleMenu.onLightbar, playerObj);
	end

	if seat <= 1 then -- only front seats can access the radio
		for partIndex=1,vehicle:getPartCount() do
			local part = vehicle:getPartByIndex(partIndex-1);
			if part:getDeviceData() and part:getInventoryItem() then
				menu:addSlice(getText("IGUI_DeviceOptions"), getTexture("media/ui/vehicles/vehicle_speakersON.png"), ISVehicleMenu.onSignalDevice, playerObj, part);
			end
		end
	end

	local door = vehicle:getPassengerDoor(seat);
	local windowPart = VehicleUtils.getChildWindow(door);
	if windowPart and (not windowPart:getItemType() or windowPart:getInventoryItem()) then
		local window = windowPart:getWindow();
		if window:isOpenable() and not window:isDestroyed() then
			if window:isOpen() then
				option = menu:addSlice(getText("ContextMenu_Close_window"), getTexture("media/ui/vehicles/vehicle_windowCLOSED.png"), ISVehiclePartMenu.onOpenCloseWindow, playerObj, windowPart, false);
			else
				option = menu:addSlice(getText("ContextMenu_Open_window"), getTexture("media/ui/vehicles/vehicle_windowOPEN.png"), ISVehiclePartMenu.onOpenCloseWindow, playerObj, windowPart, true);
			end
		end
	end

	if not vehicle:areAllDoorsLocked() then
		menu:addSlice(getText("ContextMenu_Lock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, playerObj, vehicle, true);
	else
		menu:addSlice(getText("ContextMenu_Unlock_Doors"), getTexture("media/ui/vehicles/vehicle_lockdoors.png"), ISVehiclePartMenu.onLockDoors, playerObj, vehicle, false);
	end
	
	if vehicle:getCurrentSpeedKmHour() > 1 then
		menu:addSlice(getText("ContextMenu_VehicleMechanicsStopCar"), getTexture("media/ui/vehicles/vehicle_repair.png"), nil, playerObj, vehicle);
	else
		menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenu.onMechanic, playerObj, vehicle);
	end
	
	if (not isClient() or getServerOptions():getBoolean("SleepAllowed")) then
		local doSleep = true;
		if playerObj:getStats():getFatigue() <= 0.3 then
			menu:addSlice(getText("IGUI_Sleep_NotTiredEnough"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, vehicle);
			doSleep = false;
		else
			-- Sleeping pills counter those sleeping problems
			if playerObj:getSleepingTabletEffect() < 2000 then
				-- In pain, can still sleep if really tired
				if playerObj:getMoodles():getMoodleLevel(MoodleType.Pain) >= 2 and playerObj:getStats():getFatigue() <= 0.85 then
					menu:addSlice(getText("ContextMenu_PainNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, vehicle);
					doSleep = false;
					-- In panic
				elseif playerObj:getMoodles():getMoodleLevel(MoodleType.Panic) >= 1 then
					menu:addSlice(getText("ContextMenu_PanicNoSleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, vehicle);
					doSleep = false;
					-- tried to sleep not so long ago
				elseif (playerObj:getHoursSurvived() - playerObj:getLastHourSleeped()) <= 1 then
					menu:addSlice(getText("ContextMenu_NoSleepTooEarly"), getTexture("media/ui/vehicles/vehicle_sleep.png"), nil, playerObj, vehicle);
					doSleep = false;
				end
			end
		end
		if doSleep then
			menu:addSlice(getText("ContextMenu_Sleep"), getTexture("media/ui/vehicles/vehicle_sleep.png"), ISVehicleMenu.onSleep, playerObj, vehicle);
		end
	end
	
	menu:addSlice(getText("IGUI_ExitVehicle"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onExit, playerObj);
	menu:addToUIManager();

	if JoypadState.players[playerObj:getPlayerNum()+1] then
		setJoypadFocus(playerObj:getPlayerNum(), menu);
		playerObj:setJoypadIgnoreAimUntilCentered(true);
	end
end

ISVehicleMenu.showRadialMenu = harder_hotwire_showRadialMenu;
