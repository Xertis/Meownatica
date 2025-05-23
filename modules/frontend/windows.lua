local module = {}

function module.open(id)
    hud.show_overlay("meownatica" .. ':' .. id, false)
end

return module