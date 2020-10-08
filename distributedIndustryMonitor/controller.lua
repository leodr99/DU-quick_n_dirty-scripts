--[[ --------MASTER/CONTROLLER Prog. Board
     Setup:

     Connect/link the databank that is connected to the worker/slave boards, connect the core (don't forget this, or no custom names shall show up!),
     and displays (connect one display per worker/slave board that you'll use/define; and NAME THEM! or use the default slot names, but remmember who is who ffs, you'll need it later).
     Edit the lua parameters (right click, advanced>>edit lua parameters; set the refresh/timer/tick rate at what the screens will update; make sure it's >= worker pboard refresh.)

     Now comes the somewhat "maybe" tricky part.
     If you have more than one worker/slave board, then you'll need
     to copy&paste some code, and change a couple lines of code. I'll try my best to lead you on how to do it.

     Example, if you have 3 worker/slave boards (make sure their IDs are unique! and note them down. you'll need them) connected and feeding to the databank,
     then you'll need 3 displays. each display is going to show you their respective board (1:1 ratio for now; working on this part).
     Now, how do you do that, simple. To try and keep it simple for even new players to the game, I tried to keep this realy basic. so, here we go.

     duplicate as many times, as many displays/worker boards you've got connected, the following line that you have put into the tick/timer section "screens":
     display.setHTML(renderHTML("PB1"))

     If you notice the PB1, is the default unique ID for the initial single worker/slave board. and you'll also notice that the display slot is named "display".
     So, if you have more displays and you've named their respective slots on the controller board, for example, display1, display2, displayMetalWorks...
     You'd change the code in the tick/timer filter, like so:

     display1.setHTML(renderHTML("PB1"))   it'll show the status of the industries connected to the PB1 worker/slave board on display1.
     display2.setHTML(renderHTML("PB2"))   it'll show the status of the industries connected to PB2 on the display2... and so on.
     displayMetalWorks.setHTML(renderHTML('MetalWorks'))  it'll show the status of indy's connected to worker boards MetalWorks on displayMetalWorks...   you catch my drift?
     |----------------|                   |----------|
     display_slot_name  . function ( function ('UID you defined on the worker/slave board') )

     There you have it.

     So, just make sure, that you are using unique identifiers on the worker/slave boards (check the worker.lua header for info), and that you know where the connected displays are linked to (which slots on the controller board).
     Then, put an extra line on the tick/timer filter, with the correct display slot name, and the worker/slave board ID, and you shoul'd be golden.

     Insert code below onto unit>>start() filter and the timer/tick.
     ]]
--// the "magic" starts here...
--
if display1 then
    display1.activate()
    display1.setCenteredText("Industry Monitor Starting...")
    end
if display2 then
    display2.activate()
    display2.setCenteredText("Industry Monitor Starting...")
    end
if display3 then
    display3.activate()
    display3.setCenteredText("Industry Monitor Starting...")
    end
if displayAlerts then
    displayAlerts.activate()
    displayAlerts.setCenteredText("Industry Monitor Starting...")
    end



unit.hide()
--

--variables
_mode = 0 --export: default mode: Industry Monitor (0) alternate mode, Alert Monitor (1), the latter will only exhibit error'd industries.
local refresh = 10 --export: refresh info screen every # seconds (keep it higher than the worker boards)
local _strON  = "ON" --export: string to display when industry is ON
local _strOFF = "OFF" --export: string to display when industry is OFF
local _strHLD = "HLD" --export: string to display when industry is on hold/maintain mode
local _strREZ = "REZ" --export: string to display when industry is in need for resources (input)
local _strERR = "ERR" --export: string to display when industry is in fault/error mode
local _colorBGHeader = "red" --export: html color code, that you want the header background to have. can be #ffffff values, or simple colour names (red, yellow, green.... check htmlcolorcodes.com ;] ) 
local _colorFGHeader = "black" --export: html colour code, that you want the header font to have. can be #ffffff values, or simple colour names (red, yellow, green.... check htmlcolorcodes.com ;] ) 
local _colorTable = "white" --export: industry names and efficiency font colour
_dbCounter = 0
--

--functions
function tablelenght(input)
    local count = 0
    for _ in pairs(input) do count = count + 1 end
    return count
end
--
function getAlerts()
    local _keys = json.decode(databank.getKeys())
    local _datum = {}
    local strings = {}

    if _keys then
        for i=1, #_keys do
            local _tmp = json.decode(databank.getStringValue(_keys[i]))
            for x=1, tablelenght(_tmp) do
                if string.match(_tmp[x].status, "ERR") then
                    table.insert(_datum, core.getElementNameById(_tmp[x].id))
                end
            end
        end
    else
        system.print("MASTER:DB_ERR:NO_KEYS! Empty Keys!")
    end
    if #_datum > 0 then
        local count = 0
        for z=1, tablelenght(_datum) do
            local str = ""
            count = count + 1
            str = str .. [[<th style="text-align: left;">]] .. _datum[z] .. [[</th><th style="color: red; !important;">]] .. _strERR .. "</th>"
            table.insert(strings, str)
            if count == 9 then
                break
            end
        end
        return strings
    else
        table.insert(strings, [[<td colspan="2" style="text-align: center; color: green; !important; max-width: 100%; font-size: 12rem;">!ALL CLEAR!</td>]])
        return strings
    end
end
--
function getWorkerDbData(_PBID)
    local _data = json.decode(databank.getStringValue(_PBID))
    local strings = {}
    if _data then
        for k,v in pairs(_data) do
            local str = ""
            if string.match(_data[k].status, "OFF") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. "</th><th>" .. _strOFF .. "</th><th>NaN</th>"
                elseif string.match(_data[k].status, "ON") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: green;">]] .. _strON .. "</th><th>" .. string.format("%.1f",_data[k].efficiency * 100) .."</th>"
                elseif string.match(_data[k].status, "HLD") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: yellow;">]] .. _strHLD .. "</th><th>" .. string.format("%.1f",_data[k].efficiency * 100) .."</th>"
                elseif string.match(_data[k].status, "REZ") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: orange; !important;">]] .. _strREZ .. "</th><th>" .. string.format("%.1f",_data[k].efficiency * 100) .."</th>"
                elseif string.match(_data[k].status, "ERR") then 
                    str = str .. [[<th style="text-align: left;">]] .. core.getElementNameById(_data[k].id) .. [[</th><th style="color: red; !important;">]] .. _strERR .. "</th><th>" .. string.format("%.1f",_data[k].efficiency * 100) .."</th>"
                else str = [[<th colspan="3" style="color: red; !important;">FUBAR</th>]]
            end
            table.insert(strings, str)
        end
    else system.print("DB_WARN:READ_ERROR!")  --you forgot to connect the damned databank, or turn on the worker/slave board :P
    end
    --
    return strings        
end    
--
function renderHTML(_pbID)
    local htmlout = ""
    local _status = {}
    local header = ""
    local table = ""
    local div = ""
    if _mode == 1 or string.match(_pbID, "lert") then
        _status = getAlerts()
        header = "<th>ALERT</th><th>CODE</th>"
        table = [[<table style="width: 100%; font-size: 8rem;">]]
        div = [[<div class="row" style="justify-content: center;">]]
    else
        _status = getWorkerDbData(_pbID)
        header = "<th>Industry</th><th>Status</th><th>%</th>"
        table = [[<table style="margin-left: auto; margin-right: auto; width: 98%; font-size: 9rem;">]]
        div = [[<div class="row" style="justify-content: center;">]]
    end
    --
    for i=1, #_status do
        htmlout = htmlout .. [[<tr style="font-size: 7rem; font-family: roboto">]] .. _status[i] .. "</tr>"
    end
    --
    local html = [[
    <style>
    body {
      border: 3px solid red;
    }
    
    .container {
      font-size: 10rem;
      color:]] .. _colorTable .. [[;
    }
    </style>
    <div class="container">]] .. div .. table ..
    [[<tr style="background-color:]] .. _colorBGHeader ..
    "; color: "  .. _colorFGHeader .. [[; font-size: 10rem; text-align: center;">]] 
    .. header ..[[</tr>]] .. htmlout .. [[</table></div></div>]]
    --    
    return html
end
--
--runtime
if databank then
    databank.clear()
    system.print("MASTER: DB_CLEAR!")
    unit.setTimer("screens", refresh)
else
    system.print("ERROR: DB MISSING!")
end


--[[ insert into unit>>tick("screens") filter]]
--
_dbCounter = _dbCounter + 1
if _dbCounter >= 10 then
    databank.clear()
    _dbCounter = 0
    --this will clear all keys from the DB every 10 cycles (10 x refresh timer; seconds)
    --in order to display properly, if you remove/add new industries, during runtime.
else
    display1.setHTML(renderHTML('PB1'))
    display2.setHTML(renderHTML('PB2'))
    display3.setHTML(renderHTML('PB3'))
    displayAlerts.setHTML(renderHTML('Alerts'))
    --[[insert or remove more above this line, one line per display:pboard combo, example:
    display2.setHTML(renderHTML('PB2') -- it'll show the status of the industries connected to
    worker prog.broad with UID "PB2" on the display connected to, the named slot "display2".
    
    Notes: 
    1)if running in Alert Monitor Mode (only), you'll need only one display. so just add/leave a line like this, or leave the default one:
    display.setHTML(renderHTML('Alerts') -- make sure there's a display connected and that its slot
    is named "display". if not, change the line accordingly. also ensure that the lua parameter for the mode is set to 1.
    In this mode, it'll show only industries connected to the worker prog.boards that are in error (failed status; check codex for them.).
    
    2) dual mode (monitor + alerts)
    then follow the initial instruction (not note #1), and create another line like this:
    displayAlerts.setHTML(renderHTML('Alerts')) -- where displayAlerts is the name of the slot where you have the dedicated monitor connected.
    you can have displays to monitor the industry and a added one just for Alerts/Alarms (faulted industries; be advised that it's not yet possible
     identify industries with Unknown Server Error. since those do not provide any alarm code via the lua API.).
    ]]
end


--[[ insert into unit>>stop() filter]]
--
if display1 then
    display1.clear()
    display1.deactivate()
    end
if display2 then
    display2.clear()
    display2.deactivate()
    end
if display3 then
    display3.clear()
    display3.deactivate()
    end
if displayAlerts then
    displayAlerts.clear()
    displayAlerts.deactivate()
    end

--EOF
