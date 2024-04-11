-- ARBD (Array Binary Document) File format implementation for Lua
-- Creator: Onran

local STR = 0
local BOOL = 1
local ARR = 2
local NUM_BYTE, NUM_UINT16, NUM_UINT32, NUM_INT16, NUM_INT32, NUM_INT64, NUM_DOUBLE, NUM_ZERO = 3, 4, 5, 6, 7, 8, 9, 10

local MAX_BYTE = 255
local MAX_UINT16 = 65535
local MIN_UINT16 = 0
local MAX_UINT32 = 4294967295
local MIN_UINT32 = 0

local MAX_INT16 = 32767
local MIN_INT16 = -32768
local MAX_INT32 = 2147483647
local MIN_INT32 = -2147483648
local MAX_INT64 = 9223372036854775807
local MIN_INT64 = -9223372036854775808

local arbd = { }

local function serializeArray(arr, buf)
    local len = #arr
    buf:put_byte(ARR)
    buf:put_uint32(len)

    for i = 1, len do
        local o = arr[i]
        local otype = type(o)

        if otype == "string" then
            buf:put_byte(STR)
            buf:put_string(o)
        elseif otype == "boolean" then
            buf:put_byte(BOOL)
            buf:put_bool(o)
        elseif otype == "number" then
            if math.floor(o) ~= o then
                buf:put_byte(NUM_DOUBLE)
                buf:put_double(o)
            elseif o > 0 and o <= MAX_UINT32 then
                if o <= MAX_BYTE then
                    buf:put_byte(NUM_BYTE)
                    buf:put_byte(o)
                elseif o <= MAX_UINT16 then
                    buf:put_byte(NUM_UINT16)
                    buf:put_uint16(o)
                elseif o <= MAX_UINT32 then
                    buf:put_uint32(0)
                end
            else
                if o == 0 then
                    buf:put_byte(NUM_ZERO)
                else
                    if o <= MAX_INT16 and o >= MIN_INT16 then
                        buf:put_byte(NUM_INT16)
                        buf:put_int16(o)
                    elseif o <= MAX_INT32 and o >= MAX_INT32 then
                        buf:put_byte(NUM_INT32)
                        buf:put_int32(o)
                    else
                        buf:put_byte(NUM_INT64)
                        buf:put_int64(o)
                    end
                end
            end
        elseif otype == "table" then
            serializeArray(o, buf)
        else
            error("Unknown object type: "..otype)
        end
    end
end

local function deserializeArray(buf)
    local len = buf:get_uint32()

    local arr = { }

    for i = 1, len do
        local id = buf:get_byte()
        local o

        if id == STR then
            o = buf:get_string()
        elseif id == BOOL then
            o = buf:get_bool()
        elseif id == NUM_ZERO then
            o = 0
        elseif id == NUM_BYTE then
            o = buf:get_byte()
        elseif id == NUM_UINT16 then
            o = buf:get_uint16()
        elseif id == NUM_UINT32 then
            o = buf:get_uint32()
        elseif id == NUM_INT16 then
            o = buf:get_int16()
        elseif id == NUM_INT32 then
            o = buf:get_int32()
        elseif id == NUM_INT64 then
            o = buf:get_int64()
        elseif id == NUM_DOUBLE then
            o = buf:get_double()
        elseif id == ARR then
            o = deserializeArray(buf)
        else
            error("Unknown element ID: "..id)
        end

        arr[i] = o
    end

    return arr
end

function arbd.serialize(arr, buf)
    serializeArray(arr, buf)
end

function arbd.deserialize(buf)
    buf:get_byte()

    return deserializeArray(buf)
end

return arbd