function close(page)
    print(page)
    hud.close("meownatica:main")
    hud.show_overlay("meownatica:pages/" .. page, false)
end