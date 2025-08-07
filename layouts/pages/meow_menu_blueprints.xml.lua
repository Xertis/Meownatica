local mbp = require "files/mbp/manager"

local Blueprints = session.get_entry("meownatica.menu.blueprints.Blueprints")
local olders_paths = session.get_entry("meownatica.menu.blueprints.olders_paths")
local olders_indexes = session.get_entry("meownatica.menu.blueprints.olders_indexes")

local blueprints_copy = table.copy(Blueprints)

function place_blueprint(info)
    document.blueprints:add(gui.template("blueprint", info))
end


local function find_blueprint(id)
    for i, blueprint in pairs(Blueprints) do
        if blueprint.id == id then
            return blueprint, i
        end
    end
end

local function load_from_files()
    local files = file.list(BLUEPRINT_SAVE_PATH)
    local next_index = table.count_pairs(Blueprints)+1
    for i, file_path in ipairs(files) do

        local name = file.stem(file_path)
        local ext = file.ext(file_path)
        local parent = file.parent(file_path)
        local new_file_path = file_path

        if olders_paths[file_path] then
            place_blueprint({
                id = olders_paths[file_path],
                name = name,
                path = new_file_path
            })
            goto continue
        end

        olders_paths[file_path] = next_index

        if ext then
            new_file_path = string.format("%s/%s.**%s**", parent, name, ext)
        end

        place_blueprint({
            id = next_index,
            name = name,
            path = new_file_path
        })

        table.insert(Blueprints, {
            id = next_index,
            name = name,
            path = file_path
        })

        next_index = next_index + 1

        ::continue::
    end
end

local function load_from_memory()
    local next_index = table.count_pairs(Blueprints)+1
    for i, blueprint in pairs(BLUEPRINTS) do
        if blueprint.loaded then
            goto continue
        end

        if olders_indexes[i] then
            place_blueprint({
                id = olders_indexes[i],
                name = blueprint.name,
                path = "in-memory"
            })
            goto continue
        end

        olders_indexes[i] = next_index

        place_blueprint({
            id = next_index,
            name = blueprint.name,
            path = "in-memory"
        })

        table.insert(Blueprints, {
            id = next_index,
            name = blueprint.name,
            path = "in-memory",
            index = i
        })

        next_index = next_index + 1

        ::continue::
    end
end

local function refresh()
    for i, blueprint in pairs(Blueprints) do
        if blueprint.index then
            document["blueprintaction_" .. blueprint.id].src = "mgui/unload"
        end

        if blueprint.index == CURRENT_BLUEPRINT.id then
            document["blueprint_" .. blueprint.id].color = {255, 255, 255, 17}
        end
    end
end

function on_open()
    local options = table.deep_copy(FILTERS)

    for _, option in ipairs(options) do
        option.text = gui.str(option.text, "meownatica")
    end

    document.filters.options = options
    document.filters.value = "all"

    load_from_files()
    load_from_memory()
    refresh()
end

function position_func(blueprint_id)
    local INTERVAL = 8
    local STEP = 0
    local SIZE = 34

    local index = 1
    for i, blueprint in ipairs(blueprints_copy) do
        if blueprint.id == blueprint_id then
            index = i
        end
    end

    local indx = index - 1
    local pos = {0, (SIZE + INTERVAL) * indx + STEP}

    return pos[1], pos[2]
end

function search(text)
    text = text or document.search.text
    blueprints_copy = table.copy(Blueprints)
    local search_text = text:lower()

    if #search_text ~= 0 then
        local function score(blueprint_name)
            if blueprint_name:lower():find(search_text) then
                return 1
            end
            return 0
        end

        local function sorting(a, b)
            local score_a = score(a.name)
            local score_b = score(b.name)


            if score_a ~= score_b then
                return score_a > score_b
            end

            return a.name < b.name
        end

        table.sort(blueprints_copy, sorting)
    end

    for _, blueprint in ipairs(blueprints_copy) do
        document["blueprint_" .. blueprint.id]:reposition()
    end
end

function select(id)
    local blueprint = find_blueprint(id)
    if not blueprint.index then
        gui.alert("Схема не загружена, загрузите схему прежде чем её выбирать")
        return
    end

    local prev_id = CURRENT_BLUEPRINT.id
    if prev_id ~= 0 then
        for _, other in ipairs(Blueprints) do
            if other.index == prev_id then
                document["blueprint_" .. other.id].color = {0, 0, 0, 64}
            end
        end
    end

    document["blueprint_" .. id].color = {255, 255, 255, 17}
    utils.blueprint.change(blueprint.index)
    gui.alert(string.format('Схема "%s" успешно выбрана', blueprint.name))
end

function load_blueprint(path)
    local status, blueprint = pcall(mbp.read, path)

    if not status or not blueprint then
        return false, blueprint
    end

    table.insert(BLUEPRINTS, blueprint)
    return true, #BLUEPRINTS
end

function action(id)
    local icon = document["blueprintaction_" .. id]
    local blueprint = find_blueprint(id)

    if icon.src == "mgui/load" then
        local status, error_or_index = load_blueprint(blueprint.path)
        if status then
            icon.src = "mgui/unload"
            blueprint.index = error_or_index
        else
            gui.alert("Не удалось загрузить схему\nОшибка:" .. tostring(error_or_index))
        end
    else
        icon.src = "mgui/load"
        document["blueprint_" .. id].color = {0, 0, 0, 64}
        if not BLUEPRINTS[blueprint.index].loaded then
            local _, id_in_tbl = find_blueprint(id)

            table.remove(Blueprints, id_in_tbl)
            document["blueprint_" .. id]:destruct()

            olders_indexes[blueprint.index] = nil

            search()
        end

        if blueprint.index then
            BLUEPRINTS[blueprint.index] = nil
        end
    end
end