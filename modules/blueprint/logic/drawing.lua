local BluePrint = require "blueprint/blueprint"
local selection = require "common/selection"
local module = {}

local norm255 =  utils.math.norm255

local function __select_blocks(pos1, pos2)
    local blocks = {}
    local _entities = {}
    local x1, y1, z1 = unpack(pos1)
    local x2, y2, z2 = unpack(pos2)
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                local block_id = block.get(x, y, z)
                if block_id ~= -1 then
                    if not string.starts_with(block.name(block_id), "meownatica") and not block.is_segment(x, y, z) then
                        table.insert(blocks, {
                            id = block_id,
                            pos = {x, y, z},
                            states = block.get_states(x, y, z)
                        })
                    else
                        table.insert(blocks, {
                            id = 0,
                            pos = {x, y, z},
                            states = 0
                        })
                    end
                else
                    return {}
                end
            end
        end
    end

    local pos = utils.vec.min(pos1, pos2)
    local size = vec3.add(vec3.sub(utils.vec.max(pos1, pos2), pos), 1)
    local uids = entities.get_all_in_box(pos, size)

    for _, uid in ipairs(uids) do
        local entity = entities.get(uid)
        table.insert(_entities, {
            id = entities.get_def(uid),
            pos = entity.transform:get_pos(),
            rotation = entity.transform:get_rot()
        })
    end

    return blocks, _entities
end

local function set_blueprint(pos1, pos2, origin)
    local blocks, entities = __select_blocks(pos1, pos2)
    if #blocks == 0 then return end

    local blue_print = BluePrint.new(blocks, entities, origin)
    blue_print:__init_packs()
    table.insert(BLUEPRINTS, blue_print)
    utils.blueprint.change(#BLUEPRINTS)
end

function module.draw(x, y, z)
    local id = CURRENT_BORDER_ID
    CURRENT_BORDER_ID = utils.math.in_range(CURRENT_BORDER_ID+1, {1, 2})

    if id ~= 2 then
        local sel_id = selection.sel(x, y, z, x, y, z, {norm255(255), norm255(58), norm255(50), norm255(255)})

        selection.desel(BORDERS[1][4])
        selection.desel(BORDERS[2][4])
        selection.desel(BORDERS[2][5])

        BORDERS[id] = {x, y, z, sel_id}
        return
    end

    local sel_id = selection.sel(x, y, z, x, y, z, {norm255(63), norm255(52), norm255(160), norm255(255)})

    local prev_x, prev_y, prev_z = unpack(BORDERS[1])
    local external_sel_id = selection.sel(x, y, z, prev_x, prev_y, prev_z, {norm255(255), norm255(183), norm255(0), norm255(255)})
    BORDERS[id] = {x, y, z, sel_id, external_sel_id}

    local origin = {x, y, z}
    if y > BORDERS[1][2] then origin = {BORDERS[1][1], BORDERS[1][2], BORDERS[1][3]} end

    set_blueprint(BORDERS[1], BORDERS[2], origin)
end

return module