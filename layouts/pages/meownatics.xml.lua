local toml = require 'meownatica:tools/read_toml'
local meow_change = require 'meownatica:schematics_editors/change_schem'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'

function refresh()
    local meownatics = toml.get_all_schem()

    document.meownatics:clear()
    for _, name in ipairs(meownatics) do
        local schem = meow_change.get_schem(name, false, false)

        if schem then
            local version = schem[1]
            local description = schem[6] or 'Deprecated version'
            document.meownatics:add(gui.template("meownatic", {version = version, description = description, name = name, icon = "house"}))
        else
            document.meownatics:add(gui.template("meownatic", {version = "undefined", description = "undefined", name = name, icon = "undefined"}))
        end
    end

    if #meownatics <= 0 then
        document.meownatics:clear()
        document.meownatics.size = {200,200}
        document.meownatics.pos = {130,60}
        document.meownatics:add("<image src='menu/not_found' size='200,200'/>")
    end
end

function add_meownatic(name)
    if not name then
        document.meownatics:clear()
        for _, f in ipairs(file.list(toml.sys_get('savepath'))) do
            local name = f:gsub("modules/", "")
            name = name:gsub("%.lua$", "")
            name = name:gsub("//", "/")
            document.meownatics:add(gui.template("meownatic_unload", {name = name}))
        end
    else

    end
end

function add_meownatic(name)

    document.meownatics.size = {453,204}
    document.meownatics.pos = {0,40}

    if not name then
        document.meownatics:clear()
        for _, f in ipairs(file.list(toml.sys_get('savepath'))) do
            name = f:match("([^/]+)$")
            document.meownatics:add(gui.template("meownatic_unload", {name = name}))
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