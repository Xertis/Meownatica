local save_u = require 'meownatica:tools/save_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local posm = require 'meownatica:schematics_editors/PosManager'
local lang = require 'meownatica:interface/lang'
local toml = require 'meownatica:tools/read_toml'
local json = require 'meownatica:tools/json_reader'
local convert_base = {}

function convert_base.convert(path)
    local name_format = path:match(".+/(.+)")
    local name = name_format:gsub("%.lua$", "")
    local convert_meownatic = {}
    dofile(file.resolve(path))
    for _, block in ipairs(meownatic_schem) do
        local solid = nil
        local rotation = block.state
        local id = block.id
        local x, y, z = block.x, block.y, block.z
        if id ~= 'core:air' then
            local name1 = id
            local pos = name1:find(':')
            local name_mode = name1:sub(1, pos - 1)
            if pack.is_installed(name_mode) then
                local name_block = name1:sub(pos + 1)
                local config = ''
                config = json.decode(file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json'))
                solid = config['model'] == 'block'
            else
                return false, lang.get("LuaConvError1")
            end
        else
            solid = false
        end

        convert_meownatic[#convert_meownatic + 1] = {elem = 0, x = x, y = y, z = z, id = id, state = {rotation = rotation, solid = solid}}
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
                        table.insert(result, {elem = 0, x = x, y = y, z = z, id = 'core:air', state = {rotation = 0, solid = true}})
                    end
                end
            end
        end
    end

    local save_table = save_u.convert_save(result)
    save_u.write(save_table, {description = "Converted"}, toml.sys_get('savepath') .. name .. '.mbp')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.mbp'})
    return true
end

return convert_base