--Meownatic Data File

local RLE = require 'meownatica:logic/RLEcompression'

local mdf = {}

local function serializeBlcoks(depthX, depthY, depthZ, blocks)
    local bytes = {}
    local len = depthX*depthY*depthZ
    for i = 1, len do
        bytes[i] = bit.lshift(blocks[i][1], 8)
        bytes[i + len] = bit.rshift(blocks[i][1], 8)
        bytes[i + len * 2] = blocks[i][2]
        bytes[i + len * 3] = blocks[i][3]
    end

    return RLE:encode(bytes)
end

local function serializeDWH(buf, dwh)
    --Сохраняем глубину, ширину и высоту
    print(dwh[1], dwh[2], dwh[3])
    buf:put_int16(dwh[1])
    buf:put_int16(dwh[2])
    buf:put_int16(dwh[3])
end

local function serializeModsIDS(buf, mods)
    --Сохраняем моды
    buf:put_int16(#mods)
    for id, mod in pairs(mods) do
        buf:put_string(mod)
    end
    print(buf.pos)
end

local function serializeBlocksID(buf, blocks)
    --Сохраняем айдишники модов для блоков, чтобы по ним восстановить массив
    buf:put_int16(#blocks)
    for i = 1, #blocks do
        buf:put_int16(blocks[i][1])
    end
end

function mdf:StartSerialize(buf, arr)
    --Сериализуем версию
    buf:put_uint16(arr[1])
    --Сериализуем айди модов
    serializeModsIDS(buf, arr[2])
    --Сериализуем айди блоков
    --serializeBlocksID(buf, arr[4])
    --Сериализуем глубину
    serializeDWH(buf, arr[3])
    --Сериализуем блоки
    local blocks = serializeBlcoks(arr[3][1], arr[3][2], arr[3][3], arr[4])
    buf:put_int32(#blocks)
    buf:put_bytes(blocks)
    
end

local function deserializeBlocks(depthX, depthY, depthZ, encodedData)
    local bytes = RLE:decode(encodedData)
    local blocks = {}
    local blockIndex = 1

    for i = 1, depthX * depthY * depthZ, 4 do
        local block = {}
        block[1] = bytes[i]
        block[2] = bytes[i + 1]
        block[3] = bytes[i + 2]
        block[4] = bytes[i + 3]
        blocks[blockIndex] = block
        blockIndex = blockIndex + 1
    end

    return blocks
end

function mdf:StartDeserialize(buf)
    local result = {}
    local mods_ids = {}
    local ids = {}
    local dwh = {}
    local blocks = {}

    --Получаем версию
    local version = buf:get_uint16()
    
    --Получаем айдишники модов
    local mods_ids_len = buf:get_int16()
    for i = 1, mods_ids_len do
        local mod = buf:get_string()
        table.insert(mods_ids, mod)
        print(mod)
    end
    print(buf.pos)
    --Получаем dwh
    local dX = buf:get_int16()
    local dY = buf:get_int16()
    local dZ = buf:get_int16()
    dwh = {dX, dY, dZ}

    --Получаеем блоки
    local blocks_len = buf:get_int32()
    blocks = buf:get_bytes(blocks_len)
    blocks = deserializeBlocks(dwh[1], dwh[2], dwh[3], blocks)
    return {version, mods_ids, dwh, blocks}
end

return mdf
