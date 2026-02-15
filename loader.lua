-- // Hello skid have a good day!
-- // You can try crack or bypass it but you cant because its luarmor
repeat task.wait() until game:IsLoaded()

local tween_service = game:GetService("TweenService")
local user_input_service = game:GetService("UserInputService")
local core_gui = game:GetService("CoreGui")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

local function create_instance(instance_type, properties, children)
    local instance = Instance.new(instance_type)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

local function create_tween(instance, properties, tween_information)
    tween_information = tween_information or TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween_service:Create(instance, tween_information, properties):Play()
end

local function make_frame_draggable(frame)
    frame.Active = true
    local is_dragging = false
    local drag_input = nil
    local drag_start_position = nil
    local start_frame_position = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            is_dragging = true
            drag_start_position = input.Position
            start_frame_position = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    is_dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)

    user_input_service.InputChanged:Connect(function(input)
        if input == drag_input and is_dragging then
            local scale_factor = frame:FindFirstChild("UIScale") and frame.UIScale.Scale or 1
            local delta_movement = (input.Position - drag_start_position) / scale_factor
            frame.Position = UDim2.new(
                start_frame_position.X.Scale,
                start_frame_position.X.Offset + delta_movement.X,
                start_frame_position.Y.Scale,
                start_frame_position.Y.Offset + delta_movement.Y
            )
        end
    end)
end

local function show_notification(title_text, message_text, display_duration)
    local screen_gui = core_gui:FindFirstChild("PhantomLoader")
    if not screen_gui then return end

    local notification_container = screen_gui:FindFirstChild("NotifContainer")
    if not notification_container then
        notification_container = create_instance("Frame", {
            Name = "NotifContainer",
            Parent = screen_gui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -20),
            Size = UDim2.new(0, 300, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        }, {
            create_instance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
        })
    end

    local notification_frame = create_instance("Frame", {
        Parent = notification_container,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    }, {
        create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
        create_instance("UIStroke", {Color = Color3.fromRGB(50, 15, 15), Thickness = 1}),
        create_instance("Frame", {
            BackgroundColor3 = Color3.fromRGB(220, 30, 30),
            Size = UDim2.new(0, 4, 1, 0)
        }, {create_instance("UICorner", {CornerRadius = UDim.new(0, 2)})})
    })

    create_instance("TextLabel", {
        Parent = notification_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title_text,
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21
    })

    create_instance("TextLabel", {
        Parent = notification_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        Text = message_text,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21
    })

    create_tween(notification_frame, {Size = UDim2.new(1, 0, 0, 70)})

    task.delay(display_duration or 3, function()
        create_tween(notification_frame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.3)
        notification_frame:Destroy()
    end)
end

if core_gui:FindFirstChild("PhantomLoader") then
    core_gui.PhantomLoader:Destroy()
end

local screen_gui = create_instance("ScreenGui", {
    Name = "PhantomLoader",
    Parent = core_gui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local main_frame = create_instance("Frame", {
    Name = "MainFrame",
    Parent = screen_gui,
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BackgroundTransparency = 0.05,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 550, 0, 400),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true
}, {
    create_instance("UICorner", {CornerRadius = UDim.new(0, 14)}),
    create_instance("UIStroke", {Color = Color3.fromRGB(50, 15, 15), Thickness = 1})
})

local ui_scale = create_instance("UIScale", {Parent = main_frame, Scale = 1})

local function update_ui_scale()
    local viewport_size = camera.ViewportSize
    local target_width = 550
    local available_width = viewport_size.X * 0.9
    ui_scale.Scale = math.min(1, available_width / target_width)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(update_ui_scale)
update_ui_scale()

local sidebar_frame = create_instance("Frame", {
    Name = "Sidebar",
    Parent = main_frame,
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 180, 1, 0),
    BorderSizePixel = 0
}, {
    create_instance("UICorner", {CornerRadius = UDim.new(0, 14)}),
    create_instance("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        BorderSizePixel = 0
    })
})

local avatar_image = create_instance("ImageLabel", {
    Name = "Avatar",
    Parent = sidebar_frame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.35, 0),
    Size = UDim2.new(0, 70, 0, 70),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Image = ""
}, {create_instance("UICorner", {CornerRadius = UDim.new(1, 0)})})

