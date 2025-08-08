local manager = require "files/mbp/manager"

function on_open()
    local options = table.deep_copy(FILE_EXTENSIONS)

    for _, option in ipairs(options) do
        option.text = option.text
    end

    document.extensions.options = options
    document.extensions.value = "mbp"
    select_extension("mbp")

    for _, tag in ipairs(TAGS) do
        document.tags:add(string.format(
            '<checkbox id="tag_%s">@%s</checkbox>',
            tag.id, tag.text
        ))
    end
end

function axis_x(value)
    document["text_axis_x"].text = tostring(value)
end

function axis_y(value)
    document["text_axis_y"].text = tostring(value)
end

function axis_z(value)
    document["text_axis_z"].text = tostring(value)
end

---

function axis_x_text(value)
    if not axis_validator(value) then return end
    document["track_axis_x"].value = tonumber(value)
end

function axis_y_text(value)
    if not axis_validator(value) then return end
    document["track_axis_y"].value = tonumber(value)
end

function axis_z_text(value)
    if not axis_validator(value) then return end
    document["track_axis_z"].value = tonumber(value)
end

function axis_validator(text)
    if #text > 4 then
        return false
    end

    local status, res = pcall(tonumber, text)
    if not status or not res then
        return false
    end

    local number = tonumber(text)
    if number > 360 or number < 0 then
        return false
    end

    return true
end

local prev_ext = nil
function select_extension(ext)
    if not manager.has_parser(ext) then
        gui.alert("Этот формат экспортирования на данный момент недоступен")
        document.extensions.value = prev_ext
        return
    end

    prev_ext = ext

    if table.has(HALF_EXTENSIONS, ext) then
        document.author.enabled = false
        document.description.enabled = false
        document.path.enabled = false
        document.tags.enabled = false
        document.rotation.enabled = false
    else
        document.author.enabled = true
        document.description.enabled = true
        document.path.enabled = true
        document.tags.enabled = true
        document.rotation.enabled = true
    end
end

function export()
    local index = CURRENT_BLUEPRINT.id
    local blueprint = BLUEPRINTS[index]

    if not blueprint then
        gui.alert("Схема не выбрана")
        return
    end

    local name = document.file_name.text
    local extension = document.extensions.value
    local author = document.author.text
    local description = document.description.text
    local image_path = document.path.text
    local tags = {}

    for _, tag in ipairs(TAGS) do
        if document["tag_" .. tag.id].checked then
            table.insert(tags, tag.id)
        end
    end

    local centering = document.centering.checked
    local rotation_x = document.track_axis_x.value
    local rotation_y = document.track_axis_y.value
    local rotation_z = document.track_axis_z.value

    local properties = {
        name = name,
        extension = extension,
        author = author,
        description = description,
        image_path = image_path,
        tags = tags,
        centering = centering,
        rotation_x = rotation_x,
        rotation_y = rotation_y,
        rotation_z = rotation_z
    }

    manager.utils.easy_write(properties, blueprint)
end