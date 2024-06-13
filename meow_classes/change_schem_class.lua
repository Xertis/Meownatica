local reader = require 'meownatica:tools/read_toml'
local arbd = require 'meownatica:tools/save_utils'
local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local meow_change = { }
local point2 = 2

local FORMAT = reader.sys_get('fileformat')

local function arbd_convert(tbl)
    return arbd.convert_read(tbl)
end

function meow_change.convert_schem(meownatic_load)
    local source = meownatic_load:match("(.+)%..+") .. FORMAT
    local source1 = reader.sys_get('savepath') .. source
    local is_convert = meow_schem.convert(meownatic_load, FORMAT, meownatic_load)
    if is_convert then
        local doc = arbd.read(source1)
        container.send_g(arbd_convert(doc))
        return container.get_g()
    else
        return 'not converted'
    end
end

function meow_change.change(meownatica, change)
    if meownatica ~= false then
        local index = (point2 - 1) % reader.len() + 1
        if reader.len() > 0 then
            local source1 = reader.sys_get('savepath') .. reader.schem(index)
            if reader.schem(index):find(FORMAT) then
                local doc = arbd.read(source1)
                point2 = point2 + 1
                container.send_g(arbd_convert(doc))
                return container.get_g(), 0, reader.schem(index)
                -----------------------------------------------------
            else
                point2 = point2 + 1
                return 'convert', reader.schem(index), reader.schem(index)
            end
        else
            container.send_g({})
            return container.get_g(), 0, 0
        end

    elseif meownatica == false and change == false then
        local index = (point2 - 1) % reader.len() + 1
        local source1 = reader.sys_get('savepath')  .. reader.schem(index)
        if reader.schem(index):find(FORMAT) then
            local doc = arbd.read(source1)
            container.send_g(arbd_convert(doc))
            return container.get_g(), 0, reader.schem(index)
            -----------------------------------------------------
        else
            return 'convert', reader.schem(index), reader.schem(index)
        end
    else
        local index = 1
        point2 = 2
        local source1 = ''
        if reader.len() > 0 then
            source1 = reader.sys_get('savepath') .. reader.schem(index)
        else
            container.send_g({})
            return {}
        end
        if reader.schem(index):find(FORMAT) then
            print(source1)
            local doc = arbd.read(source1)
            container.send_g(arbd_convert(doc))
            return container.get_g(), 0, reader.schem(index)
            -----------------------------------------------------
        else
            return 'convert', reader.schem(index), reader.schem(index)
        end
    end
end

function meow_change.get_schem(meownatic_load)
    local www, index = reader.find(meownatic_load)
    if index ~= nil then
        local source1 = reader.sys_get('savepath') .. reader.schem_full(index)
        if reader.schem_full(index):find(FORMAT) then
            local doc = arbd.read(source1)
            return arbd_convert(doc)
            -----------------------------------------------------
        else
            return 'convert', reader.schem_full(index), reader.schem_full(index)
        end
    end
end

return meow_change

    