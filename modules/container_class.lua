local table_utils = require 'meownatica:table_utils'
local container = {}
local information = {}
local information_g = {}
local queue_to_save = {}

function container:send(data)
    information = table_utils:copy(data)
end

function container:get()
    if information ~= nil then
        return information
    else
        return {}
    end
end

function container:send_g(data)
    information_g = table_utils:copy(data)
end

function container:get_g()
    if information_g ~= nil then
        return information_g
    else
        return {}
    end
end

function container:send_to_save(data)
    queue_to_save = table_utils:copy(data)
end

function container:get_to_save()
    if queue_to_save ~= nil then
        return queue_to_save
    else
        return {}
    end
end

return container