--Meownatic BluePrint

local MAX_BYTE = 255
local MAX_UINT16 = 65535
local MAX_UINT32 = 4294967295
local VERSION_MBP = 1
local TYPE_IDS = nil
local mbp = {}

local function add_to_blocks_array(buf, value)
    if type(value) == 'number' then
        if value >= MAX_BYTE then
            if value >= MAX_UINT16 then
                buf:put_byte(3)
                buf:put_uint32(value)
            else
                buf:put_byte(2)
                buf:put_uint16(value)
            end
        else
            buf:put_byte(1)
            buf:put_byte(value)
        end
    elseif type(value) == 'table' then
        buf:put_byte(0)
        if TYPE_IDS == 0 then
            buf:put_byte(value[1])
        elseif TYPE_IDS == 1 then
            buf:put_uint16(value[1])
        end
        buf:put_byte(value[2])
        buf:put_bool(value[3])
    end
end

local function put_version(buf)
    buf:put_byte(VERSION_MBP)
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

local function put_blocks(buf, blocks)
    buf:put_uint32(#blocks)
    for b, block in ipairs(blocks) do
        add_to_blocks_array(buf, block)
    end
end

function mbp.serialize(buf, array)
    put_version(buf)
    put_ids_array(buf, array[2])
    put_depth(buf, array[3][1], array[3][2], array[3][3], array[3][4])
    put_blocks(buf, array[4])
end

local function get_version(buf)
    return buf:get_byte()
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
    local data = {}
    local X = buf:get_uint16()
    local Y = buf:get_uint16()
    local Z = buf:get_uint16()
    local Bind = buf:get_uint32()
    return {X, Y, Z, Bind}
end

local function read_block(buf)
    local type_data = buf:get_byte()
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
    else
        return buf:get_uint32()
    end
end

local function get_blocks(buf)
    local len = buf:get_uint32()
    local result = {}
    for i = 1, len do
        table.insert(result, read_block(buf))
    end
    return result
end

function mbp.deserialize(buf)
    local version = get_version(buf)
    local ids = get_ids_array(buf)
    local depth = get_depth(buf)
    local blocks = get_blocks(buf)
    return {version, ids, depth, blocks}
end

return mbp
