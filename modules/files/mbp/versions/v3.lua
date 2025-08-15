local bit_buffer = require "files/buffer/bit_buffer"
local BluePrint = require "blueprint/blueprint"
local rle = require "files/utils/rle"

local mbp = {}

local VERSION = 3

local MAX_UINT16 = 65535
local MIN_UINT16 = 0
local MAX_UINT32 = 4294967295
local MIN_UINT32 = 0
local MAX_BYTE = 255

local MIN_NBYTE = -255
local MAX_NINT16 = 0
local MIN_NINT16 = -65535
local MAX_NINT32 = 0
local MIN_NINT32 = -4294967295

local MAX_INT64 = 9223372036854775807
local MIN_INT64 = -9223372036854775808

local blocks_types = {
    block = 0,
    rle_byte = 1,
    rle_uint16 = 2,
    rle_uint32 = 3
}

local function __put_count(buf, count)
    if count <= MAX_BYTE then
        buf:put_uint(1, 2)
        buf:put_byte(count)
    elseif count <= MAX_UINT16 then
        buf:put_uint(2, 2)
        buf:put_uint16(count)
    elseif count <= MAX_UINT32 then
        buf:put_uint(3, 2)
        buf:put_uint32(count)
    end
end

local function __put_block(buf, block)
    buf:put_uint16(block.id)
    buf:put_uint16(block.states)
end

