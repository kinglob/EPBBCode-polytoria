--!nocheck

-- function related types
type BoundFunction = {
	FunctionRef: PTCallback | PTFunction | () -> nil,
	UnbindWhenCalled: boolean,
}

type BoundFunctions = { [string]: BoundFunction }

-- image related types
type BoundImage = {
	isCached: boolean,
	Cache: UIImage?, -- optional depending on the isCached value
	UnbindWhenCalled: boolean,
	ImageAsset: PTImageAsset, -- sighhh
}

type BoundImages = { [string]: BoundImage }

-- image sequence related types
type BoundImageSequence = {
	Images: { number },
	UnbindWhenCalled: boolean,
	isLooping: boolean,
	isCached: boolean,
}

type BoundImageSequences = { [string]: ImageSequence }

-- event related types
-- bindable / client
type BoundEvent = {
	EventRef: PTSignal | BindableEvent | PTSignalConnection,
	UnbindWhenCalled: boolean,
}
type BoundEvents = { [string]: BoundEvent }

-- server / network
type BoundNetworkEvent = {
	NetworkEventRef: PTSignal | NetworkEvent | PTSignalConnection,
	UnbindWhenCalled: boolean,
}
type BoundNetworkEvents = { [string]: BoundNetworkEvents }

-- animation related types
type BoundAnimation = {
	AnimationRef: TweenObject,
	UnbindWhenCalled: boolean,
}
type BoundAnimations = { [string]: BoundAnimation }

-- gradient related types
type BoundGradient = {
	GradientType: number, -- see EPBBCode.Enums.GradientTypes
	GradientData: GradientImageAsset | ColorSeries,
	UnbindWhenCalled: boolean,
}
type BoundGradients = { [string]: BoundGradient }

-- parsed text related types
type ParsedToken = string | { string | number }
type ParsedText = { ParsedToken }

-- metadata related types
type Metadata = { [number]: any }
type MetadataMap = { [string]: { [number]: Metadata } }
type BoundMetadataMap = { [string]: { [string]: any } }

-- bindable types
type Bindable =
	PTCallback
	| PTFunction
	| BoundImage
	| BoundImage
	| ImageSequence
	| PTSignal
	| BindableEvent
	| NetworkEvent
	| TweenObject
	| GradientImageAsset

export type EPBBTextProperties = {

	-- mutable
	isPaused: boolean,
	typewriterSpeed: number,
	FontSize: number,
	RawText: string,

	-- immutable while outputting
	isTypewriter: boolean,

	-- read only
	_ParsedText: ParsedText,
	_EPBBTextMetadata: MetadataMap,
	_EPBBTextBoundMetadata: BoundMetadataMap,
	_Length: number,
	_isOutputting: boolean,

	-- methods
	Get: (self: EPBBTextProperties) -> any,
	Set: (self: EPBBTextProperties) -> nil,
	Out: (self: EPBBTextProperties) -> nil,
	TypewriterOut: (self: EPBBTextProperties) -> nil,

	-- add binds
	Bind_Function: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundFunction: BoundFunction?,
		FunctionRef: PTCallback? | PTFunction? | () -> nil?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_Image: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundImage: BoundImage?,
		ImageAsset: PTImageAsset?,
		ImageSize: Vector2?,
		isCached: boolean?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_ImageSequence: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundImageSequence: BoundImageSequence?,
		Images: { PTImageAsset }?,
		isLooping: boolean?,
		isCached: boolean?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_Event: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundEvent: BoundEvent?,
		EventRef: PTSignal? | BindableEvent?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_NetworkEvent: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundNetworkEvent: BoundNetworkEvent?,
		NetworkEventRef: PTSignal | NetworkEvent?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_Gradient: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundGradient: BoundGradient?,
		GradientType: number?,
		GradientData: GradientImageAsset? | ColorSeries?,
		UnbindWhenCalled: boolean?
	) -> nil,
	Bind_Animation: (
		self: EPBBTextProperties,
		BoundName: string,
		BoundAnimation: BoundAnimation?,
		AnimationRef: TweenObject?,
		UnbindWhenCalled: boolean?
	) -> nil,

	-- add unbinds
	Unbind: (self: EPBBTextProperties, BoundName: string) -> nil,
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
			isOutputting = 7,
			Metadata = 8,
			FontSize = 9,
		},

		Tags = {
			BBCode_Open_Tag = 1,
			EPBBCode_Open_Tag = 2,
			BBCode_Close_Tag = 3,
			EPBBCode_Close_Tag = 4,
		},

		EPBBTypes = {
			Function = "Function",
			Image = "Image",
			Image_Sequence = "ImageSequence",
			BindableEvent = "BindableEvent",
			NetworkEvent = "NetworkEvent",
			Animation = "Animation",
			Gradient = "Gradient",
		},

		SegmentTypes = {
			EPBBCode_Metadata = 1,
			Offset_Character = 2,
			-- Characters / text that is appended immediately do not have a enum.
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

		GradientTypes = {
			ColorSeriesType = 1,
			HorizontalImgageType = 2,
			VerticalImageType = 3,
		},
	},
}
EPBBText.__index = EPBBText

