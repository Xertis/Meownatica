local mbp = require "files/mbp/manager"

console.add_command(
    "m.schem.folder",
    "Выводит лист доступных схем",
    function ()
        local files = file.list(BLUEPRINT_SAVE_PATH)
        local res = "Доступные схемы:\n"
        local indx = 1
        for _, blueprint in ipairs(files) do
            if string.ends_with(blueprint, ".mbp") then
                res = res .. string.format("%s. %s\n", indx, file.name(blueprint))
                indx = indx + 1
            end
        end

        return res
    end
)

console.add_command(
    "m.schem.list",
    "Выводит лист загруженных схем",
    function ()
        local res = "Загруженные схемы:\n"
        for indx, blueprint in ipairs(BLUEPRINTS) do
            res = res .. string.format("%s. %s\n", indx, blueprint.name)
        end

        return res
    end
)

console.add_command(
    "m.schem.load path:str",
    "Загружает выбранную схему",
    function (args)
        local path = string.format("%s/%s", BLUEPRINT_SAVE_PATH, args[1])

        local status, blueprint = pcall(mbp.read, path)

        if not status or not blueprint then
            return "Ошибка при чтении файла"
        end

        table.insert(BLUEPRINTS, blueprint)

        return "Схема загружена в память"
    end
)

console.add_command(
    "m.schem.set index:int",
    "Выбрать схему",
    function (args)
        if BLUEPRINTS[args[1]] ~= nil then
            utils.blueprint.change(args[1])
            return "Схема выбрана"
        else
            return "Схемы с таким индексом не существует"
        end
    end
)

console.add_command(
    "m.schem.cur",
    "Выводит выбранную схему",
    function ()
        local index = CURRENT_BLUEPRINT.id
        local blueprint = BLUEPRINTS[index]

        if blueprint then
            return string.format("Имя: %s\nИндекс: %s", blueprint.name, index)
        else
            return "Схема не выбрана"
        end
    end
)

console.add_command(
    "m.schem.save path:str index:int",
    "Сохраняет выбранную схему",
    function (args)
        local path = string.format("%s/%s", BLUEPRINT_SAVE_PATH, args[1])

        local status, _ = pcall(mbp.write, path, BLUEPRINTS[args[2]])

        if not status then
            return "Ошибка при записи файла"
        end

        return "Схема сохранена"
    end
)

console.add_command(
    "m.schem.place",
    "Устанавливает выбранную схему",
    function (args)
        local x, y, z = unpack(CURRENT_BLUEPRINT.preview_pos)

        if not x then
            return "Превью не установлено"
        end

        local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

        if blue_print then
            blue_print:build({x, y, z})
            CURRENT_BLUEPRINT.preview_pos = {}
            return "Схема установлена"
        else
            return "Схема не загружена"
        end
    end
)

console.add_command(
    "m.schem.preview x:int~pos.x y:int~pos.y z:int~pos.z",
    "Устанавливает превью выбранной схемы",
    function (args)
        local x, y, z = math.floor(args[1]), math.floor(args[2]), math.floor(args[3])

        local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

        if blue_print then
            if CURRENT_BLUEPRINT.preview_pos[1] ~= nil then
                blue_print:unbuild_preview(CURRENT_BLUEPRINT.preview_pos)
            end

            local new_preview_pos = {x, y, z}
            blue_print:build_preview(new_preview_pos)
            CURRENT_BLUEPRINT.preview_pos = new_preview_pos
            return "Схема установлена"
        else
            return "Схема не загружена"
        end
    end
)

console.add_command(
    "m.schem.rotate axis_x:int=0 axis_y:int=0 axis_z:int=0",
    "Поворачивает выбраанную схему",
    function (args)
        local rotation_vec = args

        local blue_print = BLUEPRINTS[CURRENT_BLUEPRINT.id]

        if blue_print then
            if CURRENT_BLUEPRINT.preview_pos[1] == nil then
                return "Превью не установлено"
            end

            blue_print:unbuild_preview(CURRENT_BLUEPRINT.preview_pos)
            blue_print:rotate(rotation_vec)
            blue_print:build_preview(CURRENT_BLUEPRINT.preview_pos)
            return "Схема повёрнута"
        else
            return "Схема не загружена"
        end
    end
)