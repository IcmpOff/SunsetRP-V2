fx_version "bodacious"

games { "gta5" }


ui_page "nui/ui.html"

server_scripts {
     "config.lua",
    -- "server/lib.lua",
    -- "server/classes/*.lua",
    -- "server/modules/*.lua",
    -- "server/server.lua",
    -- "server/implementation/*.lua"
    "server/modules/*.lua",
    "server/*.lua"
}

client_scripts {
    "config.lua",
    "client/tools/*.lua",
    "client/classes/*.lua",
    "client/modules/*.lua",
    -- "client/modules/filter.lua",
    -- "client/modules/grid.lua",
    -- "client/modules/hud.lua",
    -- "client/modules/infinity.lua",
    "client/client.lua",
    --"client/implementation/*.lua",
}

files {
    "nui/sounds/*.*",
    "nui/sounds/clicks/*.*",
    "nui/ui.html",
    "nui/css/style.css",
    "nui/js/script.js"
}

-- exports {
--     'getCurrentChannelId'
-- }

-- if GetConvar("sv_environment", "prod") == "debug" then
--     server_script "tests/sv_*.lua"
--     client_script "tests/cl_*.lua"
-- end
