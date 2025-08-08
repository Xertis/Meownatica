function on_hud_open()
    session.reset_entry("meownatica.menu.blueprints.Blueprints")
    session.reset_entry("meownatica.menu.blueprints.olders_paths")
    session.reset_entry("meownatica.menu.blueprints.olders_indexes")
    session.reset_entry("meownatica.menu.obj")

    require "inputs"
    hud.open_permanent("meownatica:build_hud")
end