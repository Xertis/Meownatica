function on_hud_open()
    session.reset("meownatica.menu.blueprints.Blueprints")
    session.reset("meownatica.menu.blueprints.olders_paths")
    session.reset("meownatica.menu.blueprints.olders_indexes")

    require "inputs"
end