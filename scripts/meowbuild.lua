local meow_build = load_script('meownatica:meow_classes/build_class.lua')
local container = require 'meownatica:container_class'
local reader = require 'meownatica:tools/read_toml'
local table_utils = require 'meownatica:tools/table_utils'
local lang = require 'meownatica:interface/lang'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local g_meownatic = {}
local schem_thread = {}

local function delete_air(meownatic, setair)
    if setair == false then
        local j = 0
        local res = {}
        
        for i, b in pairs(meownatic) do
            if b.id ~= 'core:air' then
                j = j + 1
                res[j] = b
            end
        end
        return res
    else
        return meownatic
    end
end

function on_broken(x, y, z)
    local save_meowmatic = container.get()
    for key, value in ipairs(g_meownatic) do
        if value.x == x and value.y == y and value.z == z then
            table.remove(g_meownatic, key)
        end
    end
    if #save_meowmatic > 0 then
        meow_build.unbuild_reed(x, y, z, save_meowmatic)
    end
end

function on_placed(x, y, z)
    local save_meowmatic = container.get()
    if #save_meowmatic > 0 then
        meow_build.build_reed(x, y, z, save_meowmatic)
    end
end

function on_interact(x, y, z, playerid)
    local save_meowmatic = container.get()
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
                g_meownatic[#g_meownatic + 1] = {schem = delete_air(table_utils.copy(save_meowmatic, reader.get('SetAir'))), x = x, y = y, z = z}
            end
        end
    end
end

local say_over_tick = false
function on_blocks_tick(tps)
    if #g_meownatic <= 0 then
        if say_over_tick == false then
            print(lang.get('Local is finish'))
            say_over_tick = true
        end
    else
        say_over_tick = false
        schem_thread = table_utils.copy(g_meownatic[1])
    end
    if #g_meownatic > 0 then
        schem_thread = meow_build.build_schem(schem_thread.x, schem_thread.y, schem_thread.z, schem_thread.schem, reader.get('SetAir'), reader.get('BlocksUpdate'), reader.get('SetBlockOnTick'), '')
        if schem_thread == 'over' then
            table.remove(g_meownatic, 1)
        end
    end
end