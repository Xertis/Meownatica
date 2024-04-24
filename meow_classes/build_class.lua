local meow_build = { }
local json = require 'meownatica:json_reader'
local table_utils = require 'meownatica:table_utils'
local lang = load_script('meownatica:meow_data/lang.lua')

function meow_build:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function meow_build:build_reed(x, y, z, read_meowmatic)
    local point = 0
    --local if_placed = false
    while point <= #read_meowmatic do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index] 
        if structure.id ~= 'core:air' then
            if block.get(structure.x + x, structure.y + y, structure.z + z) == 0 then
                --if_placed = true
                block.set(structure.x + x, structure.y + y, structure.z + z, block.index("meownatica:meowreed"), 0, true)
            end
        end
        point = point + 1
    end
    --return if_placed
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

function meow_build:build_schem(x, y, z, read_meowmatic, set_air, blocks_update, set_block_on_tick, available_ids, lose_blocks)

    local function build_block(x, y, z, id, rotation, update, block_in_cord)
        if block.name(block_in_cord) ~= 'meownatica:meowoad' then  
            if table_utils:find(available_ids, id, '') then   
                block.set(x, y, z, block.index(id), rotation, update)
            else
                print('[MEOWNATICA] ' .. id .. ' ' .. lang:get('not found'))
                lose_blocks = table_utils:insert_unique(lose_blocks, id:match("(.*):"))
                block.set(x, y, z, 0, rotation, update)
            end
        end
    end
    --build_block(structure.x + x, structure.y + y, structure.z + z, structure.id, structure.state.rotation, blocks_update, block_in_cord)

    local point = 0
    local bs = 0

    if blocks_update then
        blocks_update = false
    else
        blocks_update = true
    end

    while point <= #read_meowmatic and bs < set_block_on_tick do
        local index = (point - 1) % #read_meowmatic + 1 
        local schem = read_meowmatic[index]
        local block_in_cord = block.get(schem.x + x, schem.y + y, schem.z + z)
        if block_in_cord ~= -1 and block.name(block_in_cord) ~= schem.id then
            if schem.id ~= 'core:air' then
                build_block(schem.x + x, schem.y + y, schem.z + z, schem.id, schem.state.rotation, blocks_update, block_in_cord)
                bs = bs + 1
            elseif schem.id == 'core:air' and set_air == true then
                build_block(schem.x + x, schem.y + y, schem.z + z, 'core:air', schem.state.rotation, blocks_update, block_in_cord)
                bs = bs + 1
            end
        end

        table.remove(read_meowmatic, point)
        point = point + 1
    end

    -- Завершение
    if #read_meowmatic > 0 then
        return read_meowmatic, lose_blocks
    else
        return 'over', lose_blocks
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