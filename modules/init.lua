-- Инициализация конфига
do
    local path = pack.shared_file("meownatica", "config.toml")
    if not file.exists(path) then
        file.write(path, file.read("meownatica:default_data/config.toml"))
    end

    MEOW_CONFIG = toml.parse(file.read(path))
end

-- Инициализация папки экспорта
do
    local path = BLUEPRINT_SAVE_PATH

    if not file.exists(path) then
        file.mkdir(path)
    end
end

--Инициализация списка предметов
for i=0, item.defs_count()-1 do
    COMMON_GLOBALS.ITEMS_AVAILABLE[item.name(i)] = true
end

require "cmd"