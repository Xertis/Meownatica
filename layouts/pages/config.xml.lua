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

local function create_label(id, text)

    document.root:add(string.format(
        "<label id='%s'>%s</label>",
        id, text
    ))
end

function set_value(id, val)
    meow_schem.save_to_config(nil, nil, {id, val}, true)
end

function on_open()
    for name, value in pairs(PARAMETERS) do
        if value[2] == 'bool' then
            create_checkbox(name, value[1], value[3], toml.get(name))
        end
    end
end