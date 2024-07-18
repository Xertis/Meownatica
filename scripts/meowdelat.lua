local save_meowmatic = {}
local executer_delat = false
local x1_delat, y1_delat, z1_delat = 0, 0, 0

local data_meow = require 'meownatica:files/metadata_class'
local reader = require 'meownatica:tools/read_toml'
local container = require 'meownatica:container_class'
local posm = require 'meownatica:schematics_editors/PosManager'
local quat = require 'meownatica:logic/quaternion_zip'

local function createCube(x1, y1, z1, x2, y2, z2, x_p, y_p, z_p)
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if block.get(x, y, z) ~= -1 then
                    if (block.name(block.get(x, y, z)) ~= 'meownatica:meowdelat' and
                    block.name(block.get(x, y, z)) ~= 'meownatica:meowdelenie')
                    and block.is_segment(x, y, z) == false then
                        save_meowmatic[#save_meowmatic + 1] = {elem = 0, x = x - x_p, y = y - y_p, z = z - z_p, id = block.name(block.get(x, y, z)), state = {rotation = block.get_states(x, y, z), solid = block.is_solid_at(x, y, z)}}
                    else
                        save_meowmatic[#save_meowmatic + 1] = {elem = 0, x = x - x_p, y = y - y_p, z = z - z_p, id = 'core:air', state = {rotation = 0, solid = false}}
                    end
                else
                    return {}
                end
            end
        end
    end
end

local function create_ribs(x1, y1, z1, x2, y2, z2)
    local set_meowdelenie = reader.get('SetMeowdelenie')
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if (x == x1 or x == x2 or y == y1 or y == y2 or z == z1 or z == z2) and (set_meowdelenie == true and block.get(x, y, z) == 0) then
                    if x == x1 and y == math.min(y1, y2) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif x == x2 and y == math.min(y1, y2) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif x == x1 and y == math.max(y1, y2) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif x == x2 and y == math.max(y1, y2) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif z == z2 and (y == math.max(y1, y2) or  y == math.min(y1, y2)) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif z == z1 and (y == math.max(y1, y2) or  y == math.min(y1, y2)) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif z == z1 and (x == math.max(x1, x2) or x == math.min(x1, x2)) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    elseif z == z2 and (x == math.max(x1, x2) or x == math.min(x1, x2)) then
                        block.set(x, y, z, block.index('meownatica:meowdelenie'), 0)
                    end
                end
            end
        end
    end
end

local function deleteCube(x1, y1, z1, x2, y2, z2)
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if block.get(x, y, z) == block.index('meownatica:meowdelenie') then
                    block.set(x, y, z, 0, 0)
                elseif block.get(x, y, z) == block.index('meownatica:meowdelat') and x == x2 and y == y2 and z == z2 then
                    data_meow.remove(x, y, z)
                    block.set(x, y, z, 0, 0)
                end
            end
        end
    end
end

function on_broken(x, y, z)
    executer_delat = false
    local data = data_meow.read(x, y, z)
    if data ~= nil then
        deleteCube(data[1], data[2], data[3], data[4], data[5], data[6])
    end
    data_meow.remove(x, y, z)
end

local function copy_entities(x1, y1, z1, x2, y2, z2)

    if reader.get('EntitiesSave') == true then
        local function combine(table1, table2)
            local result = {}
            for i = 1, #table1 do
                result[i] = math.abs(table1[i] - table2[i] + 1)
            end
            return result
        end

        local max_pos, min_pos = posm.min_max_in_cube(x1, y1, z1, x2, y2, z2)
        local size = combine(max_pos, min_pos)

        local uids = entities.get_all_in_box(min_pos, size)

        for _, uid in ipairs(uids) do
            local entity = entities.get(uid)
            local tsf = entity.transform
            local pos = tsf:get_pos()
            local rot = tsf:get_rot()

            local id = entities.def_name(entities.get_def(uid))
            if id ~= "base:drop" then
                table.insert(save_meowmatic, {elem = 1, x = pos[1] - x1, y = pos[2] - y1, z = pos[3] - z1, id = id, rot = rot})
            end
        end
    end
end

function on_placed(x, y, z)
    if executer_delat == false then
        x1_delat, y1_delat, z1_delat = x, y, z
        executer_delat = true
    elseif executer_delat == true then
        executer_delat = false
        x2_delat, y2_delat, z2_delat = x, y, z
        if block.get(x1_delat, y1_delat, z1_delat) == block.index('meownatica:meowdelat') and block.get(x2_delat, y2_delat, z2_delat) == block.index('meownatica:meowdelat') then
            save_meowmatic = {}
            if y1_delat > y2_delat then
                createCube(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat, x, y, z)
                create_ribs(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat)
                copy_entities(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat)
            else
                createCube(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat, x1_delat, y1_delat, z1_delat)
                create_ribs(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat)
                copy_entities(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat)
            end
            
            local data1 = {x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat}
            local data2 = {x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat}
            data_meow.add(x, y, z, data2)
            data_meow.add(x1_delat, y1_delat, z1_delat, data1)
        end
        container.send(save_meowmatic)
    end
end

function on_interact(x, y, z)
    local data = data_meow.read(x, y, z)
    if data ~= nil then
        local x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat = data[1], data[2], data[3], data[4], data[5], data[6]
        save_meowmatic = {}
        if y1_delat > y2_delat then
            createCube(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat, x, y, z)
            create_ribs(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat)
            copy_entities(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat)
        else
            createCube(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat, x1_delat, y1_delat, z1_delat)
            create_ribs(x2_delat, y2_delat, z2_delat, x1_delat, y1_delat, z1_delat)
            copy_entities(x1_delat, y1_delat, z1_delat, x2_delat, y2_delat, z2_delat)
        end
    end
    container.send(save_meowmatic)
end

return save_meowmatic