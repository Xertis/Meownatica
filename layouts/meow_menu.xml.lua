local all_pages = {
    "blueprints",
    "materials",
    "export"
}

function on_open()
    session.entries["meownatica.menu.obj"] = document.menu
    change_page("blueprints")

    document.blueprint_info:setInterval(50, update)
end

function change_page(page)
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint and page ~= "blueprints" then
        gui.alert("Схема не выбрана, для перехода на эту страницу выберите схему")
        return
    end

    document.menu.page = "meow_menu_" .. page

    document["buttom_" .. page].enabled = false

    for _, other_page in ipairs(all_pages) do
        if other_page ~= page then
            document["buttom_" .. other_page].enabled = true
        end
    end
end

function update()
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then return end
    if blueprint.image ~= '' then
        document.blueprint_icon.src = blueprint.image
    elseif blueprint.image_bytes and #blueprint.image_bytes > 0 then
        assets.load_texture(blueprint.image_bytes, "blueprint_icon_" .. blueprint.id)
        document.blueprint_icon.src = "blueprint_icon_" .. blueprint.id
        blueprint.image = "blueprint_icon_" .. blueprint.id
    else
        document.blueprint_icon.src = "mgui/default_blueprint_icon"
    end

    document.blueprint_name.text = string.format("%s: %s", gui.str("meownatica.menu.name", "meownatica"), 'None')
    document.blueprint_author.text = string.format("%s: %s", gui.str("meownatica.menu.author", "meownatica"), 'None')
    document.blueprint_tags.text = string.format("%s: %s", gui.str("meownatica.menu.tags", "meownatica"), 'None')
    document.blueprint_description.text = string.format("%s: %s", gui.str("Description", "menu"), 'None')
    document.blueprint_size.text = string.format("%s: %s", gui.str("meownatica.menu.size", "meownatica"), 'None')
    document.blueprint_blocks_count.text = string.format("%s: %s", gui.str("meownatica.menu.blocks_count", "meownatica"), 'None')
    document.blueprint_entities_count.text = string.format("%s: %s", gui.str("meownatica.menu.entities_count", "meownatica"), 'None')

    local blocks_count = 0
    for _, blk in ipairs(blueprint.blocks) do
        if blueprint.block_indexes.from[blk.id].name ~= "core:air" then
            blocks_count = blocks_count + 1
        end
    end

    document.blueprint_name.text = string.format("%s: %s", gui.str("meownatica.menu.name", "meownatica"), blueprint.name or 'None')
    document.blueprint_author.text = string.format("%s: %s", gui.str("meownatica.menu.author", "meownatica"), blueprint.author or 'None')
    document.blueprint_tags.text = string.format("%s: %s", gui.str("meownatica.menu.tags", "meownatica"), table.concat(blueprint.tags or {}, ', '))
    document.blueprint_description.text = string.format("%s: %s", gui.str("Description", "menu"), blueprint.description or 'None')
    document.blueprint_size.text = string.format("%s: %s", gui.str("meownatica.menu.size", "meownatica"), table.tostring(blueprint.size))
    document.blueprint_blocks_count.text = string.format("%s: %s", gui.str("meownatica.menu.blocks_count", "meownatica"), blocks_count)
    document.blueprint_entities_count.text = string.format("%s: %s", gui.str("meownatica.menu.entities_count", "meownatica"), #blueprint.entities)
end