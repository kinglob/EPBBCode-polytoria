--!nocheck
local EPBBCode = require("./EPBBCode")

print("edgecase test suite!")

-- issue with this edgecase
-- the regular color bbcode tag is processed as regular text (NOT GOOD) when put inside of a EPBBCode tag (the function one)
-- fix this later as it shouldn't process the bbcode tag as regular text, and instead should be appended per-tag
local EPBBText = EPBBCode.New(
	"test, test, <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> and [b]bold[/b] andredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredred <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> [b]bold[/b] and <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]>",
	true
)
EPBBText:Set(EPBBText.Enums.Property.typewriterSpeed, 1)
print(EPBBText:Get(EPBBCode.Enums.Property.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.Property.ParsedText), "printing ParsedText")

print("------------------using typewriterout method--------")

local string_value: string = ""
local result = EPBBText:TypewriterOut(string_value, function(string_value)
	print(string_value)
end)

print("----------------the rebuilt string---------------")
print(string_value, "LENGTH: " .. tostring(#string_value))

print("------------------------metadata-----------------------")
for data_type, data in pairs(EPBBText:Get(EPBBCode.Enums.Property.Metadata)) do
	print("---------" .. tostring(data_type) .. "-----------")
	for column, piece in pairs(data) do
		print("-------" .. column .. "---------")
		for _, info in pairs(piece) do
			print(_, info)
		end
	end
end

print("---------")
