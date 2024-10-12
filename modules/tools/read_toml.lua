local reader = {}

local function load_toml()
    return toml.parse(file.read('meownatica:meow_config.toml'))
end

function reader.get(parameter)
    local parameter = string.lower(parameter)
    return load_toml()[parameter]
end

--Возвращает названия всех схем из конфига 
--In: nil
--Out: {"example.mbp"}
function reader.get_all_schem()
    local tbl = load_toml()
    local parameters = {}
    for idx, value in pairs(tbl['meownatics']) do
        table.insert(parameters, value)
    end
    return parameters
end

--Возвращает схему по индексу
--In: 1
--Out: "example.mbp"
function reader.schem(indx)
    local tbl = load_toml()
    tbl = tbl['meownatics']
    return tbl['source' .. indx]
end

--Возвращает длинну по индексу
--In: "meownatics"
--Out: 5
function reader.len(key)
    local tbl = reader.get(key)
    local i = 0
    for _, _ in pairs(tbl) do
        i = i + 1
    end
    return i
end

--Возвращает все параметры в виде строки
--In: nil
--Out: мне лень писать
function reader.all_parameters()
    local tbl = load_toml()
    local text = ''
    for idx, value in pairs(tbl) do
        if idx ~= 'meownatics' then
            text = text .. idx .. ' = ' .. tostring(value) .. '\n'
        end
    end
    return text
end

--Возвращает все схемы в виде строки
--In: nil
--Out: мне лень писать
function reader.all_schem()
    local tbl = load_toml()
    tbl = tbl['meownatics']
    local text = ''
    local i = 1
    for idx, value in pairs(tbl) do
        text = text .. i .. '.\t' .. value .. '\n'
        i = i + 1
    end
    return text
end

--Возвращает значение и индекс элемента, если находит его
--In: значение
--Out: значение, индекс
function reader.find(source)
    local tbl = load_toml()['meownatics']
    for idx, _ in pairs(tbl) do
        if tbl[idx] == source then
            return source, idx
        end
    end
end

function reader.ci_get(indx)
    local tbl = toml.parse(file.read('meownatica:conversion_instructions/conversion_instructions.toml'))
    tbl = tbl['conversion_instructions']
    return tbl['instruction' .. indx]
end

function reader.sys()
    local tbl = toml.parse(file.read('meownatica:meow_data/sys_config.toml'))
    return tbl
end

function reader.sys_get(key)
    local tbl = toml.parse(file.read('meownatica:meow_data/sys_config.toml'))
    return tbl[key]
end

function reader.ci_len()
    local tbl = toml.parse(file.read('meownatica:conversion_instructions/conversion_instructions.toml'))
    tbl = tbl['conversion_instructions']
    local i = 0
    for idx, value in pairs(tbl) do
        i = i + 1
    end
    return i
end

return reader