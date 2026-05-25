--!nocheck

-- function related types
type BoundFunctions = {[string]: PTCallback}

-- image related types
type BoundImage = {
    isCached: boolean,
    ImageID: number
}

type BoundImages = {[string]: BoundImage}

-- image sequence related types
type ImageSequence = {
    Images: {number},
    isLooping: boolean,
    isCached: boolean
}

type BoundImageSequences = {[string]: ImageSequence}

-- event related types
-- bindable / client
type BoundEvents = {[string]: PTSignal}

-- server / network
type BoundNetworkEvents = {[string]: NetworkEvent}

-- animation related types
type BoundAnimations = {[string]: TweenObject}

-- gradient related types
type BoundGradients = {[string]: GradientImageAsset}

-- parsed text related types
type ParsedToken = string | {string | number}
type ParsedText = {ParsedToken}
type Metadata = {[string]: any}
type ParsedTextMetadata = {[number]: Metadata}

-- bindable types
type Bindable = 
PTCallback          |
BoundImage          |
BoundImage          |
ImageSequence       |
PTSignal            |
NetworkEvent        |
TweenObject         |
GradientImageAsset  

export type EPBBTextProperties = {

    -- mutable
    isPaused: boolean,
    typewriterSpeed: number,
    RawText: string,

    -- immutable while outputting
    isTypewriter: boolean, 

    -- read only
    ParsedText: ParsedText,
    EPBBTextMetadata: ParsedTextMetadata,
    Length: number,
    isOutputting: boolean,

    -- modified through methods only
    EPBBTextBoundFunctions: BoundFunctions,
    EPBBTextBoundImages: BoundImages,
    EPBBTextBoundImageSequences: BoundImageSequences,
    EPBBTextBoundEvents: BoundEvents,
    EPBBTextBoundNetworkEvents: BoundNetworkEvents,
    EPBBTextBoundAnimations: BoundAnimations,
    EPBBTextBoundGradients: BoundGradients,
    EPBBTextBoundLabel: UILabel,

    -- methods
    Get: (self: EPBBTextProperties) -> any,
    Set: (self: EPBBTextProperties) -> nil,
    Out: (self: EPBBTextProperties) -> nil,
    TypewriterOut: (self: EPBBTextProperties) -> nil,
    Bind: (self: EPBBTextProperties, value: Bindable) -> nil,
    Unbind: (self: EPBBTextProperties, value: Bindable) -> nil,
    Test: (self: EPBBTextProperties) -> nil
}

local EPBBText = {
    Enums = {
        Property = {
            RawText = 1,
            isTypewriter = 2,
            isPaused = 3,
            typewriterSpeed = 4,
		    ParsedText = 5,
		    Length = 6,
		    Images = 7,
		    isOutputting = 8
        },

        Tags = {
            BBCode_Open_Tag = 1,
            EPBBCode_Open_Tag = 2,
            BBCode_Close_Tag = 3,
            EPBBCode_Close_Tag = 4
        },

        EPBBTypes = {
            Function = 1,
            Image = 2,
            Image_Sequence = 3,
            BindableEvent = 4,
            NetworkEvent = 5,
            Animation = 6,
            Gradient = 7
        },

        SegmentTypes = {
          EPBBCode_Metadata = 1,
          Offset_Character = 2
          -- Characters / text that is appended immediately does not have a enum.
        },

        SegmentProperty = {
          Offset = 1,
          Character = 2,
          Type = 3,
          Args = 4,
          OutsideText = 5,
          CloseTagLength = 6,
          Column = 7,
          SegmentType = 8,
          Value = 9,
          WrappedText = 10,
          Text = 11,
        },

    }
}
EPBBText.__index = EPBBText

-- private

