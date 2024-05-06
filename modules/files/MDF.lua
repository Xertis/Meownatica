--Meownatic Data File

local RLE = require 'meownatica:logic/RLEcompression'

local mdf = {}

local function serializeBlcoks(depthX, depthY, depthZ, blocks)
    local bytes = {}
    local len =  #blocks
    for i = 1, len do
        bytes[i] = bit.lshift(blocks[i][1], 8)
        bytes[i + len] = bit.rshift(blocks[i][1], 8)
        bytes[i + len * 2] = blocks[i][2]
        bytes[i + len * 3] = blocks[i][3]
    end
    for i = 1, #bytes do
        print(bytes[i])
    end
    return RLE:encode(bytes)
end

local function serializeDWH(buf, dwh)
    --Сохраняем глубину, ширину, высоту и блок привязки
    buf:put_int16(dwh[1])
    buf:put_int16(dwh[2])
    buf:put_int16(dwh[3])
    buf:put_int32(dwh[4])
end

local function serializeModsIDS(buf, mods)
    --Сохраняем моды
    buf:put_int16(#mods)
    for id, mod in pairs(mods) do
        buf:put_string(mod)
    end
end

local function serializeBlocksID(buf, blocks)
    --Сохраняем айдишники модов для блоков, чтобы по ним восстановить массив
    buf:put_int16(#blocks)
    for i = 1, #blocks do
        buf:put_int16(blocks[i][1])
    end
end

function mdf:StartSerialize(arr, buf)
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
    print('erg')
    buf:put_bytes(blocks)
    print('fed')
    
end

local function deserializeBlocks(depthX, depthY, depthZ, encodedData)
    local bytes = RLE:decode(encodedData)
    local blocks = {}
    local len = depthX * depthY * depthZ

    for i = 1, len do
        print(i)
        local blockType = bit.bor(bit.lshift(bytes[i], 8), bytes[i + len])
        local a = bytes[i + len * 2]
        local b = bytes[i + len * 3]
        blocks[i] = {blockType, a, b}
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
    end
    --Получаем dwh
    local dX = buf:get_int16()
    local dY = buf:get_int16()
    local dZ = buf:get_int16()
    local binding_block = buf:get_int32()
    dwh = {dX, dY, dZ, binding_block}

    --Получаеем блоки
    local blocks_len = buf:get_int32()
    blocks = buf:get_bytes(blocks_len)
    blocks = deserializeBlocks(dwh[1], dwh[2], dwh[3], blocks)
    return {version, mods_ids, dwh, blocks}
end

return mdf
