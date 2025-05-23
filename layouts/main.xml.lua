function set_page(page)
    document.meownatics.enabled = true
    document.config.enabled = true
    document.saving.enabled = true
    document[page].enabled = false
    document.menu.page = page
end

function on_open()
    document.config.enabled = false
    document.meownatics.enabled = true
    document.saving.enabled = true

    document.menu.page = "config"
end