--!nocheck
export type EPBBTextProperties = {

    -- mutable
    isPaused: boolean,
    typewriterSpeed: number,
    RawText: string,

    -- immutable while outputting
    isTypewriter: boolean, 

    -- read only
    ParsedText: {},
    Length: number,
    Images: {[string]: string},
    isOutputting: boolean,

    -- methods
    Get: (self: EPBBTextProperties) -> any,
    Set: (self: EPBBTextProperties) -> nil,
    Out: (self: EPBBTextProperties) -> nil,
    TypewriterOut: (self: EPBBTextProperties) -> nil,
    BindLabel: (self: EPBBTextProperties) -> nil,
    UnbindLabel: (self: EPBBTextProperties) -> nil,
    Test: (self: EPBBTextProperties) -> nil
}

local EPBBText = {
    Enums = {
        RawText = 1,
        isTypewriter = 2,
        isPaused = 3,
        typewriterSpeed = 4,
				ParsedText = 5,
				Length = 6,
				Images = 7,
				isOutputting = 8
    }
}
EPBBText.__index = EPBBText

-- private

--[[
Parses RawText into a machine-readable format.
If isTypewriter is enabled, it'll parse it into per-letter segments, ignoring tags.
For text *after* a tag, it will be added to the ParsedText as "{"<letter>", <number of letters behind>}
eg;
RawText = "this is [color=red]red[/color]"
ParsedText = {"t", "h", "i", "s", " ", "i", "s", " ", "{[color=red], "open_tag"}" "{[/color], "close_tag"}", {"r", -8}, {"e", -8}, {"d", -8}}
]]--
local function ParseTypewriterText(RawText: string): any
    local result = {}

    local text_buffer = {}
    local close_tag_end = nil
    local close_tag_start = nil
    local close_tag_length = nil

    local open_tag_end = nil
    local open_tag_start = nil
    local open_tag_length = nil

    local segment_type = "none"
    local previous_segment_type = "none"

    for char = 1, #RawText do

        if not (open_tag_start == nil) then
            if char > open_tag_start and char <= open_tag_end then continue end
        end
        
        if not (close_tag_start == nil) then
            if char > close_tag_start and char == close_tag_end then continue end
        end

        local to_be_appended = ""

        -- get first character, and then get the first + second character
        local character = RawText:sub(char, char)
        local character_plus_one = RawText:sub(char, char + 1)
	    print(character, character_plus_one)
        
        -- IF OPEN_TAG
        if (character == "[") and not (character_plus_one == "[/") then
            segment_type = "open_tag"
			print(segment_type)

            if (previous_segment_type == "none") then
                previous_segment_type = "open_tag"
            end
            
            for search = char, #RawText do
                local search_character = RawText:sub(search, search)
                if not (search_character == "]") then continue end
				print("found end of open tag")

                -- set the "to be appended" to be the open tag
                local open_tag = RawText:sub(char, search)
                to_be_appended = {open_tag, segment_type}

                open_tag_end = search
                open_tag_start = char
                open_tag_length = #open_tag

                break
            end
        
        -- IF CLOSE_TAG
        elseif (character_plus_one == "[/") then
            segment_type = "close_tag"
			print(segment_type)

            if (previous_segment_type == "none") then
                previous_segment_type = "close_tag"
            end

            for search = char, #RawText do
                local search_character = RawText:sub(search, search)
                if not (search_character == "]") then continue end
				print("found end of close tag")

                -- set the "to be appended" to be the close tag
                local close_tag = RawText:sub(char, search)
                to_be_appended = {close_tag, segment_type}

                close_tag_end = search
                close_tag_start = char
                close_tag_length = #close_tag

                break
            end
        
        -- IF NONE
        else

            -- check if there's an open tag
            if (segment_type == "open_tag") then
                -- add to text buffer, unload after the segment_type is close_tag
                text_buffer[#text_buffer + 1] = character
                continue
            
            elseif (segment_type == "close_tag") then

                for _, text_in_buffer in pairs(text_buffer) do
                    print(text_in_buffer, close_tag_length)
                    result[#result + 1] = {text_in_buffer, close_tag_length}
                end
                
                text_buffer = {}
                segment_type = "none"
								
			else

				to_be_appended = character

            end

        end

        result[#result + 1] = to_be_appended

    end

    return result
end

local function ParseRegularText(RawText: string)

end

--[[
Gets called everytime ParsedText RawText, isTypewriter and isPaused is changed.
Recompiles all properties (except for methods) when called.
"args" expects EPBBText enums for what property got changed.
]]--
local function Update(args: {}): nil
    -- lookup table for avoiding if-else chains
    local ExecTable = {
        [EPBBText.Enums.RawText]            = function() end,
        [EPBBText.Enums.isTypewriter]       = function() end,
        [EPBBText.Enums.isPaused]           = function() end,
        [EPBBText.Enums.typewriterSpeed]    = function() end,
    }

    for _, arg in pairs(args) do
        local Exec = ExecTable[arg]
        Exec()
    end

    return
end

-- public

function EPBBText:Get(Property: number): any
    -- lookup table for avoiding if-else chains
    local LookupTable = {
        [EPBBText.Enums.RawText]            = self.RawText,
        [EPBBText.Enums.isTypewriter]       = self.isTypewriter,
        [EPBBText.Enums.isPaused]           = self.isPaused,
        [EPBBText.Enums.typewriterSpeed]    = self.typewriterSpeed,
        [EPBBText.Enums.ParsedText]         = self.ParsedText,
        [EPBBText.Enums.Length]       		= self.Length,
        [EPBBText.Enums.Images]           	= self.Images,
        [EPBBText.Enums.isOutputting]    	= self.isOutputting,
    }

    return LookupTable[Property]
end

function EPBBText:Set(Property: number, Value: any): EPBBTextProperties
    -- lookup table for avoiding if-else chains
    local ExecTable = {
        [EPBBText.Enums.RawText]            = function(Value) self.RawText = Value;         Update({EPBBText.Enums.RawText}) end,
        [EPBBText.Enums.isTypewriter]       = function(Value) self.isTypewriter = Value;    Update({EPBBText.Enums.isTypewriter}) end,
        [EPBBText.Enums.isPaused]           = function(Value) self.isPaused = Value;        Update({EPBBText.Enums.isPaused}) end,
        [EPBBText.Enums.typewriterSpeed]    = function(Value) self.typewriterSpeed = Value; Update({EPBBText.Enums.typewriterSpeed}) end,
        [EPBBText.Enums.ParsedText]         = function(Value) print("EPBBText: ParsedText cannot be modified directly.") end,
        [EPBBText.Enums.Length]       		= function(Value) print("EPBBText: Length cannot be modified directly.") end,
        [EPBBText.Enums.Images]           	= function(Value) print("EPBBText: Images cannot be modified directly.") end,
        [EPBBText.Enums.isOutputting]    	= function(Value) print("EPBBText: isOutputting cannot be modified directly.") end,
    }

    local Exec = ExecTable[Property]
    Exec(Value)

    return self
end

function EPBBText:Out(output_location: UILabel): nil
    self.isOutputting = true
    
    if self.isTypewriter then
        print("EPBBText: self.isTypewritter is set to true, did you mean to call TypewriterOut()? continuing output regardless")
    end

    self.isOutputting = false
    return
end

function EPBBText:TypewriterOut(output_location: UILabel): nil
    self.isOutputting = true

    if not self.isTypewriter then
        print("EPBBText: self.isTypewriter set to false, did you mean to call Out() instead?")
        return
    end

    local output_string = ""
    for _, segment in self.ParsedText do
        
        if not self.isTypewriter then
            print("EPBBText: self.isTypewriter set to false while outputting segments, ending output (why would you do that)")
            return
        end

        output_string = output_string .. segment
    end

    self.isOutputting = false
    return
end

function EPBBText.New(RawText: string, isTypewriter: boolean): EPBBTextProperties
    local self = setmetatable({}, EPBBText)
    self.isTypewriter = isTypewriter
    self.RawText = RawText

    if isTypewriter then
		local ParsedText = ParseTypewriterText(RawText)
        self.ParsedText = ParsedText
    else
        local ParsedText = ParseRegularText(RawText)
        self.ParsedText = ParsedText
    end

    return self
end

return EPBBText