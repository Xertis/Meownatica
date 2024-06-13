local table_utils = require 'meownatica:tools/table_utils'
local container = {}

local new_container = {
    local_schem  = {},
    global_schem = {},

}

function container.send(data)
    new_container.local_schem = table_utils.copy(data)
end

function container.get()
    return new_container.local_schem
end

function container.send_g(data)
    new_container.global_schem = table_utils.copy(data)
end

function container.get_g()
    return new_container.global_schem
end

function container.load()
    return new_container
end

return container