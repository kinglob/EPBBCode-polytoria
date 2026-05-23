local EPBBCode = require("./EPBBCode")

local EPBBText = EPBBCode.New("test, [color=what?][/color][color=blue_blue_Blue][/color], |||||||[color=red]tungtest[/color]", true)
print(EPBBText:Get(EPBBCode.Enums.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.ParsedText), "printing ParsedText")

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