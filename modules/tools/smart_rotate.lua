local json = require "meownatica:tools/json_reader"
local lang = require 'meownatica:interface/lang'

local rotate_schem = {}

local function is_close(value1, value2)
    return math.abs(value1 - value2)
end

--find_max_value
local function fmv(tbl)
    local maximum = tbl[1]
    for i = 1, #tbl do
        if tbl[i] > maximum then
            maximum = tbl[i]
        end
    end
    return maximum
end

function rotate_schem.rotate(id, state)

    local name = id
    local pos = name:find(':')
    local name_mode = name:sub(1, pos - 1)
    local name_block = name:sub(pos + 1)

    if name_mode ~= 'core' then
        local config = nil
        
        if file.isfile(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json') then
            config = json.decode(file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json'))
        else
            print('[MEOWNATICA] ' .. lang.get('block') .. ' ' .. name .. ' ' .. lang.get('not found'))
            return nil
        end

        local model = nil
        if config['model'] ~= nil then model = string.lower(config['model']) end

        local rotate = nil
        if config['rotation'] ~= nil then rotate = string.lower(config['rotation']) end

        local hitbox = {}
        local sides = {{}, {}, {}, {}, {}, {}}

        if (model == 'aabb' or model == 'custom') and (rotate == 'pipe' or rotate == 'pane') then

            if config['hitbox'] ~= nil then
                hitbox = {config['hitbox']}
            elseif config['model-primitives'] ~= nil then
                for _, aabb in ipairs(config['model-primitives']['aabbs']) do
                    local save = {}
                    for i = 1, 6 do
                        table.insert(save, aabb[i])
                    end
                    table.insert(hitbox, save)
                end
            end

            if hitbox[1] ~= nil then
                for _, aabb in ipairs(hitbox) do
                    local x, y, z, width, height, depth = aabb[1], aabb[2], aabb[3], aabb[4], aabb[5], aabb[6]
                    local minX = x
                    local maxX = x + width
                    local minY = y
                    local maxY = y + height
                    local minZ = z
                    local maxZ = z + depth
                    table.insert(sides[1], is_close(minY, 0.0))
                    table.insert(sides[2], is_close(maxY, 1.0))
                    table.insert(sides[3], is_close(minX, 0.0))
                    table.insert(sides[4], is_close(maxX, 1.0))
                    table.insert(sides[5], is_close(minZ, 0.0))
                    table.insert(sides[6], is_close(maxZ, 1.0))
                end
            end
        end

        if hitbox[1] ~= nil then
            if rotate == 'pane' and ((fmv(sides[5]) < fmv(sides[6]) or fmv(sides[5]) > fmv(sides[6])) or (fmv(sides[3]) < fmv(sides[4]) or fmv(sides[3]) > fmv(sides[4]))) then
                if state == 1 then
                    return 0
                elseif state == 0 then
                    return 3
                elseif state == 3 then
                    return 2
                elseif state == 2 then
                    return 1
                end
            end
        end
    end
end

return rotate_schem