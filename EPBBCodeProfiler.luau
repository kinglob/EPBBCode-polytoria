local EPBBCode = require("./EPBBCode")

print("stress test suite!")

local stress_test_string_1 = 
"thisisthestartofalongstringwithlotsoftags"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
.. "bbcoode is [color=red]red[/color]"
.. "bbocde is [b]bold[/bold]"
.. "bbcode is [b][color=red]red and bold[/color][/b]"
.. "epbbcode is <[func='function', args={foo=bar}]>function</[func]>"
local EPBBText = EPBBCode.New(stress_test_string_1, true)
EPBBText:Set(EPBBText.Enums.Property.typewriterSpeed, 0.1)

print("------------------using typewriterout method--------")

-- really weird thing with strings is that they don't work with larger values
-- this is fixed if you pass it by reference
-- probably has something to do with the luau compiler not wanting to copy large values
local string_value = ""
local result = EPBBText:TypewriterOut(string_value, function(string_value)
	print(string_value)
    print("-----")
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