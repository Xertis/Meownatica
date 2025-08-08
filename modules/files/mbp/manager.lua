local bit_buffer = require "files/buffer/bit_buffer"

local PARSERS = {
    mbp = true
}

local mbp_v1 = require "files/mbp/versions/v1"
local manager = {
    versions = {mbp_v1},
    utils = {}
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

function manager.write_mbp(path, blueprint)
    local buf = manager.versions[#manager.versions].serialize(blueprint)
    file.write_bytes(path, buf.bytes)
end

function manager.has_parser(parser)
    return PARSERS[parser] ~= nil
end

local function preparation_mbp(properties, blueprint)
    local path = string.format("%s/%s.mbp", BLUEPRINT_SAVE_PATH, properties.name)

    if properties.centering then
        local center = blueprint:get_center_pos()
        blueprint:move_origin(center)
    end

    blueprint:rotate({properties.rotation_x, properties.rotation_y, properties.rotation_z})

    blueprint.author = properties.author
    blueprint.description = properties.description
    blueprint.image_path = properties.image_path
    blueprint.tags = properties.tags

    manager.write_mbp(path, blueprint)
end

function manager.utils.easy_write(properties, blueprint)
    local extension = properties.extension
    if extension == "mbp" then
        preparation_mbp(properties, blueprint)
    end
end

return manager