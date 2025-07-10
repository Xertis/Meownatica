local BluePrint = {}
BluePrint.__index = BluePrint

local block_signature = {
    id = 0,
    states = 0,
    pos = {0, 0, 0},
}

local function __pre_process(blocks, origin)
    local min = {math.huge, math.huge, math.huge}
    local max = {0, 0, 0}
    local origin_index = 1

    for id, block in ipairs(blocks) do
        local pos = vec3.sub(block.pos, origin)

        min = utils.vec.min(min, pos)
        max = utils.vec.max(max, pos)

        if pos[1] == 0 and pos[2] == 0 and pos[3] == 0 then
            origin_index = id
        end

        block.pos = pos
    end

    local size = vec3.add(vec3.abs(vec3.sub(max, min)), 1)

    return size, origin_index
end

local function __pre_process_indexes(blocks)
    local indexes = {to = {}, from = {}}
    local max_index = 0
    for _, _block in ipairs(blocks) do
        local block_name = block.name(_block.id)
        if indexes.to[block_name] == nil then
            indexes.to[block_name] = {
                id = max_index,
                name = block_name
            }
            indexes.from[max_index] = {
                id = max_index,
                name = block_name
            }
            max_index = max_index + 1
        end

        _block.id = indexes.to[block_name].id
    end

    return indexes
end

local function __change_origin(blocks, new_origin)
    for _, block in ipairs(blocks) do
        block.pos = vec3.sub(block.pos, new_origin)
    end

    return blocks
end

function BluePrint.new(blocks, origin)
    local self = setmetatable({}, BluePrint)

    self.blocks = blocks or {}
    self.size, self.origin = __pre_process(self.blocks, origin)
    self.indexes = __pre_process_indexes(self.blocks)
    self.name = "default_name.mbp"

    self.meta = {
        description = '',
        image = {}
    }

    return self
end

function BluePrint:move_origin(new_origin)
    self.blocks = __change_origin(self.blocks, new_origin)
end

function BluePrint:rotate(rotation)
    local rad_x = math.rad(rotation[1] or 0)
    local rad_y = math.rad(rotation[2] or 0)
    local rad_z = math.rad(rotation[3] or 0)

    local cos_x, sin_x = math.cos(rad_x), math.sin(rad_x)
    local cos_y, sin_y = math.cos(rad_y), math.sin(rad_y)
    local cos_z, sin_z = math.cos(rad_z), math.sin(rad_z)

    for _, block in ipairs(self.blocks) do
        local x, y, z = block.pos[1], block.pos[2], block.pos[3]

        if rad_x ~= 0 then
            local new_y = y * cos_x - z * sin_x
            local new_z = y * sin_x + z * cos_x
            y, z = new_y, new_z
        end

        if rad_y ~= 0 then
            local new_x = x * cos_y + z * sin_y
            local new_z = -x * sin_y + z * cos_y
            x, z = new_x, new_z
        end

        if rad_z ~= 0 then
            local new_x = x * cos_z - y * sin_z
            local new_y = x * sin_z + y * cos_z
            x, y = new_x, new_y
        end

        block.pos[1], block.pos[2], block.pos[3] = x, y, z
    end

    return self
end

function BluePrint:build(origin_pos)
    for _, _block in ipairs(self.blocks) do
        local pos = vec3.add(origin_pos, _block.pos)
        local states = _block.states
        local id = block.index(self.indexes.from[_block.id].name)

        if (not CONFIG.setair and id ~= 0) or CONFIG.setair then
            block.set(pos[1], pos[2], pos[3], id, states)
        end
    end
end

function BluePrint:index_to_pos(index)
    local sizeX, sizeY, sizeZ = unpack(self.size)
    local total_blocks = sizeX * sizeY * sizeZ

    if index < 1 or index > total_blocks then
        return nil
    end

    index = index - 1
    local z = index % sizeZ
    local y = math.floor(index / sizeZ) % sizeY
    local x = math.floor(index / (sizeY * sizeZ))

    local origin_index = self.origin - 1
    local origin_z = origin_index % sizeZ
    local origin_y = math.floor(origin_index / sizeZ) % sizeY
    local origin_x = math.floor(origin_index / (sizeY * sizeZ))

    return {
        x - origin_x,
        y - origin_y,
        z - origin_z
    }
end

function BluePrint:pos_to_index(pos)
    local sizeX, sizeY, sizeZ = unpack(self.size)
    local x, y, z = unpack(pos)

    local origin_index = self.origin - 1
    local origin_z = origin_index % sizeZ
    local origin_y = math.floor(origin_index / sizeZ) % sizeY
    local origin_x = math.floor(origin_index / (sizeY * sizeZ))

    local abs_x = origin_x + x
    local abs_y = origin_y + y
    local abs_z = origin_z + z

    if abs_x < 0 or abs_x >= sizeX or
       abs_y < 0 or abs_y >= sizeY or
       abs_z < 0 or abs_z >= sizeZ then
        return nil
    end

    return abs_x * sizeY * sizeZ + abs_y * sizeZ + abs_z + 1
end

return BluePrint