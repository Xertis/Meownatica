-- Инициализация конфига
do
    local path = pack.shared_file("meownatica", "config.toml")
    if not file.exists(path) then
        file.write(path, file.read("meownatica:default_data/config.toml"))
    end

    CONFIG = toml.parse(file.read(path))
end

-- Инициализация папки экспорта
do
    local path = BLUEPRINT_SAVE_PATH

    if not file.exists(path) then
        file.mkdir(path)
    end
end

require "cmd"