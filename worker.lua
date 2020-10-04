--[[ -------------------WORKER Prog. Board
     Insert code onto unit>>start() filter and the timer/tick (check the comments, it tells you everything), connect the databank, and name the slot databank.
     then connect/link your industries that you want to monitor, on the remaining 9 slots.
     after all links are setup, rename the connected industries, with discernable names, doesn't matter what, anything goes.
     Next, edit the lua parameters, right click the PBoard, choose advanced>>edit lua parameters.
     please make sure that the Programming board ID is unique, as not in use by any other worker/slave board that you'll connect
     to the databank. Also choose a refresh rate (timer for the db sync), make sure that it's less than the controller refresh timer.
     also, small tip, to not use a lot of cpu resources, i recommend to keep at >=5 seconds. it all depends on the performance of
     your rig, and how fast you want to see the industry status changing... are you that bored? :D
     ]]
--
unit.hide()
--helpers
json = require ("dkjson")

--variables
local PBID = "PB1" --export: this worker's unique ID (Ex:. PB1; for databank purposes)
local refresh = 5 --export: refresh interval (write to db, every # seconds; keep it lower than the master/controller refresh)

--functions
function tablelenght(input)
    local count = 0
    for _ in pairs(input) do count = count + 1 end
    return count
end

function updateIndustry(_PBID)
    local industries = {}

    function convertStatus(_status)
        local result = ""
        if string.match(_status, "RUNNING") then
            result = "ON"
        elseif string.match(_status, "STOPPED") then
            result = "OFF"
        elseif string.match(_status, "PENDING") then
            result = "HLD"
        elseif string.match(_status, "INGREDIENT") then
            result = "REZ "
        else
            result = "ERR"
            end
        return result
    end

    function newIndustry(_element)
        local industry = 
        {
            id = _element.getId();
            status = convertStatus(_element.getStatus());
            efficiency = _element.getEfficiency();
        }
        return industry
    end
       
    --//----------//--
    --runtime
    
    for key, value in pairs(unit) do
        if type(value) == "table" and type(value.export) == "table" then -- `value` is an element and `key` is the slot name
            if value.getElementClass then
                if string.match(value.getElementClass(), "Industry") then
                    table.insert(industries, newIndustry(value))
                end
            end
        end
    end
    return industries
end
--

function writeDB()
    local data = updateIndustry(PBID)
    databank.setStringValue(PBID, json.encode(data))
end
--

--//runtime\\--
--
unit.setTimer("updateDB", refresh)


--[[ inserto into unit>>tick(updateDB) filter]]
--
writeDB()

--EOF
