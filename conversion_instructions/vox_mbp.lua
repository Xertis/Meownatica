local sv = require 'meownatica:tools/save_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local toml = require 'meownatica:tools/read_toml'
local RLE = require 'meownatica:logic/RLEcompression'
local fragment = require 'meownatica:files/fragment_saver'
local tblu = require 'meownatica:tools/table_utils'

local function conv(originalArray, DepthX, DepthY, DepthZ)
    local newArray = {}

    for x = 1, DepthX do
        for y = 1, DepthY do
            for z = 1, DepthZ do
                local originalIndex = (y - 1) * (DepthX * DepthZ) + (x - 1) * DepthZ + z
                table.insert(newArray, originalArray[originalIndex])
            end
        end
    end
    return newArray
end

local convert_base = {}
function convert_base.convert(path)
    local name_format = path:match(".+/(.+)")
    local name = name_format:gsub("%.vox$", "")
    local schem = bjson.frombytes(file.read_bytes(path))

    local block_names = schem['block-names']
    local depth = schem['size']
    local bs = schem['voxels']
    local blocks = {}

    depth = {depth[1] - 1, depth[2] - 1, depth[3] - 1, 1}

    if tblu.get_index(block_names, "core:struct_air") then
        block_names[tblu.get_index(block_names, "core:struct_air")] = 'core:air'
    end

    for i=1, #bs do
        if i % 2 == 0 then
            table.insert(blocks, {bs[i-1]+1, bs[i], true})
        end
    end

    blocks = conv(blocks, depth[1]+1, depth[2]+1, depth[3]+1)
    local meownatic = {0, block_names, depth, RLE.encode_table(blocks), {}}
    sv.write(meownatic, {description = "Converted"}, toml.sys_get('savepath') .. name .. '.mbp')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.mbp'})
    return true
end

return convert_base