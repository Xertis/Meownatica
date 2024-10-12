local module = {}

function module.get_items()
    local available_ids = {}
    local packs = item.defs_count()
    for i = 0, packs do
        available_ids[#available_ids + 1] = item.name(i)
    end
    return available_ids
end

function module.get_blocks()
    local available_ids = {}
    local packs = block.defs_count()
    for i = 0, packs do
        available_ids[#available_ids + 1] = block.name(i)
    end
    return available_ids
end

return module