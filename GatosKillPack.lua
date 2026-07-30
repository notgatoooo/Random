-- Gato's Kill Pack

local shared = odh_shared_plugins

local my_own_section = shared.AddSection("READ ME")

my_own_section:AddParagraph("Warning", "This addon has been patched and will no longer work, please uninstall it.")

my_own_section:AddButton("Copy Uninstaller", function()
    setclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/not-gato/Random/refs/heads/main/Uninstaller.lua"))()]])
    shared.Notify("Check Clipboard and Execute this.", 0)
end)
