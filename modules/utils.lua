utils = {
    vec = {},
    math = {},
    table = {},
    blueprint = {}
}

function utils.vec.min(vec1, vec2)
    return {
        math.min(vec1[1], vec2[1]),
        math.min(vec1[2], vec2[2]),
        math.min(vec1[3], vec2[3])
    }
end

function utils.vec.max(vec1, vec2)
    return {
        math.max(vec1[1], vec2[1]),
        math.max(vec1[2], vec2[2]),
        math.max(vec1[3], vec2[3])
    }
end

function utils.math.in_range(num, range)
    if num < range[1] then
        return range[2]
    end

    if num > range[2] then
        return range[1]
    end

    return num
end

function utils.table.deep_equals(tbl1, tbl2)
    if type(tbl1) ~= type(tbl2) then
        return false
    end

    if type(tbl1) ~= "table" then
        return tbl1 == tbl2
    end

    if tbl1 == tbl2 then
        return true
    end

    local count1 = 0
    for _ in pairs(tbl1) do count1 = count1 + 1 end
    local count2 = 0
    for _ in pairs(tbl2) do count2 = count2 + 1 end
    if count1 ~= count2 then
        return false
    end

    for key, value1 in pairs(tbl1) do
        local value2 = tbl2[key]
        if value2 == nil or not utils.table.deep_equals(value1, value2) then
            return false
        end
    end

    return true
end

function utils.table.rep(tbl, unit, count)
    for i=1, count do
        if type(unit) ~= "table" then
            table.insert(tbl, unit)
        else
            table.insert(tbl, table.deep_copy(unit))
        end
    end

    return tbl
end

function utils.blueprint.change(indx)
    if CURRENT_BLUEPRINT.preview_pos[1] ~= nil then
        BLUEPRINTS[CURRENT_BLUEPRINT.id]:unbuild_preview(CURRENT_BLUEPRINT.preview_pos)
    end

    if BLUEPRINTS[indx] then
        CURRENT_BLUEPRINT.id = indx
        CURRENT_BLUEPRINT.preview_pos = {}
    end
end