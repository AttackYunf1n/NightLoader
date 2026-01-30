local Phantom = loadstring(game:HttpGet("https://raw.githubusercontent.com/AttackYunf1n/NightLoader/refs/heads/main/library.lua"))()

Phantom:Loader(function()
    local key = readfile("Phantom_Key.txt")
    
    getgenv().script_key = key
    
    local success, _ = pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9ac63143cd14f16eebcacfbc2e913a62.lua"))()
    end)

    local window = Phantom:Window("PHANTOM <font color='rgb(220,30,30)'>HUB</font>")
    
    local main_tab = window:Tab("Combat", "Combat")
    local visuals_tab = window:Tab("Visuals", "Visuals")
    
    local main_section = main_tab:Section("Main Features", "Left")
    local misc_section = main_tab:Section("Misc", "Right")
    local visuals_section = visuals_tab:Section("ESP Settings", "Left")

    main_section:Toggle("Auto Parry", false, function(state)
        print(state)
    end)

    main_section:Slider("Reach Distance", 10, 50, 25, function(value)
        print(value)
    end)

    misc_section:Button("Kill All", function()
        print("killed")
    end)

    visuals_section:ColorPicker("ESP Color", Color3.fromRGB(220, 30, 30), function(color)
        print(color)
    end)
    
    Phantom:Notify("System", "Script Loaded Successfully", 3)
end)
