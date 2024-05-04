local meow_schem = {}

function meow_schem:min_y(meownatic)
    local minimal = meownatic[1].y
    --Минимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y < minimal then
            minimal = meownatic[i].y
        end
    end
    return minimal
end

function meow_schem:max_y(meownatic)
    local maximum = meownatic[1].y
    --Максимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y > maximum then
            maximum = meownatic[i].y
        end
    end
    return maximum
end

function meow_schem:max_x(meownatic)
    local maximum = meownatic[1].x
    --Максимальный X
    for i = 1, #meownatic do
        if meownatic[i].x > maximum then
            maximum = meownatic[i].x
        end
    end
    return maximum
end

function meow_schem:min_x(meownatic)
    local minimal = meownatic[1].x
    --Минимальный X
    for i = 1, #meownatic do
        if meownatic[i].x < minimal then
            minimal = meownatic[i].x
        end
    end
    return minimal
end

function meow_schem:max_z(meownatic)
    local maximum = meownatic[1].z
    --Максимальный Z
    for i = 1, #meownatic do
        if meownatic[i].z > maximum then
            maximum = meownatic[i].z
        end
    end
    return maximum
end

function meow_schem:min_z(meownatic)
    local minimal = meownatic[1].z
    --Минимальный Z
    for i = 1, #meownatic do
        if meownatic[i].z < minimal then
            minimal = meownatic[i].z
        end
    end
    return minimal
end

function meow_schem:max_position(meownatic)
    local max_x = meownatic[1].x
    local max_y = meownatic[1].y
    local max_z = meownatic[1].z
    for i = 1, #meownatic do
        if meownatic[i].x > max_x then
            max_x = meownatic[i].x
        end
        if meownatic[i].y > max_y then
            max_y = meownatic[i].y
        end
        if meownatic[i].z > max_z then
            max_z = meownatic[i].z
        end
    end
    return {max_x, max_y, max_z}
end

function meow_schem:min_position(meownatic)
    local min_x = meownatic[1].x
    local min_y = meownatic[1].y
    local min_z = meownatic[1].z
    for i = 1, #meownatic do
        if meownatic[i].x < min_x then
            min_x = meownatic[i].x
        end
        if meownatic[i].y < min_y then
            min_y = meownatic[i].y
        end
        if meownatic[i].z < min_z then
            min_z = meownatic[i].z
        end
    end
    return {min_x, min_y, min_z}
end


return meow_schem