local module = {}

function module.rot2Bytes(bits)
    local byte1, byte2 = 0, 0

    for i = 1, 8 do
        byte1 = byte1 + bits[i] * 2^(8 - i)
    end

    for i = 9, 16 do
        byte2 = byte2 + bits[i] * 2^(16 - i)
    end

    return byte1, byte2
end

function module.bytes2Rot(byte1, byte2)
    local bits = {}

    for i = 7, 0, -1 do
        table.insert(bits, bit.band(bit.rshift(byte1, i), 1))
    end

    for i = 7, 0, -1 do
        table.insert(bits, bit.band(bit.rshift(byte2, i), 1))
    end

    return bits
end

return module