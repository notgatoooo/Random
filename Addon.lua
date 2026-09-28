--> Overdrive H On Top.
print("Pass 1")
local shared = odh_shared_plugins

print("Pass 2")
local my_own_tab = shared.CreateTab("My Plugin", "/axioriasolver/testplugin/refs/heads/main/icon")
--[[
This is kind of hard to understand, but you will need to upload your file as a .png, get its URL (e.g., https://raw.githubusercontent.com/axioriasolver/testplugin/refs/heads/main/icon.png), remove the `https://raw.githubusercontent.com` and `.png` parts so it becomes, for example, `axioriasolver/testplugin/refs/heads/main/icon`, and you are done.
]]
print("Pass 3")
local my_own_section = my_own_tab:AddSection("Example Addon", "CUSTOM SUBTITLE")

print("Pass 4")
--> Label (<string> text, <bool> allow_edit): allow_edit ? <table> : <void>
  -- Methods:
    -- :SetValue(<string> text): <void>
      -- This modifies the label text to the new one using the provided string
my_own_section:AddLabel("Credits: @my_name")

print("Pass 5")
--> Paragraph (<string> title, <string> description, <bool> allow_edit): allow_edit ? <table> : <void>
  -- Methods:
    -- :SetValue(<string> text): <void>
      -- This modifies the description text to the new one using the provided string
my_own_section:AddParagraph("title", "description")

print("Pass 6")
--> Toggle (<string> feature_name, <closure> callback): <closure>
  -- Methods:
    -- (): <void>
      -- This will change the toggle state and calls the callback with boolean argument

print("Pass 7")
my_own_section:AddToggle("toggle", function(state)
    if state then
        -- add your logic if the feature is toggled on
        
        print("Toggled On")
    else
        -- add your logic if the feature is toggled off
        
        print("Toggled Off")
    end
end)

print("Pass 8")
--> Slider (<string> feature_name, <int|float> minimum, <int|float> maximum, <int|float> default, <closure> callback): <table>
  -- Methods:
    -- :SetValue(<int|float> num): <void>
      -- This will change the slider value and calls the callback with int|float argument
my_own_section:AddSlider("slider", 10, 30, 20, function(int_or_float)
    shared.Notify("the computer process is at " .. int_or_float .. "%", 3)
end)

print("Pass 10")
--> Colorpicker (<string> feature_name, <color3> default_color, <closure> callback): <table>
  -- Methods:
    -- :SetHexValue(<string> hex): <void>
      -- Change the colorpicker value with hex and update other properties
    -- :SetRGBValue(<color3> color): <void>
      -- Change the colorpicker value with color3 and update other properties
my_own_section:AddColorpicker("colorpicker", Color3.fromRGB(255, 255, 255), function(color3rgb)
    print(color3rgb)
end)

print("11")
--> Dropdown (<string> feature_name, <array> default_list, <closure> callback)
  -- Methods:
    -- :Select(<string> text): <void>
      -- Select an existing item from the current lists.
    -- :ChangeItems(<array> list)
      -- Change the old items to with the provided array items.
my_own_section:AddDropdown("dropdown", {"list #1", "list #2"}, function(selected)
    shared.Notify(selected, 2)
end)

print("Pass 12")
--> PlayerDropdown (<string> feature_name, <closure> callback): <void>
my_own_section:AddPlayerDropdown("make gay", function(player)
    shared.Notify(player.Name .. " is now a gay person.", 1)
end)

print("Pass 13")
--> TextBox (<string> feature_name, <closure> callback): <void>
my_own_section:AddTextBox("textbox", function(text)
    shared.Notify(text)
end)

print("Pass 14")
--> Button (<string> feature_name, <closure> callback): <void>
my_own_section:AddButton("button", function()
    shared.Notify("this is a button", 2)
end)

print("Pass 17")
--> Keybind (<string> feature_name, <string> default_key, <closure> callback): <void>
my_own_section:AddKeybind("keybind", "U", function()
    shared.Notify("Keybind test", 1)
end)

print("Pass 18")
 --> Identifiers:
print("Premium:", shared.is_premium_user)
print("Exclusive:", shared.is_exclusive_user)
print("ServerBooster:", shared.is_serverbooster_user)
print("Discord Name:", shared.discord_name)
print("Discord ID:", shared.discord_id)
print("Executor:", shared.executor)
print("HWID:", shared.hwid)
print("Pass 19")

shared.load_from_github_url("/notgatoooo/Random/refs/heads/main/Addon_ext.lua")
