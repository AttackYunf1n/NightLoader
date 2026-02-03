local players = game:GetService("Players")
local core_gui = game:GetService("CoreGui")
local http_service = game:GetService("HttpService")
local tween_service = game:GetService("TweenService")
local user_input_service = game:GetService("UserInputService")

local local_player = players.LocalPlayer
local current_camera = workspace.CurrentCamera
local mouse = local_player:GetMouse()

local phantom = {}
local settings = {}
local settings_file = "phantom_config.json"

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

local function load_settings()
    if isfile and isfile(settings_file) and readfile then
        local success, result = pcall(function()
            return http_service:JSONDecode(readfile(settings_file))
        end)
        if success then
            settings = result
        end
    end
end

local function save_settings()
    if writefile then
        pcall(function()
            writefile(settings_file, http_service:JSONEncode(settings))
        end)
    end
end

load_settings()

local function create_instance(class_name, properties, children)
    local object = Instance.new(class_name)
    for property, value in pairs(properties) do
        object[property] = value
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = object
        end
    end
    return object
end

local function tween_object(object, properties, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween_service:Create(object, info, properties):Play()
end

local function make_draggable(topbar, main_frame)
    local dragging = false
    local drag_input
    local drag_start
    local start_position

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_position = main_frame.Position

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
            local delta = input.Position - drag_start
            tween_object(main_frame, {
                Position = UDim2.new(
                    start_position.X.Scale,
                    start_position.X.Offset + delta.X,
                    start_position.Y.Scale,
                    start_position.Y.Offset + delta.Y
                )
            }, TweenInfo.new(0.05))
        end
    end)
end

