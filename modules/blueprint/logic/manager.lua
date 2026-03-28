local BluePrint = require "blueprint/blueprint"
local drawing = require "blueprint/logic/drawing"
local selection = require "common/selection"

local norm255 = utils.math.norm255
local module = {}

local function set_blueprint(pos1, pos2, origin)
    local blocks, ents = drawing.select_blocks(pos1, pos2)
    if #blocks == 0 then return end

    local bp = BluePrint.new(blocks, ents, origin)
    bp:__init_packs()
    table.insert(BLUEPRINTS, bp)
    utils.blueprint.change(#BLUEPRINTS)
end

function module.draw(x, y, z)
    local id = CURRENT_BORDER_ID
    CURRENT_BORDER_ID = utils.math.in_range(CURRENT_BORDER_ID + 1, { 1, 2 })

    if id ~= 2 then
        local sel_id = selection.sel(x, y, z, x, y, z, { norm255(255), norm255(58), norm255(50), norm255(255) })

        selection.desel(BORDERS[1][4])
        selection.desel(BORDERS[2][4])
        selection.desel(BORDERS[2][5])

        BORDERS[id] = { x, y, z, sel_id }
        return
    end

    local sel_id = selection.sel(x, y, z, x, y, z, { norm255(63), norm255(52), norm255(160), norm255(255) })

    local prev_x, prev_y, prev_z = unpack(BORDERS[1])
    local external_sel_id = selection.sel(x, y, z, prev_x, prev_y, prev_z,
        { norm255(255), norm255(183), norm255(0), norm255(255) })
    BORDERS[id] = { x, y, z, sel_id, external_sel_id }

    local origin = { x, y, z }
    if y > BORDERS[1][2] then origin = { BORDERS[1][1], BORDERS[1][2], BORDERS[1][3] } end

    set_blueprint(BORDERS[1], BORDERS[2], origin)
end

return module
