function set_page(page)
    document.meownatics.enabled = true
    document.config.enabled = true
    document[page].enabled = false
    document.menu.page = page
end