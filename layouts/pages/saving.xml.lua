local save_u = require 'meownatica:tools/save_utils'
local lang = require 'meownatica:frontend/lang'

local ICONS = {
    "penrose_triangle",
    "house",
    "spaceship",
    "bridge",
    "cat"
}

function saving()
    save_u.save(nil, {description = document.schem_description.text, icon = document.m_icon.src:match("([^/]+)$")}, document.schem_name.text)
end

function refresh()
    local x_plus, y_plus = 0, 0
    for _, icon in ipairs(ICONS) do
        document.root:add(gui.template("icon", {icon = 'mgui/meownatic_icons/' .. icon, name = x_plus, tooltip = lang.get("schem_icon tooltip")}))

        local pos = document["icon_" .. x_plus].pos
        document["icon_" .. x_plus].pos = {pos[1] + 25 + 80 * x_plus, pos[2] - 80 * y_plus + 200}

        x_plus = x_plus + 1

        if x_plus % 5 == 0 then
            y_plus = y_plus + 1
            x_plus = 0
        end
    end
end

function meownatic_update(text)
    local schem_name = document.schem_name.text .. '.mbp'
    document.m_name.text = schem_name
    document.m_description.text = document.schem_description.text
    return true
end

function icon_update(icon)
    document.m_icon.src = icon
end

function on_open()
    refresh()
    local schem_name = document.schem_name.text .. '.mbp'
    document.meownatic:add(gui.template("meownatic", {version = 2, description = document.schem_description.text, name = schem_name, icon = "mgui/meownatic_icons/house", id = 'm'}))
    document.schem_name.tooltip = lang.get("schem_name tooltip")
    document.schem_description.tooltip = lang.get("schem_description tooltip")
    meownatic_update()
end

function del_meownatic() end
function settings() end
