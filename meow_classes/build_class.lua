local meow_build = { }
local json = require 'meownatica:json_reader'
local table_utils = require 'meownatica:table_utils'

function meow_build:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function meow_build:build_reed(x, y, z, read_meowmatic)
    local point = 0
    while point <= #read_meowmatic do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index] 
        if structure.id ~= 'core:air' then
            if block.get(structure.x + x, structure.y + y, structure.z + z) == 0 then
                block.set(structure.x + x, structure.y + y, structure.z + z, block.index("meownatica:meowreed"), 0, true)
            end
        end
        point = point + 1
    end
end

function meow_build:unbuild_reed(x, y, z, read_meowmatic)
    local point = 0
    while point <= #read_meowmatic do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index]
        if structure.id ~= 'core:air' then
            if block.get(structure.x + x, structure.y + y, structure.z + z) == block.index("meownatica:meowreed") then
                block.set(structure.x + x, structure.y + y, structure.z + z, 0, 0, true)
            end
        end
        point = point + 1
    end
end

function meow_build:build_schem(x, y, z, read_meowmatic, set_air, blocks_update, set_block_on_tick)
    local available_ids = ''
    if file.isfile('world:indices.json') then
        available_ids = json.decode(file.read('world:indices.json'))['blocks']
    end

    local function build_block(x, y, z, id, rotation, update, block_in_cord)
        if table_utils:find(available_ids, id, '') then
            if block.name(block_in_cord) ~= 'meownatica:meowoad' then    
                block.set(x, y, z, block.index(id), rotation, update)
            end
        else
            print('[MEOWNATICA] ' .. id .. ' does not exist')
            if block.name(block_in_cord) ~= 'meownatica:meowoad' then   
                block.set(x, y, z, 0, rotation, update)
            end
        end
    end

    local point = 0
    local block_pack = set_block_on_tick
    if blocks_update then
        blocks_update = false
    else
        blocks_update = true
    end
    while point <= #read_meowmatic and point <= block_pack do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index]
        local Block_in_cord = block.get(structure.x + x, structure.y + y, structure.z + z)
        if Block_in_cord ~= -1 and block.name(Block_in_cord) ~= structure.id then
            if structure.id == "core:air" and set_air == true then
                build_block(structure.x + x, structure.y + y, structure.z + z, structure.id, structure.state.rotation, blocks_update, block_in_cord)
            elseif structure.id ~= "core:air" then
                build_block(structure.x + x, structure.y + y, structure.z + z, structure.id, structure.state.rotation, blocks_update, block_in_cord)
            else
                block_pack = block_pack + 1
            end
        end
        if Block_in_cord ~= -1 then
            table.remove(read_meowmatic, point)
            block_pack = set_block_on_tick
        else
            block_pack = block_pack + 1
        end
        point = point + 1
    end
    if #read_meowmatic > 0 then
        return read_meowmatic
    else
        return 'over'
    end
end

function meow_build:build_layer(x, y, z, read_meowmatic, set_air, blocks_update, layer)
    local point = 0
    if blocks_update then
        blocks_update = false
    else
        blocks_update = true
    end
    while point <= #read_meowmatic do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index]
        if block.get(structure.x + x, structure.y + y, structure.z + z) ~= block.index("meownatica:meowoad") then
            if structure.id == "core:air" and set_air == true then
                if layer == structure.y then
                    block.set(structure.x + x, structure.y + y, structure.z + z, block.index(structure.id), structure.state.rotation, blocks_update)
                end
            else 
                if structure.id ~= "core:air" then
                    if layer == structure.y then
                        block.set(structure.x + x, structure.y + y, structure.z + z, block.index(structure.id), structure.state.rotation, blocks_update)
                    end
                end
            end
        end
        point = point + 1
    end
end

return meow_build