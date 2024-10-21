local module = {}

function module.split_path(path)
    local result = {}
    local current_path = ""

    for part in string.gmatch(path, "([^/]+)") do
        if current_path == "" then
            current_path = part
        else
            current_path = current_path .. part
        end

        if part ~= path:match("[^/]+$") then
            current_path = current_path .. "/"
        end
        table.insert(result, current_path)
    end

    return result
end

function module.exists_path(path)
    local paths = module.split_path(path)
    for _, path in ipairs(paths) do
        if file.exists(path) == false then
            return false
        end
    end
    return true
end

function module.is_dir(path)
    path = path:match("^%s*(.-)%s*$")

    return path:sub(-1) == "/"
end

function module.path_create(path)
    local paths = module.split_path(path)
    for _, path in ipairs(paths) do
        if file.exists(path) == false and module.is_dir(path) then
            file.mkdir(path)
        end
    end
end

return module