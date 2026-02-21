-- Get the main addon object from AceAddon-3.0
local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

--------------------------------------------------
-- Options Table
--------------------------------------------------
--- Blizzard options table to show basic info and open config
local BlizzardOptions = {
    type = "group",
    name = "",
    args = {
        -- Addon title, centered horizontally
        title = {
            type = "description",
            name = "|cffffff00Skyriding UI|r", -- yellow color
            fontSize = "large",
            order = 2,
        },

        -- Addon author
        author = {
            type = "description",
            name = "Author: TheQuibbler",
            fontSize = "medium",
            order = 3,
        },

        -- Addon description and instructions
        description = {
            type = "description",
            name = "\nSkyriding UI provides helpful visual cues for skyriding.\n\n" ..
                   "Open the full settings window using the slash command |cff00ffff/skyui|r.",
            fontSize = "medium",
            order = 4,
        },
    },
}


LibStub("AceConfig-3.0"):RegisterOptionsTable("Skyriding UI", BlizzardOptions)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Skyriding UI", "Skyriding UI")
