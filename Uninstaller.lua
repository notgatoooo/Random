local function scanAndDelete(folder)
    if not isfolder(folder) then return end
    for _, item in ipairs(listfiles(folder)) do
        if isfolder(item) then
            scanAndDelete(item)
        elseif isfile(item) then
            local ok, content = pcall(readfile, item)
            if ok and content and content:lower():find("gato's kill pack", 1, true) then
                pcall(delfile, item)
            end
        end
    end
end

for _, folder in ipairs(listfiles("Ixry Shizuka/plugins")) do
    scanAndDelete(folder)
end

game:GetService("Players").LocalPlayer:Kick("Uninstall Sucessfull!")
