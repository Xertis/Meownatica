local module = {}

function module.encode(tbl)
    local result = 0
    for i = 1, #tbl do
        if tbl[i] < 0 then
            result = result + 2^(i-1)
        end
    end
    return result
end

function module.decode(num, len)
    local tbl = {}
    for i = 1, len do
        if num % 2 == 1 then
            tbl[i] = -1
        else
            tbl[i] = 1
        end
        num = math.floor(num / 2)
    end
    return tbl
end

function module.parse(signs, tbl)
    for i=1, #tbl do
        if signs[i] > 0 then
            tbl[i] = math.abs(tbl[i])
        elseif tbl[i] > 0 then
            tbl[i] = -tbl[i]
        end
    end
    return tbl
end

return module