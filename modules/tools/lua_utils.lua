local module = {}

function module.when(values)
    for _, v in ipairs(values) do
        if v[1] then
            return v[2]()
        end
    end
end

return module