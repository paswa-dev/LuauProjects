local Types = require(script.Parent.Parent.Types)

return function(Iris: Types.Internal, widgets: Types.WidgetUtility)
    local numberChanged = {
        ["Init"] = function(_thisWidget: Types.Widget) end,
        ["Get"] = function(thisWidget: Types.Widget)
            return thisWidget.lastNumberChangedTick == Iris._cycleTick
        end,
    }

    local function getValueByIndex(value: Types.InputDataType, index: number, arguments: Types.Arguments): number
        if typeof(value) == "number" then
            return value
        elseif typeof(value) == "Vector2" then
            if index == 1 then
                return value.X
            elseif index == 2 then
                return value.Y
            end
        elseif typeof(value) == "Vector3" then
            if index == 1 then
                return value.X
            elseif index == 2 then
                return value.Y
            elseif index == 3 then
                return value.Z
            end
        elseif typeof(value) == "UDim" then
            if index == 1 then
                return value.Scale
            elseif index == 2 then
                return value.Offset
            end
        elseif typeof(value) == "UDim2" then
            if index == 1 then
                return value.X.Scale
            elseif index == 2 then
                return value.X.Offset
            elseif index == 3 then
                return value.Y.Scale
            elseif index == 4 then
                return value.Y.Offset
            end
        elseif typeof(value) == "Color3" then
            local color: { number } = arguments.UseHSV and { value:ToHSV() } or { value.R, value.G, value.B }
            if index == 1 then
                return color[1]
            elseif index == 2 then
                return color[2]
            elseif index == 3 then
                return color[3]
            end
        elseif typeof(value) == "Rect" then
            if index == 1 then
                return value.Min.X
            elseif index == 2 then
                return value.Min.Y
            elseif index == 3 then
                return value.Max.X
            elseif index == 4 then
                return value.Max.Y
            end
        elseif typeof(value) == "table" then
            return value[index]
        end

        error(`Incorrect datatype or value: {value} {typeof(value)} {index}`)
    end

    local function updateValueByIndex(value: Types.InputDataType, index: number, newValue: number, arguments: Types.Arguments): Types.InputDataType
        if typeof(value) == "number" then
            return newValue
        elseif typeof(value) == "Vector2" then
            if index == 1 then
                return Vector2.new(newValue, value.Y)
            elseif index == 2 then
                return Vector2.new(value.X, newValue)
            end
        elseif typeof(value) == "Vector3" then
            if index == 1 then
                return Vector3.new(newValue, value.Y, value.Z)
            elseif index == 2 then
                return Vector3.new(value.X, newValue, value.Z)
            elseif index == 3 then
                return Vector3.new(value.X, value.Y, newValue)
            end
        elseif typeof(value) == "UDim" then
            if index == 1 then
                return UDim.new(newValue, value.Offset)
            elseif index == 2 then
                return UDim.new(value.Scale, newValue)
            end
        elseif typeof(value) == "UDim2" then
            if index == 1 then
                return UDim2.new(UDim.new(newValue, value.X.Offset), value.Y)
            elseif index == 2 then
                return UDim2.new(UDim.new(value.X.Scale, newValue), value.Y)
            elseif index == 3 then
                return UDim2.new(value.X, UDim.new(newValue, value.Y.Offset))
            elseif index == 4 then
                return UDim2.new(value.X, UDim.new(value.Y.Scale, newValue))
            end
        elseif typeof(value) == "Rect" then
            if index == 1 then
                return Rect.new(Vector2.new(newValue, value.Min.Y), value.Max)
            elseif index == 2 then
                return Rect.new(Vector2.new(value.Min.X, newValue), value.Max)
            elseif index == 3 then
                return Rect.new(value.Min, Vector2.new(newValue, value.Max.Y))
            elseif index == 4 then
                return Rect.new(value.Min, Vector2.new(value.Max.X, newValue))
            end
        elseif typeof(value) == "Color3" then
            if arguments.UseHSV then
                local h: number, s: number, v: number = value:ToHSV()
                if index == 1 then
                    return Color3.fromHSV(newValue, s, v)
                elseif index == 2 then
                    return Color3.fromHSV(h, newValue, v)
                elseif index == 3 then
                    return Color3.fromHSV(h, s, newValue)
                end
            end
            if index == 1 then
                return Color3.new(newValue, value.G, value.B)
            elseif index == 2 then
                return Color3.new(value.R, newValue, value.B)
            elseif index == 3 then
                return Color3.new(value.R, value.G, newValue)
            end
        end

        error(`Incorrect datatype or value {value} {typeof(value)} {index}`)
    end

    local defaultIncrements: { [Types.InputDataTypes]: { number } } = {
        Num = { 1 },
        Vector2 = { 1, 1 },
        Vector3 = { 1, 1, 1 },
        UDim = { 0.01, 1 },
        UDim2 = { 0.01, 1, 0.01, 1 },
        Color3 = { 1, 1, 1 },
        Color4 = { 1, 1, 1, 1 },
        Rect = { 1, 1, 1, 1 },
    }

    local defaultMin: { [Types.InputDataTypes]: { number } } = {
        Num = { 0 },
        Vector2 = { 0, 0 },
        Vector3 = { 0, 0, 0 },
        UDim = { 0, 0 },
        UDim2 = { 0, 0, 0, 0 },
        Rect = { 0, 0, 0, 0 },
    }

    local defaultMax: { [Types.InputDataTypes]: { number } } = {
        Num = { 100 },
        Vector2 = { 100, 100 },
        Vector3 = { 100, 100, 100 },
        UDim = { 1, 960 },
        UDim2 = { 1, 960, 1, 960 },
        Rect = { 960, 960, 960, 960 },
    }

    local defaultPrefx: { [Types.InputDataTypes]: { string } } = {
        Num = { "" },
        Vector2 = { "X: ", "Y: " },
        Vector3 = { "X: ", "Y: ", "Z: " },
        UDim = { "", "" },
        UDim2 = { "", "", "", "" },
        Color3_RGB = { "R: ", "G: ", "B: " },
        Color3_HSV = { "H: ", "S: ", "V: " },
        Color4_RGB = { "R: ", "G: ", "B: ", "T: " },
        Color4_HSV = { "H: ", "S: ", "V: ", "T: " },
        Rect = { "X: ", "Y: ", "X: ", "Y: " },
    }

    local defaultSigFigs: { [Types.InputDataTypes]: { number } } = {
        Num = { 0 },
        Vector2 = { 0, 0 },
        Vector3 = { 0, 0, 0 },
        UDim = { 3, 0 },
        UDim2 = { 3, 0, 3, 0 },
        Color3 = { 0, 0, 0 },
        Color4 = { 0, 0, 0, 0 },
        Rect = { 0, 0, 0, 0 },
    }

    --[[
        Input
    ]]
    local generateInputScalar: (dataType: Types.InputDataTypes, components: number, defaultValue: any) -> Types.WidgetClass
    do
        local function generateButtons(thisWidget: Types.Widget, parent: GuiObject, rightPadding: number, textHeight: number)
            rightPadding += 2 * Iris._config.ItemInnerSpacing.X + 2 * textHeight

            local SubButton = widgets.abstractButton.Generate(thisWidget) :: TextButton
            SubButton.Name = "SubButton"
            SubButton.ZIndex = thisWidget.ZIndex + 5
            SubButton.LayoutOrder = thisWidget.ZIndex + 5
            SubButton.TextXAlignment = Enum.TextXAlignment.Center
            SubButton.Text = "-"
            SubButton.Size = UDim2.fromOffset(Iris._config.TextSize + 2 * Iris._config.FramePadding.Y, Iris._config.TextSize)
            SubButton.Parent = parent

            widgets.applyButtonClick(thisWidget, SubButton, function()
                local isCtrlHeld: boolean = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                local changeValue: number = (thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, 1, thisWidget.arguments) or 1) * (isCtrlHeld and 100 or 1)
                local newValue: number = thisWidget.state.number.value - changeValue
                if thisWidget.arguments.Min ~= nil then
                    newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, 1, thisWidget.arguments))
                end
                if thisWidget.arguments.Max ~= nil then
                    newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, 1, thisWidget.arguments))
                end
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumberChangedTick = Iris._cycleTick + 1
            end)

            local AddButton = widgets.abstractButton.Generate(thisWidget) :: TextButton
            AddButton.Name = "AddButton"
            AddButton.ZIndex = thisWidget.ZIndex + 6
            AddButton.LayoutOrder = thisWidget.ZIndex + 6
            AddButton.TextXAlignment = Enum.TextXAlignment.Center
            AddButton.Text = "+"
            AddButton.Size = UDim2.fromOffset(Iris._config.TextSize + 2 * Iris._config.FramePadding.Y, Iris._config.TextSize)
            AddButton.Parent = parent

            widgets.applyButtonClick(thisWidget, AddButton, function()
                local isCtrlHeld: boolean = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                local changeValue: number = (thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, 1, thisWidget.arguments) or 1) * (isCtrlHeld and 100 or 1)
                local newValue: number = thisWidget.state.number.value + changeValue
                if thisWidget.arguments.Min ~= nil then
                    newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, 1, thisWidget.arguments))
                end
                if thisWidget.arguments.Max ~= nil then
                    newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, 1, thisWidget.arguments))
                end
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumberChangedTick = Iris._cycleTick + 1
            end)

            return rightPadding
        end

        function generateInputScalar(dataType: Types.InputDataTypes, components: number, defaultValue: any)
            return {
                hasState = true,
                hasChildren = false,
                Args = {
                    ["Text"] = 1,
                    ["Increment"] = 2,
                    ["Min"] = 3,
                    ["Max"] = 4,
                    ["Format"] = 5,
                },
                Events = {
                    ["numberChanged"] = numberChanged,
                    ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                        return thisWidget.Instance
                    end),
                },
                Generate = function(thisWidget: Types.Widget)
                    local Input: Frame = Instance.new("Frame")
                    Input.Name = "Iris_Input" .. dataType
                    Input.Size = UDim2.fromScale(1, 0)
                    Input.BackgroundTransparency = 1
                    Input.BorderSizePixel = 0
                    Input.ZIndex = thisWidget.ZIndex
                    Input.LayoutOrder = thisWidget.ZIndex
                    Input.AutomaticSize = Enum.AutomaticSize.Y
                    widgets.UIListLayout(Input, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

                    -- we add plus and minus buttons if there is only one box. This can be disabled through the argument.
                    local rightPadding: number = 0
                    local textHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

                    if components == 1 then
                        rightPadding = generateButtons(thisWidget, Input, rightPadding, textHeight)
                    end

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth: UDim = UDim.new(Iris._config.ContentWidth.Scale / components, (Iris._config.ContentWidth.Offset - (Iris._config.ItemInnerSpacing.X * (components - 1)) - rightPadding) / components)
                    local totalWidth: UDim = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Iris._config.ItemInnerSpacing.X * (components - 1)) + rightPadding)
                    local lastComponentWidth: UDim = Iris._config.ContentWidth - totalWidth

                    -- we handle each component individually since they don't need to interact with each other.
                    for index = 1, components do
                        local InputField: TextBox = Instance.new("TextBox")
                        InputField.Name = "InputField" .. tostring(index)
                        InputField.ZIndex = thisWidget.ZIndex + index
                        InputField.LayoutOrder = thisWidget.ZIndex + index
                        if index == components then
                            InputField.Size = UDim2.new(lastComponentWidth, UDim.new())
                        else
                            InputField.Size = UDim2.new(componentWidth, UDim.new())
                        end
                        InputField.AutomaticSize = Enum.AutomaticSize.Y
                        InputField.BackgroundColor3 = Iris._config.FrameBgColor
                        InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
                        InputField.ClearTextOnFocus = false
                        InputField.TextTruncate = Enum.TextTruncate.AtEnd
                        InputField.ClipsDescendants = true

                        widgets.applyFrameStyle(InputField)
                        widgets.applyTextStyle(InputField)
                        widgets.UISizeConstraint(InputField, Vector2.new(1, 0))

                        InputField.Parent = Input

                        InputField.FocusLost:Connect(function()
                            local newValue: number? = tonumber(InputField.Text:match("-?%d*%.?%d*"))
                            if newValue ~= nil then
                                if thisWidget.arguments.Min ~= nil then
                                    newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments))
                                end
                                if thisWidget.arguments.Max ~= nil then
                                    newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments))
                                end

                                if thisWidget.arguments.Increment then
                                    newValue = math.round(newValue / getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)) * getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                end

                                thisWidget.state.number:set(updateValueByIndex(thisWidget.state.number.value, index, newValue, thisWidget.arguments))
                                thisWidget.lastNumberChangedTick = Iris._cycleTick + 1
                            end
                            local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                            if thisWidget.arguments.Prefix then
                                format = thisWidget.arguments.Prefix[index] .. format
                            end
                            InputField.Text = string.format(format, getValueByIndex(thisWidget.state.number.value, index, thisWidget.arguments))

                            thisWidget.state.editingText:set(0)
                        end)

                        InputField.Focused:Connect(function()
                            -- this highlights the entire field
                            InputField.CursorPosition = #InputField.Text + 1
                            InputField.SelectionStart = 1

                            thisWidget.state.editingText:set(index)
                        end)
                    end

                    local TextLabel: TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.Size = UDim2.fromOffset(0, textHeight)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.ZIndex = thisWidget.ZIndex + 7
                    TextLabel.LayoutOrder = thisWidget.ZIndex + 7
                    TextLabel.AutomaticSize = Enum.AutomaticSize.X

                    widgets.applyTextStyle(TextLabel)

                    TextLabel.Parent = Input

                    return Input
                end,
                Update = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or `Input {dataType}`

                    if components == 1 then
                        Input.SubButton.Visible = not thisWidget.arguments.NoButtons
                        Input.AddButton.Visible = not thisWidget.arguments.NoButtons
                    end

                    if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                        thisWidget.arguments.Format = { thisWidget.arguments.Format }
                    elseif not thisWidget.arguments.Format then
                        -- we calculate the format for the s.f. using the max, min and increment arguments.
                        local format: { string } = {}
                        for index = 1, components do
                            local sigfigs: number = defaultSigFigs[dataType][index]

                            if thisWidget.arguments.Increment then
                                local value: number = getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Max then
                                local value: number = getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Min then
                                local value: number = getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if sigfigs > 0 then
                                -- we know it's a float.
                                format[index] = `%.{sigfigs}f`
                            else
                                format[index] = "%d"
                            end
                        end

                        thisWidget.arguments.Format = format
                        thisWidget.arguments.Prefix = defaultPrefx[dataType]
                    end
                end,
                Discard = function(thisWidget: Types.Widget)
                    thisWidget.Instance:Destroy()
                    widgets.discardState(thisWidget)
                end,
                GenerateState = function(thisWidget: Types.Widget)
                    if thisWidget.state.number == nil then
                        thisWidget.state.number = Iris._widgetState(thisWidget, "number", defaultValue)
                    end
                    if thisWidget.state.editingText == nil then
                        thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", 0)
                    end
                end,
                UpdateState = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject

                    for index = 1, components do
                        local InputField: TextBox = Input:FindFirstChild("InputField" .. tostring(index))
                        local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                        if thisWidget.arguments.Prefix then
                            format = thisWidget.arguments.Prefix[index] .. format
                        end
                        InputField.Text = string.format(format, getValueByIndex(thisWidget.state.number.value, index, thisWidget.arguments))
                    end
                end,
            }
        end
    end

    --[[
        Drag
    ]]
    local generateDragScalar: (dataType: Types.InputDataTypes, components: number, defaultValue: any) -> Types.WidgetClass
    local generateColorDragScalar: (dataType: Types.InputDataTypes, ...any) -> Types.WidgetClass
    do
        local PreviouseMouseXPosition: number = 0
        local AnyActiveDrag: boolean = false
        local ActiveDrag: Types.Widget? = nil
        local ActiveIndex: number = 0
        local ActiveDataType: Types.InputDataTypes | "" = ""

        local function updateActiveDrag()
            local currentMouseX: number = widgets.getMouseLocation().X
            local mouseXDelta: number = currentMouseX - PreviouseMouseXPosition
            PreviouseMouseXPosition = currentMouseX
            if AnyActiveDrag == false then
                return
            end
            if ActiveDrag == nil then
                return
            end

            local state: Types.State = ActiveDrag.state.number
            if ActiveDataType == "Color3" or ActiveDataType == "Color4" then
                state = ActiveDrag.state.color
                if ActiveIndex == 4 then
                    state = ActiveDrag.state.transparency
                end
            end

            local increment: number = ActiveDrag.arguments.Increment and getValueByIndex(ActiveDrag.arguments.Increment, ActiveIndex, ActiveDrag.arguments) or defaultIncrements[ActiveDataType][ActiveIndex]
            increment *= (widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1
            increment *= (widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1
            -- we increase the speed for Color3 and Color4 since it's too slow because the increment argument needs to be low.
            increment *= (ActiveDataType == "Color3" or ActiveDataType == "Color4") and 5 or 1

            local value: number = getValueByIndex(state.value, ActiveIndex, ActiveDrag.arguments)
            local newValue: number = value + (mouseXDelta * increment)

            if ActiveDrag.arguments.Min ~= nil then
                newValue = math.max(newValue, getValueByIndex(ActiveDrag.arguments.Min, ActiveIndex, ActiveDrag.arguments))
            end
            if ActiveDrag.arguments.Max ~= nil then
                newValue = math.min(newValue, getValueByIndex(ActiveDrag.arguments.Max, ActiveIndex, ActiveDrag.arguments))
            end

            state:set(updateValueByIndex(state.value, ActiveIndex, newValue, ActiveDrag.arguments))
            ActiveDrag.lastNumberChangedTick = Iris._cycleTick + 1
        end

        local function DragMouseDown(thisWidget: Types.Widget, dataTypes: Types.InputDataTypes, index: number, x: number, y: number)
            local currentTime: number = widgets.getTime()
            local isTimeValid: boolean = currentTime - thisWidget.lastClickedTime < Iris._config.MouseDoubleClickTime
            local isCtrlHeld: boolean = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            if (isTimeValid and (Vector2.new(x, y) - thisWidget.lastClickedPosition).Magnitude < Iris._config.MouseDoubleClickMaxDist) or isCtrlHeld then
                thisWidget.state.editingText:set(index)
            else
                thisWidget.lastClickedTime = currentTime
                thisWidget.lastClickedPosition = Vector2.new(x, y)

                AnyActiveDrag = true
                ActiveDrag = thisWidget
                ActiveIndex = index
                ActiveDataType = dataTypes
                updateActiveDrag()
            end
        end

        widgets.registerEvent("InputChanged", function()
            if not Iris._started then
                return
            end
            updateActiveDrag()
        end)

        widgets.registerEvent("InputEnded", function(inputObject: InputObject)
            if not Iris._started then
                return
            end
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveDrag then
                AnyActiveDrag = false
                ActiveDrag = nil
                ActiveIndex = 0
            end
        end)

        function generateDragScalar(dataType: Types.InputDataTypes, components: number, defaultValue: any)
            return {
                hasState = true,
                hasChildren = false,
                Args = {
                    ["Text"] = 1,
                    ["Increment"] = 2,
                    ["Min"] = 3,
                    ["Max"] = 4,
                    ["Format"] = 5,
                },
                Events = {
                    ["numberChanged"] = numberChanged,
                    ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                        return thisWidget.Instance
                    end),
                },
                Generate = function(thisWidget: Types.Widget)
                    thisWidget.lastClickedTime = -1
                    thisWidget.lastClickedPosition = Vector2.zero

                    local Drag: Frame = Instance.new("Frame")
                    Drag.Name = "Iris_Drag" .. dataType
                    Drag.Size = UDim2.fromScale(1, 0)
                    Drag.BackgroundTransparency = 1
                    Drag.BorderSizePixel = 0
                    Drag.ZIndex = thisWidget.ZIndex
                    Drag.LayoutOrder = thisWidget.ZIndex
                    Drag.AutomaticSize = Enum.AutomaticSize.Y
                    widgets.UIListLayout(Drag, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

                    -- we add a color box if it is Color3 or Color4.
                    local rightPadding: number = 0
                    local textHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

                    if dataType == "Color3" or dataType == "Color4" then
                        rightPadding += Iris._config.ItemInnerSpacing.X + textHeight

                        local ColorBox: ImageLabel = Instance.new("ImageLabel")
                        ColorBox.Name = "ColorBox"
                        ColorBox.BorderSizePixel = 0
                        ColorBox.Size = UDim2.fromOffset(textHeight, textHeight)
                        ColorBox.ZIndex = thisWidget.ZIndex + 5
                        ColorBox.LayoutOrder = thisWidget.ZIndex + 5
                        ColorBox.Image = widgets.ICONS.ALPHA_BACKGROUND_TEXTURE
                        ColorBox.ImageTransparency = 1

                        widgets.applyFrameStyle(ColorBox, true, true)

                        ColorBox.Parent = Drag
                    end

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth: UDim = UDim.new(Iris._config.ContentWidth.Scale / components, (Iris._config.ContentWidth.Offset - (Iris._config.ItemInnerSpacing.X * (components - 1)) - rightPadding) / components)
                    local totalWidth: UDim = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Iris._config.ItemInnerSpacing.X * (components - 1)) + rightPadding)
                    local lastComponentWidth: UDim = Iris._config.ContentWidth - totalWidth

                    for index = 1, components do
                        local DragField: TextButton = Instance.new("TextButton")
                        DragField.Name = "DragField" .. tostring(index)
                        DragField.ZIndex = thisWidget.ZIndex + index
                        DragField.LayoutOrder = thisWidget.ZIndex + index
                        if index == components then
                            DragField.Size = UDim2.new(lastComponentWidth, UDim.new())
                        else
                            DragField.Size = UDim2.new(componentWidth, UDim.new())
                        end
                        DragField.AutomaticSize = Enum.AutomaticSize.Y
                        DragField.BackgroundColor3 = Iris._config.FrameBgColor
                        DragField.BackgroundTransparency = Iris._config.FrameBgTransparency
                        DragField.AutoButtonColor = false
                        DragField.Text = ""
                        DragField.ClipsDescendants = true

                        widgets.applyFrameStyle(DragField)
                        widgets.applyTextStyle(DragField)
                        widgets.UISizeConstraint(DragField, Vector2.new(1, 0))

                        DragField.TextXAlignment = Enum.TextXAlignment.Center

                        DragField.Parent = Drag

                        widgets.applyInteractionHighlights(thisWidget, DragField, DragField, {
                            ButtonColor = Iris._config.FrameBgColor,
                            ButtonTransparency = Iris._config.FrameBgTransparency,
                            ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                            ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                            ButtonActiveColor = Iris._config.FrameBgActiveColor,
                            ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                        })

                        local InputField: TextBox = Instance.new("TextBox")
                        InputField.Name = "InputField"
                        InputField.ZIndex = thisWidget.ZIndex + 5
                        InputField.LayoutOrder = thisWidget.ZIndex + 2
                        InputField.Size = UDim2.new(1, 0, 1, 0)
                        InputField.BackgroundTransparency = 1
                        InputField.ClearTextOnFocus = false
                        InputField.TextTruncate = Enum.TextTruncate.AtEnd
                        InputField.ClipsDescendants = true
                        InputField.Visible = false

                        widgets.applyFrameStyle(InputField, true)
                        widgets.applyTextStyle(InputField)

                        InputField.Parent = DragField

                        InputField.FocusLost:Connect(function()
                            local newValue: number? = tonumber(InputField.Text:match("-?%d*%.?%d*"))
                            local state: Types.State = thisWidget.state.number
                            if dataType == "Color4" and index == 4 then
                                state = thisWidget.state.transparency
                            elseif dataType == "Color3" or dataType == "Color4" then
                                state = thisWidget.state.color
                            end
                            if newValue ~= nil then
                                if dataType == "Color3" or dataType == "Color4" and not thisWidget.arguments.UseFloats then
                                    newValue = newValue / 255
                                end
                                if thisWidget.arguments.Min ~= nil then
                                    newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments))
                                end
                                if thisWidget.arguments.Max ~= nil then
                                    newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments))
                                end

                                if thisWidget.arguments.Increment then
                                    newValue = math.round(newValue / getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)) * getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                end

                                state:set(updateValueByIndex(state.value, index, newValue, thisWidget.arguments))
                                thisWidget.lastNumberChangedTick = Iris._cycleTick + 1
                            end

                            local value: number = getValueByIndex(state.value, index, thisWidget.arguments)
                            if dataType == "Color3" or dataType == "Color4" and not thisWidget.arguments.UseFloats then
                                value = math.round(value * 255)
                            end

                            local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                            if thisWidget.arguments.Prefix then
                                format = thisWidget.arguments.Prefix[index] .. format
                            end
                            InputField.Text = string.format(format, value)

                            thisWidget.state.editingText:set(0)
                            InputField:ReleaseFocus(true)
                        end)

                        InputField.Focused:Connect(function()
                            -- this highlights the entire field
                            InputField.CursorPosition = #InputField.Text + 1
                            InputField.SelectionStart = 1

                            thisWidget.state.editingText:set(index)
                        end)

                        widgets.applyButtonDown(thisWidget, DragField, function(x: number, y: number)
                            DragMouseDown(thisWidget, dataType, index, x, y)
                        end)
                    end

                    local TextLabel: TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.Size = UDim2.fromOffset(0, textHeight)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.ZIndex = thisWidget.ZIndex + 5
                    TextLabel.LayoutOrder = thisWidget.ZIndex + 5
                    TextLabel.AutomaticSize = Enum.AutomaticSize.X

                    widgets.applyTextStyle(TextLabel)

                    TextLabel.Parent = Drag

                    return Drag
                end,
                Update = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or `Drag {dataType}`

                    if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                        thisWidget.arguments.Format = { thisWidget.arguments.Format }
                    elseif not thisWidget.arguments.Format then
                        -- we calculate the format for the s.f. using the max, min and increment arguments.
                        local format: { string } = {}
                        for index = 1, components do
                            local sigfigs: number = defaultSigFigs[dataType][index]

                            if thisWidget.arguments.Increment then
                                local value: number = getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Max then
                                local value: number = getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Min then
                                local value: number = getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if sigfigs > 0 then
                                -- we know it's a float.
                                format[index] = `%.{sigfigs}f`
                            else
                                format[index] = "%d"
                            end
                        end

                        thisWidget.arguments.Format = format
                        thisWidget.arguments.Prefix = defaultPrefx[dataType]
                    end
                end,
                Discard = function(thisWidget: Types.Widget)
                    thisWidget.Instance:Destroy()
                    widgets.discardState(thisWidget)
                end,
                GenerateState = function(thisWidget: Types.Widget)
                    if thisWidget.state.number == nil then
                        thisWidget.state.number = Iris._widgetState(thisWidget, "number", defaultValue)
                    end
                    if thisWidget.state.editingText == nil then
                        thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                    end
                end,
                UpdateState = function(thisWidget: Types.Widget)
                    local Drag = thisWidget.Instance :: Frame

                    for index = 1, components do
                        local state: Types.State = thisWidget.state.number
                        if dataType == "Color3" or dataType == "Color4" then
                            state = thisWidget.state.color
                            if index == 4 then
                                state = thisWidget.state.transparency
                            end
                        end
                        local DragField = Drag:FindFirstChild("DragField" .. tostring(index)) :: TextButton
                        local InputField: TextBox = DragField.InputField
                        local value: number = getValueByIndex(state.value, index, thisWidget.arguments)
                        if (dataType == "Color3" or dataType == "Color4") and not thisWidget.arguments.UseFloats then
                            value = math.round(value * 255)
                        end

                        local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                        if thisWidget.arguments.Prefix then
                            format = thisWidget.arguments.Prefix[index] .. format
                        end
                        DragField.Text = string.format(format, value)
                        InputField.Text = tostring(value)

                        if thisWidget.state.editingText.value == index then
                            InputField.Visible = true
                            InputField:CaptureFocus()
                            DragField.TextTransparency = 1
                        else
                            InputField.Visible = false
                            DragField.TextTransparency = Iris._config.TextTransparency
                        end
                    end

                    if dataType == "Color3" or dataType == "Color4" then
                        local ColorBox: ImageLabel = Drag.ColorBox

                        ColorBox.BackgroundColor3 = thisWidget.state.color.value

                        if dataType == "Color4" then
                            ColorBox.ImageTransparency = 1 - thisWidget.state.transparency.value
                        end
                    end
                end,
            }
        end

        function generateColorDragScalar(dataType: Types.InputDataTypes, ...: any)
            local defaultValues: { any } = { ... }
            local input: Types.WidgetClass = generateDragScalar(dataType, dataType == "Color4" and 4 or 3, defaultValues[1])

            return widgets.extend(input, {
                Args = {
                    ["Text"] = 1,
                    ["UseFloats"] = 2,
                    ["UseHSV"] = 3,
                    ["Format"] = 4,
                },
                Update = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or `Drag {dataType}`

                    if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                        thisWidget.arguments.Format = { thisWidget.arguments.Format }
                    elseif not thisWidget.arguments.Format then
                        if thisWidget.arguments.UseFloats then
                            thisWidget.arguments.Format = { "%.3f" }
                        else
                            thisWidget.arguments.Format = { "%d" }
                        end

                        thisWidget.arguments.Prefix = defaultPrefx[dataType .. if thisWidget.arguments.UseHSV then "_HSV" else "_RGB"]
                    end

                    thisWidget.arguments.Min = { 0, 0, 0, 0 }
                    thisWidget.arguments.Max = { 1, 1, 1, 1 }
                    thisWidget.arguments.Increment = { 0.001, 0.001, 0.001, 0.001 }

                    -- since the state values have changed display, we call an update. The check is because state is not
                    -- initialised on creation, so it would error otherwise.
                    if thisWidget.state then
                        Iris._widgets[thisWidget.type].UpdateState(thisWidget)
                    end
                end,
                GenerateState = function(thisWidget: Types.Widget)
                    if thisWidget.state.color == nil then
                        thisWidget.state.color = Iris._widgetState(thisWidget, "color", defaultValues[1])
                    end
                    if dataType == "Color4" then
                        if thisWidget.state.transparency == nil then
                            thisWidget.state.transparency = Iris._widgetState(thisWidget, "transparency", defaultValues[2])
                        end
                    end
                    if thisWidget.state.editingText == nil then
                        thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                    end
                end,
            })
        end
    end

    --[[
        Slider
    ]]
    local generateSliderScalar: (dataType: Types.InputDataTypes, components: number, defaultValue: any) -> Types.WidgetClass
    local generateEnumSliderScalar: (enum: Enum, item: EnumItem) -> Types.WidgetClass
    do
        local AnyActiveSlider: boolean = false
        local ActiveSlider: Types.Widget? = nil
        local ActiveIndex: number = 0
        local ActiveDataType: Types.InputDataTypes | "" = ""

        local function updateActiveSlider()
            if AnyActiveSlider == false then
                return
            end
            if ActiveSlider == nil then
                return
            end

            local Slider = ActiveSlider.Instance :: Frame
            local SliderField = Slider:FindFirstChild("SliderField" .. tostring(ActiveIndex)) :: TextButton
            local GrabBar: Frame = SliderField.GrabBar

            local increment: number = ActiveSlider.arguments.Increment and getValueByIndex(ActiveSlider.arguments.Increment, ActiveIndex, ActiveSlider.arguments) or defaultIncrements[ActiveDataType][ActiveIndex]
            local min: number = ActiveSlider.arguments.Min and getValueByIndex(ActiveSlider.arguments.Min, ActiveIndex, ActiveSlider.arguments) or defaultMin[ActiveDataType][ActiveIndex]
            local max: number = ActiveSlider.arguments.Max and getValueByIndex(ActiveSlider.arguments.Max, ActiveIndex, ActiveSlider.arguments) or defaultMax[ActiveDataType][ActiveIndex]

            local GrabWidth: number = GrabBar.AbsoluteSize.X
            local Offset: number = widgets.getMouseLocation().X - (SliderField.AbsolutePosition.X + GrabWidth / 2)
            local Ratio: number = Offset / (SliderField.AbsoluteSize.X - GrabWidth)
            local Positions: number = math.floor((max - min) / increment)
            local newValue: number = math.clamp(math.round(Ratio * Positions) * increment + min, min, max)

            ActiveSlider.state.number:set(updateValueByIndex(ActiveSlider.state.number.value, ActiveIndex, newValue, ActiveSlider.arguments))
            ActiveSlider.lastNumberChangedTick = Iris._cycleTick + 1
        end

        local function SliderMouseDown(thisWidget: Types.Widget, dataType: Types.InputDataTypes, index: number)
            local isCtrlHeld: boolean = widgets.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or widgets.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            if isCtrlHeld then
                thisWidget.state.editingText:set(index)
            else
                AnyActiveSlider = true
                ActiveSlider = thisWidget
                ActiveIndex = index
                ActiveDataType = dataType
                updateActiveSlider()
            end
        end

        widgets.registerEvent("InputChanged", function()
            if not Iris._started then
                return
            end
            updateActiveSlider()
        end)

        widgets.registerEvent("InputEnded", function(inputObject: InputObject)
            if not Iris._started then
                return
            end
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and AnyActiveSlider then
                AnyActiveSlider = false
                ActiveSlider = nil
                ActiveIndex = 0
                ActiveDataType = ""
            end
        end)

        function generateSliderScalar(dataType: Types.InputDataTypes, components: number, defaultValue: any, ...: any)
            return {
                hasState = true,
                hasChildren = false,
                Args = {
                    ["Text"] = 1,
                    ["Increment"] = 2,
                    ["Min"] = 3,
                    ["Max"] = 4,
                    ["Format"] = 5,
                },
                Events = {
                    ["numberChanged"] = numberChanged,
                    ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                        return thisWidget.Instance
                    end),
                },
                Generate = function(thisWidget: Types.Widget)
                    local Slider: Frame = Instance.new("Frame")
                    Slider.Name = "Iris_Slider" .. dataType
                    Slider.Size = UDim2.fromScale(1, 0)
                    Slider.BackgroundTransparency = 1
                    Slider.BorderSizePixel = 0
                    Slider.ZIndex = thisWidget.ZIndex
                    Slider.LayoutOrder = thisWidget.ZIndex
                    Slider.AutomaticSize = Enum.AutomaticSize.Y
                    widgets.UIListLayout(Slider, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

                    local textHeight: number = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y

                    -- we divide the total area evenly between each field. This includes accounting for any additional boxes and the offset.
                    -- for the final field, we make sure it's flush by calculating the space avaiable for it. This only makes the Vector2 box
                    -- 4 pixels shorter, all for the sake of flush.
                    local componentWidth: UDim = UDim.new(Iris._config.ContentWidth.Scale / components, (Iris._config.ContentWidth.Offset - (Iris._config.ItemInnerSpacing.X * (components - 1))) / components)
                    local totalWidth: UDim = UDim.new(componentWidth.Scale * (components - 1), (componentWidth.Offset * (components - 1)) + (Iris._config.ItemInnerSpacing.X * (components - 1)))
                    local lastComponentWidth: UDim = Iris._config.ContentWidth - totalWidth

                    for index = 1, components do
                        local SliderField: TextButton = Instance.new("TextButton")
                        SliderField.Name = "SliderField" .. tostring(index)
                        SliderField.ZIndex = thisWidget.ZIndex + index
                        SliderField.LayoutOrder = thisWidget.ZIndex + index
                        if index == components then
                            SliderField.Size = UDim2.new(lastComponentWidth, UDim.new())
                        else
                            SliderField.Size = UDim2.new(componentWidth, UDim.new())
                        end
                        SliderField.AutomaticSize = Enum.AutomaticSize.Y
                        SliderField.BackgroundColor3 = Iris._config.FrameBgColor
                        SliderField.BackgroundTransparency = Iris._config.FrameBgTransparency
                        SliderField.AutoButtonColor = false
                        SliderField.Text = ""
                        SliderField.ClipsDescendants = true

                        widgets.applyFrameStyle(SliderField)
                        widgets.applyTextStyle(SliderField)
                        widgets.UISizeConstraint(SliderField, Vector2.new(1, 0))

                        SliderField.Parent = Slider

                        local OverlayText = Instance.new("TextLabel")
                        OverlayText.Name = "OverlayText"
                        OverlayText.Size = UDim2.fromScale(1, 1)
                        OverlayText.BackgroundTransparency = 1
                        OverlayText.BorderSizePixel = 0
                        OverlayText.ZIndex = thisWidget.ZIndex + 10
                        OverlayText.ClipsDescendants = true

                        widgets.applyTextStyle(OverlayText)

                        OverlayText.TextXAlignment = Enum.TextXAlignment.Center

                        OverlayText.Parent = SliderField

                        widgets.applyInteractionHighlights(thisWidget, SliderField, SliderField, {
                            ButtonColor = Iris._config.FrameBgColor,
                            ButtonTransparency = Iris._config.FrameBgTransparency,
                            ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
                            ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
                            ButtonActiveColor = Iris._config.FrameBgActiveColor,
                            ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
                        })

                        local InputField: TextBox = Instance.new("TextBox")
                        InputField.Name = "InputField"
                        InputField.ZIndex = thisWidget.ZIndex + 5
                        InputField.LayoutOrder = thisWidget.ZIndex + 2
                        InputField.Size = UDim2.new(1, 0, 1, 0)
                        InputField.BackgroundTransparency = 1
                        InputField.ClearTextOnFocus = false
                        InputField.TextTruncate = Enum.TextTruncate.AtEnd
                        InputField.ClipsDescendants = true
                        InputField.Visible = false

                        widgets.applyFrameStyle(InputField, true)
                        widgets.applyTextStyle(InputField)

                        InputField.Parent = SliderField

                        InputField.FocusLost:Connect(function()
                            local newValue: number? = tonumber(InputField.Text:match("-?%d*%.?%d*"))
                            if newValue ~= nil then
                                if thisWidget.arguments.Min ~= nil then
                                    newValue = math.max(newValue, getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments))
                                end
                                if thisWidget.arguments.Max ~= nil then
                                    newValue = math.min(newValue, getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments))
                                end

                                if thisWidget.arguments.Increment then
                                    newValue = math.round(newValue / getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)) * getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                end

                                thisWidget.state.number:set(updateValueByIndex(thisWidget.state.number.value, index, newValue, thisWidget.arguments))
                                thisWidget.lastNumberChangedTick = Iris._cycleTick + 1
                            end

                            local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                            if thisWidget.arguments.Prefix then
                                format = thisWidget.arguments.Prefix[index] .. format
                            end

                            InputField.Text = string.format(format, getValueByIndex(thisWidget.state.number.value, index, thisWidget.arguments))

                            thisWidget.state.editingText:set(0)
                            InputField:ReleaseFocus(true)
                        end)

                        InputField.Focused:Connect(function()
                            -- this highlights the entire field
                            InputField.CursorPosition = #InputField.Text + 1
                            InputField.SelectionStart = 1

                            thisWidget.state.editingText:set(index)
                        end)

                        widgets.applyButtonDown(thisWidget, SliderField, function()
                            SliderMouseDown(thisWidget, dataType, index)
                        end)

                        local GrabBar: Frame = Instance.new("Frame")
                        GrabBar.Name = "GrabBar"
                        GrabBar.ZIndex = thisWidget.ZIndex + 5
                        GrabBar.LayoutOrder = thisWidget.ZIndex + 5
                        GrabBar.AnchorPoint = Vector2.new(0.5, 0.5)
                        GrabBar.Position = UDim2.new(0, 0, 0.5, 0)
                        GrabBar.BorderSizePixel = 0
                        GrabBar.BackgroundColor3 = Iris._config.SliderGrabColor
                        GrabBar.Transparency = Iris._config.SliderGrabTransparency
                        if Iris._config.GrabRounding > 0 then
                            widgets.UICorner(GrabBar, Iris._config.GrabRounding)
                        end

                        widgets.UISizeConstraint(GrabBar, Vector2.new(Iris._config.GrabMinSize, 0))

                        GrabBar.Parent = SliderField
                    end

                    local TextLabel: TextLabel = Instance.new("TextLabel")
                    TextLabel.Name = "TextLabel"
                    TextLabel.Size = UDim2.fromOffset(0, textHeight)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.BorderSizePixel = 0
                    TextLabel.ZIndex = thisWidget.ZIndex + 5
                    TextLabel.LayoutOrder = thisWidget.ZIndex + 5
                    TextLabel.AutomaticSize = Enum.AutomaticSize.X

                    widgets.applyTextStyle(TextLabel)

                    TextLabel.Parent = Slider

                    return Slider
                end,
                Update = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or `Slider {dataType}`

                    if thisWidget.arguments.Format and typeof(thisWidget.arguments.Format) ~= "table" then
                        thisWidget.arguments.Format = { thisWidget.arguments.Format }
                    elseif not thisWidget.arguments.Format then
                        -- we calculate the format for the s.f. using the max, min and increment arguments.
                        local format: { string } = {}
                        for index = 1, components do
                            local sigfigs: number = defaultSigFigs[dataType][index]

                            if thisWidget.arguments.Increment then
                                local value: number = getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Max then
                                local value: number = getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if thisWidget.arguments.Min then
                                local value: number = getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments)
                                sigfigs = math.max(sigfigs, math.ceil(-math.log10(value == 0 and 1 or value)), sigfigs)
                            end

                            if sigfigs > 0 then
                                -- we know it's a float.
                                format[index] = `%.{sigfigs}f`
                            else
                                format[index] = "%d"
                            end
                        end

                        thisWidget.arguments.Format = format
                        thisWidget.arguments.Prefix = defaultPrefx[dataType]
                    end

                    for index = 1, components do
                        local SliderField = Input:FindFirstChild("SliderField" .. tostring(index)) :: TextButton
                        local GrabBar: Frame = SliderField.GrabBar

                        local increment: number = thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments) or defaultIncrements[dataType][index]
                        local min: number = thisWidget.arguments.Min and getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments) or defaultMin[dataType][index]
                        local max: number = thisWidget.arguments.Max and getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments) or defaultMax[dataType][index]

                        local grabScaleSize = math.max(1 / math.floor((1 + max - min) / increment), Iris._config.GrabMinSize / SliderField.AbsoluteSize.X)

                        GrabBar.Size = UDim2.new(grabScaleSize, 0, 1, 0)
                    end
                end,
                Discard = function(thisWidget: Types.Widget)
                    thisWidget.Instance:Destroy()
                    widgets.discardState(thisWidget)
                end,
                GenerateState = function(thisWidget: Types.Widget)
                    if thisWidget.state.number == nil then
                        thisWidget.state.number = Iris._widgetState(thisWidget, "number", defaultValue)
                    end
                    if thisWidget.state.editingText == nil then
                        thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                    end
                end,
                UpdateState = function(thisWidget: Types.Widget)
                    local Slider = thisWidget.Instance :: Frame

                    for index = 1, components do
                        local SliderField = Slider:FindFirstChild("SliderField" .. tostring(index)) :: TextButton
                        local InputField: TextBox = SliderField.InputField
                        local OverlayText: TextLabel = SliderField.OverlayText
                        local GrabBar: Frame = SliderField.GrabBar

                        local value: number = getValueByIndex(thisWidget.state.number.value, index, thisWidget.arguments)
                        local format: string = thisWidget.arguments.Format[index] or thisWidget.arguments.Format[1]
                        if thisWidget.arguments.Prefix then
                            format = thisWidget.arguments.Prefix[index] .. format
                        end

                        OverlayText.Text = string.format(format, value)
                        InputField.Text = tostring(value)

                        local increment: number = thisWidget.arguments.Increment and getValueByIndex(thisWidget.arguments.Increment, index, thisWidget.arguments) or defaultIncrements[dataType][index]
                        local min: number = thisWidget.arguments.Min and getValueByIndex(thisWidget.arguments.Min, index, thisWidget.arguments) or defaultMin[dataType][index]
                        local max: number = thisWidget.arguments.Max and getValueByIndex(thisWidget.arguments.Max, index, thisWidget.arguments) or defaultMax[dataType][index]

                        local SliderWidth: number = SliderField.AbsoluteSize.X
                        local PaddedWidth: number = SliderWidth - GrabBar.AbsoluteSize.X
                        local Ratio: number = (value - min) / (max - min)
                        local Positions: number = math.floor((max - min) / increment)
                        local ClampedRatio: number = math.clamp(math.floor((Ratio * Positions)) / Positions, 0, 1)
                        local PaddedRatio: number = ((PaddedWidth / SliderWidth) * ClampedRatio) + ((1 - (PaddedWidth / SliderWidth)) / 2)

                        GrabBar.Position = UDim2.new(PaddedRatio, 0, 0.5, 0)

                        if thisWidget.state.editingText.value == index then
                            InputField.Visible = true
                            OverlayText.Visible = false
                            GrabBar.Visible = false
                            InputField:CaptureFocus()
                        else
                            InputField.Visible = false
                            OverlayText.Visible = true
                            GrabBar.Visible = true
                        end
                    end
                end,
            }
        end

        function generateEnumSliderScalar(enum: Enum, item: EnumItem)
            local input: Types.WidgetClass = generateSliderScalar("Enum", 1, item.Value)
            local valueToName = { string }

            for _, enumItem: EnumItem in enum:GetEnumItems() do
                valueToName[enumItem.Value] = enumItem.Name
            end

            return widgets.extend(input, {
                Args = {
                    ["Text"] = 1,
                },
                Update = function(thisWidget: Types.Widget)
                    local Input = thisWidget.Instance :: GuiObject
                    local TextLabel: TextLabel = Input.TextLabel
                    TextLabel.Text = thisWidget.arguments.Text or "Input Enum"

                    thisWidget.arguments.Increment = 1
                    thisWidget.arguments.Min = 0
                    thisWidget.arguments.Max = #enum:GetEnumItems() - 1

                    local SliderField = Input:FindFirstChild("SliderField1") :: TextButton
                    local GrabBar: Frame = SliderField.GrabBar

                    local grabScaleSize = math.max(1 / math.floor(#enum:GetEnumItems()), Iris._config.GrabMinSize / SliderField.AbsoluteSize.X)

                    GrabBar.Size = UDim2.new(grabScaleSize, 0, 1, 0)
                end,
                GenerateState = function(thisWidget: Types.Widget)
                    if thisWidget.state.number == nil then
                        thisWidget.state.number = Iris._widgetState(thisWidget, "number", item.Value)
                    end
                    if thisWidget.state.enumItem == nil then
                        thisWidget.state.enumItem = Iris._widgetState(thisWidget, "enumItem", item)
                    end
                    if thisWidget.state.editingText == nil then
                        thisWidget.state.editingText = Iris._widgetState(thisWidget, "editingText", false)
                    end
                end,
            })
        end
    end

    do
        local inputNum: Types.WidgetClass = generateInputScalar("Num", 1, 0)
        inputNum.Args["NoButtons"] = 6
        Iris.WidgetConstructor("InputNum", inputNum)
    end
    Iris.WidgetConstructor("InputVector2", generateInputScalar("Vector2", 2, Vector2.zero))
    Iris.WidgetConstructor("InputVector3", generateInputScalar("Vector3", 3, Vector3.zero))
    Iris.WidgetConstructor("InputUDim", generateInputScalar("UDim", 2, UDim.new()))
    Iris.WidgetConstructor("InputUDim2", generateInputScalar("UDim2", 4, UDim2.new()))
    Iris.WidgetConstructor("InputRect", generateInputScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

    Iris.WidgetConstructor("DragNum", generateDragScalar("Num", 1, 0))
    Iris.WidgetConstructor("DragVector2", generateDragScalar("Vector2", 2, Vector2.zero))
    Iris.WidgetConstructor("DragVector3", generateDragScalar("Vector3", 3, Vector3.zero))
    Iris.WidgetConstructor("DragUDim", generateDragScalar("UDim", 2, UDim.new()))
    Iris.WidgetConstructor("DragUDim2", generateDragScalar("UDim2", 4, UDim2.new()))
    Iris.WidgetConstructor("DragRect", generateDragScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

    Iris.WidgetConstructor("InputColor3", generateColorDragScalar("Color3", Color3.fromRGB(0, 0, 0)))
    Iris.WidgetConstructor("InputColor4", generateColorDragScalar("Color4", Color3.fromRGB(0, 0, 0), 0))

    Iris.WidgetConstructor("SliderNum", generateSliderScalar("Num", 1, 0))
    Iris.WidgetConstructor("SliderVector2", generateSliderScalar("Vector2", 2, Vector2.zero))
    Iris.WidgetConstructor("SliderVector3", generateSliderScalar("Vector3", 3, Vector3.zero))
    Iris.WidgetConstructor("SliderUDim", generateSliderScalar("UDim", 2, UDim.new()))
    Iris.WidgetConstructor("SliderUDim2", generateSliderScalar("UDim2", 4, UDim2.new()))
    Iris.WidgetConstructor("SliderRect", generateSliderScalar("Rect", 4, Rect.new(0, 0, 0, 0)))
    -- Iris.WidgetConstructor("SliderEnum", generateSliderScalar("Enum", 4, 0))

    --stylua: ignore
    Iris.WidgetConstructor("InputText", {
        hasState = true,
        hasChildren = false,
        Args = {
            ["Text"] = 1,
            ["TextHint"] = 2,
        },
        Events = {
            ["textChanged"] = {
                ["Init"] = function(thisWidget: Types.Widget)
                    thisWidget.lastTextchangeTick = 0
                end,
                ["Get"] = function(thisWidget: Types.Widget)
                    return thisWidget.lastTextchangeTick == Iris._cycleTick
                end,
            },
            ["hovered"] = widgets.EVENTS.hover(function(thisWidget: Types.Widget)
                return thisWidget.Instance
            end),
        },
        Generate = function(thisWidget: Types.Widget)
            local InputText: Frame = Instance.new("Frame")
            InputText.Name = "Iris_InputText"
            InputText.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
            InputText.BackgroundTransparency = 1
            InputText.BorderSizePixel = 0
            InputText.ZIndex = thisWidget.ZIndex
            InputText.LayoutOrder = thisWidget.ZIndex
            InputText.AutomaticSize = Enum.AutomaticSize.Y
            widgets.UIListLayout(InputText, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

            local InputField: TextBox = Instance.new("TextBox")
            InputField.Name = "InputField"
            InputField.Size = UDim2.new(1, 0, 0, 0)
            InputField.AutomaticSize = Enum.AutomaticSize.Y
            InputField.BackgroundColor3 = Iris._config.FrameBgColor
            InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
            InputField.Text = ""
            InputField.PlaceholderColor3 = Iris._config.TextDisabledColor
            InputField.TextTruncate = Enum.TextTruncate.AtEnd
            InputField.ClearTextOnFocus = false
            InputField.ZIndex = thisWidget.ZIndex + 1
            InputField.LayoutOrder = thisWidget.ZIndex + 1
            InputField.ClipsDescendants = true

            widgets.applyFrameStyle(InputField)
            widgets.applyTextStyle(InputField)
            widgets.UISizeConstraint(InputField, Vector2.new(1, 0)) -- prevents sizes beaking when getting too small.
            -- InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
            -- InputField.UIPadding.PaddingRight = UDim.new(0, 0)
            InputField.Parent = InputText

            InputField.FocusLost:Connect(function()
                thisWidget.state.text:set(InputField.Text)
                thisWidget.lastTextchangeTick = Iris._cycleTick + 1
            end)

            local frameHeight: number = Iris._config.TextSize + Iris._config.FramePadding.Y * 2

            local TextLabel: TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "TextLabel"
            TextLabel.Size = UDim2.fromOffset(0, frameHeight)
            TextLabel.AutomaticSize = Enum.AutomaticSize.X
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.ZIndex = thisWidget.ZIndex + 4
            TextLabel.LayoutOrder = thisWidget.ZIndex + 4

            widgets.applyTextStyle(TextLabel)

            TextLabel.Parent = InputText

            return InputText
        end,
        Update = function(thisWidget: Types.Widget)
            local InputText = thisWidget.Instance :: Frame
            local TextLabel: TextLabel = InputText.TextLabel
            local InputField: TextBox = InputText.InputField

            TextLabel.Text = thisWidget.arguments.Text or "Input Text"
            InputField.PlaceholderText = thisWidget.arguments.TextHint or ""
        end,
        Discard = function(thisWidget: Types.Widget)
            thisWidget.Instance:Destroy()
            widgets.discardState(thisWidget)
        end,
        GenerateState = function(thisWidget: Types.Widget)
            if thisWidget.state.text == nil then
                thisWidget.state.text = Iris._widgetState(thisWidget, "text", "")
            end
        end,
        UpdateState = function(thisWidget: Types.Widget)
            local InputText = thisWidget.Instance :: Frame
            local InputField: TextBox = InputText.InputField

            InputField.Text = thisWidget.state.text.value
        end,
    } :: Types.WidgetClass)
end
