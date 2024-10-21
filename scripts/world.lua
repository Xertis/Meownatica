local data_meow = require 'meownatica:files/metadata_class'
local reader = require 'meownatica:tools/read_toml'
require 'meownatica:frontend/cmd'

function on_world_open()
    if file.exists(reader.sys_get('savepath')) == false then
        file.mkdir(reader.sys_get('savepath'))
    end
    data_meow.open_metadata()
end

function on_world_save()
    data_meow.save_metadata()
end