function on_placed(x, y, z)
    local blue_print = CURRENT_BLUEPRINT

    if blue_print then
        blue_print:build({x, y, z})
    end

    return true
end