function phantom:notify(title, text, duration)
    local screen_gui = core_gui:FindFirstChild("PhantomUI")
    if not screen_gui then return end

    local container = screen_gui:FindFirstChild("NotifContainer")
    if not container then
        container = create_instance("Frame", {
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

    local notif_frame = create_instance("Frame", {
        Parent = container,
        BackgroundColor3 = theme.section,
        BackgroundTransparency = theme.notif_transparency,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    }, {
        create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
        create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
        create_instance("Frame", {
            BackgroundColor3 = theme.accent,
            Size = UDim2.new(0, 4, 1, 0)
        }, {create_instance("UICorner", {CornerRadius = UDim.new(0, 2)})}),
        create_instance("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 21
        }),
        create_instance("TextLabel", {
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
    })

    tween_object(notif_frame, {Size = UDim2.new(1, 0, 0, 70)})

    task.delay(duration or 3, function()
        tween_object(notif_frame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.3)
        notif_frame:Destroy()
    end)
end

function phantom:window(title)
    if core_gui:FindFirstChild("PhantomUI") then
        core_gui.PhantomUI:Destroy()
    end

    local viewport_size = current_camera.ViewportSize
    local window_size = UDim2.new(0, 800, 0, 550)

    if viewport_size.X < 500 then
        window_size = UDim2.new(0.95, 0, 0.9, 0)
    elseif viewport_size.X < 1100 then
        window_size = UDim2.new(0.85, 0, 0.75, 0)
    end

    local screen_gui = create_instance("ScreenGui", {
        Name = "PhantomUI",
        Parent = core_gui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999
    })

    local main_frame = create_instance("Frame", {
        Name = "Main",
        Parent = screen_gui,
        BackgroundColor3 = theme.main,
        BackgroundTransparency = theme.main_transparency,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = window_size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    }, {
        create_instance("UICorner", {CornerRadius = UDim.new(0, 14)}),
        create_instance("UIStroke", {Color = theme.stroke, Thickness = 1})
    })

    local top_bar = create_instance("Frame", {
        Parent = main_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Active = true
    }, {
        create_instance("ImageButton", {
            Name = "Minimizer",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = "rbxassetid://72388072420613",
            ImageColor3 = theme.accent
        }),
        create_instance("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })
    })

    local sidebar = create_instance("Frame", {
        Parent = main_frame,
        BackgroundColor3 = theme.sidebar,
        BackgroundTransparency = theme.sidebar_transparency,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 200, 1, -50),
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        create_instance("UICorner", {CornerRadius = UDim.new(0, 14)}),
        create_instance("Frame", {
            Name = "Decoration",
            BackgroundColor3 = theme.sidebar,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -1, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 2
        }, {create_instance("UIStroke", {Color = theme.stroke, Thickness = 1})})
    })

    local sidebar_content = create_instance("Frame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3
    }, {
        create_instance("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        }),
        create_instance("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})
    })

    local container = create_instance("Frame", {
        Parent = main_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 215, 0, 60),
        Size = UDim2.new(1, -230, 1, -75),
        ClipsDescendants = true
    })

    local is_minimized = false
    local function toggle_menu()
        is_minimized = not is_minimized
        if is_minimized then
            sidebar.Visible = false
            container.Visible = false
            tween_object(main_frame, {Size = UDim2.new(0, 200, 0, 50)}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        else
            tween_object(main_frame, {Size = window_size, Position = UDim2.new(0.5, 0, 0.5, 0)}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            task.delay(0.3, function()
                if not is_minimized then
                    sidebar.Visible = true
                    container.Visible = true
                end
            end)
        end
    end

    top_bar.Minimizer.MouseButton1Click:Connect(toggle_menu)

    user_input_service.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            toggle_menu()
        end
    end)

    local is_mobile = user_input_service.TouchEnabled
    local drag_connection

    if is_mobile then
        local drag_button = create_instance("TextButton", {
            Parent = top_bar,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -50, 0, 0),
            Size = UDim2.new(0, 50, 1, 0),
            Text = "⤓",
            TextColor3 = theme.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 20
        })

        drag_button.MouseButton1Down:Connect(function()
            make_draggable(top_bar, main_frame)
        end)

        drag_button.MouseButton1Up:Connect(function()
            if drag_connection then
                drag_connection:Disconnect()
                drag_connection = nil
            end
        end)
    else
        make_draggable(top_bar, main_frame)
    end

    local window_object = {}
    local tabs = {}
    local first_tab = true

    function window_object:tab(name, icon_id)
        local tab_object = {}
        local tab_data = {selected = false}

        local final_icon = "rbxassetid://10747384394"
        if icon_id then
            if type(icon_id) == "number" then
                final_icon = "rbxassetid://" .. tostring(icon_id)
            else
                final_icon = icon_id
            end
        end

        local tab_button = create_instance("TextButton", {
            Parent = sidebar_content,
            BackgroundColor3 = theme.main,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            AutoButtonColor = false
        }, {
            create_instance("UICorner", {CornerRadius = UDim.new(0, 10)}),
            create_instance("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                Image = final_icon,
                ImageColor3 = theme.text_dark
            }),
            create_instance("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -44, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = name,
                TextColor3 = theme.text_dark,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        local tab_page = create_instance("Frame", {
            Parent = container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        }, {
            create_instance("ScrollingFrame", {
                Name = "Left",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -8, 1, 0),
                ScrollBarThickness = 0,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollingEnabled = true,
                ElasticBehavior = Enum.ElasticBehavior.Always
            }, {
                create_instance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)}),
                create_instance("UIPadding", {PaddingBottom = UDim.new(0, 10)})
            }),
            create_instance("ScrollingFrame", {
                Name = "Right",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 8, 0, 0),
                Size = UDim2.new(0.5, -8, 1, 0),
                ScrollBarThickness = 0,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollingEnabled = true,
                ElasticBehavior = Enum.ElasticBehavior.Always
            }, {
                create_instance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)}),
                create_instance("UIPadding", {PaddingBottom = UDim.new(0, 10)})
            })
        })

        local function update_canvas(scrolling_frame)
            local layout = scrolling_frame:FindFirstChild("UIListLayout")
            if layout then
                scrolling_frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end
        end

        tab_page.Left.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() update_canvas(tab_page.Left) end)
        tab_page.Right.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() update_canvas(tab_page.Right) end)

        local function update_tab()
            if tab_data.selected then
                tween_object(tab_button, {BackgroundTransparency = 0, BackgroundColor3 = theme.section})
                tween_object(tab_button.Icon, {ImageColor3 = theme.accent})
                tween_object(tab_button.Title, {TextColor3 = theme.text})
            else
                tween_object(tab_button, {BackgroundTransparency = 1})
                tween_object(tab_button.Icon, {ImageColor3 = theme.text_dark})
                tween_object(tab_button.Title, {TextColor3 = theme.text_dark})
            end
        end

        tab_button.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.selected = false
                t.update()
                t.page.Visible = false
            end
            tab_data.selected = true
            update_tab()
            tab_page.Visible = true
        end)

        tab_data.update = update_tab
        tab_data.page = tab_page
        tabs[#tabs + 1] = tab_data

        if first_tab then
            first_tab = false
            tab_data.selected = true
            update_tab()
            tab_page.Visible = true
        end

        function tab_object:section(title, side)
            local parent_frame = (side == "Right") and tab_page.Right or tab_page.Left
            local section_object = {}

            local section_frame = create_instance("Frame", {
                Parent = parent_frame,
                BackgroundColor3 = theme.section,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 100),
                ClipsDescendants = false
            }, {
                create_instance("UICorner", {CornerRadius = UDim.new(0, 10)}),
                create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                create_instance("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 10),
                    Size = UDim2.new(1, -28, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title:upper(),
                    TextColor3 = theme.text_dark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local content_frame = create_instance("Frame", {
                Parent = section_frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0)
            }, {
                create_instance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}),
                create_instance("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
            })

            local function resize_section()
                section_frame.Size = UDim2.new(1, 0, 0, content_frame.UIListLayout.AbsoluteContentSize.Y + 50)
            end

            content_frame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize_section)
            resize_section()

            function section_object:toggle(text, default, callback)
                if settings[text] ~= nil then default = settings[text] end
                local toggled = default or false
                local toggle_button = create_instance("TextButton", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -55, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    create_instance("Frame", {
                        Name = "Switch",
                        BackgroundColor3 = toggled and theme.accent or Color3.fromRGB(45, 45, 55),
                        Position = UDim2.new(1, -42, 0.5, -10),
                        Size = UDim2.new(0, 32, 0, 20)
                    }, {
                        create_instance("UICorner", {CornerRadius = UDim.new(1, 0)}),
                        create_instance("Frame", {
                            Name = "Knob",
                            BackgroundColor3 = theme.text,
                            Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16)
                        }, {create_instance("UICorner", {CornerRadius = UDim.new(1, 0)})})
                    })
                })

                if toggled then callback(toggled) end

                toggle_button.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    settings[text] = toggled
                    save_settings()
                    tween_object(toggle_button.Switch, {BackgroundColor3 = toggled and theme.accent or Color3.fromRGB(45, 45, 55)})
                    tween_object(toggle_button.Switch.Knob, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    callback(toggled)
                end)
            end

            function section_object:button(text, callback)
                local button_instance = create_instance("TextButton", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13
                    })
                })

                button_instance.MouseEnter:Connect(function() tween_object(button_instance, {BackgroundColor3 = theme.stroke}) end)
                button_instance.MouseLeave:Connect(function() tween_object(button_instance, {BackgroundColor3 = theme.main}) end)
                button_instance.MouseButton1Click:Connect(function() callback() end)
            end

            function section_object:slider(text, min, max, default, callback)
                if settings[text] ~= nil then default = settings[text] end
                local value = default or min
                local dragging_slider = false

                local slider_frame = create_instance("Frame", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 50)
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 8),
                        Size = UDim2.new(1, -24, 0, 15),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    create_instance("TextLabel", {
                        Name = "Val",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -52, 0, 8),
                        Size = UDim2.new(0, 40, 0, 15),
                        Font = Enum.Font.Gotham,
                        Text = tostring(value),
                        TextColor3 = theme.text_dark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Right
                    }),
                    create_instance("Frame", {
                        Name = "Track",
                        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                        Position = UDim2.new(0, 12, 0, 35),
                        Size = UDim2.new(1, -24, 0, 4)
                    }, {
                        create_instance("UICorner", {CornerRadius = UDim.new(1, 0)}),
                        create_instance("Frame", {
                            Name = "Fill",
                            BackgroundColor3 = theme.accent,
                            Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        }, {create_instance("UICorner", {CornerRadius = UDim.new(1, 0)})})
                    })
                })

                local track = slider_frame.Track
                if default then callback(value) end

                local function update_slider(input)
                    local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = math.floor((min + ((max - min) * percent)) * 10) / 10
                    slider_frame.Val.Text = tostring(value)
                    settings[text] = value
                    tween_object(track.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, TweenInfo.new(0.05))
                    callback(value)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging_slider = true
                        update_slider(input)
                    end
                end)

                user_input_service.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging_slider = false
                        save_settings()
                    end
                end)

                user_input_service.InputChanged:Connect(function(input)
                    if dragging_slider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        update_slider(input)
                    end
                end)
            end

            function section_object:textbox(text, placeholder, callback)
                local box_frame = create_instance("Frame", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38)
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    create_instance("TextBox", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.4, 10, 0, 0),
                        Size = UDim2.new(0.6, -22, 1, 0),
                        Font = Enum.Font.Gotham,
                        PlaceholderText = placeholder or "...",
                        PlaceholderColor3 = Color3.fromRGB(90, 90, 110),
                        Text = "",
                        TextColor3 = theme.accent,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        ClearTextOnFocus = false
                    })
                })

                if settings[text] then
                    box_frame.TextBox.Text = settings[text]
                    callback(settings[text])
                end

                box_frame.TextBox.FocusLost:Connect(function()
                    settings[text] = box_frame.TextBox.Text
                    save_settings()
                    callback(box_frame.TextBox.Text)
                end)
            end

            function section_object:keybind(text, default, callback)
                local key = default or Enum.KeyCode.E
                local mode = "Toggle"
                local is_binding = false
                local is_active = false

                if settings[text] then
                    if settings[text].key then
                        if pcall(function() return Enum.KeyCode[settings[text].key] end) then
                            key = Enum.KeyCode[settings[text].key]
                        elseif pcall(function() return Enum.UserInputType[settings[text].key] end) then
                            key = Enum.UserInputType[settings[text].key]
                        end
                    end
                    if settings[text].mode then mode = settings[text].mode end
                end

                local bind_frame = create_instance("Frame", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ZIndex = 2
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -60, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                })

                local bind_button = create_instance("TextButton", {
                    Parent = bind_frame,
                    BackgroundColor3 = theme.section,
                    Position = UDim2.new(1, -55, 0, 6),
                    Size = UDim2.new(0, 45, 0, 26),
                    Font = Enum.Font.Gotham,
                    Text = key.Name,
                    TextColor3 = theme.text_dark,
                    TextSize = 12,
                    AutoButtonColor = false
                }, {create_instance("UICorner", {CornerRadius = UDim.new(0, 6)}), create_instance("UIStroke", {Color = theme.stroke, Thickness = 1})})

                local context_menu = create_instance("Frame", {
                    Parent = bind_frame,
                    BackgroundColor3 = theme.main,
                    Position = UDim2.new(1, -60, 1, 5),
                    Size = UDim2.new(0, 50, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 200
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
                })

                local function make_mode_button(name, mode_val)
                    local btn = create_instance("TextButton", {
                        Parent = context_menu,
                        BackgroundColor3 = theme.main,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = name,
                        TextColor3 = (mode == mode_val) and theme.accent or theme.text_dark,
                        TextSize = 11,
                        AutoButtonColor = false,
                        ZIndex = 201
                    })

                    btn.MouseEnter:Connect(function() if mode ~= mode_val then btn.TextColor3 = theme.text end end)
                    btn.MouseLeave:Connect(function() if mode ~= mode_val then btn.TextColor3 = theme.text_dark end end)

                    btn.MouseButton1Click:Connect(function()
                        mode = mode_val
                        settings[text] = {key = key.Name, mode = mode}
                        save_settings()

                        context_menu.Visible = false
                        tween_object(context_menu, {Size = UDim2.new(0, 50, 0, 0)})
                        bind_frame.ZIndex = 2

                        for _, b in pairs(context_menu:GetChildren()) do
                            if b:IsA("TextButton") then
                                b.TextColor3 = (b.Text == mode) and theme.accent or theme.text_dark
                            end
                        end
                    end)
                end

                make_mode_button("Toggle", "Toggle")
                make_mode_button("Hold", "Hold")

                bind_button.MouseButton1Click:Connect(function()
                    is_binding = true
                    bind_button.Text = "..."
                    bind_button.TextColor3 = theme.accent
                end)

                bind_button.MouseButton2Click:Connect(function()
                    if context_menu.Visible then
                        tween_object(context_menu, {Size = UDim2.new(0, 50, 0, 0)})
                        task.delay(0.2, function() context_menu.Visible = false bind_frame.ZIndex = 2 end)
                    else
                        bind_frame.ZIndex = 100
                        context_menu.Visible = true
                        tween_object(context_menu, {Size = UDim2.new(0, 50, 0, 50)})
                    end
                end)

                user_input_service.InputBegan:Connect(function(input, processed)
                    if is_binding then
                        local binding_input
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            binding_input = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            binding_input = input.UserInputType
                        end

                        if binding_input and binding_input ~= Enum.KeyCode.Unknown then
                            key = binding_input
                            is_binding = false
                            bind_button.Text = key.Name
                            bind_button.TextColor3 = theme.text_dark
                            settings[text] = {key = key.Name, mode = mode}
                            save_settings()
                        end
                    elseif not processed then
                        local check_input = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                        if check_input == key then
                            if mode == "Toggle" then
                                is_active = not is_active
                                callback(is_active)
                            else
                                is_active = true
                                callback(true)
                            end
                        end
                    end
                end)

                user_input_service.InputEnded:Connect(function(input)
                    local check_input = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                    if check_input == key and mode == "Hold" then
                        is_active = false
                        callback(false)
                    end
                end)
            end

            function section_object:color_picker(text, default, callback)
                if settings[text] then
                    local c = settings[text]
                    default = Color3.new(c.r, c.g, c.b)
                end

                local current_color = default or Color3.fromRGB(255, 255, 255)
                local h, s, v = current_color:ToHSV()
                local is_expanded = false
                local dragging_color = false
                local dragging_hue = false

                local picker_frame = create_instance("Frame", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -60, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    create_instance("TextButton", {
                        Name = "Preview",
                        BackgroundColor3 = current_color,
                        Position = UDim2.new(1, -42, 0, 9),
                        Size = UDim2.new(0, 30, 0, 20),
                        Text = "",
                        AutoButtonColor = false
                    }, {create_instance("UICorner", {CornerRadius = UDim.new(0, 4)})})
                })

                local container_frame = create_instance("Frame", {
                    Parent = picker_frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 45),
                    Size = UDim2.new(1, -20, 0, 140),
                    Visible = false
                })

                local sv_box = create_instance("ImageButton", {
                    Parent = container_frame,
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    AutoButtonColor = false,
                    Image = ""
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    create_instance("Frame", {
                        Name = "Sat",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 2
                    }, {
                        create_instance("UICorner", {CornerRadius = UDim.new(0, 4)}),
                        create_instance("UIGradient", {
                            Color = ColorSequence.new(Color3.new(1, 1, 1)),
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            }
                        })
                    }),
                    create_instance("Frame", {
                        Name = "Val",
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 3
                    }, {
                        create_instance("UICorner", {CornerRadius = UDim.new(0, 4)}),
                        create_instance("UIGradient", {
                            Rotation = 90,
                            Color = ColorSequence.new(Color3.new(0, 0, 0)),
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0)
                            }
                        })
                    }),
                    create_instance("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(s, -4, 1 - v, -4),
                        ZIndex = 4
                    }, {create_instance("UICorner", {CornerRadius = UDim.new(1, 0)}), create_instance("UIStroke", {Thickness = 1, Color = Color3.new(0, 0, 0)})})
                })

                local hue_bar = create_instance("ImageButton", {
                    Parent = container_frame,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(1, -15, 0, 0),
                    Size = UDim2.new(0, 15, 1, 0),
                    AutoButtonColor = false
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    create_instance("UIGradient", {Rotation = 90, Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.834, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
                    }}),
                    create_instance("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.new(1, 4, 0, 4),
                        Position = UDim2.new(0.5, 0, 1 - h, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BorderSizePixel = 0
                    }, {create_instance("UIStroke", {Thickness = 1, Color = Color3.new(0, 0, 0)})})
                })

                if default then callback(current_color) end

                local function update_color()
                    current_color = Color3.fromHSV(h, s, v)
                    picker_frame.Preview.BackgroundColor3 = current_color
                    sv_box.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    settings[text] = {r = current_color.R, g = current_color.G, b = current_color.B}
                    callback(current_color)
                end

                sv_box.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging_color = true
                    end
                end)

                hue_bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging_hue = true
                    end
                end)

                user_input_service.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging_color = false
                        dragging_hue = false
                        save_settings()
                    end
                end)

                user_input_service.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                        if dragging_color then
                            local size = sv_box.AbsoluteSize
                            local pos = sv_box.AbsolutePosition
                            local x = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                            local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                            s = x
                            v = 1 - y
                            sv_box.Cursor.Position = UDim2.new(s, -4, 1 - v, -4)
                            update_color()
                        elseif dragging_hue then
                            local size = hue_bar.AbsoluteSize
                            local pos = hue_bar.AbsolutePosition
                            local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                            h = 1 - y
                            hue_bar.Cursor.Position = UDim2.new(0.5, 0, y, 0)
                            update_color()
                        end
                    end
                end)

                picker_frame.Preview.MouseButton1Click:Connect(function()
                    is_expanded = not is_expanded
                    container_frame.Visible = is_expanded
                    tween_object(picker_frame, {Size = UDim2.new(1, 0, 0, is_expanded and 200 or 38)})
                end)
            end

            function section_object:dropdown(text, list, default, callback)
                if settings[text] then default = settings[text] end
                local selected_item = default or list[1]
                local is_expanded = false

                local drop_frame = create_instance("Frame", {
                    Parent = content_frame,
                    BackgroundColor3 = theme.main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true,
                    ZIndex = 5
                }, {
                    create_instance("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    create_instance("UIStroke", {Color = theme.stroke, Thickness = 1}),
                    create_instance("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0.5, 0, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = theme.text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    create_instance("TextLabel", {
                        Name = "Val",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0.5, -35, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = selected_item,
                        TextColor3 = theme.accent,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right
                    }),
                    create_instance("ImageButton", {
                        Name = "Arrow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 19),
                        Size = UDim2.new(0, 16, 0, 16),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Image = "rbxassetid://6031091004",
                        ImageColor3 = theme.text_dark,
                        ZIndex = 6
                    }),
                    create_instance("Frame", {
                        Name = "List",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 38),
                        Size = UDim2.new(1, 0, 0, 0)
                    }, {
                        create_instance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
                    })
                })

                if default then callback(selected_item) end

                for _, item in pairs(list) do
                    local item_button = create_instance("TextButton", {
                        Parent = drop_frame.List,
                        BackgroundColor3 = theme.main,
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. item,
                        TextColor3 = theme.text_dark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 6
                    })

                    item_button.MouseEnter:Connect(function()
                        tween_object(item_button, {BackgroundColor3 = theme.section, TextColor3 = theme.text})
                    end)
                    item_button.MouseLeave:Connect(function()
                        tween_object(item_button, {BackgroundColor3 = theme.main, TextColor3 = theme.text_dark})
                    end)

                    item_button.MouseButton1Click:Connect(function()
                        selected_item = item
                        drop_frame.Val.Text = selected_item
                        is_expanded = false
                        settings[text] = selected_item
                        save_settings()
                        tween_object(drop_frame, {Size = UDim2.new(1, 0, 0, 38)})
                        tween_object(drop_frame.Arrow, {Rotation = 0})
                        callback(item)
                    end)
                end

                drop_frame.Arrow.MouseButton1Click:Connect(function()
                    is_expanded = not is_expanded
                    tween_object(drop_frame, {Size = UDim2.new(1, 0, 0, is_expanded and (38 + #list * 30) or 38)})
                    tween_object(drop_frame.Arrow, {Rotation = is_expanded and 180 or 0})
                end)
            end

            return section_object
        end
        return tab_object
    end
    return window_object
end

return phantom
