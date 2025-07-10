local bit_buffer = require "files/buffer/bit_buffer"

local mbp_v1 = require "files/mbp/versions/v1"
local manager = {
    versions = {mbp_v1}
}

function manager.read(path)
    local bytes = file.read_bytes(path)

    local buf = bit_buffer:new(bytes)

    local is_mbp = buf:get_string()

    if is_mbp ~= "MBP" then
        error("Неправильный файл .mbp")
    end

    local version = buf:get_uint16()

    if not manager.versions[version] then
        error("Неподдерживаемая версия")
    end

    local blueprint = manager.versions[version].deserialize(bytes)

    blueprint.name = file.name(path)

    return blueprint
end

function manager.write(path, blueprint)
    local buf = manager.versions[#manager.versions].serialize(blueprint)
    file.write_bytes(path, buf.bytes)
end

return manager