local reader = require 'meownatica:tools/read_toml'
local save_u = require 'meownatica:tools/save_utils'
local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local meow_change = { }
local meow_point = 2

local FORMAT = reader.sys_get('fileformat')

function meow_change.convert_schem(meownatic_load)
    local source = meownatic_load:match("(.+)%..+") .. FORMAT
    local source = reader.sys_get('savepath') .. source
    local is_convert, reason = meow_schem.convert(meownatic_load, FORMAT, meownatic_load)
    if is_convert then
        local doc = save_u.read(source)
        container.send_g(save_u.convert_read(doc))
        return container.get_g()
    else
        return 'not converted', reason
    end
end

function meow_change.change(meownatica)
    if meownatica ~= false then
        local index = (meow_point - 1) % reader.len() + 1
        if reader.len() > 0 then
            meow_point = meow_point + 1
            local source = reader.sys_get('savepath') .. reader.schem(index)
            local is_exists = file.exists(source)
            if reader.schem(index):find(FORMAT) and is_exists then
                local doc = save_u.read(source)
                container.send_g(save_u.convert_read(doc))
                return container.get_g(), 0, reader.schem(index)
                -----------------------------------------------------
            elseif is_exists then
                return 'convert', reader.schem(index), reader.schem(index)
            end
            container.send_g({})
            return {}, 0, 0
        else
            container.send_g({})
            return container.get_g(), 0, 0
        end
    else
        local index = 1
        meow_point = 2
        local source = ''
        if reader.len() > 0 then
            source = reader.sys_get('savepath') .. reader.schem(index)
        else
            container.send_g({})
            return {}
        end

        local is_exists = file.exists(source)

        if reader.schem(index):find(FORMAT) and is_exists then
            local doc = save_u.read(source)
            container.send_g(save_u.convert_read(doc))
            return container.get_g(), 0, reader.schem(index)
            -----------------------------------------------------
        elseif is_exists then
            return 'convert', reader.schem(index), reader.schem(index)
        end
        container.send_g({})
        return {}, 0, 0
    end
end

function meow_change.get_schem(meownatic_load, setair, if_convert)
    if file.exists(reader.sys_get('savepath') .. meownatic_load) ~= false then
        if meownatic_load:find(FORMAT) then
            if if_convert ~= false then
                local doc = save_u.read(reader.sys_get('savepath') .. meownatic_load, setair)
                return save_u.convert_read(doc, setair)
            else
                return save_u.read(reader.sys_get('savepath') .. meownatic_load, setair)
            end
        end
    end
end

return meow_change