local library = {}
local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/Miscellaneous/main/util.lua"))()

--
library.UI = CoreGui:FindFirstChild("UI") or util.create('ScreenGui', {
	Name = "UI",
	Parent = CoreGui,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
})

do -- Default Creation Params
	util.def_window = {
		Text = "Window",
		Theme_Overrides = {},
		--
		Position = V2(500, 500),
		Position_Callback = function(n)end, -- Fires every window position change
	}
	util.def_page = {
		Text = "Page"
	}
	util.def_button = {
		Text = "Button",
		Key = false,
		Callback = function()end,
		KCallback = function(newkey)end
	}
	util.def_toggle = {
		Text = "Toggle",
		Default = false,
		Key = false,
		Callback = function(state)end,
		KCallback = function(newkey)end
	}
	util.def_picker = {
		Text = "Picker",
		Default = {RGB(255, 0, 255), 1},
		Callback = function(color)end
	}
	util.def_slider = {
		Text = "Slider",
		Default = 50,
		Min = 0, Max = 100, Decimals = 0,
		Suffix = "",
		Callback = function(value)end
	}
	util.def_dropdown = {
		Text = "Dropdown",
		Options = {},
		Callback = function(option)end
	}
	util.def_chipset = {
		Text = "Dropdown",
		Options = {},
		Callback = function(Options)end
	}
	util.def_label = {
		Text = "Label"
	}
end

util.diagonalSizeId     = 'rbxassetid://9063724353'
util.horizontalSizeId   = 'rbxassetid://8943647369'

