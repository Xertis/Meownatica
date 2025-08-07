function on_open()
    local options = table.deep_copy(FILE_EXTENSIONS)

    for _, option in ipairs(options) do
        option.text = option.text
    end

    document.extensions.options = options
    document.extensions.value = "mbp"
end