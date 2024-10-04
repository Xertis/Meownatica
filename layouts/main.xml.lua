local save_u = require 'meownatica:tools/save_utils'

function set_page(page)
    document.meownatics.enabled = true
    document.config.enabled = true
    document[page].enabled = false
    document.menu.page = page
end

function saving()
    save_u.save(nil, document.schem_description.text, document.schem_name.text)
end