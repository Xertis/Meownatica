local all_pages = {
    "blueprints",
    "materials",
    "export"
}

function on_open()
    change_page("blueprints")
end

function change_page(page)
    document.menu.page = "meow_menu_" .. page

    document["buttom_" .. page].enabled = false

    for _, other_page in ipairs(all_pages) do
        if other_page ~= page then
            document["buttom_" .. other_page].enabled = true
        end
    end
end