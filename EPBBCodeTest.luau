--!nocheck
local EPBBCode = require("./EPBBCode")

print("debug test suite!")

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
local thing: string = ""
local thing_ref = { out = ""}

-- testing by reference, try to make this more user-friendly if possible
--local out: string = EPBBText:TypewriterOut(thing_ref)
local out = EPBBText:TypewriterOut(thing)
local istrue = true
while istrue do
	EPBBText:TypewriterOut(thing_ref)
	print(thing_ref.out)
	if out == thing_ref.out then istrue = false end
end
print("----------------reference result------------")
print(thing_ref.out, "LENGTH: " .. tostring(#thing_ref.out))

print("----------------the rebuilt string---------------")
print(out, "LENGTH: " .. tostring(#out))

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
