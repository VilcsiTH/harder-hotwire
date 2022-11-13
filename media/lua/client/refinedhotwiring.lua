function onUnHotwire(playerObj)
	ISTimedActionQueue.add(unhotwire:new(playerObj));
end

function onGetKey(playerObj)
	ISTimedActionQueue.add(get_key:new(playerObj));
end

local old_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu

function ISVehicleMenu.showRadialMenu(playerObj)
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end
	old_ISVehicleMenu_showRadialMenu(playerObj)
	local vehicle = playerObj:getVehicle()
	if vehicle ~= nil then
		local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
		
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil)
		end
		menu:undisplay()
		return
	end
		
		-- un-hotwire and get key
		if vehicle:isDriver(playerObj) and
			not vehicle:isEngineStarted() and
			not vehicle:isEngineRunning() and
			not SandboxVars.VehicleEasyUse and
			not vehicle:isKeysInIgnition() and
			not playerObj:getInventory():haveThisKeyId(vehicle:getKeyId()) then
				if vehicle:isHotwired() then
					-- un-hotwire
					if playerObj:getPerkLevel(Perks.Electricity) >= SandboxVars.RefinedHotwiring.UnhotwireElectrical and
						playerObj:getPerkLevel(Perks.Mechanics) >= SandboxVars.RefinedHotwiring.UnhotwireMechanics then
							menu:addSlice(getText("ContextMenu_VehicleUnhotwire", SandboxVars.RefinedHotwiring.UnhotwireElectrical, SandboxVars.RefinedHotwiring.UnhotwireMechanics), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), onUnHotwire, playerObj);
					else
						menu:addSlice(getText("ContextMenu_VehicleUnhotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj);
					end
				else
					-- get key
					if playerObj:getPerkLevel(Perks.Electricity) >= SandboxVars.RefinedHotwiring.KeyElectrical and
						playerObj:getPerkLevel(Perks.Mechanics) >= SandboxVars.RefinedHotwiring.KeyMechanics and
						playerObj:getPerkLevel(Perks.MetalWelding) >= SandboxVars.RefinedHotwiring.KeyMetalworking then
							menu:addSlice(getText("ContextMenu_VehicleGetKey"), getTexture("media/ui/vehicles/vehicle_add_key.png"), onGetKey, playerObj);
					else
						menu:addSlice(getText("ContextMenu_VehicleGetKeySkill", SandboxVars.RefinedHotwiring.KeyElectrical, SandboxVars.RefinedHotwiring.KeyMechanics, SandboxVars.RefinedHotwiring.KeyMetalworking), getTexture("media/ui/vehicles/vehicle_add_key_fail.png"), nil, playerObj);
					end
				end
		end
		menu:addToUIManager()
	end
end