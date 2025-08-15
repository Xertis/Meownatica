local MATERIALS = {}
local blocked = nil

local function place_material(info)
    document.materials:add(gui.template("material", info))
end

local function get_materials(blocks, entities)
    local block_counts = {}
    local entity_counts = {}

    for _, material in ipairs(blocks) do
        local id = material.id
        block_counts[id] = (block_counts[id] or 0) + 1
    end

    for _, entity in ipairs(entities) do
        local id = entity.id
        entity_counts[id] = (entity_counts[id] or 0) + 1
    end

    local combined = {}

    for id, count in pairs(block_counts) do
        table.insert(combined, {
            id = id,
            count = count,
            type = "block"
        })
    end

    for id, count in pairs(entity_counts) do
        table.insert(combined, {
            id = id,
            count = count,
            type = "entity"
        })
    end

    table.sort(combined, function(a, b)
        if a.count == b.count then
            if a.type == b.type then
                return a.id < b.id
            else
                return a.type == "block"
            end
        else
            return a.count > b.count
        end
    end)

    return combined
end

local function open()
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then
        return
    end

    local materials = get_materials(blueprint.blocks, blueprint.entities)
    for id, material in ipairs(materials) do
        local unit_name = nil
        if material.type == "block" then
            unit_name = blueprint.block_indexes.from[material.id].name
        else
            unit_name = blueprint.entity_indexes.from[material.id].name
        end

        local item_name = unit_name .. ".item"
        local icon = nil
        local caption = nil
        local count = string.format("%s: %s %s",
            gui.str("meownatica.menu.count", "meownatica"), material.count,
            gui.str("meownatica.menu.units", "meownatica")
        )
        local tooltip = "Not found"
        if COMMON_GLOBALS.ITEMS_AVAILABLE[item_name] then
            local indx = item.index(item_name)
            local stack_size = item.stack_size(indx)
            local stacks = math.floor(material.count / stack_size)
            local units = material.count - (stacks * stack_size)
            icon = item.icon(indx)
            caption = item.caption(indx)
            tooltip = unit_name

            if stacks > 0 then
                count = string.format("%s %s %s %s %s",
                    stacks, gui.str("meownatica.menu.stacks", "meownatica"),
                    gui.str("meownatica.menu.and", "meownatica"),
                    units, gui.str("meownatica.menu.units", "meownatica")
                )
            end
        end

        if unit_name == "core:air" then
            icon = "mgui/o2"
            tooltip = "core:air"
            caption = "air"
        end

        MATERIALS[id] = {
            name = unit_name,
            type = material.type,
            id = material.id
        }

        place_material({
            id = id,
            count = count,
            name = caption or unit_name,
            icon = icon,
            tooltip = tooltip,
            validator =  material.type == "block" and "block_exists" or "entity_exists"
        })
    end
end

function on_open()
    open()
end

function block_exists(text)
    return COMMON_GLOBALS.BLOCKS_AVAILABLE[text] ~= nil
end

function entity_exists(text)
    return COMMON_GLOBALS.ENTITIES_AVAILABLE[text] ~= nil
end

function material_edit(text)
    local id = blocked
    local name = MATERIALS[id].name
    blocked = nil

    document["materialitem_" .. id].visible = false

    document["materialicon_" .. id].visible = true
    document["materialcount_" .. id].visible = true
    document["materialname_" .. id].visible = true

    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then
        return
    end

    if MATERIALS[id].type == "block" then
        if not block_exists(text) then
            return
        end

        local old_id = MATERIALS[id].id
        blueprint.block_indexes.from[old_id].name = text
        blueprint.block_indexes.to[name] = nil
        blueprint.block_indexes.to[text] = {
            name = text,
            id = id
        }
    else
        if not entity_exists(text) then
            return
        end

        local old_id = MATERIALS[id].id
        blueprint.entity_indexes.from[old_id].name = text
        blueprint.entity_indexes.to[name] = nil
        blueprint.entity_indexes.to[text] = {
            name = text,
            id = id
        }
    end

    document.materials:clear()
    MATERIALS = {}
    open()
end

function change_material(id)
    if blocked then
        gui.alert("Закончите редактирование прошлого материала прежде, чем начать редактировать новый")
        return
    end

    blocked = id
    document["materialitem_" .. id].visible = true
    document["materialitem_" .. id].text = MATERIALS[id].name

    document["materialicon_" .. id].visible = false
    document["materialcount_" .. id].visible = false
    document["materialname_" .. id].visible = false
end