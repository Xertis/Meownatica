data_meow = require 'meownatica:metadata_class'

function on_world_open()
    data_meow:open_metadata()
end

function on_world_save()
    data_meow:save_metadata()
end