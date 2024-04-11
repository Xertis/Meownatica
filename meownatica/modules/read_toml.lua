local reader = {}
local toml = require "core:toml"

function reader:get(parameter)
    local parameter = string.lower(parameter)
    return toml.deserialize(file.read('meownatica:meow_config.toml'))[parameter] 
end

function reader:get_all()
    local parameters = {}
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    for idx, value in pairs(tbl) do
        table.insert(parameters, {id = idx, value = value})
    end
    return parameters
end

function reader:schem(indx)
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    tbl = tbl['meownatics']
    return tbl['source' .. indx]
end

function reader:indx_is_real(indx, config)
    local indx = string.lower(indx)
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    if config == nil then
        tbl = tbl['meownatics']
    end
    if tbl[indx] ~= nil then
        return true
    else
        return false
    end
end

function reader:len()
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    tbl = tbl['meownatics']
    local i = 0
    for idx, value in pairs(tbl) do
        i = i + 1
    end
    return i
end

function reader:all_schem()
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    tbl = tbl['meownatics']
    local text = ''
    for idx, value in pairs(tbl) do
        text = text .. value .. '\n'
    end
    return text
end

function reader:find(text)
    local tbl = toml.deserialize(file.read('meownatica:meow_config.toml'))
    tbl = tbl['meownatics']
    for idx, value in pairs(tbl) do
        if tbl[idx] == text then
            return tbl[idx], idx
        end
    end
end

function reader:ci_get(indx)
    local tbl = toml.deserialize(file.read('meownatica:conversion_instructions/conversion_instructions.toml'))
    tbl = tbl['conversion_instructions']
    return tbl['instruction' .. indx]
end

function reader:ci_len()
    local tbl = toml.deserialize(file.read('meownatica:conversion_instructions/conversion_instructions.toml'))
    tbl = tbl['conversion_instructions']
    local i = 0
    for idx, value in pairs(tbl) do
        i = i + 1
    end
    return i
end

return reader