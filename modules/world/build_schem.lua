local table_utils = require 'meownatica:tools/table_utils'
local toml = require 'meownatica:tools/read_toml'
local meow_build = {}

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

function meow_build.build_schem(x, y, z, read_meowmatic, available_ids, lose_blocks)
    local bs = 0

    local parameters = toml.get_all_parameters()
    local set_air = parameters["setair"]
    local blocks_update = not parameters["blocksupdate"]
    local set_block_on_tick = parameters["setblockontick"]
    local set_entities = parameters["setentities"]
    local on_placed = parameters["onplaced"]
    local on_broken = parameters["onbroken"]

    local function build_block(schem, block_in_cord)
        if block.name(block_in_cord) ~= 'meownatica:meowoad' then
            local id = schem.id
            if on_broken then events.emit(block.name(block_in_cord) .. ".broken", schem.x + x, schem.y + y, schem.z + z) end
            if table_utils.find(available_ids, id, '') then
                block.set(schem.x + x, schem.y + y, schem.z + z, block.index(id), schem.state.rotation, blocks_update)
                if on_placed then events.emit(id .. '.placed', schem.x + x, schem.y + y, schem.z + z) end
            else
                table_utils.insert_unique(lose_blocks, id:match("(.*):"))
                block.set(schem.x + x, schem.y + y, schem.z + z, 0, schem.state.rotation, blocks_update)
            end
        end
    end

    for point = 1, math.min(#read_meowmatic, set_block_on_tick) do
        local schem = read_meowmatic[point]
        if schem.elem == 0 then
            local block_in_cord = block.get(schem.x + x, schem.y + y, schem.z + z)
            if block_in_cord ~= -1 and block.name(block_in_cord) ~= schem.id then
                if schem.id ~= 'core:air' or set_air then
                    build_block(schem, block_in_cord)
                end
            end
        elseif schem.elem == 1 and set_entities then
            if table_utils.find(available_ids, schem.id, '') then
                local entity = entities.spawn(schem.id, {schem.x + x, schem.y + y, schem.z + z})
                entity.transform:set_rot(schem.rot)
            else
                table_utils.insert_unique(lose_blocks, schem.id:match("(.*):"))
            end
        end
        bs = bs + 1
    end

    for _ = 1, bs do
        table.remove(read_meowmatic, 1)
    end

    if #read_meowmatic > 0 then
        return read_meowmatic, lose_blocks
    else
        return 'over', lose_blocks
    end
end

return meow_build