local module = {}

function module.ToByte(tbl)
    local byte = 0
    for i = 1, 4 do
        byte = byte + tbl[i] * 4^(i - 1)
    end
    return byte
end

function module.ToTable(byte)
    local tbl = {}
    for i = 4, 1, -1 do
        tbl[i] = math.floor(byte / 4^(i - 1))
        byte = byte % 4^(i - 1)
    end
    return tbl
end

return module