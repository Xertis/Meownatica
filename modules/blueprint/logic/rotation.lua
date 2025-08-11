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

local dirs = {
    pipe = {
        [0] = "+Z",
        [1] = "-X",
        [2] = "-Z",
        [3] = "+X",
        [4] = "+Y",
        [5] = "-Y"
    },
    pane = {
        [0] = "-Z",
        [1] = "-X",
        [2] = "+Z",
        [3] = "+X"
    }
}

local vec_map = {
    ["+X"] = {1,0,0},
    ["-X"] = {-1,0,0},
    ["+Y"] = {0,1,0},
    ["-Y"] = {0,-1,0},
    ["+Z"] = {0,0,1},
    ["-Z"] = {0,0,-1},
}

local function same_vec(a,b)
    return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

local function rotate_vector(v, axis, times)
    times = times % 4
    local x, y, z = v[1], v[2], v[3]
    for _ = 1, times do
        if axis == "+Y" then x, z = z, -x
        elseif axis == "-Y" then x, z = -z, x
        elseif axis == "+X" then y, z = z, -y
        elseif axis == "-X" then y, z = -z, y
        elseif axis == "+Z" then x, y = -y, x
        elseif axis == "-Z" then x, y = y, -x
        end
    end
    return {x, y, z}
end

--Я заколебался пытаться сам матешей, поэтому выпросил у нейронки эту функцию
function module.transform_block(view_dir, axis_rot, block_rot, profile)
    if profile == "none" then
        return block_rot
    end

    local block_vec = vec_map[dirs[profile][block_rot]]

    local def_view = "+Y"
    local def_forward = "-Z"

    local target_view = dirs.pipe[view_dir]

    local orientations = {
        ["+Y"] = {"+Z","+X","-Z","-X"},
        ["-Y"] = {"+Z","-X","-Z","+X"},
        ["+Z"] = {"+Y","-X","-Y","+X"},
        ["-Z"] = {"+Y","+X","-Y","-X"},
        ["+X"] = {"+Y","+Z","-Y","-Z"},
        ["-X"] = {"+Y","-Z","-Y","+Z"},
    }

    local function rotate_to_view(vec, from, to)
        if from == to then return vec end
        for _,axis in ipairs({"+X","-X","+Y","-Y","+Z","-Z"}) do
            local tmp = {vec[1], vec[2], vec[3]}
            for t=1,3 do
                tmp = rotate_vector(tmp, axis, 1)
                local new_from = rotate_vector(vec_map[from], axis, t)
                if same_vec(new_from, vec_map[to]) then
                    return tmp
                end
            end
        end
        return vec
    end

    block_vec = rotate_to_view(block_vec, def_view, target_view)

    local rotation_times = axis_rot % 4
    block_vec = rotate_vector(block_vec, target_view, rotation_times)

    for idx, name in pairs(dirs[profile]) do
        if same_vec(block_vec, vec_map[name]) then
            return idx
        end
    end
end

return module