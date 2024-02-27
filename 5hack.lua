local rgb = { r = 0, g = 0, b = 0}

local noclipping = false
local NoclipSpeed = 5.0

local cam = nil
local FreeCameraMode = "Object Spooner"

local CrownMenu = { 
	ESP = {},
	ObjectOptions = {
		Sensitivity = 0.1,
		currentObject = {},
	},
	Functions = {},
	DynamicTriggers = {
		Search = {
			-- Usage { Trigger To Search for but trim it down, ID that gets uded in buttons }
			{ "jail:jailPlayer", "ESXQalleJail" },
			{ "job:rev", 'ESXRevive' },
			{ "job:ESXHandcuff", 'ESXHandcuff' },
			{ "job:drag", 'ESXDrag' },
			{ "vangelico_robbery:rob", 'ESXVangelicoRobbery' },
			{ "Tackle", "tryTackle"},
			{ "InteractionMenu:Jail", 'JailSEM' },
			{ "InteractionMenu:DragNear", 'DragSEM' },
		},
		Triggers = {
			['JailSEM'] = "SEM_InteractionMenu:Jail",
			['DragSEM'] = "SEM_InteractionMenu:DragNear",
		},
	},
	Objectlist = {},
    menus = {},
    Cache = {},
    UI = {
		GTAInput = false,
		RGB = true,
		MenuX = 0.75,
		MenuY = 0.025,
		NotificationX = 0.011,
		NotificationY = 0.3025,
        TitleHeight = 0.11,
        ButtonHeight = 0.038,
        ButtonScale = 0.325,
        ButtonFont = 0,
		MaximumOptionCount = 14,
	},
	BottomText = nil,
	Version = "1.1.0",
	ScreenWidth, ScreenHeight = Citizen.InvokeNative(0x873C9F3104101DD3, Citizen.PointerValueInt(), Citizen.PointerValueInt()),
    rgb = { r = 255, g = 255, b = 255},
    optionCount = 0,
    currentMenu = nil,
}

local RuntimeTXD = CreateRuntimeTxd('CrownMenu')
local HeaderObject = CreateDui("https://cdn.discordapp.com/attachments/985183909195186197/1119059235108556880/standard_8.gif", 680, 240)
_G.HeaderObject = HeaderObject
local TextureThing = GetDuiHandle(HeaderObject)
local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'CrownMenuHeader', TextureThing)
local LogoObject = CreateDui("https://cdn.discordapp.com/attachments/985183909195186197/1119059235108556880/standard_8.gif", 30, 30)
_G.LogoObject = LogoObject
local TextureThing = GetDuiHandle(LogoObject)
local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'CrownMenuLogo', TextureThing)

if Ham == nil then
	CrownMenu.UI.GTAInput = true
	Ham = {}
	
	function Ham.printStr(resname, msg)
	    print(msg)
	end

	function Ham.getName()
        return "nil"
	end

	function Ham.getKeyState(val)
        return 0
	end
end

function CrownMenu.RGBRainbow(frequency)
	if CrownMenu.UI.RGB then
		local result = {}
		
		local curtime = GetGameTimer() / 1000
		
		result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
		result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
		result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)
	
		return result
	else
		return CrownMenu.rgb
	end
end

function CrownMenu.SetMenuProperty(id, property, value)
	if id and CrownMenu.menus[id] then
		CrownMenu.menus[id][property] = value
	end
end

function CrownMenu.IsMenuVisible(id)
	if id and CrownMenu.menus[id] then
		return CrownMenu.menus[id].visible
	else
		return false
	end
end

function CrownMenu.CloseMenu()
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		if menu.aboutToBeClosed then
			CrownMenu.optionCount = 0
			menu.aboutToBeClosed = false
			CrownMenu.SetMenuVisible(CrownMenu.currentMenu, false)
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			CrownMenu.currentMenu = nil
		else
			menu.aboutToBeClosed = true
		end
	end
end

function CrownMenu.SetMenuVisible(id, visible, holdCurrent)
	if id and CrownMenu.menus[id] then
		CrownMenu.SetMenuProperty(id, 'visible', visible)

		if not holdCurrent and CrownMenu.menus[id] then
			CrownMenu.SetMenuProperty(id, 'currentOption', 1)
		end

		if visible then
			if id ~= CrownMenu.currentMenu and CrownMenu.IsMenuVisible(CrownMenu.currentMenu) then
				CrownMenu.SetMenuProperty(CrownMenu.currentMenu, false)
			end

			CrownMenu.currentMenu = id
		end
	end
end


function GetTextWidthS(string, font, scale)
	font = font or 4
	scale = scale or 0.35
	CrownMenu.Cache[font] = CrownMenu.Cache[font] or {}
	CrownMenu.Cache[font][scale] = CrownMenu.Cache[font][scale] or {}
	if CrownMenu.Cache[font][scale][string] then return CrownMenu.Cache[font][scale][string].length end
	Citizen.InvokeNative(0x54CE8AC98E120CAB, "STRING")
	Citizen.InvokeNative(0x6C188BE134E074AA, string)
	Citizen.InvokeNative(0x66E0276CC5F6B9DA, font or 4)
	Citizen.InvokeNative(0x07C837F9A01C34C9, scale or 0.35, scale or 0.35)
	local length = Citizen.InvokeNative(0x85F061DA64ED2F67, 1, Citizen.ReturnResultAnyway(), Citizen.ResultAsFloat())

	CrownMenu.Cache[font][scale][string] = {length = length}
	return length
end

function CrownMenu.GetTextWidth(string, font, scale)
    return GetTextWidthS(string, font, scale)
end

function CrownMenu.DrawSprite(TxtDict, TxtName, x, y, width, height, heading, red, green, blue, alpha)
	Citizen.InvokeNative(0xE7FFAE5EBF23D890, TxtDict, TxtName, x, y, width, height, heading, red, green, blue, alpha)
end

function CrownMenu.DrawRect(x, y, width, height, color)
	Citizen.InvokeNative(0x3A618A217E5154F0, x, y, width, height, color.r, color.g, color.b, color.a)
end

function CrownMenu.DrawTitle()
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		local x = menu.x + menu.width / 2
		local y = menu.y + CrownMenu.UI.TitleHeight / 2

		CrownMenu.DrawSprite('CrownMenu', 'CrownMenuHeader', x, y, menu.width, CrownMenu.UI.TitleHeight, 0.0, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
	end
end

function CrownMenu.DrawBottom()
	local menu = CrownMenu.menus[CrownMenu.currentMenu]

	if menu then
		local x = menu.x + menu.width / 2

		local multiplier = 1
	
		if CrownMenu.optionCount > CrownMenu.UI.MaximumOptionCount then
			multiplier = CrownMenu.UI.MaximumOptionCount
		else
			multiplier = CrownMenu.optionCount
		end

		CrownMenu.DrawRect(x, menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 2 + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier, menu.width, CrownMenu.UI.ButtonHeight, {r = 0, g = 0, b = 0, a = 255})
	
		CrownMenu.DrawRect(x, menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier, menu.width, 0.001, {r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 255})
		
		CrownMenu.DrawSprite('CrownMenu', 'CrownMenuLogo', x, menu.y + CrownMenu.UI.ButtonHeight / 2 + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier, 0.02, 0.02 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)

		CrownMenu.DrawText(CrownMenu.Version, {menu.x + menu.width - CrownMenu.GetTextWidth(CrownMenu.Version), menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 6 + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 1, 0, 0)

		CrownMenu.DrawText(menu.currentOption .. " / " ..CrownMenu.optionCount, {menu.x + 0.005, menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 6 + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 0, 0, 0)

		
		--[[
		if CrownMenu.BottomText ~= nil and CrownMenu.BottomText ~= "" then
            
		    CrownMenu.DrawRect(x, menu.y + CrownMenu.UI.TitleHeight + 0.005 + CrownMenu.UI.ButtonHeight * 2 + CrownMenu.UI.ButtonHeight * multiplier, menu.width, 0.001, {r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 255})
		
		    CrownMenu.DrawRect(x, menu.y + CrownMenu.UI.TitleHeight + 0.025 + CrownMenu.UI.ButtonHeight * 2 + CrownMenu.UI.ButtonHeight * multiplier, menu.width, CrownMenu.UI.ButtonHeight, {r = 0, g = 0, b = 0, a = 200})
		
			CrownMenu.DrawText(CrownMenu.BottomText, {menu.x + 0.018, 0.044 + menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 6 + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier}, {255, 255, 255, 255}, 0.3, 0)
			
		    CrownMenu.DrawSprite('shared', 'info_icon_32', menu.x + 0.010, 0.058 + menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 6 + CrownMenu.UI.ButtonHeight + CrownMenu.UI.ButtonHeight * multiplier, 0.016, 0.016 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, 255, 255, 255, 255)

		end
		]]
	end
end

function CrownMenu.DrawSubTitle()
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		local x = menu.x + menu.width / 2
		local y = menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight / 2
		local subTitleColor = { r = 0, g = 0, b = 0, a = 240 }
		CrownMenu.DrawRect(x, y, menu.width, CrownMenu.UI.ButtonHeight, subTitleColor)
		CrownMenu.DrawRect(x, y - CrownMenu.UI.ButtonHeight / 2, menu.width, 0.001, {r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 255})
		CrownMenu.DrawText(menu.subTitle, {menu.x + menu.width / 2, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 1, 0, 1)
	end
end

function CrownMenu.DrawText(text, location, colour, size, font, alignment, textentry, outline)
	x, y = table.unpack(location)
	r, g, b, a = table.unpack(colour)

	menu = CrownMenu.menus[CrownMenu.currentMenu]

    SetTextFont(font)
    SetTextProportional(1)
	SetTextScale(size, size)
	if outline then
		SetTextDropshadow(1, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
	end
	SetTextColour(r, g, b, a)
	if alignment == 1 then
		SetTextCentre(1)
	elseif alignment == 2 then
		if menu then
			SetTextWrap(menu.x, menu.x + menu.width - 0.005)
		end
		SetTextRightJustify(true)
	elseif alignment == 3 then
		if menu then
			SetTextWrap(menu.x, menu.x + menu.width - 0.022)
		end
		SetTextRightJustify(true)
	elseif alignment == 4 then
		if menu then
			SetTextWrap(0.0, -1.0)
		end
	end
	if type(textentry) == "string" then
		AddTextEntry(textentry, text)
		SetTextEntry(textentry)
	else
		SetTextEntry("STRING")
	end
    AddTextComponentString(text)
    DrawText(x, y)
end
  
function CrownMenu.drawButton(text, subText, menubutton, bottomtext)
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	local x = menu.x + menu.width / 2
	local multiplier = nil

	if menu.currentOption <= menu.maxOptionCount and CrownMenu.optionCount <= menu.maxOptionCount then
		multiplier = CrownMenu.optionCount
	elseif CrownMenu.optionCount > menu.currentOption - menu.maxOptionCount and CrownMenu.optionCount <= menu.currentOption then
		multiplier = CrownMenu.optionCount - (menu.currentOption - menu.maxOptionCount)
	end

	if multiplier then
		local y = menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight + (CrownMenu.UI.ButtonHeight * multiplier) - CrownMenu.UI.ButtonHeight / 2
		local backgroundColor = nil

		if menu.currentOption == CrownMenu.optionCount then
			backgroundColor = {r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 180}
			CrownMenu.BottomText = bottomtext
		else
			backgroundColor = menu.menuBackgroundColor
		end
		
		CrownMenu.DrawRect(x, y, menu.width, CrownMenu.UI.ButtonHeight, backgroundColor)
		
		CrownMenu.DrawText(text, {menu.x + 0.005, y - (CrownMenu.UI.ButtonHeight / 2) + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 0)
		
		if menubutton then

			CrownMenu.DrawText(">>>", {menu.width + 0.005, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 2)
		
		end

		if not HasStreamedTextureDictLoaded('commonmenu') then
			RequestStreamedTextureDict('commonmenu', true)
		end
		
		if subText == "On" then
	
            CrownMenu.DrawSprite('commonmenu', "shop_box_tick", CrownMenu.menus[CrownMenu.currentMenu].width + 0.005 + menu.x - 0.017, y + 0.005 - 0.0048, 0.025, 0.025 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, 255, 255, 255, 200)
			--CrownMenu.DrawText("~g~On", {menu.width + 0.005, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 2)
		
		elseif subText == "Off" then

			CrownMenu.DrawSprite('commonmenu', "shop_box_blank", CrownMenu.menus[CrownMenu.currentMenu].width + 0.005 + menu.x - 0.017, y + 0.005 - 0.0048, 0.025, 0.025 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, 255, 255, 255, 200)
			--CrownMenu.DrawText("~r~Off", {menu.width + 0.005, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 2)
		
		elseif not menubutton and subText ~= nil then

			CrownMenu.DrawText(subText, {menu.width + 0.005, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 2)
		
		end
	end
end

function CrownMenu.DrawChanger(text, subText)
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	local x = menu.x + menu.width / 2
	local multiplier = nil

	if menu.currentOption <= menu.maxOptionCount and CrownMenu.optionCount <= menu.maxOptionCount then
		multiplier = CrownMenu.optionCount
	elseif CrownMenu.optionCount > menu.currentOption - menu.maxOptionCount and CrownMenu.optionCount <= menu.currentOption then
		multiplier = CrownMenu.optionCount - (menu.currentOption - menu.maxOptionCount)
	end

	if multiplier then
		local y = menu.y + CrownMenu.UI.TitleHeight + CrownMenu.UI.ButtonHeight + (CrownMenu.UI.ButtonHeight * multiplier) - CrownMenu.UI.ButtonHeight / 2
		local backgroundColor = nil

		if menu.currentOption == CrownMenu.optionCount then
			backgroundColor = {r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 180}
			Alignment = 3
		else
			backgroundColor = menu.menuBackgroundColor
			Alignment = 2
		end


		if not HasStreamedTextureDictLoaded('commonmenu') then RequestStreamedTextureDict('commonmenu', true) end

		CrownMenu.DrawRect(x, y, menu.width, CrownMenu.UI.ButtonHeight, backgroundColor)
		
		CrownMenu.DrawText(text, {menu.x + 0.005, y - (CrownMenu.UI.ButtonHeight / 2) + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, 0)
	
		CrownMenu.DrawText(subText, {menu.width + 0.005, y - CrownMenu.UI.ButtonHeight / 2 + 0.005}, {255, 255, 255, 255}, CrownMenu.UI.ButtonScale, 0, Alignment)
		
		if menu.currentOption == CrownMenu.optionCount then
			CrownMenu.DrawSprite('commonmenu', 'arrowright', CrownMenu.UI.MenuX + menu.width - 0.0075, y, 0.0205, 0.0205 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, 255, 255, 255, 255)
			
			CrownMenu.DrawSprite('commonmenu', 'arrowright', CrownMenu.UI.MenuX + menu.width - 0.0175, y, 0.0205, 0.0205 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 180.0, 255, 255, 255, 255)
		end
	end
end


function CrownMenu.CreateMenu(id, title, subtitle)
	-- Default settings
	CrownMenu.menus[id] = { }
	CrownMenu.menus[id].title = title
	CrownMenu.menus[id].subTitle = subtitle

	CrownMenu.menus[id].visible = false

	CrownMenu.menus[id].previousMenu = nil

	CrownMenu.menus[id].aboutToBeClosed = false

	CrownMenu.menus[id].x = 0.75
	CrownMenu.menus[id].y = 0.025
	CrownMenu.menus[id].width = 0.24

	CrownMenu.menus[id].currentOption = 1
	CrownMenu.menus[id].maxOptionCount = CrownMenu.UI.MaximumOptionCount

	CrownMenu.menus[id].titleFont = 6
	CrownMenu.menus[id].titleColor = { r = 255, g = 255, b = 255, a = 255 }
	CrownMenu.menus[id].titleBackgroundColor = { r = 255, g = 0, b = 0, a = 255 }
	CrownMenu.menus[id].titleBackgroundSprite = nil

	CrownMenu.menus[id].menuTextColor = { r = 255, g = 255, b = 255, a = 255 }
	CrownMenu.menus[id].menuSubTextColor = { r = 189, g = 189, b = 189, a = 255 }
	CrownMenu.menus[id].menuFocusTextColor = { r = 255, g = 255, b = 255, a = 255 }
	CrownMenu.menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	CrownMenu.menus[id].menuBackgroundColor = { r = 0, g = 0, b = 0, a = 160 }

	CrownMenu.menus[id].subTitleBackgroundColor = { r = CrownMenu.menus[id].menuBackgroundColor.r, g = CrownMenu.menus[id].menuBackgroundColor.g, b = CrownMenu.menus[id].menuBackgroundColor.b, a = 255 }

	CrownMenu.menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } --https://pastebin.com/0neZdsZ5
end

function CrownMenu.CreateSubMenu(id, parent, subTitle)
	if CrownMenu.menus[parent] then
		CrownMenu.CreateMenu(id, CrownMenu.menus[parent].title)

		if subTitle then
			CrownMenu.SetMenuProperty(id, 'subTitle', subTitle)
		else
			CrownMenu.SetMenuProperty(id, 'subTitle', CrownMenu.menus[parent].subTitle)
		end

		CrownMenu.SetMenuProperty(id, 'previousMenu', parent)

		CrownMenu.SetMenuProperty(id, 'x', CrownMenu.menus[parent].x)
		CrownMenu.SetMenuProperty(id, 'y', CrownMenu.menus[parent].y)
		CrownMenu.SetMenuProperty(id, 'maxOptionCount', CrownMenu.menus[parent].maxOptionCount)
		CrownMenu.SetMenuProperty(id, 'titleFont', CrownMenu.menus[parent].titleFont)
		CrownMenu.SetMenuProperty(id, 'titleColor', CrownMenu.menus[parent].titleColor)
		CrownMenu.SetMenuProperty(id, 'titleBackgroundColor', CrownMenu.menus[parent].titleBackgroundColor)
		CrownMenu.SetMenuProperty(id, 'titleBackgroundSprite', CrownMenu.menus[parent].titleBackgroundSprite)
		CrownMenu.SetMenuProperty(id, 'menuTextColor', CrownMenu.menus[parent].menuTextColor)
		CrownMenu.SetMenuProperty(id, 'menuSubTextColor', CrownMenu.menus[parent].menuSubTextColor)
		CrownMenu.SetMenuProperty(id, 'menuFocusTextColor', CrownMenu.menus[parent].menuFocusTextColor)
		CrownMenu.SetMenuProperty(id, 'menuFocusBackgroundColor', CrownMenu.menus[parent].menuFocusBackgroundColor)
		CrownMenu.SetMenuProperty(id, 'menuBackgroundColor', CrownMenu.menus[parent].menuBackgroundColor)
		CrownMenu.SetMenuProperty(id, 'subTitleBackgroundColor', CrownMenu.menus[parent].subTitleBackgroundColor)
	end
end

function CrownMenu.MenuButton(text, id, bottomText)
	local buttonText = text
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		CrownMenu.optionCount = CrownMenu.optionCount + 1

		local isCurrent = menu.currentOption == CrownMenu.optionCount

		CrownMenu.drawButton(text, nil, true, bottomText)

		if isCurrent then
			if IsDisabledControlJustPressed(0, 201) then
				PlaySoundFrontend(-1, menu.buttonPressedSound.name, menu.buttonPressedSound.set, true)
				CrownMenu.SetMenuVisible(CrownMenu.currentMenu, false)
				CrownMenu.SetMenuProperty(id, 'x', CrownMenu.UI.MenuX)
				CrownMenu.SetMenuProperty(id, 'y', CrownMenu.UI.MenuY)
				CrownMenu.SetMenuVisible(id, true, true)
				return true
			elseif IsDisabledControlJustPressed(0, 189) or IsDisabledControlJustPressed(0, 190) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		return false
	end
end

function CrownMenu.CurrentMenu()
	return CrownMenu.currentMenu
end

PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", true)

function CrownMenu.ValueChanger(text, index, changeamout, minmaxvalues, callback, sensitivity)

	lowestvalue, highestvalue = table.unpack(minmaxvalues)

	if index == nil then
		index = 0
	end

	local menu = CrownMenu.menus[CrownMenu.currentMenu]

	if menu then

		CrownMenu.optionCount = CrownMenu.optionCount + 1

		local retval = CrownMenu.DrawChanger(text, tostring(index))

		if menu.currentOption == CrownMenu.optionCount then
			if sensitivity then
				if IsDisabledControlPressed(0, 189) then
					if index > lowestvalue then
						callback(index - changeamout)
					end
				end
				if IsDisabledControlPressed(0, 190) then
					if index < highestvalue then
						callback(index + changeamout)
					end
				end
			else
				if IsDisabledControlJustPressed(0, 189) then
					if index > lowestvalue then
						callback(index - changeamout)
					end
				end
				if IsDisabledControlJustPressed(0, 190) then
					if index < highestvalue then
						callback(index + changeamout)
					end
				end
			end
		end

		if retval then
	        return true
		end
	end
	return false
end

function CrownMenu.ComboBox(text, items, index, callback)
	
	local itemsCount = #items
	local selectedItem = items[index]
	local buttonText = text

	local menu = CrownMenu.menus[CrownMenu.currentMenu]

	if menu then

		CrownMenu.optionCount = CrownMenu.optionCount + 1

		CrownMenu.DrawChanger(text, selectedItem)

		if menu.currentOption == CrownMenu.optionCount then
			if IsDisabledControlJustPressed(0, 189) then
				if index > 1 then
					callback(index - 1)
				elseif index == 1 then
					callback(itemsCount)
				end
			end
			if IsDisabledControlJustPressed(0, 190) then
				if itemsCount > index then
					callback(index + 1)
				elseif index == itemsCount then
					callback(1)
				end
			end
			if IsDisabledControlJustPressed(0, 201) then
				PlaySoundFrontend(-1, menu.buttonPressedSound.name, menu.buttonPressedSound.set, true)
				return true
			elseif IsDisabledControlJustPressed(0, 189) or IsDisabledControlJustPressed(0, 190) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		return false
	end
end

function CrownMenu.Button(text, subText, bottomText)
	local buttonText = text
	if subText then
		buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
	end
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		CrownMenu.optionCount = CrownMenu.optionCount + 1

		CrownMenu.drawButton(text, subText, false, bottomText)

		if menu.currentOption == CrownMenu.optionCount then
			if IsDisabledControlJustPressed(0, 201) then
				PlaySoundFrontend(-1, menu.buttonPressedSound.name, menu.buttonPressedSound.set, true)
				return true
			elseif IsDisabledControlJustPressed(0, 189) or IsDisabledControlJustPressed(0, 190) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		return false
	end
end

function CrownMenu.CheckBox(text, checked, bottomText)
	local buttonText = text
	local menu = CrownMenu.menus[CrownMenu.currentMenu]
	if menu then
		CrownMenu.optionCount = CrownMenu.optionCount + 1

		local isCurrent = menu.currentOption == CrownMenu.optionCount

		CrownMenu.drawButton(text, (checked and "On" or "Off"), false, bottomText)

		if isCurrent then
			if IsDisabledControlJustPressed(0, 201) then
				PlaySoundFrontend(-1, menu.buttonPressedSound.name, menu.buttonPressedSound.set, true)
				return true
			elseif IsDisabledControlJustPressed(0, 189) or IsDisabledControlJustPressed(0, 190) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		return false
	end
end

function CrownMenu.ESP.DrawRect(Location, Size, Color)
    SetDrawOrigin(Location.x, Location.y, Location.z, 0)
	CrownMenu.DrawSprite("", "", 0.0, 0.0, Size.Width, Size.Height, 0.0, Color.r, Color.g, Color.b, Color.a)
	ClearDrawOrigin()
end

function CrownMenu.Display()
	if CrownMenu.IsMenuVisible(CrownMenu.currentMenu) then
		DisableControlAction(0, 187, true)
		DisableControlAction(0, 188, true)
		DisableControlAction(0, 189, true)
		DisableControlAction(0, 190, true)
		DisableControlAction(0, 201, true)
		DisableControlAction(0, 202, true)

		DisableControlAction(0, 24, true)
		DisableControlAction(0, 27, true)

		local menu = CrownMenu.menus[CrownMenu.currentMenu]

		if menu.currentOption > CrownMenu.optionCount then
			CrownMenu.menus[CrownMenu.currentMenu].currentOption = CrownMenu.CurrentOption
		end
		
		if menu.aboutToBeClosed then
			CrownMenu.CloseMenu()
		else
			ClearAllHelpMessages()

			if CrownMenu.menus[CrownMenu.currentMenu].currentOption == nil then
				CrownMenu.menus[CrownMenu.currentMenu].currentOption = CrownMenu.optionCount
			end
			
			CrownMenu.DrawTitle()
			CrownMenu.DrawSubTitle()
			CrownMenu.DrawBottom()

			if IsDisabledControlJustReleased(0, 187) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menu.currentOption < CrownMenu.optionCount then
					menu.currentOption = menu.currentOption + 1
				else
					menu.currentOption = 1
				end
			elseif IsDisabledControlJustReleased(0, 188) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menu.currentOption > 1 then
					menu.currentOption = menu.currentOption - 1
				else
					menu.currentOption = CrownMenu.optionCount
				end
			elseif IsDisabledControlJustReleased(0, 202) then
				if CrownMenu.menus[menu.previousMenu] then
					PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					CrownMenu.SetMenuVisible(CrownMenu.currentMenu, false)
					CrownMenu.SetMenuProperty(menu.previousMenu, 'x', CrownMenu.UI.MenuX)
					CrownMenu.SetMenuProperty(menu.previousMenu, 'y', CrownMenu.UI.MenuY)
					CrownMenu.SetMenuVisible(menu.previousMenu, true)
				else
					CrownMenu.CloseMenu()
				end
			end

			CrownMenu.optionCount = 0
		end
	end
end

function CrownMenu.IsMenuOpened(id)
	return CrownMenu.IsMenuVisible(id)
end

function CrownMenu.OpenMenu(id)
	if id and CrownMenu.menus[id] then
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		CrownMenu.SetMenuVisible(id, true)
	end
end

------------------------------------------------------
--------------------- Menu Code ----------------------
------------------------------------------------------


local globalAttachmentTable = {  
	-- Putting these at the top makes them work properly as they need to be applied to the weapon first before other attachments
	{ "COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_CARBINERIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_ASSAULTRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_MICROSMG_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_SNIPERRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_PISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_PISTOL50_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_APPISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_HEAVYPISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_SMG_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_MARKSMANRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },

	{ "COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_SNSPISTOL_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_MG_COMBATMG_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_BULLPUPRIFLE_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_MG_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER", "Lowrider Finish" },

	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SMG_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTSHOTGUN_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYSHOTGUN_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL50_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_APPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATPDW_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SNSPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTSMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_GUSENBERG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MICROSMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_BULLPUPRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMPACTRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_VINTAGEPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_CARBINERIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ADVANCEDRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MARKSMANRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SPECIALCARBINE_CLIP_02", "Extended Magazine" },

	{ "COMPONENT_SPECIALCARBINE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_COMPACTRIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_COMBATPDW_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_HEAVYSHOTGUN_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_CARBINERIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_SMG_CLIP_03", "Drum Magazine" },

	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_PISTOL_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE", "Explosive Rounds" },

	{ "COMPONENT_SNSPISTOL_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_REVOLVER_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_SMG_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_TRACER", "Tracer Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE", "Explosive Rounds" },

	{ "COMPONENT_AT_PI_FLSH_02", "Flashlight" },
	{ "COMPONENT_AT_AR_FLSH	", "Flashlight" },
	{ "COMPONENT_AT_PI_FLSH", "Flashlight" },
	{ "COMPONENT_AT_AR_FLSH", "Flashlight" },
	{ "COMPONENT_AT_PI_FLSH_03", "Flashlight" },

	{ "COMPONENT_AT_PI_SUPP", "Suppressor" },
	{ "COMPONENT_AT_PI_SUPP_02", "Suppressor" },
	{ "COMPONENT_AT_AR_SUPP", "Suppressor" },
	{ "COMPONENT_AT_AR_SUPP_02", "Suppressor" },
	{ "COMPONENT_AT_SR_SUPP", "Suppressor" },
	{ "COMPONENT_AT_SR_SUPP_03", "Suppressor" },

	{ "COMPONENT_AT_PI_COMP", "Compensator" },
	{ "COMPONENT_AT_PI_COMP_02", "Compensator" },
	{ "COMPONENT_AT_PI_COMP_03", "Compensator" },
	{ "COMPONENT_AT_MRFL_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MRFL_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_BP_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_BP_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SC_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_SC_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_AR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_SB_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_CR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MG_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MG_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_CR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SB_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_AR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_MUZZLE_01", "Muzzle Attachment 1" },
	{ "COMPONENT_AT_MUZZLE_02", "Muzzle Attachment 2" },
	{ "COMPONENT_AT_MUZZLE_03", "Muzzle Attachment 3" },
	{ "COMPONENT_AT_MUZZLE_04", "Muzzle Attachment 4" },
	{ "COMPONENT_AT_MUZZLE_05", "Muzzle Attachment 5" },
	{ "COMPONENT_AT_MUZZLE_06", "Muzzle Attachment 6" },
	{ "COMPONENT_AT_MUZZLE_07", "Muzzle Attachment 7" },

	{ "COMPONENT_AT_AR_AFGRIP", "Grip" },
	{ "COMPONENT_AT_AR_AFGRIP_02", "Grip" },

	{ "COMPONENT_AT_PI_RAIL", "Holographic Sight" },
	{ "COMPONENT_AT_SCOPE_MACRO_MK2", "Holographic Sight" },
	{ "COMPONENT_AT_PI_RAIL_02", "Holographic Sight" },
	{ "COMPONENT_AT_SIGHTS_SMG", "Holographic Sight" },
	{ "COMPONENT_AT_SIGHTS", "Holographic Sight" },

	{ "COMPONENT_AT_SCOPE_SMALL", "Scope Small" },
	{ "COMPONENT_AT_SCOPE_SMALL_02", "Scope Small" },

	{ "COMPONENT_AT_SCOPE_MACRO_02", "Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL_02", "Scope" },
	{ "COMPONENT_AT_SCOPE_MACRO", "Scope" },
	{ "COMPONENT_AT_SCOPE_MEDIUM", "Scope" },
	{ "COMPONENT_AT_SCOPE_LARGE", "Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL", "Scope" },

	{ "COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2", "2x Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL_MK2", "2x Scope" },

	{ "COMPONENT_AT_SCOPE_SMALL_SMG_MK2", "4x Scope" },
	{ "COMPONENT_AT_SCOPE_MEDIUM_MK2", "4x Scope" },

	{ "COMPONENT_AT_SCOPE_MAX", "Advanced Scope" },
	{ "COMPONENT_AT_SCOPE_LARGE", "Scope Large" },
	{ "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2", "Scope Large" },
	{ "COMPONENT_AT_SCOPE_LARGE_MK2", "8x Scope" },

	{ "COMPONENT_AT_SCOPE_NV", "Nightvision Scope" },
	{ "COMPONENT_AT_SCOPE_THERMAL", "Thermal Scope" },

	--{ "COMPONENT_KNUCKLE_VARMOD_PLAYER", "Default Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_LOVE", "Love Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_DOLLAR", "Dollar Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_VAGOS", "Vagos Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_HATE", "Hate Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_DIAMOND", "Diamond Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_PIMP", "Pimp Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_KING", "King Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_BALLAS", "Ballas Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_BASE", "Base Skin" },
	{ "COMPONENT_SWITCHBLADE_VARMOD_VAR1", "Default Skin" },
	{ "COMPONENT_SWITCHBLADE_VARMOD_VAR2", "Variant 2 Skin" },
	--{ "COMPONENT_SWITCHBLADE_VARMOD_BASE", "Base Skin" },

	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_REVOLVER_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_PISTOL_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SMG_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_COMBATMG_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_PISTOL_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SMG_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_PISTOL_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SMG_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_PISTOL_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SMG_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_PISTOL_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SMG_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_PISTOL_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SMG_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_PISTOL_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SMG_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PISTOL_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SMG_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PISTOL_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SMG_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_PISTOL_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SMG_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_PISTOL_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_SMG_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01", "American Camo" },
}

local allWeapons = {
	"WEAPON_UNARMED",
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BAT",
	"WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_HATCHET",
	"WEAPON_MACHETE",
	"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_REVOLVER",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_MICROSMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_GUSENBERG",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_MINIGUN",
	"WEAPON_STINGER",
	"WEAPON_FIREWORK",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_GRENADE",
	"WEAPON_STICKYBOMB",
	"WEAPON_PROXMINE",
	"WEAPON_BZGAS",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_PETROLCAN",
	"WEAPON_FLARE",
	"WEAPON_RAYPISTOL",
	"WEAPON_RAYCARBINE",
	"WEAPON_RAYMINIGUN",
	"WEAPON_STONE_HATCHET",
	"WEAPON_BATTLEAXE",
	"GADGET_PARACHUTE",
}

local PlayerModels = {
	"mp_m_freemode_01",
	"a_m_m_acult_01",
	"a_m_m_afriamer_01",
	"a_m_m_beach_01",
	"a_m_m_beach_02",
	"a_m_m_bevhills_01",
	"a_m_m_bevhills_02",
	"a_m_m_business_01",
	"a_m_m_eastsa_01",
	"a_m_m_eastsa_02",
	"a_m_m_farmer_01",
	"a_m_m_fatlatin_01",
	"a_m_m_genfat_01",
	"a_m_m_genfat_02",
	"a_m_m_golfer_01",
	"a_m_m_hasjew_01",
	"a_m_m_hillbilly_01",
	"a_m_m_hillbilly_02",
	"a_m_m_indian_01",
	"a_m_m_ktown_01",
	"a_m_m_malibu_01",
	"a_m_m_mexcntry_01",
	"a_m_m_mexlabor_01",
	"a_m_m_og_boss_01",
	"a_m_m_paparazzi_01",
	"a_m_m_polynesian_01",
	"a_m_m_prolhost_01",
	"a_m_m_rurmeth_01",
	"a_m_m_salton_01",
	"a_m_m_salton_02",
	"a_m_m_salton_03",
	"a_m_m_salton_04",
	"a_m_m_skater_01",
	"a_m_m_skidrow_01",
	"a_m_m_socenlat_01",
	"a_m_m_soucent_01",
	"a_m_m_soucent_02",
	"a_m_m_soucent_03",
	"a_m_m_soucent_04",
	"a_m_m_stlat_02",
	"a_m_m_tennis_01",
	"a_m_m_tourist_01",
	"a_m_m_tramp_01",
	"a_m_m_trampbeac_01",
	"a_m_m_tranvest_01",
	"a_m_m_tranvest_02",
	"a_m_o_acult_01",
	"a_m_o_acult_02",
	"a_m_o_beach_01",
	"a_m_o_genstreet_01",
	"a_m_o_ktown_01",
	"a_m_o_salton_01",
	"a_m_o_soucent_01",
	"a_m_o_soucent_02",
	"a_m_o_soucent_03",
}

local DoorPropNames = {
	"v_ilev_shrfdoor",
	"v_ilev_ph_gendoor004",
	"prop_faceoffice_door_l",
	"v_ilev_ct_door03",
	"v_ilev_ml_door1",
	"v_ilev_ss_door04",
	"v_ilev_ss_doorext",
	"v_ilev_methdoorscuff",
	"v_ilev_fibl_door01",
	"v_ilev_fibl_door02",
	"v_ilev_fib_doore_l",
	"v_ilev_fib_doore_r",
	"v_ilev_csr_door_l",
	"v_ilev_csr_door_r",
	"v_ilev_fib_door1",
	"apa_prop_ss1_mpint_door_l",
	"apa_prop_ss1_mpint_door_r",
	"v_ilev_roc_door4",
	"v_ilev_roc_door1_l",
	"v_ilev_roc_door1_r",
	"v_ilev_roc_door2",
	"prop_strip_door_01",
	"v_ilev_door_orange",
	"v_ilev_door_orangesolid",
	"v_ilev_247door",
	"v_ilev_247door_r",
	"v_ilev_mldoor2"
}

local spawninsidevehicle = false
local CustomSpawnColour = false
local defaultvehcolor = { 0, 0, 0 }
local VehicleList = {
    Catagories = {
		"Boats",
		"Commercial",
		"Compacts",
		"Coupes",
		"Cycles",
		"Emergency",
		"Helictopers",
		"Industrial",
		"Military",
		"Motorcycles",
		"Muscle",
		"Off-Road",
		"Planes",
		"SUVs",
		"Sedans",
		"Service",
		"Sports",
		"Sports Classic",
		"Super",
		"Trailer",
		"Trains",
		"Utility",
		"Vans"
	},
	Boats = {
		"Dinghy",
		"Dinghy2",
		"Dinghy3",
		"Dingh4",
		"Jetmax",
		"Marquis",
		"Seashark",
		"Seashark2",
		"Seashark3",
		"Speeder",
		"Speeder2",
		"Squalo",
		"Submersible",
		"Submersible2",
		"Suntrap",
		"Toro",
		"Toro2",
		"Tropic",
		"Tropic2",
		"Tug"
	},
    Commercial = {
		"Benson",
		"Biff",
		"Cerberus",
		"Cerberus2",
		"Cerberus3",
        "Hauler",
        "Hauler2",
        "Mule",
        "Mule2",
        "Mule3",
		"Mule4",
        "Packer",
        "Phantom",
		"Phantom2",
        "Phantom3",
        "Pounder",
        "Pounder2",
        "Stockade",
        "Stockade3",
        "Terbyte"
	},
	Compacts = {
		"Blista",
		"Blista2",
		"Blista3",
		"Brioso",
		"Dilettante",
		"Dilettante2",
		"Issi2",
		"Issi3",
		"issi4",
		"Iss5",
		"issi6",
		"Panto",
		"Prarire",
		"Rhapsody"
	},
	Coupes = {
		"CogCabrio",
		"Exemplar",
		"F620",
		"Felon",
		"Felon2",
		"Jackal",
		"Oracle",
		"Oracle2",
		"Sentinel",
		"Sentinel2",
		"Windsor",
		"Windsor2",
		"Zion",
		"Zion2"
	},
	Cycles = {
		"Bmx", 
		"Cruiser", 
		"Fixter", 
		"Scorcher", 
		"Tribike", 
		"Tribike2", 
		"tribike3"
	},
	Emergency = {
		"AMBULANCE",
		"FBI",
		"FBI2",
		"FireTruk",
		"PBus",
		"police",
		"Police2",
		"Police3",
		"Police4",
		"PoliceOld1",
		"PoliceOld2",
		"PoliceT",
		"Policeb",
		"Polmav",
		"Pranger",
		"Predator",
		"Riot",
		"Riot2",
		"Sheriff",
		"Sheriff2"
	},
	Helictopers = {
		"Akula",
		"Annihilator",
		"Buzzard",
		"Buzzard2",
		"Cargobob",
		"Cargobob2",
		"Cargobob3",
		"Cargobob4",
		"Frogger",
		"Frogger2",
		"Havok",
		"Hunter",
		"Maverick",
		"Savage",
		"Seasparrow",
		"Skylift",
		"Supervolito",
		"Supervolito2",
		"Swift",
		"Swift2",
		"Valkyrie",
		"Valkyrie2",
		"Volatus"
	},
	Industrial = {
		"Bulldozer",
		"Cutter",
		"Dump",
		"Flatbed",
		"Guardian",
		"Handler",
		"Mixer",
		"Mixer2",
		"Rubble",
		"Tiptruck",
		"Tiptruck2"
	},
	Military = {
		"APC",
		"Barracks",
		"Barracks2",
		"Barracks3",
		"Barrage",
		"Chernobog",
		"Crusader",
		"Halftrack",
		"Khanjali",
		"Rhino",
		"Scarab",
		"Scarab2",
		"Scarab3",
		"Thruster",
		"Trailersmall2"
	},
	Motorcycles = {
		"Akuma",
		"Avarus",
		"Bagger",
		"Bati2",
		"Bati",
		"BF400",
		"Blazer4",
		"CarbonRS",
		"Chimera",
		"Cliffhanger",
		"Daemon",
		"Daemon2",
		"Defiler",
		"Deathbike",
		"Deathbike2",
		"Deathbike3",
		"Diablous",
		"Diablous2",
		"Double",
		"Enduro",
		"esskey",
		"Faggio2",
		"Faggio3",
		"Faggio",
		"Fcr2",
		"fcr",
		"gargoyle",
		"hakuchou2",
		"hakuchou",
		"hexer",
		"innovation",
		"Lectro",
		"Manchez",
		"Nemesis",
		"Nightblade",
		"Oppressor",
		"Oppressor2",
		"PCJ",
		"Ratbike",
		"Ruffian",
		"Sanchez2",
		"Sanchez",
		"Sanctus",
		"Shotaro",
		"Sovereign",
		"Thrust",
		"Vader",
		"Vindicator",
		"Vortex",
		"Wolfsbane",
		"zombiea",
		"zombieb"
	},
	Muscle = {
		"Blade",
		"Buccaneer",
		"Buccaneer2",
		"Chino",
		"Chino2",
		"clique",
		"Deviant",
		"Dominator",
		"Dominator2",
		"Dominator3",
		"Dominator4",
		"Dominator5",
		"Dominator6",
		"Dukes",
		"Dukes2",
		"Ellie",
		"Faction",
		"faction2",
		"faction3",
		"Gauntlet",
		"Gauntlet2",
		"Hermes",
		"Hotknife",
		"Hustler",
		"Impaler",
		"Impaler2",
		"Impaler3",
		"Impaler4",
		"Imperator",
		"Imperator2",
		"Imperator3",
		"Lurcher",
		"Moonbeam",
		"Moonbeam2",
		"Nightshade",
		"Phoenix",
		"Picador",
		"RatLoader",
		"RatLoader2",
		"Ruiner",
		"Ruiner2",
		"Ruiner3",
		"SabreGT",
		"SabreGT2",
		"Sadler2",
		"Slamvan",
		"Slamvan2",
		"Slamvan3",
		"Slamvan4",
		"Slamvan5",
		"Slamvan6",
		"Stalion",
		"Stalion2",
		"Tampa",
		"Tampa3",
		"Tulip",
		"Vamos,",
		"Vigero",
		"Virgo",
		"Virgo2",
		"Virgo3",
		"Voodoo",
		"Voodoo2",
		"Yosemite"
	},
	Off_Road = {
		"BFinjection",
		"Bifta",
		"Blazer",
		"Blazer2",
		"Blazer3",
		"Blazer5",
		"Bohdi",
		"Brawler",
		"Bruiser",
		"Bruiser2",
		"Bruiser3",
		"Caracara",
		"DLoader",
		"Dune",
		"Dune2",
		"Dune3",
		"Dune4",
		"Dune5",
		"Insurgent",
		"Insurgent2",
		"Insurgent3",
		"Kalahari",
		"Kamacho",
		"LGuard",
		"Marshall",
		"Mesa",
		"Mesa2",
		"Mesa3",
		"Monster",
		"Monster4",
		"Monster5",
		"Nightshark",
		"RancherXL",
		"RancherXL2",
		"Rebel",
		"Rebel2",
		"RCBandito",
		"Riata",
		"Sandking",
		"Sandking2",
		"Technical",
		"Technical2",
		"Technical3",
		"TrophyTruck",
		"TrophyTruck2",
		"Freecrawler",
		"Menacer"
	},
	Planes = {
		"AlphaZ1",
		"Avenger",
		"Avenger2",
		"Besra",
		"Blimp",
		"blimp2",
		"Blimp3",
		"Bombushka",
		"Cargoplane",
		"Cuban800",
		"Dodo",
		"Duster",
		"Howard",
		"Hydra",
		"Jet",
		"Lazer",
		"Luxor",
		"Luxor2",
		"Mammatus",
		"Microlight",
		"Miljet",
		"Mogul",
		"Molotok",
		"Nimbus",
		"Nokota",
		"Pyro",
		"Rogue",
		"Seabreeze",
		"Shamal",
		"Starling",
		"Stunt",
		"Titan",
		"Tula",
		"Velum",
		"Velum2",
		"Vestra",
		"Volatol",
		"Striekforce"
	},
	SUVs = {
		"BJXL",
		"Baller",
		"Baller2",
		"Baller3",
		"Baller4",
		"Baller5",
		"Baller6",
		"Cavalcade",
		"Cavalcade2",
		"Dubsta",
		"Dubsta2",
		"Dubsta3",
		"FQ2",
		"Granger",
		"Gresley",
		"Habanero",
		"Huntley",
		"Landstalker",
		"patriot",
		"Patriot2",
		"Radi",
		"Rocoto",
		"Seminole",
		"Serrano",
		"Toros",
		"XLS",
		"XLS2"
	},
	Sedans = {
		"Asea",
		"Asea2",
		"Asterope",
		"Cog55",
		"Cogg552",
		"Cognoscenti",
		"Cognoscenti2",
		"emperor",
		"emperor2",
		"emperor3",
		"Fugitive",
		"Glendale",
		"ingot",
		"intruder",
		"limo2",
		"premier",
		"primo",
		"primo2",
		"regina",
		"romero",
		"stafford",
		"Stanier",
		"stratum",
		"stretch",
		"surge",
		"tailgater",
		"warrener",
		"Washington"
	},
	Service = {
		"Airbus",
		"Brickade",
		"Bus",
		"Coach",
		"Rallytruck",
		"Rentalbus",
		"taxi",
		"Tourbus",
		"Trash",
		"Trash2",
		"WastIndr",
		"PBus2"
	},
	Sports = {
		"Alpha",
		"Banshee",
		"Banshee2",
		"BestiaGTS",
		"Buffalo",
		"Buffalo2",
		"Buffalo3",
		"Carbonizzare",
		"Comet2",
		"Comet3",
		"Comet4",
		"Comet5",
		"Coquette",
		"Deveste",
		"Elegy2",
		"Feltzer2",
		"Feltzer3",
		"FlashGT",
		"Furoregt",
		"Fusilade",
		"Futo",
		"GB200",
		"Hotring",
		"Infernus2",
		"Italigto",
		"Jester",
		"Jester2",
		"Khamelion",
		"Kurama",
		"Kurama2",
		"Lynx",
		"MAssacro",
		"MAssacro2",
		"neon",
		"Ninef",
		"ninfe2",
		"omnis",
		"Pariah",
		"Penumbra",
		"Raiden",
		"RapidGT",
		"RapidGT2",
		"Raptor",
		"Revolter",
		"Ruston",
		"Schafter2",
		"Schafter3",
		"Schafter4",
		"Schafter5",
		"Schafter6",
		"Schlagen",
		"Schwarzer",
		"Sentinel3",
		"Seven70",
		"Specter",
		"Specter2",
		"Streiter",
		"Sultan",
		"Surano",
		"Tampa2",
		"Tropos",
		"Verlierer2",
		"ZR380"
	},
	Sports_Classic = {
		"Ardent",
		"BType",
		"BType2",
		"BType3",
		"Casco",
		"Cheetah2",
		"Cheburek",
		"Coquette2",
		"Coquette3",
		"Deluxo",
		"Fagaloa",
		"Gt500",
		"JB700",
		"Jester3",
		"MAmba",
		"Manana",
		"Michelli",
		"Monroe",
		"Peyote",
		"Pigalle",
		"RapidGT3",
		"Retinue",
		"Savestra",
		"Stinger",
		"Stingergt",
		"Stromberg",
		"Swinger",
		"Torero",
		"Tornado",
		"Tornado2",
		"Tornado3",
		"Tornado4",
		"Tornado5",
		"Tornado6",
		"Viseris",
		"Z190",
		"ZType"
	},
	Super = {
		"Adder",
		"Autarch",
		"Bullet",
		"Cheetah",
		"Cyclone",
		"Elegy",
		"EntityXF",
		"Entity2",
		"FMJ",
		"GP1",
		"Infernus",
		"LE7B",
		"Nero",
		"Nero2",
		"Osiris",
		"Penetrator",
		"PFister811",
		"Prototipo",
		"Reaper",
		"SC1",
		"Scramjet",
		"Sheava",
		"SultanRS",
		"Superd",
		"T20",
		"Taipan",
		"Tempesta",
		"Tezeract",
		"Turismo2",
		"Turismor",
		"Tyrant",
		"Tyrus",
		"Vacca",
		"Vagner",
		"Vigilante",
		"Visione",
		"Voltic",
		"Voltic2",
		"Zentorno",
		"Italigtb",
		"Italigtb2",
		"XA21"
	},
	Trailer = {
		"ArmyTanker",
		"ArmyTrailer",
		"ArmyTrailer2",
		"BaleTrailer",
		"BoatTrailer",
		"CableCar",
		"DockTrailer",
		"Graintrailer",
		"Proptrailer",
		"Raketailer",
		"TR2",
		"TR3",
		"TR4",
		"TRFlat",
		"TVTrailer",
		"Tanker",
		"Tanker2",
		"Trailerlogs",
		"Trailersmall",
		"Trailers",
		"Trailers2",
		"Trailers3"
	},
	Trains = {
		"Freight",
		"Freightcar",
		"Freightcont1",
		"Freightcont2",
		"Freightgrain",
		"Freighttrailer",
		"TankerCar"
	},
	Utility = {
		"Airtug",
		"Caddy",
		"Caddy2",
		"Caddy3",
		"Docktug",
		"Forklift",
		"Mower",
		"Ripley",
		"Sadler",
		"Scrap",
		"TowTruck",
		"Towtruck2",
		"Tractor",
		"Tractor2",
		"Tractor3",
		"TrailerLArge2",
		"Utilitruck",
		"Utilitruck3",
		"Utilitruck2"
	},
	Vans = {
		"Bison",
		"Bison2",
		"Bison3",
		"BobcatXL",
		"Boxville",
		"Boxville2",
		"Boxville3",
		"Boxville4",
		"Boxville5",
		"Burrito",
		"Burrito2",
		"Burrito3",
		"Burrito4",
		"Burrito5",
		"Camper",
		"GBurrito",
		"GBurrito2",
		"Journey",
		"Minivan",
		"Minivan2",
		"Paradise",
		"pony",
		"Pony2",
		"Rumpo",
		"Rumpo2",
		"Rumpo3",
		"Speedo",
		"Speedo2",
		"Speedo4",
		"Surfer",
		"Surfer2",
		"Taco",
		"Youga",
		"youga2"
	}
}

-------- Menu Config --------

local killmenu = false

local CrownVariables = {
	SelfOptions = {
		Wardrobe = {
			Head = 0,
			Mask = 0,
		},
		AlienColorSpam = false,
		invisiblitity = false,
		godmode = false,
		AutoHealthRefil = false,
		AntiHeadshot = false,
		MoonWalk = false,
		InfiniteCombatRoll = false,
		superjump = false,
		superrun = false,
		infstamina = false,
		FreezeWantedLevel = false,
		noragdoll = false,
		disableobjectcollisions = false,
		disablepedcollisions = false,
		disablevehiclecollisions = false,
		forceradar = false,
		playercoords = false
	},
	VehicleOptions = {
		AutoPilotOptions = {
			DrivingStyles = {"Avoid Traffic Extremely", "Sometimes Overtake Traffic", "Rushed", "Normal", "Ignore Lights", "Avoid Traffic"},
			CruiseSpeed = 50.0,
			DrivingStyle = 6,
			SelCruiseSpeedIndex = 1,
			CurCruiseSpeedIndex = 1,
		},
		SelDoorPV = 1,
		CurDoorPV = 1,
		SelCloseDoorPV = 1,
		CurCloseDoorPV = 1,
		AutoClean = false,
		vehgodmode = false,
		speedboost = false,
		Waterproof = false,
		InstantBreaks = false,
		Crownplate = false,
		rainbowcar = false,
		speedometer = false,
		EasyHandling = false,
		DriveOnWater = false,
		AlwaysWheelie = false,
		PersonalVehicle = false,
		forcelauncontrol = false,
		activetorquemulr = false,
		activeenignemulr = false,
		PersonalVehicleESP = false,
		PersonalVehicleCam = false,
		PersonalVehicleMarker = false,
		vehenginemultiplier = { "x2", "x4", "x8", "x16", "x32", "x64", "x128", "x256", "x512", "x1024" },
		selactivetorqueIndex = 1,
		curractivetorqueIndex = 1,
		selactiveenignemulrIndex = 1,
		curractiveenignemulrIndex = 1
	},
	TeleportOptions = {
		smoothteleport = false,
		teleportlocations = {
			{"Mission Row PD", 440.22, -982.21, 30.69},
			{"Sandy Shores PD", 1857.48, 3677.88, 33.73},
			{"Paleto Bay PD", -434.34, 6020.89, 31.50}
		}
	},
	WeaponOptions = {
		BulletOptions = {
			Enabled = false,
			Bullets = { "Revolver", "Heavy Sniper", "RPG", "Firework Launcher", "Ray Pistol" },
			CurrentBullet = 1,
			WeaponBulletName = "WEAPON_REVOLVER",
		},
		BulletToUse = "WEAPON_HEAVYSNIPER",
		ExplosiveAmmo = false,
		TriggerBot = false,
		RapidFire = false,
		Crosshair = false, 
		DelGun = false,
		AimBot = {
			Targeting = {
				Target = nil,
				LowestResult = { x = 1.0, y = 1.0}
			},
			ComboBox = {
				SelIndex = 1,
				CurIndex = 1,
				IndexItems = { "Head", "Chest", "Pelvis" },
			},
			MultiTarget = 1,
			Target = nil,
			Enabled = false,
			Bone = "SKEL_HEAD",
			HitChance = 100,
			ThroughWalls = false,
			DrawFOV = true,
			ShowTarget = false,
			FOV = 0.50,
			OnlyPlayers = false,
			IgnoreFriends = true,
			Distance = 1000.0,
			InvisibilityCheck = true,
		},
		NoRecoil = false,
		Tracers = false,
		RageBot = false,
		Spinbot = false,
		InfAmmo = false,
		NoReload = false,
		OneShot = false
	},
	OnlinePlayer = {
		ExplosionType = 1,
		TrackingPlayer = nil,
		attatchedplayer = nil,
		attachtoplayer = false,
		playertofreeze = nil,
		freezeplayer = false,
		messageloopplayer = nil,
		messagetosend = ".",
		messagelooping = false,
		CargodPlayer = nil,
		cargoplaneloop = false,
		ExplosionLoop = false,
		ExplodingPlayer = nil,
		FlingingPlayer = false,
		FireWorkPlayer = nil,
		FireWorkLoop = false,
		FireWork2Player = nil,
		FireWork2Loop = false,
		SmokeLoop = false,
		SmokePlayer = nil,
		JesusLightLoop = false,
		JesusPlayer = nil,
		AlienLightLoop = false,
		ExplosionParticlePlayer = nil,
		AlienPlayer = nil,
		FlarePlayer = nil,
		FlareLoop = false,
		lighttroll = false,
		lighttrollingplayer = nil
	},
	AllOnlinePlayers = {
	    DPEmotes = {"dancesilly", "twerk", "headbutted", "dancehorse", "slapped", "bartender"},
		CurrentEmote = 1,
		IncludeSelf = true,
		ParicleEffects = {
			HugeExplosionLoop = false,
			ClownLoop = false,
			BloodLoop = false,
			FireworksLoop = false,
		},
		busingserverloop = false,
		cargoplaneserverloop = false,
		freezeserver = false,
		tugboatrainoverplayers = false,
		ExplodisionLoop = false,
		PTFXSpam = false,
	},
	ScriptOptions = {
		GGACBypass = false,
		SSBBypass = false,
		script_crouch = false,
		vault_doors = false,
		blocktakehostage = false,
		BlockBlackScreen = false,
		blockbeingcarried = false,
		BlockPeacetime = false
	},
	MiscOptions = {
		GlifeHack = false,
		UnlockAllVehicles = false,
		SpamServerChat = false,
		FlyingCars = false,
		ESPLines = false,
		ESPBones = false,
		ESPName = false,
		ESPBlips = false,
		ESPBlipDB = {},
		ESPBox = true,
		ESPBoxStyle = 1,
		ESPDistance = 1000.0,
	},
	MenuOptions = {
		DiscordRichPresence = false,
		Watermark = false
	},
	Keybinds = {
		OpenKey = 344,
		NoClipKey = 56,
		DriftMode = 999,
		RefilHealthKey = 999,
		RefilArmourKey = 999,
		AimBotToggleKey = 999,
	},
	ServerOptions = {
		ESXServer = false,
		VRPServer = false
	}
}

local rgbhud = false

local OnlinePlayerOptions = false

local mocks = 0

local selectedPlayer = 0
local selectedWeapon = nil

local FriendsList = {}
local TazeLoop = false
local TazeLoopingPlayer = nil

local policeheadlights = false

local SafeMode = false

local AntiCheats = {
	ATG = false,
	WaveSheild = false,
	AntiCheese = false,
	ChocoHax = false,
	BadgerAC = false,
	TigoAC = false,
	ESXAC = false,
	VAC = false,
}

local selDoorIndex = 1
local curDoorIndex = 1

local selClosedDoorIndex = 1
local curClosedDoorIndex = 1

local selClosedBreakIndex = 1
local curClosedBreakIndex = 1

local spawnedobjectslist = {}

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


local function GetResources()
    local resources = {}
    for i = 1, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

AddEventHandler('cmg3_animations:syncTarget', function(target)
	if CrownVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("cmg3_animations:cl_stop")
	end
end)
AddEventHandler('cmg3_animations:Me', function(target)
	if CrownVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("cmg3_animations:cl_stop")
	end
end)

AddEventHandler('CarryPeople:syncTarget', function(target)
	if CrownVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("CarryPeople:cl_stop")
	end
end)
AddEventHandler('CarryPeople:Me', function(target)
	if CrownVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("CarryPeople:cl_stop")
	end
end)

RegisterNetEvent('screenshot_basic:requestScreenshot')
AddEventHandler('screenshot_basic:requestScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('EasyAdmin:CaptureScreenshot')
AddEventHandler('EasyAdmin:CaptureScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('requestScreenshot')
AddEventHandler('requestScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('__cfx_nui:screenshot_created')
AddEventHandler('__cfx_nui:screenshot_created', function()
	CancelEvent()
end)

RegisterNetEvent('screenshot-basic')
AddEventHandler('screenshot-basic', function()
	CancelEvent()
end)

RegisterNetEvent('requestScreenshotUpload')
AddEventHandler('requestScreenshotUpload', function()
	CancelEvent()
end)

AddEventHandler('EasyAdmin:FreezePlayer', function(toggle)
	TriggerEvent("EasyAdmin:FreezePlayer", false)
end)

RegisterNetEvent('EasyAdmin:CaptureScreenshot')
AddEventHandler('EasyAdmin:CaptureScreenshot', function()
	PushNotification("You're screen is being screen shotted", 1000)
	TriggerServerEvent("EasyAdmin:TookScreenshot", "ERROR")
	CancelEvent()
end)

local year, month, day, hour, minute, second = GetLocalTime()

local InjectionTime = string.format("%02d/%02d/%04d", day, month, year) .. " " .. string.format("%02d:%02d", hour, minute)

Ham.printStr("Crown Menu", "\n^1Crown Menu Loaded!\nWelcome " .. Ham.getName() .. "\n^3F11 to open the menu\n^5Resource " .. GetCurrentResourceName() .."\n^6Version " .. CrownMenu.Version)
Ham.printStr("Crown Menu", "\n^1Injected at " .. InjectionTime .. "\n")

Resources = GetResources()

-- Main Thread
	
Citizen.CreateThread(function()
	
	for i = 1, #Resources do
		if Resources[i] == "Badger-AntiCheat" then
			AntiCheats.BadgerAC = true
		elseif Resources[i] == "BadgerAntiCheat" then
			AntiCheats.BadgerAC = true
		elseif Resources[i] == "BadgerAntiCheat" then
			AntiCheats.BadgerAC = true
		elseif Resources[i] == "Tigo-Anticheat" then
			AntiCheats.TigoAC = true
		elseif Resources[i] == "TigoAnticheat" then
			AntiCheats.TigoAC = true
		elseif string.find(Resources[i], "Tigo") then
			AntiCheats.TigoAC = true
		elseif string.find(Resources[i], "VAC") then
			AntiCheats.VAC = true
		elseif string.find(Resources[i], "Badger") and string.find(Resources[i], "Anti") then
			AntiCheats.BadgerAC = true
		elseif string.find(Resources[i], "cheese") then
			AntiCheats.AntiCheese = true
		elseif string.find(Resources[i], "Choco") then
		    AntiCheats.ChocoHax = true
		elseif string.find(Resources[i], "esx") then
			CrownVariables.ServerOptions.ESXServer = true
		elseif string.find(Resources[i], "vrp") then
			CrownVariables.ServerOptions.VRPServer = true
		end
	end
	
	CrownMenu.CreateMenu('main', 'Crown Menu', 'Main Menu')
	CrownMenu.CreateSubMenu('onlineplayerlist', 'main', 'Online Players')

	CrownMenu.CreateSubMenu('allplayeroptions', 'onlineplayerlist', 'All Player Options')
	CrownMenu.CreateSubMenu('attachpropsallplayeroptions', 'allplayeroptions', 'All Player Options > Prop Options')
	CrownMenu.CreateSubMenu('particleeffectsallplayeroptions', 'allplayeroptions', 'All Player Options > Particle Effects')
	CrownMenu.CreateSubMenu('triggereventsallplayeroptions', 'allplayeroptions', 'All Player Options > Trigger Events')

	CrownMenu.CreateSubMenu('selectedonlineplayr', 'onlineplayerlist', 'Selected Player Options')
	CrownMenu.CreateSubMenu('trollonlineplayr', 'selectedonlineplayr', 'Troll Options')
	CrownMenu.CreateSubMenu('attachpropstoplayer', 'selectedonlineplayr', 'Attach Options')
	CrownMenu.CreateSubMenu('pedspawningonplayer', 'selectedonlineplayr', 'Ped Spawning')
	CrownMenu.CreateSubMenu('particleeffectsonplayer', 'selectedonlineplayr', 'Pariticle Options')
	CrownMenu.CreateSubMenu('selectedPlayervehicleopts', 'selectedonlineplayr', 'Selected Player Vehicle Options')
	CrownMenu.CreateSubMenu('selectedplayerTriggerEvents', 'selectedonlineplayr', 'Trigger Events On Player')

	CrownMenu.CreateSubMenu('selfoptions', 'main', 'Self Options')
	CrownMenu.CreateSubMenu('selfmodellist', 'selfoptions', 'Self Options > Change Ped')
	CrownMenu.CreateSubMenu('visionoptions', 'selfoptions', 'Self Options > Vision Options')
	CrownMenu.CreateSubMenu('selfwardrobe', 'selfoptions', 'Self Options > Wardrobe')
	CrownMenu.CreateSubMenu('premadeoutfits', 'selfoptions', 'Wardrobe > Pre Made Outifts')
	CrownMenu.CreateSubMenu('superpowers', 'selfoptions', 'Self Options > Super Powers')
	CrownMenu.CreateSubMenu('collisionoptions', 'selfoptions', 'Self Options > Collisions')
	
	CrownMenu.CreateSubMenu('vehicleoptions', 'main', 'Vehicle Options')
	CrownMenu.CreateSubMenu('spawnvehicleoptions', 'vehicleoptions', 'Vehicle Spawner')

	CrownMenu.CreateSubMenu('funnyvehicles', 'spawnvehicleoptions', 'Funny Vehicles')

	CrownMenu.CreateSubMenu('spawnvehiclesettings', 'spawnvehicleoptions', 'Vehicle Spawner  Settings')
	CrownMenu.CreateSubMenu("selectectedcatagoryvehicleoptions", 'spawnvehicleoptions', 'Options')
	CrownMenu.CreateSubMenu('doorvehicleoptions', 'vehicleoptions', 'Vehicle Options > Doors')
	CrownMenu.CreateSubMenu('vehicletricks', 'vehicleoptions', 'Vehicle Options > Tricks')
	CrownMenu.CreateSubMenu('vehicleautopilot', 'vehicleoptions', 'Vehicle Auto Pilot')

	CrownMenu.CreateSubMenu('personalvehicle', 'vehicleoptions', 'Personal Vehicle')
	CrownMenu.CreateSubMenu('personalvehicleautopilot', 'personalvehicle', 'Personal Vehicle')

	CrownMenu.CreateSubMenu('Crowncustoms', 'vehicleoptions', 'Crown Customs')

	CrownMenu.CreateSubMenu('teleportoptions', 'main', 'Teleport Options')
	
	CrownMenu.CreateSubMenu('weaponoptions', 'main', 'Weapon Options')
	CrownMenu.CreateSubMenu('weaponaimbotsettings', 'weaponoptions', 'Aimbot')
	CrownMenu.CreateSubMenu('bulletoptions', 'weaponoptions', 'Bullet Options')
	CrownMenu.CreateSubMenu('weaponslist', 'weaponoptions', 'Selected Weapon Options')
	CrownMenu.CreateSubMenu('selectedweaponoptions', 'weaponslist', 'Weapon Name Here')

	CrownMenu.CreateSubMenu('worldoptions', 'main', 'World Options')
	CrownMenu.CreateSubMenu('weatheroptions', 'worldoptions', 'Weather Options')
	CrownMenu.CreateSubMenu('timeoptions', 'worldoptions', 'Time Options')

	CrownMenu.CreateSubMenu('miscellaneousoptions', 'main', 'Misc Options')
	CrownMenu.CreateSubMenu('hudoptions', 'miscellaneousoptions', 'Misc Options > Hud Colors')
	CrownMenu.CreateSubMenu('serveroptions', 'miscellaneousoptions', 'Server Options')
	CrownMenu.CreateSubMenu('anticheatdetections', 'miscellaneousoptions', 'Anticheat Options')
	CrownMenu.CreateSubMenu('espoptions', 'miscellaneousoptions', 'ESP Options')
	CrownMenu.CreateSubMenu('triggerevents', 'miscellaneousoptions', "Trigger Events")
	CrownMenu.CreateSubMenu('scriptoptions', 'miscellaneousoptions', "Script Options")
	
	CrownMenu.CreateSubMenu('objectslist', 'main', 'Objects List')
	CrownMenu.CreateSubMenu('selectedobjectsettings', 'objectslist', 'Object Settings')
	CrownMenu.CreateSubMenu('selectedobjectattachmentsettings', 'selectedobjectsettings', 'Object Attachment Settings')
	CrownMenu.CreateSubMenu('clearareaobjects', 'objectslist', 'Clear Area')
	
	CrownMenu.CreateSubMenu('menusettings', 'main', "Settings")
	CrownMenu.CreateSubMenu('menuthemes', 'menusettings', "Themes")
	CrownMenu.CreateSubMenu('keybinds', 'menusettings', "Keybinds")
	
	local mOpenKey = CrownMenu.KeyboardEntry("Enter Menu Open Key", 3)

	if tonumber(mOpenKey) == nil then
		CrownVariables.Keybinds.OpenKey = 344
	else
        CrownVariables.Keybinds.OpenKey = mOpenKey
	end

	PushNotification("Successfully Loaded!", 1000)
	PushNotification("Open Key Set to " .. CrownVariables.Keybinds.OpenKey, 1000)

	FindACResource()
	FindDynamicTriggers()
	
	while true do

		if CrownVariables.MenuOptions.DiscordRichPresence then
			SetDiscordAppId(779447457884405782)
			SetDiscordRichPresenceAsset('Crown')
			SetDiscordRichPresenceAssetText("Crown Menu On top")
			SetDiscordRichPresenceAssetSmall('discord')
			SetDiscordRichPresenceAssetSmallText('discord.gg/DXQvMEzKSd')
		end

		EnableControlAction(0, 344, true)

		if killmenu then
            break
		end

		curMenu = CrownMenu.CurrentMenu()

		CrownMenu.SetMenuProperty(curMenu, 'maxOptionCount', CrownMenu.UI.MaximumOptionCount)

		if curMenu ~= nil then
			if string.find(curMenu, "playr") or string.find(curMenu, "onplayer") or string.find(curMenu, "selectedPlayer") or  string.find(curMenu, "selectedplayer") or string.find(curMenu, "toplayer") then
				OnlinePlayerOptions = true
			else
				OnlinePlayerOptions = false
			end
	    end

		if CrownMenu.IsMenuOpened('main') then

			if CrownMenu.MenuButton('Online Player Options', 'onlineplayerlist', "Individual Players / All Players") then
			elseif CrownMenu.MenuButton('Self Options', 'selfoptions', "Godmode, Super Powers") then
			elseif CrownMenu.MenuButton('Vehicle Options', 'vehicleoptions', "Funny Vehicles, Rainbow Car") then
			elseif CrownMenu.MenuButton('Teleport Options', 'teleportoptions', "Teleport to a Location or Waypoint") then
			elseif CrownMenu.MenuButton('Weapon Options', 'weaponoptions', "Infinite Ammo, Explosive ammo") then
			elseif CrownMenu.MenuButton('World Options', 'worldoptions', "Set World Options") then
			elseif CrownMenu.MenuButton('Object Options', 'objectslist', "Spawned Objects") then
			elseif CrownMenu.MenuButton('Misc Options', 'miscellaneousoptions', "Anticheat Options, Script Options") then
			elseif CrownMenu.MenuButton('Settings', 'menusettings', "Change Menu Settings") then
			elseif CrownMenu.Button('Kill Menu', "", false, "You need to re-execute the menu if you Kill the Menu") then
				killmenu = true
				break;
				CrownMenu.CloseMenu()
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('objectslist') then
			
			if CrownMenu.MenuButton("Clear Objects", "clearareaobjects") then
		    elseif CrownMenu.CheckBox("Object Spooner", fcam) then
				fcam = not fcam
				if fcam then
					FreeCameraMode = "Object Spooner"
					StartFreeCam(GetGameplayCamFov())
				else
					FreeCameraMode = false
					EndFreeCam()
				end
			elseif CrownMenu.Button("Create Object") then
				local model = CrownMenu.KeyboardEntry("Enter Model Name", 200)
				coords = GetEntityCoords(PlayerPedId())
				local obj = CreateObject(GetHashKey(model), coords, 1, 1, 1)
				SetEntityHeading(obj, GetEntityHeading(PlayerPedId()))
				SetEntityAsMissionEntity(obj, true, true)
			    cord = GetEntityCoords(obj)
				local Information = {ID = obj, AttachedEntity = nil, AttachmentOffset = {X = 	0, Y = 0, Z = 0, XAxis = 0, YAxis = 0, ZAxis = 0}}
				table.insert(CrownMenu.Objectlist, #CrownMenu.Objectlist + 1, Information)
				if cam and FreeCameraMode == "Object Spooner" then		
					local coords = GetCoordCamLooking()
					local retval, zz, normal = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 100)
                    SetEntityCoords(obj, coords.x, coords.y, zz)
				end
			end
			for i = 1, #CrownMenu.Objectlist do
				if CrownMenu.MenuButton(CrownMenu.Objectlist[i].ID, "selectedobjectsettings") then
					CrownMenu.ObjectOptions.currentObject = CrownMenu.Objectlist[i]
				end
				if not DoesEntityExist(CrownMenu.Objectlist[i].ID) then
					table.remove(CrownMenu.Objectlist, i)
                    break
				end
			end
			
			if IsDisabledControlJustPressed(0, 178) then
				ting = CrownMenu.menus[CrownMenu.currentMenu].currentOption	- 3
				if CrownMenu.menus[CrownMenu.currentMenu].currentOption > 3 then
					CrownMenu.menus[CrownMenu.currentMenu].currentOption = CrownMenu.menus[CrownMenu.currentMenu].currentOption - 1
					DeleteEntity(CrownMenu.Objectlist[ting].ID)
				end
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selectedobjectsettings') then

			if CrownMenu.MenuButton("Attachment Options", "selectedobjectattachmentsettings") then
	        elseif CrownMenu.ValueChanger("Sensitivity", CrownMenu.ObjectOptions.Sensitivity, 0.01, {0.011, 10}, function(value)
				CrownMenu.ObjectOptions.Sensitivity = value
			end, true) then
			elseif CrownMenu.ValueChanger("X Coordinate", tonumber(string.format("%.2f", GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID).x)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID, value, y, z)
			end) then
			elseif CrownMenu.ValueChanger("Y Coordinate", tonumber(string.format("%.2f", GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID).y)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID, x, value, z)
			end) then
			elseif CrownMenu.ValueChanger("Z Coordinate", tonumber(string.format("%.2f", GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID).z)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID, x, y, value)
			end) then
			elseif CrownMenu.ValueChanger("X Rotation", tonumber(string.format("%.2f", GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID).x)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID, value, y, z)
			end) then
			elseif CrownMenu.ValueChanger("Y Rotation", tonumber(string.format("%.2f", GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID).y)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID, x, value, z)
			end) then
			elseif CrownMenu.ValueChanger("Z Rotation", tonumber(string.format("%.2f", GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID).z)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
				x, y, z = table.unpack(GetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID))
				SetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID, x, y, value)
			end) then
			elseif CrownMenu.Button("Set Entity Upright") then
				SetEntityRotation(CrownMenu.ObjectOptions.currentObject.ID, 0.0, 0.0, GetEntityHeading(CrownMenu.ObjectOptions.currentObject.ID))
			elseif CrownMenu.Button("Teleport Entity To Self") then
				SetEntityCoords(CrownMenu.ObjectOptions.currentObject.ID, GetEntityCoords(PlayerPedId()))
			elseif CrownMenu.CheckBox("Freeze / Unfreeze Entity", IsEntityStatic(CrownMenu.ObjectOptions.currentObject.ID)) then
				if IsEntityStatic(CrownMenu.ObjectOptions.currentObject.ID) then
					FreezeEntityPosition(CrownMenu.ObjectOptions.currentObject.ID, false)
				else
					FreezeEntityPosition(CrownMenu.ObjectOptions.currentObject.ID, true)
				end
			elseif CrownMenu.CheckBox("Collision", EntityCollision) then
				EntityCollision = not EntityCollision
				SetEntityCollision(CrownMenu.ObjectOptions.currentObject.ID, EntityCollision, true)
			elseif CrownMenu.Button("Delete Entity") then
				DeleteEntity(CrownMenu.ObjectOptions.currentObject.ID)
				CrownMenu.OpenMenu("objectslist")
			end
			
			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('selectedobjectattachmentsettings') then

			if CrownMenu.Button("Detach Entity") then
				CrownMenu.ObjectOptions.currentObject.AttachedEntity = nil
				DetachEntity(CrownMenu.ObjectOptions.currentObject.ID)
			elseif CrownMenu.Button("Attach To Self") then
				CrownMenu.ObjectOptions.currentObject.AttachedEntity = PlayerPedId()
				AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), false, true, true)
			elseif CrownMenu.Button("Attach To Current Vehicle") then
				CrownMenu.ObjectOptions.currentObject.AttachedEntity = GetVehiclePedIsIn(PlayerPedId())
				AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), false, true, true)
			end

			if CrownMenu.ObjectOptions.currentObject.AttachedEntity then
				if CrownMenu.ValueChanger("Sensitivity", CrownMenu.ObjectOptions.Sensitivity, 0.01, {0.02, 10}, function(value)
					CrownMenu.ObjectOptions.Sensitivity = value
				end, true) then
				elseif CrownMenu.ValueChanger("X Coordinate", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				elseif CrownMenu.ValueChanger("Y Coordinate", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				elseif CrownMenu.ValueChanger("Z Coordinate", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				elseif CrownMenu.ValueChanger("X Rotation", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				elseif CrownMenu.ValueChanger("Y Rotation", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				elseif CrownMenu.ValueChanger("Z Rotation", tonumber(string.format("%.2f", CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis)), CrownMenu.ObjectOptions.Sensitivity, {-math.huge, math.huge}, function(value)
					CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis = value
					AttachEntityToEntity(CrownMenu.ObjectOptions.currentObject.ID, CrownMenu.ObjectOptions.currentObject.AttachedEntity, 0, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.X, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Y, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.Z, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.XAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.YAxis, CrownMenu.ObjectOptions.currentObject.AttachmentOffset.ZAxis, true, true, false, IsEntityAPed(CrownMenu.ObjectOptions.currentObject.AttachedEntity), true, true)
				end) then
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('clearareaobjects') then
			
			if CrownMenu.Button("Clear Area Of Objects") then
				for object in EnumerateObjects() do
					NetworkRequestControlOfEntity(object)
					DeleteEntity(object)
				end
			elseif CrownMenu.Button("Clear Area Of Vehicles") then
				for vehicle in EnumerateVehicles() do
					NetworkRequestControlOfEntity(vehicle)
					DeleteEntity(vehicle)
				end
			elseif CrownMenu.Button("Clear Area Of Peds") then
				for ped in EnumeratePeds() do
					if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
						NetworkRequestControlOfEntity(ped)
						DeleteEntity(ped)
					end
				end
			elseif CrownMenu.Button("Clear Object List") then
				CrownMenu.Objectlist = {}
			end

			CrownMenu.Display()
	
		elseif CrownMenu.IsMenuOpened('menuthemes') then
			if CrownMenu.CheckBox("RGB Rainbow", CrownMenu.UI.RGB) then
				CrownMenu.UI.RGB = not CrownMenu.UI.RGB
			elseif CrownMenu.ValueChanger("R", CrownMenu.rgb.r, 1, {0, 255}, function(val)
				CrownMenu.rgb.r = val
			end, true) then
			elseif CrownMenu.ValueChanger("G", CrownMenu.rgb.g, 1, {0, 255}, function(val)
				CrownMenu.rgb.g = val
			end, true) then
			elseif CrownMenu.ValueChanger("B", CrownMenu.rgb.b, 1, {0, 255}, function(val)
				CrownMenu.rgb.b = val
			end, true) then
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('keybinds') then

			if CrownMenu.Button("Change Open Key", tostring(CrownVariables.Keybinds.OpenKey), false, "https://docs.fivem.net/docs/game-references/controls/") then

				local OpenKey = CrownMenu.KeyboardEntry("Enter Menu Open Key", 3)
			
				if tonumber(OpenKey) == nil then
					CrownVariables.Keybinds.OpenKey = 344
				else
					CrownVariables.Keybinds.OpenKey = OpenKey
				end

				PushNotification("Press ~o~Alt + B~w~ to reset the open key", 600)

			elseif CrownMenu.Button("Change Noclip Key", tostring(CrownVariables.Keybinds.NoClipKey), false, "https://docs.fivem.net/docs/game-references/controls/") then
				local NoClipKey = CrownMenu.KeyboardEntry("Enter Noclip Key", 3)
			
				if tonumber(NoClipKey) == nil then
					CrownVariables.Keybinds.NoClipKey = 56
				else
					CrownVariables.Keybinds.NoClipKey = NoClipKey
				end

			elseif CrownMenu.Button("Change Health Refill Key", tostring(CrownVariables.Keybinds.RefilHealthKey), false, "https://docs.fivem.net/docs/game-references/controls/") then
				local HealthRefilKey = CrownMenu.KeyboardEntry("Enter Health Refill Key", 3)
			
				if tonumber(HealthRefilKey) == nil then
					CrownVariables.Keybinds.RefilHealthKey = 999
				else
					CrownVariables.Keybinds.RefilHealthKey = HealthRefilKey
				end

			elseif CrownMenu.Button("Change Drift Key", tostring(CrownVariables.Keybinds.DriftMode), false, "https://docs.fivem.net/docs/game-references/controls/") then
				local DriftKey = CrownMenu.KeyboardEntry("Enter Drift Key", 3)
			
				if tonumber(DriftKey) == nil then
					CrownVariables.Keybinds.DriftMode = 999
				else
					CrownVariables.Keybinds.DriftMode = DriftKey
				end
			elseif CrownMenu.Button("Change Armour Refill Key", tostring(CrownVariables.Keybinds.RefilHealthKey), false, "https://docs.fivem.net/docs/game-references/controls/") then
				local RefilArmourKey = CrownMenu.KeyboardEntry("Enter Health Refill Key", 3)
			
				if tonumber(RefilArmourKey) == nil then
					CrownVariables.Keybinds.RefilArmourKey = 999
				else
					CrownVariables.Keybinds.RefilArmourKey = RefilArmourKey
				end
			elseif CrownMenu.Button("Change Aimbot Toggle Key", tostring(CrownVariables.Keybinds.AimBotToggleKey), false, "https://docs.fivem.net/docs/game-references/controls/") then
				local AimbotToggleKey = CrownMenu.KeyboardEntry("Enter Aimbot Toggle Key", 3)
			
				if tonumber(AimbotToggleKey) == nil then
					CrownVariables.Keybinds.AimbotToggleKey = 999
				else
					CrownVariables.Keybinds.AimbotToggleKey = AimbotToggleKey
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('menusettings') then
			if CrownMenu.MenuButton("Themes", "menuthemes") then
			elseif CrownMenu.MenuButton("Keybinds", "keybinds") then
			elseif CrownMenu.CheckBox("Discord Presence", CrownVariables.MenuOptions.DiscordRichPresence) then
				CrownVariables.MenuOptions.DiscordRichPresence = not CrownVariables.MenuOptions.DiscordRichPresence

				if not CrownVariables.MenuOptions.DiscordRichPresence then
                    SetDiscordAppId(0)
					SetDiscordRichPresenceAsset(0)
					SetDiscordRichPresenceAssetText(0)
					SetDiscordRichPresenceAssetSmall(0)
					SetDiscordRichPresenceAssetSmallText(0)
				end

			elseif CrownMenu.CheckBox("GTA Keyboard Input", CrownMenu.UI.GTAInput) then
				CrownMenu.UI.GTAInput = not CrownMenu.UI.GTAInput
			elseif CrownMenu.CheckBox("Watermark", CrownVariables.MenuOptions.Watermark) then
				CrownVariables.MenuOptions.Watermark = not CrownVariables.MenuOptions.Watermark
			elseif CrownMenu.ValueChanger("Maximum Option Count", CrownMenu.UI.MaximumOptionCount, 1, {1, 19}, function(val)
				CrownMenu.UI.MaximumOptionCount = val
			end) then
			elseif CrownMenu.ValueChanger("Menu X", CrownMenu.UI.MenuX, 0.01, {0.025, 0.99 - CrownMenu.menus[CrownMenu.currentMenu].width}, function(val)
				CrownMenu.UI.MenuX = val
				CrownMenu.SetMenuProperty(CrownMenu.currentMenu, 'x', CrownMenu.UI.MenuX)
			end) then
			elseif CrownMenu.ValueChanger("Menu Y", CrownMenu.UI.MenuY, 0.01, {0.025, 0.2}, function(val)
				CrownMenu.UI.MenuY = val
				CrownMenu.SetMenuProperty(CrownMenu.currentMenu, 'y', CrownMenu.UI.MenuY)
			end) then
			elseif CrownMenu.ValueChanger("Notification X", CrownMenu.UI.NotificationX, 0.01, {0.025, 0.690}, function(val)
				CrownMenu.UI.NotificationX = val
			end) then
			elseif CrownMenu.ValueChanger("Notification Y", CrownMenu.UI.NotificationY, 0.01, {0.025, 0.5}, function(val)
				CrownMenu.UI.NotificationY = val
			end) then
			elseif CrownMenu.Button("Injected at " .. InjectionTime) then
			elseif CrownMenu.Button("Menu Version: " ..CrownMenu.Version) then
			end
			
			if CrownMenu.menus[CrownMenu.currentMenu].currentOption == 9 or CrownMenu.menus[CrownMenu.currentMenu].currentOption == 10 then
				PushNotification("Notifications Look Like This", 1)
			end
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('worldoptions') then
			if CrownMenu.MenuButton('Weather Options', 'weatheroptions', "Set the Weather") then
			elseif CrownMenu.MenuButton('Time Options', 'timeoptions', "Set the Time") then
			end
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('doorvehicleoptions') then
			
			if CrownMenu.Button("Open All Doors", "", false, "Opens All Doors") then
				for door = 0, 7 do
					SetVehicleDoorOpen(GetPlayersLastVehicle(), door, false, false)
				end
			elseif CrownMenu.Button("Close All Doors", "", false, "Close All Doors") then
				for door = 0, 7 do
					SetVehicleDoorShut(GetPlayersLastVehicle(), door, false)
				end
			elseif CrownMenu.Button("Break All Doors", "", false, "Make all doors fall off") then
				for door = 0, 7 do
					SetVehicleDoorBroken(GetPlayersLastVehicle(), door, false)
				end
			elseif CrownMenu.ComboBox("Open Door", {"Left Front", "Right Front", "Left Back", "Right Back", "Hood", "Trunk"}, curDoorIndex, function(currentIndex, selectedIndex)
				curDoorIndex = currentIndex
				selDoorIndex = currentIndex
				end) then

				SetVehicleDoorOpen(GetPlayersLastVehicle(), selDoorIndex - 1, false, false)
			elseif CrownMenu.ComboBox("Close Door", {"Left Front", "Right Front", "Left Back", "Right Back", "Hood", "Trunk"}, curClosedDoorIndex, function(currentIndex, selectedIndex)
				curClosedDoorIndex = currentIndex
				selClosedDoorIndex = currentIndex
				end) then
	
				SetVehicleDoorShut(GetPlayersLastVehicle(), selClosedDoorIndex - 1, false)
			elseif CrownMenu.ComboBox("Break Door", {"Left Front", "Right Front", "Left Back", "Right Back", "Hood", "Trunk"}, curClosedBreakIndex, function(currentIndex, selectedIndex)
				curClosedBreakIndex = currentIndex
				selClosedBreakIndex = currentIndex
				end) then
	
				SetVehicleDoorBroken(GetPlayersLastVehicle(), selClosedBreakIndex - 1, false)
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selectectedcatagoryvehicleoptions') then
			local menu = CrownMenu.menus[CrownMenu.currentMenu]
			local catagory = CrownMenu.menus[CrownMenu.currentMenu].subTitle

			if VehicleList[catagory] ~= nil then
				for i = 1, #VehicleList[catagory] do
					if CrownMenu.Button(VehicleList[catagory][i]) then
						RequestModel(GetHashKey(VehicleList[catagory][i]))
	
						local loops = 0
	
						while not HasModelLoaded(GetHashKey(VehicleList[catagory][i])) and loops < 500 do
							loops = loops + 1
							Wait(1)
						end
						
						if spawninsidevehicle then
							local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5)
							local SpawnedCar = CreateVehicle(GetHashKey(VehicleList[catagory][i]), coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), 1, 1)	  
							SetPedInVehicleContext(PlayerPedId(), GetHashKey(VehicleList[catagory][i]))
							SetPedIntoVehicle(PlayerPedId(), SpawnedCar, -1)
							if CustomSpawnColour then
								local r,g,b = table.unpack(defaultvehcolor)
								SetVehicleCustomPrimaryColour(SpawnedCar, r, g, b)
								SetVehicleCustomSecondaryColour(SpawnedCar, r, g, b)
							end
						else
							local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5)
							local SpawnedCar = CreateVehicle(GetHashKey(VehicleList[catagory][i]), coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), 1, 1)
							if CustomSpawnColour then
								local r,g,b = table.unpack(defaultvehcolor)
								SetVehicleCustomPrimaryColour(SpawnedCar, r, g, b)
								SetVehicleCustomSecondaryColour(SpawnedCar, r, g, b)
							end
						end
					end
				end
		    end
		
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('spawnvehiclesettings') then
			if CrownMenu.CheckBox("Spawn Inside", spawninsidevehicle) then
				spawninsidevehicle = not spawninsidevehicle
			elseif CrownMenu.CheckBox("Spawn with Custom Colour", CustomSpawnColour) then
				CustomSpawnColour = not CustomSpawnColour
			elseif CrownMenu.Button("Set Vehicle Spawn Colour") then
				local r = CrownMenu.KeyboardEntry("Enter Red Value 0 - 255", 3)
				local g = CrownMenu.KeyboardEntry("Enter Green Value 0 - 255", 3)
				local b = CrownMenu.KeyboardEntry("Enter Blue Value 0 - 255", 3)
				r = tonumber(r)
				g = tonumber(g)
				b = tonumber(b)
				if r == nil or g == nil or b == nil then
				elseif r  < 0 or g < 0 or b < 0 or r > 255 or g > 255 or b > 255 then
				else
					defaultvehcolor = { r,g,b }
				end
			end
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('spawnvehicleoptions') then

			if CrownMenu.MenuButton("Spawn Settings", "spawnvehiclesettings") then
			elseif CrownMenu.Button("Input Vehicle Spawn Code") then
				local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5)
				local result = CrownMenu.KeyboardEntry("Enter Vehcle Spawn Name", 200)

				if HasModelLoaded(GetHashKey(result)) then

				else
					RequestModel(GetHashKey(result))
					Wait(500)
				end
				
				CancelOnscreenKeyboard()
					
				local vehicle = CreateVehicle(GetHashKey(result), coords.x + 1.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
				if CustomSpawnColour then
					local r,g,b = table.unpack(defaultvehcolor)
					SetVehicleCustomPrimaryColour(vehicle, r, g, b)
					SetVehicleCustomSecondaryColour(vehicle, r, g, b)
				end
				SetVehicleNeedsToBeHotwired(vehicle, false)
				SetEntityHeading(vehicle, GetEntityHeading(PlayerPedId()))
				SetVehicleEngineOn(vehicle, true, false, false)
				SetVehRadioStation(vehicle, 'OFF')
				if spawninsidevehicle then
					SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
				end

				CancelOnscreenKeyboard()
			elseif CrownMenu.MenuButton("Funny Vehicles", "funnyvehicles") then
			end

			for i = 1, #VehicleList.Catagories do
				if CrownMenu.MenuButton(VehicleList.Catagories[i], "selectectedcatagoryvehicleoptions") then
					CrownMenu.SetMenuProperty('selectectedcatagoryvehicleoptions', 'subTitle', VehicleList.Catagories[i])
				end
			end
 
			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('funnyvehicles') then
			
			if CrownMenu.Button("UFO") then

				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					UFOVeh(-1)
				end

			elseif CrownMenu.Button("T20 Ramp Car") then

				RampCar(-1)

			elseif CrownMenu.Button("Armoured Banshee") then
				RequestModel(GetHashKey("banshee"))
				RequestModel(GetHashKey("kuruma2"))

				local r = math.random(1, 254)
				local g = math.random(1, 254)
				local b = math.random(1, 254)

				Wait(500)

				local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5)

				local vehicle = CreateVehicle(GetHashKey("banshee"), coords.x, coords.y, coords.z, 0.0, 1, 1)
				local vehicle2 = CreateVehicle(GetHashKey("kuruma2"), coords.x, coords.y, coords.z, 0.0, 1, 1)

				SetEntityHeading(vehicle, GetEntityHeading(PlayerPedId()))

				AttachEntityToEntity(vehicle2, vehicle, 0, 0.0, -0.11, -0.0100, 0.5, 0.0, 0.0, true, true, false, false, true, true)

				SetVehicleCanBreak(vehicle2, false)

				WashDecalsFromVehicle(vehicle, 1.0)
				SetVehicleDirtLevel(vehicle)
				WashDecalsFromVehicle(vehicle2, 1.0)
				SetVehicleDirtLevel(vehicle2)
				SetVehicleCustomPrimaryColour(vehicle, r, g, b)
				SetVehicleCustomSecondaryColour(vehicle, r, g, b)
				SetVehicleModColor_1(vehicle, 4, 255, 0)
				SetVehicleModColor_1(vehicle2, 4, 255, 0)

				SetVehicleCustomPrimaryColour(vehicle2, r, g, b)
				SetEntityHeading(vehicle, GetEntityHeading(PlayerPedId()))

				SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
			elseif CrownMenu.Button("Boombox Car") then
				RequestModel(GetHashKey("surano"))
				RequestModel(GetHashKey("prop_speaker_05"))
				RequestModel(GetHashKey("prop_speaker_03"))
				RequestModel(GetHashKey("prop_speaker_01"))

				local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5)

				local vehicle = CreateVehicle(GetHashKey("surano"), coords.x, coords.y, coords.z, 0.0, 1, 1)
				local frontspeaker = CreateObject(GetHashKey("prop_speaker_05"), 9, 9, 9, 1, 1, 1)
				local secondspeaker = CreateObject(GetHashKey("prop_speaker_01"), 9, 9, 9, 1, 1, 1)
				local thirdspeaker = CreateObject(GetHashKey("prop_speaker_03"), 9, 9, 9, 1, 1, 1)
				local fourthspeaker = CreateObject(GetHashKey("prop_speaker_03"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(frontspeaker, vehicle, 0, 0.0, 1.8830, 0.2240, 0.0, 0.0, 180.0, true, true, false, false, true, true)
				AttachEntityToEntity(secondspeaker, vehicle, 0, 0.0, -1.23, -0.24, 0.0, 0.0, 180.0, true, true, false, false, true, true)
				AttachEntityToEntity(thirdspeaker, vehicle, 0, -0.6, -1.5, 0.25, 0.0, 0.0, 0.0, true, true, false, false, true, true)
				AttachEntityToEntity(fourthspeaker, thirdspeaker, 0, 1.2, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, true, true)

				SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)

				SetEntityHeading(vehicle, GetEntityHeading(PlayerPedId()))
				
				SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('Crowncustoms') then
			
			local inveh = IsPedInAnyVehicle(PlayerPedId(), false)

			if CrownMenu.Button("Set Vehicle License Plate", "", false, "Set License") then
				license = CrownMenu.KeyboardEntry("Vehicle License Plate", 8)
				SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId()), license)
				
			elseif CrownMenu.Button("Set Vehicle Paint") then
				local playerVeh = GetVehiclePedIsIn(PlayerPedId(), true)
				local r = CrownMenu.KeyboardEntry("Red Colour | Number Between 0-255", 3)
				local g = CrownMenu.KeyboardEntry("Green Colour | Number Between 0-255", 3)
				local b = CrownMenu.KeyboardEntry("Blue Colour | Number Between 0-255", 3)

				r = tonumber(r)
				g = tonumber(g)
				b = tonumber(b)

				if r == nil then
					r = 0
				end
				if g == nil then
					g = 0
				end
				if b == nil then
					b = 0
				end

				if r > 255 then
					r = 255
				end
				if r < 0 then
					r = 0
				end
				if g > 255 then
					g = 255
				end
				if g < 0 then
					g = 0
				end
				if b > 255 then
					b = 255
				end
				if b < 0 then
					b = 0
				end

				SetVehicleCustomPrimaryColour(playerVeh, r, g, b)
				SetVehicleCustomSecondaryColour(playerVeh, r, g, b)
		    elseif CrownMenu.Button("Max Out Vehicle", "", false, "Max Out Engine and the Bodywork") then
			    MaxOut(GetVehiclePedIsIn(PlayerPedId(), 0))
		    end
			if CrownMenu.Button("Helicopter Blades Under Car") then
				for i = 1, 5 do 
					
			     	local ped = PlayerPedId()
			     	local coords = GetEntityCoords(ped)
					local vehicleplyr = GetVehiclePedIsIn(ped, 0)
				
			     	local pedmodel = "a_m_m_eastsa_01"
			     	local planemodel = "buzzard"
			
			     	RequestModel(GetHashKey(pedmodel))
			     	RequestModel(GetHashKey(planemodel))
			
			     	local loadattemps = 0
			
			     	while not HasModelLoaded(GetHashKey(pedmodel)) do
						loadattemps = loadattemps + 1
						Citizen.Wait(1)
						if loadattemps > 10000 then
							break
						end
					end
			
					while not HasModelLoaded(GetHashKey(planemodel)) and loadattemps < 10000 do
						Wait(500)
					end
				
					local nped = CreatePed(4, pedmodel, coords.x, coords.y, coords.z, 0.0, true, true)
			
					local veh = CreateVehicle(GetHashKey(planemodel), coords.x, coords.y, coords.z + 50.0, GetEntityHeading(ped), 1, 1)
				
					ClearPedTasks(nped)
				
					SetPedIntoVehicle(nped, veh, -1)
			
					SetPedKeepTask(nped, true)

					AttachEntityToEntity(veh, vehicleplyr, 0, 0.0, 0.0, -2.5, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

					SetVehicleCanBreak(veh, false)

				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('vehicletricks') then
			if CrownMenu.Button("Do a Kick Flip", "", "Do a Kickflip") then
				local playerPed = PlayerPedId()
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
			       
	            if DoesEntityExist(playerVeh) then
				    ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 10.0, 90.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end
			elseif CrownMenu.Button("Do a Back Flip") then
				local playerPed = PlayerPedId()
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
			       
	            if DoesEntityExist(playerVeh) then
				    ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 15.0, 0.0, 60.0, 0.0, 0, 0, 1, 1, 0, 0)
				end
			elseif CrownMenu.Button("Do a Jump") then
				local playerPed = PlayerPedId()
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
			       
	            if DoesEntityExist(playerVeh) then
				    ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 15.0, 0.0, 0.0, 00.0, 0, 1, 0, 1, 0, 0)
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('personalvehicleautopilot') then
			if CrownMenu.Button("Teleport Self Into Vehicle") then
				SetPedIntoVehicle(PlayerPedId(), CrownVariables.VehicleOptions.PersonalVehicle, -1)
			elseif CrownMenu.Button("Teleport Vehicle To Self") then
				SetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle, GetEntityCoords(PlayerPedId()))
			elseif CrownMenu.Button("Auto Pilot Vehicle To Self", "", false, "Dude WTF How do you do that") then
				if GetVehiclePedIsUsing(PlayerPedId()) == CrownVariables.VehicleOptions.PersonalVehicle then
					PVAutoDriving = false
				else
					PVAutoDriving = true
					Citizen.CreateThread(function()
						if DoesEntityExist(Driver) then
							DeleteEntity(Driver)
						end
						Driver = CreatePed(5, GetEntityModel(PlayerPedId()), spawnCoords, spawnHeading, true)
						TaskWarpPedIntoVehicle(Driver, CrownVariables.VehicleOptions.PersonalVehicle, -1)
						SetEntityVisible(Driver, false)
						while not killmenu and PVAutoDriving do
							SetPedMaxHealth(Driver, 10000)
							SetEntityHealth(Driver, 10000)
							SetEntityInvincible(Driver, false)
							SetPedCanRagdoll(Driver, true)
							ClearPedLastWeaponDamage(Driver)
							SetEntityProofs(Driver, false, false, false, false, false, false, false, false)
							SetEntityOnlyDamagedByPlayer(Driver, true)
							SetEntityCanBeDamaged(Driver, true)

							if not DoesEntityExist(CrownVariables.VehicleOptions.PersonalVehicle) or not DoesEntityExist(Driver) then
								break
							end
							Wait(100)
							coords = GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle)
							plycoords = GetEntityCoords(PlayerPedId())
							TaskVehicleDriveToCoordLongrange(Driver, CrownVariables.VehicleOptions.PersonalVehicle, plycoords.x, plycoords.y, plycoords.z, 25.0, 1074528293, 1.0)
							SetVehicleLightsMode(CrownVariables.VehicleOptions.PersonalVehicle, 2)
							distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, plycoords.x, plycoords.y, coords.z, true)
							if IsVehicleStuckOnRoof(CrownVariables.VehicleOptions.PersonalVehicle) then
								SetVehicleCoords(CrownVariables.VehicleOptions.PersonalVehicle, GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle))
							end
							if distance < 5.0 then
								PushNotification("Your Personal Vehicle has Arrived")
								SetVehicleForwardSpeed(CrownVariables.VehicleOptions.PersonalVehicle, 1.0)
								DeleteEntity(Driver)
								PVAutoDriving = false
								return
							end
						end
					end)
				end
			
			elseif CrownMenu.Button("Auto Pilot Vehicle To Waypoint", "", false, "Dude WTF How do you do that") then
				local plycoords = GetBlipCoords(GetFirstBlipInfoId(8))
				if GetVehiclePedIsUsing(PlayerPedId()) == CrownVariables.VehicleOptions.PersonalVehicle then
					PVAutoDriving = false
				else
					PVAutoDriving = true
					Citizen.CreateThread(function()
						if DoesEntityExist(Driver) then
							DeleteEntity(Driver)
						end
						Driver = CreatePed(5, GetEntityModel(PlayerPedId()), spawnCoords, spawnHeading, true)
						TaskWarpPedIntoVehicle(Driver, CrownVariables.VehicleOptions.PersonalVehicle, -1)
						SetEntityVisible(Driver, false)
				
						while not killmenu and PVAutoDriving do
							if not DoesEntityExist(CrownVariables.VehicleOptions.PersonalVehicle) or not DoesEntityExist(Driver) then
								break
							end
							Wait(100)
							coords = GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle)
							TaskVehicleDriveToCoordLongrange(Driver, CrownVariables.VehicleOptions.PersonalVehicle, plycoords.x, plycoords.y, plycoords.z, 25.0, 1074528293, 1.0)
							SetVehicleLightsMode(CrownVariables.VehicleOptions.PersonalVehicle, 2)
							distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, plycoords.x, plycoords.y, coords.z, true)
							if IsVehicleStuckOnRoof(CrownVariables.VehicleOptions.PersonalVehicle) then
								SetVehicleCoords(CrownVariables.VehicleOptions.PersonalVehicle, GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle))
							end
							if distance < 5.0 then
								SetVehicleForwardSpeed(CrownVariables.VehicleOptions.PersonalVehicle, 1.0)
								DeleteEntity(Driver)
								PVAutoDriving = false
								return
							end
						end
					end)
				end
			
			elseif CrownMenu.Button("Auto Pilot Vehicle Around Area", "", false, "Dude WTF How do you do that") then
				Driver = CreatePed(5, GetEntityModel(PlayerPedId()), spawnCoords, spawnHeading, true)
				TaskWarpPedIntoVehicle(Driver, CrownVariables.VehicleOptions.PersonalVehicle, -1)
				SetEntityVisible(Driver, false)
				TaskVehicleDriveWander(Driver, CrownVariables.VehicleOptions.PersonalVehicle, 50.0, 5)
			elseif CrownMenu.Button("Cancel Auto Pilot", "", false, "Dude Thats INSANE") then
				PVAutoDriving = false
				if DoesEntityExist(Driver) then
					DeleteEntity(Driver)
				end
			elseif PVAutoDriving and CrownMenu.Button("Teleport Vehicle Forward") then
				offset = GetOffsetFromEntityInWorldCoords(CrownVariables.VehicleOptions.PersonalVehicle, 0.0, 5.0, 0.5)
				SetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle, offset.x, offset.y, offset.z, 0, 0, 0, 0)
			elseif PVAutoDriving and CrownMenu.Button("Teleport Vehicle Back") then
				offset = GetOffsetFromEntityInWorldCoords(CrownVariables.VehicleOptions.PersonalVehicle, 0.0, -5.0, 0.5)
				SetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle, offset.x, offset.y, offset.z, 0, 0, 0, 0)
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('personalvehicle') then

			if not DoesEntityExist(CrownVariables.VehicleOptions.PersonalVehicle) then
                CrownVariables.VehicleOptions.PersonalVehicle = false
			end

			if CrownVariables.VehicleOptions.PersonalVehicle == false then

				CrownVariables.VehicleOptions.PersonalVehicleESP = false
				CrownVariables.VehicleOptions.PersonalVehicleMarker = false
				PVLocked = false
				PVLockedForSelf = false
				
				if CrownMenu.Button("Set Personal Vehicle") then
					CrownVariables.VehicleOptions.PersonalVehicle = GetVehiclePedIsIn(PlayerPedId(), 0)
					SetEntityAsMissionEntity(CrownVariables.VehicleOptions.PersonalVehicle, 1, 1)
				end
			end

			if CrownVariables.VehicleOptions.PersonalVehicle ~= false then
				if CrownMenu.MenuButton("Auto Pilot", "personalvehicleautopilot") then
				elseif CrownMenu.Button("Remove Personal Vehicle") then
					CrownVariables.VehicleOptions.PersonalVehicle = false
					SetEntityAsMissionEntity(CrownVariables.VehicleOptions.PersonalVehicle, 0, 0)
			    elseif CrownMenu.Button("Repair Vehicle") then
					NetworkRequestControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle))
					if NetworkHasControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle)) then
						SetVehicleEngineHealth(CrownVariables.VehicleOptions.PersonalVehicle, 1000)
						SetVehicleFixed(CrownVariables.VehicleOptions.PersonalVehicle)
					else
                        NetworkRequestControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle))
					end
			    elseif CrownMenu.Button("Burst Vehicle Tyres") then
					NetworkRequestControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle))
					if NetworkHasControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle)) then
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 0, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 1, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 2, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 3, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 4, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 5, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 4, true, 1000.0)
						SetVehicleTyreBurst(CrownVariables.VehicleOptions.PersonalVehicle, 7, true, 1000.0)
					else
                        NetworkRequestControlOfNetworkId(VehToNet(CrownVariables.VehicleOptions.PersonalVehicle))
					end
				elseif CrownMenu.CheckBox("Siern", VehicleSiren) then
					VehicleSiren = not VehicleSiren
					SetVehicleSiren(CrownVariables.VehicleOptions.PersonalVehicle, VehicleSiren)
				elseif CrownMenu.CheckBox("Locked", PVLocked) then
					PVLocked = not PVLocked
					RequestControlOnce(CrownVariables.VehicleOptions.PersonalVehicle)
					SetVehicleDoorsLocked(CrownVariables.VehicleOptions.PersonalVehicle, PVLocked)
					SetVehicleDoorsLockedForAllPlayers(CrownVariables.VehicleOptions.PersonalVehicle, PVLocked)
					if PVLocked == false then
						PVLockedForSelf = false
					end
				elseif PVLocked and CrownMenu.CheckBox("Unlocked For Self", PVLockedForSelf, "The Car is locked for everyone but you") then
					PVLockedForSelf = not PVLockedForSelf
					RequestControlOnce(CrownVariables.VehicleOptions.PersonalVehicle)
					SetVehicleDoorsLockedForPlayer(CrownVariables.VehicleOptions.PersonalVehicle, PlayerId(), not PVLockedForSelf)
				elseif PVLocked and CrownMenu.CheckBox("Unlocked For Friends", PVLockedForFriends, "The Car is locked for everyone but yourfriends") then
					PVLockedForFriends = not PVLockedForFriends
					RequestControlOnce(CrownVariables.VehicleOptions.PersonalVehicle)
					for i = 1, #FriendsList do
					    SetVehicleDoorsLockedForPlayer(CrownVariables.VehicleOptions.PersonalVehicle, FriendsList[i], not PVLockedForFriends)
					end
				elseif CrownMenu.CheckBox("Camera", CrownVariables.VehicleOptions.PersonalVehicleCam) then
					if CrownVariables.VehicleOptions.PersonalVehicleCam then
                        EndPersonalVehicleCam()
					else
                        StartPersonalVehicleCam()
					end
				elseif CrownMenu.CheckBox("ESP", CrownVariables.VehicleOptions.PersonalVehicleESP) then
					CrownVariables.VehicleOptions.PersonalVehicleESP = not CrownVariables.VehicleOptions.PersonalVehicleESP
				elseif CrownMenu.CheckBox("Blip", CrownVariables.VehicleOptions.PersonalVehicleMarker) then
					CrownVariables.VehicleOptions.PersonalVehicleMarker = not CrownVariables.VehicleOptions.PersonalVehicleMarker
				elseif CrownMenu.ComboBox("Open Vehicle Doors", {"Left Front", "Right Front", "Left Back", "Right Back", "Hood", "Trunk"}, CrownVariables.VehicleOptions.CurDoorPV, function(currentIndex, selectedIndex)
					
					CrownVariables.VehicleOptions.CurDoorPV = currentIndex

				end) then
					SetVehicleDoorOpen(GetPlayersLastVehicle(), CrownVariables.VehicleOptions.SelDoorPV - 1, false, false)
				elseif CrownMenu.ComboBox("Close Vehicle Doors", {"Left Front", "Right Front", "Left Back", "Right Back", "Hood", "Trunk"}, CrownVariables.VehicleOptions.CurCloseDoorPV, function(currentIndex, selectedIndex)
					
					CrownVariables.VehicleOptions.CurCloseDoorPV = currentIndex

				end) then
					SetVehicleDoorShut(GetPlayersLastVehicle(), CrownVariables.VehicleOptions.SelCloseDoorPV - 1, false, false)
				end
			end
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('vehicleautopilot') then

			if CrownMenu.Button("Drive To Waypoint") then
				autodriving = true
				local waypoint = GetFirstBlipInfoId(8)
				if DoesBlipExist(waypoint) then
					coords = GetBlipInfoIdCoord(waypoint)
					TaskVehicleDriveToCoordLongrange(PlayerPedId(), GetVehiclePedIsUsing(PlayerPedId()), coords.x, coords.y, coords.z, CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed, CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle, 10.0)
					Citizen.CreateThread(function()
						while not killmenu and autodriving do
							Wait(1000)
							plycoords = GetEntityCoords(PlayerPedId())
							distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, plycoords.x, plycoords.y, coords.z, false)
							if distance < 10.0 then
								ClearPedTasks(PlayerPedId())
								PushNotification("You have arrived at your Destination", 600)
								SetDriveTaskCruiseSpeed(PlayerPedId(), 0)
								autodriving = false
							end
						end
					end)
				end
			elseif CrownMenu.ComboBox("Driving Style", CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyles, CrownVariables.VehicleOptions.AutoPilotOptions.CurCruiseSpeedIndex, function(currentIndex)
					
				CrownVariables.VehicleOptions.AutoPilotOptions.CurCruiseSpeedIndex = currentIndex

			end) then
				
				if CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 1 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 6
				elseif CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 2 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 5
				elseif CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 3 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 1074528293
				elseif CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 4 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 786603
				elseif CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 5 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 2883621
				elseif CrownVariables.VehicleOptions.AutoPilotOptions.SelCruiseSpeedIndex == 6 then
					CrownVariables.VehicleOptions.AutoPilotOptions.DrivingStyle = 786468 
				end
			elseif CrownMenu.Button("Speed",  "ᐊ " .. CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed .. " ") then
			elseif CrownMenu.Button("Cancel Auto Pilot") then
				autodriving = false
				ClearPedTasks(PlayerPedId())
			end

			if CrownMenu.menus[CrownMenu.currentMenu].currentOption == 3 then
				if IsDisabledControlJustReleased(0, 175) then
					if CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed < 200.0 then
					    CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed = CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed + 1 
					end
				end
				if IsDisabledControlJustReleased(0, 174) then
					if CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed > 10.0 then
					    CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed = CrownVariables.VehicleOptions.AutoPilotOptions.CruiseSpeed - 1
					end
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('vehicleoptions') then
			
			if CrownMenu.MenuButton("Spawn Vehicles", "spawnvehicleoptions") then
			elseif CrownMenu.MenuButton("Open Vehicle Doors", "doorvehicleoptions") then
			elseif CrownMenu.MenuButton("Vehicle Tricks", "vehicletricks") then
			elseif CrownMenu.MenuButton("Crown Customs", "Crowncustoms") then
			elseif CrownMenu.MenuButton("Personal Vehicle", "personalvehicle") then
			elseif CrownMenu.MenuButton("Auto Pilot Menu", "vehicleautopilot") then
			elseif CrownMenu.CheckBox("Vehicle Snatcher", VehicleSnatcher) then
				VehicleSnatcher = not VehicleSnatcher
				if VehicleSnatcher then
					FreeCameraMode = "Vehicle Snatcher"
					StartFreeCam(GetGameplayCamFov())
				else
					FreeCameraMode = false
					EndFreeCam()
				end
				
			elseif CrownMenu.Button("Toggle Engine On/Off", "", false, "Turn The Engine On/Off") then
				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
				if GetIsVehicleEngineRunning(veh) then
					SetVehicleEngineOn(veh, false, true, true)
				else
					SetVehicleEngineOn(veh, true, true, false)
				end
		    elseif CrownMenu.Button("Repair Vehicle", "", false, "Repair All Scratches, Dents & Engine") then

				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)

				SetVehicleEngineHealth(veh, 1000)
				SetVehicleFixed(veh)
			elseif CrownMenu.Button("Freeze / Unfreeze Vehicle") then
				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)

				if IsEntityStatic(veh) then
					FreezeEntityPosition(veh, false)
				else
					FreezeEntityPosition(veh, true)
				end
			elseif CrownMenu.Button("Set Vehicle Upright") then
				
				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)

				SetEntityRotation(veh, 0.0, 0.0, GetEntityHeading(veh))

			elseif CrownMenu.Button("Clean Vehicle") then
				WashDecalsFromVehicle(GetVehiclePedIsUsing(GetPlayerPed(-1)), 1.0)
				SetVehicleDirtLevel(GetVehiclePedIsUsing(GetPlayerPed(-1)))
			elseif CrownMenu.CheckBox("Vehicle Godmode", CrownVariables.VehicleOptions.vehgodmode) then
				
				CrownVariables.VehicleOptions.vehgodmode = not CrownVariables.VehicleOptions.vehgodmode

				if not CrownVariables.VehicleOptions.vehgodmode then
					SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), false)
				end
		
			elseif CrownMenu.CheckBox("Always Clean", CrownVariables.VehicleOptions.AutoClean) then
				CrownVariables.VehicleOptions.AutoClean = not CrownVariables.VehicleOptions.AutoClean
			elseif CrownMenu.CheckBox("Speed Boost On Horn", CrownVariables.VehicleOptions.speedboost, "Haha Car go brrrrr") then
				CrownVariables.VehicleOptions.speedboost = not CrownVariables.VehicleOptions.speedboost
			elseif CrownMenu.CheckBox("Instant Stop", CrownVariables.VehicleOptions.InstantBreaks, "When you break you stop Instantly") then
				CrownVariables.VehicleOptions.InstantBreaks = not CrownVariables.VehicleOptions.InstantBreaks
			elseif CrownMenu.CheckBox("Waterproof", CrownVariables.VehicleOptions.Waterproof) then
				CrownVariables.VehicleOptions.Waterproof = not CrownVariables.VehicleOptions.Waterproof
			elseif CrownMenu.CheckBox("Power Multiplier", CrownVariables.VehicleOptions.activeenignemulr) then
				CrownVariables.VehicleOptions.activeenignemulr = not CrownVariables.VehicleOptions.activeenignemulr

				if not CrownVariables.VehicleOptions.activeenignemulr then
					local vehicle = GetPlayersLastVehicle()
					SetVehicleEnginePowerMultiplier(vehicle, 1.0)
				end

			elseif CrownMenu.ComboBox("Power Multiplier", CrownVariables.VehicleOptions.vehenginemultiplier, CrownVariables.VehicleOptions.curractiveenignemulrIndex, function(currentIndex, selectedIndex)
				
				CrownVariables.VehicleOptions.curractiveenignemulrIndex = currentIndex

				end) then
		
			elseif CrownMenu.CheckBox("Torque Multiplier", CrownVariables.VehicleOptions.activetorquemulr) then

				CrownVariables.VehicleOptions.activetorquemulr = not CrownVariables.VehicleOptions.activetorquemulr
	
				if not CrownVariables.VehicleOptions.activetorquemulr then
					local vehicle = GetPlayersLastVehicle()
					SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
				end

			elseif CrownMenu.ComboBox("Torque Multiplier", CrownVariables.VehicleOptions.vehenginemultiplier, CrownVariables.VehicleOptions.curractivetorqueIndex, function(currentIndex, selectedIndex)
				    CrownVariables.VehicleOptions.curractivetorqueIndex = currentIndex
				end) then

			elseif CrownMenu.UI.RGB and CrownMenu.CheckBox("Rainbow Car", CrownVariables.VehicleOptions.rainbowcar) then
				
				CrownVariables.VehicleOptions.rainbowcar = not CrownVariables.VehicleOptions.rainbowcar

			elseif CrownMenu.CheckBox("Always Wheelie", CrownVariables.VehicleOptions.AlwaysWheelie) then
				CrownVariables.VehicleOptions.AlwaysWheelie = not CrownVariables.VehicleOptions.AlwaysWheelie
			elseif CrownMenu.CheckBox("Easy Handling", CrownVariables.VehicleOptions.EasyHandling) then
					
				CrownVariables.VehicleOptions.EasyHandling = not CrownVariables.VehicleOptions.EasyHandling
				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
	
				if not CrownVariables.VehicleOptions.EasyHandling then
					SetVehicleGravityAmount(veh, 9.8)
				end
				
			elseif CrownMenu.CheckBox("Drive On Water", CrownVariables.VehicleOptions.DriveOnWater) then
				CrownVariables.VehicleOptions.DriveOnWater = not CrownVariables.VehicleOptions.DriveOnWater
				if CrownVariables.VehicleOptions.DriveOnWaterProp == nil then
					x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
					CrownVariables.VehicleOptions.DriveOnWaterProp = CreateObject(GetHashKey("ar_prop_ar_bblock_huge_01"), x, y, -90.0, 0, 1, 0)
				elseif not CrownVariables.VehicleOptions.DriveOnWater then
					DeleteEntity(CrownVariables.VehicleOptions.DriveOnWaterProp)
					CrownVariables.VehicleOptions.DriveOnWaterProp = nil
				end
			elseif CrownMenu.CheckBox("Police Headlights", policeheadlights) then

	            policeheadlights = not policeheadlights
				TogPoliceHeadlights()

			elseif CrownMenu.CheckBox("Vehicle Speedometer", CrownVariables.VehicleOptions.speedometer) then
	
				CrownVariables.VehicleOptions.speedometer = not CrownVariables.VehicleOptions.speedometer

			elseif CrownMenu.CheckBox("Force Launch Control", CrownVariables.VehicleOptions.forcelauncontrol) then
				CrownVariables.VehicleOptions.forcelauncontrol = not CrownVariables.VehicleOptions.forcelauncontrol
				if CrownVariables.VehicleOptions.forcelauncontrol then
					SetLaunchControlEnabled(true)
				else
					SetLaunchControlEnabled(false)
				end
			elseif CrownMenu.CheckBox("No Bike Fall", CrownVariables.VehicleOptions.NoBikeFall) then
				CrownVariables.VehicleOptions.NoBikeFall = not CrownVariables.VehicleOptions.NoBikeFall
				SetPedCanBeKnockedOffVehicle(PlayerPedId(), CrownVariables.VehicleOptions.NoBikeFall)
			elseif CrownMenu.CheckBox("Crown License Plate", CrownVariables.VehicleOptions.Crownplate) then
				CrownVariables.VehicleOptions.Crownplate = not CrownVariables.VehicleOptions.Crownplate
				CrownPlate()
			elseif CrownMenu.Button("Delete Vehicle") then
				DeleteEntity(GetPlayersLastVehicle(PlayerPedId()))
			end

			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('visionoptions') then
			if CrownMenu.CheckBox("Thermal Vision", thermalvision) then
				thermalvision = not thermalvision
				if thermalvision then
					SetSeethrough(true)
				else
					SetSeethrough(false)
				end
			elseif CrownMenu.CheckBox("Night Vision", nightvision) then
				nightvision = not nightvision
				if nightvision then
					SetNightvision(true)
				else
					SetNightvision(false)
				end
			elseif CrownMenu.Button("Reset Vision") then
				ClearTimecycleModifier()
				ClearExtraTimecycleModifier()
			elseif CrownMenu.Button("Drunk Vision") then
				SetTimecycleModifier("Drunk")
			elseif CrownMenu.Button("Blue Vision", "") then
				SetExtraTimecycleModifier("LostTimeFlash")
			elseif CrownMenu.Button("Red Player Glow") then
				SetTimecycleModifier("mp_lad_night")
				SetTimecycleModifierStrength(1.2)
			elseif CrownMenu.Button("Yellow Player Glow") then
				SetTimecycleModifier("mp_lad_judgment")
				SetTimecycleModifierStrength(1.2)
			elseif CrownMenu.Button("White Player Glow") then
				SetTimecycleModifier("mp_lad_day")
				SetTimecycleModifierStrength(1.2)
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selfoptions') then

			if CrownMenu.MenuButton("Set Player Model", "selfmodellist") then
			elseif CrownMenu.MenuButton("Wardrobe", "selfwardrobe") then
			elseif CrownMenu.MenuButton("Super Powers", "superpowers") then
			elseif CrownMenu.MenuButton("Vision Options", "visionoptions") then
			elseif CrownMenu.MenuButton("Trigger Events", 'triggerevents') then
			elseif CrownMenu.MenuButton("Collision Options", "collisionoptions", "Disable Collisions for Some Objects") then
				
		    elseif CrownMenu.CheckBox("Invisible", CrownVariables.SelfOptions.invisiblitity) then
				CrownVariables.SelfOptions.invisiblitity = not CrownVariables.SelfOptions.invisiblitity
				
				if not CrownVariables.SelfOptions.invisiblitity then
					SetEntityVisible(PlayerPedId(), true, true)
				end 
			elseif CrownMenu.CheckBox("Godmode", CrownVariables.SelfOptions.godmode) then
				if SafeMode then
                    SafeModeNotification()
				else
					CrownVariables.SelfOptions.godmode = not CrownVariables.SelfOptions.godmode
					if not CrownVariables.SelfOptions.godmode then
						SetPedCanRagdoll(PlayerPedId(), true)
						ClearPedLastWeaponDamage(PlayerPedId())
						SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
						SetEntityOnlyDamagedByPlayer(PlayerPedId(), false)
						SetEntityCanBeDamaged(PlayerPedId(), true)
						SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
					end
				end
			elseif CrownMenu.CheckBox("Semi-Godmode", CrownVariables.SelfOptions.AutoHealthRefil) then
				CrownVariables.SelfOptions.AutoHealthRefil = not CrownVariables.SelfOptions.AutoHealthRefil
			elseif CrownMenu.CheckBox("Infinite Stamina", CrownVariables.SelfOptions.infstamina) then
				CrownVariables.SelfOptions.infstamina = not CrownVariables.SelfOptions.infstamina
			elseif CrownMenu.CheckBox("No Ragdoll", CrownVariables.SelfOptions.noragdoll) then

				CrownVariables.SelfOptions.noragdoll = not CrownVariables.SelfOptions.noragdoll

			elseif CrownMenu.CheckBox(GetPlayerWantedLevel(PlayerId()) > 0 and "Freeze Wanted Level" or "Never Wanted", CrownVariables.SelfOptions.FreezeWantedLevel) then
				CrownVariables.SelfOptions.FreezeWantedLevel = not CrownVariables.SelfOptions.FreezeWantedLevel
				CrownVariables.SelfOptions.FrozenWantedLevel = GetPlayerWantedLevel(PlayerId())
			elseif CrownMenu.ValueChanger("Wanted Level", GetPlayerWantedLevel(PlayerId()), 1, {0, 5}, function(val)
				SetPlayerWantedLevel(PlayerId(), val, false)
				SetPlayerWantedLevelNow(PlayerId())
			end) then
			elseif CrownMenu.CheckBox("Player Coords", CrownVariables.SelfOptions.playercoords) then
				CrownVariables.SelfOptions.playercoords = not CrownVariables.SelfOptions.playercoords
			elseif CrownMenu.CheckBox("Force Radar", CrownVariables.SelfOptions.forceradar, "Turn Your radar back on") then
				CrownVariables.SelfOptions.forceradar = not CrownVariables.SelfOptions.forceradar
			elseif CrownMenu.Button("Toggle Noclip") then
				NoClip()
			
	        elseif CrownMenu.ValueChanger("No-clip Speed", NoclipSpeed, 0.1, {0.1, 15}, function(value)
				NoclipSpeed = value
			end, true) then
				
			elseif CrownMenu.Button("Force Revive", "", "Revive Yourself works on most Non-ESX servers") then
				local ped = PlayerPedId()
				local playerPos = GetEntityCoords(ped, true)
				local heading = GetEntityHeading(ped)

				TriggerEvent("PGX:RevivePlayer")
			
				NetworkResurrectLocalPlayer(playerPos, true, true, false)
				SetPlayerInvincible(ped, false)
				ClearPedBloodDamage(ped)
				SetEntityHeading(ped, heading)
				FreezeEntityPosition(ped, false)

			elseif CrownMenu.DynamicTriggers.Triggers['ESXRevive'] ~= nil and CrownMenu.Button("ESX Revive", "", false, "Revive Yourself works on most Non-ESX servers") then
				
				TriggerEvent(CrownMenu.DynamicTriggers.Triggers['ESXRevive'])

			elseif CrownMenu.Button("Suicide") then

				SetEntityHealth(PlayerPedId(), 0)

			elseif CrownMenu.Button("Refill Health") then

				SetEntityHealth(PlayerPedId(), 200)

			elseif CrownMenu.Button("Refill Armour") then

				SetPedArmour(PlayerPedId(), 100)

			elseif CrownMenu.Button("Set Player Wet") then

				SetPedWetnessHeight(PlayerPedId(), 100.0)

			elseif CrownMenu.Button("Set Player Dry") then

				SetPedWetnessHeight(PlayerPedId(), -100.0)

			elseif CrownMenu.Button("Start Fireworks") then

				StartFireworks()
				
			elseif CrownMenu.Button("Freeze / Unfreeze Self") then

				if IsEntityStatic(PlayerPedId()) then
                    FreezeEntityPosition(PlayerPedId(), false)
				else
                    FreezeEntityPosition(PlayerPedId(), true)
				end

			elseif CrownMenu.CheckBox("Wander around", wonderaround) then
				wonderaround = not wonderaround

				if wonderaround then
					TaskWanderStandard(PlayerPedId(), 10.0, 10)	
				else
					ClearPedTasksImmediately(PlayerPedId())
				end
			elseif CrownMenu.Button("Clear Animation") then
                ClearPedTasksImmediately(PlayerPedId())
			
			end
			CrownMenu.Display()
			
		elseif CrownMenu.IsMenuOpened('teleportoptions') then
			if CrownMenu.CheckBox("Smooth Teleport", CrownVariables.TeleportOptions.smoothteleport, "Takes Longer but with a nice transition") then
				CrownVariables.TeleportOptions.smoothteleport = not CrownVariables.TeleportOptions.smoothteleport
			elseif CrownMenu.Button("Teleport To Waypoint") then
				
				local waypoint = GetFirstBlipInfoId(8)

				if DoesBlipExist(waypoint) then
					TeleportToCoords(GetBlipInfoIdCoord(waypoint))
				else
					PushNotification("You have not set a Waypoint", 600)
				end

			elseif CrownMenu.Button('Teleport To Coords') then

				local x = CrownMenu.KeyboardEntry("X Coordinate", 10)
				local y = CrownMenu.KeyboardEntry("Y Coordinate", 10)
				local z = CrownMenu.KeyboardEntry("Z Coordinate", 10)

				x = tonumber(x)
				y = tonumber(y)
				z = tonumber(z)

				SetEntityCoords(PlayerPedId(), x, y, z)

			elseif CrownMenu.Button('Teleport Foward') then

				local ped = PlayerPedId()
				local vehicle = GetPlayersLastVehicle()

				if IsPedInAnyVehicle(ped, true) then
					local coords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 2.5, 0)
					local x = coords.x
					local y = coords.y
					local z = coords.z
				    SetEntityCoords(vehicle, x, y, z)
				else
					local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.5, -1.0)
					local x = coords.x
					local y = coords.y
					local z = coords.z
				    SetEntityCoords(PlayerPedId(), x, y, z)
				end
			end

			if CrownMenu.Button("~c~--------------------- Locations --------------------") then

			end

			for i = 1, #CrownVariables.TeleportOptions.teleportlocations do
				local currLocation = CrownVariables.TeleportOptions.teleportlocations[i]
	
				if CrownMenu.Button(currLocation[1]) then
					local x = currLocation[2]
					local y = currLocation[3]
					local z = currLocation[4]

					TeleportToCoords(x, y, z)
				end
			end
			

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selectedweaponoptions') then

			local currentWeapon = selectedWeapon

			currentWeapon = currentWeapon:gsub("WEAPON_", "")

			firstletter = currentWeapon:sub(1, 1)

			firstletter = string.upper(firstletter)

			currentWeapon = currentWeapon:sub(2)

			local weapo = firstletter .. string.upper(currentWeapon)

			CrownMenu.SetMenuProperty('selectedweaponoptions', 'subTitle', weapo)
			
			equporrem = ""

			if not HasPedGotWeapon(PlayerPedId(), GetHashKey(selectedWeapon), false) then
				equporrem = "Equip"
			else
				equporrem = "Remove"
			end

			if CrownMenu.Button(equporrem) then
				if HasPedGotWeapon(PlayerPedId(), GetHashKey(selectedWeapon), false) then
				    RemoveWeaponFromPed(PlayerPedId(), GetHashKey(selectedWeapon))
			    else
				    GiveWeaponToPed(PlayerPedId(), GetHashKey(selectedWeapon), 9999, false, false)
				end
			elseif CrownMenu.Button("Refill Ammo") then
				SetAmmoInClip(PlayerPedId(), GetHashKey(selectedWeapon), 9999)
				SetPedAmmo(PlayerPedId(), GetHashKey(selectedWeapon), 9999)
			end
			
			for i = 1, #globalAttachmentTable do

				if DoesWeaponTakeWeaponComponent(GetHashKey(selectedWeapon), GetHashKey(globalAttachmentTable[i][1])) then
					if CrownMenu.Button(globalAttachmentTable[i][2]) then
						if HasPedGotWeaponComponent(PlayerPedId(), GetHashKey(selectedWeapon), globalAttachmentTable[i][1]) then
                            RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(selectedWeapon), globalAttachmentTable[i][1])
						else
						    GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(selectedWeapon), globalAttachmentTable[i][1])
						end
				    end
			    end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('weaponslist') then

			for i = 1, #allWeapons do
				local currentWeapon = allWeapons[i]
	
				currentWeapon = currentWeapon:gsub("WEAPON_", "")

				firstletter = currentWeapon:sub(1, 1)

				firstletter = string.upper(firstletter)

				currentWeapon = currentWeapon:sub(2)

				currentWeapon = string.lower(currentWeapon)

				if string.find(currentWeapon, "_") then
					currentWeapon = currentWeapon:gsub("_", " ")
				end

				if string.find(currentWeapon, "50") then
					currentWeapon = currentWeapon:gsub("50", " 50")
				end

				if string.find(currentWeapon, "mk") then
					currentWeapon = currentWeapon:gsub("mk", " MK")
				end

				if firstletter .. string.lower(currentWeapon) ~= "Unarmed" then
					if not string.find(currentWeapon, "adget") then
						if CrownMenu.MenuButton(firstletter .. currentWeapon, "selectedweaponoptions") then
							selectedWeapon = allWeapons[i] 
						end
					end
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('bulletoptions') then
			
			if CrownMenu.CheckBox("Bullet Replace", CrownVariables.WeaponOptions.BulletOptions.Enabled) then
				CrownVariables.WeaponOptions.BulletOptions.Enabled = not CrownVariables.WeaponOptions.BulletOptions.Enabled
			elseif CrownMenu.ComboBox("Bullet Type", CrownVariables.WeaponOptions.BulletOptions.Bullets, CrownVariables.WeaponOptions.BulletOptions.CurrentBullet, function(currentIndex)
				CrownVariables.WeaponOptions.BulletOptions.CurrentBullet = currentIndex
				if CrownVariables.WeaponOptions.BulletOptions.CurrentBullet == 1 then
					CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName = "WEAPON_REVOLVER"
				elseif CrownVariables.WeaponOptions.BulletOptions.CurrentBullet == 2 then
					CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName = "WEAPON_HEAVYSNIPER"
				elseif CrownVariables.WeaponOptions.BulletOptions.CurrentBullet == 3 then
					CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName = "WEAPON_RPG"
				elseif CrownVariables.WeaponOptions.BulletOptions.CurrentBullet == 4 then
					CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName = "WEAPON_FIREWORK"
				elseif CrownVariables.WeaponOptions.BulletOptions.CurrentBullet == 5 then
					CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName = "WEAPON_RAYPISTOL"
				end
			end) then
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('weaponaimbotsettings') then
			if CrownMenu.CheckBox("Aimbot", CrownVariables.WeaponOptions.AimBot.Enabled) then
				CrownVariables.WeaponOptions.AimBot.Enabled = not CrownVariables.WeaponOptions.AimBot.Enabled
				if not CrownVariables.WeaponOptions.AimBot.Enabled then
					SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, false)
				end
			elseif CrownMenu.CheckBox("Through Walls", CrownVariables.WeaponOptions.AimBot.ThroughWalls) then
				CrownVariables.WeaponOptions.AimBot.ThroughWalls = not CrownVariables.WeaponOptions.AimBot.ThroughWalls
			elseif CrownMenu.CheckBox("Draw FOV", CrownVariables.WeaponOptions.AimBot.DrawFOV) then
				CrownVariables.WeaponOptions.AimBot.DrawFOV = not CrownVariables.WeaponOptions.AimBot.DrawFOV
			elseif CrownMenu.CheckBox("Show Target", CrownVariables.WeaponOptions.AimBot.ShowTarget) then
				CrownVariables.WeaponOptions.AimBot.ShowTarget = not CrownVariables.WeaponOptions.AimBot.ShowTarget
			elseif CrownMenu.ValueChanger("FOV", CrownVariables.WeaponOptions.AimBot.FOV, 0.01, {0.02, 1}, function(val)
				CrownVariables.WeaponOptions.AimBot.FOV = val
			end, true) then
			elseif CrownMenu.ValueChanger("Distance", CrownVariables.WeaponOptions.AimBot.Distance, 1, {1, 1000}, function(val)
				CrownVariables.WeaponOptions.AimBot.Distance = val
			end, true) then
			elseif CrownMenu.ValueChanger("Hit Chance", CrownVariables.WeaponOptions.AimBot.HitChance, 1, {0, 100}, function(val)
				CrownVariables.WeaponOptions.AimBot.HitChance = val
			end, true) then
			elseif CrownMenu.ComboBox("Bone", CrownVariables.WeaponOptions.AimBot.ComboBox.IndexItems, CrownVariables.WeaponOptions.AimBot.ComboBox.CurIndex, function(currentIndex, selectedIndex)
				CrownVariables.WeaponOptions.AimBot.ComboBox.CurIndex = currentIndex
				CrownVariables.WeaponOptions.AimBot.ComboBox.SelIndex = selectedIndex
				end) then

				if CrownVariables.WeaponOptions.AimBot.ComboBox.CurIndex == 1 then
					CrownVariables.WeaponOptions.AimBot.Bone = "SKEL_HEAD"
				elseif CrownVariables.WeaponOptions.AimBot.ComboBox.CurIndex == 2 then
					CrownVariables.WeaponOptions.AimBot.Bone = "SKEL_ROOT"
				elseif CrownVariables.WeaponOptions.AimBot.ComboBox.CurIndex == 3 then
					CrownVariables.WeaponOptions.AimBot.Bone = "SKEL_PELVIS"
				end

			elseif CrownMenu.CheckBox("Only Target Players", CrownVariables.WeaponOptions.AimBot.OnlyPlayers) then
				CrownVariables.WeaponOptions.AimBot.OnlyPlayers = not CrownVariables.WeaponOptions.AimBot.OnlyPlayers
			elseif CrownMenu.CheckBox("Ignore Friends", CrownVariables.WeaponOptions.AimBot.IgnoreFriends) then
				CrownVariables.WeaponOptions.AimBot.IgnoreFriends = not CrownVariables.WeaponOptions.AimBot.IgnoreFriends
			elseif CrownMenu.CheckBox("Visibility Check", CrownVariables.WeaponOptions.AimBot.InvisibilityCheck, "Only Visible Peds/Players") then
				CrownVariables.WeaponOptions.AimBot.InvisibilityCheck = not CrownVariables.WeaponOptions.AimBot.InvisibilityCheck
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('weaponoptions') then

			if CrownMenu.MenuButton("Weapon List", 'weaponslist') then
			elseif CrownMenu.MenuButton("Aimbot", 'weaponaimbotsettings') then
			elseif CrownMenu.MenuButton("Bullet Options", 'bulletoptions') then
			elseif CrownMenu.Button("Get All Weapons") then
				for i = 1, #allWeapons do
				    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(allWeapons[i]), 9999, false, false)
				end
			elseif CrownMenu.Button("Remove All Weapons") then
				RemoveAllPedWeapons(PlayerPedId(), false)
			elseif CrownMenu.Button("Refill All Ammo") then
				for i = 1, #allWeapons do
					SetAmmoInClip(PlayerPedId(), GetHashKey(allWeapons[i]), 9999)
					SetPedAmmo(PlayerPedId(), GetHashKey(allWeapons[i]), 9999)
				end
            elseif CrownMenu.CheckBox("Infinite Ammo", CrownVariables.WeaponOptions.InfAmmo) then
				CrownVariables.WeaponOptions.InfAmmo = not CrownVariables.WeaponOptions.InfAmmo
            elseif CrownMenu.CheckBox("No Reload", CrownVariables.WeaponOptions.NoReload) then
				CrownVariables.WeaponOptions.NoReload = not CrownVariables.WeaponOptions.NoReload
			elseif CrownMenu.CheckBox("Ragebot", CrownVariables.WeaponOptions.RageBot) then
                CrownVariables.WeaponOptions.RageBot = not CrownVariables.WeaponOptions.RageBot
			elseif CrownMenu.CheckBox("Spinbot", CrownVariables.WeaponOptions.Spinbot) then
				CrownVariables.WeaponOptions.Spinbot = not CrownVariables.WeaponOptions.Spinbot
            elseif CrownMenu.CheckBox("Rapid Fire", CrownVariables.WeaponOptions.RapidFire) then
				CrownVariables.WeaponOptions.RapidFire = not CrownVariables.WeaponOptions.RapidFire
			elseif CrownMenu.CheckBox("Trigger Bot", CrownVariables.WeaponOptions.TriggerBot) then
				CrownVariables.WeaponOptions.TriggerBot = not CrownVariables.WeaponOptions.TriggerBot
            elseif CrownMenu.CheckBox("Crosshair", CrownVariables.WeaponOptions.Crosshair) then
				CrownVariables.WeaponOptions.Crosshair = not CrownVariables.WeaponOptions.Crosshair
            elseif CrownMenu.CheckBox("Bullet Tracers", CrownVariables.WeaponOptions.Tracers) then
				CrownVariables.WeaponOptions.Tracers = not CrownVariables.WeaponOptions.Tracers
				if not CrownVariables.WeaponOptions.Tracers then
					BulletCoords = {}
				end
            elseif CrownMenu.CheckBox("No Recoil", CrownVariables.WeaponOptions.NoRecoil) then
				CrownVariables.WeaponOptions.NoRecoil = not CrownVariables.WeaponOptions.NoRecoil
			elseif CrownMenu.CheckBox("Force Mod", CrownVariables.WeaponOptions.MagnetoMode) then
				CrownVariables.WeaponOptions.MagnetoMode = not CrownVariables.WeaponOptions.MagnetoMode
				ForceMod(CrownVariables.WeaponOptions.MagnetoMode)
			elseif CrownMenu.CheckBox("Explosive Ammo", CrownVariables.WeaponOptions.ExplosiveAmmo) then
				if AntiCheats.WaveSheild or AntiCheats.BadgerAC or AntiCheats.TigoAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then  
					SafeModeNotification()
				else
				    CrownVariables.WeaponOptions.ExplosiveAmmo = not CrownVariables.WeaponOptions.ExplosiveAmmo
				end
			elseif CrownMenu.CheckBox("Del Gun", CrownVariables.WeaponOptions.DelGun) then
				CrownVariables.WeaponOptions.DelGun = not CrownVariables.WeaponOptions.DelGun
			elseif CrownMenu.CheckBox("One Shot", CrownVariables.WeaponOptions.OneShot) then
				if SafeMode then
                    SafeModeNotification()
				else
					CrownVariables.WeaponOptions.OneShot = not CrownVariables.WeaponOptions.OneShot
				end
			end

			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('espoptions') then

			if CrownMenu.CheckBox("ESP RGB Sync", CrownVariables.MiscOptions.ESPMenuColours) then
				CrownVariables.MiscOptions.ESPMenuColours = not CrownVariables.MiscOptions.ESPMenuColours
			elseif CrownMenu.ValueChanger("ESP Distance", CrownVariables.MiscOptions.ESPDistance, 1, {100, 5000}, function(val)
				CrownVariables.MiscOptions.ESPDistance = val
			end, true) then
			elseif CrownMenu.CheckBox("ESP Lines", CrownVariables.MiscOptions.ESPLines) then
				CrownVariables.MiscOptions.ESPLines = not CrownVariables.MiscOptions.ESPLines 
			--[[
			elseif CrownMenu.CheckBox("ESP Player Bones", CrownVariables.MiscOptions.ESPBones) then
				CrownVariables.MiscOptions.ESPBones = not CrownVariables.MiscOptions.ESPBones 
				if not CrownVariables.MiscOptions.ESPBones then
					local playerlist = GetActivePlayers()
					for i = 1, #playerlist do
						local curplayer = playerlist[i]
						local curplayerped = GetPlayerPed(curplayer)
		
						ResetEntityAlpha(curplayerped)
					end
				end
			]]

			elseif CrownMenu.CheckBox("ESP Boxes", CrownVariables.MiscOptions.ESPBox) then
				CrownVariables.MiscOptions.ESPBox = not CrownVariables.MiscOptions.ESPBox 
			elseif CrownMenu.CheckBox("ESP Blips", CrownVariables.MiscOptions.ESPBlips) then
				CrownVariables.MiscOptions.ESPBlips = not CrownVariables.MiscOptions.ESPBlips 
				PlayerBlips()
			elseif CrownMenu.CheckBox("ESP Player Info", CrownVariables.MiscOptions.ESPName) then
				CrownVariables.MiscOptions.ESPName = not CrownVariables.MiscOptions.ESPName 
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('serveroptions') then

			if CrownMenu.Button("Server IP: " ..GetCurrentServerEndpoint()) then
			elseif CrownMenu.CheckBox("GLife Method", CrownVariables.MiscOptions.GlifeHack) then
				CrownVariables.MiscOptions.GlifeHack = not CrownVariables.MiscOptions.GlifeHack
			elseif CrownMenu.CheckBox("Make All Vehicles Fly", CrownVariables.MiscOptions.FlyingCars) then
				CrownVariables.MiscOptions.FlyingCars = not CrownVariables.MiscOptions.FlyingCars
			elseif CrownMenu.Button("Teleport All Peds 100ft above Self") then
				for ped in EnumeratePeds() do
					if IsPedAPlayer(ped) ~= true and ped ~= PlayerPedId() then
						RequestControlOnce(ped)
						SetPedToRagdoll(ped, 4000, 5000, 0, true, true, true)
						local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
						SetEntityCoords(ped, x, y, z + 100.0)
					end
				end
			elseif CrownMenu.Button("Kill All Peds") then
				for ped in EnumeratePeds() do
					if IsPedAPlayer(ped) ~= true and ped ~= PlayerPedId() then
						RequestControlOnce(ped)
						SetEntityHealth(ped, 0)
					end
				end
			elseif CrownMenu.Button("Ramp All Vehicles") then
				RampAllCars()
			elseif CrownMenu.Button("FIB Building All Vehicles") then
				for vehicle in EnumerateVehicles() do
					local building = CreateObject(-1404869155, 0, 0, 0, true, true, true)
					NetworkRequestControlOfEntity(vehicle)
					if DoesEntityExist(vehicle) then
						AttachEntityToEntity(building, vehicle, 0, 0, 0.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
					end
					NetworkRequestControlOfEntity(building)
					SetEntityAsMissionEntity(building, true, true)
				end
			elseif CrownMenu.CheckBox("Unlock All Vehicles", CrownVariables.MiscOptions.UnlockAllVehicles, "I locked my car WTF") then
				CrownVariables.MiscOptions.UnlockAllVehicles = not CrownVariables.MiscOptions.UnlockAllVehicles
			elseif CrownMenu.Button("Spam Server Chat") then

				if AntiCheats.WaveSheild or AntiCheats.ChocoHax or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					SpamServerChat()
				end
				
			elseif CrownMenu.CheckBox("Spam Server Chat ~r~Loop", CrownVariables.MiscOptions.SpamServerChat, "Will Freeze Servers Chat") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					CrownVariables.MiscOptions.SpamServerChat = not CrownVariables.MiscOptions.SpamServerChat
					SpamServerChatLoop()
					if not CrownVariables.MiscOptions.SpamServerChat then
						PushNotification("Spammed Servers Chat " ..tostring(mocks).. " times", 500)
						mocks = 0
					end
				end

			elseif CrownMenu.Button("Clear Chat For Self") then
				TriggerEvent("chat:clear")
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('scriptoptions') then
		    if CrownMenu.CheckBox('Crouch Script', CrownVariables.ScriptOptions.script_crouch) then
				CrownVariables.ScriptOptions.script_crouch = not CrownVariables.ScriptOptions.script_crouch
				if CrownVariables.ScriptOptions.script_crouch then
					PushNotification("Crouch Script has Been ~g~Enabled", 600)
					CrouchScript()
				else
					PushNotification("Crouch Script has Been ~r~Disabled", 600)
					ResetPedMovementClipset(PlayerPedId(), 1.0)
				end
			elseif CrownMenu.CheckBox('Screenshot-basic Bypass', CrownVariables.ScriptOptions.SSBBypass) then
				CrownVariables.ScriptOptions.SSBBypass = not CrownVariables.ScriptOptions.SSBBypass
				ScreenshotBasicBypass()
			elseif CrownMenu.CheckBox("GGAC Bypass", CrownVariables.ScriptOptions.GGACBypass) then
				CrownVariables.ScriptOptions.GGACBypass = not CrownVariables.ScriptOptions.GGACBypass
				if CrownVariables.ScriptOptions.GGACBypass then
					GGACBypass()
                    PushNotification("GGAC Bypass has been ~g~Enabled", 1000)
                    PushNotification("Just Stop the resource :)", 1000)
				end
			elseif CrownMenu.CheckBox("Open Vaults Script", CrownVariables.ScriptOptions.vault_doors) then
				CrownVariables.ScriptOptions.vault_doors = not CrownVariables.ScriptOptions.vault_doors
				if CrownVariables.ScriptOptions.vault_doors then
					PushNotification("Open Vault Doors Script has Been ~g~Enabled", 600)
					VaultDoors()
				else
					PushNotification("Open Vault Doors Script has Been ~r~Disabled", 600)
				end
			elseif CrownMenu.CheckBox("Block Being Taken Hostage", CrownVariables.ScriptOptions.blocktakehostage) then
				CrownVariables.ScriptOptions.blocktakehostage = not CrownVariables.ScriptOptions.blocktakehostage
			elseif CrownMenu.CheckBox("Block Black Screen", CrownVariables.ScriptOptions.BlockBlackScreen) then
				CrownVariables.ScriptOptions.BlockBlackScreen = not CrownVariables.ScriptOptions.BlockBlackScreen
			elseif CrownMenu.CheckBox("Block Being Carried", CrownVariables.ScriptOptions.blockbeingcarried) then
				CrownVariables.ScriptOptions.blockbeingcarried = not CrownVariables.ScriptOptions.blockbeingcarried
			elseif CrownMenu.CheckBox("Block Peacetime", CrownVariables.ScriptOptions.BlockPeacetime) then
				CrownVariables.ScriptOptions.BlockPeacetime = not CrownVariables.ScriptOptions.BlockPeacetime
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('hudoptions') then
			if CrownMenu.Button("Reset Hud Colour", "") then 
				ReplaceHudColourWithRgba(116, 45, 110, 185, 255)
			elseif CrownMenu.Button("Set Hud Colour Red", "") then 
				ReplaceHudColourWithRgba(116, 255, 0, 0, 255)
			elseif CrownMenu.Button("Set Hud Colour Ornage", "") then 
				ReplaceHudColourWithRgba(116, 255, 77, 0, 255)
			elseif CrownMenu.Button("Set Hud Colour Yellow", "") then 
				ReplaceHudColourWithRgba(116, 255, 255, 00, 255)
			elseif CrownMenu.Button("Set Hud Colour Green", "") then 
				ReplaceHudColourWithRgba(116, 0, 255, 102, 255)
			elseif CrownMenu.Button("Set Hud Colour Blue", "") then 
				ReplaceHudColourWithRgba(116, 0, 204, 255, 255)
			elseif CrownMenu.Button("Set Hud Colour Purple", "") then 
				ReplaceHudColourWithRgba(116, 162, 0, 255, 255)
			elseif CrownMenu.Button("Set Hud Colour Pink", "") then 
				ReplaceHudColourWithRgba(116, 255, 0, 234, 255)
			elseif CrownMenu.CheckBox("Set Hud RGB Cycle", rgbhud) then
			    rgbhud = not rgbhud
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('weatheroptions') then
			
			if CrownMenu.Button("Extra Sunny Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("EXTRASUNNY")
				SetOverrideWeather("EXTRASUNNY")
				SetWeatherTypeNowPersist("EXTRASUNNY")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Clear Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("CLEAR")
				SetOverrideWeather("CLEAR")
				SetWeatherTypeNowPersist("CLEAR")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Cloudy Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("CLOUDS")
				SetOverrideWeather("CLOUDS")
				SetWeatherTypeNowPersist("CLOUDS")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Overcast Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("OVERCAST")
				SetOverrideWeather("OVERCAST")
				SetWeatherTypeNowPersist("OVERCAST")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Rainy Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("RAIN")
				SetOverrideWeather("RAIN")
				SetWeatherTypeNowPersist("RAIN")
				SetRainLevel(10.0)
			elseif CrownMenu.Button("Clearing Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("CLEARING")
				SetOverrideWeather("CLEARING")
				SetWeatherTypeNowPersist("CLEARING")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Thunder Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("THUNDER")
				SetOverrideWeather("THUNDER")
				SetWeatherTypeNowPersist("THUNDER")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Smog Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("SMOG")
				SetOverrideWeather("SMOG")
				SetWeatherTypeNowPersist("SMOG")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Foggy Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("FOGGY")
				SetOverrideWeather("FOGGY")
				SetWeatherTypeNowPersist("FOGGY")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Christmas Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("XMAS")
				SetOverrideWeather("XMAS")
				SetWeatherTypeNowPersist("XMAS")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Snowlight Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("SNOWLIGHT")
				SetOverrideWeather("SNOWLIGHT")
				SetWeatherTypeNowPersist("SNOWLIGHT")
				SetRainLevel(0.0)
			elseif CrownMenu.Button("Blizzard Weather", "") then 
				ClearOverrideWeather()
				ClearWeatherTypePersist()
				SetWeatherTypeNow("BLIZZARD")
				SetOverrideWeather("BLIZZARD")
				SetWeatherTypeNowPersist("BLIZZARD")
				SetRainLevel(0.0)
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('timeoptions') then
			if CrownMenu.Button("Set Time to 9:00", "") then 

				SetClockTime(9, 0, 0)
				NetworkOverrideClockTime(9, 0, 0)

			elseif CrownMenu.Button("Set Time to 12:00", "") then 
	
				SetClockTime(12, 0, 0)
				NetworkOverrideClockTime(12, 0, 0)

			elseif CrownMenu.Button("Set Time to 15:00", "") then 
		
				SetClockTime(15, 0, 0)
				NetworkOverrideClockTime(15, 0, 0)
	
			elseif CrownMenu.Button("Set Time to 18:00", "") then 
		
				SetClockTime(18, 0, 0)
				NetworkOverrideClockTime(18, 0, 0)
				
			elseif CrownMenu.Button("Set Time to 21:00", "") then 
		
				SetClockTime(21, 0, 0)
				NetworkOverrideClockTime(21, 0, 0)

			elseif CrownMenu.Button("Set Time to 00:00", "") then 
		
				SetClockTime(0, 0, 0)
				NetworkOverrideClockTime(0, 0, 0)

			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('miscellaneousoptions') then
			if CrownMenu.MenuButton('Anticheat Options', 'anticheatdetections', "Check what Anticheat the Server has") then
			elseif CrownMenu.MenuButton('Server Options', 'serveroptions', "Options to Destroy The Server") then
			elseif CrownMenu.MenuButton('ESP Options', 'espoptions', "ESP Options For All Players") then
			elseif CrownMenu.MenuButton("Hud Options", 'hudoptions', "Change the Color of the weapon wheel") then
			elseif CrownMenu.MenuButton("Script Options", 'scriptoptions', "Crouch Script, Bypass Vehicle Blacklist") then
			elseif CrownMenu.CheckBox("North Yankton", northyankton) then
				northyankton = not northyankton
				if northyankton then
					LoadMpDlcMaps()
					EnableMpDlcMaps(true)
					RequestIpl("FIBlobbyfake")
					RequestIpl("DT1_03_Gr_Closed")
					RequestIpl("v_tunnel_hole")
					RequestIpl("TrevorsMP")
					RequestIpl("TrevorsTrailer")
					RequestIpl("farm")
					RequestIpl("farmint")
					RequestIpl("farmint_cap")
					RequestIpl("farm_props")
					RequestIpl("CS1_02_cf_offmission")
					RequestIpl("prologue01")
					RequestIpl("prologue01c")
					RequestIpl("prologue01d")
					RequestIpl("prologue01e")
					RequestIpl("prologue01f")
					RequestIpl("prologue01g")
					RequestIpl("prologue01h")
					RequestIpl("prologue01i")
					RequestIpl("prologue01j")
					RequestIpl("prologue01k")
					RequestIpl("prologue01z")
					RequestIpl("prologue02")
					RequestIpl("prologue03")
					RequestIpl("prologue03b")
					RequestIpl("prologue04")
					RequestIpl("prologue04b")
					RequestIpl("prologue05")
					RequestIpl("prologue05b")
					RequestIpl("prologue06")
					RequestIpl("prologue06b")
					RequestIpl("prologue06_int")
					RequestIpl("prologuerd")
					RequestIpl("prologuerdb ")
					RequestIpl("prologue_DistantLights")
					RequestIpl("prologue_LODLights")
					RequestIpl("prologue_m2_door")  
				else
					LoadMpDlcMaps()
					EnableMpDlcMaps(false)
					RemoveIpl("FIBlobbyfake")
					RemoveIpl("DT1_03_Gr_Closed")
					RemoveIpl("v_tunnel_hole")
					RemoveIpl("TrevorsMP")
					RemoveIpl("TrevorsTrailer")
					RemoveIpl("farm")
					RemoveIpl("farmint")
					RemoveIpl("farmint_cap")
					RemoveIpl("farm_props")
					RemoveIpl("CS1_02_cf_offmission")
					RemoveIpl("prologue01")
					RemoveIpl("prologue01c")
					RemoveIpl("prologue01d")
					RemoveIpl("prologue01e")
					RemoveIpl("prologue01f")
					RemoveIpl("prologue01g")
					RemoveIpl("prologue01h")
					RemoveIpl("prologue01i")
					RemoveIpl("prologue01j")
					RemoveIpl("prologue01k")
					RemoveIpl("prologue01z")
					RemoveIpl("prologue02")
					RemoveIpl("prologue03")
					RemoveIpl("prologue03b")
					RemoveIpl("prologue04")
					RemoveIpl("prologue04b")
					RemoveIpl("prologue05")
					RemoveIpl("prologue05b")
					RemoveIpl("prologue06b")
					RemoveIpl("prologue06_int")
					RemoveIpl("prologuerd")
					RemoveIpl("prologuerdb ")
					RemoveIpl("prologue_DistantLights")
					RemoveIpl("prologue_LODLights")
					RemoveIpl("prologue_m2_door") 
				end
			elseif disabled and CrownMenu.Button("Execute Lua") then
				local stringToRun = CrownMenu.KeyboardEntry("Lua Executor", 200)
				ExecuteLuaCode(stringToRun)
			elseif CrownMenu.Button("Quit Game", "", "Close FiveM") then
				result = CrownMenu.KeyboardEntry("Exit Game? Type Yes/No", 200)
				if string.lower(result) == "yes" then
					RestartGame()
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('anticheatdetections') then

			if CrownMenu.CheckBox("Safe Mode", SafeMode, "~g~NEW! ~s~Avoids All Detections") then
				SafeMode = not SafeMode
			elseif CrownMenu.CheckBox("ChocoHax", AntiCheats.ChocoHax) then
				AntiCheats.ChocoHax = not AntiCheats.ChocoHax
			elseif CrownMenu.CheckBox("Wave Sheild", AntiCheats.WaveSheild) then
				AntiCheats.WaveSheild = not AntiCheats.WaveSheild
			elseif CrownMenu.CheckBox("Badger Anticheat", AntiCheats.BadgerAC) then
				AntiCheats.BadgerAC = not AntiCheats.BadgerAC
			elseif CrownMenu.CheckBox("Tigo Anticheat", AntiCheats.TigoAC) then
				AntiCheats.TigoAC = not AntiCheats.TigoAC
			elseif CrownMenu.CheckBox("VAC", AntiCheats.VAC) then
				AntiCheats.VAC = not AntiCheats.VAC
			elseif CrownMenu.Button("Disable Anticheese") then
				DisableAnticheat("anticheese")
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('triggerevents') then
			if CrownMenu.Button("Vehicle Whitelist Bypass", "", false, "Works On Most Servers") then
			    TriggerEvent("FaxDisVeh:CheckPermission:Return", true, false)
				for i = 0, 20 do
					TriggerEvent("FaxDisVeh:CheckPermission:Return", i, false)
				end
				TriggerEvent("blacklist.setAdminPermissions", true)
			elseif CrownMenu.Button("Set Current AOP", "~g~Client") then
				local aop = CrownMenu.KeyboardEntry("Enter New AOP", 200)
				TriggerEvent("AOP:SendAOP", aop)
				TriggerEvent("yodaaop:sync_cl", aop)
				TriggerEvent("activeAOP:SyncAOPName", aop)
			elseif CrownMenu.Button("Unjail Self", "~g~Client", nil, "Works On Most Non-ESX/VRP servers") then
				TriggerEvent("SEM_InteractionMenu:UnjailPlayer")
				TriggerEvent("UnJP")
			elseif CrownMenu.Button("Un Hospitalize Self", "~g~Client", nil, "Works On Servers With SEM Interaction Menu") then
				TriggerEvent("SEM_InteractionMenu:UnhospitalizePlayer")
			elseif CrownMenu.Button("Toggle Cuffs", "~g~SEM", nil, "Works On Servers With SEM Interaction Menu") then
				TriggerEvent("SEM_InteractionMenu:Cuff")
			elseif CrownMenu.Button("Toggle Drag", "~g~SEM", nil, "Works On Servers With SEM Interaction Menu") then
				TriggerEvent(CrownMenu.DynamicTriggers.Triggers['DragSEM'])
			elseif CrownMenu.Button("Police Backup Spam", "~g~SEM", nil, "Works On Servers With SEM Interaction Menu") then
				TriggerServerEvent("SEM_InteractionMenu:Backup", math.random(1, 3), "Crown Menu On Top - discord.gg/DXQvMEzKSd\n" ..math.random(1, 1000))
			elseif CrownMenu.Button("Spam Chat", "~g~SEM") then
				local rand = 1
				for i = 1, 20 do
					colourslist = {'^1', '^2', '^3', '^4' , '^5', '^6', '^7', '^8', '^9'}
					
					local colour = colourslist[rand]
				
					if rand >= 9 then
						rand = 1
					else
						rand = rand + 1 
					end 
				
				    TriggerServerEvent("SEM_InteractionMenu:GlobalChat", {0,0,0}, colour .. "Crown Menu", colour .. "discord.gg/DXQvMEzKSd | Enjoy Monkeys")
				end
			end
			
			if CrownMenu.DynamicTriggers.Triggers['ESXHandcuff'] ~= nil and CrownMenu.Button("Toggle Cuffs", "~g~ESX", nil, "Works On Servers With ESX") then
				TriggerEvent(CrownMenu.DynamicTriggers.Triggers['ESXHandcuff'])
			elseif CrownMenu.DynamicTriggers.Triggers['ESXDrag'] ~= nil and CrownMenu.Button("Toggle Drag", "~g~ESX", nil, "Works On Servers With ESX") then
				TriggerEvent(CrownMenu.DynamicTriggers.Triggers['ESXDrag'])
			elseif CrownMenu.DynamicTriggers.Triggers['ESXVangelicoRobbery'] ~= nil and CrownMenu.Button("Vangelico Robbery", "~g~ESX", nil, "Works On Servers With ESX") then
				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['ESXVangelicoRobbery'], 1)	
			end
			

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('triggereventsallplayeroptions') then
			
			if CrownMenu.Button("Carry All Players", "~y~Server") then
				local player = PlayerPedId()	
				lib = 'missfinale_c2mcs_1'
				anim1 = 'fin_c2_mcs_1_camman'
				lib2 = 'nm'
				anim2 = 'firemans_carry'
				distans = 0.15
				distans2 = 0.27
				height = 0.63
				spin = 0.0		
				length = 100000
				controlFlagMe = 49
				controlFlagTarget = 33
				animFlagTarget = 1

				ActivePlayers = GetActivePlayers()
				
				carryingBackInProgress = true

				for i = 1, #ActivePlayers do
					if CrownVariables.AllOnlinePlayers.IncludeSelf and ActivePlayers[i] ~= PlayerId() then
						TriggerServerEvent('CarryPeople:sync', GetPlayerServerId(ActivePlayers[i]), lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
					elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
						TriggerServerEvent('CarryPeople:sync', GetPlayerServerId(ActivePlayers[i]), lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
					end
				end

			elseif CrownMenu.Button("Take All Players Hostage", "~y~Server") then
				lib = 'anim@gangops@hostage@'
				anim1 = 'perp_idle'
				lib2 = 'anim@gangops@hostage@'
				anim2 = 'victim_idle'
				distans = 0.11 --Higher = closer to camera
				distans2 = -0.24 --higher = left
				height = 0.0
				spin = 0.0		
				length = 100000
				controlFlagMe = 49
				controlFlagTarget = 49
				animFlagTarget = 50
				attachFlag = true 
				PlayerList = GetActivePlayers()

				for i = 1, #PlayerList do
					if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
						TriggerServerEvent('CarryPeople:sync', GetPlayerServerId(PlayerList[i]), lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
					elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
						TriggerServerEvent('CarryPeople:sync', GetPlayerServerId(PlayerList[i]), lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
					end
				end

			elseif CrownMenu.ComboBox("Task All Players to", CrownVariables.AllOnlinePlayers.DPEmotes, CrownVariables.AllOnlinePlayers.CurrentEmote, function(currentIndex, selectedIndex)
				CrownVariables.AllOnlinePlayers.CurrentEmote = currentIndex
			    end) then

					PlayerList = GetActivePlayers()
				
					for i = 1, #PlayerList do
						TriggerServerEvent("ServerValidEmote", GetPlayerServerId(PlayerList[i]), CrownVariables.AllOnlinePlayers.DPEmotes[CrownVariables.AllOnlinePlayers.CurrentEmote])	
					end

			elseif CrownMenu.DynamicTriggers.Triggers['TacklePlayer'] ~= nil and CrownMenu.Button("Tackle All Players", "~y~Server") then
				ActivePlayers = GetActivePlayers()
				
				for i = 1, #ActivePlayers do
					if CrownVariables.AllOnlinePlayers.IncludeSelf and ActivePlayers[i] ~= PlayerId() then
						TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['TacklePlayer'], GetPlayerServerId(ActivePlayers[i]))
					elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
						TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['TacklePlayer'], GetPlayerServerId(ActivePlayers[i]))
					end
				end
			elseif CrownMenu.DynamicTriggers.Triggers['JailSEM'] ~= nil and CrownMenu.Button("Jail All Players", "~y~SEM") then
				Citizen.CreateThread(function()
					PlayerList = GetActivePlayers()
					for i = 1, #PlayerList do
						Wait(10)
						if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
							TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['JailSEM'], GetPlayerServerId(PlayerList[i]), math.huge)
						elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
							TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['JailSEM'], GetPlayerServerId(PlayerList[i]), math.huge)
						end
					end
			   end)
				elseif CrownMenu.Button("Drag All Players", "~y~SEM") then
					Citizen.CreateThread(function()
						PlayerList = GetActivePlayers()
						for i = 1, #PlayerList do
							Wait(10)
							if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
								TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['DragSEM'], GetPlayerServerId(PlayerList[i]))
							elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
								TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['DragSEM'], GetPlayerServerId(PlayerList[i]))
							end
						end
				   end)
				elseif CrownMenu.Button("Unjail All Players", "~y~SEM") then
					Citizen.CreateThread(function()
						PlayerList = GetActivePlayers()
						for i = 1, #PlayerList do
							Wait(10)
							if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
								TriggerServerEvent("SEM_InteractionMenu:Unjail", GetPlayerServerId(PlayerList[i]))
							elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
								TriggerServerEvent("SEM_InteractionMenu:Unjail", GetPlayerServerId(PlayerList[i]))
							end
						end
				   end)
				elseif CrownMenu.Button("Fake Chat Message All Players", "~y~SEM") then
					message = CrownMenu.KeyboardEntry("Enter Fake Message", 200)
					Citizen.CreateThread(function()
						PlayerList = GetActivePlayers()
						for i = 1, #PlayerList do
							Wait(10)
							TriggerServerEvent("SEM_InteractionMenu:GlobalChat", {255, 255, 255}, GetPlayerName(PlayerList[i]), message)
						end
				   end)
				   
				elseif CrownMenu.Button("Cuff All Players", "~y~SEM") then
					Citizen.CreateThread(function()
						PlayerList = GetActivePlayers()
						for i = 1, #PlayerList do
							Wait(10)
							if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
								TriggerServerEvent("SEM_InteractionMenu:CuffNear", GetPlayerServerId(PlayerList[i]))
							elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
								TriggerServerEvent("SEM_InteractionMenu:CuffNear", GetPlayerServerId(PlayerList[i]))
							end
						end
				   end)
				elseif CrownMenu.Button("Send Fake Message All Players", "~y~Server") then
					if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
						PushNotification("Anticheat Detected! Function Blocked", 600)
					else
						local result = CrownMenu.KeyboardEntry("Send Fake Chat Message All Players", 200)
						if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
							PushNotification("Anticheat Detected! Function Blocked", 600)
						else
							local playerlist = GetActivePlayers()
						
							for i = 1, #playerlist do
								Wait(0)
								local playername = playerlist[i]
								if msg == "" then
						
								else
									TriggerServerEvent("_chat:messageEntered", GetPlayerName(playername), { 255, 255, 255 }, msg)
								end
							end
						end
				    end
				end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('particleeffectsallplayeroptions') then
			if CrownMenu.CheckBox("Huge Explosion FX Spam", CrownVariables.AllOnlinePlayers.ParicleEffects.HugeExplosionSpam) then
			    CrownVariables.AllOnlinePlayers.ParicleEffects.HugeExplosionSpam = not CrownVariables.AllOnlinePlayers.ParicleEffects.HugeExplosionSpam
		    elseif CrownMenu.CheckBox("Clown Appears FX Spam", CrownVariables.AllOnlinePlayers.ParicleEffects.ClownLoop) then
			    CrownVariables.AllOnlinePlayers.ParicleEffects.ClownLoop = not CrownVariables.AllOnlinePlayers.ParicleEffects.ClownLoop
			elseif CrownMenu.CheckBox("Blood FX Spam", CrownVariables.AllOnlinePlayers.ParicleEffects.BloodLoop) then
			    CrownVariables.AllOnlinePlayers.ParicleEffects.BloodLoop = not CrownVariables.AllOnlinePlayers.ParicleEffects.BloodLoop
			elseif CrownMenu.CheckBox("Fireworks FX Spam", CrownVariables.AllOnlinePlayers.ParicleEffects.FireworksLoop) then
			    CrownVariables.AllOnlinePlayers.ParicleEffects.FireworksLoop = not CrownVariables.AllOnlinePlayers.ParicleEffects.FireworksLoop
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('attachpropsallplayeroptions') then
			
			if CrownMenu.Button("Attach Ball to Everyone", "~y~Native") then
				RequestModel(GetHashKey('prop_juicestand'))
				local time = 0
				while not HasModelLoaded(GetHashKey('prop_juicestand')) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break
					end
			
					plist = GetActivePlayers()
					for i = 1, #plist do
						local ped = GetPlayerPed(plist[i])
						local x, y, z = table.unpack(GetEntityCoords(ped, true))
						local CreatedObject = CreateObject(GetHashKey('prop_juicestand'), x, y, z, true, true, false)
						AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 0), 0, 0, 0, 0, 90, 0, false, false, false, false, 2, true)
					end
				end
				
			elseif CrownMenu.Button("Slit All Players Wrist", "~y~Native") then

				RequestModel(GetHashKey('prop_knife'))
				local time = 0
				while not HasModelLoaded(GetHashKey('prop_knife')) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break
					end
					
					plist = GetActivePlayers()
					for i = 1, #plist do
						local ped = GetPlayerPed(plist[i])
						local x, y, z = table.unpack(GetEntityCoords(ped, true))
						local CreatedObject = CreateObject(GetHashKey('prop_knife'), x, y, z, true, true, false)
						AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 6286), 0, 0, 0, 0, 90, 0, false, false, false, false, 2, true)
						local CreatedObject2 = CreateObject(GetHashKey('p_bloodsplat_s'), x, y, z, true, true, false)
						AttachEntityToEntity(CreatedObject2, ped, GetPedBoneIndex(ped, 6286), 0, 0, 0, 0, 90, 0, false, false, false, false, 2, true)
					end
				end
				
			elseif CrownMenu.Button("Ramp All Players", "~y~Native") then
				AllPlayersAreARamp()
			elseif CrownMenu.Button("Dildo Server", "~y~Native", "15 Dildos on All Players") then
                DildosServer()
			elseif CrownMenu.Button("Gas All Players", "~y~Native") then
				local object = GetHashKey('prop_gas_05')
				RequestModel(object)
				local time = 0

				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break
					end
				end
				
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true)
				end
				
			elseif CrownMenu.Button("Attach Dog lead to Neck", "~y~Native") then
				local object = GetHashKey('prop_cs_dog_lead_2a')
				RequestModel(object)
				local time = 0

				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break
					end
				end
				
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 47495), 0, 0, 0, 0, 90, 0, false, false, false, false, 2, true)
				end						
		
			elseif CrownMenu.Button("Dog Sign All Players", "~y~Native") then
				local object = GetHashKey('prop_beware_dog_sign')
				RequestModel(object)
				local time = 0
				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break
					end
				end
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true) 
				end
			elseif CrownMenu.Button("Crashed Heli", "~y~Native") then
				local object = GetHashKey('p_crahsed_heli_s')
				RequestModel(object)
				local time = 0
				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break 
					end
				end
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true) 
				end
			elseif CrownMenu.Button("Air Dancer All Players", "~y~Native") then
				local object = GetHashKey('p_airdancer_01_s')
				RequestModel(object)
				local time = 0
				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break 
					end
				end
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true) 
				end
			elseif CrownMenu.Button("Sex Doll All Players", "~y~Native") then
				local object = GetHashKey('prop_bikini_disp_03')
				RequestModel(object)
				local time = 0
				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break 
					end
				end
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true) 			
				end
			elseif CrownMenu.Button("Car Rack All Players", "~y~Native") then
				local object = GetHashKey('imp_prop_impexp_half_cut_rack_01b')
				RequestModel(object)
				local time = 0
				while not HasModelLoaded(object) do
					time = time + 100.0
					Citizen.Wait(100.0)
					if time > 5000 then
						print("Could not load model!")
						break 
					end
				end
				plist = GetActivePlayers()
				for i = 1, #plist do
					local ped = GetPlayerPed(plist[i])
					local x, y, z = table.unpack(GetEntityCoords(ped, true))
					local CreatedObject = CreateObject(object, x, y, z, true, true, false)
					AttachEntityToEntity(CreatedObject, ped, GetPedBoneIndex(ped, 17719), 10, 0, 0, 0, 110, 90, false, false, false, false, 2, true) 			
				end
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('allplayeroptions') then

			if CrownMenu.MenuButton("Particle Effects", "particleeffectsallplayeroptions") then
			elseif CrownMenu.MenuButton("Prop Options", "attachpropsallplayeroptions") then
			elseif CrownMenu.MenuButton("Trigger Events", "triggereventsallplayeroptions") then
			elseif CrownMenu.CheckBox("Include Self", not CrownVariables.AllOnlinePlayers.IncludeSelf) then
				CrownVariables.AllOnlinePlayers.IncludeSelf = not CrownVariables.AllOnlinePlayers.IncludeSelf
			elseif CrownMenu.Button("Explode All Players", "~y~Native") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					ExplosionAllPlayers()
				end
			elseif CrownMenu.CheckBox("Explode All Players Loop", CrownVariables.AllOnlinePlayers.ExplodisionLoop) then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					CrownVariables.AllOnlinePlayers.ExplodisionLoop = not CrownVariables.AllOnlinePlayers.ExplodisionLoop
					NativeExplosionServerLoop()
				end
			elseif CrownMenu.Button("Give All Players Weapons", "~y~Risky") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					playerlist = GetActivePlayers()
					for i = 1, #playerlist do

						if CrownVariables.AllOnlinePlayers.IncludeSelf and playerlist[i] ~= PlayerId() then
							for i = 1, #allWeapons do
								GiveWeaponToPed(GetPlayerPed(playerlist[i]), GetHashKey(allWeapons[i]), 9999, true, true)
							end
						elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
							for i = 1, #allWeapons do
								GiveWeaponToPed(GetPlayerPed(playerlist[i]), GetHashKey(allWeapons[i]), 9999, true, true)
							end
						end
					end
				end
			elseif CrownMenu.Button("Remove All Players Weapons", "~y~Risky") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					playerlist = GetActivePlayers()
					for i = 1, #playerlist do
						if CrownVariables.AllOnlinePlayers.IncludeSelf and playerlist[i] ~= PlayerId() then
							curPlayer = playerlist[i]
							RemoveAllPedWeapons(GetPlayerPed(curPlayer), true)
							RemoveWeaponFromPed(GetPlayerPed(curPlayer), "WEAPON_UNARMED")
						elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
							curPlayer = playerlist[i]
							RemoveAllPedWeapons(GetPlayerPed(curPlayer), true)
							RemoveWeaponFromPed(GetPlayerPed(curPlayer), "WEAPON_UNARMED")
						end
					end
				end

			elseif CrownMenu.CheckBox("Rain Tug Boats Over Players", CrownVariables.AllOnlinePlayers.tugboatrainoverplayers) then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild  then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					CrownVariables.AllOnlinePlayers.tugboatrainoverplayers = not CrownVariables.AllOnlinePlayers.tugboatrainoverplayers
				end
			elseif CrownMenu.CheckBox("Freeze Server", CrownVariables.AllOnlinePlayers.freezeserver) then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
                    SafeModeNotification()
				else
				    CrownVariables.AllOnlinePlayers.freezeserver = not CrownVariables.AllOnlinePlayers.freezeserver
				end
			elseif CrownMenu.Button("Bus Server", "~y~Native") then
				if AntiCheats.VAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
                    SafeModeNotification()
				else
					BusServer()
				end
			elseif CrownMenu.CheckBox("Bus Server ~r~LOOP", CrownVariables.AllOnlinePlayers.busingserverloop) then

				if AntiCheats.VAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
                    SafeModeNotification()
				else
					CrownVariables.AllOnlinePlayers.busingserverloop = not CrownVariables.AllOnlinePlayers.busingserverloop
					BusServerLoop()
				end

			elseif CrownMenu.Button("Kick All Players From Vehicle", "~y~Native") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
				    KickAllFromVeh()
				end
			elseif CrownMenu.Button("Cargo Plane", "~y~Native") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild  then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					CargoplaneServer()
				end
			elseif CrownMenu.CheckBox("Cargo Plane Server ~r~LOOP", CrownVariables.AllOnlinePlayers.cargoplaneserverloop) then

				if AntiCheats.ChocoHax or AntiCheats.WaveSheild  then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					CrownVariables.AllOnlinePlayers.cargoplaneserverloop = not CrownVariables.AllOnlinePlayers.cargoplaneserverloop
					CargoPlaneServerLoop()
				end

			elseif CrownMenu.Button("Rape All Players", "~y~Native") then
				PlayerList = GetActivePlayers()
				for i = 1, #PlayerList do
					if CrownVariables.AllOnlinePlayers.IncludeSelf and PlayerList[i] ~= PlayerId() then
						CurPlayer = PlayerList[i]
						RapePlayer(CurPlayer)
					elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
						CurPlayer = PlayerList[i]
						RapePlayer(CurPlayer)
					end
				end
			end
			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('onlineplayerlist') then

			if CrownMenu.MenuButton("All Online Players ", 'allplayeroptions', "All Player Options") then
			end

			local playerlist = GetActivePlayers()
			for i = 1, #playerlist do
				local currPlayer = playerlist[i]
	
				local friend = ""

				if TableHasValue(FriendsList, GetPlayerServerId(currPlayer)) then
					friend = "Friend | "
				elseif currPlayer == PlayerId() then
					friend = "Self | "
				end

				if CrownMenu.MenuButton(friend .. GetPlayerServerId(currPlayer) .. " | " .. GetPlayerName(currPlayer), 'selectedonlineplayr', "Options For ".. GetPlayerName(currPlayer)) then
					selectedPlayer = currPlayer 
				end
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('collisionoptions') then
			
			if CrownMenu.CheckBox("Disable Object Collisions", CrownVariables.SelfOptions.disableobjectcollisions, "Might be Glitchy for some Buildings") then
				CrownVariables.SelfOptions.disableobjectcollisions = not CrownVariables.SelfOptions.disableobjectcollisions
				if not CrownVariables.SelfOptions.disableobjectcollisions then
					for door in EnumerateObjects() do
				
						SetEntityCollision(door, true, true)
		
					end
				end
			elseif CrownMenu.CheckBox("Disable Ped Collisions", CrownVariables.SelfOptions.disablepedcollisions, "Peds may fall through the Map") then
				CrownVariables.SelfOptions.disablepedcollisions = not CrownVariables.SelfOptions.disablepedcollisions
				if not CrownVariables.SelfOptions.disablepedcollisions then
					for ped in EnumeratePeds() do
				
						SetEntityCollision(ped, true, true)
		
					end
				end
			elseif CrownMenu.CheckBox("Disable Vehicle Collisions", CrownVariables.SelfOptions.disablevehiclecollisions, "Every single Vehicle won't have Collision") then
				CrownVariables.SelfOptions.disablevehiclecollisions = not CrownVariables.SelfOptions.disablevehiclecollisions
				
				if not CrownVariables.SelfOptions.disablevehiclecollisions then
					for vehicle in EnumerateVehicles() do
						SetEntityCollision(vehicle, true, true)
					end
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('superpowers') then
		
		    if CrownMenu.CheckBox("Anti Headshot", CrownVariables.SelfOptions.AntiHeadshot) then
				CrownVariables.SelfOptions.AntiHeadshot = not CrownVariables.SelfOptions.AntiHeadshot
				if not CrownVariables.SelfOptions.AntiHeadshot then
					SetPedSuffersCriticalHits(PlayerPedId(), true)
				end
			elseif CrownMenu.CheckBox("Infinite Combat Roll", CrownVariables.SelfOptions.InfiniteCombatRoll) then
				CrownVariables.SelfOptions.InfiniteCombatRoll = not CrownVariables.SelfOptions.InfiniteCombatRoll
			elseif CrownMenu.CheckBox("Moon Walk", CrownVariables.SelfOptions.MoonWalk) then
				CrownVariables.SelfOptions.MoonWalk = not CrownVariables.SelfOptions.MoonWalk
			elseif CrownMenu.CheckBox("Super Jump", CrownVariables.SelfOptions.superjump) then
				CrownVariables.SelfOptions.superjump = not CrownVariables.SelfOptions.superjump
			elseif CrownMenu.CheckBox("Super Run", CrownVariables.SelfOptions.superrun) then
				CrownVariables.SelfOptions.superrun = not CrownVariables.SelfOptions.superrun
			elseif CrownMenu.CheckBox("Force Footstep Trail", forcefoottrail) then
				forcefoottrail = not forcefoottrail
				SetForcePedFootstepsTracks(forcefoottrail)
			elseif CrownMenu.CheckBox("Super Swim", superswim) then

				superswim = not superswim

				if superswim then
					SetSwimMultiplierForPlayer(PlayerId(), 1.49)
				else
					SetSwimMultiplierForPlayer(PlayerId(), 1.0)
				end
			end
			
			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('premadeoutfits') then
			
			if CrownMenu.Button("Fuse | Monkey") then
				AntiMenuCrash = 0

				RequestModel("mp_m_freemode_01")
                
				while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) and AntiMenuCrash < 5000 do
					AntiMenuCrash = AntiMenuCrash + 1
					Wait(0)
				end

				if HasModelLoaded(GetHashKey("mp_m_freemode_01")) then
					SetPlayerModel(PlayerId(), "mp_m_freemode_01")
					SetPedComponentVariation(PlayerPedId(), 1, 3, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 2, 4, 3, 0)
					SetPedComponentVariation(PlayerPedId(), 3, 17, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 4, 4, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 6, 4, 1, 0)
					SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 11, 256, 0, 0)
				else
					PushNotification("Requesting Model Timeout", 600)
				end

			--[[
			elseif CrownMenu.Button("Kyler | MP Rasta") then
				AntiMenuCrash = 0
				RequestModel("mp_m_freemode_01")
				Wait(450)
				
				while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) and AntiMenuCrash < 5000 do
					AntiMenuCrash = AntiMenuCrash + 1
					Wait(0)
				end

				if HasModelLoaded(GetHashKey("mp_m_freemode_01")) then
					SetPlayerModel(PlayerId(), "mp_m_freemode_01")
					SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 2, 17, 1, 0)
					SetPedComponentVariation(PlayerPedId(), 4, 4, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 6, 6, 1, 0)
					SetPedComponentVariation(PlayerPedId(), 11, 121, 3, 0)
					SetPedPropIndex(PlayerPedId(), 1, 25, 3, 0)
				else
					PushNotification("Requesting Model Timeout", 600)
				end
			]]
			elseif CrownMenu.Button("Fuse | Gangsta") then
				AntiMenuCrash = 0
				RequestModel("mp_m_freemode_01")

				Wait(450)
				
				while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) and AntiMenuCrash < 5000 do
					AntiMenuCrash = AntiMenuCrash + 1
					Wait(0)
				end

				if HasModelLoaded(GetHashKey("mp_m_freemode_01")) then
					SetPlayerModel(PlayerId(), "mp_m_freemode_01")
					SetPedPropIndex(PlayerPedId(), 0, 56, 1, 0)
					SetPedPropIndex(PlayerPedId(), 1, 7, 2, 0)
					SetPedComponentVariation(PlayerPedId(), 1, 51, 7, 0)
					SetPedComponentVariation(PlayerPedId(), 2, 11, 4, 0)
					SetPedComponentVariation(PlayerPedId(), 3, 14, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 4, 4, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 6, 6, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 11, 14, 7, 0)
				end

			elseif CrownMenu.Button("Fuse | Cop") then
				AntiMenuCrash = 0
				RequestModel("mp_m_freemode_01")

				Wait(450)
				
				while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) and AntiMenuCrash < 5000 do
					AntiMenuCrash = AntiMenuCrash + 1
					Wait(0)
				end

				if HasModelLoaded(GetHashKey("mp_m_freemode_01")) then
					SetPlayerModel(PlayerId(), "mp_m_freemode_01")
					SetPedComponentVariation(PlayerPedId(), 1, -1, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 2, 2, 4, 0)
					SetPedComponentVariation(PlayerPedId(), 3, 17, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 4, 66, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 6, 4, 1, 0)
					SetPedComponentVariation(PlayerPedId(), 7, 8, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 8, 37, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 9, 1, 0, 0)
					SetPedComponentVariation(PlayerPedId(), 11, 166, 0, 0)
					SetPedPropIndex(PlayerPedId(), 0, 130, 0, 0)
					SetPedPropIndex(PlayerPedId(), 1, 6, 0, 0)
				else
					PushNotification("Requesting Model Timeout", 600)
				end
			elseif CrownMenu.CheckBox("Purple And Green Alien", CrownVariables.SelfOptions.AlienColorSpam, "Because why not both") then
				CrownVariables.SelfOptions.AlienColorSpam = not CrownVariables.SelfOptions.AlienColorSpam
				if CrownVariables.SelfOptions.AlienColorSpam then
					AlienColourSpam()
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selfwardrobe') then

			if CrownMenu.MenuButton("Pre-Made Outfits", "premadeoutfits") then
			elseif CrownMenu.ValueChanger("Head", GetPedDrawableVariation(PlayerPedId(), 0), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 0)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 0, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Hat", HatVal, 1, {-1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1}, function(val)
				HatVal = val
				if HatVal == -1 then
					ClearPedProp(PlayerPedId(), 0)
				end
				SetPedPropIndex(PlayerPedId(), 0, HatVal, 1, 0)
			end) then
			elseif CrownMenu.ValueChanger("Hat Colour", GetPedPropTextureIndex(PlayerPedId(), 0), 1, {1, GetNumberOfPedPropTextureVariations(PlayerPedId(), 0, GetPedPropIndex(PlayerPedId(), 0))}, function(val)
				SetPedPropIndex(PlayerPedId(), 0, HatVal, val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Glasses", GlassesVal, 1, {-1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)}, function(val)
				GlassesVal = val
				SetPedPropIndex(PlayerPedId(), 1, GlassesVal, 1, 0)
			end) then
			elseif CrownMenu.ValueChanger("Glasses Colour", GetPedPropTextureIndex(PlayerPedId(), 1), 1, {1, GetNumberOfPedPropTextureVariations(PlayerPedId(), 1, GetPedPropIndex(PlayerPedId(), 1))}, function(val)
				SetPedPropIndex(PlayerPedId(), 1, GetPedPropIndex(PlayerPedId(), 1), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Mask", GetPedDrawableVariation(PlayerPedId(), 1), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 1, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Mask Colour", GetPedTextureVariation(PlayerPedId(), 1), 1, {0, GetNumberOfPedTextureVariations(PlayerPedId(), 1, GetPedDrawableVariation(PlayerPedId(), 1)) - 1}, function(val)
				SetPedComponentVariation(PlayerPedId(), 1, GetPedDrawableVariation(PlayerPedId(), 1), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Hair", GetPedDrawableVariation(PlayerPedId(), 2), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 2, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Hair Colour", GetPedTextureVariation(PlayerPedId(), 2), 1, {0, 63}, function(val)
				SetPedComponentVariation(PlayerPedId(), 2, GetPedDrawableVariation(PlayerPedId(), 2), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Torso", GetPedDrawableVariation(PlayerPedId(), 3), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 3, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Legs", GetPedDrawableVariation(PlayerPedId(), 4), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 4, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Legs Colour", GetPedTextureVariation(PlayerPedId(), 4), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 4, GetPedDrawableVariation(PlayerPedId(), 4), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Accessory", GetPedDrawableVariation(PlayerPedId(), 5), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 5, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Accessory Colour", GetPedTextureVariation(PlayerPedId(), 5), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 5, GetPedDrawableVariation(PlayerPedId(),5), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Shoes", GetPedDrawableVariation(PlayerPedId(), 6), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 6, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Shoes Colour", GetPedTextureVariation(PlayerPedId(), 6), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 6, GetPedDrawableVariation(PlayerPedId(), 6), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Undershirt", GetPedDrawableVariation(PlayerPedId(), 8), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 8, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Undershirt Colour", GetPedTextureVariation(PlayerPedId(), 8), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 8, GetPedDrawableVariation(PlayerPedId(), 8), val, 0)
			end) then
			elseif CrownMenu.ValueChanger("Shirt", GetPedDrawableVariation(PlayerPedId(), 11), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 11, val, 0, 0)
			end) then
			elseif CrownMenu.ValueChanger("Shirt Colour", GetPedTextureVariation(PlayerPedId(), 11), 1, {0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11)}, function(val)
				SetPedComponentVariation(PlayerPedId(), 11, GetPedDrawableVariation(PlayerPedId(),11), val, 0)
			end) then
		    end
			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('selfmodellist') then
			if CrownMenu.Button("Input Model") then
				local result = CrownMenu.KeyboardEntry("Enter Player Model", 50)

				if IsModelAVehicle(result) or not IsModelValid(result) then

					PushNotification("Invalid Model Entered", 600)

				else

					while not HasModelLoaded(GetHashKey(result)) and not killmenu do
						RequestModel(GetHashKey(result))
						Wait(500)
					end
		
					SetPlayerModel(PlayerId(), GetHashKey(result))
		
					CancelOnscreenKeyboard()
				end
			end
			local modelslist = PlayerModels
			for i = 1, #modelslist do
				if CrownMenu.Button(modelslist[i]) then
                    while not HasModelLoaded(GetHashKey(modelslist[i])) and not killmenu do
						RequestModel(GetHashKey(modelslist[i]))
						Wait(500)
					end

					SetPlayerModel(PlayerId(), GetHashKey(modelslist[i]))

					if modelslist[i] == "mp_m_freemode_01" then
				        SetPedComponentVariation(PlayerPedId(), 1, -1, 0, 0)
					end
				end
			end

			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('particleeffectsonplayer') then
			
			if CrownMenu.CheckBox("Molotov Particles Loop", CrownVariables.OnlinePlayer.MolotovLoop) then
				CrownVariables.OnlinePlayer.MolotovLoop = not CrownVariables.OnlinePlayer.MolotovLoop
				CrownVariables.OnlinePlayer.MolotovPlayer = selectedPlayer
			elseif CrownMenu.CheckBox("Firework Particles Loop", CrownVariables.OnlinePlayer.FireWorkLoop) then
				CrownVariables.OnlinePlayer.FireWorkLoop = not CrownVariables.OnlinePlayer.FireWorkLoop
				CrownVariables.OnlinePlayer.FireWorkPlayer = selectedPlayer
			elseif CrownMenu.CheckBox("Firework 2 Particles Loop", CrownVariables.OnlinePlayer.FireWork2Loop) then
				CrownVariables.OnlinePlayer.FireWork2Loop = not CrownVariables.OnlinePlayer.FireWork2Loop
				CrownVariables.OnlinePlayer.FireWork2Player = selectedPlayer
			elseif CrownMenu.CheckBox("Smoke Particles Loop", CrownVariables.OnlinePlayer.SmokeLoop) then
				CrownVariables.OnlinePlayer.SmokeLoop = not CrownVariables.OnlinePlayer.SmokeLoop
				CrownVariables.OnlinePlayer.SmokePlayer = selectedPlayer
			elseif CrownMenu.CheckBox("Jesus Light Particles Loop", CrownVariables.OnlinePlayer.JesusLightLoop) then
				CrownVariables.OnlinePlayer.JesusLightLoop = not CrownVariables.OnlinePlayer.JesusLightLoop
				CrownVariables.OnlinePlayer.JesusPlayer = selectedPlayer
			elseif CrownMenu.CheckBox("Alien Light Particles Loop", CrownVariables.OnlinePlayer.AlienLightLoop) then
				CrownVariables.OnlinePlayer.AlienLightLoop = not CrownVariables.OnlinePlayer.AlienLightLoop
				CrownVariables.OnlinePlayer.AlienPlayer = selectedPlayer
			elseif CrownMenu.CheckBox("Huge Explosion Loop", CrownVariables.OnlinePlayer.ExplosionParticlePlayer) then
				if CrownVariables.OnlinePlayer.ExplosionParticlePlayer == nil then
					CrownVariables.OnlinePlayer.ExplosionParticlePlayer = selectedPlayer
				else
					CrownVariables.OnlinePlayer.ExplosionParticlePlayer = nil
				end
		    end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('pedspawningonplayer') then
			CrownMenu.SetMenuProperty('pedspawningonplayer', 'subTitle', GetPlayerName(selectedPlayer) .. " > Ped Options")
			
			if CrownMenu.Button("Copy Player Outfit / Ped") then
				model = GetEntityModel(GetPlayerPed(selectedPlayer))
				SetPlayerModel(PlayerId(), model)
				Wait(100)
				ClonePedToTarget(GetPlayerPed(selectedPlayer), PlayerPedId())
			elseif CrownMenu.CheckBox("Hostile Peds", HostilePeds) then
			    HostilePeds = not HostilePeds
			elseif CrownMenu.Button("Clone Player") then
			    ClonePed(GetPlayerPed(selectedPlayer), 1, 1, 1)
			elseif CrownMenu.Button("Spawn Rats") then
				local sick = 0
				while sick < 30 and not killmenu do
					sick = sick + 1
					SpawnPed(selectedPlayer, "a_c_rat", false)
					Wait(0)
			    end
		    elseif CrownMenu.Button("Spawn Mexican Guy") then
				PlayerPed = GetPlayerPed(selectedPlayer)
				PlayerCoords(GetEntityCoords(PlayerPed))
				Data = {
					Model = "a_m_m_eastsa",
					Behavior = 24,
					Coords = PlayerCoords,
					Weapon = "WEAPON_ASSAULTRIFLE",
				}
				
				CrownMenu.Functions.SpawnPed(Data)
			elseif CrownMenu.Button("Spawn Fat Man") then
				SpawnPed(selectedPlayer, "a_m_m_afriamer_01", HostilePeds)
			elseif CrownMenu.Button("Spawn Indian Man") then
				SpawnPed(selectedPlayer, "a_m_m_indian_01", HostilePeds)
			elseif CrownMenu.Button("Spawn Mr Muscle") then
				SpawnPed(selectedPlayer, "u_m_y_babyd", HostilePeds)
			elseif CrownMenu.Button("Spawn Michael") then
				SpawnPed(selectedPlayer, "player_zero", HostilePeds)
			elseif CrownMenu.Button("Spawn Franklin") then
				SpawnPed(selectedPlayer, "player_one", HostilePeds)
			elseif CrownMenu.Button("Spawn Trevor") then
				SpawnPed(selectedPlayer, "player_two", HostilePeds)
			elseif CrownMenu.Button("Spawn Stripper") then
                SpawnPed(selectedPlayer, "csb_stripper_01", HostilePeds)
			elseif CrownMenu.Button("Spawn Dog") then
                SpawnPed(selectedPlayer, "a_c_chop", HostilePeds)
			elseif CrownMenu.Button("Spawn Merryweather Guard") then
                SpawnPed(selectedPlayer, "csb_mweather", HostilePeds)
			elseif CrownMenu.Button("Spawn Fat Man") then
                SpawnPed(selectedPlayer, "a_m_m_afriamer_01", HostilePeds)
			end

			CrownMenu.Display()

		elseif CrownMenu.IsMenuOpened('trollonlineplayr') then
			CrownMenu.SetMenuProperty('trollonlineplayr', 'subTitle', GetPlayerName(selectedPlayer) .. " > Troll Options")
			
			if CrownMenu.Button("Give All Weapons") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
					SafeModeNotification()
				else
				    for i = 1, #allWeapons do
					    GiveWeaponToPed(GetPlayerPed(selectedPlayer), GetHashKey(allWeapons[i]), 9999, false, false)
				    end
			    end
			elseif CrownMenu.Button("Remove All Weapons") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
					SafeModeNotification()
				else
				    RemoveAllPedWeapons(GetPlayerPed(selectedPlayer), false)
				    RemoveWeaponFromPed(GetPlayerPed(selectedPlayer), "WEAPON_UNARMED")
				end
			elseif CrownMenu.Button("Teleport All Vehicles On Player") then
				for veh in EnumerateVehicles() do
					if DoesEntityExist(veh) then
						SetEntityCoords(veh, GetEntityCoords(GetPlayerPed(selectedPlayer)))
					end
				end
			elseif CrownMenu.Button("Kill With Assault Rifle") then

				ExplodePedHead(GetPlayerPed(selectedPlayer), GetHashKey("WEAPON_ASSAULTRIFLE"))
				
			elseif CrownMenu.Button("Taze Player") then

				local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
				RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	            ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + 2, 0, true, "WEAPON_STUNGUN", ped, false, false, 100)

			elseif CrownMenu.CheckBox("Taze Loop Player", TazeLoop, "They Might fly up") then

				TazeLoop = not TazeLoop
				TazeLoopingPlayer = selectedPlayer

			elseif CrownMenu.Button("Stop Player From Jumping / No Vehicles", "", "Whatever car he enters will Fly") then

				local ped = GetPlayerPed(selectedPlayer)
				local fok = ClonePed(GetPlayerPed(selectedPlayer), 1, 1, 1)
				SetEntityVisible(fok, false, true)
				AttachEntityToEntity(fok, ped, 0, 0.0, 0.0, 1.0, 0.0, 180.0, 180.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Cage Player") then

				CagePlayer(selectedPlayer)

			elseif CrownMenu.Button("Cargo Plane", "~y~Native") then

				local ped = GetPlayerPed(selectedPlayer) 
				local coords = GetEntityCoords(ped)
				
	            while not HasModelLoaded(GetHashKey("cargoplane")) and not killmenu do
					RequestModel(GetHashKey("cargoplane"))
					Wait(1)
				end

				local veh = CreateVehicle(GetHashKey("cargoplane"), coords.x, coords.y, coords.z, 90.0, 1, 1)

			elseif CrownMenu.CheckBox("Cargo Plane Loop", CrownVariables.OnlinePlayer.cargoplaneloop) then
				CrownVariables.OnlinePlayer.CargodPlayer = selectedPlayer
				CrownVariables.OnlinePlayer.cargoplaneloop = not CrownVariables.OnlinePlayer.cargoplaneloop
			elseif CrownMenu.Button("Tug Boat", "~y~Native") then

				local ped = GetPlayerPed(selectedPlayer) 
				local coords = GetEntityCoords(ped)
				
	            while not HasModelLoaded(GetHashKey("tug")) and not killmenu do
					RequestModel(GetHashKey("tug"))
					Wait(1)
				end

				local veh = CreateVehicle(GetHashKey("tug"), coords.x, coords.y, coords.z, 90.0, 1, 1)

			elseif CrownMenu.Button("Bus Player", "~y~Native") then

				BusPlayer(selectedPlayer)

			elseif CrownMenu.Button("Helicopter Chase Player", "~y~Native") then

				HelicopterChase(selectedPlayer)

			elseif CrownMenu.Button("9/11 into Player", "~y~Native") then

				FlyPlaneIntoPlayer(selectedPlayer)

			elseif CrownMenu.Button("Swat Team Attack", "~y~Native") then

				SWATTeamPullUp(selectedPlayer)

			elseif CrownMenu.Button("Player into Ramp") then

				RampPlayer(selectedPlayer)

	        elseif CrownMenu.ValueChanger("Explosion Type", CrownVariables.OnlinePlayer.ExplosionType, 1, {1, 36}, function(value)
				CrownVariables.OnlinePlayer.ExplosionType = value
			end) then

			elseif CrownMenu.Button("Explode Player", "~y~Native") and not SafeMode then
				local ped = GetPlayerPed(selectedPlayer)
				local coords = GetEntityCoords(ped)
				AddExplosion(coords.x + 1, coords.y + 1, coords.z + 1, CrownVariables.OnlinePlayer.ExplosionType, 100.0, true, false, 0.0)

			elseif CrownMenu.CheckBox("Explosion Loop", CrownVariables.OnlinePlayer.ExplosionLoop) and not SafeMode then
				CrownVariables.OnlinePlayer.ExplodingPlayer = selectedPlayer
				NativeExplosionLoop()
				CrownVariables.OnlinePlayer.ExplosionLoop = not CrownVariables.OnlinePlayer.ExplosionLoop

			elseif CrownMenu.Button("Rape Player", "", false, "Attach Rapist to Player") then
				RapePlayer(selectedPlayer)
			elseif CrownMenu.CheckBox("Freeze Player", CrownVariables.OnlinePlayer.freezeplayer) then

				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
					SafeModeNotification()
				else
					CrownVariables.OnlinePlayer.freezeplayer = not CrownVariables.OnlinePlayer.freezeplayer
					CrownVariables.OnlinePlayer.playertofreeze = selectedPlayer
				end

			elseif selectedPlayer ~= PlayerId() and CrownMenu.CheckBox("Attach to Player", CrownVariables.OnlinePlayer.attachtoplayer) then
				if PlayerId() == selectedPlayer == false then
					CrownVariables.OnlinePlayer.attatchedplayer = selectedPlayer
					CrownVariables.OnlinePlayer.attachtoplayer = not CrownVariables.OnlinePlayer.attachtoplayer
					if CrownVariables.OnlinePlayer.attachtoplayer == false then
						DetachEntity(PlayerPedId())
					end
				end
			elseif CrownMenu.CheckBox("Fling Player", CrownVariables.OnlinePlayer.FlingingPlayer) then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif SafeMode then
					SafeModeNotification()
				elseif CrownVariables.OnlinePlayer.FlingingPlayer then
					CrownVariables.OnlinePlayer.FlingingPlayer = false
				else
				    CrownVariables.OnlinePlayer.FlingingPlayer = selectedPlayer
				end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('attachpropstoplayer') then
			CrownMenu.SetMenuProperty('attachpropstoplayer', 'subTitle', GetPlayerName(selectedPlayer) .. " > Attach Props")
			
			if CrownMenu.Button("Attach UFO") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("p_spinning_anus_s"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
			elseif CrownMenu.Button("Attach Central Los Santos") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("dt1_lod_slod3"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach FIB Building") then
	
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(-1404869155, 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Sandy Shores") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("cs4_lod_04_slod2"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach LS Docks") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("po1_lod_slod4"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Mirror Park") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("id2_lod_slod4 "), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Airport") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("ap1_lod_slod4"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Del Pero Pier") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("sm_lod_slod2_22"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
				
			elseif CrownMenu.Button("Attach Christmas Tree") then
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("prop_xmas_tree_int"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
				
			elseif CrownMenu.Button("Attach Box to Head") then

				local ped = GetPlayerPed(selectedPlayer)
				local bone = GetPedBoneIndex(ped, 31086)
				local prop = CreateObject(GetHashKey("prop_cs_cardbox_01"), 9, 9, 9, 1, 1, 1)
	
				AttachEntityToEntity(prop, ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Alien Egg") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local bone = GetPedBoneIndex(ped, 31086)
				local prop = CreateObject(GetHashKey("prop_alien_egg_01"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, bone, 0.2, 0.0, 0.0, 90.0, 90.0, 90.0, false, false, true, false, 0, true)
				
			elseif CrownMenu.Button("Attach TV On Head") then
				
				local ped = GetPlayerPed(selectedPlayer)
				local bone = GetPedBoneIndex(ped, 31086)
				local prop = CreateObject(GetHashKey("prop_tv_03"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, bone, 0.1, 0.075, 0.0, 0.0, 270.0, 180.0, false, false, true, false, 0, true)

				AttachEntityToEntity(entity1, entity2, boneIndex, xPos, yPos, zPos, xRot, yRot, zRot, p9, useSoftPinning, collision, isPed, vertexIndex, fixedRot)
			elseif CrownMenu.Button("Attach Campfire") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("prop_beach_fire"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Windmill") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("prop_windmill_01_l1"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, -2.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Ramp") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("stt_prop_stunt_track_start"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach Mexican Flag") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("apa_prop_flag_mexico_yt"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach USA Flag") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("apa_prop_flag_us_yt"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Attach UK Flag") then

				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("apa_prop_flag_uk_yt"), 9, 9, 9, 1, 1, 1)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, false, false, true, false, 0, true)

            end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selectedplayerTriggerEvents') then
			CrownMenu.SetMenuProperty('selectedplayerTriggerEvents', 'subTitle', GetPlayerName(selectedPlayer) .. " > Trigger Events")

			if CrownMenu.Button("Bill Player", "~y~ESX | Server") then

				name = CrownMenu.KeyboardEntry("Bill Name", 200)
				amount = CrownMenu.KeyboardEntry("Bill Amount", 200)

				amount = tonumber(amount)

				TriggerServerEvent("esx_billing:sendBill", GetPlayerServerId(selectedPlayer), GetPlayerName(selectedPlayer), name, amount)

			elseif CrownMenu.Button("Carry Player", "~g~Carry Script") then

				local player = PlayerPedId()	
				lib = 'missfinale_c2mcs_1'
				anim1 = 'fin_c2_mcs_1_camman'
				lib2 = 'nm'
				anim2 = 'firemans_carry'
				distans = 0.15
				distans2 = 0.27
				height = 0.63
				spin = 0.0		
				length = 100000
				controlFlagMe = 49
				controlFlagTarget = 33
				animFlagTarget = 1

				carryingBackInProgress = true

				TriggerServerEvent('CarryPeople:sync', GetPlayerServerId(selectedPlayer), lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
		
			elseif CrownMenu.Button("Open Players Inventory", "~g~ESX | Client") then

				TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(selectedPlayer), selectedPlayer, GetPlayerName(selectedPlayer))

			elseif CrownMenu.DynamicTriggers.Triggers['ESXHandcuff'] ~= nil and CrownMenu.Button("Cuff Player", "~y~ESX | Server") then

				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['ESXHandcuff'], GetPlayerServerId(selectedPlayer))	
				
			elseif CrownMenu.DynamicTriggers.Triggers['ESXDrag'] ~= nil and CrownMenu.Button("Drag Player", "~y~ESX | Server") then

				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['ESXDrag'], GetPlayerServerId(selectedPlayer))	

			elseif CrownMenu.DynamicTriggers.Triggers['ESXQalleJail'] ~= nil and CrownMenu.Button("Jail Player", "~g~ESX", nil, "Works On Servers With ESX") then
				
				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['ESXQalleJail'], GetPlayerServerId(selectedPlayer), math.huge, "Crown Menu On top ")
			
			elseif CrownMenu.DynamicTriggers.Triggers['TacklePlayer'] ~= nil and CrownMenu.Button("Tackle Player", "~y~Server") then
				
				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['TacklePlayer'], selectedPlayer)

			elseif CrownMenu.Button("Drag Player", "~g~SEM") then

				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['DragSEM'], GetPlayerServerId(selectedPlayer))

			elseif CrownMenu.Button("Cuff Player", "~g~SEM") then

				TriggerServerEvent("SEM_InteractionMenu:CuffNear", GetPlayerServerId(selectedPlayer))

			elseif CrownMenu.Button("Jail Player", "~g~SEM") then

				TriggerServerEvent(CrownMenu.DynamicTriggers.Triggers['JailSEM'], GetPlayerServerId(selectedPlayer), math.huge)

			elseif CrownMenu.Button("Unjail Player", "~g~SEM") then
				
				TriggerServerEvent("SEM_InteractionMenu:Unjail", GetPlayerServerId(selectedPlayer))
				
			elseif CrownMenu.Button("Kick Out Of Veh", "~g~SEM") then

				TriggerServerEvent('SEM_InteractionMenu:UnseatNear', GetPlayerServerId(selectedPlayer))
				
			elseif CrownMenu.Button("TP Player Into My Vehicle", "~g~SEM") then

				TriggerServerEvent('SEM_InteractionMenu:SeatNear', GetPlayerServerId(selectedPlayer), CrownVariables.VehicleOptions.PersonalVehicle)
				
			elseif CrownMenu.Button("TP Player to Space", "~g~SEM") then

				RequestModel(GetHashKey("baller"))

				Timout = 0

				while not HasModelLoaded(GetHashKey("baller")) and Timout < 4000 do
					RequestModel(GetHashKey("baller"))
					Wait(1)
					Timout = Timout + 1
				end

				if HasModelLoaded(GetHashKey("baller")) then
					local Vehicle = CreateVehicle(GetHashKey("baller"), 10000.0, 10000.0, 1000.0, 0.0, 1, 1)
					SetEntityAsMissionEntity(Vehicle, true, true)
					FreezeEntityPosition(Vehicle)
					
					TriggerServerEvent('SEM_InteractionMenu:UnseatNear', GetPlayerServerId(selectedPlayer))
					TriggerServerEvent('SEM_InteractionMenu:SeatNear', GetPlayerServerId(selectedPlayer), Vehicle)
					DeleteEntity(Vehicle)
				end

			elseif CrownMenu.Button("Send Fake Message", "~g~SEM") then

				message = CrownMenu.KeyboardEntry("Enter Fake Message", 200)
				TriggerServerEvent("SEM_InteractionMenu:GlobalChat", {255, 255, 255}, GetPlayerName(selectedPlayer), message)

			elseif CrownMenu.Button("Send Fake Message", "~y~Server") then

				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
				    FakeChatMessage(GetPlayerName(selectedPlayer))
				end

			elseif CrownMenu.CheckBox("Send Fake Message Loop", CrownVariables.OnlinePlayer.messagelooping) then

			
				CrownVariables.OnlinePlayer.messageloopplayer = selectedPlayer
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				elseif CrownVariables.OnlinePlayer.messagelooping then
					CrownVariables.OnlinePlayer.messagelooping = false
				elseif SafeMode then
					SafeModeNotification()
				else

					result = CrownMenu.KeyboardEntry("Message To Send", 200)
					
					if HasModelLoaded(GetHashKey(result)) then

					else
						RequestModel(GetHashKey(result))
						Wait(500)
					end
				
					CancelOnscreenKeyboard()
					CrownVariables.OnlinePlayer.messagelooping = not CrownVariables.OnlinePlayer.messagelooping
					CrownVariables.OnlinePlayer.messagetosend = result
			    end
			end

			CrownMenu.Display()
		elseif CrownMenu.IsMenuOpened('selectedPlayervehicleopts') then
		    CrownMenu.SetMenuProperty('selectedPlayervehicleopts', 'subTitle', GetPlayerName(selectedPlayer) .. " > Vehicle Options")
			if CrownMenu.Button("Give Player a Car") then
				local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0.0, 8.0, 0.5)
				local x = coords.x
				local y = coords.y
				local z = coords.z
				result = CrownMenu.KeyboardEntry("Vehicle Spawn Code", 200)
                
				if HasModelLoaded(GetHashKey(result)) then

				else
					RequestModel(GetHashKey(result))
					Wait(500)
				end
				
				if not IsModelAVehicle(result) then
                    PushNotification("Invalid Vehicle Model", 600)
				end

				CancelOnscreenKeyboard()
				if result == "t20ramp" then
				    RampCar(selectedPlayer)
				elseif result == "ufo" then
			        UFOVeh(selectedPlayer)
				else
					local vehicle = CreateVehicle(GetHashKey(result), x, y, z, 0.0, 1, 1)
					SetEntityHeading(vehicle, GetEntityHeading(GetPlayerPed(selectedPlayer)))
					SetEntityHeading(vehicle, GetEntityHeading(PlayerPedId()))
					SetVehicleEngineOn(vehicle, true, false, false)
					SetVehRadioStation(vehicle, 'OFF')
				end

				CancelOnscreenKeyboard()
				
			elseif CrownMenu.Button("Teleport Into Players Car") then
				local veh = GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), 0)
				
				if IsVehicleSeatFree(veh, 0) then
					SetPedIntoVehicle(PlayerPedId(), veh, 0)
				else
					if IsVehicleSeatFree(veh, 1) then
						SetPedIntoVehicle(PlayerPedId(), veh, 1)
					else
						if IsVehicleSeatFree(veh, 2) then
							SetPedIntoVehicle(PlayerPedId(), veh, 2)
						else
							if IsVehicleSeatFree(veh, 3) then
								SetPedIntoVehicle(PlayerPedId(), veh, 3)
							else
								PushNotification("Vehicle has no Empty Seat", 600)
							end
						end
					end
				end
			elseif CrownMenu.Button("Repair Vehicle") then
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer)))
				SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), false))
				SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), false), 0.0)
				SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), false), 0)
				SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), false), false)
				Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(selectedPlayer), false), 0)
			elseif CrownMenu.Button("Destroy Engine") then
				local playerPed = GetPlayerPed(selectedPlayer)
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer)))
				SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
				SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 10)
			elseif CrownMenu.Button("Kick From Vehicle") then
				if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
					PushNotification("Anticheat Detected! Function Blocked", 600)
				else
					ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
				end
			elseif CrownMenu.Button("Destroy Vehicle") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer)))
				StartVehicleAlarm(playerVeh)
				DetachVehicleWindscreen(playerVeh)
				SmashVehicleWindow(playerVeh, 0)
				SmashVehicleWindow(playerVeh, 1)
				SmashVehicleWindow(playerVeh, 2)
				SmashVehicleWindow(playerVeh, 3)
				SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
				SetVehicleDoorBroken(playerVeh, 0, true)
				SetVehicleDoorBroken(playerVeh, 1, true)
				SetVehicleDoorBroken(playerVeh, 2, true)
				SetVehicleDoorBroken(playerVeh, 3, true)
				SetVehicleDoorBroken(playerVeh, 4, true)
				SetVehicleDoorBroken(playerVeh, 5, true)
				SetVehicleDoorBroken(playerVeh, 6, true)
				SetVehicleDoorBroken(playerVeh, 7, true)
				SetVehicleLights(playerVeh, 1)
				Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
				SetVehicleDirtLevel(playerVeh, 10.0)
				SetVehicleBurnout(playerVeh, true)
			elseif CrownMenu.Button("Delete Vehicle") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer)))
				DeleteVehicle(playerVeh)
			elseif CrownMenu.Button("Teleport Vehicle To Waypoint") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				local waypoint = GetFirstBlipInfoId(8)
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(GetPlayerPed(selectedPlayer)))
				if DoesBlipExist(waypoint) then
					SetEntityCoords(playerVeh, GetBlipInfoIdCoord(waypoint))
				end
			elseif CrownMenu.Button("Ramp Players Vehicle") then
				Citizen.CreateThread(function()

					local ped = GetPlayerPed(selectedPlayer)
					local carSpeed = GetEntitySpeed(GetVehiclePedIsIn(ped, true)) * 2.236936 -- convert in mph
					local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(selectedPlayer), 0.0, 8.0, 0.5)
					local x = coords.x
					local y = coords.y
					local z = coords.z
					local faggot = CreateObject(GetHashKey("prop_jetski_ramp_01"), x, y, z - 2, 1, 1, 1)
					SetEntityHeading(faggot, GetEntityHeading(ped))
					FreezeEntityPosition(faggot, true)
	
					Wait(5000)

					DeleteEntity(faggot)

					return ExitThread
				end)
			elseif CrownMenu.Button("Add Ramp to Players Vehicle") then

				local ped = GetPlayerPed(selectedPlayer)
				local vehi = GetVehiclePedIsIn(ped, 0)
				local ramp = CreateObject(GetHashKey("prop_jetski_ramp_01"), 0, 0, 0, 1, 1, 1)
				AttachEntityToEntity(ramp, vehi, bogie_front, 0.0, 3.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Launch Players Vehicle", "+X") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)

				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, 5000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end
				
			elseif CrownMenu.Button("Launch Players Vehicle","-X") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)

				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, -5000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end

			elseif CrownMenu.Button("Launch Players Vehicle", "+Y") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)

				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, 0.0, 5000.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end

			elseif CrownMenu.Button("Launch Players Vehicle", "-Y") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)

				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, 0.0, -5000.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end

			elseif CrownMenu.Button("Launch Players Vehicle", "+Z") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				
				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 5000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end
				
			elseif CrownMenu.Button("Slam Players Vehicle", "-Z") then
				local playerPed = GetPlayerPed(selectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)

				if playerVeh ~= 0 then
					NetworkRequestControlOfEntity(playerVeh)
					ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, -5000.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
				end
			end

		    CrownMenu.Display()
			
		elseif CrownMenu.IsMenuOpened('selectedonlineplayr') then

			CrownMenu.SetMenuProperty('selectedonlineplayr', 'subTitle', string.upper(GetPlayerServerId(selectedPlayer) .. " | ~s~" .. GetPlayerName(selectedPlayer)))
			
		    if CrownMenu.MenuButton('Vehicle Options', 'selectedPlayervehicleopts', "Mess with Player's Vehicle" ) then
			elseif CrownMenu.MenuButton('Trigger Events', 'selectedplayerTriggerEvents', "Trigger Events For Player") then
			elseif CrownMenu.MenuButton('Particle Effects', 'particleeffectsonplayer', "Particle Effects") then
			elseif CrownMenu.MenuButton('Attach Objects', 'attachpropstoplayer', "Attach Objects On Player") then
			elseif CrownMenu.MenuButton('Troll Options', 'trollonlineplayr', "Troll Options") then
			elseif CrownMenu.MenuButton('Ped Options', 'pedspawningonplayer', "Spawn Friendly / Hostile Peds") then

			elseif CrownMenu.Button("Semi-Godmode", "", false, "Player can not Die From Bullets") then

				RequestModel("prop_juicestand")
				Wait(600)
				local ped = GetPlayerPed(selectedPlayer)
				local prop = CreateObject(GetHashKey("prop_juicestand"), 9, 9, 9, 1, 1, 1)

				SetEntityVisible(prop, false, true)

				AttachEntityToEntity(prop, ped, 0, 0.0, 0.0, 0.0, 90.0, 90.0, 90.0, false, false, true, false, 0, true)

			elseif CrownMenu.Button("Teleport To Player") then

				TeleportToPlayer(selectedPlayer)
				
			elseif CrownMenu.Button("Set Waypoint on Player") then

				local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
				SetNewWaypoint(coords.x, coords.y)

			elseif CrownMenu.CheckBox("Track Player", CrownVariables.OnlinePlayer.TrackingPlayer) then

				if CrownVariables.OnlinePlayer.TrackingPlayer then
					CrownVariables.OnlinePlayer.TrackingPlayer = nil
				else
					CrownVariables.OnlinePlayer.TrackingPlayer = selectedPlayer
				end

			elseif selectedPlayer ~= PlayerId() and CrownMenu.CheckBox("Friend", TableHasValue(FriendsList, GetPlayerServerId(selectedPlayer))) then
					if TableHasValue(FriendsList, GetPlayerServerId(selectedPlayer)) then
						RemoveValueFromTable(FriendsList, GetPlayerServerId(selectedPlayer))
					else
						FriendsList[tablelength(FriendsList) + 1] = GetPlayerServerId(selectedPlayer)
					end
			elseif selectedPlayer ~= PlayerId() and CrownMenu.CheckBox("Spectate", isSpectatingTarget) then
				if AntiCheats.ChocoHax or AntiCheats.VAC or AntiCheats.BadgerAC or AntiCheats.WaveSheild or AntiCheats.ATG then
		            PushNotification("Anticheat Detected! Function Blocked", 600)
				else

				end
				isSpectatingTarget = not isSpectatingTarget

				local PlayersPed = GetPlayerPed(selectedPlayer)
				if isSpectatingTarget then
					local coords = GetEntityCoords(PlayersPed)
					local targetx = coords.x
					local targety = coords.y
					local targetz = coords.z

					NetworkSetOverrideSpectatorMode(false)
					RequestCollisionAtCoord(GetEntityCoords(PlayersPed))
					NetworkSetInSpectatorModeExtended(true, PlayersPed, false)
					NetworkSetOverrideSpectatorMode(false)
				else
					local coords = GetEntityCoords(PlayersPed)
					local targetx = coords.x
					local targety = coords.y
					local targetz = coords.z

					NetworkSetOverrideSpectatorMode(false)
					RequestCollisionAtCoord(targetx, targety, targetz)
					NetworkSetInSpectatorModeExtended(false, PlayersPed, false)
					NetworkSetOverrideSpectatorMode(false)
				end
				
			end

			CrownMenu.Display()

		elseif IsDisabledControlJustPressed(0, tonumber(CrownVariables.Keybinds.OpenKey)) then -- Open Key
			CrownMenu.OpenMenu('main')
		end

		Wait(0)

		if OnlinePlayerOptions then
			
			local ped = GetPlayerPed(selectedPlayer)
			local coords = GetEntityCoords(ped)
			local selfcoords = GetEntityCoords(PlayerPedId())
			local invehicle = "~r~No"

			if IsPedInAnyVehicle(ped) then
				invehicle = "~g~Yes"
			else
				invehicle = "~r~No"
			end

			x = tonumber(string.format("%.2f", coords.x))
			y = tonumber(string.format("%.2f", coords.y))
			z = tonumber(string.format("%.2f", coords.z))

			health = GetEntityHealth(ped) - 100 
			armour = tonumber(string.format("%.0f", GetPedArmour(ped)))
			distance = GetDistanceBetweenCoords(selfcoords.x, selfcoords.y, selfcoords.z, coords.x, coords.y, coords.z, true)

			if health > -99 then
				health = health .. " / 100"
			else
				health = "~r~Dead~s~" 
			end

			if CrownMenu.UI.MenuX > 0.13 then
				CrownMenu.DrawText("Godmode: " .. tostring(IsPlayerInGodmode(selectedPlayer)) ..
				"\n~s~Health: " .. health ..
				"\nArmour: " .. armour .. " / 100 " ..
				"\nIn Vehicle: " .. invehicle .. "~s~" ..
				"\nRoad: " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)) ..
				"\nDistance: " .. string.format("%.2f", distance) .. "m"
				, {CrownMenu.UI.MenuX - 0.132, CrownMenu.UI.MenuY + 0.002}, {255, 255, 255, 255}, 0.45, 4, 0, "PlayerInfoText")
				
				CrownMenu.DrawRect(CrownMenu.UI.MenuX - 0.0690, CrownMenu.UI.MenuY + 0.085, 0.13, 0.165, { r = 0, g = 0, b = 0, a = 200 })
	
				CrownMenu.DrawRect(CrownMenu.UI.MenuX - 0.0690, CrownMenu.UI.MenuY + 0.169, 0.13, 0.002, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })
				CrownMenu.DrawRect(CrownMenu.UI.MenuX - 0.0690, CrownMenu.UI.MenuY + 0.001, 0.13, 0.002, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })
			else
				CrownMenu.DrawText("Godmode: " .. tostring(IsPlayerInGodmode(selectedPlayer)) ..
				"\n~s~Health: " .. health ..
				"\nArmour: " .. armour .. " / 100 " ..
				"\nIn Vehicle: " .. invehicle .. "~s~" ..
				"\nRoad: " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)) ..
				"\nDistance: " .. string.format("%.2f", distance) .. "m"
				, {CrownMenu.UI.MenuX + 0.248, CrownMenu.UI.MenuY + 0.002}, {255, 255, 255, 255}, 0.45, 4, 0, "PlayerInfoText")
				
				CrownMenu.DrawRect(CrownMenu.UI.MenuX + 0.31, CrownMenu.UI.MenuY + 0.085, 0.13, 0.165, { r = 0, g = 0, b = 0, a = 200 })
	
				CrownMenu.DrawRect(CrownMenu.UI.MenuX + 0.31, CrownMenu.UI.MenuY + 0.169, 0.13, 0.002, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })
				CrownMenu.DrawRect(CrownMenu.UI.MenuX + 0.31, CrownMenu.UI.MenuY + 0.001, 0.13, 0.002, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })
			end
		end
	end
end)

function IsPlayerInGodmode(player)
	local isgod = GetPlayerInvincible_2(player)
	if isgod == 1 then
        return "~g~Yes"
	else
		return "~r~No"
	end
end

function NoClip()
	if not IsPedInAnyVehicle(PlayerPedId(), true) then
		ClearPedTasksImmediately(PlayerPedId())
	end
	Citizen.CreateThread(function()
		noclipping = not noclipping
		if not noclipping then
			local vehicle = GetVehiclePedIsIn(PlayerPedId())
			SetEntityCollision(vehicle, true, true)
			SetEntityLocallyVisible(PlayerPedId())
			SetEntityCollision(PlayerPedId(), true, true)
            ResetEntityAlpha(PlayerPedId())
			FreezeEntityPosition(PlayerPedId(), false)
			FreezeEntityPosition(vehicle, false)
			ResetEntityAlpha(vehicle)
			DisableControlAction(0, 85, false)
		end

		while noclipping and not killmenu do
			DisableControlAction(0, 85, true)
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				local vehicle = GetVehiclePedIsIn(PlayerPedId())
				local heading = GetEntityHeading(vehicle)
				SetEntityCollision(vehicle, false, false)
				FreezeEntityPosition(vehicle, true)

				if IsDisabledControlPressed(0, 32) then -- W
					local coords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, NoclipSpeed, 0.0)
					local z = GetEntityCoords(vehicle).z
					SetEntityCoords(vehicle, coords.x, coords.y, z - 0.55, 0.0, 0.0, 0.0, false)
				end
				if IsDisabledControlPressed(0, 31) then -- S
					local coords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -NoclipSpeed, 0.0)
					local z = GetEntityCoords(vehicle).z
					SetEntityCoords(vehicle, coords.x, coords.y, z - 0.55, 0.0, 0.0, 0.0, false)
				end
				if IsDisabledControlPressed(0, 34) then -- A
					SetEntityHeading(vehicle, heading + 2)
				end
				if IsDisabledControlPressed(0, 30) then -- D
					SetEntityHeading(vehicle, heading - 2)
				end
				if IsDisabledControlPressed(0, 20) then -- Z
					local coords = GetEntityCoords(vehicle)
					SetEntityCoords(vehicle, coords.x, coords.y, coords.z - NoclipSpeed * 2, 0.0, 0.0, 0.0, false)
				end
				if IsDisabledControlPressed(0, 44) then -- Q
					local coords = GetEntityCoords(vehicle)
					SetEntityCoords(vehicle, coords.x, coords.y, coords.z + NoclipSpeed, 0.0, 0.0, 0.0, false)
				end
			else
				local heading = GetEntityHeading(PlayerPedId())
				SetEntityCollision(PlayerPedId(), false, false)
				FreezeEntityPosition(PlayerPedId(), true)
				SetEntityAlpha(PlayerPedId(), 0.05, false)
				if IsDisabledControlPressed(0, 32) then -- W
					local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, NoclipSpeed, 0.0)
					
					SetEntityVelocity(PlayerPedId(), 0.0, 0.0, 0.0)
					SetEntityRotation(PlayerPedId(), 0.0, 0.0, 0.0, 0, false)
					SetEntityHeading(PlayerPedId(), heading)
					SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, noclipping, noclipping, noclipping)

					--SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z - 1, 0.0, 0.0, 0.0, false)
				end
				if IsDisabledControlPressed(0, 31) then -- S
					local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -NoclipSpeed, 0.0)
					
					SetEntityVelocity(PlayerPedId(), 0.0, 0.0, 0.0)
					SetEntityRotation(PlayerPedId(), 0.0, 0.0, 0.0, 0, false)
					SetEntityHeading(PlayerPedId(), heading)
					SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, noclipping, noclipping, noclipping)

				end
				if IsDisabledControlPressed(0, 34) then -- A
					SetEntityHeading(PlayerPedId(), heading + 2)
				end
				if IsDisabledControlPressed(0, 30) then -- D
					SetEntityHeading(PlayerPedId(), heading - 2)
				end
				if IsDisabledControlPressed(0, 20) then -- Z
					local coords = GetEntityCoords(PlayerPedId())
					SetEntityVelocity(PlayerPedId(), 0.0, 0.0, 0.0)
					SetEntityRotation(PlayerPedId(), 0.0, 0.0, 0.0, 0, false)
					SetEntityHeading(PlayerPedId(), heading)
					SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z - NoclipSpeed * 2, noclipping, noclipping, noclipping)
				end
				if IsDisabledControlPressed(0, 44) then -- Q
					local coords = GetEntityCoords(PlayerPedId())
					SetEntityVelocity(PlayerPedId(), 0.0, 0.0, 0.0)
					SetEntityRotation(PlayerPedId(), 0.0, 0.0, 0.0, 0, false)
					SetEntityHeading(PlayerPedId(), heading)
					SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z + NoclipSpeed, noclipping, noclipping, noclipping)
				end
			end

			if IsDisabledControlJustReleased(0, 21) then -- Shift
				NoclipSpeed = NoclipSpeed + 1.0
		
				if NoclipSpeed > 15.0 then
					NoclipSpeed = 1.0
				end
			end

			RoundedNoClipSpeed = tonumber(string.format("%.0f", NoclipSpeed))

            Wait(0)
	    end
	end)
end

local PVRemoteControlButtons = {
	{
		["label"] = "Toggle Camera",
		["button"] = "~INPUT_DETONATE~"
	},
}

local BottomTextEntries = {}
local YLoc = 1.02

Citizen.CreateThread(function()
	while not killmenu do
		
		for i = 1, #BottomTextEntries do
			CurEntry = BottomTextEntries[i]
	        XWidth = CrownMenu.GetTextWidth(CurEntry, 4, 0.45) + 0.01
			DrawY = i * 0.0455
			
			if XWidth < 0.12 then
				XWidth = 0.12
			end

			CrownMenu.DrawRect(0.5, YLoc - DrawY, XWidth, 0.04, { r = 0, g = 0, b = 0, a = 200 })

			CrownMenu.DrawRect(0.5, YLoc - 0.019 - DrawY, XWidth, 0.002, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })

			CrownMenu.DrawText(CurEntry, { 0.500, YLoc - 0.015 - DrawY }, {255, 255, 255, 255}, 0.45, 4, 1)

		end

		BottomTextEntries = {}
		Wait(0)
	end
end)

function CrownMenu.DrawBottomText(text) 
	table.insert(BottomTextEntries, #BottomTextEntries + 1, text)
end

local prevframes, prevtime, curtime, curframes, fps = 0, 0, 0, 0, 0

function GetFPS()
	curtime = GetGameTimer()
	curframes = GetFrameCount()
	
	if (curtime - prevtime) > 1000 then
		fps = (curframes - prevframes) - 1              
		prevtime = curtime
		prevframes = curframes
	end

	if fps > 1000 then
		return "N/A"
	end

	return fps
end

BulletCoords = {}

function DeleteInSeconds(Table, Time)
	Citizen.CreateThread(function()
		Wait(Time)
		table.remove(Table, 1)
	end)
end

local Targets = 0

-- PTFX Loop for any niggers seeing this we made everything here name 1 menu you seen this from faggots niggers we have your ip just from injecting this menu kys kys kys kys kys 


Citizen.CreateThread(function()
	while not killmenu do
		RemoveParticleFx("scr_indep_firework_trailburst", 1)
		RemoveParticleFx("scr_ex1_plane_exp_sp", 1)
		RemoveParticleFx("scr_clown_appears", 1)
		RemoveParticleFx("td_blood_throat", 1)

		OnlinePlayers = GetActivePlayers()

		if CrownVariables.AllOnlinePlayers.ParicleEffects.HugeExplosionSpam then
			for i = 1, #OnlinePlayers do 

				local ped = GetPlayerPed(OnlinePlayers[i])
				local pedcoords = GetEntityCoords(ped)
				
				RequestNamedPtfxAsset("scr_exile1")
		    
				UseParticleFxAssetNextCall("scr_exile1")
				StartNetworkedParticleFxNonLoopedAtCoord("scr_ex1_plane_exp_sp", pedcoords, 0.0, 0.0, 0.0, 20.0, false, false, false, false)

			end
		end
		
		if CrownVariables.AllOnlinePlayers.ParicleEffects.ClownLoop then
			for i = 1, #OnlinePlayers do 
			
				local ped = GetPlayerPed(OnlinePlayers[i])
				local pedcoords = GetEntityCoords(ped)

				RequestNamedPtfxAsset("scr_rcbarry2")
	
				UseParticleFxAssetNextCall("scr_rcbarry2")
				StartNetworkedParticleFxNonLoopedAtCoord("scr_clown_appears", pedcoords, 0.0, 0.0, 0.0, 20.0, false, false, false, false)

			end
		end

		if CrownVariables.AllOnlinePlayers.ParicleEffects.BloodLoop then
			for i = 1, #OnlinePlayers do 
			
				local ped = GetPlayerPed(OnlinePlayers[i])
				local pedcoords = GetEntityCoords(ped)

				RequestNamedPtfxAsset("core")
	
				UseParticleFxAssetNextCall("core")
				StartNetworkedParticleFxNonLoopedAtCoord("td_blood_throat", pedcoords, 0.0, 0.0, 0.0, 200.0, false, false, false, false)

			end
		end

		if CrownVariables.AllOnlinePlayers.ParicleEffects.FireworksLoop then
			for i = 1, #OnlinePlayers do 
			
				local ped = GetPlayerPed(OnlinePlayers[i])
				local pedcoords = GetEntityCoords(ped)

				RequestNamedPtfxAsset("scr_indep_fireworks")
	
				UseParticleFxAssetNextCall("scr_indep_fireworks")
				StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_firework_trailburst", pedcoords, 0.0, 0.0, 0.0, 200.0, false, false, false, false)

			end
		end

		Wait(750)
	end
end)

-- Secondary Loop

Citizen.CreateThread(function()
	while not killmenu do
		if CrownVariables.WeaponOptions.AimBot.Enabled and CrownVariables.WeaponOptions.AimBot.DrawFOV and not IsControlPressed(0, 37) then
			if not HasStreamedTextureDictLoaded('mpmissmarkers256') then 
				RequestStreamedTextureDict('mpmissmarkers256', true) 
			end

			CrownMenu.DrawSprite('mpmissmarkers256', 'corona_shade', 0.5, 0.5, CrownVariables.WeaponOptions.AimBot.FOV, CrownVariables.WeaponOptions.AimBot.FOV * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, 0.0, 0, 0, 0, 100)
		end


		CrownMenu.ScreenWidth, CrownMenu.ScreenHeight = Citizen.InvokeNative(0x873C9F3104101DD3, Citizen.PointerValueInt(), Citizen.PointerValueInt())
		CrownMenu.rgb = CrownMenu.RGBRainbow(1)
		
		if CrownVariables.MenuOptions.Watermark then
			DisplayText = "Crown Menu | FPS: " .. GetFPS() .. " | Resource: " ..GetCurrentResourceName()
			CrownMenu.DrawBottomText(DisplayText)
		end
		
		if noclipping then
			CrownMenu.DrawBottomText("Noclip | Speed "..RoundedNoClipSpeed.. "m")
		end
		
		if CrownVariables.SelfOptions.InfiniteCombatRoll then
			for i = 0, 3 do
				StatSetInt(GetHashKey("mp" .. i .. "_shooting_ability"), 9999, true)
				StatSetInt(GetHashKey("sp" .. i .. "_shooting_ability"), 9999, true)
			end
		end

		if CrownVariables.VehicleOptions.speedometer then
			if IsPedInAnyVehicle(PlayerPedId()) then
				local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
				local carSpeed = GetEntitySpeed(veh) * 2.236936 -- convert to mph
				local carkphSpeed = GetEntitySpeed(veh) * 3.6 -- convert to kph
				carspeedround = tonumber(string.format("%.0f", carSpeed))
				carkphspeedround = tonumber(string.format("%.0f", carkphSpeed))
		
				CrownMenu.DrawBottomText("MPH " .. carspeedround .. " |  KPH " .. carkphspeedround)
			end
		end

		if IsDisabledControlPressed(0, 19) and IsDisabledControlPressed(0, 29) then -- Reset Open Key
			Ham.printStr("Crown Menu", "Keybind Reset\n")
			openKey = 344
		end
		
		if IsDisabledControlPressed(0, 19) and IsDisabledControlPressed(0, 73) then -- Kill Menu
			killmenu = true
		end

		if IsDisabledControlPressed(0, 19) and IsDisabledControlPressed(0, 80) then -- Kill Menu
			CrownMenu.UI.GTAInput = true
		end

		rgb = CrownMenu.RGBRainbow(1)

		year, month, day, hour, minute, second = GetLocalTime()

		if CrownVariables.WeaponOptions.NoRecoil and IsDisabledControlPressed(0, 24) then
			local GameplayCamPitch = GetGameplayCamRelativePitch()
			SetGameplayCamRelativePitch(GameplayCamPitch, 0.0)
		end

		if CrownVariables.WeaponOptions.Tracers then
			local _, weapon = GetCurrentPedWeapon(PlayerPedId())
			if weapon ~= -1569615261 then
				local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
				local launchPos = GetEntityCoords(wepent)
				local targetPos = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 2000.0)
				if IsPedShooting(PlayerPedId()) then
					Hit, ImpactCoord = GetPedLastWeaponImpactCoord(PlayerPedId())
					LineToInsertOn = tablelength(BulletCoords) + 1
					Coords = table.pack(launchPos, targetPos, ImpactCoord)
					table.insert(BulletCoords, LineToInsertOn, Coords)
					DeleteInSeconds(BulletCoords, 3 * 1000)
				end
			end
	
			for i = 1, #BulletCoords do
				CurBullet = BulletCoords[i]
				if CurBullet ~= nil then     
					launchPos = CurBullet[1]
					TargetPos = CurBullet[2]
					ImpactCoord = CurBullet[3]			
					Lx, Ly, Lz = table.unpack(ImpactCoord)

					DrawMarker(28, ImpactCoord, 0, 0, 0, 0, 0, 0, 0.051, 0.051, 0.051, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 200, 0, 0, 0, 0)

					if Lx ~= 0.0 and Ly ~= 0.0 and Lz ~= 0.0 then
						DrawLine(launchPos.x, launchPos.y, launchPos.z, ImpactCoord.x, ImpactCoord.y, ImpactCoord.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
					else
						DrawLine(launchPos.x, launchPos.y, launchPos.z, TargetPos.x, TargetPos.y, TargetPos.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
					end
				end
			end
		end

		if IsControlJustReleased(0, tonumber(CrownVariables.Keybinds.NoClipKey)) then -- No Clip
			NoClip()
		end

		if CrownVariables.Keybinds.RefilHealthKey and IsDisabledControlJustPressed(0, tonumber(CrownVariables.Keybinds.RefilHealthKey)) then
            SetEnitityHealth(PlayerPedId(), 200)
		end

		if CrownVariables.Keybinds.RefilArmourKey and IsDisabledControlJustPressed(0, tonumber(CrownVariables.Keybinds.RefilArmourKey)) then
            SetPedArmour(PlayerPedId(), 100)
		end

		if IsControlPressed(0, tonumber(CrownVariables.Keybinds.DriftMode)) then
			SetVehicleReduceGrip(GetVehiclePedIsUsing(PlayerPedId()), true)
		else
			SetVehicleReduceGrip(GetVehiclePedIsUsing(PlayerPedId()), false)
		end

		if killmenu then
            break
		end
		
		if CrownVariables.MiscOptions.UnlockAllVehicles then
			for Vehicle in EnumerateVehicles() do
				SetVehicleDoorsLockedForPlayer(Vehicle, PlayerId(), false)
			end
		end

		if CrownVariables.OnlinePlayer.TrackingPlayer then

			local coords = GetEntityCoords(GetPlayerPed(CrownVariables.OnlinePlayer.TrackingPlayer))
			SetNewWaypoint(coords.x, coords.y)
		end

		if CrownVariables.VehicleOptions.PersonalVehicleCam then
			
			local camCoords = GetCamCoord(CrownVariables.VehicleOptions.PersonalVehicleCam)

			SetFocusEntity(CrownVariables.VehicleOptions.PersonalVehicle)
			
			SetCamRot(CrownVariables.VehicleOptions.PersonalVehicleCam, -2.0, 0.0, GetEntityHeading(CrownVariables.VehicleOptions.PersonalVehicle), 0)
		end

		if CrownVariables.VehicleOptions.rainbowcar then
			local vehicle = GetVehiclePedIsIn(PlayerPedId())
			SetVehicleCustomPrimaryColour(vehicle, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b)
			SetVehicleCustomSecondaryColour(vehicle, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b)
			SetVehicleTyreSmokeColor(vehicle, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b)
		end
		
		if rgbhud then
			ReplaceHudColourWithRgba(116, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
		end

		if CrownVariables.VehicleOptions.vehgodmode then
			SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true)
		end

		if CrownVariables.VehicleOptions.AutoClean then
			SetVehicleDirtLevel(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
		end

		if CrownVariables.VehicleOptions.PersonalVehicle == false or DoesEntityExist(CrownVariables.VehicleOptions.PersonalVehicle) == false then
			CrownVariables.VehicleOptions.PersonalVehicleESP = false
			CrownVariables.VehicleOptions.PersonalVehicleMarker = false
			PVLocked = false
		end

		if CrownVariables.VehicleOptions.PersonalVehicleCam then
			RenderScriptCams(true, false, 0, true, false)
		end

		if CrownVariables.SelfOptions.FreezeWantedLevel then
			if CrownVariables.SelfOptions.FrozenWantedLevel > 0 then
				SetPlayerWantedCentrePosition(PlayerId(), GetEntityCoords(PlayerPedId()))
				SetPlayerWantedLevel(PlayerId(), CrownVariables.SelfOptions.FrozenWantedLevel + 1, true)
				SetPlayerWantedLevelNow(PlayerId())
				SetPlayerWantedLevel(PlayerId(), CrownVariables.SelfOptions.FrozenWantedLevel, true)
				SetPlayerWantedLevelNow(PlayerId())
			else
				SetPlayerWantedLevel(PlayerId(), 0, true)
				SetPlayerWantedLevelNow(PlayerId())
			end
		end

		if CrownVariables.VehicleOptions.PersonalVehicleESP then
			plycoords = GetEntityCoords(PlayerPedId())
			coords = GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle)
			
			local retval, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

			local DistanceToCar = GetDistanceBetweenCoords(plycoords.x, plycoords.y, plycoords.z, coords.x, coords.y, coords.z, true)

			CrownMenu.DrawText("Personal Vehicle\nDistance: " .. string.format("%.2f", DistanceToCar) .. "m", { screenX, screenY }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.45, 4, 1)
		end

		if CrownVariables.VehicleOptions.PersonalVehicleMarker then
			coords = GetEntityCoords(CrownVariables.VehicleOptions.PersonalVehicle)
			if blip == nil then
				blip = AddBlipForCoord(coords.x, coords.y, coords.z)
				SetBlipSprite(blip, 1)
				SetBlipDisplay(blip, 4)
				SetBlipScale(blip, 0.9)
				SetBlipColour(blip, 3)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Personal Vehicle")
				EndTextCommandSetBlipName(blip)
			end

			SetBlipDisplay(blip, 2)
			SetBlipCoords(blip, coords.x, coords.y, coords.z)
		else 
			SetBlipDisplay(blip, 0)
		end

		if CrownVariables.VehicleOptions.Waterproof then
            SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId()), true, true, true)
		end

		if CrownVariables.VehicleOptions.InstantBreaks then
			if IsDisabledControlPressed(0, 33) and IsPedInAnyVehicle(PlayerPedId()) then
				local ped = GetPlayerPed(-1)
				local playerVeh = GetVehiclePedIsIn(ped, false)

				SetVehicleForwardSpeed(playerVeh, 0.0)
			end
		end

	    if CrownVariables.VehicleOptions.EasyHandling and IsPedInAnyVehicle(PlayerPedId()) then
			local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
			SetVehicleGravityAmount(veh, 60.0)
		end

		if CrownVariables.VehicleOptions.DriveOnWater then
			x, y, z = table.unpack(GetEntityCoords(GetPlayersLastVehicle()))
			sucess, z = GetWaterHeight(x, y, z)
			if sucess and CrownVariables.VehicleOptions.DriveOnWaterProp then
				SetEntityVisible(CrownVariables.VehicleOptions.DriveOnWaterProp, false, false)
				SetEntityCoords(CrownVariables.VehicleOptions.DriveOnWaterProp, x, y, z)
				SetEntityHeading(CrownVariables.VehicleOptions.DriveOnWaterProp, GetEntityHeading(PlayerPedId()))
			elseif not sucess then
				SetEntityCoords(CrownVariables.VehicleOptions.DriveOnWaterProp, x, y, z - 100.5)
			end
		end

		if CrownVariables.VehicleOptions.AlwaysWheelie then
			local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
			if IsPedInAnyVehicle(PlayerPedId()) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
				SetVehicleWheelieState(veh, 129)
			end
		end

		if CrownVariables.VehicleOptions.speedboost then
			DisableControlAction(0, 86, true)
			if IsDisabledControlPressed(0, 86) and IsPedInAnyVehicle(PlayerPedId()) then
				local ped = GetPlayerPed(-1)
				local playerVeh = GetVehiclePedIsIn(ped, false)
				
				SetVehicleForwardSpeed(playerVeh, 336.0)
			end
		end

		if CrownVariables.VehicleOptions.activeenignemulr then
			local vehicle = GetPlayersLastVehicle()
			local curractiveenignemulrIndex = CrownVariables.VehicleOptions.curractiveenignemulrIndex
			if curractiveenignemulrIndex == 1 then
				SetVehicleEnginePowerMultiplier(vehicle, 2.0)
			elseif curractiveenignemulrIndex == 2 then
			    SetVehicleEnginePowerMultiplier(vehicle, 4.0)
			elseif curractiveenignemulrIndex == 3 then
			    SetVehicleEnginePowerMultiplier(vehicle, 8.0)
			elseif curractiveenignemulrIndex == 4 then
			    SetVehicleEnginePowerMultiplier(vehicle, 16.0)
			elseif curractiveenignemulrIndex == 5 then
			    SetVehicleEnginePowerMultiplier(vehicle, 32.0)
			elseif curractiveenignemulrIndex == 6 then
			    SetVehicleEnginePowerMultiplier(vehicle, 64.0)
			elseif curractiveenignemulrIndex == 7 then
			    SetVehicleEnginePowerMultiplier(vehicle, 128.0)
			elseif curractiveenignemulrIndex == 8 then
			    SetVehicleEnginePowerMultiplier(vehicle, 256.0)
			elseif curractiveenignemulrIndex == 9 then
			    SetVehicleEnginePowerMultiplier(vehicle, 512.0)
			elseif curractiveenignemulrIndex == 10 then
			    SetVehicleEnginePowerMultiplier(vehicle, 1024.0)
			end
		end

		if CrownVariables.MiscOptions.ESPBox then
            local PlayerList = GetActivePlayers()
			for i = 1, #PlayerList do
				local curplayerped = GetPlayerPed(PlayerList[i])

				bone = GetEntityBoneIndexByName(curplayerped, "SKEL_HEAD")
				x,y,z = table.unpack(GetPedBoneCoords(curplayerped, bone, 0.0, 0.0, 0.0))
				px,py,pz = table.unpack(GetGameplayCamCoord())

				if GetDistanceBetweenCoords(x, y, z, px, py, pz, true) < CrownVariables.MiscOptions.ESPDistance then
					if curplayerped ~= PlayerPedId() and  IsEntityOnScreen(curplayerped) and not IsPedDeadOrDying(curplayerped) then
						z = z + 0.9
						local Distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true) * 0.002 / 2
						if Distance < 0.0042 then
							Distance = 0.0042
						end
						
						if CrownVariables.MiscOptions.ESPMenuColours then
							color = { r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b}
						else
							color = { r = 255, g = 255, b = 255}
						end
	
						retval, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	
						width = 0.00045
						height = 0.0023
	
						DrawRect(_x, _y, width / Distance, 0.0015, color.r, color.g, color.b, 200)
						DrawRect(_x, _y + height / Distance, width / Distance, 0.0015, color.r, color.g, color.b, 200)
						DrawRect(_x + width / 2 / Distance, _y + height / 2 / Distance , 0.001, height / Distance, color.r, color.g, color.b, 200)
						DrawRect(_x - width / 2 / Distance, _y + height / 2 / Distance , 0.001, height / Distance, color.r, color.g, color.b, 200)
						
						health = GetEntityHealth(curplayerped)
						if health > 200 then
							health = 200
						end

						DrawRect(_x - 0.00028 / Distance, _y + height / 2 / Distance, 0.0016 / Distance * 0.015, height / Distance, 0, 0, 0, 200)
						DrawRect(_x - 0.00028 / Distance, _y + height / Distance - GetEntityHealth(curplayerped) / 175000 / Distance,  0.0016 / Distance * 0.015, GetEntityHealth(curplayerped) / 87500 / Distance, 0, 255, 0, 200)
					
					end
				end
			end
		end
		
		if CrownVariables.MiscOptions.ESPName then
            local PlayerList = GetActivePlayers()
			for i = 1, #PlayerList do
				local curplayerped = GetPlayerPed(PlayerList[i])

				x,y,z = table.unpack(GetPedBoneCoords(curplayerped, 0, 0.0, 0.0, -0.9))
				px,py,pz = table.unpack(GetGameplayCamCoord())

				if GetDistanceBetweenCoords(x, y, z, px, py, pz, true) < CrownVariables.MiscOptions.ESPDistance then
					local retval, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
					local Distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true) * 0.0002
					if Distance < 1 then
						Distance = 1
					end
					CrownMenu.DrawText(GetPlayerName(PlayerList[i]), { _x, _y }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5 / Distance, 4, 1, 0)	
				end
			end
		end

		if CrownVariables.MiscOptions.ESPBones then
			local playerlist = GetActivePlayers()
			for i = 1, #playerlist do
				local curplayer = playerlist[i]
				local curplayerped = GetPlayerPed(curplayer)
				local PlayerCoords = GetEntityCoords(curplayerped)
				x,y,z = table.unpack(PlayerCoords)

				local RightShoulderBone = GetPedBoneIndex(curplayerped, 31086)
				local RightElbowBone = GetPedBoneIndex(curplayerped, 2992)
				local RightHand = GetPedBoneIndex(curplayerped, 28422)

				local LeftElbowBone = GetPedBoneIndex(curplayerped, 22711)
				local LeftHand = GetPedBoneIndex(curplayerped, 18905)

				local rightshoulder = GetWorldPositionOfEntityBone(curplayerped, RightShoulderBone, 0.0, 0.0, 0.0)
				local rightelbow = GetWorldPositionOfEntityBone(curplayerped, RightElbowBone, 0.0, 0.0, 0.0)
				local rightelhand = GetWorldPositionOfEntityBone(curplayerped, RightHand, 0.0, 0.0, 0.0)
				
				local leftelbow = GetWorldPositionOfEntityBone(curplayerped, LeftElbowBone, 0.0, 0.0, 0.0)
				local lefthand = GetWorldPositionOfEntityBone(curplayerped, LeftHand, 0.0, 0.0, 0.0)

				local pelvis = GetWorldPositionOfEntityBone(curplayerped, GetPedBoneIndex(curplayerped, 11816), 0.0, 0.0, 0.0)
				local rightknee = GetWorldPositionOfEntityBone(curplayerped, GetPedBoneIndex(curplayerped, 16335), 0.0, 0.0, 0.0)
				local leftknee = GetWorldPositionOfEntityBone(curplayerped, GetPedBoneIndex(curplayerped, 46078), 0.0, 0.0, 0.0)
				local leftfoot = GetWorldPositionOfEntityBone(curplayerped, GetPedBoneIndex(curplayerped, 14201), 0.0, 0.0, 0.0)
				local rightfoot = GetWorldPositionOfEntityBone(curplayerped, GetPedBoneIndex(curplayerped, 52301), 0.0, 0.0, 0.0)
				
				DrawLine(rightshoulder.x, rightshoulder.y, rightshoulder.z, rightelbow.x, rightelbow.y, rightelbow.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				DrawLine(rightelbow.x, rightelbow.y, rightelbow.z, rightelhand.x, rightelhand.y, rightelhand.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
				DrawLine(rightshoulder.x, rightshoulder.y, rightshoulder.z, leftelbow.x, leftelbow.y, leftelbow.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				DrawLine(leftelbow.x, leftelbow.y, leftelbow.z, lefthand.x, lefthand.y, lefthand.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
				DrawLine(rightshoulder.x, rightshoulder.y, rightshoulder.z, pelvis.x, pelvis.y, pelvis.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				DrawLine(rightknee.x, rightknee.y, rightknee.z, pelvis.x, pelvis.y, pelvis.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				DrawLine(leftknee.x, leftknee.y, leftknee.z, pelvis.x, pelvis.y, pelvis.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
				DrawLine(rightknee.x, rightknee.y, rightknee.z, rightfoot.x, rightfoot.y, rightfoot.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				DrawLine(leftknee.x, leftknee.y, leftknee.z, leftfoot.x, leftfoot.y, leftfoot.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
				ResetEntityAlpha(curplayerped)
				SetEntityAlpha(curplayerped, 200, true)
			end
		end

		if CrownVariables.MiscOptions.ESPLines then
			local pedcoords = GetEntityCoords(PlayerPedId())

			local playerlist = GetActivePlayers()
			for i = 1, #playerlist do
				local curplayer = playerlist[i]
				local curplayerped = GetPlayerPed(curplayer)
				local PlayerCoords = GetEntityCoords(curplayerped)
				
				DrawLine(pedcoords.x, pedcoords.y, pedcoords.z, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
			end
		end
		
		if CrownVariables.VehicleOptions.activetorquemulr then
			local vehicle = GetPlayersLastVehicle()
			local curractivetorqueIndex = CrownVariables.VehicleOptions.curractivetorqueIndex
			if curractivetorqueIndex == 1 then
				SetVehicleEngineTorqueMultiplier(vehicle, 2.0)
			elseif curractivetorqueIndex == 2 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 4.0)
			elseif curractivetorqueIndex == 3 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 8.0)
			elseif curractivetorqueIndex == 4 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 16.0)
			elseif curractivetorqueIndex == 5 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 32.0)
			elseif curractivetorqueIndex == 6 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 64.0)
			elseif curractivetorqueIndex == 7 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 128.0)
			elseif curractivetorqueIndex == 8 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 256.0)
			elseif curractivetorqueIndex == 9 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 512.0)
			elseif curractivetorqueIndex == 10 then
			    SetVehicleEngineTorqueMultiplier(vehicle, 1024.0)
			end
		end

		if CrownVariables.OnlinePlayer.cargoplaneloop then
			local coords = GetEntityCoords(GetPlayerPed(CrownVariables.OnlinePlayer.CargodPlayer))
			SpawnVehAtCoords("cargoplane", coords)
		end

		if CrownVariables.OnlinePlayer.attachtoplayer then
			local self = PlayerPedId()
			
			AttachEntityToEntity(self, GetPlayerPed(CrownVariables.OnlinePlayer.attatchedplayer), 0, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 0, true)
		end
		
		if CrownVariables.ScriptOptions.BlockBlackScreen then
            DoScreenFadeIn(0)
		end

		if CrownVariables.ScriptOptions.BlockPeacetime then
			TriggerEvent("AOP:SendPT", false)
			TriggerEvent("yoda:peacetime", false)
			TriggerEvent("Badssentials:SetPT", false)
		end

		if CrownVariables.SelfOptions.infstamina then
            RestorePlayerStamina(PlayerId(), GetPlayerSprintStaminaRemaining(PlayerId()))
		end

		if CrownVariables.SelfOptions.superrun then
			if IsDisabledControlPressed(0, 21) and not IsPedRagdoll(PlayerPedId()) then
			    local x, y, z = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 30.0, GetEntityVelocity(PlayerPedId())[3]) - GetEntityCoords(PlayerPedId())

			    SetEntityVelocity(PlayerPedId(), x, y, z)
			end
		end

		if CrownVariables.MiscOptions.FlyingCars then
            for vehicle in EnumerateVehicles() do
                NetworkRequestControlOfEntity(vehicle)
                ApplyForceToEntity(vehicle, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
            end
		end

		if CrownVariables.MiscOptions.GlifeHack then
            for ped in EnumeratePeds() do
				if not IsPedAPlayer(ped) and ped ~= PlayerPedId() then
					Wait(1)
					RequestControlOnce(ped)
					SetEntityHealth(ped, 0)
					SetEntityCoords(ped, GetEntityCoords(PlayerPedId()))
				end
			end
		end

		if CrownVariables.OnlinePlayer.freezeplayer then
			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.playertofreeze)

			if not HasAnimDictLoaded("reaction@shove") then
				RequestAnimDict("reaction@shove")
				while not HasAnimDictLoaded("reaction@shove") do
					Wait(0)
				end        
			end

			TaskPlayAnim(ped, "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
		end

		if CrownVariables.AllOnlinePlayers.freezeserver then
			ActivePlayers = GetActivePlayers()
			for i = 1, #ActivePlayers do
				if CrownVariables.AllOnlinePlayers.IncludeSelf and ActivePlayers[i] ~= PlayerId() then
					local ped = GetPlayerPed(ActivePlayers[i])
					FreezeEntityPosition(CrownVariables.OnlinePlayer.playertofreeze, true)
					ClearPedTasksImmediately(ped)
				elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
					local ped = GetPlayerPed(ActivePlayers[i])
					FreezeEntityPosition(CrownVariables.OnlinePlayer.playertofreeze, true)
					ClearPedTasksImmediately(ped)
				end
			end
		end
		
		if CrownVariables.AllOnlinePlayers.tugboatrainoverplayers then
			for i = 1, #GetActivePlayers() do
				if CrownVariables.AllOnlinePlayers.IncludeSelf and GetActivePlayers()[i] ~= PlayerId() then
					coords = GetEntityCoords(GetPlayerPed(GetActivePlayers()[i]))
					
					while not HasModelLoaded(GetHashKey("tug")) and not killmenu do
						RequestModel(GetHashKey("tug"))
						Wait(1)
					end
	
					CreateVehicle(GetHashKey("tug"), coords.x, coords.y, coords.z + 300.0, 90.0, 1, 1)	
				elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
					coords = GetEntityCoords(GetPlayerPed(GetActivePlayers()[i]))
					
					while not HasModelLoaded(GetHashKey("tug")) and not killmenu do
						RequestModel(GetHashKey("tug"))
						Wait(1)
					end
	
					CreateVehicle(GetHashKey("tug"), coords.x, coords.y, coords.z + 300.0, 90.0, 1, 1)	
				end
			end
		end
		
		if CrownVariables.WeaponOptions.RageBot then
			if IsDisabledControlPressed(0, 24) then
				for k in EnumeratePeds() do
					if k ~= PlayerPedId() then 
						RageShoot(k) 
					end
				end
			end
		end

		if CrownVariables.WeaponOptions.Spinbot and not noclipping then
			if GetEntityVelocity(PlayerPedId()) == vector3(0, 0, 0) then
				SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 20)
				for Ped in EnumeratePeds() do
					if Ped ~= PlayerPedId() and HasEntityClearLosToEntityInFront(PlayerPedId(), Ped) then
						x, y, z = table.unpack(GetEntityCoords(Ped)) 
						SetPedShootsAtCoord(PlayerPedId(), x, y, z, true)
						RageShoot(Ped)
					end
				end
			end
		end

		if CrownVariables.WeaponOptions.InfAmmo then
			if IsPedShooting(PlayerPedId()) then
				local __, weapon = GetCurrentPedWeapon(PlayerPedId())
				ammo = GetAmmoInPedWeapon(PlayerPedId(), weapon)
				SetPedAmmo(PlayerPedId(), weapon, ammo + 1)
			end
		end

		if CrownVariables.WeaponOptions.NoReload then
			if IsPedShooting(PlayerPedId()) then
				PedSkipNextReloading(PlayerPedId())
				MakePedReload(PlayerPedId())
			end
		end

		if CrownVariables.WeaponOptions.AimBot.Enabled then
			FOV = CrownVariables.WeaponOptions.AimBot.FOV

			--[[
			DrawRect(0.5 - FOV / 2, 0.5, 0.01, 0.515, 255, 80, 80, 100)
			DrawRect(0.5 + FOV / 2, 0.5, 0.01, 0.515, 255, 80, 80, 100)
			DrawRect(0.5, 0.5 - FOV / 1.2, 0.49, 0.015, 255, 80, 80, 100)
			DrawRect(0.5, 0.5 + FOV / 1.2, 0.49, 0.015, 255, 80, 80, 100)
			]]
	
			local success, PedAimingAt = GetEntityPlayerIsFreeAimingAt(PlayerId())
	
			if GetEntityType(PedAimingAt) == 1 then
				CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult = { x = 0, y = 0}
				CrownVariables.WeaponOptions.AimBot.Targeting.Target = PedAimingAt
			end
	
			if IsPedDeadOrDying(CrownVariables.WeaponOptions.AimBot.Targeting.Target) then
				CrownVariables.WeaponOptions.AimBot.Targeting.Target = nil
				CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult = { x = 1.0, y = 1.0}
			end
	
			for Ped in EnumeratePeds() do
				SuccessAimbot = true
				local x, y, z = table.unpack(GetEntityCoords(Ped))
				local _, _x, _y = World3dToScreen2d(x, y, z)

				if GetEntityModel(Ped) ~= 111281960 then
					if not IsPedDeadOrDying(Ped) then
						local _, _xx, _xy = World3dToScreen2d(table.unpack(GetEntityCoords(CrownVariables.WeaponOptions.AimBot.Targeting.Target)))
		
						if _x > 0.5 - FOV / 2 and _x < 0.5 + FOV / 2 and _y > 0.5 - FOV / 2 and _y < 0.5 + FOV / 2 then
							if Ped ~= PlayerPedId() then
								if CrownVariables.WeaponOptions.AimBot.OnlyPlayers then
									if IsPedAPlayer(Ped) then
										SuccessAimbot = true
									else
										SuccessAimbot = false
									end
								end
								if SuccessAimbot and CrownVariables.WeaponOptions.AimBot.InvisibilityCheck then
									if IsEntityVisible(Ped) then
										SuccessAimbot = true
									else
										SuccessAimbot = false
									end
								end
								if SuccessAimbot and CrownVariables.WeaponOptions.AimBot.IgnoreFriends then
									for i = 1, #FriendsList do
										pped = GetPlayerPed(FriendsList[i])
										if Ped == pped then
											SuccessAimbot = false
										end
									end
								end

								if SuccessAimbot then
									CrosshairCheck(Ped, _x, _y)
								end
							end
						end
						
						--CrownMenu.DrawRect(_xx, _xy, 0.06, 0.02 * CrownMenu.ScreenWidth / CrownMenu.ScreenHeight, { r = 20, g = 20, b = 255, a = 150 })
						
						if _xx > 0.5 - FOV / 2 and _xx < 0.5 + FOV / 2 and _xy > 0.5 - FOV / 2 and _xy < 0.5 + FOV / 2 then
							
						else
							CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult = { x = 1.0, y = 1.0}
						end
					end
				end
			end
			
			if CrownVariables.WeaponOptions.AimBot.ShowTarget and CrownVariables.WeaponOptions.AimBot.Targeting.Target ~= nil then
				local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
				local launchPos = GetEntityCoords(wepent)

				DrawLine(launchPos, GetEntityCoords(CrownVariables.WeaponOptions.AimBot.Targeting.Target), CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
			end
	
			if IsEntityOnScreen(CrownVariables.WeaponOptions.AimBot.Targeting.Target) and IsPedShooting(PlayerPedId()) and IsPlayerFreeAiming(PlayerId()) then
				local coords = GetEntityCoords(CrownVariables.WeaponOptions.AimBot.Targeting.Target)
				RequestCollisionAtCoord(coords.x, coords.y, coords.z)
				
				ShootAtBone(CrownVariables.WeaponOptions.AimBot.Targeting.Target, CrownVariables.WeaponOptions.AimBot.Bone, 50)
			end

		end

		if CrownVariables.WeaponOptions.RapidFire then
            DoRapidFireTick()
		end
		
		if CrownVariables.WeaponOptions.BulletOptions.Enabled then
			if IsPedShooting(PlayerPedId()) then
				local _, weapon = GetCurrentPedWeapon(PlayerPedId())
				local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
				local launchPos = GetEntityCoords(wepent)
				local targetPos = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 200.0)
				local weaponbullet = CrownVariables.WeaponOptions.BulletOptions.WeaponBulletName
			
				ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, GetHashKey(weaponbullet), PlayerPedId(), true, true, 24000.0)
			end
		end

		if CrownVariables.WeaponOptions.TriggerBot then
			local hasTarget, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
			
            if hasTarget and IsEntityAPed(target) then
				local boneTarget = GetPedBoneCoords(target, 0, 0.0, -0.2, 0.0)
				x, y, z = table.unpack(boneTarget)
				SetPedShootsAtCoord(PlayerPedId(), x, y, z, true)
            end
		end

		if CrownVariables.WeaponOptions.ExplosiveAmmo then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
				AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
            end
		end

		if CrownVariables.WeaponOptions.DelGun then
			if IsPlayerFreeAiming(PlayerId()) then
                local entity = getEntity(PlayerId())
                if GetEntityType(entity) == 2 or 3 then
                    if aimCheck(GetPlayerPed(-1)) then
                        SetEntityAsMissionEntity(entity, true, true)
                        DeleteEntity(entity)
                    end
                end
            end
		end

		if CrownVariables.WeaponOptions.OneShot then
			SetWeaponDamageModifier(GetSelectedPedWeapon(PlayerPedId()), 1000.0)
		else
			SetWeaponDamageModifier(GetSelectedPedWeapon(PlayerPedId()), 1.0)
		end
		
		if CrownVariables.SelfOptions.noragdoll then
			SetPedCanRagdoll(PlayerPedId(), false)
		else
			SetPedCanRagdoll(PlayerPedId(), true)
		end

		if CrownVariables.SelfOptions.superjump then
			SetSuperJumpThisFrame(PlayerId())
		end

		if CrownVariables.SelfOptions.MoonWalk then
			if IsDisabledControlPressed(0, 21) and IsDisabledControlPressed(0, 32) then
				forwardback = -9.8
			elseif IsPedWalking(PlayerPedId()) then
				forwardback = -3.6
			else
				forwardback = 0.0
			end

			local x, y, z = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, forwardback, GetEntityVelocity(PlayerPedId())[3]) - GetEntityCoords(PlayerPedId())

			SetEntityVelocity(PlayerPedId(), x, y, z)
		end
		
		if CrownVariables.OnlinePlayer.messagelooping then
			if NetworkIsPlayerConnected(CrownVariables.OnlinePlayer.messageloopplayer) then

				TriggerServerEvent("_chat:messageEntered", GetPlayerName(CrownVariables.OnlinePlayer.messageloopplayer), { 255, 255, 255 }, CrownVariables.OnlinePlayer.messagetosend)
				
			else

				CrownVariables.OnlinePlayer.messagelooping = false
				CrownVariables.OnlinePlayer.messageloopplayer = nil
				CrownVariables.OnlinePlayer.messagetosend = "."

			end
		end

		if CrownVariables.SelfOptions.disableobjectcollisions then
			for door in EnumerateObjects() do
				
				SetEntityCollision(door, false, true)

			end
		end

		if CrownVariables.SelfOptions.disablepedcollisions then
			for ped in EnumeratePeds() do
				if ped ~= PlayerPedId() and IsPedAPlayer(ped) ~= true then
					SetEntityCollision(ped, false, true)
				end
			end
		end

		if CrownVariables.SelfOptions.disablevehiclecollisions then
			local ped = PlayerPedId()

			for vehicle in EnumerateVehicles() do
			    SetEntityCollision(vehicle, false, true)
			end
		end

		if CrownVariables.SelfOptions.forceradar then
			DisplayRadar(true)
		end

		if CrownVariables.SelfOptions.playercoords then

			local entity = IsPedInAnyVehicle(PlayerPedId()) and GetVehiclePedIsIn(PlayerPedId(), false) or PlayerPedId()

			local coords = GetEntityCoords(PlayerPedId())
			local x = coords.x
			local y = coords.y
			local z = coords.z
			local h = GetEntityHeading(PlayerPedId())
			
			roundx = tonumber(string.format("%.2f", x))
			roundy = tonumber(string.format("%.2f", y))
			roundz = tonumber(string.format("%.2f", z))
			roundh = tonumber(string.format("%.2f", h))
			
			CrownMenu.DrawText("X: ~w~"..roundx, {0.01, 0.20 }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5, 4, 0, 0, 1)
			CrownMenu.DrawText("Y: ~w~"..roundy, {0.01, 0.225 }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5, 4, 0, 0, 1)
			CrownMenu.DrawText("Z: ~w~"..roundz, {0.01, 0.25 }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5, 4, 0, 0, 1)
			CrownMenu.DrawText("Heading: ~w~"..roundh, {0.01, 0.275 }, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5, 4, 0, 0, 1)

		end
		 
		if CrownVariables.OnlinePlayer.MolotovWLoop then
			local coords = GetEntityCoords(GetPlayerPed(CrownVariables.OnlinePlayer.MolotovWPlayer))
			AddExplosion(coords.x, coords.y, coords.z, 3, 100.0, true, false, 0.0)
		end

		if CrownVariables.OnlinePlayer.HydrantPlayer then
			local coords = GetEntityCoords(GetPlayerPed(CrownVariables.OnlinePlayer.MolotovWPlayer))
			AddExplosion(coords.x, coords.y, coords.z, 13, 100.0, true, false, 0.0)
		end

		if CrownVariables.SelfOptions.godmode then
			SetPedCanRagdoll(PlayerPedId(), false)
			ClearPedBloodDamage(PlayerPedId())
			ResetPedVisibleDamage(PlayerPedId())
			ClearPedLastWeaponDamage(PlayerPedId())
			SetEntityProofs(PlayerPedId(), true, true, true, true, true, true, true, true)
			SetEntityOnlyDamagedByPlayer(PlayerPedId(), false)
			SetEntityCanBeDamaged(PlayerPedId(), false)
		end

		if CrownVariables.SelfOptions.AutoHealthRefil then
			SetEntityHealth(PlayerPedId(), 200)
		end

		if CrownVariables.SelfOptions.AntiHeadshot then
			SetPedSuffersCriticalHits(PlayerPedId(), false)
		end

		if CrownVariables.SelfOptions.invisiblitity then
            SetEntityVisible(PlayerPedId(), false, true)
		end

		if CrownVariables.OnlinePlayer.FlingingPlayer then
			local coords = GetEntityCoords(GetPlayerPed(CrownVariables.OnlinePlayer.FlingingPlayer))
		
			ShootSingleBulletBetweenCoords(AddVectors(coords, vector3(0, 0, 0.1)), coords, 0.0, true, GetHashKey("WEAPON_RAYPISTOL"), PlayerPedId(), true, true, 100)
		end

		if CrownVariables.OnlinePlayer.MolotovLoop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.MolotovPlayer)
			local pedcoords = GetEntityCoords(ped)

			RequestNamedPtfxAsset("core")
			
			UseParticleFxAssetNextCall("core")
			StartNetworkedParticleFxNonLoopedAtCoord("exp_air_molotov", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.FireWorkLoop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.FireWorkPlayer)

			RequestNamedPtfxAsset("scr_indep_fireworks")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("scr_indep_fireworks")
			StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_firework_trailburst", pedcoords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.FireWork2Loop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.FireWork2Player)

			RequestNamedPtfxAsset("proj_indep_firework_v2")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("proj_indep_firework_v2")
			StartNetworkedParticleFxNonLoopedAtCoord("scr_firework_indep_ring_burst_rwb", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.SmokeLoop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.SmokePlayer)

			RequestNamedPtfxAsset("scr_agencyheist")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("scr_agencyheist")
			StartNetworkedParticleFxNonLoopedAtCoord("scr_fbi_dd_breach_smoke", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.JesusLightLoop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.JesusPlayer)

			RequestNamedPtfxAsset("scr_rcbarry1")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("scr_rcbarry1")

			StartNetworkedParticleFxNonLoopedAtCoord("scr_alien_teleport", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.AlienLightLoop then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.AlienPlayer)

			RequestNamedPtfxAsset("scr_rcbarry2")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("scr_rcbarry2")

			StartNetworkedParticleFxNonLoopedAtCoord("scr_clown_appears", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if CrownVariables.OnlinePlayer.ExplosionParticlePlayer then

			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.ExplosionParticlePlayer)

			RequestNamedPtfxAsset("scr_exile1")
		    
			local pedcoords = GetEntityCoords(ped)

			UseParticleFxAssetNextCall("scr_exile1")
			StartNetworkedParticleFxNonLoopedAtCoord("scr_ex1_plane_exp_sp", pedcoords, 0.0, 0.0, 0.0, 10.0, false, false, false, false)
		
		end

		if TazeLoop then

			local coords = GetEntityCoords(GetPlayerPed(selectedPlayer))
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + 2, 0, true, "WEAPON_STUNGUN", ped, false, false, 100)

		end

		if CrownVariables.WeaponOptions.Crosshair and not (cam) then
			local success, PedAimingAt = GetEntityPlayerIsFreeAimingAt(PlayerId())
	
			DrawRect2(CrownMenu.ScreenWidth / 2 - 2, CrownMenu.ScreenHeight / 2 - 7, 3, 13, 0, 0, 0, 255)
			DrawRect2(CrownMenu.ScreenWidth / 2 - 7, CrownMenu.ScreenHeight / 2 - 2, 13, 3, 0, 0, 0, 255)
			DrawRect2(CrownMenu.ScreenWidth / 2 - 1, CrownMenu.ScreenHeight / 2 - 6, 1, 11, 255, 255, 255, 255)
			DrawRect2(CrownMenu.ScreenWidth / 2 - 6, CrownMenu.ScreenHeight / 2 - 1, 11, 1, 255, 255, 255, 255)

		end

		Wait(0)
		
	end
end)

function CrosshairCheck(Ped, x, y)
	if x < 0.0 then
		x = x * -1
	end
	if y < 0.0 then
		y = y * -1
	end
	if CrownVariables.WeaponOptions.AimBot.ThroughWalls then
		if x < CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.x and y < CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.y then
			CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.x = x
			CrownVariables.WeaponOptions.AimBot.Targeting.Target = Ped
		end
	elseif HasEntityClearLosToEntityInFront(PlayerPedId(), Ped) then
		if x < CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.x and y < CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.y then
			CrownVariables.WeaponOptions.AimBot.Targeting.LowestResult.x = x
			CrownVariables.WeaponOptions.AimBot.Targeting.Target = Ped
		end
	end
end

function DrawRect2(x, y, w, h, r, g, b, a)
    local _w, _h = w / CrownMenu.ScreenWidth, h / CrownMenu.ScreenHeight
    local _x, _y = x / CrownMenu.ScreenWidth + _w / 2, y / CrownMenu.ScreenHeight + _h / 2
    Citizen.InvokeNative(0x3A618A217E5154F0,_x, _y, _w, _h, r, g, b, a)
end

function NativeExplosionServerLoop()
    Citizen.CreateThread(function()
        while CrownVariables.AllOnlinePlayers.ExplodisionLoop do
			OnlinePlayers = GetActivePlayers()
			Wait(250)
			for i = 1, #OnlinePlayers do
				if CrownVariables.AllOnlinePlayers.IncludeSelf and OnlinePlayers[i] ~= PlayerId() then
					local ped = GetPlayerPed(OnlinePlayers[i])
					local coords = GetEntityCoords(ped)
					AddExplosion(coords.x, coords.y, coords.z, 29, 100.0, true, false, 0.0)
				elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
					local ped = GetPlayerPed(OnlinePlayers[i])
					local coords = GetEntityCoords(ped)
					AddExplosion(coords.x, coords.y, coords.z, 29, 100.0, true, false, 0.0)
				end
			end
		end
    end)
end

function NativeExplosionLoop()
    Citizen.CreateThread(function()
		while CrownVariables.OnlinePlayer.ExplosionLoop do
			Wait(1)
			local ped = GetPlayerPed(CrownVariables.OnlinePlayer.ExplodingPlayer)
			local coords = GetEntityCoords(ped)
			AddExplosion(coords.x, coords.y, coords.z, CrownVariables.OnlinePlayer.ExplosionType, 100.0, true, false, 0.0)
		end
    end)
end

function ShootAtCoords(coords, weapon)
    ShootSingleBulletBetweenCoords(AddVectors(coords, vector3(0, 0, 0.1)), 0, GetWeaponDamage(weapon, 1), true, weapon, PlayerPedId(), true, true, 1000.0)
end

function GetVelocityAimbot(entity)
	vel = GetEntityVelocity(entity)
	vel = vel[2]
	if vel < 0 then
		vel = vel * -1
	end
	vel = vel / 2
	return vel
end

function DoRapidFireTick()
    DisablePlayerFiring(PlayerPedId(), true)
    if IsDisabledControlPressed(0, 257) and IsPlayerFreeAiming(PlayerId()) then
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        local launchPos = GetEntityCoords(wepent)
        local targetPos = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 200.0)
    
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
        ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
    end
end

function ShootAtBone(target, bone, damage)
	local bone = GetEntityBoneIndexByName(target, bone)
	local velocity = GetVelocityAimbot(target)
	local boneTarget = GetPedBoneCoords(target, bone, 0.0, -0.2, 0.0)
	local boneTarget2 = GetPedBoneCoords(target, bone, 0.0, 0.2 + velocity, 0.0)
	local _, weapon = GetCurrentPedWeapon(PlayerPedId())
    ShootSingleBulletBetweenCoords(boneTarget, boneTarget2, damage, true, weapon, PlayerPedId(), true, true, 100.0)
end

function getEntity(player) 
	local _, entity = GetEntityPlayerIsFreeAimingAt(player)
	return entity
end

function aimCheck(player)
    if onAim == "true" then
        return true
    else
        return IsPedShooting(player)
	end
end
	
function HelpAlert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

-- How To Use
-- local clientid, serverid = CrownMenu.GetPlayerFromPedId(ped) 

function CrownMenu.GetPlayerFromPedId(ped) 
	PlayerList = GetActivePlayers()
	for i = 1, #PlayerList do
		local playerped = GetPlayerPed(PlayerList[i])
		if playerped == ped then
			return i, GetPlayerServerId(PlayerList[i])
		end
	end
	return false
end

function TogPoliceHeadlights()
	Citizen.CreateThread(function()
		while not killmenu do
			if not policeheadlights then
					local veh = GetVehiclePedIsUsing(PlayerPedId())
					ToggleVehicleMod(veh, 22, true)
					SetVehicleHeadlightsColour(veh, 0)
                return
			end
			Wait(500)
			local veh = GetVehiclePedIsUsing(PlayerPedId())
			ToggleVehicleMod(veh, 22, true) -- toggle xenon
			SetVehicleHeadlightsColour(veh, 1)
			Wait(500)
			SetVehicleHeadlightsColour(veh, 8)
		end
	end)
end

local Keybinds = {
	{ 0x30, "0", false }, 
	{ 0x31, "1", false }, 
	{ 0x32, "2", false }, 
	{ 0x33, "3", false }, 
	{ 0x34, "4", false }, 
	{ 0x35, "5", false }, 
	{ 0x36, "6", false }, 
	{ 0x37, "7", false }, 
	{ 0x38, "8", false }, 
	{ 0x39, "9", false }, 
	{ 0x41, "A", false }, 
	{ 0x42, "B", false }, 
	{ 0x43, "C", false }, 
	{ 0x44, "D", false }, 
	{ 0x45, "E", false }, 
	{ 0x46, "F", false }, 
	{ 0x47, "G", false }, 
	{ 0x48, "H", false }, 
	{ 0x49, "I", false }, 
	{ 0x4A, "J", false }, 
	{ 0x4B, "K", false }, 
	{ 0x4C, "L", false }, 
	{ 0x4D, "M", false }, 
	{ 0x4E, "N", false }, 
	{ 0x4F, "O", false }, 
	{ 0x50, "P", false }, 
	{ 0x51, "Q", false }, 
	{ 0x52, "R", false }, 
	{ 0x53, "S", false }, 
	{ 0x54, "T", false }, 
	{ 0x55, "U", false }, 
	{ 0x56, "V", false }, 
	{ 0x57, "W", false }, 
	{ 0x58, "X", false }, 
	{ 0x59, "Y", false }, 
	{ 0x5A, "Z", false }, 
	{ 0x20, " ", false }, 
	{ 0xBD, "_", false }
}


function CrownMenu.KeyboardEntry(title, maxchar)
	if CrownMenu.UI.GTAInput then
        local GTAINPUT = KeyboardEntry(title, maxchar)
		return GTAINPUT
	end

	Wait(30)
	local OneUsed = 0
	local FlashThing = 0
	local Input = ""

	if maxchar > 188 then
        maxchar = 188
	end

	for i = 1, #Keybinds do
		Keybinds[i][3] = false
	end

	while true do

		DisableAllControlActions(0)

		CrownMenu.DrawRect(0.5, 0.56, 0.5, 0.04, { r = 20, g = 20, b = 20, a = 200 })
		CrownMenu.DrawRect(0.5, 0.52, 0.5, 0.04, { r = 0, g = 0, b = 0, a = 200 })
		CrownMenu.DrawRect(0.5, 0.54, 0.5, 0.001, { r = CrownMenu.rgb.r, g = CrownMenu.rgb.g, b = CrownMenu.rgb.b, a = 200 })

		CrownMenu.DrawText("[Crown Menu] ~w~" .. title, {0.252, 0.5025}, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.5, 4, 0)
		CrownMenu.DrawText(Input .. "_", {0.252, 0.54}, {255, 255, 255, 255}, 0.5, 4, 0, "CrownTextBox")

		if IsDisabledControlJustPressed(1, 194) and #Input > 0 then
			Input = Input:sub(1, #Input - 1)
		end

		if Ham.getKeyState(0x10) ~= 0 or Ham.getKeyState(0x14) ~= 0 then
			for i = 1, #Keybinds do
				local pressed = Ham.getKeyState(Keybinds[i][1])
				if pressed ~= 0 then
					if not Keybinds[i][3] then
						Input = Input .. string.upper(Keybinds[i][2])
					end
					Keybinds[i][3] = true
				else
					Keybinds[i][3] = false
				end
			end
		else
			for i = 1, #Keybinds do
				local pressed = Ham.getKeyState(Keybinds[i][1])
				if pressed ~= 0 then
					if not Keybinds[i][3] then
						Input = Input .. string.lower(Keybinds[i][2])
					end
					Keybinds[i][3] = true
				else
					Keybinds[i][3] = false
				end
			end
		end

		if IsDisabledControlJustPressed(1, 191) then
			for i = 1, #Keybinds do
				Keybinds[i][3] = false
			end
			return Input
		end
		
		if OneUsed < 5 then
			OneUsed = OneUsed + 1
			Input = ""
		end

		Wait(0)
	end
end

function AlienColourSpam()
	Citizen.CreateThread(function()
		while CrownVariables.SelfOptions.AlienColorSpam do
			SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 1, 134, 8, 0)
			SetPedComponentVariation(PlayerPedId(), 2, 0, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 3, 13, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 4, 106, 8, 0)
			SetPedComponentVariation(PlayerPedId(), 8, 274, 8, 0)
			SetPedComponentVariation(PlayerPedId(), 11, 274, 8, 0)
			SetPedComponentVariation(PlayerPedId(), 6, 83, 8, 0)
	
			SetPedPropIndex(PlayerPedId(), 1, 0, 0, 0)

			Wait(30)

			SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 1, 134, 9, 0)
			SetPedComponentVariation(PlayerPedId(), 2, 0, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 3, 13, 0, 0)
			SetPedComponentVariation(PlayerPedId(), 4, 106, 9, 0)
			SetPedComponentVariation(PlayerPedId(), 8, 274, 9, 0)
			SetPedComponentVariation(PlayerPedId(), 11, 274, 9, 0)
			SetPedComponentVariation(PlayerPedId(), 6, 83, 9, 0)
	
			SetPedPropIndex(PlayerPedId(), 1, 0, 0, 0)

			Wait(30)
		end
	end)	
end

function KeyboardEntry(title, maxchar)
	result = ""
	if result == "" then 
		AddTextEntry('TITLETEXT', title)
	   	DisplayOnscreenKeyboard(1, "TITLETEXT", "", "", "", "", "", maxchar)
	end

	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0)
		Wait(250)		
	end

	if (GetOnscreenKeyboardResult()) then
		result = GetOnscreenKeyboardResult()
		CancelOnscreenKeyboard()
	end

	if not HasModelLoaded(GetHashKey(result)) then
		RequestModel(GetHashKey(result))
		Wait(500)
	end
				
	CancelOnscreenKeyboard()

	return result
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc) return coroutine.wrap(function() local iter, id = initFunc() if not id or id == 0 then disposeFunc(iter) return end local enum = {handle = iter, destructor = disposeFunc} setmetatable(enum, entityEnumerator) local next = true repeat coroutine.yield(id) next, id = moveFunc(iter) until not next enum.destructor, enum.handle = nil, nil disposeFunc(iter) end) end
function EnumerateVehicles() return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) end
function EnumerateObjects() return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) end
function EnumeratePeds() return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) end

function RampAllCars()
	for vehicle in EnumerateVehicles() do
		local ramp = CreateObject(GetHashKey("stt_prop_stunt_track_start"), 0, 0, 0, true, true, true)
		NetworkRequestControlOfEntity(vehicle)
		if DoesEntityExist(vehicle) then
			AttachEntityToEntity(ramp, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		end
		NetworkRequestControlOfEntity(ramp)
		SetEntityAsMissionEntity(ramp, true, true)
	end
end

function DisableAnticheat(anticheat)
	if string.find(anticheat, "anticheese") then
		TriggerServerEvent("anticheese:SetComponentStatus", "Teleport", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "GodMode", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "Speedhack", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "WeaponBlacklist", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "CustomFlag", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "Explosions", false)
		TriggerServerEvent("anticheese:SetComponentStatus", "CarBlacklist", false)
		PushNotification("Disabled Anticheese", 600)
	elseif string.find(anticheat, "badger") then
		TriggerEvent("Anticheat:CheckStaffReturn", true)
	end
end

local specialmessage = 1
local messsage = "Crown   "

function CrownPlate()
    Citizen.CreateThread(function()
		while CrownVariables.VehicleOptions.Crownplate do
			if specialmessage == 1 then
				messsage = "Crown   "
			elseif specialmessage == 2 then
				messsage = "ydro    "
			elseif specialmessage == 3 then
				messsage = "dro     "
			elseif specialmessage == 4 then
				messsage = "ro      "
			elseif specialmessage == 5 then
				messsage = "o       "
			elseif specialmessage == 6 then
				messsage = "        "
			elseif specialmessage == 7 then
				messsage = "       H"
			elseif specialmessage == 8 then
				messsage = "      Hy"
			elseif specialmessage == 9 then
				messsage = "     Hyd"
			elseif specialmessage == 10 then
				messsage = "    Hydr"
			elseif specialmessage == 11 then
				messsage = "   Crown"
			elseif specialmessage == 12 then
				messsage = "  Crown "
			elseif specialmessage == 13 then
				messsage = " Crown  "
			elseif specialmessage == 14 then
				messsage = "Crown   "
			end
			if specialmessage > 13 then
				specialmessage = 1
			end
			local vehicle = GetVehiclePedIsIn(PlayerPedId())
			local lastveh = GetPlayersLastVehicle(PlayerPedId())
			SetVehicleNumberPlateText(vehicle, messsage)
			SetVehicleNumberPlateText(lastveh, messsage)
			specialmessage = specialmessage + 1
			Citizen.Wait(250)
			if killmenu then
				break
			end
		end
	end)
end

function CrownMenu.DoesServerHaveResource(resource)
	local resourcelist = GetResources()
	for i = 1, #resourcelist do
		if resourcelist[i] == resource then
			return true
		end
	end
	return false
end

function IsEntityAlreadyAdded(entity)
    for i = 1, #CrownMenu.Objectlist do
		local id = CrownMenu.Objectlist[i].ID
        if CrownMenu.Objectlist[i].ID == entity then
            return true
		end
	end
	return false
end

function TableHasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
            return true
        end
    end

    return false
end

function RemoveValueFromTable(tbl, val)
	for i, v in ipairs(tbl) do
	    if v == val then
		    return table.remove(tbl, i)
	    end
	end
end  

function ForceMod(Toggle)
    ForceTog = Toggle
    
    if ForceTog then
        
        Citizen.CreateThread(function()
			PushNotification("Force ~g~Enabled ~w~Press E to use", 600)
            
            local ForceKey = 38
            local KeyPressed = false
            local KeyTimer = 0
            local KeyDelay = 15
            local ForceEnabled = false
			local StartPush = false
			local Distance = 20
            
            function forcetick()
            
                if (KeyPressed) then
                    KeyTimer = KeyTimer + 1
                    if (KeyTimer >= KeyDelay) then
                        KeyTimer = 0
                        KeyPressed = false
                    end
				end
				
				DisableControlAction(0, 14, true)
				DisableControlAction(0, 15, true)
				DisableControlAction(0, 16, true)
				DisableControlAction(0, 17, true)
                
				if IsDisabledControlPressed(0, 15) then
					Distance = Distance + 1
				end
                
				if IsDisabledControlPressed(0, 14) then
					if Distance > 20 then
					    Distance = Distance - 1
					end
				end

                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
                    KeyPressed = true
                    ForceEnabled = true
                end
                
                if (StartPush) then
                    
                    StartPush = false
                    local pid = PlayerPedId()
                    local CamRot = GetGameplayCamRot(2)
                    
                    local force = 5
                    
                    local Fx = -(math.sin(math.rad(CamRot.z)) * force * 10)
                    local Fy = (math.cos(math.rad(CamRot.z)) * force * 10)
                    local Fz = force * (CamRot.x * 0.2)
                    
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, false)
                        if IsEntityOnScreen(k) and k ~= PlayerVeh and  k ~= CrownVariables.VehicleOptions.PersonalVehicle then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= pid then
                            ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
                        end
                    end
                end
                
                if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
                    KeyPressed = true
                    StartPush = true
                    ForceEnabled = false
                end
                
                if (ForceEnabled) then
                    local pid = PlayerPedId()
                    local PlayerVeh = GetVehiclePedIsIn(pid, false)
                    
                    Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * Distance)
                    
                    DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 35, false, true, 2, nil, nil, false)
                    
                    for k in EnumerateVehicles() do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and (k ~= PlayerVeh) and k ~= CrownVariables.VehicleOptions.PersonalVehicle then
                            RequestControlOnce(k)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                    
                    for k in EnumeratePeds() do
                        if IsEntityOnScreen(k) and k ~= PlayerPedId() then
                            RequestControlOnce(k)
                            SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
                            FreezeEntityPosition(k, false)
                            Oscillate(k, Markerloc, 0.5, 0.3)
                        end
                    end
                end
            end
            while ForceTog do forcetick() Wait(0) end
        end)
    else PushNotification("Force ~r~Disabled ~w~Press E to use", 600) end
end

function ShootAt(target, bone)
    local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
    SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end

function RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

function Oscillate(entity, position, angleFreq, dampRatio)
    local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq * angleFreq))
    local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
    local targetPos = SubVectors(pos1, pos2)
    
    ApplyForce(entity, targetPos)
end

function ScaleVector(vect, mult)
    return vector3(vect.x * mult, vect.y * mult, vect.z * mult)
end

function AddVectors(vect1, vect2)
    return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

function ApplyForce(entity, direction)
    ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
end

function KickAllFromVeh()
	local playerlist = GetActivePlayers()
	
	for i = 1, #playerlist do
		Wait(50)
		local currPlayer = playerlist[i]
		if CrownVariables.AllOnlinePlayers.IncludeSelf and playerlist[i] ~= PlayerId() then
			ClearPedTasksImmediately(GetPlayerPed(currPlayer))
		elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
			ClearPedTasksImmediately(GetPlayerPed(currPlayer))
		end
	end
end

function AddRampToCar(player)
	local ped = GetPlayerPed(player)
	local vehi = GetVehiclePedIsIn(ped, 0)
	local ramp = CreateObject(GetHashKey("prop_jetski_ramp_01"), 0, 0, 0, 1, 1, 1)
	AttachEntityToEntity(ramp, vehi, 0, 0.0, 5.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 0, true)
end

function MaxOutEngine(veh, toggle)
	ToggleVehicleMod(veh, 2, toggle)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, toggle)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, toggle)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14) - 1, toggle)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, toggle)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17) - 1, toggle)
end

function MaxOut(veh)
	SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
	SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
	SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
	SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
	SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end

function CagePlayer(player)
	local ped = GetPlayerPed(player)
	local coords = GetEntityCoords(ped)
	local inveh = IsPedInAnyVehicle(ped)

	if inveh then
		
		obj = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x -6.8, coords.y + 1, coords.z - 1.5, 0, 1, 1)
		SetEntityHeading(obj, 90.0)
		
		CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y + 6.8, coords.z - 1.5, 0, 1, 1)
		
	    CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y - 4.8, coords.z - 1.5, 0, 1, 1)

		obj2 = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x + 4.8, coords.y + 1, coords.z - 1.5, 0, 1, 1)
		SetEntityHeading(obj2, 90.0)
		
		obj = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x -6.8, coords.y + 1, coords.z + 1.3, 0, 1, 1)
		SetEntityHeading(obj, 90.0)
		
		CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y + 6.8, coords.z + 1.3, 0, 1, 1)
		
	    CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x - 0.6, coords.y - 4.8, coords.z + 1.3, 0, 1, 1)

		obj2 = CreateObject(GetHashKey("prop_const_fence03b_cr"), coords.x + 4.8, coords.y + 1, coords.z + 1.3, 0, 1, 1)
		SetEntityHeading(obj2, 90.0)
	else

	local obj = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y - 1, coords.z - 1, 1, 1, 1)
	FreezeEntityPosition(obj, true)
	local obj2 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.55, coords.y - 1.05, coords.z - 1, 1, 1, 1)
	SetEntityHeading(obj2, 90.0)
	FreezeEntityPosition(obj2, true)
	local obj3 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y + 0.6, coords.z - 1, 1, 1, 1)
	FreezeEntityPosition(obj3, true)
	local obj4 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x + 1.05, coords.y - 1.05, coords.z - 1, 1, 1, 1)
	SetEntityHeading(obj4, 90.0)
	FreezeEntityPosition(obj4, true)
	local obj5 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y - 1, coords.z + 1.5, 1, 1, 1)
	FreezeEntityPosition(obj5, true)
	local obj6 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.55, coords.y - 1.05, coords.z + 1.5, 1, 1, 1)
	SetEntityHeading(obj6, 90.0)
	FreezeEntityPosition(obj6, true)
	local obj7 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x - 0.6, coords.y + 0.6, coords.z + 1.5, 1, 1, 1)
	FreezeEntityPosition(obj7, true)
	local obj8 = CreateObject(GetHashKey("prop_fnclink_03gate5"), coords.x + 1.05, coords.y - 1.05, coords.z + 1.5, 1, 1, 1)
	SetEntityHeading(obj8, 90.0)
	FreezeEntityPosition(obj8, true)

	end
end

function UFOVeh(player)
	local ped = GetPlayerPed(player)
	local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 8.0, 0.5)
	local x = coords.x
	local y = coords.y
	local z = coords.z
	if not HasModelLoaded(GetHashKey("hydra")) then
		RequestModel(GetHashKey("hydra"))
		Wait(500)
	end

	local vehi = CreateVehicle(GetHashKey("hydra"), x, y, z, 0.0, 1, 1)
	Wait(50)
	if DoesEntityExist(vehi) then
		SetVehicleEngineTorqueMultiplier(vehi, 8000)
		SetVehicleEnginePowerMultiplier(vehi, 600)
		local ufoprop = CreateObject(GetHashKey("p_spinning_anus_s"), x, y, z, 1, 1, 0)
		SetEntityHeading(vehi, GetEntityHeading(ped))
		SetPedIntoVehicle(ped, vehi, -1)
		SetEntityCollision(ufoprop, false, true)
		AttachEntityToEntity(ufoprop, vehi, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 0, true)
	else
		return
	end
end

function ScreenToWorld(screenCoord)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    
    local vect2x = 0.0
    local vect2y = 0.0
    local vect21y = 0.0
    local vect21x = 0.0
    local direction = RotationToDirection(camRot)
    local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)
    
    local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
    local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
    local radians = -(math.rad(camRot.y))
    
    vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
    vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))
    
    local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
    if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
    end
    
    local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
    if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
    end
    
    if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
    end
    
    local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
    local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
    return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)
end

function SubVectors(vect1, vect2)
    return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
end

function WorldToScreenRel(worldCoords)
    local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
    if not check then
        return false
    end
    
    screenCoordsx = (x - 0.5) * 2.0
    screenCoordsy = (y - 0.5) * 2.0
    return true, screenCoordsx, screenCoordsy
end

function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

local function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

function GetCamDirFromScreenCenter()
    local pos = GetGameplayCamCoord()
    local world = ScreenToWorld(0, 0)
    local ret = SubVectors(world, pos)
    return ret
end

function RampCar(player)
	local ped = GetPlayerPed(player)
	local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 8.0, 0.5)
	local x = coords.x
	local y = coords.y
	local z = coords.z

	if not HasModelLoaded(GetHashKey("t20")) then
		RequestModel(GetHashKey("t20"))
		Wait(500)
	end

	local vehi = CreateVehicle(GetHashKey("t20"), x, y, z, 0.0, 1, 1)
	Wait(50)
	if DoesEntityExist(vehi) then
	    local ramp = CreateObject(GetHashKey("prop_jetski_ramp_01"), x, y, z - 1, 1, 1, 1)
		SetEntityHeading(vehi, GetEntityHeading(ped))
		SetPedIntoVehicle(ped, vehi, -1)
		AttachEntityToEntity(ramp, vehi, 0, 0.0, 3.0, 0.0, 0.0, 0.0, 180.0, false, false, true, false, 0, true)
		SetVehicleCustomPrimaryColour(vehi, 0, 0, 0)
		SetVehicleCustomSecondaryColour(vehi, 0, 0, 0)
		MaxOut(vehi)
	else
        return
	end
end

function SWATTeamPullUp(player)
	for i = 1, 1 do
		local ped = GetPlayerPed(player)
		local coords = GetEntityCoords(ped)

		local ret, x, y, z = GetClosestRoad(coords.x + 100.0, coords.y + 125.0, coords.z, 1, 1)

		local pedmodel = "s_m_y_swat_01"
		local carmodel = "riot"

		RequestModel(GetHashKey(pedmodel))
		RequestModel(GetHashKey(carmodel))

		local loadattemps = 0

		while not HasModelLoaded(GetHashKey(pedmodel)) and not HasModelLoaded(GetHashKey(carmodel)) do
			loadattemps = loadattemps + 1
			Citizen.Wait(1)
			if loadattemps > 10000 then
    	        break
			end
		end

		local nped = CreatePed(31, pedmodel, x, y, z, 0.0, true, true)
		local nped2 = CreatePed(31, pedmodel, x, y, z, 0.0, true, true)
		local nped3 = CreatePed(31, pedmodel, x, y, z, 0.0, true, true)
		local nped4 = CreatePed(31, pedmodel, x, y, z, 0.0, true, true)

		local veh = CreateVehicle(GetHashKey(carmodel), x, y, z, GetEntityHeading(ped), 1, 1)
		
		SetVehicleSiren(veh, true)
	
		ClearPedTasks(nped)
	
		GiveWeaponToPed(nped, "WEAPON_ASSAULTRIFLE", 9999, false, true)
		GiveWeaponToPed(nped2, "WEAPON_ASSAULTRIFLE", 9999, false, true)
		GiveWeaponToPed(nped3, "WEAPON_ASSAULTRIFLE", 9999, false, true)
		GiveWeaponToPed(nped4, "WEAPON_MINIGUN", 9999, false, true)
	
		if DoesEntityExist(veh) then
			SetPedIntoVehicle(nped, veh, -1)
			SetPedIntoVehicle(nped2, veh, 0)
			SetPedIntoVehicle(nped3, veh, 1)
			SetPedIntoVehicle(nped4, veh, 2)
		else
			DeleteEntity(nped)
			DeleteEntity(nped2)
			DeleteEntity(nped3)
			DeleteEntity(nped4)
			DeleteEntity(veh)
		end

		TaskVehicleDriveToCoord(nped, veh, coords.x + 7 * i, coords.y + 7 * i, coords.z, 200.0, 40.0, GetHashKey(veh), 6, 1.0, true)
		
		TaskCombatPed(nped2, GetPlayerPed(selectedPlayer), true, true)
		TaskCombatPed(nped3, GetPlayerPed(selectedPlayer), true, true)
		TaskCombatPed(nped4, GetPlayerPed(selectedPlayer), true, true)

		SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped))
		SetRelationshipBetweenGroups(5, GetHashKey(nped), GetHashKey(ped))
		SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped2))
		SetRelationshipBetweenGroups(5, GetHashKey(nped2), GetHashKey(ped))
		SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped))
		SetRelationshipBetweenGroups(5, GetHashKey(nped3), GetHashKey(ped))
		SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped3))
		SetRelationshipBetweenGroups(5, GetHashKey(nped4), GetHashKey(ped))
		SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped4))

		SetPedKeepTask(nped, true)
		SetPedKeepTask(nped2, true)
		SetPedKeepTask(nped3, true)
		SetPedKeepTask(nped4, true)

		SetVehicleOnGroundProperly(veh)
    end
end

function StartFireworks()
	Citizen.CreateThread(function()
		box = nil

		if not HasNamedPtfxAssetLoaded("scr_indep_fireworks") then
			RequestNamedPtfxAsset("scr_indep_fireworks")
			while not HasNamedPtfxAssetLoaded("scr_indep_fireworks") do
			   Wait(10)
			end
		end
	
		local pedcoords = GetEntityCoords(GetPlayerPed(-1))
		local ped = GetPlayerPed(-1)
		local times = 20
	
		   
		box = CreateObject(GetHashKey('ind_prop_firework_03'), pedcoords, true, false, false)
		PlaceObjectOnGroundProperly(box)
		FreezeEntityPosition(box, true)
		local firecoords = GetEntityCoords(box)
	    DeleteEntity(box)

		repeat
		UseParticleFxAssetNextCall("scr_indep_fireworks")
		local part1 = StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_firework_trailburst", firecoords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
		times = times - 1
		Citizen.Wait(2000)
		until(times == 0)
		DeleteEntity(box)
		box = nil
	end)
end

function TeleportToCoords(x, y, z, heading)
	if CrownVariables.TeleportOptions.smoothteleport then
		SwitchOutPlayer(PlayerPedId(), 0, 1)
		Wait(800)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			SetEntityCoords(GetPlayersLastVehicle(), x, y, z)
			SetPedIntoVehicle(PlayerPedId(), playersveh, -1)
		else
			SetEntityCoords(PlayerPedId(), x, y, z)
		end
		SwitchInPlayer(PlayerPedId())
	else
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			SetEntityCoords(GetPlayersLastVehicle(), x, y, z)
		else
			SetEntityCoords(PlayerPedId(), x, y, z)
		end
	end
end

function FlyPlaneIntoPlayer(player)
	
	local ped = GetPlayerPed(player)
	local coords = GetEntityCoords(ped)
	
	local pedmodel = "a_m_m_eastsa_01"
	local planemodel = "jet"

	RequestModel(GetHashKey(pedmodel))
	RequestModel(GetHashKey(planemodel))

    local loadattemps = 0

	while not HasModelLoaded(GetHashKey(pedmodel)) do
		loadattemps = loadattemps + 1
		Citizen.Wait(1)
		if loadattemps > 10000 then
            break
		end
	end

	while not HasModelLoaded(GetHashKey(planemodel)) and loadattemps < 10000 do
		Wait(500)
	end

	
	local nped = CreatePed(31, pedmodel, coords.x, coords.y, coords.z, 0.0, true, true)

	local veh = CreateVehicle(GetHashKey(planemodel), coords.x, coords.y, coords.z + 250.0, GetEntityHeading(ped), 1, 1)
	
	SetVehicleEngineOn(veh, true, true, true)

	ClearPedTasks(nped)
	
	SetPedIntoVehicle(nped, veh, -1)

	-- SetPedIntoVehicle(PlayerPedId(), veh, 0)

	SetEntityRotation(veh, -90.0, 0.0, 0.0, 0.0, true)

	SetVehicleForwardSpeed(veh, 336.0)

	-- TaskVehicleDriveToCoord(nped, veh, coords.x, coords.y, coords.z + 10.0, 10.0, true, GetHashKey(veh), 5, 1.0, true)
	
	SetPedKeepTask(nped, true)
end

function HelicopterChase(player)

	ped = GetPlayerPed(player)
	coords = GetEntityCoords(ped)
	
	local pedmodel = "a_m_m_eastsa_01"
	local planemodel = "buzzard2"

	RequestModel(GetHashKey(pedmodel))
	RequestModel(GetHashKey(planemodel))

    local loadattemps = 0

	while not HasModelLoaded(GetHashKey(pedmodel)) do
		loadattemps = loadattemps + 1
		Citizen.Wait(1)
		if loadattemps > 10000 then
            break
		end
	end

	while not HasModelLoaded(GetHashKey(planemodel)) and loadattemps < 10000 do
		Wait(500)
	end

	local nped = CreatePed(31, pedmodel, coords.x, coords.y, coords.z, 0.0, true, true)

	local veh = CreateVehicle(GetHashKey(planemodel), coords.x, coords.y + 15.0, coords.z + 60.0, GetEntityHeading(ped), 1, 1)
	
	local nped2 = CreatePedInsideVehicle(veh, 31, pedmodel, 0, true, true)
	local nped3 = CreatePedInsideVehicle(veh, 31, pedmodel, 1, true, true)
	local nped4 = CreatePedInsideVehicle(veh, 31, pedmodel, 2, true, true)

	ClearPedTasks(nped)
	
	SetPedIntoVehicle(nped, veh, -1)
	SetPedIntoVehicle(nped2, veh, 0)
	SetPedIntoVehicle(nped3, veh, 1)
	SetPedIntoVehicle(nped4, veh, 2)

	GiveWeaponToPed(nped2, "WEAPON_ASSAULTRIFLE", 9999, false, true)
	GiveWeaponToPed(nped3, "WEAPON_ASSAULTRIFLE", 9999, false, true)
	GiveWeaponToPed(nped4, "WEAPON_ASSAULTRIFLE", 9999, false, true)
	
	SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped))
	SetRelationshipBetweenGroups(5, GetHashKey(nped), GetHashKey(ped))

	SetRelationshipBetweenGroups(5, GetHashKey(ped), GetHashKey(nped2))
	SetRelationshipBetweenGroups(5, GetHashKey(nped2), GetHashKey(ped))

	SetVehicleEngineOn(veh, 10, true, false)

	TaskVehicleChase(nped, GetPlayerPed(selectedPlayer))

	SetPedKeepTask(nped, true)
	
	SetPedCanSwitchWeapon(nped2, true)
	SetPedCanSwitchWeapon(nped3, true)
	SetPedCanSwitchWeapon(nped4, true)
	
	SetEntityInvincible(nped, true)
	SetEntityInvincible(nped2, true)
	SetEntityInvincible(nped3, true)
	SetEntityInvincible(nped2, true)
	
	TaskCombatPed(nped2, GetPlayerPed(selectedPlayer), 0, 16.0)
	TaskCombatPed(nped3, GetPlayerPed(selectedPlayer), 0, 16.0)
	TaskCombatPed(nped4, GetPlayerPed(selectedPlayer), 0, 16.0)

	SetPedKeepTask(nped, true)
	SetPedKeepTask(nped2, true)
	SetPedKeepTask(nped3, true)
	SetPedKeepTask(nped4, true)

	SetRelationshipBetweenGroups(5,GetHashKey("PLAYER"),GetHashKey(pedmodel))
	SetRelationshipBetweenGroups(5,GetHashKey(pedmodel),GetHashKey("PLAYER"))
           
end

local stops = 0 

function SpamServerChatLoop()
	stops = 0 
	Citizen.CreateThread(function()
		while CrownVariables.MiscOptions.SpamServerChat do
			Wait(1)
			SpamServerChat()
			mocks = mocks + 1
			if mocks > 1250 then
				stops = stops + 1
				Wait(10 * 1000)
				mocks = 0
			elseif stops > 5 then
				Wait(60 * 1000)
				stops = 0
			end
			if killmenu then
				break
			end
		end
	end)
end

local rand = 1
function SpamServerChat()
	colourslist = {'^1', '^2', '^3', '^4' , '^5', '^6', '^7', '^8', '^9'}
	
	local colour = colourslist[rand]

	if rand >= 9 then
		rand = 1
	else
	    rand = rand + 1 
	end 

	TriggerServerEvent("_chat:messageEntered", tostring(colour) .. "Crown Menu", { 255, 255, 255 },  tostring(colour) .. "Crown Menu on Top | discord.gg/DXQvMEzKSd")
	TriggerServerEvent("_chat:messageEntered", tostring(colour) .. "Crown Menu", { 255, 255, 255 },  tostring(colour) .. "Crown Menu on Top | discord.gg/DXQvMEzKSd")

	--TriggerServerEvent("_chat:messageEntered", tostring(colour) .. "Crown Menu", { 255, 255, 255 },  tostring(colour) .. " Crown Menu on Top Baby, Oooh Nice Skiddy Server. Crown Detects ur Anticheats")
end

function TeleportToPlayer(target)
    local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end

function CrownMenu.Functions.SpawnPed(Data)
    local LoadAttemps = 0
	
	RequestModel(GetHashKey(Data.Model))

	while not HasModelLoaded(GetHashKey(Data.Model)) and LoadAttemps < 100 do
		LoadAttemps = LoadAttemps + 1
		RequestModel(GetHashKey(Data.Model))
		Citizen.Wait(1)
	end

	if not HasModelLoaded(Data.Model) then
        PushNotification("Request Model Timeout", 600)
		return
	end

	x, y, z = table.unpack(Data.Coords)

	local Ped = CreatePed(Data.Behaviour, Data.Model, x, y, z, 0.0, true, true)

	if Data.Behaviour == 24 then
		TaskCombatPed(Ped, GetPlayerPed(selectedPlayer), 0, 16 )
	end
	
	if Data.Weapon then
		GiveWeaponToPed(Ped, Data.Weapon, 9999, false, true)
	end

	SetEntityCoords(Ped, Data.Coords)

	return Ped
end

function SpawnPed(player, model, angry)
	local ped = GetPlayerPed(player)
	local coords = GetEntityCoords(ped)
	local x = coords.x
	local y = coords.y
	local z = coords.z
	
	RequestModel(GetHashKey(model))
	
    local loadattemps = 0

	while not HasModelLoaded(GetHashKey(model)) do
		loadattemps = loadattemps + 1
		Citizen.Wait(1)
		if loadattemps > 10000 then
			PushNotification("Request Model Timeout", 600)
            break
		end
	end

	if angry then
		local nped = CreatePed(31, model, x, y, z, 0.0, true, true)
		TaskCombatPed(nped, ped, 0, 16 )
		if (model == "csb_mweather") then
			SetEntityInvincible(nped, true) 
		    GiveWeaponToPed(nped, "WEAPON_RAYMINIGUN", 9999, false, true)
		end
	else
		local nped = CreatePed(4, model, x, y, z, 0.0, true, true)
	end

	SetEntityCoords(nped, x, y, z, 1, 1, 1, false)

	return nped
end

function FakeChatMessage(name)
	if AntiCheats.ChocoHax or AntiCheats.WaveSheild or AntiCheats.BadgerAC then
		PushNotification("Anticheat Detected! Function Blocked", 600)
	else
		local result = CrownMenu.KeyboardEntry("Message as " .. name, 200)
		
		if result == "" then

		else
		    TriggerServerEvent("_chat:messageEntered", name, { 255, 255, 255 }, result)
		end
    end
end

function SpawnVehAtCoords(model, coords)
	if HasModelLoaded(GetHashKey(model)) then

	else
		RequestModel(GetHashKey(model))
		Wait(500)
	end
    if HasModelLoaded(GetHashKey(model)) then
		local veh = CreateVehicle(GetHashKey(model), coords.x + 1.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
		return veh
    end
end

function ExplosionAllPlayers()
	local playerlist = GetActivePlayers()
	
	for i = 1, #playerlist do
		if CrownVariables.AllOnlinePlayers.IncludeSelf and playerlist[i] ~= PlayerId() then
			local ped = GetPlayerPed(playerlist[i])
			local coords = GetEntityCoords(ped)
			AddExplosion(coords.x, coords.y, coords.z, 4, 100.0, true, false, 0.0)
		elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
			local ped = GetPlayerPed(playerlist[i])
			local coords = GetEntityCoords(ped)
			AddExplosion(coords.x, coords.y, coords.z, 4, 100.0, true, false, 0.0)
      	end
	end
end

function RampPlayer(player)
	Citizen.CreateThread(function()
		local ped = GetPlayerPed(player)
		local coords = GetEntityCoords(ped)
		local x = coords.x
		local y = coords.y
		local z = coords.z
		
		local faggot = CreateObject(GetHashKey("stt_prop_stunt_track_start"), x, y, z, 1, 1, 1)
		local faggot2 = CreateObject(GetHashKey("stt_prop_stunt_track_start"), x + 10, y, z, 1, 1, 1)
		local faggot3 = CreateObject(GetHashKey("stt_prop_stunt_track_start"), x, y + 10, z, 1, 1, 1)
		SetEntityHeading(faggot, GetEntityHeading(ped))
		SetEntityHeading(faggot2, GetEntityHeading(ped) + 90)
		SetEntityHeading(faggot3, GetEntityHeading(ped) + 160)
		FreezeEntityPosition(faggot, true)
		FreezeEntityPosition(faggot2, true)
		FreezeEntityPosition(faggot3, true)

		if killmenu then
			return
		end
		return ExitThread
	end)
end

function DildosServer()
	local playerlist = GetActivePlayers()
	local anticrash = 0

	RequestModel("prop_cs_dildo_01")

	while not HasModelLoaded("prop_cs_dildo_01") and anticrash < 5 do
		anticrash = anticrash + 1
        Wait(500)
	end

	for i = 1, #playerlist do
		local ped = GetPlayerPed(playerlist[i])
		local coords = GetEntityCoords(ped)

		for i = 1, 15 do
		    CreateObject(GetHashKey("prop_cs_dildo_01"), coords.x, coords.y, coords.z, 1, 1, 1)
		end
	end
end

function AllPlayersAreARamp()
	local playerlist = GetActivePlayers()
	
	for i = 1, #playerlist do
		Wait(0)
		local PlayerToRamp = playerlist[i]
		RampPlayer(PlayerToRamp)
	end
end

function BusServerLoop()
	local playerlist = GetActivePlayers()
	
    local model = "airbus"

	if HasModelLoaded(GetHashKey(model)) then

	else
		RequestModel(GetHashKey(model))
		Wait(500)
	end

	Citizen.CreateThread(function()
		while CrownVariables.AllOnlinePlayers.busingserverloop do
			Wait(150)
			if killmenu then
				break
			end
	        BusServer()
		end
    end)
end

function CargoPlaneServerLoop()
	local playerlist = GetActivePlayers()
	
    local model = "cargoplane"

	if HasModelLoaded(GetHashKey(model)) then

	else
		RequestModel(GetHashKey(model))
		Wait(500)
	end

	Citizen.CreateThread(function()
		while CrownVariables.AllOnlinePlayers.cargoplaneserverloop do
			if killmenu then
				break
			end
			Wait(150)
	        CargoplaneServer()
		end
    end)
end

function CargoplaneServer()
	local playerlist = GetActivePlayers()
	
    local model = "cargoplane"

	if HasModelLoaded(GetHashKey(model)) then

	else
		RequestModel(GetHashKey(model))
		Wait(500)
	end
	
	for i = 1, #playerlist do
		if CrownVariables.AllOnlinePlayers.IncludeSelf and playerlist[i] ~= PlayerId() then
			local currPlayer = playerlist[i]
			local coords = GetEntityCoords(GetPlayerPed(currPlayer))
	
			local busone = CreateVehicle(GetHashKey(model), coords.x + 5.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
			local bustwo = CreateVehicle(GetHashKey(model), coords.x + 5.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
		elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
			local currPlayer = playerlist[i]
			local coords = GetEntityCoords(GetPlayerPed(currPlayer))
	
			local busone = CreateVehicle(GetHashKey(model), coords.x + 5.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
			local bustwo = CreateVehicle(GetHashKey(model), coords.x + 5.0, coords.y + 1.0, coords.z, 0.0, 1, 1)
		end
	end
end

function BusServer()
	
	local playerlist = GetActivePlayers()
	
    local model = "airbus"

	if HasModelLoaded(GetHashKey(model)) then

	else
		RequestModel(GetHashKey(model))
		Wait(500)
	end
	
	for i = 1, #playerlist do
		if CrownVariables.AllOnlinePlayers.IncludeSelf and ActivePlayers[i] ~= PlayerId() then
			local currPlayer = playerlist[i]
			BusPlayer(currPlayer)
		elseif not CrownVariables.AllOnlinePlayers.IncludeSelf then
			local currPlayer = playerlist[i]
			BusPlayer(currPlayer)
		end
	end
end

function BusPlayer(player)
    local model = "airbus"
    local anticrash = 0
	while not HasModelLoaded(GetHashKey(model)) and anticrash < 5000 do
		anticrash = anticrash + 1
		RequestModel(GetHashKey(model))
		Wait(0)
	end

	local coords = GetEntityCoords(GetPlayerPed(player))

	local busone = CreateVehicle(GetHashKey(model), coords.x + 10, coords.y, coords.z, 0.0, 1, 1)
	SetEntityHeading(busone, 90.0)

	if DoesEntityExist(busone) then
		ApplyForceToEntity(busone, 1, -5000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
	else
		SetEntityCoords(busone, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, false)
	end

	Wait(150)

	local bustwo = CreateVehicle(GetHashKey(model), coords.x + 10, coords.y, coords.z, 0.0, 1, 1)
	SetEntityHeading(bustwo, 90.0)

	if DoesEntityExist(bustwo) then
	    ApplyForceToEntity(bustwo, 1, -5000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
	else
		SetEntityCoords(bustwo, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, false)
	end
end

function RageShoot(target)
    if not IsPedDeadOrDying(target) then
        local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, "SKEL_HEAD"), 0.0, 0.0, 0.0)
        local _, weapon = GetCurrentPedWeapon(PlayerPedId())
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0.1, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
        ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0.1, 0, 0)), boneTarget, 9999, true, weapon, PlayerPedId(), false, false, 1000.0)
    end
end

CrownVariables.Notifications = {}

Citizen.CreateThread(function()
	while not killmenu do

		if #CrownVariables.Notifications > 0 then
			CrownMenu.DrawText([[[Crown Menu] ~w~Notifications]], {CrownMenu.UI.NotificationX, CrownMenu.UI.NotificationY}, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.45, 4, 0)
			CrownMenu.DrawRect(CrownMenu.UI.NotificationX + 0.15, CrownMenu.UI.NotificationY + 0.0175, 0.30, 0.035, { r = 0, g = 0, b = 0, a = 220 })
			CrownMenu.DrawRect(CrownMenu.UI.NotificationX + 0.15, CrownMenu.UI.NotificationY + 0.0345, 0.30, 0.001, { r = rgb.r, g = rgb.g, b = rgb.b, a = 255 })
			
			for i = 1, #CrownVariables.Notifications do
				if CrownVariables.Notifications[i][2] == nil then
					CrownVariables.Notifications[i][2] = 2
				end

				if CrownVariables.Notifications[i][2] < 2 then
					table.remove(CrownVariables.Notifications, 1)
					break
				end
				CrownVariables.Notifications.HeaderAlpha = 255
				curNotification = CrownVariables.Notifications[i]
				CrownVariables.Notifications[i][2] = CrownVariables.Notifications[i][2] - 1
				CrownMenu.DrawRect(CrownMenu.UI.NotificationX + 0.15, CrownMenu.UI.NotificationY + 0.0175 + 0.035 * i, 0.30, 0.035, { r = 10, g = 10, b = 10, a = 220 })
				CrownMenu.DrawText("[HM] ~w~" .. CrownVariables.Notifications[i][1], {CrownMenu.UI.NotificationX, CrownMenu.UI.NotificationY + 0.035 * i}, {CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255}, 0.45, 4, 0)
				if CrownVariables.Notifications[i][2] < 2 then
					table.remove(CrownVariables.Notifications, 1)
					break
				end
			end
		end
		
		Wait(1)
	end
end)

function PushNotification(Message, MSLength)
	Stuff = table.pack(Message, MSLength)
	table.insert(CrownVariables.Notifications, #CrownVariables.Notifications + 1, Stuff)
end

function SafeModeNotification()
	PushNotification("Safe Mode is ~g~Active ~s~Function Blocked", 600)
end

function VaultDoors()
    Citizen.CreateThread(function()
		while CrownVariables.ScriptOptions.vault_doors do 
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local door = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, "v_ilev_gb_vauldr", false, false, false)
			local door2 = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, "v_ilev_bk_vaultdoor", false, false, false)
			SetEntityCoords(door, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
			SetEntityCoords(door2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
			DeleteEntity(door)
			DeleteEntity(door2)
			Wait(5000)
		end
	end)
end

function GGACBypass()
    Citizen.CreateThread(function()
		while CrownVariables.ScriptOptions.GGACBypass do 
			TriggerServerEvent("gameCheck")
			Wait(5000)
		end
    end)
end

function ScreenshotBasicBypass()
    Citizen.CreateThread(function()
        while CrownVariables.ScriptOptions.SSBBypass and not killmenu do 
			for i = 1, 20 do
				TriggerServerEvent("EasyAdmin:CaptureScreenshot")
			end

			Wait(20000)
		end
	end)
end

local crouched = false

function CrouchScript()
    Citizen.CreateThread( function()
        while CrownVariables.ScriptOptions.script_crouch do 
            Citizen.Wait( 1 )

            local ped = GetPlayerPed( -1 )

            if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
                DisableControlAction( 0, 36, true ) -- INPUT_DUCK  

                if ( not IsPauseMenuActive() ) then 
                    if ( IsDisabledControlJustPressed( 0, 36 ) ) then 
                        RequestAnimSet( "move_ped_crouched" )

                        while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                            Citizen.Wait( 100 )
                        end 

                        if ( crouched == true ) then 
	    					ResetPedMovementClipset( ped, 0 )
                            crouched = false 
                        elseif ( crouched == false ) then
							SetPedMovementClipset( ped, "move_ped_crouched", 0.25 )
                            crouched = true 
                        end 
                    end
                end 
            end 
        end
    end)
end

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- Anticheat Detection --------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------


function RapePlayer(player)

	local rmodel = "a_m_o_acult_01"
	local ped = GetPlayerPed(player)
	local coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(player), 0.0, 8.0, 0.5)
	local x = coords.x
	local y = coords.y
	local z = coords.z

	RequestModel(GetHashKey(rmodel))
	RequestAnimDict("rcmpaparazzo_2")

	while not HasModelLoaded(GetHashKey(rmodel)) and not killmenu do
		Citizen.Wait(0)
	end

	while not HasAnimDictLoaded("rcmpaparazzo_2") and not killmenu do
		Citizen.Wait(0)
	end

	local nped = CreatePed(31, rmodel, x, y, z, 0.0, true, true)
	SetPedComponentVariation(nped, 4, 0, 0, 0)

	SetPedKeepTask(nped)
	TaskPlayAnim(nped, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1,49, 0, 16, 0, 0)

	AttachEntityToEntity(nped, ped, 0, 0.0, -0.3, 0.0, 0.0, 0.0, 0.0, true, true, true, true, 0, true)

end

function PlayerBlips()
	if not CrownVariables.MiscOptions.ESPBlips then
        Wait(100)
	end
	for i = 1, #CrownVariables.MiscOptions.ESPBlipDB do
		local CurrentEntry = CrownVariables.MiscOptions.ESPBlipDB[i]
		if CurrentEntry ~= nil then
			local Blip = CurrentEntry.Blip
	
			if DoesBlipExist(Blip) then
				SetBlipDisplay(Blip, 0)
				RemoveBlip(Blip)
			end
			if DoesBlipExist(CurrentEntry.Blip) then
				SetBlipDisplay(Blip, 0)
				RemoveBlip(CurrentEntry.Blip)
			end
			table.remove(CrownVariables.MiscOptions.ESPBlipDB, i)
		end
	end

	Citizen.CreateThread(function()
		while CrownVariables.MiscOptions.ESPBlips do
			Wait(100)

			local OnlinePlayers = GetActivePlayers()
			for k = 1, #OnlinePlayers do
                local CurPlayer = OnlinePlayers[k]
				if not BlipCreatedForPlayer(CurPlayer) then
					local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(CurPlayer)))
					local Blipa = AddBlipForCoord(x, y, z)
					SetBlipSprite(Blipa, 1)

					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(GetPlayerName(CurPlayer)) 
					EndTextCommandSetBlipName(Blipa)

					SetBlipShrink(Blipa, true)

					SetBlipCategory(Blipa, 7)

                    local Data = { Player = CurPlayer, Blip = Blipa }
					table.insert(CrownVariables.MiscOptions.ESPBlipDB, #CrownVariables.MiscOptions.ESPBlipDB + 1, Data)
				end
			end
	
			for i = 1, #CrownVariables.MiscOptions.ESPBlipDB do
                local CurrentEntry = CrownVariables.MiscOptions.ESPBlipDB[i]
				if CurrentEntry ~= nil then
					local CurPlayer = CurrentEntry.Player
					local CurPlayerPed = GetPlayerPed(CurPlayer)
					local x, y, z = table.unpack(GetEntityCoords(CurPlayerPed))
					local Blip = CurrentEntry.Blip
	 
					if TableHasValue(FriendsList, GetPlayerServerId(CurPlayer)) then
						ShowCrewIndicatorOnBlip(Blip, true)
						ShowFriendIndicatorOnBlip(Blip, true)
					else
						ShowCrewIndicatorOnBlip(Blip, false)
						ShowFriendIndicatorOnBlip(Blip, false)
					end
	
					SetBlipCoords(Blip, x, y, z)
	
					if IsEntityDead(CurPlayerPed) then
						SetBlipColour(Blip, 1)
					else
						SetBlipColour(Blip, 0)
					end
	
					if NetworkIsPlayerConnected(CurPlayer) ~= 1 then
						if DoesBlipExist(Blip) then
							RemoveBlip(Blip)
						end
						if DoesBlipExist(CurrentEntry.Blip) then
							RemoveBlip(CurrentEntry.Blip)
						end
						table.remove(CrownVariables.MiscOptions.ESPBlipDB, i)
					end
				end
			end
		end
	end)
end

function BlipCreatedForPlayer(player) 
	for k = 1, #CrownVariables.MiscOptions.ESPBlipDB do
		CurrentEntry = CrownVariables.MiscOptions.ESPBlipDB[k]
        if player == CurrentEntry.Player then
            return true
		end
	end
	return false
end

function splitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function round(num, numDecimalPlaces)
	local value = string.format("%." .. tostring(numDecimalPlaces) .. "f %%", num)
	value = tonumber(value)
	return value
end


local SpecialCharacter = {
	ClosingBracket = ")",
}

function FindDynamicTriggers()
	PushNotification("Searching for Triggers", 1000)
	Citizen.CreateThread(function()
		local Resources = GetResources()
		
		for i = 1, #Resources do
			Time = math.random(5, 100)
			Wait(Time)
			curres = Resources[i]
			for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
				data = LoadResourceFile(curres, v)

				if data ~= nil then
					for line in data:gmatch("([^\n]*)\n?") do
					    TriggersFile = line:gsub("client_scripts", "")
					    TriggersFile = TriggersFile:gsub("client_script", "")
						TriggersFile = TriggersFile:gsub("exports", "")
						TriggersFile = TriggersFile:gsub('.lua','')
						local addval = string.match(TriggersFile, "/(%a+)/")
						if addval ~= nil then
							TriggersFile = TriggersFile:gsub(addval,"")
							TriggersFile = TriggersFile:gsub('%W','')
							TriggersFile = addval .. "/" .. TriggersFile
						else
							TriggersFile = TriggersFile:gsub('%W','')
						end

						if TriggersFile ~= "" then
							test = LoadResourceFile(curres, TriggersFile .. ".lua")

							if string.find(curres, "ambulance") then
								print(curres)
								print(test)
								print(TriggersFile)
							end
							if test ~= nil then
								for resline in test:gmatch("([^\n]*)\n?") do
									if string.find(resline, "TriggerEvent") then
										for i = 1, #CrownMenu.DynamicTriggers.Search do
											local CurSearch = CrownMenu.DynamicTriggers.Search[i]
											if string.find(resline, CurSearch[1]) then
												resline = resline:gsub("TriggerEvent(", "")
												resline = splitString(resline, "(")[2]
												resline = splitString(resline, ")")[1]
												resline = splitString(resline, " ")[1]
												resline = resline:gsub(" ", "")
												resline = resline:gsub("'", "")
												resline = resline:gsub('"', "")
												resline = resline:gsub(',', "")
											
												print("Detected " .. resline  .. " in " .. curres)
		
												CrownMenu.DynamicTriggers.Triggers[CurSearch[2]] = resline
											end
										end
									elseif string.find(resline, "RegisterNetEvent") then
										for i = 1, #CrownMenu.DynamicTriggers.Search do
											local CurSearch = CrownMenu.DynamicTriggers.Search[i]
											if string.find(resline, CurSearch[1]) then
												resline = resline:gsub("RegisterNetEvent(", "")
												resline = resline:gsub("'", "")
												resline = resline:gsub([["]], "")
												resline = splitString(resline, "(")[1]
												resline = splitString(resline, ")")[1]
											
												print("Detected " .. resline  .. " in " .. curres)
		
												CrownMenu.DynamicTriggers.Triggers[CurSearch[2]] = resline
											end
										end
									elseif string.find(resline, "TriggerServerEvent") then
										for i = 1, #CrownMenu.DynamicTriggers.Search do
											local CurSearch = CrownMenu.DynamicTriggers.Search[i]
											if resline ~= nil and string.find(resline, CurSearch[1]) then
												resline = resline:gsub("TriggerServerEvent(", "")
												backup = resline
												resline = splitString(resline, "(")[2]	
												if resline ~= nil then
													resline = splitString(resline, ")")[1]
													resline = splitString(resline, " ")[1]
													resline = splitString(resline, ",")[1]
													resline = resline:gsub(" ", "")
													resline = resline:gsub("'", "")
													resline = resline:gsub('"', "")
													resline = resline:gsub(',', "")
												
													print("Detected " .. resline  .. " in " .. curres)
			
													CrownMenu.DynamicTriggers.Triggers[CurSearch[2]] = resline
												else
													backup = backup:gsub(" ", "")
													backup = splitString(backup, ",")[1]
													backup = backup:gsub('%W','')
												
													print("Detected " .. backup  .. " in " .. curres)
			
													CrownMenu.DynamicTriggers.Triggers[CurSearch[2]] = backup
												end
											end
										end
									elseif string.find(resline, "TriggerServerCallback") then
										for i = 1, #CrownMenu.DynamicTriggers.Search do
											local CurSearch = CrownMenu.DynamicTriggers.Search[i]
											if string.find(resline, CurSearch[1]) then
												resline = resline:gsub("TriggerServerCallback(", "")
												resline = splitString(resline, "(")[2]
												resline = splitString(resline, ")")[1]
												resline = splitString(resline, " ")[1]
												resline = resline:gsub(" ", "")
												resline = resline:gsub("'", "")
												resline = resline:gsub('"', "")
												resline = resline:gsub(',', "")
											
												print("Detected " .. resline  .. " in " .. curres)
		
												CrownMenu.DynamicTriggers.Triggers[CurSearch[2]] = resline
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		PushNotification("Triggers Search Complete", 1000)
	end)
end

function FindACResource()
	PushNotification("Searching for Servers Anticheat", 1000)
	Citizen.CreateThread(function()
		local Resources = GetResources()
		
		for i = 1, #Resources do
			curres = Resources[i]
			for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
				data = LoadResourceFile(curres, v)
				
				if data ~= nil then
					for line in data:gmatch("([^\n]*)\n?") do
						FinishedString = line:gsub("client_script", "")
						FinishedString = FinishedString:gsub(" ", "")
						FinishedString = FinishedString:gsub('"', "")
						FinishedString = FinishedString:gsub("'", "")

						local NiceSource = LoadResourceFile(curres, FinishedString)
					
						if NiceSource ~= nil and string.find(NiceSource, "This file was obfuscated using PSU Obfuscator 4.0.A") then
							if AntiCheats.VAC == false then
								PushNotification("VAC Detected in " .. curres, 1000)
							end
							AntiCheats.VAC = true
						elseif NiceSource ~= nil and string.find(NiceSource, "he is so lonely") then
							if AntiCheats.VAC == false then
								PushNotification("VAC Detected in " .. curres, 1000)
							end
							AntiCheats.VAC = true
						elseif NiceSource ~= nil and string.find(NiceSource, "Vyast") then
							if AntiCheats.VAC == false then
								PushNotification("VAC Detected in " .. curres, 1000)
							end
							AntiCheats.VAC = true
						end

						if tonumber(FinishedString) then
							if AntiCheats.ChocoHax == false then
								PushNotification("ChocoHax Detected in " .. curres, 1000)
							end
							AntiCheats.ChocoHax = true
						end
					end
				end

				if data and type(data) == 'string' and string.find(data, 'acloader.lua') and string.find(data, 'Enumerators.lua') then
					PushNotification("Badger Anticheat Detected in " .. curres, 1000)
					AntiCheats.BadgerAC = true
				end

				if data and type(data) == 'string' and string.find(data, 'client_config.lua') then
					PushNotification("ATG Detected Detected in " .. curres, 1000)
                    AntiCheats.ATG = true
				end

				if data and type(data) == 'string' and string.find(data, 'clientconfig.lua') and string.find('blacklistedmodels.lua') then
					PushNotification("ChocoHax Detected in " .. curres, 1000)
					AntiCheats.ChocoHax = true
				end
				
				if data and type(data) == 'string' and string.find(data, 'acloader.lua') then
					if not AntiCheats.BadgerAC then
						PushNotification("Badger Anticheat Detected in " .. curres, 1000)
					end
					AntiCheats.BadgerAC = true
				end

				if data and type(data) == 'string' and string.find(data, "Badger's Official Anticheat") then
					PushNotification("Badger Anticheat Detected in " .. curres, 1000)
					AntiCheats.BadgerAC = true
				end

				if data and type(data) == 'string' and string.find(data, 'TigoAntiCheat.net.dll') then
					PushNotification("Tigo Detected in " .. curres, 1000)
					AntiCheats.TigoAC = true
				end
			end
			Wait(10)
		end
	end)
end

RegisterNetEvent('chatMessage')
AddEventHandler('chatMessage', function(author, color, text)
	local pname = GetPlayerName(source)
	local pid = GetPlayerServerId(source)

	if pname == "*Invalid*" then
        return
	end

	if pid ~= 0 then
        return
	end

	if string.find(author, "Choco") then
		AntiCheats.ChocoHax = true
	elseif string.find(author, "Badger AntiCheat") then
		AntiCheats.BadgerAC = true
	elseif string.find(author, "Tigo") then
		AntiCheats.TigoAC = true
	elseif string.find(author, "WaveSheild") then
		AntiCheats.WaveSheild = true
	elseif string.find(author, "VAC") then
		AntiCheats.VAC = true
	end
end)

function StartPersonalVehicleCam()
    ClearFocus()

    local playerPed = PlayerPedId()
    
    CrownVariables.VehicleOptions.PersonalVehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, 50.0 * 1.0)

    SetCamActive(CrownVariables.VehicleOptions.PersonalVehicleCam, true)
    RenderScriptCams(true, false, 0, true, false)
    
	SetCamAffectsAiming(CrownVariables.VehicleOptions.PersonalVehicleCam, false)
	
	AttachCamToEntity(CrownVariables.VehicleOptions.PersonalVehicleCam, CrownVariables.VehicleOptions.PersonalVehicle, 0.0, -6.6, 1.2, true)
end

function EndPersonalVehicleCam()
	ClearFocus()
	
    RenderScriptCams(false, false, 0, true, false)
	DestroyCam(CrownVariables.VehicleOptions.PersonalVehicleCam, false)

	SetFocusEntity(PlayerPedId())

	CrownVariables.VehicleOptions.PersonalVehicleCam = nil
end

--------------------------------------------------
---- CINEMATIC CAM FOR FIVEM MADE BY KIMINAZE ----
--------------------------------------------------

--------------------------------------------------
------------------- VARIABLES --------------------
--------------------------------------------------

-- main variables

local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0

local offsetCoords = {}
offsetCoords.x = 0.0
offsetCoords.y = 0.0
offsetCoords.z = 0.0

local counter = 0
local precision = 1.0
local currPrecisionIndex
local precisions = {}

local speed = 1.0

local currFilter = 1
local currFilterIntensity = 10
local filterInten = {}
for i=0.1, 2.01, 0.1 do table.insert(filterInten, tostring(i)) end

local charControl = false

local isAttached = false
local entity
local camCoords

local pointEntity = false

-- menu variables

local itemCamPrecision

local itemFilter
local itemFilterIntensity

local itemAttachCam

local itemPointEntity

local ObjectSpoonerButtons = {
	{
		["label"] = "Go Faster",
		["button"] = "~INPUT_SPRINT~"
	},
	{
		["label"] = "Edit",
		["button"] = "~INPUT_AIM~"
	},
	{
		["label"] = "Delete",
		["button"] = "~INPUT_CREATOR_DELETE~"
	},
	{
		["label"] = "Duplicate",
		["button"] = "~INPUT_LOOK_BEHIND~"
	},
	{
		["label"] = "Add Object To DB",
		["button"] = "~INPUT_REPLAY_STARTPOINT~"
	},
	{
		["label"] = "Create Vehicle",
		["button"] = "~INPUT_PICKUP~"
	}
}

local FreeCameraButtons = {
	{
		["label"] = "Go Faster",
		["button"] = "~INPUT_SPRINT~"
	},
	{
		["label"] = "Set Vehicle As Personal Vehicle",
		["button"] = "~INPUT_CONTEXT_SECONDARY~"
	},
	{
		["label"] = "Teleport Into Vehicle",
		["button"] = "~INPUT_MULTIPLAYER_INFO~"
	}
}

function GetGroundZAtCoords(x, y)
	for i = 1, 500 do
		local retval, z, normal = GetGroundZAndNormalFor_3dCoord(x, y, i)
		print(normal)
        if retval == 1 then
            return z
		end
    end
end

--------------------------------------------------
---------------------- LOOP ----------------------
--------------------------------------------------

Citizen.CreateThread(function()
	while not killmenu do
		if (cam) then
			if noclipping then
			    NoClip()
			end

			ProcessCamControls()
			if FreeCameraMode == "Object Spooner" then

				if GetEntityInFrontOfCam() == 0 then
					CrownMenu.DrawRect(0.5, 0.5, 0.00075, 0.035, { r = 255, g = 255, b = 255, a = 200 })
					CrownMenu.DrawRect(0.5,  0.5, 0.02, 0.0035, { r = 255, g= 255, b = 255, a = 200 })
				else
	
					CrownMenu.DrawRect(0.5, 0.5, 0.00075, 0.035, { r = 0, g = 255, b = 0, a = 200 })
					CrownMenu.DrawRect(0.5,  0.5, 0.02, 0.0035, { r = 0, g= 255, b = 0, a = 200 })
	
					
					local plyrveh = GetEntityInFrontOfCam()
					local Dimensions = GetModelDimensions(plyrveh)
					local plyrvehcoords = GetEntityCoords(plyrveh)
			
					if Dimensions ~= nil then

						attempt1 = GetOffsetFromEntityInWorldCoords(plyrveh, Dimensions.x, Dimensions.y, Dimensions.z)
						attempt2 = GetOffsetFromEntityInWorldCoords(plyrveh, -Dimensions.x, Dimensions.y, Dimensions.z)
			
						attempt3 = GetOffsetFromEntityInWorldCoords(plyrveh, Dimensions.x, Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
						attempt4 = GetOffsetFromEntityInWorldCoords(plyrveh, -Dimensions.x, Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
				
						attempt5 = GetOffsetFromEntityInWorldCoords(plyrveh, Dimensions.x, -Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
						attempt6 = GetOffsetFromEntityInWorldCoords(plyrveh, Dimensions.x, -Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
						
						attempt7 = GetOffsetFromEntityInWorldCoords(plyrveh, -Dimensions.x, -Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
						attempt8 = GetOffsetFromEntityInWorldCoords(plyrveh, -Dimensions.x, -Dimensions.y, -Dimensions.z + -Dimensions.z / 2 + 0.1)
				
						attempt9 = GetOffsetFromEntityInWorldCoords(plyrveh, -Dimensions.x, -Dimensions.y, Dimensions.z)
						attempt10 = GetOffsetFromEntityInWorldCoords(plyrveh, Dimensions.x, -Dimensions.y, Dimensions.z)
						
						DrawLine(attempt1.x, attempt1.y, attempt1.z, attempt2.x, attempt2.y, attempt2.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
						DrawLine(attempt3.x, attempt3.y, attempt3.z, attempt4.x, attempt4.y, attempt4.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt3.x, attempt3.y, attempt3.z, attempt6.x, attempt6.y, attempt6.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt4.x, attempt4.y, attempt4.z, attempt5.x, attempt5.y, attempt5.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt3.x, attempt3.y, attempt3.z, attempt7.x, attempt7.y, attempt7.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt4.x, attempt4.y, attempt4.z, attempt8.x, attempt8.y, attempt8.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt4.x, attempt4.y, attempt4.z, attempt8.x, attempt8.y, attempt8.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt6.x, attempt6.y, attempt6.z, attempt8.x, attempt8.y, attempt8.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
						DrawLine(attempt1.x, attempt1.y, attempt1.z, attempt3.x, attempt3.y, attempt3.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt2.x, attempt2.y, attempt2.z, attempt4.x, attempt4.y, attempt4.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
						DrawLine(attempt1.x, attempt1.y, attempt1.z, attempt9.x, attempt9.y, attempt9.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt2.x, attempt2.y, attempt2.z, attempt10.x, attempt10.y, attempt10.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt10.x, attempt10.y, attempt10.z, attempt8.x, attempt8.y, attempt8.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				
						DrawLine(attempt2.x, attempt2.y, attempt2.z, attempt9.x, attempt9.y, attempt9.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt10.x, attempt10.y, attempt10.z, attempt9.x, attempt9.y, attempt9.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt1.x, attempt1.y, attempt1.z, attempt10.x, attempt10.y, attempt10.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt1.x, attempt1.y, attempt1.z, attempt4.x, attempt4.y, attempt4.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt2.x, attempt2.y, attempt2.z, attempt3.x, attempt3.y, attempt3.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt9.x, attempt9.y, attempt9.z, attempt8.x, attempt8.y, attempt8.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt10.x, attempt10.y, attempt10.z, attempt6.x, attempt6.y, attempt6.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt9.x, attempt9.y, attempt9.z, attempt6.x, attempt6.y, attempt6.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						
						DrawLine(attempt6.x, attempt6.y, attempt6.z, attempt1.x, attempt1.y, attempt1.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt7.x, attempt7.y, attempt7.z, attempt2.x, attempt2.y, attempt2.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt9.x, attempt9.y, attempt9.z, attempt4.x, attempt4.y, attempt4.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
						DrawLine(attempt10.x, attempt10.y, attempt10.z, attempt3.x, attempt3.y, attempt3.z, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 255)
				    end
				end
	
				local coords = GetCoordCamLooking()

				local retval, zz, normal = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z + 100)

				-- DrawMarker(1, coords.x, coords.y, zz, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, CrownMenu.rgb.r, CrownMenu.rgb.g, CrownMenu.rgb.b, 200, 0, 0, 0, 0)

				DrawBottomHelp(ObjectSpoonerButtons)
	
				if IsDisabledControlJustReleased(0, 23) then
					CrownMenu.OpenMenu("objectslist")
				end
	
				if IsDisabledControlJustReleased(0, 38) then
	
					CrownMenu.CloseMenu()
					CrownMenu.CloseMenu()
	
					local vehmodel = CrownMenu.KeyboardEntry("Enter Spawn Code", 50)
	
					
					if IsModelAVehicle(vehmodel) then
						CreateVehicle(GetHashKey(vehmodel), coords.x, coords.y, coords.z, GetCamRot(cam, 2)[3], 1, 1)
					else
						PushNotification("Invalid Vehciel Model", 600)
					end
	
					CrownMenu.OpenMenu("objectslist")
				end
	
				if IsDisabledControlJustReleased(0, 26) then
					local entity = GetEntityInFrontOfCam()
					if entity ~= 0 and DoesEntityExist(entity) and GetEntityType(entity) ~= 0 or nil then
						local modeltodupe = GetEntityModel(entity)
						cords = GetEntityCoords(entity)
						if IsModelAVehicle(modeltodupe) then
							CreateVehicle(modeltodupe, cords.x, cords.y, cords.z, GetEntityHeading(entity), 1, 1)
						elseif IsEntityAPed(entity) then
							pud = CreatePed(5, modeltodupe, cords.x, cords.y, cords.z, GetEntityHeading(entity), 1, 1)
							TaskWanderStandard(pud, 10.0, 10)	
						end
					end
				end
				
				if IsDisabledControlPressed(0, 305) then
					local entity = GetEntityInFrontOfCam()
					if DoesEntityExist(entity) and not IsEntityAlreadyAdded(entity) then
						if entity ~= PlayerPedId() and entity ~= IsPedAPlayer(entity) then		
							local Information = {ID = entity, AttachedEntity = nil, AttachmentOffset = {X = 0, Y = 0, Z = 0, XAxis = 0, YAxis = 0, ZAxis = 0}}
							table.insert(CrownMenu.Objectlist, #CrownMenu.Objectlist + 1, Information)
						end
					end
				end
	
				--[[
				if IsDisabledControlJustReleased(0, 25) then
					if GetEntityInFrontOfCam() ~= PlayerPedId() and GetEntityInFrontOfCam() ~= IsPedAPlayer(GetEntityInFrontOfCam()) and GetEntityInFrontOfCam() ~= 0 then
						print("^ 1CrownMenu^0: Function does not exist")
					end
				end
				]]
	
				if IsDisabledControlPressed(0, 229) then
					if GetEntityInFrontOfCam() ~= 0 then
						CrownMenu.DrawRect(0.5, 0.5, 0.005, 0.0075, { r = 255, g = 128, b = 0, a = 200 })
					end
				end
	
				if IsDisabledControlJustReleased(0, 256) then
					if GetEntityInFrontOfCam() ~= PlayerPedId() and GetEntityInFrontOfCam() ~= IsPedAPlayer(GetEntityInFrontOfCam()) then
						if TableHasValue(spawnedobjectslist, GetEntityInFrontOfCam()) then
							RemoveValueFromTable(spawnedobjectslist, GetEntityInFrontOfCam())
						end
						NetworkRequestControlOfEntity(GetEntityInFrontOfCam())
						RequestControlOnce(GetEntityInFrontOfCam())
						DeleteEntity(GetEntityInFrontOfCam())
					end
				end
			
			elseif FreeCameraMode == "Vehicle Snatcher" then 
				
				if GetEntityInFrontOfCam() == 0 then
					CrownMenu.DrawRect(0.5, 0.5, 0.00075, 0.035, { r = 255, g = 255, b = 255, a = 200 })
					CrownMenu.DrawRect(0.5,  0.5, 0.02, 0.0035, { r = 255, g= 255, b = 255, a = 200 })
				else
					CrownMenu.DrawRect(0.5, 0.5, 0.00075, 0.035, { r = 0, g = 255, b = 0, a = 200 })
					CrownMenu.DrawRect(0.5,  0.5, 0.02, 0.0035, { r = 0, g= 255, b = 0, a = 200 })
				end

				if IsDisabledControlJustReleased(0, 52) then
					if IsEntityAVehicle(GetEntityInFrontOfCam()) then 
						if IsPedInAnyVehicle(PlayerPedId()) then
							oldveh = GetVehiclePedIsIn(PlayerPedId(), true)
							Wait(10)
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), -1)
							CrownVariables.VehicleOptions.PersonalVehicle = GetEntityInFrontOfCam()
							Wait(10)
							if IsVehicleSeatFree(oldveh, -1) then
								SetPedIntoVehicle(PlayerPedId(), oldveh, -1)
							elseif IsVehicleSeatFree(oldveh, 0) then
								SetPedIntoVehicle(PlayerPedId(), oldveh, 0)
							elseif IsVehicleSeatFree(oldveh, 1) then
								SetPedIntoVehicle(PlayerPedId(), oldveh, 1)
							elseif IsVehicleSeatFree(oldveh, 2) then
								SetPedIntoVehicle(PlayerPedId(), oldveh, 2)
							end
						else
							coords = GetEntityCoords(PlayerPedId())
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), -1)
							CrownVariables.VehicleOptions.PersonalVehicle = GetEntityInFrontOfCam()
							SetEntityCoords(PlayerPedId(), coords)
						end
					end
					
				elseif IsDisabledControlPressed(0, 20) then
					if IsEntityAVehicle(GetEntityInFrontOfCam()) then
						if IsVehicleSeatFree(GetEntityInFrontOfCam(), -1) then
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), -1)
						elseif IsVehicleSeatFree(GetEntityInFrontOfCam(), 0) then
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), 0)
						elseif IsVehicleSeatFree(GetEntityInFrontOfCam(), 1) then
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), 1)
						elseif IsVehicleSeatFree(GetEntityInFrontOfCam(), 2) then
							SetPedIntoVehicle(PlayerPedId(), GetEntityInFrontOfCam(), 2)
						end
					end
				end

				DrawBottomHelp(FreeCameraButtons)
			end
        end
        Citizen.Wait(1)
    end
end)

--------------------------------------------------
------------------- FUNCTIONS --------------------
--------------------------------------------------

function DrawBottomHelp(table)
    Citizen.CreateThread(function()
        local instructionScaleform = RequestScaleformMovie("instructional_buttons")

        while not HasScaleformMovieLoaded(instructionScaleform) do
            Wait(0)
        end

        PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")
        PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
        PushScaleformMovieFunctionParameterBool(0)
        PopScaleformMovieFunctionVoid()

        for buttonIndex, buttonValues in ipairs(table) do
            PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(buttonIndex - 1)

            PushScaleformMovieMethodParameterButtonName(buttonValues["button"])
            PushScaleformMovieFunctionParameterString(buttonValues["label"])
            PopScaleformMovieFunctionVoid()
        end

        PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
        PushScaleformMovieFunctionParameterInt(-1)
        PopScaleformMovieFunctionVoid()
        DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)
    end)
end

-- initialize camera
function StartFreeCam(fov)
    ClearFocus()

    local playerPed = PlayerPedId()
    
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, fov * 1.0)

    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    
    SetCamAffectsAiming(cam, false)

    if (isAttached and DoesEntityExist(entity)) then
        offsetCoords = GetOffsetFromEntityGivenWorldCoords(entity, GetCamCoord(cam))

        AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
    end
end

-- destroy camera
function EndFreeCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
	DestroyCam(cam, false)
	
	SetFocusEntity(PlayerPedId())
    
    offsetRotX = 0.0
    offsetRotY = 0.0
    offsetRotZ = 0.0

    isAttached = false

    speed       = 1.0
    precision   = 1.0
    currFov     = GetGameplayCamFov()

    cam = nil
end
disabledControls = {
    30,     -- A and D (Character Movement)
    31,     -- W and S (Character Movement)
    21,     -- LEFT SHIFT
    36,     -- LEFT CTRL
    22,     -- SPACE
    44,     -- Q
    38,     -- E
    71,     -- W (Vehicle Movement)
    72,     -- S (Vehicle Movement)
    59,     -- A and D (Vehicle Movement)
    60,     -- LEFT SHIFT and LEFT CTRL (Vehicle Movement)
    85,     -- Q (Radio Wheel)
    86,     -- E (Vehicle Horn)
    15,     -- Mouse wheel up
    14,     -- Mouse wheel down
    37,     -- Controller R1 (PS) / RT (XBOX)
    80,     -- Controller O (PS) / B (XBOX)
    228,    -- 
    229,    -- 
    172,    -- 
    173,    -- 
    37,     -- 
    44,     -- 
    178,    -- 
    244,    -- 
}

-- process camera controls
function ProcessCamControls()
    local playerPed = PlayerPedId()

    DisableFirstPersonCamThisFrame()
    BlockWeaponWheelThisFrame()
    -- disable character/vehicle controls
	if (not charControl) then
        for k, v in pairs(disabledControls) do
            DisableControlAction(0, v, true)
        end
	end
	
	-- Switch Modes

	if IsDisabledControlJustReleased(0, 82) or IsDisabledControlJustReleased(0, 81) then
		if FreeCameraMode == "Object Spooner" then
			FreeCameraMode = "Vehicle Snatcher"
		elseif FreeCameraMode == "Vehicle Snatcher" then
			FreeCameraMode = "Object Spooner"
		end
	end

    local camCoords = GetCamCoord(cam)

    -- calculate new position
    local newPos = ProcessNewPosition(camCoords.x, camCoords.y, camCoords.z)

     -- focus cam area
     SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
        
    -- set coords of cam
	SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
	
	SetMinimapHideFow(false)

    -- set rotation
    SetCamRot(cam, offsetRotX, offsetRotY, offsetRotZ, 2)
end

function ProcessNewPosition(x, y, z)
    local _x = x
    local _y = y
    local _z = z

    -- keyboard
    if (IsInputDisabled(0) and not charControl) then
        if (IsDisabledControlPressed(1, 32)) then
            local multX = Sin(offsetRotZ)
            local multY = Cos(offsetRotZ)
            local multZ = Sin(offsetRotX)

            _x = _x - (0.1 * speed * multX)
            _y = _y + (0.1 * speed * multY)
            _z = _z + (0.1 * speed * multZ)
        end
        if (IsDisabledControlPressed(1, 33)) then
            local multX = Sin(offsetRotZ)
            local multY = Cos(offsetRotZ)
            local multZ = Sin(offsetRotX)

            _x = _x + (0.1 * speed * multX)
            _y = _y - (0.1 * speed * multY)
            _z = _z - (0.1 * speed * multZ)
        end
        if (IsDisabledControlPressed(1, 34)) then
            local multX = Sin(offsetRotZ + 90.0)
            local multY = Cos(offsetRotZ + 90.0)
            local multZ = Sin(offsetRotY)

            _x = _x - (0.1 * speed * multX)
            _y = _y + (0.1 * speed * multY)
             _z = _z + (0.1 * speed * multZ)
        end
        if (IsDisabledControlPressed(1, 35)) then
            local multX = Sin(offsetRotZ + 90.0)
            local multY = Cos(offsetRotZ + 90.0)
            local multZ = Sin(offsetRotY)

            _x = _x + (0.1 * speed * multX)
            _y = _y - (0.1 * speed * multY)
            _z = _z - (0.1 * speed * multZ)
        end
        
            --[[
            if (IsDisabledControlPressed(1, 17)) then
                if ((speed + 0.1) < 20.0) then
                    speed = speed + 1.0
                else
                    speed = 20.0
                end
            elseif (IsDisabledControlPressed(1, 16)) then
                if (speed  > 1.0) then
                    speed = speed - 1.0
                else
                    speed = 0.1
                end
			end
			]]
			
			if IsDisabledControlPressed(0, 21) then
				speed = 15.0
			else
				speed = 2.0
			end
        

        -- rotation
        offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * precision * 8.0)
		offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * precision * 8.0)
		
    end
    

    if (offsetRotX > 90.0) then offsetRotX = 90.0 elseif (offsetRotX < -90.0) then offsetRotX = -90.0 end
    if (offsetRotY > 90.0) then offsetRotY = 90.0 elseif (offsetRotY < -90.0) then offsetRotY = -90.0 end
    if (offsetRotZ > 360.0) then offsetRotZ = offsetRotZ - 360.0 elseif (offsetRotZ < -360.0) then offsetRotZ = offsetRotZ + 360.0 end

    return {x = _x, y = _y, z = _z}
end

function ToggleCam(flag, fov)
    if (flag) then
        StartFreeCam(fov)
        _menuPool:RefreshIndex()
    else
        EndFreeCam()
        _menuPool:RefreshIndex()
    end
end

function GetEntityInFrontOfCam()
    local camCoords = GetCamCoord(cam)
    local offset = GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 40)

	local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, offset.x, offset.y, offset.z, -1)
    local a, b, c, d, entity = GetShapeTestResult(rayHandle)
    return entity
end

function GetPedThroughWall()
    local camCoords = GetCamCoord(cam)
    local offset = GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 40)

	local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, offset.x, offset.y, offset.z, -1)
    local a, b, c, d, entity = GetShapeTestResult(rayHandle)
    return entity
end

function GetCoordCamLooking()
	Markerloc = GetCamCoord(cam) + (RotationToDirection(GetCamRot(cam, 2)) * 20)
	return Markerloc
end

function ToggleAttachMode()
    if (not isAttached) then
        entity = GetEntityInFrontOfCam()
        
        if (DoesEntityExist(entity)) then
            offsetCoords = GetOffsetFromEntityGivenWorldCoords(entity, GetCamCoord(cam))

            Citizen.Wait(1)
            local camCoords = GetCamCoord(cam)
            AttachCamToEntity(cam, entity, GetOffsetFromEntityInWorldCoords(entity, camCoords.x, camCoords.y, camCoords.z), true)

            isAttached = true
        end
    else
        ClearFocus()

        DetachCam(cam)

        isAttached = false
    end
end

function TogglePointing(flag)
    if (flag and isAttached) then
        pointEntity = true
        PointCamAtEntity(cam, entity, 0.0, 0.0, 0.0, 1)
    else
        pointEntity = false
        StopCamPointing(cam)
    end
end