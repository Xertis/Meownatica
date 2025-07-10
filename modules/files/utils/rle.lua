local module = {}

function module.compress(blocks)
    local res = {}
    local last = nil
    local count = 0

    for _, block in ipairs(blocks) do
        if not last then
            last = block
        end

        if block.id == last.id and block.states == last.states then
            count = count + 1
        else
            if count > 1 then
                table.insert(res, count)
            end
            table.insert(res, last)

            last = block
            count = 1
        end
    end

    if count > 1 then
        table.insert(res, count)
    end
    table.insert(res, last)

    return res
end

function module.decompress(blocks)
    local res = {}

    for i=1, #blocks do
        local block = blocks[i]
        local prev_block = blocks[i-1]

        if type(block) == "number" then
            i = i + 1
            utils.table.rep(res, blocks[i], block)
        elseif prev_block == nil or type(prev_block) == "table" then
            table.insert(res, block)
        end
    end

    return res
end

return module