utils = {
    vec = {},
    math = {}
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