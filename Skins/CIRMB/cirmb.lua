--[[
    Lua script to use with dinaj.ini Rainmeter skin
    Shayne Holmes
    2015-11-02
    Orig. by FlyingHyrax, 2014-11-15
--]]

--[[ LOCAL VARIABLES =========================================================]]

-- personal taste - values parsed from skin variables
local WARM_LIMIT, COOL_LIMIT, UNIT
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
    "hot as the sun",
}
-- words of encouragement
local ENCOURAGEMENT = {
    "you should get out there",
    "you need the exercise",
    "that bike won't ride itself",
    "you don't want to miss it",
    "you're no wuss",
    "cyclists gotta cycle",
}
-- all weather codes
-- from https://developer.yahoo.com/weather/documentation.html#codes
local allWeather = {
  [0] = "tornado",
  [1] = "tropical storm",
  [2] = "hurricane",
  [3] = "severe thunderstorms",
  [4] = "thunderstorms",
  [5] = "mixed rain and snow",
  [6] = "mixed rain and sleet",
  [7] = "mixed snow and sleet",
  [8] = "freezing drizzle",
  [9] = "drizzle",
  [10] = "freezing rain",
  [11] = "showers",
  [12] = "showers",
  [13] = "snow flurries",
  [14] = "light snow showers",
  [15] = "blowing snow",
  [16] = "snow",
  [17] = "hail",
  [18] = "sleet",
  [19] = "dust",
  [20] = "foggy",
  [21] = "haze",
  [22] = "smoky",
  [23] = "blustery",
  [24] = "windy",
  [25] = "cold",
  [26] = "cloudy",
  [27] = "mostly cloudy (night)",
  [28] = "mostly cloudy (day)",
  [29] = "partly cloudy (night)",
  [30] = "partly cloudy (day)",
  [31] = "clear (night)",
  [32] = "sunny",
  [33] = "fair (night)",
  [34] = "fair (day)",
  [35] = "mixed rain and hail",
  [36] = "hot",
  [37] = "isolated thunderstorms",
  [38] = "scattered thunderstorms",
  [39] = "scattered thunderstorms",
  [40] = "scattered showers",
  [41] = "heavy snow",
  [42] = "scattered snow showers",
  [43] = "heavy snow",
  [44] = "partly cloudy",
  [45] = "thundershowers",
  [46] = "snow showers",
  [47] = "isolated thundershowers",
  [3200] = "not available",
  }
local dangerousWeather = {
  [0] = "Tornadoes aren't fun", -- tornado
  [1] = "Tropical storms are dangerous", -- tropical storm
  [2] = "Hurricanes are afoot", -- hurricane
  [3] = "Severe thunderstorms can kill you", -- severe thunderstorms
  [4] = "Nobody likes thunderstorms", -- thunderstorms
  [5] = "Mixed rain and snow lessens traction", -- mixed rain and snow
  [8] = "Freezing drizzle is nasty", -- freezing drizzle
  [10] = "Freezing rain can hurt you", -- freezing rain
  [13] = "Snow flurries are blinding", -- snow flurries
  [14] = "Light snow showers can make riding tough", -- light snow showers
  [15] = "Blowing snow reduces visibility", -- blowing snow
  [16] = "Snow gets in your path", -- snow
  [41] = "Heavy snow is inconvenient at best", -- heavy snow
  [43] = "Heavy snow can make you slip", -- heavy snow
  [45] = "Thundershowers can be dangerous", -- thundershowers
  [46] = "Snow showers are gnarly", -- snow showers
  }
local adverseWeather = {
  [6] = "a little rainy", -- mixed rain and sleet
  [7] = "a little rainy", -- mixed snow and sleet
  [9] = "a little rainy", -- drizzle
  [11] = "rainy", -- showers
  [12] = "rainy", -- showers
  [17] = "hailing", -- hail
  [18] = "rainy", -- sleet
  [23] = "windy", -- blustery
  [35] = "rainy", -- mixed rain and hail
  }

-- measure handles
local tempStrMsr, tempUnitMsr, tempCodeMsr
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
local function getTempWords( code, temp, unit )
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
    -- pick that word
    local descriptor = TEMP_DESCRIPTORS[index]
    -- add adverse weather message if needed
    if adverseWeather[code] ~= nil then
      descriptor = descriptor .. " and " .. adverseWeather[code]
    end
    return descriptor
end

--[[ Given the current temperature and its scale,
  return a message of encouragement to tack on ]]
local function getEncouragement( temp, unit )
    local agreeable = (temp > COOL_LIMIT) and (temp < WARM_LIMIT)
    local text = ", " 
      .. (agreeable and "and " or "but ")
      .. (ENCOURAGEMENT[math.random(#ENCOURAGEMENT)])
    return text
end

--[[ Given the current temperature, return the appropriate
  string for the main string meter ]]
local function getMainString( code )
    local negation = dangerousWeather[code] == nil and "should" or "shouldn't"
    return string.format("You %s ride your bike", negation)
end

--[[ Given the current temperature and its unit, return the appropriate string
  for the secondary string meter ]]
local function getSubString( code, temp, unit )
    local substring = dangerousWeather[code] == nil
      and string.format("It's %s out%s", getTempWords(code, temp, unit), getEncouragement(temp, unit))
      or dangerousWeather[code] .. ", so be careful"
    return substring
end

--[[ Sets the Text value of the specified meter with a SetOption bang ]]
local function setStringMeterText( meterName, text )
    SKIN:Bang('!SetOption', meterName, 'Text', text)
end

--[[ Log the descriptor which is returned for various temperatures ]]
local function test()
    for i = -20, 100, 5 do
        printf("t=%d, s=%s", i, getTempWords(19, i))
    end
    for k, v in pairs(allWeatherCodes) do
      printf("%s: %s / %s", v, getMainString(k), getSubString( k, 40, 'f'))
    end
end

--[[ GLOBAL SKIN FUNCTIONS ===================================================]]

--[[ Run on Refresh (or on update if DynamicVariables is set on the script measure)
  Retrieves user specified values from variables and handles to measures and meters ]]
function Initialize()
    -- read settings
    WARM_LIMIT = tonumber(SKIN:GetVariable("comfortable_warm", 70))
    COOL_LIMIT = tonumber(SKIN:GetVariable("comfortable_cool", 50))
    UNIT = string.lower(SKIN:GetVariable("unit", "f"))
    -- measure handles
    tempStrMsr = SKIN:GetMeasure("mChillTemp")
    tempUnitMsr = SKIN:GetMeasure("mTempUnit")
    tempCodeMsr = SKIN:GetMeasure("mCode")
    -- meter handles
    mainMeter = SKIN:GetMeter("mainString")
    subMeter = SKIN:GetMeter("subString")
    -- run tests
    -- test()
end

--[[ Run on Update - We need to update two different string meters on every tick,
  So we use a bang for both and do not return a value. ]]
function Update()
    -- get current temp and conditions
    local temp = tonumber(tempStrMsr:GetStringValue())
    local code = tonumber(tempCodeMsr:GetStringValue())
    -- WebParser will not have returned values for the first few update ticks
    if temp ~= nil then
        setStringMeterText(mainMeter:GetName(), getMainString(code))
        setStringMeterText(subMeter:GetName(), getSubString(code, temp, UNIT))
    end
end
