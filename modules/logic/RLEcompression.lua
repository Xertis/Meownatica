local RLE = {}
local table_utils = require 'meownatica:tools/table_utils'

function RLE:encode_modify(data)
    local encodedTable = {}
    local count = 1
    local lastValue = nil
    local tempValue = {}
    
    for _, value in ipairs(data) do
        if value == lastValue then
            count = count + 1
        else
            if lastValue and count > 2 then
                table.insert(encodedTable, {count})
                table.insert(encodedTable, lastValue)
            elseif lastValue and count <= 2 then
                for _, v in ipairs(tempValue) do
                    table.insert(encodedTable, v)
                end
            end
            count = 1
            lastValue = value
            tempValue = {}
        end
        table.insert(tempValue, value)
    end
    
    if count > 2 then
        table.insert(encodedTable, {count})
        table.insert(encodedTable, lastValue)
    else
        for _, v in ipairs(tempValue) do
            table.insert(encodedTable, v)
        end
    end
    
    return encodedTable
end

function RLE:decode_modify(data)
    local decodedTable = {}
    local len_data = #data
    for i = 1, len_data do
        local val = data[i]
        local valType = type(val)
        if valType ~= 'table' then
            table.insert(decodedTable, val)
        else
            for j = 1, val[1] - 1 do
                table.insert(decodedTable, data[i+1])
            end
        end
    end
    return decodedTable
end

function RLE:encode(data)
    local encodedTable = {}
    local count = 1
    local lastValue = nil
    
    for _, value in ipairs(data) do
        if value == lastValue then
            count = count + 1
        else
            if lastValue then
                table.insert(encodedTable, count)
                table.insert(encodedTable, lastValue)
            end
            
            count = 1
            lastValue = value
        end
    end
    
    table.insert(encodedTable, count)
    table.insert(encodedTable, lastValue)
    
    return encodedTable
end

function RLE:decode(data)
    local decodedTable = {}
    local len_data = #data
    for i = 1, len_data - 1 do
      local count, value = 0, 0
        if i % 2 == 0 then
          ount = data[i-1]
          value = data[i]
        else
          count = data[i]
          value = data[i+1]
        end
        
        for i = 1, count do
            table.insert(decodedTable, value)
        end
    end
    
    return decodedTable
end

function RLE:encode_table(data)
    local encodedTable = {}
    local count = 1
    local lastValue = {1}
    local tempValue = {}

    for _, value in ipairs(data) do
        if table_utils:equals(value, lastValue) then
            count = count + 1
        else
            if lastValue and count > 2 then
                table.insert(encodedTable, {{count}})
                table.insert(encodedTable, lastValue)
            elseif lastValue and count <= 2 then
                for _, v in ipairs(tempValue) do
                    table.insert(encodedTable, v)
                end
            end
            count = 1
            lastValue = value
            tempValue = {}
        end
        table.insert(tempValue, value)
    end

    if count > 2 then
        table.insert(encodedTable, {count})
        table.insert(encodedTable, lastValue)
    else
        for _, v in ipairs(tempValue) do
            table.insert(encodedTable, v)
        end
    end

    return encodedTable
end

function RLE:decode_table(data)
    local decodedTable = {}
    local len_data = #data
    for i = 1, len_data do
        local val = data[i]
        local valType = type(val[1])
        if valType ~= 'table' then
            table.insert(decodedTable, val)
        else
            for j = 1, val[1][1] - 1 do
                table.insert(decodedTable, data[i+1])
            end
        end
    end
    return decodedTable
end

return RLE