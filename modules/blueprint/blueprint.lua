local rotator = require "blueprint/logic/rotation"

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
    local origin_index = 1
    for id, block in ipairs(blocks) do
        local pos = vec3.sub(block.pos, new_origin)
        block.pos = pos

        if pos[1] == 0 and pos[2] == 0 and pos[3] == 0 then
            origin_index = id
        end
    end

    return blocks, origin_index
end

function BluePrint.new(blocks, origin)
    local self = setmetatable({}, BluePrint)

    self.blocks = blocks or {}
    self.size, self.origin = __pre_process(self.blocks, origin)
    self.indexes = __pre_process_indexes(self.blocks)
    self.name = "default_name.mbp"
    self.rotation_vector = {0, 0, 0}
    self.rotation_matrix = utils.mat4.vec_to_mat(self.rotation_vector)
    self.author = ""
    self.description = ""
    self.logo = {}
    self.loaded = false
    self.tags = {}

    self.meta = {
        description = '',
        image = {}
    }

    return self
end

function BluePrint:move_origin(new_origin)
    self.blocks, self.origin = __change_origin(self.blocks, new_origin)
    return self
end

function BluePrint:rotate(rotation)
    self.rotation_vector = rotation
    self.rotation_matrix = utils.mat4.vec_to_mat(rotation)

    return self
end

function BluePrint:build(origin_pos)
    local rotated = rotator.dual_pass_rotated(self.blocks, self.rotation_matrix)
    for _, blk in ipairs(rotated) do
        local p = blk.pos
        local world_x = origin_pos[1] + p[1]
        local world_y = origin_pos[2] + p[2]
        local world_z = origin_pos[3] + p[3]

        local id = block.index(self.indexes.from[blk.id].name)
        if (not MEOW_CONFIG.setair and id ~= 0) or MEOW_CONFIG.setair then
            block.set(world_x, world_y, world_z, id, blk.states)
        end
    end

    return self
end

function BluePrint:build_preview(origin_pos)
    local rotated = rotator.dual_pass_rotated(self.blocks, self.rotation_matrix)
    local preview_id = block.index("meownatica:preview")

    for _, blk in ipairs(rotated) do
        local world_pos = vec3.add(origin_pos, blk.pos)

        local existing = block.get(world_pos[1], world_pos[2], world_pos[3])
        local block_id = block.index(self.indexes.from[blk.id].name)

        if block_id ~= 0 and existing == 0 then
            block.set(world_pos[1], world_pos[2], world_pos[3], preview_id)
        end
    end

    return self
end

function BluePrint:unbuild_preview(origin_pos)
    local rotated = rotator.dual_pass_rotated(self.blocks, self.rotation_matrix)
    local preview_id = block.index("meownatica:preview")

    for _, blk in ipairs(rotated) do
        local world_pos = vec3.add(origin_pos, blk.pos)

        if block.get(world_pos[1], world_pos[2], world_pos[3]) == preview_id then
            block.set(world_pos[1], world_pos[2], world_pos[3], 0)
        end
    end

    return self
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

function BluePrint:get_center_pos()
    local min = {math.huge, math.huge, math.huge}
    local max = {-math.huge, -math.huge, -math.huge}

    for _, block in ipairs(self.blocks) do
        min = utils.vec.min(min, block.pos)
        max = utils.vec.max(max, block.pos)
    end

    local center_x = math.floor((min[1] + max[1]) / 2)
    local center_y = math.floor((min[2] + max[2]) / 2)
    local center_z = math.floor((min[3] + max[3]) / 2)

    return {center_x, center_y, center_z}
end

return BluePrint