local module = {}

function module.dual_pass_rotated(blocks, rotation_matrix)
    local src = {}
    for _, blk in ipairs(blocks) do
        local key = blk.pos[1]..","..blk.pos[2]..","..blk.pos[3]
        src[key] = blk
    end

    local R    = rotation_matrix
    local invR = mat4.inverse(R)

    local pivot = {0,0,0}

    local dst = {}
    local minx, maxx = math.huge, -math.huge
    local miny, maxy = math.huge, -math.huge
    local minz, maxz = math.huge, -math.huge

    for _, blk in ipairs(blocks) do
        local x0 = blk.pos[1] - pivot[1]
        local y0 = blk.pos[2] - pivot[2]
        local z0 = blk.pos[3] - pivot[3]

        local v = mat4.mul(R, { x0, y0, z0, 1 })
        local w = (v[4] ~= 0 and v[4]) or 1

        local xr, yr, zr =
          math.round(v[1]/w) + pivot[1],
          math.round(v[2]/w) + pivot[2],
          math.round(v[3]/w) + pivot[3]

        local key = xr..","..yr..","..zr
        dst[key] = {
          pos    = {xr,yr,zr},
          id     = blk.id,
          states = blk.states,
        }

        minx, maxx = math.min(minx, xr), math.max(maxx, xr)
        miny, maxy = math.min(miny, yr), math.max(maxy, yr)
        minz, maxz = math.min(minz, zr), math.max(maxz, zr)
    end

    for xt = minx, maxx do
        for yt = miny, maxy do
            for zt = minz, maxz do
                local k2 = xt..","..yt..","..zt
                if not dst[k2] then
                    local v = mat4.mul(invR, { xt - pivot[1], yt - pivot[2], zt - pivot[3], 1 })
                    local w = (v[4] ~= 0 and v[4]) or 1

                    local xs = math.round(v[1]/w) + pivot[1]
                    local ys = math.round(v[2]/w) + pivot[2]
                    local zs = math.round(v[3]/w) + pivot[3]
                    local key = xs..","..ys..","..zs

                    local src_blk = src[key]
                    if src_blk then
                        dst[k2] = {
                            pos    = {xt, yt, zt},
                            id     = src_blk.id,
                            states = src_blk.states,
                        }
                    end
                end
            end
        end
    end

    local out = {}
    for _, blk in pairs(dst) do
        table.insert(out, blk)
    end

    return out
end

return module