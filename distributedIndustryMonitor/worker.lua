--[[ -------------------WORKER Prog. Board
     setup: make sure a databank is connected and named as such.
     then just edit the lua parameters (right click, advanced>edit lua parameters)
     connect the industries, up to 9 of them.
     rename your industries, in order to show up on the screens properly.
     --
     Insert code below onto unit>>start() filter]]
--
unit.hide()
--helpers
json = require ("dkjson")

--variables
PBID = "PB1" --export: this worker's board unique ID (Ex:. PB1; for databank purposes; must be unique!)
local refresh = 7 --export: refresh interval (write to db, every # seconds; keep it lower than the master controller refresh timer. recommended >=15s for reduced cpu load)

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
            result = "REZ"
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



--[[ inserto code below onto unit>>tick(updateDB) filter]]
--
if databank then
    writeDB()
else
    system.print("DB_ERR: NO DATABANK FOUND! check if databank slot is named as such!")
end

--EOF
