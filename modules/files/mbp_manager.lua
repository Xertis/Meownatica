local toml = require 'meownatica:tools/read_toml'
local data_buffer = require "core:data_buffer"
local mbp_versions = {}
local FORMAT = toml.sys_get('fileformat')

for _, f in pairs(file.list("meownatica:modules/files/mbp_versions/")) do
    local module_name = f:gsub("modules/", "")
    module_name = module_name:gsub("%.lua$", "")
    module_name = module_name:gsub("//", "/")

    mbp_versions[tonumber(module_name:match("([^/]+)$"))] = require(module_name)
end


local module = {}

function module.serialize(buf, array, meta, version)
    local version = version or #mbp_versions
    return mbp_versions[version].serialize(buf, array, meta)
end

function module.deserialize(buf)
    local version = buf:get_uint16()
    buf:set_position(1)
    return mbp_versions[version].deserialize(buf)
end

function module.get_format(name)
    return string.match(name, "(%.%w+)$")
end

function module.check_format(name)
    if module.get_format(name)  == FORMAT then
        return true
    end
    return false
end


function module.get_version(buf)
    local version = nil

    local function a(buff)
        version = buff:get_uint16()
        buff:set_position(1)
    end

    if type(buf) ~= 'string' then
        a(buf)
    else
        local path = toml.sys_get('savepath') .. buf
        a(data_buffer(file.read_bytes(path)))
    end

    local max_version = #mbp_versions
    return version, max_version
end

return module