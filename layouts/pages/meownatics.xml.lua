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
        else
            document.root:add(gui.template("meownatic", {version = "undefined", description = "undefined", name = name}))
        end
    end
    document.root:add("<panel size='453,204' padding='2' color='#0000004C'><button id='add' onclick='add_meownatic()' z-index='2'>Add</button></panel>")

    if #meownatics <= 0 then
        document.root:clear()
        document.root.size = {200,200}
        document.root.pos = {130,60}
        document.root:add("<image src='menu/not_found' size='200,200'/>")
    end
end

function add_meownatic(name)
    if not name then
        document.root:clear()
        for _, f in ipairs(file.list(toml.sys_get('savepath'))) do
            local name = f:gsub("modules/", "")
            name = name:gsub("%.lua$", "")
            name = name:gsub("//", "/")
            document.root:add(gui.template("meownatic_unload", {name = name}))
        end
    else

    end
end

function add_meownatic(name)
    if not name then
        document.root:clear()
        for _, f in ipairs(file.list(toml.sys_get('savepath'))) do
            name = f:match("([^/]+)$")
            document.root:add(gui.template("meownatic_unload", {name = name}))
        end
    else
        name = name:match("([^/]+)$")

        meow_schem.save_to_config(name, nil)
        refresh()
    end
end

function del_meownatic(name)
    meow_schem.save_to_config(nil, name)
    refresh()
end

function on_open()
    refresh()
end