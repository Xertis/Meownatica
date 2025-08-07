local bit_buffer = require "files/buffer/bit_buffer"
local BluePrint = require "blueprint/blueprint"
local rle = require "files/utils/rle"

local mbp = {}

local VERSION = 1

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

local function __put_block(buf, block, indexes)
    buf:put_uint16(block.id)
    buf:put_uint16(block.states)
end

function mbp.__put_blocks(buf, blocks, indexes)
    local compressed_blocks = rle.compress(blocks)

    buf:put_uint32(#compressed_blocks)

    for _, block in ipairs(compressed_blocks) do
        if type(block) == "number" then
            __put_count(buf, block)
        else
            buf:put_uint(0, 2)
            __put_block(buf, block, indexes)
        end
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
end

function mbp.serialize(blueprint)
    local buf  = bit_buffer:new()
    mbp.__put_data(buf, blueprint)
    mbp.__put_indexes(buf, blueprint.indexes)
    mbp.__put_blocks(buf, blueprint.blocks, blueprint.indexes)

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
    return {
        version = version,
        size = size,
        origin = origin,
        rotation_vector = rotation_vector
    }
end

function mbp.deserialize(bytes)
    local buf = bit_buffer:new(bytes)
    local data = mbp.__get_data(buf)
    local indexes = mbp.__get_indexes(buf)
    local blocks = rle.decompress(mbp.__get_blocks(buf))

    local blueprint = BluePrint.new({}, {0, 0, 0})

    blueprint.origin = data.origin
    blueprint.size = data.size
    blueprint.rotation_vector = data.rotation_vector

   for id, block in ipairs(blocks) do
        block.pos = blueprint:index_to_pos(id)
    end

    blueprint.blocks = blocks
    blueprint.indexes = indexes
    blueprint.loaded = true

    return blueprint
end

return mbp