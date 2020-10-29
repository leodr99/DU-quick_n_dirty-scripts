--[[unit.start()]]
--crappy security watchdog v0.1 by leodr (while sober)
unit.hide()
--vars
local debug = false --export: debug functions, to get player id.
local allowedUserIDs = {56008, 00001} --change here the user ids you want to allow.
local playerID = unit.getMasterPlayerId()
local playerName = system.getPlayerName(playerID)
doors = {}
screens = {}
local htmlHeader = [[<div class="bootstrap" style="font-size:8.299561vw; font-family: 'Helvetica'; background-image: url('assets.prod.novaquark.com/73857/55225284-1741-4937-acf5-800244b58dd2.jpg');  background-repeat: no-repeat; background-size: cover;]]
--
--functions
function securityCheck()
    local _allowed = false
    if #allowedUserIDs > 0 then
        for i=1, #allowedUserIDs do
            if allowedUserIDs[i] == playerID then
                _allowed = true
            end
        end
    else system.print("ERROR: No Allowed User IDs defined") end
    return _allowed
end
    
function getElements()
    local _doors = {}
    local _screens = {}
    for k,v in pairs(unit) do
        if type(v) == "table" and type(v.export) == "table" then
            if v.getElementClass then
                if v.getElementClass():lower():find("door") then
                    table.insert(_doors, v)
                end
                if v.getElementClass():lower():find("screen") then
                    table.insert(_screens, v)
                end
            end
        end
    end
    if #_doors > 0 and #_screens > 0 then
         return _doors, _screens
    else system.print("ERROR: No screen/door element found! check setup/links") end
end

--main(void) :P
---
doors, screens = getElements()
if securityCheck() then
    html = htmlHeader .. [[ color: green;"> Welcome, ]] .. playerName .. [[</div>]]
    for i=1, #screens do
        screens[i].activate()
        screens[i].setHTML(html)
    end
    for i=1, #doors do
        doors[i].activate()
    end
else
    html = htmlHeader .. [[ color: red;">ACCESS DENIED</div>]]
    for i=1, #screens do
        screens[i].activate()
        screens[i].setHTML(html)
    end
end
if debug then
    system.print("User ID: " .. playerID .. "  |  User Name: " .. playerName)
    end
