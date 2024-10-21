local windows = require 'meownatica:frontend/windows'

function on_hud_open()
    input.add_callback("meownatica.menu", function ()
        if not hud.is_paused() then
            windows.open("main")
        end
    end)
end