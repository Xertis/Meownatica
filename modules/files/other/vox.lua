local BluePrint = require "blueprint/blueprint"

local module = {}

local function convert_to_vox(blocks)
    local bs = {}
    for _, block in ipairs(blocks) do
        table.insert(bs, block.id)
        table.insert(bs, block.states)
    end
    return bs
end

local function convert_to_mbp(blocks)
    local bs = {}
    for i=1, #blocks, 2 do
        table.insert(bs, {
            id = blocks[i],
            states = blocks[i+1]
        })
    end
    return bs
end

local function reorder_blocks(blocks, size)
    local newBlocks = {}
    local sizeX, sizeY, sizeZ = unpack(size)
    local total = sizeX * sizeY * sizeZ

    for oldIndex = 1, total do
        local i = oldIndex - 1
        local y = math.floor(i / (sizeZ * sizeX))
        local z = math.floor((i % (sizeZ * sizeX)) / sizeX)
        local x = i % sizeX

        local newIndex = x * (sizeY * sizeZ) + y * sizeZ + z + 1

        newBlocks[newIndex] = blocks[oldIndex]
    end

    return newBlocks
end

local function reverse_reorder_blocks(blocks, size)
    local newBlocks = {}
    local sizeX, sizeY, sizeZ = unpack(size)
    local total = sizeX * sizeY * sizeZ

    for newIndex = 1, total do
        local ni = newIndex - 1
        local x = math.floor(ni / (sizeY * sizeZ))
        local y = math.floor((ni % (sizeY * sizeZ)) / sizeZ)
        local z = ni % sizeZ

        local oldIndex = y * (sizeZ * sizeX) + z * sizeX + x + 1
        newBlocks[newIndex] = blocks[oldIndex]
    end

    return newBlocks
end

local function get_indexes(block_names)
    local indexes = {to = {}, from = {}}
    for i, name in ipairs(block_names) do
        local id = i-1

        indexes.to[name] = {
            id = id,
            name = name
        }
        indexes.from[id] = {
            id = id,
            name = name
        }
    end

    return indexes
end

function module.save(blueprint, path)
    local ids = {}
    local size = blueprint.size

    local orderedBlocks = reverse_reorder_blocks(blueprint.blocks, size)

    local blocks = convert_to_vox(orderedBlocks)

    for id, info in pairs(blueprint.block_indexes.from) do
        ids[tonumber(id+1)] = info.name
    end

    local fragment = {
        ["block-names"] = ids,
        size = size,
        voxels = blocks,
        version = 1
    }

    file.write_bytes(path, bjson.tobytes(fragment))
end

function module.load(path)
    local blueprint = BluePrint.new({}, {}, {0, 0, 0})
    local fragment = bjson.frombytes(file.read_bytes(path))

    local blocks = convert_to_mbp(fragment.voxels)
    blocks = reorder_blocks(blocks, fragment.size)

    blueprint.size = fragment.size
    blueprint.block_indexes = get_indexes(fragment["block-names"])

    for id, block in ipairs(blocks) do
        block.pos = blueprint:index_to_pos(id)
    end

    blueprint.blocks = blocks
    blueprint.name = file.name(path)
    blueprint.loaded = true

    blueprint:__init_packs()

    return blueprint
end

return module