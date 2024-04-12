local meow_change = load_script('meownatica:meow_classes/change_schem_class.lua')
local meow_build =  load_script('meownatica:meow_classes/build_class.lua')
local meow_schem = require 'meownatica:schem_class'
local container = require 'meownatica:container_class'
local reader = require 'meownatica:read_toml'
local layer = 0
local meownatic_layer_save = {}
local start_build = false
local g_meownatic_global = {}
local schem_thread = {}
local x_tick = 0
local y_tick = 0
local z_tick = 0
local meownatic_schem = {}

local available_ids = {}

local function table_shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end


local function get_layer(meownatic)
    if meownatic_layer_save ~= meownatic then
        meownatic_layer_save = meownatic
        layer = meow_schem:min_y(meownatic)
        return layer
    else
        local max_layer = meow_schem:max_y(meownatic)
        if layer >= max_layer then
            layer = meow_schem:min_y(meownatic)
        else
            layer = layer + 1
        end
        return layer
    end
end
function on_broken(x, y, z)
    meownatic_schem = container:get_g()
    for key, value in ipairs(g_meownatic_global) do
        if value.x == x and value.y == y and value.z == z then
            table.remove(g_meownatic_global, key)
        end
    end
    if #meownatic_schem > 0 then
        meow_build:unbuild_reed(x, y, z, meownatic_schem)
    end
end

local if_first_scheme_loaded = false
function on_placed(x, y, z)
    if if_first_scheme_loaded == false then
        local packs = block.defs_count()

        for i = 0, packs do
            available_ids[#available_ids + 1] = block.name(i)
        end
        
        local name, conv = '', ''
        meownatic_schem, conv, name = meow_change:change(false, true)
        if_first_scheme_loaded = true
        if meownatic_schem == 'convert' then
            meownatic_schem = meow_change:convert_schem(conv)
        end
    else
        meownatic_schem = container:get_g()
    end
    if #meownatic_schem > 0 then
        meow_build:build_reed(x, y, z, meownatic_schem)
    end
end

function on_interact(x, y, z, playerid)
    meownatic_schem = container:get_g()
    local id_inv, id_slot = player.get_inventory(playerid)
    local id_item, werwerew = inventory.get(id_inv, id_slot)
    if item.name(id_item) == 'meownatica:block_edit' then
        hud.open_block(x, y, z)
    else
        if #meownatic_schem > 0 then
            local if_scheme_in_queue = false
            for key, value in ipairs(g_meownatic_global) do
                if value.x == x and value.y == y and value.z == z then
                    if_scheme_in_queue = true
                    break
                end
            end
            if if_scheme_in_queue == false then
                g_meownatic_global[#g_meownatic_global + 1] = {schem = table_shallow_copy(meownatic_schem), x = x, y = y, z = z}
            end
        end
    end
end

local say_over_tick = false
function on_blocks_tick(tps)
    if #g_meownatic_global <= 0 then
        start_build = false
        if say_over_tick == false then
            print('[MEOWNATICA:Global schem] The construction queue is finished')
            say_over_tick = true
        end
    else
        say_over_tick = false
        schem_thread = table_shallow_copy(g_meownatic_global[1])
    end
    if #g_meownatic_global > 0 then
        schem_thread = meow_build:build_schem(schem_thread.x, schem_thread.y, schem_thread.z, schem_thread.schem, reader:get('SetAir'), reader:get('BlocksUpdate'), reader:get('SetBlockOnTick'), available_ids)
        if schem_thread == 'over' then
            table.remove(g_meownatic_global, 1)
        end
    end
end