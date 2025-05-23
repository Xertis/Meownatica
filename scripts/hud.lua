local windows = require 'meownatica:frontend/windows'
local tblu = require 'meownatica:tools/table_utils'

function on_hud_open(pid)
    input.add_callback("meownatica.menu", function ()
        local x, y, z = player.get_selected_block(pid)
        if tblu.get_index({"meownatica:meowoad", "meownatica:meowbuild"}, block.name(block.get(x, y, z))) then
            hud.open_block(x, y, z)
            return
        end

        if not hud.is_paused() then
            windows.open("main")
        end
    end)
end