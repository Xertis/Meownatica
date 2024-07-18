local module = {}

function module.matrix2Quaternion(matrix)
    local qw, qx, qy, qz
    local trace = matrix[1][1] + matrix[2][2] + matrix[3][3]

    if trace > 0 then
        local S = math.sqrt(1 + trace) * 2
        qw = 0.25 * S
        qx = (matrix[3][2] - matrix[2][3]) / S
        qy = (matrix[1][3] - matrix[3][1]) / S
        qz = (matrix[2][1] - matrix[1][2]) / S
    elseif matrix[1][1] > matrix[2][2] and matrix[1][1] > matrix[3][3] then
        local S = math.sqrt(1 + matrix[1][1] - matrix[2][2] - matrix[3][3]) * 2
        qw = (matrix[3][2] - matrix[2][3]) / S
        qx = 0.25 * S
        qy = (matrix[1][2] + matrix[2][1]) / S
        qz = (matrix[1][3] + matrix[3][1]) / S
    elseif matrix[2][2] > matrix[3][3] then
        local S = math.sqrt(1 + matrix[2][2] - matrix[1][1] - matrix[3][3]) * 2
        qw = (matrix[1][3] - matrix[3][1]) / S
        qx = (matrix[1][2] + matrix[2][1]) / S
        qy = 0.25 * S
        qz = (matrix[2][3] + matrix[3][2]) / S
    else
        local S = math.sqrt(1 + matrix[3][3] - matrix[1][1] - matrix[2][2]) * 2
        qw = (matrix[2][1] - matrix[1][2]) / S
        qx = (matrix[1][3] + matrix[3][1]) / S
        qy = (matrix[2][3] + matrix[3][2]) / S
        qz = 0.25 * S
    end

    return {qw, qx, qy, qz}
end


function module.quaternion2Matrix(q)
    local w, x, y, z = q[1], q[2], q[3], q[4]

    local xx = x * x
    local xy = x * y
    local xz = x * z
    local xw = x * w

    local yy = y * y
    local yz = y * z
    local yw = y * w

    local zz = z * z
    local zw = z * w

    return {
        1 - 2 * (yy + zz), 2 * (xy - zw), 2 * (xz + yw), 0,
        2 * (xy + zw), 1 - 2 * (xx + zz), 2 * (yz - xw), 0,
        2 * (xz - yw), 2 * (yz + xw), 1 - 2 * (xx + yy), 0,
        0, 0, 0, 1
    }
end

return module