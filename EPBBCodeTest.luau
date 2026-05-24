local EPBBCode = require("./EPBBCode")

-- this has a lot of magic numbers because of string methods being weird
-- beware!
local function GetEPBBCodeTagData(Tag: string)
    local data = {
		["Type"] = nil,
		["Value"] = nil,
		["Args"] = nil,
		["WrappedText"] = nil
	}
    local tag_start = 1
    local valueDeclaration = Tag:find("=", tag_start)
	-- +2 to avoid the "<[", -1 to avoid the "="
    local tag_type = Tag:sub(tag_start + 2, valueDeclaration - 1)

    local TypeLookupTable = {
        ["func"] 		= {[1] = "Function", 		[2] = "String"}, -- will find a corresponding Function
        ["img"] 		= {[1] = "Image", 			[2] = "Number"}, -- will find a correspending Image
        ["img_seq"] 	= {[1] = "Image Sequence",  [2] = "Table"},  -- will find a corresponding Image Sequence table
        ["event"] 		= {[1] = "Client Event", 	[2] = "String"}, -- will find a correspending BindableEvent
        ["netevent"] 	= {[1] = "Server Event", 	[2] = "String"}, -- will find a corresponding NetworkEvent
        ["anim"] 		= {[1] = "Animation", 		[2] = "String"}, -- will find a corresponding TweenObject
        ["gradient"] 	= {[1] = "Gradient", 		[2] = "String"}, -- will find a corresponding GradientImageAsset
    }

    local typeData = TypeLookupTable[tag_type]
    local literal_type = typeData[1]
	local value_type = typeData[2]
	data["Type"] = literal_type

	-- add other value types later
    if (value_type == "String") then
        -- find single quotes
        local string_start = Tag:find("'", valueDeclaration, true)
		-- +1 to avoid the initial '
        local string_end = Tag:find("'", string_start + 1, true)

		-- +1 to avoid the ', -1 to avoid another '
        local value = Tag:sub(string_start + 1, string_end - 1)
        data["Value"] = value

		-- get args
		local argsDeclaration = Tag:find("args", string_start, true)
		if argsDeclaration == nil then
			print("[color=orange]EPBBCode: unable to find args declaration in EPBBCode tag, leaving args as an empty table.[/color]")
			data["Args"] = {}
			return data
		else
			local argsStart = Tag:find("{", argsDeclaration, true)
			local argsEnd = Tag:find("}", argsStart, true)
			local argsData = {}
		
			-- gets key-value pairs
            -- example: Speed=10
            --          Speed   10
            --          Key     Value
			for arg_name, arg in Tag:sub(argsStart, argsEnd):gmatch("([%w_]+)=([%w_]+)") do
				argsData[tostring(arg_name)] = arg
			end

			data["Args"] = argsData
		end

		-- get wrapped text

        local open_tag_end = Tag:find("]>", argsDeclaration, true)
		-- searches for </[
        local close_tag_start = Tag:find("</[", open_tag_end, true)

        local wrapped_text = Tag:sub(open_tag_end + 2, close_tag_start - 1)
        data["WrappedText"] = wrapped_text
        print("wrapped text", wrapped_text)

    end

	return data

end

GetEPBBCodeTagData("<[func='PlayACutscene', args={CutsceneName=First_cutscene, Local=true, Duration=10}]>!</[/func]>")

print("regular test suite!")

local EPBBText = EPBBCode.New("test, test, [color=red]red[/color] and [b]bold[/b]", true)
print(EPBBText:Get(EPBBCode.Enums.Property.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.Property.ParsedText), "printing ParsedText")

-- this should just be the typewriterout, add an option later to only modify an existing string
-- rather than forcing it into a UILabel.Text
local string = ""
for _, char in pairs(EPBBText:Get(EPBBCode.Enums.Property.ParsedText)) do
	
	if typeof(char) == typeof({}) then

		if typeof(char[2]) == typeof(1) then
			local close_tag = string:sub(#string - char[2] + 1, -1)
			local before_close_tag = string:sub(1, #string - char[2])
			string = before_close_tag .. char[1] .. close_tag
			continue
		end

		string = string .. char[1]
		continue
	end

	string = string .. char
end
print("------------------rebuilding parsed text----------------")
print(string)