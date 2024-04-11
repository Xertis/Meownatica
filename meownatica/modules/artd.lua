-- ARTD (Array Text Document) File format implementation for Lua
-- Creator: Onran

local STR = "&"
local NUM = "%"
local BOOL = "!"
local ARR = "#"

local function char_at(str, index)
    return string.sub(str, index, index)
end

local function is_starts_with(str1, str2)
    local strlen, str2len = string.len(str1), string.len(str2)

    if strlen < str2len then
        return false
    else
        for i = 1, str2len do
            if char_at(str1, i) ~= char_at(str2, i) then
                return false
            end
        end

        return true
    end
end

local function deserialize_array(index, lines, strictParse)
    local array = { }

    local length = tonumber(string.sub(lines[index], 2))

    for i = 1, length do
        index = index + 1

        local value = nil
        local str = lines[index]
        local rawValue = string.sub(str, 2)
        local prefix = char_at(str, 1)

        if prefix == STR then
            value = rawValue
        elseif prefix == BOOL then
            if strictParse then
                if rawValue == "1" then
                    value = true
                elseif rawValue == "0" then
                    value = false
                else
                    error("Invalid boolean value: "..rawvalue.." at line "..index)
                end
            else
                value = rawValue == "1"
            end
        elseif prefix == NUM then
            value = tonumber(rawValue)
        elseif prefix == ARR then
            value, index = deserialize_array(index, lines, strictParse)
        elseif strictParse then
            error("Invalid prefix "..prefix.." at line "..index)
        end

        array[i] = value
    end
    return array, index
end

local function serialize_array(arr)
    local len = #arr
    local result = "#"..len

    for i = 1, len do
        local e = arr[i]
        local etype = type(arr[i])

        result = result.."\n"

        if etype == "number" then
            result = result..NUM..e
        elseif etype == "boolean" then
            result = result..BOOL..(e and 1 or 0)
        elseif etype == "string" then
            result = result..STR..e
        elseif etype == "table" then
            result = result..serialize_array(e)
        end
    end

    return result
end

local artd = { }

function artd.serialize(arr)
    if arr == nil or type(arr) ~= "table" then
        error("Invalid array")
    end

    return serialize_array(arr)
end

function artd.deserialize(arg, strictParse)
    if strictParse == nil then
        strictParse = true
    end

    local lines
    local argtype = type(arg)

    if argtype == "string" then
        lines = { }

        for line in string.gmatch(arg, "[^\n]+") do
            line = string.gsub(line, "%s+", "")
            table.insert(lines, line)
        end
    elseif argtype == "table" then
        lines = arg
    else
        error("Invalid argument type: "..argtype)
    end

    if strictParse and #lines <= 0 then
        error("Invalid ARTD")
    end

    if strictParse and not is_starts_with(lines[1], ARR) then
        error("Invalid ARTD")
    end

    local doc, _ = deserialize_array(1, lines, strictParse)

    return doc
end

return artd