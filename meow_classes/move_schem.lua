local move_schem = {}

function move_schem:up(meownatic)
    for i = 1, #meownatic do
        meownatic[i].y = meownatic[i].y + 1 then
    return meownatic
end

function move_schem:down(meownatic)
    for i = 1, #meownatic do
        meownatic[i].y = meownatic[i].y - 1 then
    return meownatic
end

function move_schem:left(meownatic)
    for i = 1, #meownatic do
        meownatic[i].x = meownatic[i].x - 1 then
    return meownatic
end

function move_schem:right(meownatic)
    for i = 1, #meownatic do
        meownatic[i].x = meownatic[i].x + 1 then
    return meownatic
end

function move_schem:forward(meownatic)
    for i = 1, #meownatic do
        meownatic[i].z = meownatic[i].z + 1 then
    return meownatic
end

function move_schem:back(meownatic)
    for i = 1, #meownatic do
        meownatic[i].z = meownatic[i].z - 1 then
    return meownatic
end

return move_schem