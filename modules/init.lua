-- Инициализацию конфига
do
    local path = pack.shared_file("meownatica", "config.toml")
    if not file.exists(path) then
        file.write(path, file.read("meownatica:default_data/config.toml"))
    end

    CONFIG = toml.parse(file.read(path))
end