--
function library.New(options)
	local window_i = util.merge(util.def_window, options)

	local window_f = {active = true}
	--

	-- Connection Management
	do
		window_f.Connections = {}
		--
		function window_f:addRawConnection(c)
			TBINSERT(self.Connections, c)
		end
		--
		function window_f:addConnection(t, o, f)
			local signal = o[t]

			if (signal) then
				local c = signal:Connect(f)
				self:addRawConnection(c)
			end
		end
		--
		function window_f:addHighlighter(ref, objs, description, callback)
			self:addConnection("MouseEnter", ref, function()
				for obj, prop in next, objs do
					local s, e = pcall(function()
						obj[prop] = RGB(255, 255, 255);
					end)
					if not s then warn(e) end
				end

				if (callback) then callback(true) end
			end)
			self:addConnection("MouseLeave", ref, function()
				for obj, prop in next, objs do
					local s, e = pcall(function()
						obj[prop] = RGB(178, 178, 178);
					end)
					if not s then warn(e) end
				end

				if (callback) then callback(false) end
			end)
		end
	end
	--

	local Window = util.create('Frame', {
		Name = window_i.Text,
		Parent = library.UI,
		BackgroundColor3 = RGB(10, 18, 38),
		BorderColor3 = RGB(10, 18, 38),
		BorderSizePixel = 2,
		Position = util.v2_u2(window_i.Position),
		Size = U2(0, 220, 0, 350)
	})

	function window_f:Close()
		for _,c in next, self.Connections do
			c:Disconnect()
		end
		Window:Destroy()
		window_f.active = false
		window_f.cursor.cursor:Destroy()
	end

	-- Cursor Lib
	do
		window_f.cursor = {}
		--
		window_f.cursor.cursor = util.create("ImageLabel", {
			Name = "Cursor",
			Parent = library.UI,
			Size = U2(0, 64, 0, 64),
			ZIndex = 1000000,
			Visible = false,
			BackgroundTransparency = 1
		})
		--
		local Binded = false
		local Cursor_Lock = function()
			if not (window_f.active) then
				window_f.cursor.cursor:Destroy()
				RS:UnbindFromRenderStep("CursorLock")
			else
				local c = window_f.cursor.cursor
				c.Position = U2(0, Mouse.X-c.AbsoluteSize.X/2, 0, Mouse.Y-c.AbsoluteSize.Y/2)
			end
		end
		--
		function window_f.cursor:showCursor(CursorId)
			UIS.MouseIconEnabled = false

			local c = window_f.cursor.cursor
			c.Image = CursorId
			c.Visible = true

			if Binded then return end
			Binded = true
			RS:BindToRenderStep("CursorLock", 1, Cursor_Lock)
		end
		--
		function window_f.cursor:hideCursor()
			UIS.MouseIconEnabled = true
			window_f.cursor.cursor.Visible = false
			
			if not Binded then return end
			Binded = false
			RS:UnbindFromRenderStep("CursorLock")
		end
	end
	--

	-- Colorpicker Lib
	local g_picker = {}
	do
		g_picker.Callback = function(c, a) end
		g_picker.Current = {
			Red = 255,
			Green = 255,
			Blue = 255,
			Alpha = 255,
			Hex = "#FFFFFF",

			Hue = 0,
			Sat = 0,
			Val = 1
		}

		local function createValueTB(name, pholder, parent, order, Callback)
			local f = SUB(name, 1, 1)

			local Text = util.create('TextLabel', {
				Name = order .. f .."Text",
				Parent = parent,
				BackgroundTransparency = 1,
				Size = U2(0, 46, 0, 20),
				ZIndex = 5,
				Font = Enum.Font.Code,
				Text = name,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Input = util.create('TextBox', {
				Name = f.."Input",
				Parent = Text,
				BackgroundColor3 = RGB(14, 31, 66),
				BorderSizePixel = 0,
				Position = U2(1, 0, 0.5, -8),
				Size = U2(0, 86, 0, 16),
				ZIndex = 5,
				Font = Enum.Font.Code,
				Text = "",
				PlaceholderText = pholder,
				TextColor3 = RGB(160, 160, 160),
				TextSize = 13
			})
		

			local rgb = (pholder == "0-255")
			local old = Input.Text
			
			window_f:addRawConnection(Input:GetPropertyChangedSignal("Text"):Connect(function()
				if (rgb) then
					Input.Text = Input.Text:gsub("%a", "")

					local n = tonumber(Input.Text)

					if n then
						n = CLAMP(n, 0, 255)
						Input.Text = tostring(n)
						
						if Input.Text ~= old then
							Callback(n)
							old = Input.Text
						end
					end
				else
					local h = Input.Text:gsub("#", "")
					if #h == 6 and Input.Text ~= old then
						Callback(h)
						old = Input.Text
					end
				end
			end))

			return Input
		end

		g_picker.GlobalCP = util.create('Frame', {
			Name = "GlobalCP",
			Parent = Window,
			BackgroundColor3 = RGB(10, 18, 38),
			BorderColor3 = RGB(10, 18, 38),
			BorderSizePixel = 2,
			Position = U2(1, 8, 0, 0),
			Size = U2(0, 146, 0, 221),
			Visible = false
		})
		
		local Bar = util.create('Frame', {
			Name = "Bar",
			Parent = g_picker.GlobalCP,
			BackgroundColor3 = RGB(205, 0, 255),
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, 1)
		})
		
		local SVPicker = util.create('ImageLabel', {
			Name = "SVPicker",
			Parent = g_picker.GlobalCP,
			BackgroundColor3 = RGB(255, 255, 255),
			BorderSizePixel = 0,
			Position = U2(0, 7, 0, 11),
			Size = U2(0, 100, 0, 100),
			ZIndex = 2,
			Image = "rbxassetid://4155801252"
		})
		
		local Point = util.create('Frame', {
			Name = "Point",
			Parent = SVPicker,
			BackgroundColor3 = RGB(255, 255, 255),
			BorderColor3 = RGB(0, 0, 0),
			Position = U2(0, 20, 0, 20),
			Rotation = 45,
			Size = U2(0, 2, 0, 2),
			ZIndex = 6
		})

		local AlphaPicker = util.create('ImageLabel', {
			Name = "AlphaPicker",
			Parent = SVPicker,
			BackgroundTransparency = 1,
			BackgroundColor3 = RGB(255, 255, 255),
			Position = U2(0, 124, 0, 0),
			Size = U2(0, 8, 0, 100),
			ZIndex = 3,
			Image = "rbxassetid://9228941480"
		})
		
		local AlphaPointer = util.create('ImageLabel', {
			Name = "AlphaPointer",
			Parent = AlphaPicker,
			BackgroundColor3 = RGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = U2(0, -2, 0, 0),
			Size = U2(0, 12, 0, 4),
			ZIndex = 4,
			Image = "rbxassetid://9233904690"
		})
		
		local AlphaSpectrum = util.create('UIGradient', {
			Name = "AlphaSpectrum",
			Parent = AlphaPicker,
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, RGB(255, 255, 255)), ColorSequenceKeypoint.new(1, RGB(255, 0, 4))}),
			Rotation = 90,
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
		})
		
		local HuePicker = util.create('Frame', {
			Name = "HuePicker",
			Parent = SVPicker,
			BorderSizePixel = 0,
			BackgroundColor3 = RGB(255, 255, 255),
			Position = U2(0, 108, 0, 0),
			Size = U2(0, 8, 0, 100),
			ZIndex = 3
		})
		
		local HueSpectrum = util.create('UIGradient', {
			Name = "HueSpectrum",
			Parent = HuePicker,
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, RGB(255, 0, 4)), ColorSequenceKeypoint.new(0.10000000149011612, RGB(255, 0, 200)), ColorSequenceKeypoint.new(0.20000000298023224, RGB(153, 0, 255)), ColorSequenceKeypoint.new(0.30000001192092896, RGB(0, 0, 255)), ColorSequenceKeypoint.new(0.4000000059604645, RGB(0, 149, 255)), ColorSequenceKeypoint.new(0.5, RGB(0, 255, 209)), ColorSequenceKeypoint.new(0.6000000238418579, RGB(0, 255, 55)), ColorSequenceKeypoint.new(0.699999988079071, RGB(98, 255, 0)), ColorSequenceKeypoint.new(0.800000011920929, RGB(251, 255, 0)), ColorSequenceKeypoint.new(0.8999999761581421, RGB(255, 106, 0)), ColorSequenceKeypoint.new(1, RGB(255, 0, 0))}),
			Rotation = 270,
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 0, 0)})
		})
		
		local HuePointer = util.create('ImageLabel', {
			Name = "HuePointer",
			Parent = HuePicker,
			BackgroundTransparency = 1,
			Position = U2(0, -2, 0, 0),
			Size = U2(0, 12, 0, 4),
			ZIndex = 6,
			Image = "rbxassetid://9233904690"
		})
		
		local Control = util.create('Frame', {
			Name = "Control",
			Parent = g_picker.GlobalCP,
			BackgroundTransparency = 1,
			Position = U2(0, 7, 0, 115)
		})
		
		local Elements_List = util.create('UIListLayout', {
			Parent = Control,
			Name = "Elements_List",
			SortOrder = Enum.SortOrder.Name
		})
		
		--
		local R_TB = createValueTB("Red", "0-255", Control, "a", function(input)
			if g_picker.hsvDrag or g_picker.hueDrag or g_picker.alphaDrag then return end

			g_picker.Current.Red = input
			g_picker:Place()
		end)
		local G_TB = createValueTB("Green", "0-255", Control, "b", function(input)
			if g_picker.hsvDrag or g_picker.hueDrag or g_picker.alphaDrag then return end
			
			g_picker.Current.Green = input
			g_picker:Place()
		end)
		local B_TB = createValueTB("Blue", "0-255", Control, "c", function(input)
			if g_picker.hsvDrag or g_picker.hueDrag or g_picker.alphaDrag then return end

			g_picker.Current.Blue = input
			g_picker:Place()
		end)
		local A_TB = createValueTB("Alpha", "0-255", Control, "d", function(input)
			if g_picker.hsvDrag or g_picker.hueDrag or g_picker.alphaDrag then return end

			g_picker.Current.Alpha = util._255_a(input)
			g_picker:Place()
		end)
		local H_TB = createValueTB("Hex", "#", Control, "e", function(input)
			if g_picker.hsvDrag or g_picker.hueDrag or g_picker.alphaDrag then return end

			g_picker.Current.Hex = input

			local c = HEX(input)

			local r, g, b = util.c3_rgb(c)
			local h, s, v = util.c3_hsv(c)

			g_picker.Current.Red = r;           R_TB.Text = r;
			g_picker.Current.Green = g;         G_TB.Text = g;
			g_picker.Current.Blue = b;          B_TB.Text = b;

			g_picker.Current.Hue = h;
			g_picker.Current.Sat = s;
			g_picker.Current.Val = v;

			g_picker:Place()
		end)

		g_picker.hsvDrag = false
		window_f:addConnection("InputBegan", SVPicker, function(input)
			if input.UserInputType ~= MB1 then return end
			g_picker.hsvDrag = true
			g_picker:lockOn()
		end)
		--
		g_picker.hueDrag = false
		window_f:addConnection("InputBegan", HuePicker, function(input)
			if input.UserInputType ~= MB1 then return end
			g_picker.hueDrag = true
			g_picker:lockOn()
		end)
		--
		g_picker.alphaDrag = false
		window_f:addConnection("InputBegan", AlphaPicker, function(input)
			if input.UserInputType ~= MB1 then return end
			g_picker.alphaDrag = true
			g_picker:lockOn()
		end)
		--
		window_f:addRawConnection(UIS.InputEnded:Connect(function(input)
			if input.UserInputType == MB1 then
				g_picker.hsvDrag = false
				g_picker.hueDrag = false
				g_picker.alphaDrag = false
			end
		end))
		--

		function g_picker:calculateHSVA()
			local size, offset, origin, position, rel;

			size = HuePicker.AbsoluteSize.Y
			origin = HuePicker.AbsolutePosition.Y
			position = HuePointer.AbsolutePosition.Y
			offset = HuePointer.AbsoluteSize.Y/2
			local h = (position - (origin-offset)) / size

			size = SVPicker.AbsoluteSize.X
			origin = SVPicker.AbsolutePosition.X
			position = Point.AbsolutePosition.X
			offset = Point.AbsoluteSize.X/2
			local s = (position - (origin-offset)) / size

			size = SVPicker.AbsoluteSize.Y
			origin = SVPicker.AbsolutePosition.Y
			position = Point.AbsolutePosition.Y
			offset = Point.AbsoluteSize.Y/2
			local v = 1 - (position - (origin-offset)) / size

			size = AlphaPicker.AbsoluteSize.Y
			origin = AlphaPicker.AbsolutePosition.Y
			position = AlphaPointer.AbsolutePosition.Y
			offset = AlphaPointer.AbsoluteSize.Y/2
			local a = (position - (origin-offset)) / size

			return h, s, v, a
		end
		--
		function g_picker:lockOn()
			if g_picker.hsvDrag then
				local ox = Point.AbsoluteSize.X/2
				local nx = Mouse.X - SVPicker.AbsolutePosition.X - ox

				local oy = Point.AbsoluteSize.Y/2
				local ny = Mouse.Y - SVPicker.AbsolutePosition.Y - oy

				Point.Position = U2(0, CLAMP(nx, -ox, SVPicker.AbsoluteSize.X-ox), 0, CLAMP(ny, -oy, SVPicker.AbsoluteSize.Y-oy))

				g_picker:Update()
			elseif g_picker.hueDrag then
				local oy = HuePointer.AbsoluteSize.Y/2
				local ny = Mouse.Y - HuePicker.AbsolutePosition.Y - oy

				HuePointer.Position = U2(0, -2, 0, CLAMP(ny, -oy, HuePicker.AbsoluteSize.Y-oy))

				g_picker:Update()
			elseif g_picker.alphaDrag then
				local oy = AlphaPointer.AbsoluteSize.Y/2
				local ny = Mouse.Y - AlphaPicker.AbsolutePosition.Y - oy

				AlphaPointer.Position = U2(0, -2, 0, CLAMP(ny, -oy, AlphaPicker.AbsoluteSize.Y-oy))

				g_picker:Update()
			end
		end
		window_f:addRawConnection(UIS.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and g_picker.GlobalCP.Visible then
				g_picker:lockOn()
			end
		end))

		--

		function g_picker:updateCurrent(new, alpha, real)
			if typeof(new) ~= "Color3" then return end

			local a255 = util.a_255(alpha)

			local r,g,b = util.c3_rgb(new)
			g_picker.Current.Red = r;           R_TB.Text = r;
			g_picker.Current.Green = g;         G_TB.Text = g;
			g_picker.Current.Blue = b;          B_TB.Text = b;
			g_picker.Current.Alpha = alpha;      A_TB.Text = ROUND(a255);

			local h,s,v;

			if (real) then
				local s = pcall(function()
					h = real.h
					s = real.s
					v = real.v
				end)
				if not s then
					h,s,v = util.c3_hsv(new)
				end
			else
				h,s,v = util.c3_hsv(new)
			end
			
			g_picker.Current.Hue = h;
			g_picker.Current.Sat = s;
			g_picker.Current.Val = v;

			local _,hex = pcall(function() return util.c3_hex(new) end)

			g_picker.Current.Hex = hex; 
			H_TB.Text = hex; 

			AlphaSpectrum.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, RGB(255, 255, 255)), ColorSequenceKeypoint.new(1, new)});
			SVPicker.BackgroundColor3 = HSV(h, 1, 1)

			g_picker.Callback(new, alpha)
		end
		--
		function g_picker:Update()
			local h, s, v, a = self:calculateHSVA()

			self:updateCurrent(HSV(h,s,v), a, {h=h,s=s,v=v})
		end
		--
		function g_picker:Place()
			local c = RGB(g_picker.Current.Red, g_picker.Current.Green, g_picker.Current.Blue)
			local h, s, v = util.c3_hsv(c)
			local a = g_picker.Current.Alpha

			Point.Position = U2(0, SVPicker.AbsoluteSize.X * s - Point.AbsoluteSize.X/2, 0, SVPicker.AbsoluteSize.Y - SVPicker.AbsoluteSize.Y * v  - Point.AbsoluteSize.Y/2)
			HuePointer.Position = U2(0, -2, 0, HuePicker.AbsoluteSize.Y * h - HuePointer.AbsoluteSize.Y/2)
			AlphaPointer.Position = U2(0, -2, 0, AlphaPicker.AbsoluteSize.Y - AlphaPicker.AbsoluteSize.Y * (1-a) - AlphaPointer.AbsoluteSize.Y/2)

			self:updateCurrent(c, a)
		end
		
	end
	--

	local Pages = util.create('Folder', {
		Name = "Pages",
		Parent = Window
	})
	
	local PageSelector = util.create('ScrollingFrame', {
		Name = "PageSelector",
		Parent = Window,
		BackgroundColor3 = RGB(14, 31, 66),
		BorderColor3 = RGB(10, 18, 38),
		BorderSizePixel = 0,
		Position = U2(0, 0, 0, 1),
		Selectable = true,
		Size = U2(1, 0, 0, 20),
		ZIndex = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = U2(1, 0, 0, 0),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X
	})
	
	local PageListLayout = util.create('UIListLayout', {
		Parent = PageSelector,
		Padding = U1(0, 4),
		Name = "PageListLayout",
		FillDirection = Enum.FillDirection.Horizontal
	})

	local TopBar = util.create('Frame', {
		Name = "TopBar",
		Parent = Window,
		BackgroundColor3 = RGB(205, 0, 255),
		BorderSizePixel = 0,
		Size = U2(1, 0, 0, 1),
		ZIndex = 3
	})

	function window_f:hideAllPages(MUTEX)
		window_f.currentPage = nil
		for _,p in next, Pages:GetChildren() do
			if p:IsA("ScrollingFrame") then
				local v = (p == MUTEX)
				p.Visible = v
				if v then
					local root = p.Attach.Value
					window_f.currentPage = root

					root.BackgroundTransparency = 0
					root.Bar.Visible = true
				else
					local root = p.Attach.Value

					root.BackgroundTransparency = 1
					root.Bar.Visible = false
				end
			end
		end
	end
	window_f:hideAllPages()
	--

	-- DRAGGING
	do
		local draggingUI = false;
		local Previous_Offset;

		local dragTween = false;
		local previousPos = V2(Window.AbsolutePosition.X, Window.AbsolutePosition.Y);

		window_f:addRawConnection(UIS.InputChanged:Connect(function(input)
			if draggingUI and input.UserInputType == UIT.MouseMovement then
				if dragTween then dragTween:Cancel() end

				local nx, ny = ROUND(Mouse.X + Previous_Offset.X), ROUND(Mouse.Y + Previous_Offset.Y)

				dragTween = TS:Create(Window, TWEEN(0.04, ESS, EDO), {Position = U2(0, nx, 0, ny)})
				dragTween:Play()

				local newPos = V2(nx, ny)

				if newPos ~= previousPos then
					window_i.Position_Callback(newPos)
				end

				previousPos = newPos
			end
		end))

		window_f:addRawConnection(UIS.InputBegan:Connect(function(input)
			if input.UserInputType == MB1 and util.mouseIn(PageSelector) then
				Previous_Offset = V2(Window.AbsolutePosition.X, Window.AbsolutePosition.Y) - V2(Mouse.X, Mouse.Y)
				draggingUI = true
			end
		end))

		window_f:addRawConnection(UIS.InputEnded:Connect(function(input)
			if input.UserInputType == MB1 then
				draggingUI = false
			end
		end))

		function window_f:SetPosition(position)
			Window.Position = U2(0, position.X, 0, position.Y)
			window_i.Position_Callback(position)
		end
	end
	--

	-- PAGE Constructor - Options
	function window_f.NewPage(options)
		local page_i = util.merge(util.def_page, options)
		local page_f = {}

		local Page = util.create('ScrollingFrame', {
			Name = "Page",
			Parent = Pages,
			BackgroundTransparency = 1,
			Position = U2(0, 7, 0, 26),
			Selectable = true,
			Size = U2(1, -11, 1, -34),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			CanvasSize = U2(0, 0, 1, -7),
			ScrollBarImageColor3 = RGB(174, 0, 255),
			Visible = false,
			ScrollBarThickness = 1
		})
		
		local Elements = util.create('UIListLayout', {
			Parent = Page,
			Name = "Elements",
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local PageButton = util.create('TextButton', {
			Name = "PageButton",
			Parent = PageSelector,
			Active = true,
			AutoButtonColor = false,
			BackgroundColor3 = RGB(10, 18, 38),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Selectable = true,
			Size = U2(0, 100, 1, 0),
			Style = Enum.ButtonStyle.Custom,
			ZIndex = 3,
			Font = Enum.Font.Code,
			Text = page_i.Text,
			TextColor3 = RGB(230, 230, 230),
			TextSize = 13
		})
		spawn(function()
			WAIT(0.5) -- TextBounds not updating
			PageButton.Size = util.scaleToTB(PageButton, 4)
		end)
		
		local Bar = util.create('Frame', {
			Name = "Bar",
			Parent = PageButton,
			BackgroundColor3 = RGB(205, 0, 255),
			BorderSizePixel = 0,
			Size = U2(1, 0, 0, 2),
			Visible = false,
			ZIndex = 4
		})

		local Attach = util.create('ObjectValue', {
			Name = "Attach",
			Parent = Page,
			Value = PageButton
		})

		--
		window_f:addConnection("MouseButton1Click", PageButton, function()
			window_f:hideAllPages(Page)
		end)

		function page_f:GetText()
			return PageButton.Text
		end
		function page_f:SetText(new)
			PageButton.Text = new
			PageButton.Size = util.scaleToTB(PageButton, 4)
		end
		--

		--[[-----------------------------------------
					Children Classes
		-----------------------------------------]]--
		
		-- BUTTON Constructor - Options
		function page_f:NewButton(options)
			local button_i = util.merge(util.def_button, options)
			local button_f = {}
			--

			local Button = util.create('Frame', {
				Name = "Button",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20),
				ZIndex = 2
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Button,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = button_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local Bind = util.create('TextLabel', {
				Name = "Bind",
				Parent = Button,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				Font = Enum.Font.Code,
				Text = "[undefined]",
				TextColor3 = RGB(178, 178, 178),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})

			local TextDetector = util.create('TextButton', {
				Name = "TextDetector",
				Parent = Button,
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -7),
				Selectable = true,
				Size = U2(1, 0, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				ZIndex = 5,
				Text = "",
				TextSize = 14
			})
			
			
			local BindDetector = util.create('TextButton', {
				Name = "BindDetector",
				Parent = Button,
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Position = U2(1, -77, 0.5, -7),
				Selectable = true,
				Size = U2(0, 77, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				ZIndex = 6,
				Text = "",
				TextSize = 14
			})

			function button_f:ScaleText()
				WAIT()
				BindDetector.Position = U2(1, -(Bind.TextBounds.X), 0.5, -7)
				BindDetector.Size = U2(0, Bind.TextBounds.X, 0, 14)

				TextDetector.Size = U2(1, -(Bind.TextBounds.X), 0, 14)
			end

			local currentBind = button_i.Key
			function button_f:SetBind(new)
				currentBind = new
				if (currentBind) then
					local cut = SUB(tostring(currentBind), 14, #tostring(currentBind))
					Bind.Text =  "[" .. cut .. "]"
				else
					Bind.Text = "[undefined]"
				end
				button_i.KCallback(currentBind) 

				self:ScaleText()
			end
			button_f:SetBind(currentBind)
			button_f:ScaleText()

			--
			local Binding = false
			function button_f:StartSelection()
				if not Binding then
					Binding = true

					Bind.Text = "[...]"
					button_f:ScaleText()

					local sel_c; sel_c = UIS.InputBegan:Connect(function(input, gameProcessed)
						if (gameProcessed) then return end

						if input.UserInputType == KBD and input.KeyCode ~= BSP then
							self:SetBind(input.KeyCode)
							sel_c:Disconnect()
							RS.RenderStepped:Wait()
							Binding = false
						elseif (input.UserInputType == KBD and input.KeyCode == BSP) or (not util.mouseIn(BindDetector) and input.UserInputType == MB2) then
							self:SetBind(false)
							sel_c:Disconnect()
							RS.RenderStepped:Wait()
							Binding = false
						end
					end)
				end
				button_f:ScaleText()
			end
			--

			window_f:addRawConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and input.UserInputType == KBD and input.KeyCode == currentBind and not Binding then
					button_i.Callback()
				end
			end))

			window_f:addConnection("MouseButton1Click", BindDetector, function()
				button_f:StartSelection()
			end)
			window_f:addConnection("MouseButton1Click", TextDetector, function()
				button_i.Callback()
			end)

			--
			function button_f:GetText()
				return Text.Text
			end
			function button_f:SetText(new)
				Text.Text = new
				self:ScaleText()
			end
			--

			--
			return button_f
		end

		-- TOGGLE Constructor - Options
		function page_f:NewToggle(options)
			local toggle_i = util.merge(util.def_toggle, options)
			local toggle_f = {}
			--

			local Toggle = util.create('Frame', {
				Name = "Toggle",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20),
				ZIndex = 2
			})
			
			local TextDetector = util.create('TextButton', {
				Name = "TextDetector",
				Parent = Toggle,
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -7),
				Selectable = true,
				Size = U2(1, 0, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				ZIndex = 5,
				Text = "",
				TextSize = 14
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Toggle,
				BackgroundTransparency = 1,
				Position = U2(0, 25, 0.5, -1),
				Size = U2(1, -25, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = toggle_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local CACHE = util.create('Frame', {
				Name = "CACHE",
				Parent = Toggle,
				BackgroundColor3 = RGB(175, 175, 175),
				BorderSizePixel = 0,
				Position = U2(0, 9, 0.5, -3),
				Size = U2(0, 9, 0, 6),
				ZIndex = 4
			})
			
			local ON = util.create('Frame', {
				Name = "ON",
				Parent = Toggle,
				BackgroundColor3 = RGB(205, 0, 255),
				BorderSizePixel = 0,
				Position = U2(0, 0, 0.5, -3),
				Size = U2(0, 9, 0, 6),
				ZIndex = 3
			})
			
			local OFF = util.create('Frame', {
				Name = "OFF",
				Parent = Toggle,
				BackgroundColor3 = RGB(60, 60, 60),
				BorderSizePixel = 0,
				Position = U2(0, 9, 0.5, -3),
				Size = U2(0, 9, 0, 6),
				ZIndex = 3
			})
			
			local Bind = util.create('TextLabel', {
				Name = "Bind",
				Parent = Toggle,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				Font = Enum.Font.Code,
				Text = "[undefined]",
				TextColor3 = RGB(178, 178, 178),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local BindDetector = util.create('TextButton', {
				Name = "BindDetector",
				Parent = Toggle,
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Position = U2(1, -77, 0.5, -7),
				Selectable = true,
				Size = U2(0, 77, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				ZIndex = 6,
				Text = "",
				TextSize = 14
			})

			function toggle_f:ScaleText()
				WAIT()
				BindDetector.Position = U2(1, -(Bind.TextBounds.X), 0.5, -7)
				BindDetector.Size = U2(0, Bind.TextBounds.X, 0, 14)

				TextDetector.Size = U2(1, -(Bind.TextBounds.X), 0, 14)
			end

			local currentBind = toggle_i.Key
			function toggle_f:SetBind(new)
				currentBind = new
				if (currentBind) then
					local cut = SUB(tostring(currentBind), 14, #tostring(currentBind))
					Bind.Text =  "[" .. cut .. "]"
				else
					Bind.Text = "[undefined]"
				end
				toggle_i.KCallback(currentBind) 

				self:ScaleText()
			end
			toggle_f:SetBind(currentBind)
			toggle_f:ScaleText()

			--
			local Binding = false
			function toggle_f:StartSelection()
				if not Binding then
					Binding = true

					Bind.Text = "[...]"
					toggle_f:ScaleText()

					local sel_c; sel_c = UIS.InputBegan:Connect(function(input, gameProcessed)
						if (gameProcessed) then return end

						if input.UserInputType == KBD and input.KeyCode ~= BSP then
							self:SetBind(input.KeyCode)
							sel_c:Disconnect()
							RS.RenderStepped:Wait()
							Binding = false
						elseif (input.UserInputType == KBD and input.KeyCode == BSP) or (not util.mouseIn(BindDetector) and input.UserInputType == MB2) then
							self:SetBind(false)
							sel_c:Disconnect()
							RS.RenderStepped:Wait()
							Binding = false
						end
					end)
				end
				toggle_f:ScaleText()
			end
			--

			toggle_f.State = toggle_i.State

			function toggle_f:updateState()
				if self.State then
					CACHE.Position = U2(0, 9, 0.5, -3)
				else
					CACHE.Position = U2(0, 0, 0.5, -3)
				end
			end; toggle_f:updateState()

			function toggle_f:Toggle()
				self.State = not self.State
				toggle_i.Callback(self.State)
				self:updateState()
			end

			function toggle_f:GetText()
				return Text.Text
			end

			function toggle_f:SetText(new)
				Text.Text = new
			end
			--

			window_f:addRawConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and input.UserInputType == KBD and input.KeyCode == currentBind and not Binding then
					toggle_f:Toggle()
				end
			end))

			window_f:addConnection("MouseButton1Click", BindDetector, function()
				toggle_f:StartSelection()
			end)
			window_f:addConnection("MouseButton1Click", TextDetector, function()
				toggle_f:Toggle()
			end)

			--
			return toggle_f
		end

		-- SLIDER Constructor - Options
		function page_f:NewSlider(options)
			local slider_i = util.merge(util.def_slider, options)
			local slider_f = {}
			--

			local Slider = util.create('Frame', {
				Name = "Slider",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 32),
				ZIndex = 2
			})
			
			local Bar = util.create('TextButton', {
				Name = "Bar",
				Parent = Slider,
				Active = true,
				AutoButtonColor = false,
				BackgroundColor3 = RGB(60, 60, 60),
				BorderSizePixel = 0,
				Position = U2(0, 0, 0, 20),
				Selectable = true,
				Size = U2(1, 0, 0, 5),
				Style = Enum.ButtonStyle.Custom,
				Text = "",
				TextSize = 14
			})
			
			local Fill = util.create('Frame', {
				Name = "Fill",
				Parent = Bar,
				BackgroundColor3 = RGB(205, 0, 255),
				BorderSizePixel = 0,
				Size = U2(0, 100, 1, 0)
			})
			
			local Sub = util.create('Frame', {
				Name = "Sub",
				Parent = Slider,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20)
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Sub,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = slider_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local Value = util.create('TextBox', {
				Name = "Value",
				Parent = Sub,
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				CursorPosition = -1,
				Position = U2(0, 0, 0.5, -6),
				Size = U2(1, -2, 0, 10),
				ZIndex = 3,
				Text = "",
				TextColor3 = RGB(178, 178, 178),
				PlaceholderText = (slider_i.Min .. "-" .. slider_i.Max),
				Font = Enum.Font.Code,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			--

			window_f:addConnection("MouseEnter", Bar, function()
				if (slider_f.dragging) then return end

				window_f.cursor:showCursor(util.horizontalSizeId)
			end)

			window_f:addConnection("MouseLeave", Bar, function()
				if (slider_f.dragging) then return end

				window_f.cursor:hideCursor()
			end)

			slider_f.dragging = false
			slider_f.RS_ID = "Slider_"..util.randomString(10)

			slider_f.connection = function()end
			window_f:addConnection("MouseButton1Down", Bar, function()
				slider_f.dragging = true
				RS:BindToRenderStep(slider_f.RS_ID, 1, slider_f.connection)
			end)
			window_f:addRawConnection(UIS.InputEnded:Connect(function(input)
				if input.UserInputType == MB1 then
					if util.mouseIn(Bar) then
						window_f.cursor:showCursor(util.horizontalSizeId)
					else
						window_f.cursor:hideCursor()
					end

					slider_f.dragging = false
					RS:UnbindFromRenderStep(slider_f.RS_ID)
				end
			end))

			--

			slider_f.current    = slider_i.Default
			slider_f.min        = slider_i.Min
			slider_f.max        = slider_i.Max
			slider_f.decimals   = slider_i.Decimals

			slider_f.difference = slider_f.max - slider_f.min

			function slider_f:placeValue(val)
				local new = CLAMP(val, self.min, self.max)
				local SASX = Bar.AbsoluteSize.X
				local SAPX = Bar.AbsolutePosition.X
				local offset = (new - self.min) * SASX / (slider_f.max - slider_f.min)

				Value.Text = tostring(new) .. " " .. slider_i.Suffix

				self.current = new
				slider_i.Callback(new)

				local nx = CLAMP(offset, 0, SASX)

				Fill.Size = U2(0, nx, 1, 0)
			end
			slider_f:placeValue(slider_f.current)

			window_f:addConnection("FocusLost", Value, function()
				Value.Text = Value.Text:gsub("%a", "")
				local n = tonumber(Value.Text)

				if n then 
					n = CLAMP(n, slider_f.min, slider_f.max)
					slider_f:placeValue(n)
				end
			end)

			function slider_f:roundToN(a, n)
				if n >= 1 then
					local x = tonumber("1" .. REP("0", n))

					return ROUND(a * x)/x
				else
					return ROUND(a)
				end
			end

			local previous;
			slider_f.connection = function()
				if (slider_f.dragging) then
					local SASX = Bar.AbsoluteSize.X
					local SAPX = Bar.AbsolutePosition.X

					-- PLACING
					local offset = Mouse.X - SAPX
					local new_x = CLAMP(offset, 0, SASX)

					local difference = (slider_f.max - slider_f.min)
					
					-- CALCULATIONS
					slider_f.current = slider_f:roundToN(new_x * difference / SASX + slider_f.min, slider_f.decimals)

					if previous ~= slider_f.current then
						slider_f:placeValue(slider_f.current)
						previous = slider_f.current
					end
				end
			end

			--

			function slider_f:GetValue()
				return self.current
			end
			function slider_f:SetValue(new)
				self:placeValue(new)
			end

			function slider_f:GetText()
				return Text.Text
			end
			function slider_f:SetText(new)
				Text.Text = new
			end

			--
			return slider_f
		end

		-- PICKER Constructor - Options
		function page_f:NewPicker(options)
			local picker_i = util.merge(util.def_picker, options)
			local picker_f = {}
			--

			local Picker = util.create('Frame', {
				Name = "Picker",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20),
				ZIndex = 2
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Picker,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = picker_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local Detector = util.create('TextButton', {
				Name = "Detector",
				Parent = Picker,
				Active = true,
				AutoButtonColor = false,
				BackgroundTransparency = 1-(picker_i.Default[2] or 1),
				BackgroundColor3 = picker_i.Default[1] or RGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = U2(1, -21, 0.5, -4),
				Selectable = true,
				Size = U2(0, 18, 0, 8),
				Style = Enum.ButtonStyle.Custom,
				ZIndex = 3,
				Text = "",
				TextSize = 14
			})
			
			local AlphaGrid = util.create('ImageLabel', {
				Name = "AlphaGrid",
				Parent = Picker,
				BackgroundColor3 = RGB(255, 255, 255),
				BorderColor3 = RGB(152, 152, 152),
				BackgroundTransparency = 0,
				Position = U2(1, -21, 0.5, -4),
				Size = U2(0, 18, 0, 8),
				ZIndex = 2,
				Image = "http://www.roblox.com/asset/?id=9543861305"
			})

			--

			window_f:addConnection("MouseButton1Click", Detector, function()
				if (g_picker.previousDetector ~= Detector or not g_picker.GlobalCP.Visible) then
					g_picker.GlobalCP.Visible = true
					g_picker.GlobalCP.Position = U2(1, 8, 0, Detector.AbsolutePosition.Y-Window.AbsolutePosition.Y)

					local r, g, b = util.c3_rgb(Detector.BackgroundColor3)
					local h, s, v = util.c3_hsv(Detector.BackgroundColor3)
					
					g_picker.Callback = function(c, a)
						Detector.BackgroundColor3 = c 
						Detector.BackgroundTransparency = util.a_t(a)

						picker_i.Callback(c, a)
					end
					g_picker.Current = {
						Red = r,
						Green = g,
						Blue = b,
						Alpha = util.t_a(Detector.BackgroundTransparency),
						Hex = util.c3_hex(Detector.BackgroundColor3),

						Hue = h,
						Sat = s,
						Val = v
					}

					g_picker:Place()
				else
					g_picker.GlobalCP.Visible = false
					g_picker.Callback = function(c, a) end
					g_picker.Current = {
						Red = 1,
						Green = 1,
						Blue = 1,
						Alpha = 1,
						Hex = "#FFFFFF",

						Hue = 0,
						Sat = 0,
						Val = 1
					}
				end

				g_picker.previousDetector = Detector
			end)

			function picker_f:GetText()
				return Text.Text
			end
			function picker_f:SetText(new)
				Text.Text = new
			end

			--
			return picker_f
		end

		-- DROPDOWN Constructor - Options
		function page_f:NewDropdown(options)
			local dropdown_i = util.merge(util.def_dropdown, options)
			local dropdown_f = {}
			--

			local Dropdown = util.create('Frame', {
				Name = "Dropdown",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 38),
				ZIndex = 2
			})

			local Sub = util.create('Frame', {
				Name = "Sub",
				Parent = Dropdown,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20)
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Sub,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = dropdown_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local Bar = util.create('TextButton', {
				Name = "Bar",
				Parent = Dropdown,
				Active = true,
				AutoButtonColor = false,
				BackgroundColor3 = RGB(14, 31, 66),
				BorderSizePixel = 0,
				Position = U2(0, 0, 0, 20),
				Selectable = true,
				Size = U2(1, 0, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				Text = "",
				TextSize = 14
			})
			
			local Current = util.create('TextLabel', {
				Name = "Current",
				Parent = Bar,
				BackgroundTransparency = 1,
				Position = U2(0, 4, 0, 0),
				Size = U2(1, -4, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = dropdown_i.Options[dropdown_i.Default] or "NONE",
				TextColor3 = dropdown_i.Options[dropdown_i.Default] and RGB(230, 230, 230) or RGB(160, 160, 160),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Container = util.create('Frame', {
				Name = "Container",
				Parent = Dropdown,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0, 38),
				Size = U2(1, 0, 0, 20),
				Visible = false,
				ZIndex = 9
			})

			local OptionList = util.create('UIListLayout', {
				Parent = Container,
				Name = "OptionList"
			})

			local previous_option;
			window_f:addConnection("MouseButton1Click", Bar, function()
				Container.Visible = not Container.Visible

				if (Container.Visible) then
					previous_option = Current.Text

					Current.Text = "..."
					Current.TextColor3 = RGB(160, 160, 160)
				else
					Current.Text = previous_option
					Current.TextColor3 = previous_option ~= "NONE" and RGB(230, 230, 230) or RGB(160, 160, 160)
				end
			end)

			local function setOption(n)
				if not n then
					Current.Text = "NONE"
					Current.TextColor3 = RGB(160, 160, 160)

					dropdown_i.Callback(nil)
					return;
				end

				Current.Text = dropdown_i.Options[n]
				Current.TextColor3 = RGB(230, 230, 230)

				dropdown_i.Callback(Current.Text)
			end

			window_f:addRawConnection(UIS.InputBegan:Connect(function(input)
				if input.UserInputType == MB2 and Container.Visible then
					Container.Visible = false

					setOption(nil)
				end
			end))

			for i,o in next, dropdown_i.Options do
				local Option = util.create('TextButton', {
					Name = "Option",
					Parent = Container,
					Active = true,
					AutoButtonColor = false,
					BackgroundColor3 = RGB(14, 31, 66),
					BorderSizePixel = 0,
					Position = U2(0, 0, 0, 20),
					Selectable = true,
					Size = U2(1, 0, 0, 14),
					Style = Enum.ButtonStyle.Custom,
					Text = "",
					TextSize = 14,
					ZIndex = 10
				})
				
				local Option_Text = util.create('TextLabel', {
					Name = "Option_Text",
					Parent = Option,
					BackgroundTransparency = 1,
					Position = U2(0, 4, 0, 0),
					Size = U2(1, -4, 1, 0),
					ZIndex = 11,
					Font = Enum.Font.Code,
					Text = o,
					TextColor3 = RGB(230, 230, 230),
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				window_f:addConnection("MouseButton1Click", Option, function()
					setOption(i)

					Container.Visible = false
				end)
			end

			function dropdown_f:GetText()
				return Text.Text
			end
			function dropdown_f:SetText(new)
				Text.Text = new
			end

			function dropdown_f:SetOption(n)
				setOption(n)
			end
	
			return dropdown_f
		end

		-- CHIPSET
		function page_f:NewChipset(options)
			local chipset_i = util.merge(util.def_chipset, options)
			local chipset_f = {}
			--

			local Chipset = util.create('Frame', {
				Name = "Chipset",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 38),
				ZIndex = 2
			})

			local Sub = util.create('Frame', {
				Name = "Sub",
				Parent = Chipset,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20)
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Sub,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = chipset_i.Text,
				TextColor3 = RGB(230, 230, 230),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local Bar = util.create('TextButton', {
				Name = "Bar",
				Parent = Chipset,
				Active = true,
				AutoButtonColor = false,
				BackgroundColor3 = RGB(14, 31, 66),
				BorderSizePixel = 0,
				Position = U2(0, 0, 0, 20),
				Selectable = true,
				Size = U2(1, 0, 0, 14),
				Style = Enum.ButtonStyle.Custom,
				Text = "",
				TextSize = 14
			})
			
			local Current = util.create('TextLabel', {
				Name = "Current",
				Parent = Bar,
				BackgroundTransparency = 1,
				Position = U2(0, 4, 0, 0),
				Size = U2(1, -4, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = "NONE",
				TextColor3 = RGB(160, 160, 160),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Container = util.create('Frame', {
				Name = "Container",
				Parent = Chipset,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0, 38),
				Size = U2(1, 0, 0, 20),
				Visible = false,
				ZIndex = 9
			})

			local OptionList = util.create('UIListLayout', {
				Parent = Container,
				Name = "OptionList"
			})

			window_f:addConnection("MouseButton1Click", Bar, function()
				Container.Visible = not Container.Visible
			end)

			window_f:addRawConnection(UIS.InputBegan:Connect(function(input)
				if input.UserInputType == MB2 and Container.Visible then
					Container.Visible = false
				end
			end))

			local function updateOptionString(doCallBack)
				local s = ""
				local c = 0

				for o,v in next, chipset_i.Options do
					if (v) then 
						s = s .. o .. ", "
						c = c + 1
					end
				end

				if c == 0 then
					Current.Text = "NONE"
					Current.TextColor3 = RGB(160, 160, 160)
				else
					s = s:sub(1, -3)

					Current.Text = s
					Current.TextColor3 = RGB(230, 230, 230)
				end

				if (doCallBack) then chipset_i.Callback(chipset_i.Options) end
			end
			updateOptionString(false)

			for o,v in next, chipset_i.Options do
				local Option = util.create('TextButton', {
					Name = "Option",
					Parent = Container,
					Active = true,
					AutoButtonColor = false,
					BackgroundColor3 = RGB(14, 31, 66),
					BorderSizePixel = 0,
					Position = U2(0, 0, 0, 20),
					Selectable = true,
					Size = U2(1, 0, 0, 14),
					Style = Enum.ButtonStyle.Custom,
					Text = "",
					TextSize = 14,
					ZIndex = 10
				})
				
				local Option_Text = util.create('TextLabel', {
					Name = "Option_Text",
					Parent = Option,
					BackgroundTransparency = 1,
					Position = U2(0, 4, 0, 0),
					Size = U2(1, -4, 1, 0),
					ZIndex = 11,
					Font = Enum.Font.Code,
					Text = o,
					TextColor3 = chipset_i.Options[o] and RGB(205, 0, 255) or RGB(230, 230, 230),
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				window_f:addConnection("MouseButton1Click", Option, function()
					local new = not chipset_i.Options[o]

					chipset_i.Options[o] = new
					Option_Text.TextColor3 = new and RGB(205, 0, 255) or RGB(230, 230, 230)

					updateOptionString(true)
				end)
			end

			function chipset_f:GetText()
				return Text.Text
			end
			function chipset_f:SetText(new)
				Text.Text = new
			end
	
			return chipset_f
		end

		-- Label
		function page_f:NewLabel(options)
			local label_i = util.merge(util.def_label, options)
			local label_f = {}
			--

			local Label = util.create('Frame', {
				Name = "Label",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 20),
				ZIndex = 2
			})
			
			local Text = util.create('TextLabel', {
				Name = "Text",
				Parent = Label,
				BackgroundTransparency = 1,
				Position = U2(0, 0, 0.5, -1),
				Size = U2(1, 0, 0, 6),
				ZIndex = 3,
				Font = Enum.Font.Code,
				Text = label_i.Text,
				TextColor3 = RGB(255, 255, 255),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})

			--

			function label_f:GetText()
				return Text.Text
			end
			function label_f:SetText(new)
				Text.Text = new
			end

			--
			return label_f
		end

		-- Separator
		function page_f:NewSeparator()
			local Separator = util.create('Frame', {
				Name = "Separator",
				Parent = Page,
				BackgroundTransparency = 1,
				Size = U2(1, 0, 0, 12),
				ZIndex = 2
			})
			
			local Frame = util.create('Frame', {
				Parent = Separator,
				BackgroundColor3 = RGB(152, 152, 152),
				BorderSizePixel = 0,
				Position = U2(0, 0, 0.5, 0),
				Size = U2(1, 0, 0, 1),
				ZIndex = 3
			})
		end
		
		return page_f
	end

	--
	return window_f
end

return library

-- do -- Example
--     loadstring(string.rep("warn();", 4))()

--     local W = library.New({
--         Text = "Window", 
--         Position = V2(200, 200),
--         Position_Callback = function(v)
--             print(tostring(v))
--         end
--     })
--     local P = W.NewPage({Text="ESP"})
--     local P = W.NewPage({Text="Aimbot"})
	
--     P:NewButton({
--         Text = "Close", 
--         Key = Enum.KeyCode.X,
--         Callback = function() print("bind pressed"); W:Close() end,
--         KCallback = function(new) print("set bind to: " .. tostring(new)) end
--     })

--     P:NewToggle({
--         Text = "Aimbot", 
--         State = true,
--         Key = Enum.KeyCode.B,
--         Callback = function(state) print("now: " .. tostring(state)) end,
--         KCallback = function(new) print("set bind to: " .. tostring(new)) end
--     })

--     P:NewSlider({Text="Slide", Default = 1, Min = 0, Max = 10, Decimals = 4, Suffix = "px",
--         Callback = function(v)
--             warn(v)
--         end
--     })

--     P:NewPicker({Text="FOV Color", Default = {RGB(0, 0, 255), 1},
--         Callback = function(c, a)
--             warn(tostring(c), tostring(a))
--         end
--     })
--     P:NewPicker({Text="BOX Color", Default = {RGB(0, 0, 0), 1},
--         Callback = function(c, a)
--             warn(tostring(c), tostring(a))
--         end
--     })
--     P:NewDropdown({Text="BOX Location", Options = {"Head", "Torso", "Feet"}, Default = 1,
--         Callback = function(o)
--             warn(tostring(o))
--         end
--     })
--     P:NewChipset({Text="BOX Location", Options = {["Head"] = true, ["Torso"] = false, ["Feet"] = true},
--         Callback = function(options)
--             warn()
--             for i,v in pairs(options) do
--                 print(i,v)
--             end
--         end
--     })

--     P:NewSeparator()
--     P:NewLabel({Text = "Label"})

--     local P = W.NewPage({Text="Visuals"})
--     local P = W.NewPage({Text="Environnment"})
-- end
