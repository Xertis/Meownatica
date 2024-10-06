local save_u = require 'meownatica:tools/save_utils'

local ICONS = {
    "penrose_triangle",
    "house",
    "house",
    "house",
    "bridge"
}

function saving()
    save_u.save(nil, {description = document.schem_description.text, icon = document.m_icon.src}, document.schem_name.text)
end

function refresh()
    local x_plus = 0
    local y_plus = 0
    for _, icon in ipairs(ICONS) do
        document.root:add(gui.template("icon", {icon = icon, name = x_plus}))

        local pos = document["icon_" .. x_plus].pos

        document["icon_" .. x_plus].pos = {pos[1] + 25 + 80*(x_plus),pos[2] - 80*(y_plus) + 200}

        x_plus = x_plus + 1

        if x_plus % 5 == 0 then
            y_plus = y_plus + 1
            x_plus = 0
        end

    end
end

function meownatic_update()
    local schem_name, schem_description = document.schem_name.text .. '.mbp', document.schem_description.text
    document.m_name.text = schem_name
    document.m_description.text = schem_description
end

function icon_update(icon)
    document.m_icon.src = "menu/icons/" .. icon
end

function on_open()
    refresh()
    local schem_name, schem_description = document.schem_name.text .. '.mbp', document.schem_description.text
    document.meownatic:add(gui.template("meownatic", {version = 2, description = schem_description, name = schem_name, icon = "menu/icons/house", id = 'm'}))
    meownatic_update()
end

function del_meownatic() end