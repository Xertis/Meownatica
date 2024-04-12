local rotate_schem = {}

local function is_close(value1, value2)
    --local inaccuracy = 0.25
    return math.abs(value1 - value2)
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

function rotate_schem:rotate(x, y, z, id, state)
    --Получаем всю инфу о блоке
    if id ~= 'core:air' then
        local name = id
        local pos = name:find(':')
        local name_mode = name:sub(1, pos - 1)
        local name_block = name:sub(pos + 1)
        local config = ''
        if file.isfile(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json') then
            config = file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json')
        else
            print('[MEOWNATICA] Блок: ' .. name .. ' не найден среди ваших модов')
            return nil
        end
        local config = string.lower(config)
        -- Делим конфиг на строки
        local lines = {}
        for line in config:gmatch("[^\n]+") do
            table.insert(lines, line)
        end

        local model = ''
        --Ищем aabb в строке
        for i, line in ipairs(lines) do
            if line:find('aabb') and line:find('model') then
                model = 'aabb'
            elseif line:find('custom') and line:find('model') then
                model = 'custom'
            end
        end

        local rotate = ''
        --Ищем pipe в строке
        for i, line in ipairs(lines) do
            if line:find('pipe') and line:find('rotation') then
                rotate = 'pipe'
            elseif  line:find('pane') and line:find('rotation') then
                rotate = 'pane'
            end
        end

        
        local hitbox = {}
        local sides = {} 
        if (model == 'aabb' or model == 'custom') and (rotate == 'pipe' or rotate == 'pane') then
            --Получаем хитбокс
            for i, line in ipairs(lines) do
                if line:find('hitbox') and line:find(']') then
                    for num in line:gmatch("%d+%.?%d*") do
                        table.insert(hitbox, tonumber(num))
                    end
                end
            end
            if hitbox[1] ~= nil then
                local x, y, z, width, height, depth = hitbox[1], hitbox[2], hitbox[3], hitbox[4], hitbox[5], hitbox[6]
                local minX = x
                local maxX = x + width
                local minY = y
                local maxY = y + height
                local minZ = z
                local maxZ = z + depth
            
                table.insert(sides, is_close(minY, 0.0))
                table.insert(sides, is_close(maxY, 1.0))
                table.insert(sides, is_close(minX, 0.0))
                table.insert(sides, is_close(maxX, 1.0))
                table.insert(sides, is_close(minZ, 0.0))
                table.insert(sides, is_close(maxZ, 1.0))
            end
        end
        --print("[MEOWNATICA] Расстояние до сторон внешнего куба: " .. table.concat(sides, ", "))
        if hitbox[1] ~= nil then
            if rotate == 'pane' and (sides[5] < sides[6] or sides[5] > sides[6]) then
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