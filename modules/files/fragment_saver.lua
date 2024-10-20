local module = {}
local meow_change = require 'meownatica:schematics_editors/change_schem'
local RLE = require 'meownatica:logic/RLEcompression'
local tblu = require 'meownatica:tools/table_utils'

local function reverse_to_vox(originalArray, DepthX, DepthY, DepthZ)
    local newArray = {}

    for y = 1, DepthY do
        for x = 1, DepthX do
            for z = 1, DepthZ do
                local newIndex = (x - 1) * (DepthY * DepthZ) + (y - 1) * DepthZ + z
                table.insert(newArray, originalArray[newIndex])
            end
        end
    end

    return newArray
end

local function convert_to_vox(blocks)
    local bs = {}
    for _, block in ipairs(blocks) do
        table.insert(bs, block[1]-1)
        table.insert(bs, block[2])
    end
    return bs
end

function module.save(name, path)
    local schem, meta = meow_change.get_schem(name, true, false)
    if schem ~= nil then
        local ids = schem[2]
        local depth = schem[3]
        local blocks = reverse_to_vox(RLE.decode_table(schem[4]), depth[1]+1, depth[2]+1, depth[3]+1)
        blocks = convert_to_vox(blocks)

        if tblu.get_index(ids, "core:air") then
            ids[tblu.get_index(ids, "core:air")] = 'core:struct_air'
        end

        local fragment = {}
        fragment['size'] = {depth[1]+1, depth[2]+1, depth[3]+1}
        fragment['voxels'] = blocks
        fragment['block-names'] = ids
        fragment['version'] = 1

        file.write_bytes(path, bjson.tobytes(fragment))
        return true
    end
end

return module