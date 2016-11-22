function Initialize()
  MeasureDuration = SKIN:GetMeasure('mDuration')
  MeasurePosition = SKIN:GetMeasure('mPosition')
  MeasureState    = SKIN:GetMeasure('mStateButton')
  ResetInterval   = SELF:GetNumberOption('ResetInterval', 2)
  ClockThisTick   = os.clock()
  
  ClockThisTick = os.clock()
  ClockLastTick = ClockThisTick
  ResetInterval = SELF:GetNumberOption('ResetInterval', 2)

  ActiveColorValue = 255
  InactiveColorValue = 96
  ActiveColor = ActiveColorValue .. "," .. ActiveColorValue .. "," .. ActiveColorValue
  InactiveColor = InactiveColorValue .. "," .. InactiveColorValue .. "," .. InactiveColorValue

  NumberOfSegments = SKIN:ParseFormula(SELF:GetOption('NumberOfSegments'))
  ColorField = SELF:GetOption("ColorField", "SolidColor")
  ObjectsToUpdate = {}
  local opt = SELF:GetOption("SegmentGroup")
  if opt ~= "" then -- fetch more groups
    j = 1
    while true do
      if opt == "" then break end
      table.insert(ObjectsToUpdate, opt)
      j = j + 1
      opt = SELF:GetOption("SegmentGroup" .. j)
    end
  end
  ShadeSegmentsGradually = tonumber(SELF:GetOption("ShadeSegmentsGradually", 0))
  LastMeterSet = 0

  Debug = SELF:GetOption("Debug",0)
end

function Update()
  local Duration = MeasureDuration:GetValue()
  local ActualPosition = MeasurePosition:GetValue()
 
  local PlaybackState = MeasureState:GetValue()
  
  if PlaybackState == 0 then -- playback stopped; we can stop here
    return 0
  end

  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  if LastDuration ~= Duration or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval then
    -- track change or skip
    LastDuration = Duration
    InterpolatedPosition = ActualPosition
  end 
  
  if Stopped == 1 or Duration == 0 then -- stopped or no track
    returnVal = 0
  else
    if PlaybackState == 1 then -- playing
      InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
    end
    if Debug ~= 0 then
      SKIN:Bang('!SetVariable', 'DebugOffset', math.floor((InterpolatedPosition - ActualPosition)*1000))
    end
    returnVal = math.min(InterpolatedPosition / Duration, 0.999)
  end
  if #ObjectsToUpdate > 0 then
    SetColors(returnVal)
  end
  return returnVal
  
end

function SetColors(Value) -- use InterpolatedPosition to set the right squares
  local MeterToSet = math.floor(Value * NumberOfSegments - 0.0001)
  local step = (MeterToSet >= LastMeterSet) and 1 or -1
  local color = (MeterToSet >= LastMeterSet) and ActiveColor or InactiveColor
  -- print("setting from " .. LastMeterSet .. " to " .. MeterToSet .. " to color " .. color)
  for idx, name in pairs(ObjectsToUpdate) do
    for i = LastMeterSet, MeterToSet, step do
      if i >= 0 and i < NumberOfSegments then
        SKIN:Bang('!SetOption', name .. i, ColorField, color)
        SKIN:Bang('!UpdateMeter', name .. i)
      end
    end
  end
  if ShadeSegmentsGradually > 0 then
    IndividualPercent = Value * NumberOfSegments - MeterToSet -- just the fractional part left
    IndividualColorValue = IndividualPercent * ActiveColorValue + (1 - IndividualPercent) * InactiveColorValue
    IndividualColor = IndividualColorValue .. "," .. IndividualColorValue .. "," .. IndividualColorValue
    for idx, name in pairs(ObjectsToUpdate) do
      SKIN:Bang('!SetOption', name .. MeterToSet, ColorField, IndividualColor)
      SKIN:Bang('!UpdateMeter', name .. MeterToSet)
    end
  end
  LastMeterSet = MeterToSet
end
