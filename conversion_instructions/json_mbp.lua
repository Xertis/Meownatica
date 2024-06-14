local json = require 'meownatica:tools/json_reader'
local sv = require 'meownatica:tools/save_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local toml = require 'meownatica:tools/read_toml'

local convert_base = {}
function convert_base:convert(path)
    local name_format = path:match(".+/(.+)")
    local name = name_format:gsub("%.json$", "")

    local res = json.decode(file.read(path))

    sv.write(res, toml.sys_get('savepath') .. name .. '.mbp')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.mbp'})
end

return convert_base