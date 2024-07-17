local meow_build = {}
local table_utils = require 'meownatica:tools/table_utils'

function meow_build.build_reed(x, y, z, read_meowmatic)
    if #read_meowmatic > 0 then
        for _, structure in ipairs(read_meowmatic) do
            if structure.elem == 0 then
                if block.get(structure.x + x, structure.y + y, structure.z + z) == 0 and structure.id ~= 'core:air' then
                    block.set(structure.x + x, structure.y + y, structure.z + z, block.index("meownatica:meowreed"), 0, true)
                end
            end
        end
    end
end

function meow_build.unbuild_reed(x, y, z, read_meowmatic)
    if #read_meowmatic > 0 then
        for _, structure in ipairs(read_meowmatic) do
            if structure.id ~= 'core:air' and structure.elem == 0 then
                if block.get(structure.x + x, structure.y + y, structure.z + z) == block.index("meownatica:meowreed") then
                    block.set(structure.x + x, structure.y + y, structure.z + z, 0, 0, true)
                end
            end
        end
    end
end

function meow_build.build_schem(x, y, z, read_meowmatic, set_air, blocks_update, set_block_on_tick, available_ids, lose_blocks)

    blocks_update = blocks_update == false

    local function build_block(x, y, z, id, rotation, update, block_in_cord)
        if block.name(block_in_cord) ~= 'meownatica:meowoad' then
            if table_utils.find(available_ids, id, '') then
                block.set(x, y, z, block.index(id), rotation, update)
            else
                table_utils.insert_unique(lose_blocks, id:match("(.*):"))
                block.set(x, y, z, 0, rotation, update)
            end
        end
    end
    --build_block(structure.x + x, structure.y + y, structure.z + z, structure.id, structure.state.rotation, blocks_update, block_in_cord)

    local point = 0
    local bs = 0

    while point <= #read_meowmatic and bs < set_block_on_tick do
        local index = (point - 1) % #read_meowmatic + 1
        local schem = read_meowmatic[index]
        if schem.elem == 0 then
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
        elseif schem.elem == 1 then
            print(11)
            if table_utils.find(available_ids, schem.id, '') then
                local entity = entities.spawn(schem.id, {schem.x + x, schem.y + y, schem.z + z})
                entity.transform:set_rot(schem.rot)
            else
                table_utils.insert_unique(lose_blocks, schem.id:match("(.*):"))
            end
            bs = bs + 1
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

return meow_build