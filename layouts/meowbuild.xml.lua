local meow_build = load_script('meownatica:meow_classes/build_class.lua')
local meow_schem = require 'meownatica:schem_class'
local container = require 'meownatica:container_class'
local reader = require 'meownatica:read_toml'
local x = 0
local y = 0
local z = 0

function on_open(invid, x1, y1, z1)
    x = x1
    y = y1
    z = z1
end

function rotate()
    local save_meowmatic = container:get()
    if #save_meowmatic > 0 then
        meow_build:unbuild_reed(x, y, z, save_meowmatic)
        save_meowmatic = meow_schem:rotate(save_meowmatic, reader:get('SmartRotateOn'))
        meow_build:build_reed(x, y, z, save_meowmatic)
    end
end

function up_down()
    local save_meowmatic = container:get()
    if #save_meowmatic > 0 then
        meow_build:unbuild_reed(x, y, z, save_meowmatic)
        save_meowmatic = meow_schem:upmeow(save_meowmatic)
        meow_build:build_reed(x, y, z, save_meowmatic)
    end
end

function mirroring()
    local save_meowmatic = container:get()
    if #save_meowmatic > 0 then
        meow_build:unbuild_reed(x, y, z, save_meowmatic)
        save_meowmatic = meow_schem:mirroring(save_meowmatic)
        meow_build:build_reed(x, y, z, save_meowmatic)
    end
end