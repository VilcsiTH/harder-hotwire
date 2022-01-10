-- author: rez
-- version: 0.2-1 (2022-01-10)
-- based on: 40.43
-- modified: ShadowSWilliam
-- for: 41.65

require "TimedActions/ISBaseTimedAction"

unhotwire = ISBaseTimedAction:derive("unhotwire")

function unhotwire:isValid()
	local vehicle = self.character:getVehicle()
	return vehicle ~= nil and
		vehicle:isDriver(self.character) and
		not vehicle:isEngineRunning() and
		not vehicle:isEngineStarted()
end

function unhotwire:update()
end

function unhotwire:start()
end

function unhotwire:stop()
	ISBaseTimedAction.stop(self)
end

function unhotwire:perform()
	local vehicle = self.character:getVehicle()
	sendClientCommand(self.character, "vehicle", "cheatHotwire", {vehicle = vehicle:getId(), hotwired = false, broken = false})
	ISBaseTimedAction.perform(self)
end

function unhotwire:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.maxTime = 500 - (character:getPerkLevel(Perks.Electricity) * 8);
	return o
end
