function place_material(info)
    document.materials:add(gui.template("material", info))
end

local function get_materials(blocks)
    local count = {}
    for _, material in ipairs(blocks) do
        local id = material.id
        count[id] = (count[id] or 0) + 1
    end

    local sorted_count = {}
    for id, count_value in pairs(count) do
        table.insert(sorted_count, { id = id, count = count_value })
    end
    table.sort(sorted_count, function(a, b)
        if a.count == b.count then
            return a.id < b.id
        else
            return a.count > b.count
        end
    end)

    return sorted_count
end

function on_open()
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then
        return
    end

    local materials = get_materials(blueprint.blocks)
    for _, material in ipairs(materials) do
        local block_name = blueprint.indexes.from[material.id].name
        if block_name ~= "core:air" then
            local item_name = block_name .. ".item"
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
                tooltip = block_name

                if stacks > 0 then
                    count = string.format("%s %s %s %s %s",
                        stacks, gui.str("meownatica.menu.stacks", "meownatica"),
                        gui.str("meownatica.menu.and", "meownatica"),
                        units, gui.str("meownatica.menu.units", "meownatica")
                    )
                end
            end

            place_material({
                id = material.id,
                count = count,
                name = caption or block_name,
                icon = icon,
                tooltip = tooltip
            })
        end
    end
end