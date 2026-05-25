local EPBBCode = require("./EPBBCode")

print("regular test suite!")


EPBBCode.New("test", true)

local EPBBText = EPBBCode.New("test, test, <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> and [b]bold[/b]", true)
print(EPBBText:Get(EPBBCode.Enums.Property.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.Property.ParsedText), "printing ParsedText")

-- this should just be the typewriterout, add an option later to only modify an existing string
-- rather than forcing it into a UILabel.Text
-- TODO: THIS SUCKS ASS!!! JUST MAKE AN ACTUALLY READABLE TypewriterOut METHOD!!!!!!
-- ALSO, JUST GET THE TEST FUNCTION DONE INSTEAD OF HAVING A SEPARATE FILE!!!
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


print("------------------using typewriterout method--------")
local thing: UILabel
local out: string = EPBBText:TypewriterOut(thing)
print(out)
