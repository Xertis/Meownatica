local string_utils = {}

function string_utils.string2value(str)
    if str == "true" or str == "false" then
        return str == "true"
    elseif tonumber(str) ~= nil then
        return tonumber(str)
    else
        return str
    end
end

return string_utils