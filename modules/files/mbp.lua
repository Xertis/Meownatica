--Meownatic BluePrint

local MAX_BYTE = 255
local MAX_UINT16 = 65535
local MAX_UINT32 = 4294967295
local VERSION_MBP = 1
local TYPE_IDS = nil
local signs_e = require 'meownatica:logic/signs_encode'
local byte_conv = require 'meownatica:logic/type_byte_convert'
local mbp = {}

local function add_to_blocks_array(buf, value)
    if type(value) == 'number' then
        if value > MAX_BYTE then
            if value > MAX_UINT16 then
                buf:put_uint32(value)
            else
                buf:put_uint16(value)
            end
        else
            buf:put_byte(value)
        end
    elseif type(value) == 'table' then
        if TYPE_IDS == 0 then
            buf:put_byte(value[1])
        elseif TYPE_IDS == 1 then
            buf:put_uint16(value[1])
        end
        buf:put_byte(value[2])
        buf:put_bool(value[3])
    end
end

local function get_types(i, blocks)
    local types = {}
    for j=i, i+3 do
        if j <= #blocks then
            if type(blocks[j]) == 'table' then
                table.insert(types, 0)
            elseif type(blocks[j]) == 'number' then
                if blocks[j] > MAX_BYTE then
                    if blocks[j] > MAX_UINT16 then
                        table.insert(types, 3)
                    else
                        table.insert(types, 2)
                    end
                else
                    table.insert(types, 1)
                end
            end
        else
            for k=#types+1, 4 do
                types[k] = 0
            end
            break
        end
    end
    return types
end

local function put_blocks(buf, blocks)
    buf:put_uint32(#blocks)
    local types = get_types(1, blocks)
    local temp = 4
    buf:put_byte(byte_conv.ToByte(types))
    for i=1, #blocks do
        if temp == 0 then
            types = get_types(i, blocks)
            temp = 3
            local byte = byte_conv.ToByte(types)
            buf:put_byte(byte)
            add_to_blocks_array(buf, blocks[i])
        else
            temp = temp - 1
            add_to_blocks_array(buf, blocks[i])
        end
    end
end

local function add_to_entity_array(buf, value)
    if TYPE_IDS == 0 then
        buf:put_byte(value[1])
    elseif TYPE_IDS == 1 then
        buf:put_uint16(value[1])
    end
    local quat = mat4.decompose(value[2])['quaternion']
    buf:put_uint16(signs_e.encode(value[2]))
    buf:put_single(quat[1])
    buf:put_single(quat[2])
    buf:put_single(quat[3])
    buf:put_single(quat[4])

    buf:put_single(value[3])
    buf:put_single(value[4])
    buf:put_single(value[5])
end

local function put_version(buf)
    buf:put_uint16(VERSION_MBP)
end

local function put_ids_array(buf, blocks_ids)
    if #blocks_ids <= MAX_BYTE then
        buf:put_byte(0)
        buf:put_byte(#blocks_ids)
        TYPE_IDS = 0
    else
        buf:put_byte(1)
        buf:put_uint16(#blocks_ids)
        TYPE_IDS = 1
    end
    for b, id in ipairs(blocks_ids) do
        buf:put_string(id)
    end
end

local function put_depth(buf, DepthX, DepthY, DepthZ, Binding)
    buf:put_uint16(DepthX)
    buf:put_uint16(DepthY)
    buf:put_uint16(DepthZ)
    buf:put_uint32(Binding)
end

local function put_entities(buf, entities)
    buf:put_uint32(#entities)
    for _, entity in ipairs(entities) do
        add_to_entity_array(buf, entity)
    end
end

function mbp.serialize(buf, array)
    put_version(buf)
    put_ids_array(buf, array[2])
    put_depth(buf, array[3][1], array[3][2], array[3][3], array[3][4])
    put_blocks(buf, array[4])
    put_entities(buf, array[5])
end

local function get_version(buf)
    return buf:get_uint16()
end

local function get_ids_array(buf)
    TYPE_IDS = buf:get_byte()
    local len = nil
    if TYPE_IDS == 0 then
        len = buf:get_byte()
    elseif TYPE_IDS == 1 then
        len = buf:get_uint16()
    end
    local ids = {}
    for i = 1, len do
        table.insert(ids, buf:get_string())
    end
    return ids
end

local function get_depth(buf)
    local X = buf:get_uint16()
    local Y = buf:get_uint16()
    local Z = buf:get_uint16()
    local Bind = buf:get_uint32()
    return {X, Y, Z, Bind}
end

local function read_block(type_data, buf)
    if type_data == 0 then
        local id = nil
        if TYPE_IDS == 0 then
            id = buf:get_byte()
        elseif TYPE_IDS == 1 then
            id = buf:get_uint16()
        end
        local rotation = buf:get_byte()
        local solid =  buf:get_bool()
        return {id, rotation, solid}
    elseif type_data == 1 then
        return buf:get_byte()
    elseif type_data == 2 then
        return buf:get_uint16()
    elseif type_data == 3 then
        return buf:get_uint32()
    end
end

local function get_blocks(buf)
    local len = buf:get_uint32()
    local result = {}
    local types = byte_conv.ToTable(buf:get_byte())
    local i = 1
    local temp = 4
    while i <= len do
        if temp == 0 then
            types = byte_conv.ToTable(buf:get_byte())
            temp = 4
        else
            local point = (i - 1) % 4 + 1
            table.insert(result, read_block(types[point], buf))
            temp = temp - 1
            i = i + 1
        end
    end
    return result
end

local function read_entity(buf)
    local id = nil
    if TYPE_IDS == 0 then
        id = buf:get_byte()
    elseif TYPE_IDS == 1 then
        id = buf:get_uint16()
    end
    local signs = signs_e.decode(buf:get_uint16(), 16)
    local qp1, qp2, qp3, qp4 = buf:get_single(), buf:get_single(), buf:get_single(), buf:get_single()

    local rot = signs_e.parse(signs, mat4.from_quat({qp1, qp2, qp3, qp4}))
    local x, y, z = buf:get_single(), buf:get_single(), buf:get_single()
    return {id, rot, x, y, z}
end

local function get_entities(buf)
    local len = buf:get_uint32()
    local result = {}
    for i = 1, len do
        table.insert(result, read_entity(buf))
    end
    return result
end

function mbp.deserialize(buf)
    local version = get_version(buf)
    local ids = get_ids_array(buf)
    local depth = get_depth(buf)
    local blocks = get_blocks(buf)

    local entities = get_entities(buf)
    return {version, ids, depth, blocks, entities}
end

return mbp
