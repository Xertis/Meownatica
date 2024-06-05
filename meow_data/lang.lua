local reader = require 'meownatica:tools/read_toml'

local lang = {}
local texts = {}

texts['Save Meownatic'] = {'[MEOWNATICA] save meownatic...', '[MEOWNATICA] сохранение мяунатика...'}
texts['Local is finish'] = {'[MEOWNATICA:Local schem] The construction queue is finished', '[MEOWNATICA:Local schem] Очередь на постройку схем завершена'}
texts['Global is finish'] = {'[MEOWNATICA:Global schem] The construction queue is finished', '[MEOWNATICA:Global schem] Очередь на постройку схем завершена'}
texts['not mods'] = {'[MEOWNATICA] Meownatic is inserted incorrectly, install the following ContentPack to insert it correctly:', '[MEOWNATICA] Мяунатик построен неправильно, установите перечисленнные ниже моды чтобы вставить схему правильно'}
texts['not found'] = {'does not exist', 'не найден'}
texts['block'] = {'Block:', 'Блок:'}
texts['is converted'] = {'[MEOWNATICA] Meownatic is converted', '[MEOWNATICA] Мяунатик сконвертирован'}
texts['was deleted'] = {'was deleted', 'был удалён'}
texts['meownatic'] = {'meownatic', 'мяунатика'}
texts['was added'] = {'has been added', 'был добавлен'}
texts['meownatics in the config'] = {'meownatics in the config:', 'мяунатики в конфиге:'}
texts['config parameters'] = {'config parameters:', 'значения конфига:'}
texts['count'] = {'count:', 'кол-во:'}
texts['schem_all_console'] = {'Displays all loaded meownatics', 'Выводит все загруженные мяунатики'}
texts['config_all_console'] = {'Displays all config parameters', 'Выводит все параметры конфига'}
texts['materials_console'] = {'Displays the materials of the meownatic', 'Выводит все материалы, нужные для постройки мяунатика'}
texts['addschem_console'] = {'Load meownatic', 'Загрузить мяунатик'}
texts['delschem_console'] = {'Delete meownatic', 'Удалить мяунатик'}
texts['materials'] = {'Materials:', 'Материалы:'}
texts['setconfig_console'] = {'Changes the value of the parameter in the config to a new one', 'Меняет значение параметра в конфиге на новое'}

function lang.get(key)
    local language = reader.get('language')
    if language == 'rus' then
        return texts[key][2]
    else
        return texts[key][1]
    end
end

return lang