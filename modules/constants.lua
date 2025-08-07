MEOW_CONFIG = nil
BLUEPRINT_SAVE_PATH = "export:meownatics"

CURRENT_BLUEPRINT = {
    id = 0,
    hash = 0,
    preview_pos = {},
    preview_rot = {},
    preview_origin = {}
}
BLUEPRINTS = {}

CURRENT_BORDER_ID = 1
BORDERS = { {}, {} }

MODE = {side = "standalone"}

FILTERS = {
    {value = "all",            text="meownatica.menu-filters-all"},
    {value = "nature",         text="meownatica.menu-filters-nature"},
    {value = "middle_ages",    text="meownatica.menu-filters-middle_ages"},
    {value = "post-soviet",    text="meownatica.menu-filters-post_soviet"},
    {value = "modern",         text="meownatica.menu-filters-modern"},
    {value = "future",         text="meownatica.menu-filters-future"},
}

FILE_EXTENSIONS = {
    {value = "mbp",            text="MBP"},
    {value = "json",    text="JSON"},
    {value = "vox",         text="VOX (FRAGMENT)"}
}

COMMON_GLOBALS = {
    BUILD_HUD_OPEN = false,
    MENU = nil
}