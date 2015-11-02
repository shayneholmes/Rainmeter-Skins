--[[
    Lua script to use with dinaj.ini Rainmeter skin
    FlyingHyrax
    2014-11-15
--]]

--[[ LOCAL VARIABLES =========================================================]]

-- personal taste - values parsed from skin variables
local JACKET_LIMIT, COAT_LIMIT, UNIT
-- NOT personal taste - used to distribute descriptors across range of temperatures
local TEMP_MIN, TEMP_MAX = -10, 120
-- words for describing various temperatures
local TEMP_DESCRIPTORS = {
    "damn cold",
    "darn cold",
    "bone chilling",
    "glacial",
    "frigid",
    "freezing",
    "frosty",
    "pretty cold",
    "chilly",
    "brisk",
    "cool",
    "quite temperate",
    "rather mild",
    "pretty nice",
    "positively balmy",
    "extra warm",
    "kinda hot",
    "roasting",
    "scorching",
    "oven-like",
    "your hair is on FIRE",
}

-- measure handles
local tempStrMsr, tempUnitMsr
-- meter handles
local mainMeter, subMeter

--[[ LOCAL FUNCTIONS =========================================================]]

--[[ printf shortcut ]]
local function printf(format, ...)
    print(string.format(format, ...))
end

--[[ Keeps a value inside the given range ]]
local function clamp( value, min, max )
    local clamped = value
    if value < min then
        clamped = min
    elseif value > max then
        clamped = max
    end
    return clamped
end

--[[ Adjusts a value and its defined range if the value is negative ]]
local function normalize( value, min, max )
    local excess = min < 0 and 0 - min or 0
    return value + excess, min + excess, max + excess
end

--[[ Return a value as a percentage of its range ]]
local function percentOfRange( value, min, max )
    -- normalize
    local value, min, max = normalize( value, min, max)
    -- maths
    local percent = (value / max - min)
    -- clamping
    return clamp( percent, 0.0, 1.0)
end

--[[ Convert a number from fahrenheit to celsius ]]
local function f2c( fahrenheit )
    return (((fahrenheit - 32) * 5) / 9)
end

--[[ Convert a number from celsius to fahrenheit (unused) ]]
local function c2f( celsius )
    return (((celsius * 9) / 5) + 32)
end

--[[ Given the current temperature and its scale,
  return a descriptor for that temperature ]]
local function getTempWord( temp, unit )
    -- convert our range bounds to celsius if necessary
    local unit = unit or 'f'
    local tmin = unit == 'f' and TEMP_MIN or f2c(TEMP_MIN)
    local tmax = unit == 'f' and TEMP_MAX or f2c(TEMP_MAX)
    -- percentage of our temperature range
    local tempPer = percentOfRange( temp, tmin, tmax )
    -- index in array of descriptors, based on that percentage
    local index = math.ceil( #TEMP_DESCRIPTORS * tempPer )
    -- if temp is 0% of our range, index will be off by one
    if index < 1 then index = 1 end
    -- return that word
    return TEMP_DESCRIPTORS[index]
end

--[[ Given the current temperature, return the appropriate
  string for the main string meter ]]
local function getMainString( temp )
    local negation = (temp > JACKET_LIMIT) and " don't" or ""
    local outerwear = (temp < COAT_LIMIT) and "coat" or "jacket"
    return string.format("You%s need a %s", negation, outerwear)
end

--[[ Given the current temperature and its unit, return the appropriate string
  for the secondary string meter ]]
local function getSubString( temp, unit )
    return string.format("It's %s outside", getTempWord(temp, unit))
end

--[[ Sets the Text value of the specified meter with a SetOption bang ]]
local function setStringMeterText( meterName, text )
    SKIN:Bang('!SetOption', meterName, 'Text', text)
end

--[[ Log the descriptor which is returned for various temperatures ]]
local function test()
    for i = -20, 100, 5 do
        printf("t=%d, s=%s", i, getTempWord(i))
    end
end


--[[ GLOBAL SKIN FUNCTIONS ===================================================]]

--[[ Run on Refresh (or on update if DynamicVariables is set on the script measure)
  Retrieves user specified values from variables and handles to measures and meters ]]
function Initialize()
    -- read settings
    JACKET_LIMIT = tonumber(SKIN:GetVariable("jacket_temp", 65))
    COAT_LIMIT = tonumber(SKIN:GetVariable("coat_temp", 35))
    UNIT = string.lower(SKIN:GetVariable("unit", "f"))
    -- measure handles
    tempStrMsr = SKIN:GetMeasure("mChillTemp")
    tempUnitMsr = SKIN:GetMeasure("mTempUnit")
    -- meter handles
    mainMeter = SKIN:GetMeter("mainString")
    subMeter = SKIN:GetMeter("subString")
    -- run tests
    -- test()
end

--[[ Run on Update - We need to update two different string meters on every tick,
  So we use a bang for both and do not return a value. ]]
function Update()
    -- get current temp
    local temp = tonumber(tempStrMsr:GetStringValue())
    -- WebParser will not have returned values for the first few update ticks
    if temp ~= nil then
        setStringMeterText(mainMeter:GetName(), getMainString(temp))
        setStringMeterText(subMeter:GetName(), getSubString(temp, UNIT))
    end
end