-- private functions

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
    "Column" = 1,
    "SegmentType" = EPBBCode_Metadata
}

]]
--
local function GetEPBBCodeTagData(Tag: string, Column: number)
	local data = {
		[EPBBText.Enums.SegmentProperty.Type] = nil,
		[EPBBText.Enums.SegmentProperty.Value] = nil,
		[EPBBText.Enums.SegmentProperty.Args] = nil,
		[EPBBText.Enums.SegmentProperty.WrappedText] = {},
		[EPBBText.Enums.SegmentProperty.OutsideText] = {},
		[EPBBText.Enums.SegmentProperty.CloseTagLength] = nil,
		[EPBBText.Enums.SegmentProperty.Column] = Column,
		[EPBBText.Enums.SegmentProperty.SegmentType] = EPBBText.Enums.SegmentTypes.EPBBCode_Metadata,
	}

	local wrapped_text_data = data[EPBBText.Enums.SegmentProperty.WrappedText]

	local tag_start = 1
	local valueDeclaration = Tag:find("=", tag_start)

	-- +2 to avoid the "<[", -1 to avoid the "="
	local tag_type = Tag:sub(tag_start + 2, valueDeclaration - 1)

	local TypeLookupTable = {
		["func"] = EPBBText.Enums.EPBBTypes.Function, -- will find a corresponding Function
		["img"] = EPBBText.Enums.EPBBTypes.Image, -- will find a correspending Image
		["img_seq"] = EPBBText.Enums.EPBBTypes.Image_Sequence, -- will find a corresponding Image Sequence table
		["event"] = EPBBText.Enums.EPBBTypes.BindableEvent, -- will find a correspending BindableEvent
		["netevent"] = EPBBText.Enums.EPBBTypes.NetworkEvent, -- will find a corresponding NetworkEvent
		["anim"] = EPBBText.Enums.EPBBTypes.Animation, -- will find a corresponding TweenObject
		["gradient"] = EPBBText.Enums.EPBBTypes.Gradient, -- will find a corresponding GradientImageAsset
	}

	local literal_type = TypeLookupTable[tag_type]
	data[EPBBText.Enums.SegmentProperty.Type] = literal_type

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
	if not (literal_type == "Image") and not (literal_type == "Image Sequence") then
		local _, open_tag_end = Tag:find("]>", argsDeclaration, true)
		-- searches for </[
		local close_tag_start = Tag:find("</[", open_tag_end, true)
		local _, close_tag_end = Tag:find("]>", close_tag_start, true)
		-- +2 to account for the <>
		local close_tag_length = close_tag_end - close_tag_start + 2
		data[EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length

		-- +1 to avoid the > on the open tag end, -1 to avoid the < on the close tag start
		local wrapped_text = Tag:sub(open_tag_end + 1, close_tag_start - 1)
		-- check for bbcode / epbbcode tags inside of the wrapped text
		local open_bbcode_tag_start = wrapped_text:find("[", 1, true)
		if open_bbcode_tag_start == nil then
			wrapped_text_data[#wrapped_text_data + 1] = wrapped_text
		else
			local open_bbcode_tag_end = wrapped_text:find("]", open_bbcode_tag_start, true)
			if open_bbcode_tag_end == nil then
				error("EPBBCode: Couldn't find end of an opening BBCode tag wrapped inside of an EPBBCode tag!", 2)
			end
			local open_bbcode_tag = wrapped_text:sub(open_bbcode_tag_start, open_bbcode_tag_end)
			wrapped_text_data[#wrapped_text_data + 1] = open_bbcode_tag

			local close_bbcode_tag_start = wrapped_text:find("[/", open_bbcode_tag_end, true)
			if close_bbcode_tag_start == nil then
				warn("EPBBCode: Couldn't find closing BBCode tag wrapped inside of an EPBBCode tag!", 2)
			else
				local close_bbcode_tag_end = wrapped_text:find("]", close_bbcode_tag_start, true)
				if close_bbcode_tag_end == nil then
					error("EPBBCode: Couldn't find end of an opening BBCode tag wrapped inside of a EPBBCode tag!", 2)
				end
				-- short by one character, so add a +1
				local close_bbcode_tag_length = close_bbcode_tag_end - close_bbcode_tag_start + 1
				local close_bbcode_tag = wrapped_text:sub(close_bbcode_tag_start, close_bbcode_tag_end)

				wrapped_text_data[#wrapped_text_data + 1] = close_bbcode_tag

				-- get characters wrapped in the bbcode tags
				-- +1 to avoid the ], -1 to avoid the [
				local text_in_bbcode_tags = wrapped_text:sub(open_bbcode_tag_end + 1, close_bbcode_tag_start - 1)
				local i = 1

				while i <= #text_in_bbcode_tags do
					wrapped_text_data[#wrapped_text_data + 1] = {
						[EPBBText.Enums.SegmentProperty.Text] = text_in_bbcode_tags:sub(i, i),
						[EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length,
						[EPBBText.Enums.SegmentProperty.SegmentType] = EPBBText.Enums.SegmentTypes.Offset_Character,
					}
					i += 1
				end
			end
		end

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

	return data
end

--[[
Parses RawText into a machine-readable format.
If isTypewriter is enabled, it'll parse it into per-letter segments, ignoring tags.
For text *after* a tag, it will be added to the ParsedText as "{"<letter>", <number of letters behind>}
eg;
RawText = "this is [color=red]red[/color]"
ParsedText = {"t", "h", "i", "s", " ", "i", "s", " ", "{[color=red], "open_tag"}" "{[/color], "close_tag"}", {"r", -8}, {"e", -8}, {"d", -8}}
]]
--
local function ParseTypewriterText(RawText: string)
	local i = 1

	local states = {
		EPBBCODE_OPEN = 1,
		EPBBCODE_CLOSE = 2,
		BBCODE_OPEN = 3,
		BBCODE_CLOSE = 4,
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
	local total_tag_length = 0

	local result = {}
	local metadata = {}

	while i <= #RawText do
		-- getting five types of characters is a naive way of doing this
		-- i know there's probably a faster way to do this but i'll do it later
		local character_minus_two = RawText:sub(i - 2, i)
		local character_minus_one = RawText:sub(i - 1, i)
		local character = RawText:sub(i, i)
		local character_plus_one = RawText:sub(i, i + 1)
		local character_plus_two = RawText:sub(i, i + 2) -- PLEASE

		-- get state
		if character_plus_two == "</[" then
			state = states.EPBBCODE_CLOSE
		elseif character_plus_one == "<[" then
			state = states.EPBBCODE_OPEN
		elseif character_plus_one == "[/" then
			state = states.BBCODE_CLOSE
		elseif (character == "[") and not (character_minus_one == "<[") then
			state = states.BBCODE_OPEN
		end

		if not (open_tag_start == nil) then
			if i > open_tag_start and i <= open_tag_end then
				i += 1
				state = nil
				continue
			end
		end

		if not (close_tag_start == nil) then
			if i > close_tag_start and i <= close_tag_end then
				i += 1
				state = nil
				continue
			end
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

			for text_index = 1, #text_buffer do
				result[#result + 1] = {
					[EPBBText.Enums.SegmentProperty.Text] = text_buffer[text_index],
					[EPBBText.Enums.SegmentProperty.CloseTagLength] = close_tag_length,
					[EPBBText.Enums.SegmentProperty.SegmentType] = EPBBText.Enums.SegmentTypes.Offset_Character,
				}
			end

			text_buffer = {}
			current_segment_type = nil

			i += 1

		-- IF EPBBCode_Open_Tag (custom tags)
		elseif state == states.EPBBCODE_OPEN then
			local column_location = i - total_tag_length

			open_tag_start = i
			_, open_tag_end = RawText:find("]>", open_tag_start, true)

			-- +1 to start after open tag end
			close_tag_start = RawText:find("</[", open_tag_end + 1, true)
			_, close_tag_end = RawText:find("]>", close_tag_start, true)

			-- short by 1 character, so just have a +1
			open_tag_length = open_tag_end - open_tag_start + 1
			total_tag_length += open_tag_length

			current_segment_type = EPBBText.Enums.Tags.EPBBCode_Open_Tag

			local full_tag = RawText:sub(open_tag_start, close_tag_end)

			-- get column location
			if previous_segment_type == nil then
				previous_segment_type = EPBBText.Enums.Tags.EPBBCode_Open_Tag
			end

			local tag_metadata = GetEPBBCodeTagData(full_tag, column_location)
			-- sort by type string
			local tag_type = tag_metadata[EPBBText.Enums.SegmentProperty.Type]

			if metadata[tag_type] == nil then
				metadata[tag_type] = {}
				metadata[tag_type][column_location] = tag_metadata
			else
				metadata[tag_type][column_location] = tag_metadata
			end

			i += 1

		-- IF EPBBCode_Close_Tag
		elseif state == states.EPBBCODE_CLOSE then
			close_tag_start = i
			_, close_tag_end = RawText:find("]>", close_tag_start, true)

			-- short by 1 character, so just have a +1
			close_tag_length = close_tag_end - i + 1
			total_tag_length += close_tag_length

			current_segment_type = EPBBText.Enums.Tags.EPBBCode_Close_Tag
			if previous_segment_type == nil then
				warn("EPBBCode: Close tag found before an open tag was found.")
				previous_segment_type = EPBBText.Enums.Tags.EPBBCode_Close_Tag
			end

			i += 1

		-- IF REGULAR LETTER
		else
			if current_segment_type == EPBBText.Enums.Tags.BBCode_Open_Tag then
				text_buffer[#text_buffer + 1] = character
				i += 1
			else
				-- gets current character
				result[#result + 1] = RawText:sub(i, i)
				i += 1
			end
		end

		state = nil
	end

	return result, metadata
end

local function ParseRegularText(RawText: string) end

-- this is probably redundant except for when setting a new rawtext
local function Update(args: {}): nil
	-- lookup table for avoiding if-else chains
	local ExecTable = {
		[EPBBText.Enums.Property.RawText] = function() end,
		[EPBBText.Enums.Property.isTypewriter] = function() end,
		[EPBBText.Enums.Property.isPaused] = function() end,
		[EPBBText.Enums.Property.typewriterSpeed] = function() end,
	}

	for _, arg in pairs(args) do
		local Exec = ExecTable[arg]
		Exec()
	end

	return
end

-- gets length of a string without any bbcode or epbbcode tags polluting the string length
-- uses parsed text and checks each segment to see if it's a tag
local function GetParsedTextLength(ParsedText: ParsedText): number end

-- public

-- gets a property
-- also make this a metamethod with the dot operator
function EPBBText:Get(Property: number): any
	-- lookup table for avoiding if-else chains
	local LookupTable = {
		[EPBBText.Enums.Property.RawText] = self.RawText,
		[EPBBText.Enums.Property.isTypewriter] = self.isTypewriter,
		[EPBBText.Enums.Property.isPaused] = self.isPaused,
		[EPBBText.Enums.Property.typewriterSpeed] = self.typewriterSpeed,
		[EPBBText.Enums.Property.FontSize] = self.FontSize,
		[EPBBText.Enums.Property.ParsedText] = function()
			return self._ParsedText
		end,
		[EPBBText.Enums.Property.Length] = function()
			return self._Length
		end,
		[EPBBText.Enums.Property.isOutputting] = function()
			return self._isOutputting
		end,
		[EPBBText.Enums.Property.Metadata] = function()
			return self._EPBBTextMetadata
		end,
	}

	-- checks if value is returned via a function
	local prop_type = typeof(LookupTable[Property])
	if prop_type == "function" then
		local callback = LookupTable[Property]
		return callback()
	elseif LookupTable[Property] == nil then
		error("EPBBCode: Property enum " .. tostring(Property) .. " could not access a property.")
	else
		return LookupTable[Property]
	end
end

-- use metamethods to have this be the dot operator for this class
-- im not that smart so i'll probably do it after getting metadata working
function EPBBText:Set(Property: number, Value: any): EPBBTextProperties
	-- lookup table for avoiding if-else chains
	local ExecTable = {
		[EPBBText.Enums.Property.RawText] = function(Value)
			self.RawText = Value
			Update({ EPBBText.Enums.RawText })
		end,
		[EPBBText.Enums.Property.isTypewriter] = function(Value)
			self.isTypewriter = Value
			Update({ EPBBText.Enums.isTypewriter })
		end,
		[EPBBText.Enums.Property.isPaused] = function(Value)
			self.isPaused = Value
			Update({ EPBBText.Enums.isPaused })
		end,
		[EPBBText.Enums.Property.typewriterSpeed] = function(Value)
			self.typewriterSpeed = Value
			Update({ EPBBText.Enums.typewriterSpeed })
		end,
		[EPBBText.Enums.Property.ParsedText] = function(Value)
			warn("EPBBCode: ParsedText cannot be modified directly.")
		end,
		[EPBBText.Enums.Property.Length] = function(Value)
			warn("EPBBCode: Length cannot be modified directly.")
		end,
		[EPBBText.Enums.Property.isOutputting] = function(Value)
			warn("EPBBCode: isOutputting cannot be modified directly.")
		end,
	}

	local Exec = ExecTable[Property]
	Exec(Value)

	return self
end

function EPBBText:Out(output_location: UILabel | string): string | nil
	self.isOutputting = true

	if self.isTypewriter then
		warn(
			"EPBBCode: self.isTypewritter is set to true, did you mean to call TypewriterOut()? continuing output regardless"
		)
	end

	self.isOutputting = false
	return
end

local function GetMetadataByColumn(column: number, MetadataMapInfo: MetadataMap)
	for _, BindType in pairs(MetadataMapInfo) do
		for MetadataColumn, Metadata in pairs(BindType) do
			if column ~= MetadataColumn then
				continue
			end
			return Metadata
		end
	end

	return nil
end

local function GetBoundMetadataByName(BoundName: string, EPBBData: EPBBTextProperties)
	local BoundMetadataMap = EPBBData._EPBBTextBoundMetadata

	for BoundTypeName, BoundType in pairs(BoundMetadataMap) do
		for Name, BoundMetadata in pairs(BoundType) do
			if BoundName ~= Name then
				continue
			end

			return BoundMetadata
		end
	end
	return
end

type OutputLocation = UILabel | string | { string } | StringValue
local function ExecuteMetadata(Metadata: Metadata, EPBBData: EPBBTextProperties, output_location: OutputLocation)
	local MetadataType = Metadata[EPBBText.Enums.SegmentProperty.Type]

	-- function exec
	if MetadataType == EPBBText.Enums.EPBBTypes.Function then
		local metadataname = Metadata[EPBBText.Enums.SegmentProperty.Value]
		if metadataname == nil then
			error("EPBBCode: Failed to get value of Metadata when trying to execute metadata!", 2)
		end

		local boundmetadata = GetBoundMetadataByName(metadataname, EPBBData)
		if boundmetadata == nil then
			error(
				"EPBBCode: No binding found for '"
					.. metadataname
					.. "'. Did you call Bind_Function before TypewriterOut?",
				2
			)
		end

		local FunctionRef = boundmetadata.FunctionRef

		if FunctionRef == nil then
			error(
				"EPBBCode: Bound entry for '"
					.. metadataname
					.. "' has no FunctionRef. Was it bound correctly in Bind_Function?",
				2
			)
		end

		if typeof(FunctionRef) ~= "function" then
			error("EPBBCode: FunctionRef for '" .. metadataname .. "' is not callable, got " .. typeof(FunctionRef), 2)
		end

		-- add the bound arguments to this function via a table
		FunctionRef()

		if boundmetadata.UnbindWhenCalled then
			EPBBData._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Function][metadataname] = nil
		end

		return EPBBText.Enums.EPBBTypes.Function, FunctionRef

	-- image exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.Image then
		if typeof(output_location) ~= "UILabel" then
			error("EPBBCode: Unable to use EPBB tag 'Image' when not outputting to UILabel.")
		end

		local metadataname = Metadata[EPBBText.Enums.SegmentProperty.Value]
		if metadataname == nil then
			error("EPBBCode: Failed to get value of Metadata when trying to execute metadata!", 2)
		end

		local boundmetadata = GetBoundMetadataByName(metadataname, EPBBData)
		if boundmetadata == nil then
			error(
				"EPBBCode: No binding found for '"
					.. metadataname
					.. "'. Did you call Bind_Function before TypewriterOut?",
				2
			)
		end

		local ImageID = boundmetadata.ImageAsset.ImageID
		if ImageID == nil then
			error(
				"EPBBCode: Bound entry for '"
					.. metadataname
					.. "' has no ImageID. Was it bound correctly in Bind_Image?."
			)
		end

		if boundmetadata.isCached then
			local image_cache = boundmetadata.Cache
			image_cache.PositionRelative = output_location.PositionRelative

			local horizontal_alignment = output_location.HorizontalAlignment
			local vertical_alignment = output_location.VerticalAlignment

			if Enums.VerticalAlignment.Top == vertical_alignment then
				image_cache.PositionRelative = Vector2.New(image_cache.PositionRelative.X, 0)
				image_cache.PositionOffset = Vector2.New(image_cache.SizeOffset.X / 2, image_cache.SizeOffset.Y / 2)
			elseif Enums.VerticalAlignment.Middle == vertical_alignment then
				image_cache.PositionRelative = Vector2.New(image_cache.PositionRelative.X, 0.5)
				image_cache.PositionOffset = Vector2.New(image_cache.SizeOffset.X / 2, image_cache.SizeOffset.Y / 2)
			elseif Enums.VerticalAlignment.Bottom == vertical_alignment then
				image_cache.PositionRelative = Vector2.New(image_cache.PositionRelative.X, 1)
				image_cache.PositionOffset = Vector2.New(image_cache.SizeOffset.X / 2, -image_cache.SizeOffset.Y / 2)
			end

			if Enums.HorizontalAlignment.Left == horizontal_alignment then
				image_cache.PositionRelative = Vector2.New(0, image_cache.PositionRelative.Y)
			elseif Enums.HorizontalAlignment.Center == horizontal_alignment then
				image_cache.PositionRelative = Vector2.New(0.5, image_cache.PositionRelative.Y)
			elseif Enums.HorizontalAlignment.Right == horizontal_alignment then
				image_cache.PositionRelative = Vector2.New(1, image_cache.PositionRelative.Y)
			end

			image_cache.Parent = output_location
			return EPBBText.Enums.EPBBTypes.Image, image_cache
		else
			local metadataimage = UIImage.New()
			metadataimage.SizeOffset = boundmetadata.ImageSize
			metadataimage.Image = boundmetadata.ImageAsset
			metadataimage.Parent = output_location
			boundmetadata.Cache = metadataimage
			return EPBBText.Enums.EPBBTypes.Image, metadataimage
		end

	-- animation exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.Animation then

	-- image sequence exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.Image_Sequence then

	-- gradient exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.Gradient then

	-- bindable event exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.BindableEvent then

	-- network event exec
	elseif MetadataType == EPBBText.Enums.EPBBTypes.NetworkEvent then
	end
end

-- this is very sensitive to what the what the string table element is called
-- luau, PLEASE give us a way to pass by reference without tables :sob:
local function ParseSegment(segment: any, string: { string }, EPBBData: EPBBTextProperties): nil
	-- check if the segment is a table

	if typeof(segment) == "table" then
		-- check segment type
		-- if offset character
		if segment[EPBBText.Enums.SegmentProperty.SegmentType] == EPBBText.Enums.SegmentTypes.Offset_Character then
			local segment_character = segment[EPBBText.Enums.SegmentProperty.Text]
			local segment_offset = segment[EPBBText.Enums.SegmentProperty.CloseTagLength]

			local string_first_half = string.Value:sub(1, #string.Value - segment_offset)
			-- +1 to avoid trailing characters from the tag
			local string_second_half = string.Value:sub(#string.Value - segment_offset + 1, -1)

			string.Value = string_first_half .. segment_character .. string_second_half

			if #segment_character > 1 then
				local font_size_start, font_size_end = segment:find("font_size")
				local font_size_value = nil
				if font_size_start then
					local value_declaration_start = segment:find("=", font_size_end)
					local value_declaration_end = segment:find("]", value_declaration)
					font_size_value = tonumber(segment:sub(value_declaration_start, value_declaration_end))
				end
			end

			return

		-- if not (how)
		else
			error("EPBBCode: failed to get type of segment! Type is: " .. tostring(typeof(segment)), 2)
		end

	-- if the segment is a regular character / text
	else
		if #segment > 1 then
			local font_size_start, font_size_end = segment:find("font_size")
			local font_size_value = nil
			if font_size_start then
				local value_declaration_start = segment:find("=", font_size_end)
				local value_declaration_end = segment:find("]", value_declaration)
				font_size_value = tonumber(segment:sub(value_declaration_start, value_declaration_end))
			end
		end
		string.Value = string.Value .. segment
	end

	return font_size_value
end

-- gets the row index based on the true column number
-- true column is expected to be a table value as it's passed by reference
local function GetRow(true_column: { number }, font_size: number, output_location: UILabel): number end

--[[
returns a string being the output string going to the output location

sets output_location.Text to be string + the current segment
--]]
function EPBBText:TypewriterOut(output_location: OutputLocation, onUpdate: ((string) -> nil)?): string
	if not self.isTypewriter then
		error("EPBBCode: self.isTypewriter set to false, did you mean to call Out() instead? Ending output.", 2)
	end

	self._isOutputting = true
	local output_string = { Value = "" }
	local total_tag_length = { Value = 0 }
	local should_wait = false
	local in_image = false
	local is_whitespace = false
	local image_map = {}
	local horizontal_alignment = output_location.HorizontalAlignment
	local vertical_alignment = output_location.VerticalAlignment

	-- current_font_size should automatically update depending on if it encounters a font_size tag
	local current_font_size = self.FontSize

	local thread = coroutine.create(function()
		local column = 1
		local true_column = { Value = 1 }

		while column <= #self._ParsedText do
			local segment = self._ParsedText[column]

			if not self.isTypewriter then
				error(
					"EPBBCode: self.isTypewriter set to false while outputting segments, ending output (why would you do that)",
					2
				)
			end

			-- handle metadata first
			-- get metadata for that column, if there is any
			if GetMetadataByColumn(column, self._EPBBTextMetadata) ~= nil then
				local MetadataBind = GetMetadataByColumn(column, self._EPBBTextMetadata)
				local metadatatype, metadataresult = ExecuteMetadata(MetadataBind, self, output_location)

				if metadatatype == EPBBText.Enums.EPBBTypes.Function then
					-- literally no reason to exist
				elseif metadatatype == EPBBText.Enums.EPBBTypes.Image then
					image_map[#image_map + 1] = metadataresult
				elseif metadatatype == EPBBText.Enums.EPBBTypes.Image_Sequence then
				elseif metadatatype == EPBBText.Enums.EPBBTypes.Animation then
				elseif metadatatype == EPBBText.Enums.EPBBTypes.Gradient then
				elseif metadatatype == EPBBText.Enums.EPBBTypes.BindableEvent then
				elseif metadatatype == EPBBText.Enums.EPBBTypes.NetworkEvent then
				end
			end

			-- this literally does everything
			local font_size_value = ParseSegment(segment, output_string, self)
			if font_size_value then
				current_font_size = font_size_value
			end

			-- check if segment is > 1 (if true, it's a bbcode tag)
			if typeof(segment) ~= "table" then
				if not (#segment > 1) then
					should_wait = true

					if segment == " " then
						is_whitespace = true
					else
						is_whitespace = false
					end
				else
					should_wait = false
					total_tag_length.Value += #segment
				end
			else
				-- check if the segment is a offset character
				if
					segment[EPBBText.Enums.SegmentProperty.SegmentType] == EPBBText.Enums.SegmentTypes.Offset_Character
				then
					if segment[EPBBText.Enums.SegmentProperty.Text] == " " then
						is_whitespace = true
					else
						is_whitespace = false
					end

					if not (#segment[EPBBText.Enums.SegmentProperty.Text] > 1) then
						should_wait = true
					end
				else
					should_wait = false
				end
			end

			-- decide where to output (typesafe wowowow)
			if typeof(output_location) == "UILabel" then
				output_location.Text = output_string.Value
			elseif typeof(output_location) == "string" then
				output_location = output_string.Value
			elseif (typeof(output_location) == "table") or (typeof(output_location) == "StringValue") then
				output_location.Value = output_string.Value
			else
				error(
					"EPBBCode: Output location variable is type of "
						.. typeof(output_location)
						.. " which is unsupported!",
					2
				)
			end

			column += 1
			true_column.Value += 1

			-- shift images that have been added to the right if should wait
			if should_wait and not is_whitespace then
				for i = 1, #image_map do
					local image_ref = image_map[i]

					-- defaults to left horizontal alignment
					if horizontal_alignment == Enums.HorizontalAlignment.Center then
						image_ref.PositionOffset = image_ref.PositionOffset + Vector2.New(current_font_size / 2, 0)

					-- leave this as is until right-to-left languages / text is supported
					elseif horizontal_alignment == Enums.HorizontalAlignment.Right then
						image_ref.PositionOffset = image_ref.PositionOffset + Vector2.New(current_font_size / 2, 0)
					else
						image_ref.PositionOffset = image_ref.PositionOffset + Vector2.New(current_font_size, 0)
					end
				end
			end

			coroutine.yield(should_wait)
		end
	end)

	while coroutine.status(thread) ~= "dead" do
		if not self.isPaused then
			if coroutine.status(thread) == "suspended" then
				local success, err = pcall(coroutine.resume, thread)
				if not success then
					error("EPBBCode: Unable to resume TypewriterOut thread. Err: " .. tostring(err), 2)
				end
			end

			if onUpdate then
				onUpdate(output_string.Value)
			end

			-- wait here to avoid the yield
			if should_wait then
				--wait(self.typewriterSpeed)
			end
		else
			--wait(0.1)
		end
	end

	self.isOutputting = false
	return output_string.Value
end

function EPBBText:Bind_Function(
	BoundName: string,
	BoundFunction: BoundFunction?,
	FunctionRef: PTCallback? | PTFunction? | () -> nil?,
	UnbindWhenCalled: boolean?
)
	if self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Function] == nil then
		self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Function] = {}
	end

	local BoundFunctions = self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Function]
	local BoundFunctionData = {}

	if BoundFunction ~= nil then
		BoundFunctionData = BoundFunction
	else
		if FunctionRef == nil then
			error("EPBBCode: Bind_Function requires either a BoundFunction table or a FunctionRef, got neither.", 2)
		end
		BoundFunctionData = {
			FunctionRef = FunctionRef,
			UnbindWhenCalled = UnbindWhenCalled or false,
		}
	end

	BoundFunctions[BoundName] = BoundFunctionData
end

function EPBBText:Bind_Image(
	BoundName: string,
	BoundImage: BoundImage?,
	ImageAsset: PTImageAsset?,
	ImageSize: Vector2?,
	isCached: boolean?,
	UnbindWhenCalled: boolean?
)
	if self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Image] == nil then
		self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Image] = {}
	end

	local BoundImages = self._EPBBTextBoundMetadata[EPBBText.Enums.EPBBTypes.Image]
	local BoundImageData = {}

	if BoundImage ~= nil then
		if BoundImage.ImageAsset == nil then
			error("EPBBCode: Bind_Image requires either a BoundImage table or a valid ImageAsset, got neither.", 2)
		elseif typeof(BoundImage.ImageAsset.ImageID) ~= "number" then
			error(
				"EPBBCode: Bind_Image requires an ImageAsset with a valid ImageID when passing in an ImageAsset or BoundImage table."
			)
		end

		local Cache = BoundImage.Cache
		if BoundImage.isCached then
			Cache = UIImage.New()
			if not Hidden:FindChild("EPBBCode_Cache") then
				local epbbcode_cache = Folder.New()
				epbbcode_cache.Parent = Hidden
			end

			Cache.SizeOffset = BoundImage.ImageSize
			Cache.Image = BoundImage.ImageAsset
			Cache.Parent = Hidden:FindChild("EPBBCode_Cache")
		end

		BoundImageData = BoundImage
	else
		if ImageAsset == nil then
			error("EPBBCode: Bind_Image requires either a BoundImage table or a valid ImageAsset, got neither.", 2)
		elseif typeof(ImageAsset.ImageID) ~= "number" then
			error(
				"EPBBCode: Bind_Image requires an ImageAsset with a valid ImageID when passing in an ImageAsset or BoundImage table."
			)
		end

		local Cache = nil
		if isCached then
			Cache = UIImage.New()
			if not Hidden:FindChild("EPBBCode_Cache") then
				local epbbcode_cache = Folder.New()
				epbbcode_cache.Parent = Hidden
			end

			Cache.SizeOffset = ImageSize
			Cache.Image = ImageAsset
			Cache.Parent = Hidden:FindChild("EPBBCode_Cache")
		end

		BoundImageData = {
			ImageAsset = ImageAsset,
			ImageSize = ImageSize,
			isCached = isCached or false,
			Cache = Cache,
			UnbindWhenCalled = UnbindWhenCalled or false,
		}
	end

	BoundImages[BoundName] = BoundImageData
end

function EPBBText:Unbind(EPBBType: number, BoundName: string) end

--[[
Makes a new EPBBText with the specified string
RawText (and thereby the parsed output text) can be changed by changing the RawText value.
isTypewriter and FontSize default to false, 14 repsectively.
]]
--
function EPBBText.New(RawText: string, isTypewriter: boolean?, FontSize: number?): EPBBTextProperties
	local self = setmetatable({}, EPBBText)
	self.isTypewriter = isTypewriter or false
	self.FontSize = FontSize or 14

	-- set text font size to the set FontSize
	self.RawText = "[font_size=" .. tostring(self.FontSize) .. "]" .. RawText .. "[/font_size]"
	self._EPBBTextBoundMetadata = {}

	if isTypewriter then
		local ParsedText, Metadata = ParseTypewriterText(RawText)
		self._ParsedText = ParsedText
		self._EPBBTextMetadata = Metadata
	else
		local ParsedText, Metadata = ParseRegularText(RawText)
		self._ParsedText = ParsedText
		self._EPBBTextMetadata = Metadata
	end

	return self
end

return EPBBText
