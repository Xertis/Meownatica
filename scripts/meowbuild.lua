local meow_build = load_script('meownatica:meow_classes/build_class.lua')
local meow_schem = require 'meownatica:schem_class'
local container = require 'meownatica:container_class'
local reader = require 'meownatica:read_toml'
local table_utils = require 'meownatica:table_utils'
local lang = load_script('meownatica:meow_data/lang.lua')
local layer1 = 0
local meownatic_layer_save1 = {}
local start_build = false
local g_meownatic = {}
local schem_thread = {}
local x_tick = 0
local y_tick = 0
local z_tick = 0
local array = {}
local num_file = 0

local function get_layer1(meownatic)
    if meownatic_layer_save1 ~= meownatic then
        meownatic_layer_save1 = meownatic
        layer1 = meow_schem:min_y(meownatic)
        return layer1
    else
        local max_layer = meow_schem:max_y(meownatic)
        if layer1 >= max_layer then
            layer1 = meow_schem:min_y(meownatic)
        else
            layer1 = layer1 + 1
        end
        return layer1
    end
end
function on_broken(x, y, z)
    local save_meowmatic = container:get()
    for key, value in ipairs(g_meownatic) do
        if value.x == x and value.y == y and value.z == z then
            table.remove(g_meownatic, key)
        end
    end
    if #save_meowmatic > 0 then
        meow_build:unbuild_reed(x, y, z, save_meowmatic)
    end
end

function on_placed(x, y, z)
    local save_meowmatic = container:get()
    if #save_meowmatic > 0 then
        meow_build:build_reed(x, y, z, save_meowmatic)
        layer1 = meow_schem:min_y(save_meowmatic) - 1
    end
end

function on_interact(x, y, z, playerid)
    local save_meowmatic = container:get()
    local id_inv, id_slot = player.get_inventory(playerid)
    local id_item, werwerew = inventory.get(id_inv, id_slot)
    if item.name(id_item) == 'meownatica:block_edit' then
        hud.open_block(x, y, z)
    else
        if #save_meowmatic > 0 then
            local if_scheme_in_queue = false
            for key, value in ipairs(g_meownatic) do
                if value.x == x and value.y == y and value.z == z then
                    if_scheme_in_queue = true
                    break
                end
            end
            if if_scheme_in_queue == false then
                g_meownatic[#g_meownatic + 1] = {schem = table_utils:copy(save_meowmatic), x = x, y = y, z = z}
            end
        end
    end
end
local i_queue = 1
local stopped = false
local say_over_tick = false
function on_blocks_tick(tps)
    local queue_to_save = container:get_to_save()
    if #g_meownatic <= 0 then
        start_build = false
        if say_over_tick == false then
            print(lang:get('Local is finish'))
            say_over_tick = true
        end
    else
        say_over_tick = false
        schem_thread = table_utils:copy(g_meownatic[1])
    end
    if #g_meownatic > 0 then
        schem_thread = meow_build:build_schem(schem_thread.x, schem_thread.y, schem_thread.z, schem_thread.schem, reader:get('SetAir'), reader:get('BlocksUpdate'), reader:get('SetBlockOnTick'), '')
        if schem_thread == 'over' then
            table.remove(g_meownatic, 1)
        end
    end
end