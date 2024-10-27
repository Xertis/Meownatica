local toml = require 'meownatica:tools/read_toml'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local lang = require 'meownatica:frontend/lang'

local PARAMETERS = {
    ["setair"] = {'Set Air', 'bool', lang.get("setair tooltip")},
    ["setmeowdelenie"] = {'Set Meow Delenie', 'bool', lang.get("setmeowdelenie tooltip")},
    ["setblockontick"] = {'Set Blocks On Tick', 'number', lang.get("setblockontick tooltip")},
    ["setentities"] = {'Set Entities', 'bool', lang.get("setentities tooltip")},
    ["entitiessave"] = {'Entities Save', 'bool', lang.get("entitiessave tooltip")},
    ["blocksupdate"] = {'Blocks Update', 'bool', lang.get("blocksupdate tooltip")},
    ["language"] = {'Language (eng/rus)', 'string', lang.get("language tooltip")},
    ["smartrotateon"] = {'Smart Rotation', 'bool', lang.get("smartrotateon tooltip")},
    ["onplaced"] = {'On Placed', 'bool', lang.get("onplaced tooltip")},
    ["onbroken"] = {'On Broken', 'bool', lang.get("onbroken tooltip")}
}


local function create_checkbox(id, name, tooltip, cheaked)
    tooltip = tooltip or ''

    document.root:add(string.format(
        "<checkbox id='%s' consumer='function(x) set_value(\"%s\", x) end' checked='%s' tooltip='%s'>%s</checkbox>",
        id, id, cheaked, tooltip, name
    ))
end

local function create_textbox(id, name, tooltip, text)
    tooltip = tooltip or ''

    document.root:add(string.format(
        "<textbox id='%s' consumer='function(x) set_value(\"%s\", x) end' placeholder='%s' tooltip='%s'>%s</textbox>",
        id, id, name, tooltip, text
    ))
end

local function create_trackbar(id, name, tooltip, val)
    tooltip = tooltip or ''
    
    document.root:add(string.format(
        "<label id='%s' tooltip='%s'>%s</label>",
        id .. "_label", tooltip, name .. ' (' .. val .. ')'
    ))
    document.root:add(string.format(
        "<trackbar id='%s' consumer='function(x) set_value(\"%s\", x) end' value='%s' tooltip='%s' min='100' max='1000' step='10'>%s</trackbar>",
        id, id, val, tooltip, name
    ))
end

local function create_label(id, text)

    document.root:add(string.format(
        "<label id='%s'>%s</label>",
        id, text
    ))
end

function set_value(id, val)
    meow_schem.save_to_config(nil, nil, {id, val}, true)
    if PARAMETERS[id][2] == 'number' then
        document[id .. '_label'].text = PARAMETERS[id][1] .. ' (' .. val .. ')'
    end
end

function on_open() 
    local checkboxes = {}
    local textboxes = {}
    local trackbars = {}

    for name, value in pairs(PARAMETERS) do
        if value[2] == 'bool' then
            table.insert(checkboxes, {name, value[1], value[3]})
        elseif value[2] == 'number' then
            table.insert(trackbars, {name, value[1], value[3]})
        elseif value[2] == 'string' then
            table.insert(textboxes, {name, value[1], value[3]})
        end
    end

    for _, checkbox in ipairs(checkboxes) do
        create_checkbox(checkbox[1], checkbox[2], checkbox[3], toml.get(checkbox[1]))
    end

    for _, trackbar in ipairs(trackbars) do
        create_trackbar(trackbar[1], trackbar[2], trackbar[3], toml.get(trackbar[1]))
    end

    for _, textbox in ipairs(textboxes) do
        create_textbox(textbox[1], textbox[2], textbox[3], toml.get(textbox[1]))
    end
end
