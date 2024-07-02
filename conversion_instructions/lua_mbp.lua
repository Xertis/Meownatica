local arbd = require 'meownatica:tools/save_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local posm = require 'meownatica:schematics_editors/PosManager'
local lang = require 'meownatica:interface/lang'
local toml = require 'meownatica:tools/read_toml'
local convert_base = {}

function convert_base.convert(path)
    local name_format = path:match(".+/(.+)")
    local name = name_format:gsub("%.lua$", "")
    local convert_meownatic = {}
    dofile(file.resolve(path))
    local meownatic = meownatic_schem
    for i = 1, #meownatic do
        local solid = nil
        local rotation = meownatic[i].state
        local replaceable = nil
        local id = meownatic[i].id
        local x, y, z = meownatic[i].x, meownatic[i].y, meownatic[i].z
        if id ~= 'core:air' then
            local name1 = id
            local pos = name1:find(':')
            local name_mode = name1:sub(1, pos - 1)
            if pack.is_installed(name_mode) then
                local name_block = name1:sub(pos + 1)
                local config = ''
                config = file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json')
                local config = string.lower(config)
                -- Делим конфиг на строки
                local lines = {}
                for line in config:gmatch("[^\n]+") do
                    table.insert(lines, line)
                end
                for yyy, line in ipairs(lines) do
                    --Проверяем на солидность
                    if line:find('aabb') and line:find('model') then
                        solid = false
                    elseif line:find('custom') and line:find('model') then
                        solid = false
                    elseif line:find('block') and line:find('model') then
                        solid = true
                    elseif line:find('x') and line:find('model') then
                        solid = false
                    else
                        if solid == nil then
                            solid = true
                        end
                    end

                    --Проверяем на replaceable
                    if line:find('replaceable') and line:find('true') then
                        replaceable = true
                    else
                        if replaceable == nil then
                            replaceable = false
                        end
                    end
                end
            else
                return false, lang.get("LuaConvError1")
            end
        else
            solid = false
            replaceable = true
        end

        convert_meownatic[#convert_meownatic + 1] = {x = x, y = y, z = z, id = id, state = {rotation = rotation, solid = solid}}
    end

    local max_pos = posm.max_position(convert_meownatic)
    local min_pos = posm.min_position(convert_meownatic)

    local x1, y1, z1, x2, y2, z2 = min_pos[1], min_pos[2], min_pos[3], max_pos[1], max_pos[2], max_pos[3]
    local result = {}
    local i = 1
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if i <= #convert_meownatic then
                    if x == convert_meownatic[i].x and y == convert_meownatic[i].y and z == convert_meownatic[i].z then
                        table.insert(result, convert_meownatic[i])
                        i = i + 1
                    else
                        table.insert(result, {x = x, y = y, z = z, id = 'core:air', state = {rotation = 0, solid = false}})
                    end
                end
            end
        end
    end

    local artd_table = arbd.convert_save(result)
    arbd.write(artd_table, toml.sys_get('savepath') .. name .. '.mbp')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.mbp'})
    return true
end

return convert_base