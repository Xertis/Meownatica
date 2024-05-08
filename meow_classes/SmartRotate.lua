local json = require "meownatica:tools/json_reader"
local lang = load_script('meownatica:meow_data/lang.lua')

local rotate_schem = {}

local function is_close(value1, value2)
    return math.abs(value1 - value2)
end

--find_tiny_value
local function ftv(tbl)
    maximum = tbl[1]
    for i = 1, #tbl do
        if tbl[i] > maximum then
            maximum = tbl[i]
        end
    end
    return maximum
end

local function checkElements(big_table, elements_to_search)
    local all_elem = #big_table
    local elem_count = 0
    if #elements_to_search == all_elem then
        for _, element in ipairs(elements_to_search, big_table) do
            for i, item in ipairs(big_table) do
                if element == item then
                    elem_count = elem_count + 1
                end
            end
        end
    end
    if elem_count == all_elem then
        return true
    else
        return false
    end
end

function rotate_schem.rotate(x, y, z, id, state)
    --Получаем всю инфу о блоке
    if id ~= 'core:air' then
        print(id)
        local name = id
        local pos = name:find(':')
        local name_mode = name:sub(1, pos - 1)
        local name_block = name:sub(pos + 1)
        local config = ''
        if file.isfile(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json') then
            config = json.decode(file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json'))
        else
            print('[MEOWNATICA] ' .. lang.get('block') .. ' ' .. name .. ' ' .. lang.get('not found'))
            return nil
        end
        
        local model = ''
        if config['model'] ~= nil then model = string.lower(config['model']) end

        local rotate = ''
        if config['rotation'] ~= nil then rotate = string.lower(config['rotation']) end
        
        local hitbox = {}
        local sides = {{}, {}, {}, {}, {}, {}}
        if (model == 'aabb' or model == 'custom') and (rotate == 'pipe' or rotate == 'pane') then
            --Получаем хитбокс
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
        --print("[MEOWNATICA] Расстояние до сторон внешнего куба: " .. table.concat(sides, ", "))


        if hitbox[1] ~= nil then
            if rotate == 'pane' and ((ftv(sides[5]) < ftv(sides[6]) or ftv(sides[5]) > ftv(sides[6])) or (ftv(sides[3]) < ftv(sides[4]) or ftv(sides[3]) > ftv(sides[4]))) then
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