task.spawn(function()
    task.wait(0.5)
    local success, thumbnail = pcall(function()
        return players:GetUserThumbnailAsync(local_player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    if success and thumbnail then
        avatar_image.Image = thumbnail
    end
end)

local discord_button = create_instance("TextButton", {
    Parent = sidebar_frame,
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Position = UDim2.new(0.5, 0, 0.35, 55),
    Size = UDim2.new(0, 140, 0, 32),
    AnchorPoint = Vector2.new(0.5, 0),
    Text = "",
    AutoButtonColor = false
}, {
    create_instance("UICorner", {CornerRadius = UDim.new(0, 6)}),
    create_instance("UIStroke", {Color = Color3.fromRGB(88, 101, 242), Thickness = 1})
})

create_instance("ImageLabel", {
    Parent = discord_button,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0.5, -9),
    Size = UDim2.new(0, 18, 0, 18),
    Image = "rbxassetid://127246309238637",
    ImageColor3 = Color3.fromRGB(255, 255, 255)
})

create_instance("TextLabel", {
    Parent = discord_button,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 34, 0, 0),
    Size = UDim2.new(1, -34, 1, 0),
    Text = "Join Discord",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
})

local content_frame = create_instance("Frame", {
    Parent = main_frame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 200, 0, 0),
    Size = UDim2.new(1, -200, 1, 0)
})

create_instance("TextLabel", {
    Parent = content_frame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0.1, 0),
    Size = UDim2.new(1, 0, 0, 30),
    Font = Enum.Font.GothamBold,
    Text = "PHANTOM <font color='rgb(220,30,30)'>HUB</font>",
    TextColor3 = Color3.fromRGB(245, 245, 245),
    TextSize = 24,
    RichText = true
})

create_instance("TextLabel", {
    Parent = content_frame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0.2, 0),
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "Welcome back, " .. local_player.Name,
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14
})

local function create_input_field(placeholder_text, icon_asset_id, is_hidden)
    local input_frame = create_instance("Frame", {
        Parent = content_frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -40, 0, 40)
    }, {
        create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
        create_instance("UIStroke", {Color = Color3.fromRGB(50, 15, 15), Thickness = 1})
    })

    local icon_label = create_instance("ImageLabel", {
        Parent = input_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = icon_asset_id,
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    })

    local text_box = create_instance("TextBox", {
        Parent = input_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder_text,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.SplitWord
    })

    if is_hidden then
        text_box.TextTransparency = 1
        local mask_label = create_instance("TextLabel", {
            Parent = input_frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.fromRGB(245, 245, 245),
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        text_box:GetPropertyChangedSignal("Text"):Connect(function()
            mask_label.Text = string.rep("•", #text_box.Text)
        end)
    end

    text_box.Focused:Connect(function()
        create_tween(input_frame, {BackgroundColor3 = Color3.fromRGB(10, 0, 0)})
        create_tween(icon_label, {ImageColor3 = Color3.fromRGB(220, 30, 30)})
    end)

    text_box.FocusLost:Connect(function()
        create_tween(input_frame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
        create_tween(icon_label, {ImageColor3 = Color3.fromRGB(150, 150, 150)})
    end)

    return text_box, input_frame
end

local username_textbox, username_frame = create_input_field("Username", "rbxassetid://120214019251678", false)
username_frame.Position = UDim2.new(0, 20, 0.35, 0)

local key_textbox, key_frame = create_input_field("Key", "rbxassetid://72241908544847", true)
key_frame.Position = UDim2.new(0, 20, 0.48, 0)

username_textbox.Text = local_player.Name
key_textbox.Text = ""

local login_button = create_instance("TextButton", {
    Parent = content_frame,
    BackgroundColor3 = Color3.fromRGB(220, 30, 30),
    Position = UDim2.new(0, 20, 0.62, 0),
    Size = UDim2.new(1, -40, 0, 40),
    Text = "LOG IN",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(245, 245, 245),
    TextSize = 14,
    AutoButtonColor = false
}, {create_instance("UICorner", {CornerRadius = UDim.new(0, 8)})})

local get_key_button = create_instance("TextButton", {
    Parent = content_frame,
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    Position = UDim2.new(0, 20, 0.75, 0),
    Size = UDim2.new(1, -40, 0, 35),
    Text = "GET KEY",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 12,
    AutoButtonColor = false
}, {
    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
    create_instance("UIStroke", {Color = Color3.fromRGB(50, 15, 15), Thickness = 1})
})

login_button.MouseEnter:Connect(function()
    create_tween(login_button, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)})
end)

login_button.MouseLeave:Connect(function()
    create_tween(login_button, {BackgroundColor3 = Color3.fromRGB(220, 30, 30)})
end)

get_key_button.MouseEnter:Connect(function()
    create_tween(get_key_button, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(245, 245, 245)})
end)

get_key_button.MouseLeave:Connect(function()
    create_tween(get_key_button, {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(150, 150, 150)})
end)

discord_button.MouseEnter:Connect(function()
    create_tween(discord_button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
    create_tween(discord_button:FindFirstChild("TextLabel"), {TextColor3 = Color3.fromRGB(150, 150, 150)})
    create_tween(discord_button:FindFirstChild("ImageLabel"), {ImageColor3 = Color3.fromRGB(150, 150, 150)})
end)

discord_button.MouseLeave:Connect(function()
    create_tween(discord_button, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)})
    create_tween(discord_button:FindFirstChild("TextLabel"), {TextColor3 = Color3.fromRGB(255, 255, 255)})
    create_tween(discord_button:FindFirstChild("ImageLabel"), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
end)

get_key_button.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://ads.luarmor.net/get_key?for=Checkpoints-HSVJWPYAuoAP")
        show_notification("Success", "Key link copied to clipboard", 2)
    end
end)