--[[
Example EPBBCode tag:
<[func='PlayACutscene', args={CutsceneName=First_cutscene, Local=true, Duration=10}]>!</[func]>

Example output data:
{
    "Type" = "Function",
    "Value" = "PlayACutscene",
    "Args" = {"CutsceneName"=First_cutscene, "Local"=true, "Duration"=10},
    "WrappedText" = !,
    "OutsideText" = nil,
    "CloseTagLength" = 9,
    "Column" = 1
}

]]--
local function GetEPBBCodeTagData(Tag: string, Column: number)
    local data = {
		[EPBBText.Enums.SegmentProperty.Type] = nil,
		[EPBBText.Enums.SegmentProperty.Value] = nil,
		[EPBBText.Enums.SegmentProperty.Args] = nil,
		[EPBBText.Enums.SegmentProperty.WrappedText] = nil,
        [EPBBText.Enums.SegmentProperty.OutsideText] = nil,
        [EPBBText.Enums.SegmentProperty.CloseTagLength] = nil,
        [EPBBText.Enums.SegmentProperty.Column] = Column,
        [EPBBText.Enums.SegmentProperty.SegmentType] = EPBBText.Enums.SegmentTypes.EPBBCode_Metadata
	}
    print(Tag)
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
	data[EPBBText.Enums.SegmentProperty.Type] = literal_type

	-- add other value types later
    if (value_type == "String") then
        -- find single quotes
        local string_start = Tag:find("'", valueDeclaration, true)
		-- +1 to avoid the initial '
        local string_end = Tag:find("'", string_start + 1, true)

		-- +1 to avoid the ', -1 to avoid another '
        local value = Tag:sub(string_start + 1, string_end - 1)
        data[EPBBText.Enums.SegmentProperty.Value] = value

		-- get args
		local argsDeclaration = Tag:find("args", string_start, true)
		if argsDeclaration == nil then
			warn("EPBBCode: unable to find args declaration in EPBBCode tag, leaving args as an empty table.")
			data[EPBBText.Enums.SegmentProperty.Args] = {}
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

			data[EPBBText.Enums.SegmentProperty.Args] = argsData
		end

		-- get wrapped text

        -- if not img or img_seq
        if not (literal_type == "Image") or not (literal_type == "Image Sequence") then
            local _, open_tag_end = Tag:find("]>", argsDeclaration, true)
		    -- searches for </[
            local close_tag_start = Tag:find("</[", open_tag_end, true)
            local _, close_tag_end = Tag:find("]>", close_tag_start, true)
            -- +2 to account for the <>
            local close_tag_length = close_tag_end - close_tag_start + 2
            data[EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length

            -- +1 to avoid the > on the open tag end, -1 to avoid the < on the close tag start
            local wrapped_text = Tag:sub(open_tag_end + 1, close_tag_start - 1)
		    data[EPBBText.Enums.SegmentProperty.WrappedText] = wrapped_text
        
        -- if img or img
        else
            local _, open_tag_end = Tag:find("]>", argsDeclaration, true)
		    -- searches for </[
            local close_tag_start = Tag:find("</[", open_tag_end, true)
            local _, close_tag_end = Tag:find("]>", close_tag_start, true)
            -- +2 to account for the <>
            local close_tag_length = close_tag_end - close_tag_start + 2
            data[EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length

            -- +1 to avoid the > on the open tag end, -1 to avoid the < on the close tag start
            local outside_text = Tag:sub(open_tag_end + 1, close_tag_start - 1)
		    data[EPBBText.Enums.SegmentProperty.OutsideText] = outside_text

        end

    end

	return data

end

local function GetEPBBCodeTagPriorityOrder(EPBBCodeTagBuffer: {})
    local ordered = {}

    return EPBBCodeTagBuffer
end

--[[
Parses RawText into a machine-readable format.
If isTypewriter is enabled, it'll parse it into per-letter segments, ignoring tags.
For text *after* a tag, it will be added to the ParsedText as "{"<letter>", <number of letters behind>}
eg;
RawText = "this is [color=red]red[/color]"
ParsedText = {"t", "h", "i", "s", " ", "i", "s", " ", "{[color=red], "open_tag"}" "{[/color], "close_tag"}", {"r", -8}, {"e", -8}, {"d", -8}}
]]--
local function ParseTypewriterText(RawText: string)
    local i = 1

    local states = {
        EPBBCODE_OPEN = 1,
        EPBBCODE_CLOSE = 2,
        BBCODE_OPEN = 3,
        BBCODE_CLOSE = 4
    }

    local state = nil

    local current_segment_type = nil
    local previous_segment_type = nil

    local open_tag_start = nil
    local open_tag_end = nil
    local open_tag_length = nil
    
    local close_tag_start = nil
    local close_tag_end = nil
    local close_tag_length = nil

    local text_buffer = {}
    local epbbcode_tag_buffer = {}
    local total_tag_length = 0

    local result = {}
    local metadata = {}

    while i <= #RawText do

        -- getting five types of characters is a naive way of doing this
        -- i know there's probably a faster way to do this but i'll do it later
        local character_minus_two = RawText:sub(i - 2, i)
        local character_minus_one = RawText:sub(i - 1, i)
        local character = RawText:sub(i, i)
        local character_plus_one = RawText:sub(i, i+1)
        local character_plus_two = RawText:sub(i, i+2) -- PLEASE

        -- get state
        if (character == "[") and not ((character_minus_one == "<[")) then
            state = states.BBCODE_OPEN
        end
        if (character_plus_one == "[/") then
            state = states.BBCODE_CLOSE
        end
        if (character_plus_one == "<[") then
            state = states.EPBBCODE_OPEN
        end
        if (character_plus_two == "</[") then
            state = states.EPBBCODE_CLOSE
        end

        if not (open_tag_start == nil) then
            if i > open_tag_start and i <= open_tag_end then i += 1; continue end
        end
        
        if not (close_tag_start == nil) then
            if i > close_tag_start and i <= close_tag_end then i += 1; continue end
        end 

        -- IF BBCode_Open_Tag (regular tags)
        if state == states.BBCODE_OPEN then
            open_tag_start = i
            _, open_tag_end = RawText:find("]", open_tag_start, true)
            
            -- short by 1 character, so just have a +1
            open_tag_length = open_tag_end - open_tag_start + 1
            total_tag_length += open_tag_length

            current_segment_type = EPBBText.Enums.Tags.BBCode_Open_Tag
            if previous_segment_type == nil then
                previous_segment_type = current_segment_type
            end

            local open_tag = RawText:sub(open_tag_start, open_tag_end)
            result[#result + 1] = open_tag
            i += 1

        -- IF BBCode_Close_Tag (regular tags)
        elseif state == states.BBCODE_CLOSE then
            close_tag_start = i
            _, close_tag_end = RawText:find("]", close_tag_start, true)
            
            -- short by 1 character, so just have a +1
            close_tag_length = close_tag_end - close_tag_start + 1
            total_tag_length += close_tag_length

            current_segment_type = EPBBText.Enums.Tags.BBCode_Close_Tag
            if previous_segment_type == nil then
                warn("EPBBCode: Close tag found before an open tag was found.")
                previous_segment_type = EPBBText.Enums.Tags.BBCode_Close_Tag
            end

            local close_tag = RawText:sub(close_tag_start, close_tag_end)
            result[#result + 1] = close_tag
            i += 1

        -- IF EPBBCode_Open_Tag (custom tags)
        elseif state == states.EPBBCODE_OPEN then
            open_tag_start = i
            close_tag_start = RawText:find("</[", open_tag_start, true)

            _, close_tag_end = RawText:find("]>", close_tag_start, true)
            _, open_tag_end = RawText:find("]>", open_tag_start, true)

            -- short by 1 character, so just have a +1
            open_tag_length = open_tag_end - open_tag_start + 1
            total_tag_length += open_tag_length

            current_segment_type = EPBBText.Enums.Tags.EPBBCode_Open_Tag
            if previous_segment_type == nil then
                previous_segment_type = EPBBText.Enums.Tags.EPBBCode_Open_Tag
            end

            local full_tag = RawText:sub(open_tag_start, close_tag_end)
            epbbcode_tag_buffer[#epbbcode_tag_buffer + 1] = GetEPBBCodeTagData(full_tag, (total_tag_length - open_tag_start + 2))

            i += 1

        -- IF EPBBCode_Close_Tag
        elseif state == states.EPBBCODE_CLOSE then
            close_tag_start = i
            _, close_tag_end = RawText:find("]>", close_tag_start, true)

            -- short by 1 character, so just have a +1
            close_tag_length = close_tag_end - open_tag_start + 1
            total_tag_length += close_tag_length


            current_segment_type = EPBBText.Enums.Tags.EPBBCode_Close_Tag
            if previous_segment_type == nil then
                warn("EPBBCode: Close tag found before an open tag was found.")
                previous_segment_type = EPBBText.Enums.Tags.EPBBCode_Close_Tag
            end

            i += 1
        
        -- IF REGULAR LETTER
        else

            if (current_segment_type == EPBBText.Enums.Tags.BBCode_Open_Tag) then
                text_buffer[#text_buffer + 1] = character
                i += 1

            elseif (current_segment_type == EPBBText.Enums.Tags.BBCode_Close_Tag) then

                for text_index = 1, #text_buffer do
                    result[#result + 1] = {
                      [EPBBText.Enums.SegmentProperty.Text] = text_buffer[text_index],
                      [EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length,
                      [EPBBText.Enums.SegmentTypes.Offset_Character] = EPBBText.Enums.SegmentTypes.Offset_Character
                    }
                end

                text_buffer = {}
                current_segment_type = nil

                i += 1
            
            else
                
                -- gets current character
                result[#result + 1] = RawText:sub(i, i)
                i += 1

            end

        end
    end

    metadata = GetEPBBCodeTagPriorityOrder(epbbcode_tag_buffer)

    return result, metadata
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
        [EPBBText.Enums.Property.RawText]            = function() end,
        [EPBBText.Enums.Property.isTypewriter]       = function() end,
        [EPBBText.Enums.Property.isPaused]           = function() end,
        [EPBBText.Enums.Property.typewriterSpeed]    = function() end,
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
        [EPBBText.Enums.Property.RawText]            = self.RawText,
        [EPBBText.Enums.Property.isTypewriter]       = self.isTypewriter,
        [EPBBText.Enums.Property.isPaused]           = self.isPaused,
        [EPBBText.Enums.Property.typewriterSpeed]    = self.typewriterSpeed,
        [EPBBText.Enums.Property.ParsedText]         = self.ParsedText,
        [EPBBText.Enums.Property.Length]       		 = self.Length,
        [EPBBText.Enums.Property.Images]           	 = self.Images,
        [EPBBText.Enums.Property.isOutputting]    	 = self.isOutputting,
    }

    return LookupTable[Property]
end

function EPBBText:Set(Property: number, Value: any): EPBBTextProperties
    -- lookup table for avoiding if-else chains
    local ExecTable = {
        [EPBBText.Enums.Property.RawText]            = function(Value) self.RawText = Value;         Update({EPBBText.Enums.RawText}) end,
        [EPBBText.Enums.Property.isTypewriter]       = function(Value) self.isTypewriter = Value;    Update({EPBBText.Enums.isTypewriter}) end,
        [EPBBText.Enums.Property.isPaused]           = function(Value) self.isPaused = Value;        Update({EPBBText.Enums.isPaused}) end,
        [EPBBText.Enums.Property.typewriterSpeed]    = function(Value) self.typewriterSpeed = Value; Update({EPBBText.Enums.typewriterSpeed}) end,
        [EPBBText.Enums.Property.ParsedText]         = function(Value) warn("EPBBText: ParsedText cannot be modified directly.") end,
        [EPBBText.Enums.Property.Length]       		 = function(Value) warn("EPBBText: Length cannot be modified directly.") end,
        [EPBBText.Enums.Property.Images]           	 = function(Value) warn("EPBBText: Images cannot be modified directly.") end,
        [EPBBText.Enums.Property.isOutputting]    	 = function(Value) warn("EPBBText: isOutputting cannot be modified directly.") end,
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

local function GetMetadataByColumn(metadata: Metadata, column: number)
    for _, data in pairs(metadata) do
        if data[EPBBText.Enums.SegmentProperty.Column] == column then
            return data
        end
    end
end

--[[
returns a string being the output string going to the output location
sets output_location.Text to be string + the current segment
--]]--
function EPBBText:TypewriterOut(output_location: UILabel)
    self.isOutputting = true

    if not self.isTypewriter then
        error("EPBBText: self.isTypewriter set to false, did you mean to call Out() instead? Ending output.", 2)
    end

    local output_string = ""
    for column, segment in pairs(self.ParsedText) do
        
        if not self.isTypewriter then
            error("EPBBText: self.isTypewriter set to false while outputting segments, ending output (why would you do that)", 2)
        end
        
        -- check if the segment is a table
        if typeof(segment) == "table" then
          print("segment is table:")
          -- check segment type
          -- if offset character
          if (segment[EPBBText.Enums.SegmentProperty.SegmentType] == EPBBText.Enums.SegmentTypes.Offset_Character) then
            local segment_character = segment[EPBBText.Enums.SegmentProperty.Text]
            local segment_offset = segment[EPBBText.Enums.SegmentProperty.Offset]
            print(segment_character, segment_offset)

            local string_first_half = output_string:sub(1, #output_string - segment_offset)
            local string_second_half = output_string:sub(#output_string - segment_offset, -1)

            output_string = string_first_half .. segment_character .. string_second_half
            continue

          -- if epbbcode tag (metadata) 
          elseif (segment[EPBBText.Enums.SegmentProperty.SegmentType] == EPBBText.Enums.SegmentTypes.EPBBCode_Metadata) then
            print("is metadata tag")
            -- lol idk 
            continue
          -- if neither (how)
          else
            error("EPBBText: segment " .. tostring(column) .. " in parsed text during TypewriterOut to " .. output_location.Name .. " was found to be a table but was empty", 2)
            continue
          end
        
        -- if the segment is a regular character / text
        else

          print("segment is not table: ", segment, column)
          output_string = output_string .. segment

        end

    end

    self.isOutputting = false
    return output_string
end

function EPBBText.New(RawText: string, isTypewriter: boolean): EPBBTextProperties
    local self = setmetatable({}, EPBBText)
    self.isTypewriter = isTypewriter
    self.RawText = RawText

    if isTypewriter then
		local ParsedText, Metadata = ParseTypewriterText(RawText)
        self.ParsedText = ParsedText
        self.EPBBTextMetadata = Metadata
    else
        local ParsedText, Metadata = ParseRegularText(RawText)
        self.ParsedText = ParsedText
        self.EPBBTextMetadata = Metadata
    end

    return self
end

return EPBBText
