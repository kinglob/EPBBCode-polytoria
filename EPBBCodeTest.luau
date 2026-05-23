local EPBBCode = require("./EPBBCode")

local EPBBText = EPBBCode.New("test, test, [color=red]red[/color] and [b]bold[/b]", true)
print(EPBBText:Get(EPBBCode.Enums.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.ParsedText), "printing ParsedText")

-- this should just be the typewriterout, add an option later to only modify an existing string
-- rather than forcing it into a UILabel.Text
local string = ""
for _, char in pairs(EPBBText:Get(EPBBCode.Enums.ParsedText)) do
	
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