discord_button.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/p7W2GrUwae")
        show_notification("Success", "Discord invite copied to clipboard", 2)
    end
end)

local invalid_key_reset_task = nil

local function handle_invalid_key()
    if invalid_key_reset_task then
        task.cancel(invalid_key_reset_task)
    end

    local original_position = main_frame.Position
    create_tween(main_frame, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}, TweenInfo.new(0.2))
    create_tween(sidebar_frame, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}, TweenInfo.new(0.2))

    for iteration = 1, 6 do
        local offset_value = (iteration % 2 == 0) and -5 or 5
        create_tween(main_frame, {Position = original_position + UDim2.new(0, offset_value, 0, 0)}, TweenInfo.new(0.05))
        task.wait(0.05)
    end

    create_tween(main_frame, {Position = original_position}, TweenInfo.new(0.05))

    invalid_key_reset_task = task.delay(1.0, function()
        create_tween(main_frame, {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}, TweenInfo.new(0.5))
        create_tween(sidebar_frame, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, TweenInfo.new(0.5))
        invalid_key_reset_task = nil
    end)
end

login_button.MouseButton1Click:Connect(function()
    local entered_key = key_textbox.Text
    if entered_key == "" then
        handle_invalid_key()
        show_notification("Error", "Please enter a key", 2)
        return
    end
    entered_key = string.gsub(entered_key, "%s+", "")

    local place_identifier = game.PlaceId
    local loader_url = "https://api.luarmor.net/files/v4/loaders/18fa0aa2984290b5582813fe581dd4cf.lua"

    if place_identifier == 136801880565837 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/1bc3e428e2dc4a308c0131998c69f88f.lua"
    elseif place_identifier == 17625359962 or place_identifier == 18126510175 or place_identifier == 71874690745115 or place_identifier == 117398147513099 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/f734cbc6d30b72abe044a3fb60543345.lua"
    elseif place_identifier == 286090429 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/4bb532417b744a53f3c4f8c6f0c8cca7.lua"
    elseif place_identifier == 13772394625 or place_identifier == 14368557094 or place_identifier == 14732610803 or place_identifier == 14915220621 or place_identifier == 15131065025 or place_identifier == 15144787112 or place_identifier == 15185247558 or place_identifier == 15234596844 or place_identifier == 15264892126 or place_identifier == 15509350986 or place_identifier == 15517169103 or place_identifier == 15552588346 or place_identifier == 15582821022 or place_identifier == 15582823307 or place_identifier == 16044264830 or place_identifier == 16281300371 or place_identifier == 16331595046 or place_identifier == 16331596518 or place_identifier == 16331598816 or place_identifier == 16331600459 or place_identifier == 16456370330 or place_identifier == 16581637217 or place_identifier == 16581648071 or place_identifier == 17757592456 or place_identifier == 92458008626219 or place_identifier == 111661204337143 then
        loader_url = "https://api.luarmor.net/files/v4/loaders/18fa0aa2984290b5582813fe581dd4cf.lua"
    end

    login_button.Text = "CHECKING..."
    task.wait(0.5)

    getgenv().script_key = entered_key
    local load_successful = pcall(function()
        local loader_function = loadstring(game:HttpGet(loader_url))
        task.spawn(loader_function)
    end)

    if load_successful then
        create_tween(main_frame, {
            Size = UDim2.new(0, 550, 0, 0),
            BackgroundTransparency = 1
        }, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In))
        task.wait(0.5)
        screen_gui:Destroy()
    else
        login_button.Text = "LOG IN"
        handle_invalid_key()
        show_notification("Error", "Failed to load script", 3)
    end
end)

make_frame_draggable(main_frame)
