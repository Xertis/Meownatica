local toml = require 'meownatica:tools/read_toml'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'

local PARAMETERS = {
    ["setair"] = {'Set Air', 'bool', 'tooltip'},
    ["setmeowdelenie"] = {'Set Meow Delenie', 'bool', 'tooltip'},
    ["setblockontick"] = {'Set Block On Tick', 'number', 'tooltip'},
    ["setentities"] = {'Set Entities', 'bool', 'tooltip'},
    ["entitiessave"] = {'Entities Save', 'bool', 'tooltip'},
    ["blocksupdate"] = {'Blocks Update', 'bool', 'tooltip'},
    ["language"] = {'Language', 'string', 'tooltip'},
    ["smartrotateon"] = {'Smart Rotation', 'bool', 'tooltip'},
}


local function create_checkbox(id, name, tooltip, cheaked)
    tooltip = tooltip or ''

    document.root:add(string.format(
        "<checkbox id='%s' consumer='function(x) set_value(\"%s\", x) end' checked='%s' tooltip='%s'>%s</checkbox>",
        id, id, cheaked, tooltip, name
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
    for name, value in pairs(PARAMETERS) do
        if value[2] == 'bool' then
            create_checkbox(name, value[1], value[3], toml.get(name))
        elseif value[2] == 'number' then
            create_trackbar(name, value[1], value[3], toml.get(name))
        end
    end
end