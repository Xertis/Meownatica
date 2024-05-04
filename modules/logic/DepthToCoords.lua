local convert = {}

function convert:dtc(DepthX, DepthY, DepthZ)
    local x, y, z = DepthX, DepthY, DepthZ
    return {{0, 0, 0}, {x, y, z}}
end

return convert