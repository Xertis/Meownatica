local meow_schem = {}

function meow_schem.min_y(meownatic)
    local minimal = meownatic[1].y
    --Минимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y < minimal then
            minimal = meownatic[i].y
        end
    end
    return minimal
end

function meow_schem.max_y(meownatic)
    local maximum = meownatic[1].y
    --Максимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y > maximum then
            maximum = meownatic[i].y
        end
    end
    return maximum
end

function meow_schem.max_x(meownatic)
    local maximum = meownatic[1].x
    --Максимальный X
    for i = 1, #meownatic do
        if meownatic[i].x > maximum then
            maximum = meownatic[i].x
        end
    end
    return maximum
end

function meow_schem.min_x(meownatic)
    local minimal = meownatic[1].x
    --Минимальный X
    for i = 1, #meownatic do
        if meownatic[i].x < minimal then
            minimal = meownatic[i].x
        end
    end
    return minimal
end

function meow_schem.max_z(meownatic)
    local maximum = meownatic[1].z
    --Максимальный Z
    for i = 1, #meownatic do
        if meownatic[i].z > maximum then
            maximum = meownatic[i].z
        end
    end
    return maximum
end

function meow_schem.min_z(meownatic)
    local minimal = meownatic[1].z
    --Минимальный Z
    for i = 1, #meownatic do
        if meownatic[i].z < minimal then
            minimal = meownatic[i].z
        end
    end
    return minimal
end

function meow_schem.max_position(meownatic)
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

function meow_schem.min_position(meownatic)
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

function meow_schem.get_binding_block(meownatic)
    local clstDist = math.huge
    local clstID = nil

    for i, point in ipairs(meownatic) do
        local distance = math.sqrt(point.x^2 + point.y^2 + point.z^2)

        if distance < clstDist then
            clstDist = distance
            clstID = i
        end
    end

    return clstID
end

function meow_schem.distance(x1, y1, z1, x2, y2, z2)
	local x, y, z = x1 - x2, y1 - y2, z1 - z2

	if x < 0 then x = -x end
	if y < 0 then y = -y end
	if z < 0 then z = -z end

	return x + y + z
end

function meow_schem.easy_distance(x1, y1, z1, x2, y2, z2)
    local x, y, z = math.abs(x1 - x2), math.abs(y1 - y2), math.abs(z1 - z2)
    return x+y+z
end

function meow_schem.if_cord_in_meownatic(x, y, z, meownatic)
    for i = 1, #meownatic do
        if meownatic[i].x == x and meownatic[i].y == y and meownatic[i].z == z then
            return true, i
        end
    end
    return false
end
return meow_schem