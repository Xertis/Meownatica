utils = {
    vec = {},
    math = {},
    table = {},
    blueprint = {},
    mat4 = {},
    files = {}
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

function utils.vec.floor(vec)
    return {
        math.floor(vec[1]),
        math.floor(vec[2]),
        math.floor(vec[3])
    }
end

function utils.vec.facing(angles_deg)
    local m = utils.mat4.vec_to_mat(angles_deg)

    local dir = {0, 0, 1}

    dir = mat4.mul(m, dir)

    dir = {dir[1], dir[2], dir[3]}
    local abs_dir = vec3.abs(dir)

    if abs_dir[1] >= abs_dir[2] and abs_dir[1] >= abs_dir[3] then
        return (dir[1] > 0) and 0 or 1
    elseif abs_dir[2] >= abs_dir[1] and abs_dir[2] >= abs_dir[3] then
        return (dir[2] > 0) and 2 or 3
    else
        return (dir[3] > 0) and 4 or 5
    end
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

function utils.math.norm255(num)
    return num / 255
end

function utils.math.euclidian3D(pos1, pos2)
    local x1, y1, z1 = unpack(pos1)
    local x2, y2, z2 = unpack(pos2)
    return ((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2) ^ 0.5
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

local function mat4_mul(matrices)
    local result = mat4.idt()

    for _, matrix in ipairs(matrices) do
        result = mat4.mul(result, matrix)
    end

    return result
end

function utils.mat4.vec_to_mat(vector)
    local matrices = {}
    for pos, axis in ipairs(vector) do
        local vec = {0, 0, 0}

        if axis ~= 0 then
            vec[pos] = 1
            table.insert(matrices, mat4.rotate(vec, axis))
        end
    end

    return mat4_mul(matrices)
end

function utils.files.hash(path)
    local bytes = file.read_bytes(path)
    local sum = 0
    for _, byte in ipairs(bytes) do
        sum = sum + (byte^0.8)
    end

    sum = math.round(sum)

    return sum % (2^16-1)
end