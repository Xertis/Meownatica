local mbp_versions = {}

for _, f in pairs(file.list("meownatica:modules/files/mbp_versions/")) do
    local module_name = f:gsub("modules/", "")
    module_name = module_name:gsub("%.lua$", "")
    module_name = module_name:gsub("//", "/")

    mbp_versions[tonumber(module_name:match("([^/]+)$"))] = require(module_name)
end


local module = {}

function module.serialize(buf, array, meta)
    return mbp_versions[#mbp_versions].serialize(buf, array, meta)
end

function module.deserialize(buf)
    local version = buf:get_uint16()
    buf:set_position(1)
    return mbp_versions[version].deserialize(buf)
end

function module.get_version(buf)
    local version = buf:get_uint16()
    buf:set_position(1)
    return version
end

return module