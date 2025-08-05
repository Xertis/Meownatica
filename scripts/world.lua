require "constants"
require "utils"
require "init"

local builder = require "blueprint/logic/builder"

function on_world_tick()
    builder.tick()
end