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
					if playerObj:getPerkLevel(Perks.Electricity) >= unhotwire_electrical and
						playerObj:getPerkLevel(Perks.Mechanics) >= unhotwire_mechanics then
							menu:addSlice(getText("ContextMenu_VehicleUnhotwire"), getTexture("media/ui/vehicles/vehicle_ignitionON.png"), onUnHotwire, playerObj);
					else
						menu:addSlice(getText("ContextMenu_VehicleUnhotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj);
					end
				else
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
		menu:addToUIManager()
	end
end