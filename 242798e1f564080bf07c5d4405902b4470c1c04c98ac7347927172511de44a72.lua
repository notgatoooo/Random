-- ts will stop working on 4.0.0 or any next patch, use it while you can!
-- hello pcall monster from pcallware a.k.a xynnn

local unsandboxed_env
local shared = odh_shared_plugins

local function run(action)
    if not unsandboxed_env then
        unsandboxed_env = getfenv(0)
    end
    setfenv(1, unsandboxed_env)
    pcall(setfenv, 2, unsandboxed_env)
    if action then
        local ok,err = pcall(setfenv, action, unsandboxed_env)
        if not ok and err then
            shared.kick("fuck your code: ", err)
        end
        return action()
    end
end

run()

local function get_fs()
    local env = unsandboxed_env or (pcall(getfenv, 3) and getfenv(3)) or getfenv(0)
    local genv = (getgenv and getgenv()) or {}
    local list = env.listfiles or env.list_files or genv.listfiles or genv.list_files or listfiles or list_files
    local read = env.readfile or genv.readfile or readfile
    local write = env.writefile or genv.writefile or writefile
    local del = env.delfile or env.deletefile or genv.delfile or genv.deletefile or delfile or deletefile
    local check_file = env.isfile or genv.isfile or isfile
    local check_folder = env.isfolder or genv.isfolder or isfolder
    return list, read, write, del, check_file, check_folder
end

local function sanitize_str(str)
    if not str then return "" end
    local s = str:gsub("%z", "")
    s = s:gsub("^\239\187\191", "")
    return s:match("^%s*(.-)%s*$") or s
end

local function check_is_disabled(str)
    local s = sanitize_str(str)
    return s:sub(1, 4) == "--[[" and s:sub(5, 5) ~= "=" and s:sub(-2) == "]]"
end

local function disable_content(str)
    if check_is_disabled(str) then
        return str
    end
    return "--[[\n" .. str .. "\n]]"
end

local function enable_content(str)
    local s = sanitize_str(str)
    if s:sub(1, 4) == "--[[" and s:sub(5, 5) ~= "=" and s:sub(-2) == "]]" then
        local inner = s:sub(5, -3)
        if inner:sub(1, 2) == "\r\n" then
            inner = inner:sub(3)
        elseif inner:sub(1, 1) == "\n" then
            inner = inner:sub(2)
        end
        if inner:sub(-2) == "\r\n" then
            inner = inner:sub(1, -3)
        elseif inner:sub(-1) == "\n" then
            inner = inner:sub(1, -2)
        end
        return inner
    end
    return str
end

local function parse_metadata(content, filepath)
    local raw_name = filepath:match("([^/\\]+)$") or filepath
    local s = sanitize_str(content)
    local disabled = false
    if s:sub(1, 4) == "--[[" and s:sub(5, 5) ~= "=" and s:sub(-2) == "]]" then
        disabled = true
        s = sanitize_str(s:sub(5, -3))
    end
    local display_name = raw_name
    if s:sub(1, 6) == "--[==[" then
        local close_pos = s:find("]==]", 7, true)
        if close_pos then
            local header = s:sub(7, close_pos - 1)
            local author, repo
            for line in header:gmatch("[^\r\n]+") do
                local k, v = line:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
                if k and v then
                    local lk = k:lower()
                    if lk == "author" then
                        author = v
                    elseif lk == "repository" then
                        repo = v
                    end
                end
            end
            if author and repo and author ~= "" and repo ~= "" then
                display_name = repo .. " by " .. author
            end
        end
    end
    return display_name, disabled
end

local addon_names = {}
local addon_map = {}
local selected_addon_name = nil

