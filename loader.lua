local tween_service = game:GetService("TweenService")
local user_input_service = game:GetService("UserInputService")
local core_gui = game:GetService("CoreGui")
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

local theme = {
    main = Color3.fromRGB(10, 10, 10),
    sidebar = Color3.fromRGB(15, 15, 15),
    section = Color3.fromRGB(20, 20, 20),
    stroke = Color3.fromRGB(50, 15, 15),
    accent = Color3.fromRGB(220, 30, 30),
    text = Color3.fromRGB(245, 245, 245),
    text_dark = Color3.fromRGB(150, 150, 150),
    sidebar_transparency = 1,
    main_transparency = 0.05,
    notif_transparency = 0.1,
    error_red = Color3.fromRGB(200, 0, 0)
}

local function create(instance, properties, children)
    local obj = Instance.new(instance)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function tween(obj, props, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween_service:Create(obj, info, props):Play()
end

local function get_icon(name)
    local icons = {
        combat = "rbxassetid://75666516613797",
        visuals = "rbxassetid://131804094851461",
        settings = "rbxassetid://125142287445982",
        misc = "rbxassetid://74724520908176",
        home = "rbxassetid://10747384394",
        target = "rbxassetid://72388072420613",
        user = "rbxassetid://120214019251678",
        lock = "rbxassetid://72241908544847"
    }
    if icons[name] then
        return icons[name]
    elseif string.find(tostring(name), "rbxassetid://") then
        return name
    else
        return icons.home
    end
end

local function make_draggable(topbar, frame)
    topbar.Active = true
    local dragging, drag_input, drag_start, start_pos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
    user_input_service.InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            local scale = frame:FindFirstChild("UIScale") and frame.UIScale.Scale or 1
            local delta = (input.Position - drag_start) / scale
            tween(frame, {Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)}, TweenInfo.new(0.05))
        end
    end)
end

local function notify(title, text, duration)
    local screen_gui = core_gui:FindFirstChild("PhantomLoader")
    if not screen_gui then return end
    
    local container = screen_gui:FindFirstChild("NotifContainer")
    if not container then
        container = create("Frame", {
            Name = "NotifContainer",
            Parent = screen_gui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -20),
            Size = UDim2.new(0, 300, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        }, {
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
        })
    end
    local notif_frame = create("Frame", {
        Parent = container,
        BackgroundColor3 = theme.section,
        BackgroundTransparency = theme.notif_transparency,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    }, {
        create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        create("UIStroke", {Color = theme.stroke, Thickness = 1}),
        create("Frame", {
            BackgroundColor3 = theme.accent,
            Size = UDim2.new(0, 4, 1, 0)
        }, {create("UICorner", {CornerRadius = UDim.new(0, 2)})})
    })
    create("TextLabel", {
        Parent = notif_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = theme.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21
    })
    create("TextLabel", {
        Parent = notif_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = theme.text_dark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21
    })
    
    tween(notif_frame, {Size = UDim2.new(1, 0, 0, 70)})
    
    task.delay(duration or 3, function()
        tween(notif_frame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.3)
        notif_frame:Destroy()
    end)
end

if core_gui:FindFirstChild("PhantomLoader") then core_gui.PhantomLoader:Destroy() end
local screen_gui = create("ScreenGui", { Name = "PhantomLoader", Parent = core_gui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })

local main_frame = create("Frame", {
    Name = "MainFrame", Parent = screen_gui, BackgroundColor3 = theme.main, BackgroundTransparency = theme.main_transparency,
    Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 550, 0, 350), AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ClipsDescendants = true, Active = true
}, { create("UICorner", {CornerRadius = UDim.new(0, 14)}), create("UIStroke", {Color = theme.stroke, Thickness = 1}) })

local ui_scale = create("UIScale", { Parent = main_frame, Scale = 1 })

local function update_auto_size()
    local viewport = camera.ViewportSize
    local target_width = 550
    local available_width = viewport.X * 0.9
    
    if available_width < target_width then
        ui_scale.Scale = available_width / target_width
    else
        ui_scale.Scale = 1
    end
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(update_auto_size)
update_auto_size()

local sidebar = create("Frame", {
    Name = "Sidebar", Parent = main_frame, BackgroundColor3 = theme.sidebar, BackgroundTransparency = theme.sidebar_transparency,
    Size = UDim2.new(0, 180, 1, 0), BorderSizePixel = 0
}, {
    create("UICorner", {CornerRadius = UDim.new(0, 14)}),
    create("Frame", { BackgroundColor3 = theme.sidebar, BackgroundTransparency = theme.sidebar_transparency, Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 20, 1, 0), BorderSizePixel = 0 }),
    create("ImageLabel", {
        Name = "Avatar", BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.4, 0), Size = UDim2.new(0, 65, 0, 65), AnchorPoint = Vector2.new(0.5, 0.5),
        Image = players:GetUserThumbnailAsync(local_player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    }, {create("UICorner", {CornerRadius = UDim.new(1, 0)})})
})

local content = create("Frame", { Parent = main_frame, BackgroundTransparency = 1, Position = UDim2.new(0, 200, 0, 0), Size = UDim2.new(1, -200, 1, 0) })
create("TextLabel", { Parent = content, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.1, 0), Size = UDim2.new(1, 0, 0, 30), Font = Enum.Font.GothamBold, Text = "PHANTOM <font color='rgb(220,30,30)'>HUB</font>", TextColor3 = theme.text, TextSize = 24, RichText = true })
create("TextLabel", { Parent = content, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.2, 0), Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.Gotham, Text = "Welcome back, " .. local_player.Name, TextColor3 = theme.text_dark, TextSize = 14 })

