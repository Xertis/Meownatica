require "voxelcraft:core"

loader.load_file("brops.json", "meownatica", loader.load_drops)

crafting.add_crafting_table_craft({
    "core:empty", "core:empty", "core:empty",
    "core:empty", "voxelcraft:furnace.item", "core:empty",
    "core:empty", "base:stone.item", "core:empty",
}, {"meownatica:meowoad.item", 1}, "voxelcraft:crafting_table")

crafting.add_crafting_table_craft({
    "core:empty", "voxelcraft:iron", "core:empty",
    "core:empty", "voxelcraft:furnace.item", "core:empty",
    "core:empty", "base:planks.item", "core:empty",
}, {"meownatica:meowbuild.item", 1}, "voxelcraft:crafting_table")

crafting.add_crafting_table_craft({
    "core:empty", "voxelcraft:iron", "core:empty",
    "core:empty", "voxelcraft:stick", "core:empty",
    "core:empty", "base:stone.item", "core:empty",
}, {"meownatica:meowint", 1}, "voxelcraft:crafting_table")

crafting.add_crafting_table_craft({
    "core:empty", "voxelcraft:iron", "core:empty",
    "voxelcraft:iron", "voxelcraft:stick", "voxelcraft:iron",
    "core:empty", "voxelcraft:iron", "core:empty",
}, {"meownatica:meowdelat.item", 1}, "voxelcraft:crafting_table")