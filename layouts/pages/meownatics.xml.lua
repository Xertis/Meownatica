local toml = require 'meownatica:tools/read_toml'
local meow_change = require 'meownatica:schematics_editors/change_schem'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local mbp = require 'meownatica:files/mbp_manager'
local data_buffer = require "core:data_buffer"
local save_u = require 'meownatica:tools/save_utils'

function refresh()
    local meownatics = toml.get_all_schem()

    document.meownatics:clear()
    for _, name in ipairs(meownatics) do
        local schem, meta = meow_change.get_schem(name, false, false)

        if schem then
            local version = schem[1]

            meta = meta or {}
            local description = meta["description"] or "Deprecated version"
            local icon = meta["icon"] or "house"
            document.meownatics:add(gui.template("meownatic", {version = version, description = description, name = name, icon = "mgui/meownatic_icons/" .. icon, id = name}))
        else
            document.meownatics:add(gui.template("meownatic", {version = "undefined", description = "undefined", name = name, icon = "mgui/meownatic_icons/undefined", id = name}))
        end
    end

    if #meownatics <= 0 then
        document.meownatics:clear()
        document.meownatics.size = {200,200}
        document.meownatics.pos = {130,60}
        document.meownatics:add("<image src='mgui/not_found' size='200,200'/>")
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

function settings(name)
    local path = toml.sys_get('savepath') .. name
    local meownatic = data_buffer(file.read_bytes(path))
    if mbp.check_format(name) then
        local meownatic_version, max_version = mbp.get_version(meownatic)
        if meownatic_version ~= max_version then
            local meownatic = mbp.deserialize(meownatic)
            save_u.write(meownatic, {description = ''}, path)
            refresh()
        end
    end
end

function del_meownatic(name)
    meow_schem.save_to_config(nil, name)
    refresh()
end

function on_open()
    refresh()
end