local function create_input(placeholder, icon, hidden)
    local input_frame = create("Frame", { Parent = content, BackgroundColor3 = theme.section, BackgroundTransparency = 0.5, Size = UDim2.new(1, -40, 0, 40) }, { create("UICorner", {CornerRadius = UDim.new(0, 8)}), create("UIStroke", {Color = theme.stroke, Thickness = 1}) })
    local icon_label = create("ImageLabel", { Parent = input_frame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = get_icon(icon), ImageColor3 = theme.text_dark })
    local box = create("TextBox", { Parent = input_frame, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.Gotham, PlaceholderText = placeholder, PlaceholderColor3 = theme.text_dark, Text = "", TextColor3 = theme.text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false })
    
    if hidden then
        box.TextTransparency = 1
        local mask_display = create("TextLabel", {
            Parent = input_frame, BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamBold, Text = "", TextColor3 = theme.text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2
        })
        box:GetPropertyChangedSignal("Text"):Connect(function()
            mask_display.Text = string.rep("●", #box.Text)
        end)
    end
    
    box.Focused:Connect(function() tween(input_frame, {BackgroundColor3 = theme.main}) tween(icon_label, {ImageColor3 = theme.accent}) end)
    box.FocusLost:Connect(function() tween(input_frame, {BackgroundColor3 = theme.section}) tween(icon_label, {ImageColor3 = theme.text_dark}) end)
    return box, input_frame
end

local user_box, user_frame = create_input("Username", "user") user_frame.Position = UDim2.new(0, 20, 0.35, 0)
local pass_box, pass_frame = create_input("Key", "lock", true) pass_frame.Position = UDim2.new(0, 20, 0.50, 0)
user_box.Text = local_player.Name
pass_box.Text = ""

local login_btn = create("TextButton", { Parent = content, BackgroundColor3 = theme.accent, Position = UDim2.new(0, 20, 0.68, 0), Size = UDim2.new(1, -40, 0, 40), Text = "LOG IN", Font = Enum.Font.GothamBold, TextColor3 = theme.text, TextSize = 14, AutoButtonColor = false }, { create("UICorner", {CornerRadius = UDim.new(0, 8)}) })
local get_key_btn = create("TextButton", { Parent = content, BackgroundColor3 = theme.section, Position = UDim2.new(0, 20, 0.82, 0), Size = UDim2.new(1, -40, 0, 35), Text = "GET KEY", Font = Enum.Font.GothamBold, TextColor3 = theme.text_dark, TextSize = 12, AutoButtonColor = false }, { create("UICorner", {CornerRadius = UDim.new(0, 8)}), create("UIStroke", {Color = theme.stroke, Thickness = 1}) })

login_btn.MouseEnter:Connect(function() tween(login_btn, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}) end)
login_btn.MouseLeave:Connect(function() tween(login_btn, {BackgroundColor3 = theme.accent}) end)
get_key_btn.MouseEnter:Connect(function() tween(get_key_btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = theme.text}) end)
get_key_btn.MouseLeave:Connect(function() tween(get_key_btn, {BackgroundColor3 = theme.section, TextColor3 = theme.text_dark}) end)

get_key_btn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://ads.luarmor.net/get_key?for=Checkpoints-HSVJWPYAuoAP")
        notify("Success", "Key link copied to clipboard", 2)
    end
end)

local shake_reset_task = nil
local function shake_and_red()
    if shake_reset_task then task.cancel(shake_reset_task) end
    
    local original_pos = main_frame.Position
    tween(main_frame, {BackgroundColor3 = theme.error_red}, TweenInfo.new(0.2))
    tween(sidebar, {BackgroundColor3 = theme.error_red}, TweenInfo.new(0.2))
    
    for i = 1, 6 do
        local offset = (i % 2 == 0) and -5 or 5
        tween(main_frame, {Position = original_pos + UDim2.new(0, offset, 0, 0)}, TweenInfo.new(0.05))
        task.wait(0.05)
    end
    tween(main_frame, {Position = original_pos}, TweenInfo.new(0.05))
    
    shake_reset_task = task.delay(1.0, function()
        tween(main_frame, {BackgroundColor3 = theme.main}, TweenInfo.new(0.5))
        tween(sidebar, {BackgroundColor3 = theme.sidebar}, TweenInfo.new(0.5))
        shake_reset_task = nil
    end)
end

login_btn.MouseButton1Click:Connect(function()
    local input_key = pass_box.Text
    
    if input_key == "" then
        shake_and_red()
        notify("Error", "Please enter a key", 2)
        return
    end
    
    input_key = string.gsub(input_key, "%s+", "")

    local place_id = game.PlaceId
    local loader_url = nil
    
    if place_id == 13772394625 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/18fa0aa2984290b5582813fe581dd4cf.lua"
    elseif place_id == 286090429 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/4bb532417b744a53f3c4f8c6f0c8cca7.lua"
    end
    
    if not loader_url then
        local_player:Kick("Unsupported game!")
        return
    end
    
    login_btn.Text = "CHECKING..."
    task.wait(0.5)
    
    getgenv().script_key = input_key
    
    local success, result = pcall(function()
        local chunk = loadstring(game:HttpGet(loader_url))
        task.spawn(chunk)
    end)
    
    if success then
        tween(main_frame, {Size = UDim2.new(0, 550, 0, 0), BackgroundTransparency = 1}, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In))
        task.wait(0.5)
        screen_gui:Destroy()
    else
        login_btn.Text = "LOG IN"
        shake_and_red()
        notify("Error", "Failed to load script", 3)
    end
end)

make_draggable(main_frame, main_frame)
