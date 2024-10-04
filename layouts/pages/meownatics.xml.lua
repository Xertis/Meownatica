local toml = require 'meownatica:tools/read_toml'
local meow_change = require 'meownatica:schematics_editors/change_schem'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'

function refresh()
    local meownatics = toml.get_all_schem()

    document.root:clear()
    for _, name in ipairs(meownatics) do
        local schem = meow_change.get_schem(name, false, false)

        if schem then
            local version = schem[1]
            local description = schem[6] or 'Deprecated version'
            document.root:add(gui.template("meownatic", {version = version, description = description, name = name}))
        end
    end

    if #meownatics <= 0 then
        document.root.size = {200,200}
        document.root.pos = {130,60}
        document.root:add("<image src='menu/not_found' size='200,200'/>")
    end
end

function del_meownatic(name)
    meow_schem.save_to_config(nil, name)
    refresh()
end

function on_open()
    refresh()
end