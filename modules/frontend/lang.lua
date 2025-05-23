local reader = require 'meownatica:tools/read_toml'
local json = require 'meownatica:tools/json_reader'

local lang = {}
local texts = json.decode(file.read('meownatica:meow_data/lang.json'))

function lang.get(key)
    local language = reader.get('language')
    if language == 'rus' then
        return texts[key][2]
    else
        return texts[key][1]
    end
end

return lang