local string_utils = {}

function string_utils.string2value(str)
    if str == "true" then
        return true
    elseif str == "false" then
        return false
    elseif tonumber(str) ~= nil then
        return tonumber(str)
    else
        return str
    end
end

return string_utils