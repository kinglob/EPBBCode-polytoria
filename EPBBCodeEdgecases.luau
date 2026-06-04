--!nocheck

local localplayer = Players.LocalPlayer
local EPBBCode = require(localplayer.EBPPCode)

print("edgecase test suite!")

local EPBBText = EPBBCode.New(
	"test, test, <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> and [b]bold[/b] andredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredredred <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]> [b]bold[/b] and <[func='function', args={foo=bar}]>[color=red]red[/color]</[func]>",
	true
)

local function THEFUNCTION()
	print("THEFUNCTION")
end

EPBBText:Bind_Function("function", nil, THEFUNCTION, false)
EPBBText:Set(EPBBText.Enums.Property.typewriterSpeed, 0.05)
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

if not Environment then
	print("not in polytoria testing environment!")
	return
end

print("---------polytoria environment testing---------")

wait(2)
local Output_UILabel = script.Parent:FindChild("EPBBCode_Testing_Label")

print("----function test----")
local function createapart()
	local part = Part.New()
	part.Size = Vector3.New(5, 5, 5)
	part.Color = Color.Random()
	part.Position = localplayer.Position
	part.Anchored = false
	part.Parent = Environment
end

local Polytoria_Test_Function = EPBBCode.New(
	"hocus pocus create me a [color=red]bloc[/color]<[func='createapart', args={foo=bar}]>[color=red]k[/color]</[func]>!",
	true
)
Polytoria_Test_Function:Bind_Function("createapart", nil, createapart, false)
Polytoria_Test_Function:Set(EPBBText.Enums.Property.typewriterSpeed, 0.05)
Polytoria_Test_Function:TypewriterOut(Output_UILabel, function(string_value)
	print(string_value)
end)

print("----image test----")
local Polytoria_Test_Image = EPBBCode.New("<[img='image_test1', args={}]>tung tung tung sten</[img]> there is a lot of whitespace here and it will result in a new line right about now! applesauce!<[img='image_test2', args={}]> img2</[img]>", true)

local Test_ImageAsset = PTImageAsset.New()
Test_ImageAsset.ImageID = 178035
Test_ImageAsset.ImageType = Enums.ImageType.Asset

Polytoria_Test_Image:Bind_Image("image_test1", nil, Test_ImageAsset, Vector2.New(32, 32), true, false)
Polytoria_Test_Image:Bind_Image("image_test2", nil, Test_ImageAsset, Vector2.New(32, 32), true, false)
Polytoria_Test_Image:Set(EPBBCode.Enums.Property.typewriterSpeed, 0.05)

Polytoria_Test_Image:TypewriterOut(Output_UILabel, function(string_value)
end)
