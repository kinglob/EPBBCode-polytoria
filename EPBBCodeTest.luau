--!nocheck
local EPBBCode = require("./EPBBCode")

print("debug test suite!")

local EPBBText = EPBBCode.New(
	"test, test, <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> and [b]bold[/b] andredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredred <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> [b]bold[/b] and <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]>",
	true
)
print(EPBBText:Get(EPBBCode.Enums.Property.RawText), "printing RawText")
print(EPBBText:Get(EPBBCode.Enums.Property.ParsedText), "printing ParsedText")

print("------------------using typewriterout method--------")
local thing: string = ""
local out: string = EPBBText:TypewriterOut(thing)
print(out, "LENGTH: " .. tostring(#out))
print("------------------------metadata-----------------------")
for _, data in pairs(EPBBText.EPBBTextMetadata) do
	print("---------" .. tostring(_) .. "-----------")
	for _, piece in pairs(data) do
		print(_, piece)
	end
end