function mbp.__put_blocks(buf, blocks)
    local compressed_blocks = rle.compress(blocks)

    buf:put_uint32(#compressed_blocks)

    for _, block in ipairs(compressed_blocks) do
        if type(block) == "number" then
            __put_count(buf, block)
        else
            buf:put_uint(0, 2)
            __put_block(buf, block)
        end
    end
end

function mbp.__put_entities(buf, entities)
    buf:put_uint32(#entities)

    for _, entity in ipairs(entities) do
        buf:put_uint16(entity.id)
        local pos = entity.pos
        local rot = entity.rotation

        buf:put_float32(pos[1])
        buf:put_float32(pos[2])
        buf:put_float32(pos[3])

        local quaternion = quat.from_mat4(rot)
        for i = 1, 16 do
            buf:put_bit(rot[i] >= 0)
        end
        buf:put_float32(quaternion[1])
        buf:put_float32(quaternion[2])
        buf:put_float32(quaternion[3])
        buf:put_float32(quaternion[4])
    end
end

function mbp.__put_indexes(buf, indexes)
    local len = table.count_pairs(indexes.from)
    buf:put_uint16(len)
    for i=0, len-1 do
        buf:put_string(indexes.from[i].name)
    end
end

function mbp.__put_data(buf, blueprint)
    buf:put_string("MBP")
    buf:put_uint16(VERSION)

    buf:put_uint16(blueprint.size[1])
    buf:put_byte(blueprint.size[2])
    buf:put_uint16(blueprint.size[3])

    buf:put_float32(blueprint.rotation_vector[1])
    buf:put_float32(blueprint.rotation_vector[2])
    buf:put_float32(blueprint.rotation_vector[3])

    buf:put_uint32(blueprint.origin)

    buf:put_string(blueprint.author)
    buf:put_string(blueprint.description)
    buf:put_byte(#blueprint.tags)

    for _, tag in ipairs(blueprint.tags) do
        buf:put_string(tag)
    end

    local image_bytes = nil
    if blueprint.image_path ~= '' then
        image_bytes = file.read_bytes(blueprint.image_path)
    end

    image_bytes = image_bytes or {}
    buf:put_uint32(#image_bytes)
    buf:put_bytes(image_bytes)
end

function mbp.serialize(blueprint)
    local buf  = bit_buffer:new()
    mbp.__put_data(buf, blueprint)
    mbp.__put_indexes(buf, blueprint.block_indexes)
    mbp.__put_indexes(buf, blueprint.entity_indexes)

    mbp.__put_blocks(buf, blueprint.blocks)
    mbp.__put_entities(buf, blueprint.entities)

    buf:flush()
    buf:reset()

    return buf
end

function mbp.__get_indexes(buf)
    local len = buf:get_uint16()

    local indexes = {to = {}, from = {}}
    for i=0, len-1 do
        local id = i
        local name = buf:get_string()

        indexes.to[name] = {
            id = id,
            name = name
        }
        indexes.from[id] = {
            id = id,
            name = name
        }
    end

    return indexes
end

function mbp.__get_blocks(buf)
    local len = buf:get_uint32()
    local blocks = {}
    for i=1, len do
        local type = buf:get_uint(2)
        if type == 0 then
            blocks[i] = {
                id = buf:get_uint16(),
                states = buf:get_uint16()
            }
        elseif type == 1 then
            blocks[i] = buf:get_byte()
        elseif type == 2 then
            blocks[i] = buf:get_uint16()
        elseif type == 3 then
            blocks[i] = buf:get_uint32()
        end
    end

    return blocks
end

function mbp.__get_entities(buf)
    local len = buf:get_uint32()
    local entities = {}
    for i=1, len do
        local id = buf:get_uint16()
        local pos = {
            buf:get_float32(),
            buf:get_float32(),
            buf:get_float32()
        }

        local signs = {}
        for j = 1, 16 do
            signs[j] = buf:get_bit()
        end
        local quaternion = {
            buf:get_float32(),
            buf:get_float32(),
            buf:get_float32(),
            buf:get_float32()
        }
        local rot_mat = mat4.from_quat(quaternion)
        for j = 1, 16 do
            if not signs[j] then
                rot_mat[j] = -math.abs(rot_mat[j])
            else
                rot_mat[j] = math.abs(rot_mat[j])
            end
        end

        table.insert(entities, {
            id = id,
            pos = pos,
            rotation = rot_mat
        })
    end

    return entities
end

function mbp.__get_data(buf)
    local is_mbp = buf:get_string()

    if is_mbp ~= "MBP" then
        error("Неправильный файл .mbp")
    end

    local version = buf:get_uint16()
    local size = {
        buf:get_uint16(),
        buf:get_byte(),
        buf:get_uint16()
    }

    local rotation_vector = {
        buf:get_float32(),
        buf:get_float32(),
        buf:get_float32()
    }

    local origin = buf:get_uint32()

    local author = buf:get_string()
    local description =  buf:get_string()
    local count_tags = buf:get_byte()

    local tags = {}
    for _=1, count_tags do
        table.insert(tags, buf:get_string())
    end

    local image_bytes_count = buf:get_uint32()
    local image_bytes = buf:get_bytes(image_bytes_count)

    return {
        version = version,
        size = size,
        origin = origin,
        rotation_vector = rotation_vector,
        author = author,
        description = description,
        tags = tags,
        image_bytes = image_bytes
    }
end

function mbp.deserialize(bytes)
    local buf = bit_buffer:new(bytes)
    local data = mbp.__get_data(buf)

    local block_indexes = mbp.__get_indexes(buf)
    local entity_indexes = mbp.__get_indexes(buf)

    local blocks = rle.decompress(mbp.__get_blocks(buf))
    local entities = mbp.__get_entities(buf)

    local blueprint = BluePrint.new({}, {}, {0, 0, 0})

    blueprint.origin = data.origin
    blueprint.size = data.size
    blueprint.entities = entities
    blueprint.image_bytes = data.image_bytes
    blueprint.rotation_vector = data.rotation_vector
    blueprint.rotation_matrix = utils.mat4.vec_to_mat(data.rotation_vector)
    blueprint.author = data.author
    blueprint.description = data.description
    blueprint.tags = data.tags

   for id, block in ipairs(blocks) do
        block.pos = blueprint:index_to_pos(id)
    end

    blueprint.blocks = blocks
    blueprint.block_indexes = block_indexes
    blueprint.entity_indexes = entity_indexes
    blueprint.loaded = true

    blueprint:__init_packs()

    return blueprint
end

return mbp