run(function()
    local list, read, write, del, check_file, check_folder = get_fs()
    if check_folder and not check_folder("Ixry Shizuka/plugins") then
        shared.kick("WHAT? 😹")
    end
    if list then
        local s, files = pcall(list, "Ixry Shizuka/plugins")
        if s and type(files) == "table" then
            for _, filepath in ipairs(files) do
                if not check_file or check_file(filepath) then
                    local ext = filepath:match("%.([%w_]+)$")
                    if not ext or ext:lower() == "lua" or ext:lower() == "luau" then
                        local read_s, content = pcall(read, filepath)
                        if read_s and content then
                            local display_name, is_disabled = parse_metadata(content, filepath)
                            if not addon_map[display_name] then
                                local item = {
                                    name = display_name,
                                    path = filepath,
                                    disabled = is_disabled
                                }
                                addon_map[display_name] = item
                                table.insert(addon_names, display_name)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local tab = shared.CreateTab("Plugin Manager", "/notgatoooo/Random/refs/heads/main/Assets/bs")
local section = tab:AddSection("Plugin Manager", "MADE BY GATO 😎") -- fucker im so cool cant u see 😎

local current_toggle_state = false
local is_syncing_toggle = false
local toggle_func

local function set_toggle_state(target)
    if toggle_func and current_toggle_state ~= target then
        is_syncing_toggle = true
        current_toggle_state = target
        toggle_func()
        is_syncing_toggle = false
    end
end

local function sync_toggle_for_addon(name)
    local info = addon_map[name]
    if not info then
        set_toggle_state(false)
        return
    end
    local is_dis = false
    run(function()
        local list, read, write, del, check_file, check_folder = get_fs()
        if read then
            local s, c = pcall(read, info.path)
            if s and c then
                is_dis = check_is_disabled(c)
            end
        end
    end)
    info.disabled = is_dis
    set_toggle_state(is_dis)
end

local dropdown = section:AddDropdown("Addons", addon_names, function(selected)
    selected_addon_name = selected
    sync_toggle_for_addon(selected)
end)

section:AddButton("Delete Addon", function()
    if not selected_addon_name or not addon_map[selected_addon_name] then
        shared.kick("what the fuck? 😹")
        return
    end
    local target = addon_map[selected_addon_name]
    run(function()
        local list, read, write, del, check_file, check_folder = get_fs()
        if del then
            pcall(del, target.path)
        end
    end)
    addon_map[selected_addon_name] = nil
    for i, name in ipairs(addon_names) do
        if name == selected_addon_name then
            table.remove(addon_names, i)
            break
        end
    end
    dropdown:ChangeItems(addon_names)
    if #addon_names > 0 then
        selected_addon_name = addon_names[1]
        dropdown:Select(selected_addon_name)
        sync_toggle_for_addon(selected_addon_name)
    else
        selected_addon_name = nil
        set_toggle_state(false)
    end
end)

toggle_func = section:AddToggle("Disable Addon", function(state)
    if is_syncing_toggle then
        if state ~= nil then
            current_toggle_state = state
        end
        return
    end
    if state ~= nil then
        current_toggle_state = state
    else
        current_toggle_state = not current_toggle_state
    end
    if not selected_addon_name or not addon_map[selected_addon_name] then
        shared.kick("im gay")
        return
    end
    local target = addon_map[selected_addon_name]
    run(function()
        local list, read, write, del, check_file, check_folder = get_fs()
        if not read or not write then
            shared.kick("peakaboo!")
            return
        end
        local content = read(target.path)
        if not content then
            -- lol go guess bro
            shared.kick("Xynnn Says:\nOvedrive H best MM2 script")
            return
        end
        if current_toggle_state then
            local wrapped = disable_content(content)
            write(target.path, wrapped)
            target.disabled = true
        else
            local unwrapped = enable_content(content)
            write(target.path, unwrapped)
            target.disabled = false
        end
    end)
end)

if #addon_names > 0 then
    selected_addon_name = addon_names[1]
    dropdown:Select(selected_addon_name)
    sync_toggle_for_addon(selected_addon_name)
end