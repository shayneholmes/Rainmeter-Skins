function Initialize()
  MeasureDuration = SKIN:GetMeasure('mDuration')
  MeasurePosition = SKIN:GetMeasure('mPosition')
  MeasureState    = SKIN:GetMeasure('mStateButton')
  ResetInterval   = SELF:GetNumberOption('ResetInterval', 2)
  ClockThisTick   = os.clock()
  
  ActiveColorValue = 255
  InactiveColorValue = 96
  ActiveColor = ActiveColorValue .. "," .. ActiveColorValue .. "," .. ActiveColorValue
  InactiveColor = InactiveColorValue .. "," .. InactiveColorValue .. "," .. InactiveColorValue

  NumberOfSegments = SKIN:ParseFormula(SELF:GetOption('NumberOfSegments'))
  ColorField = SELF:GetOption("ColorField", "SolidColor")
  Debug = SELF:GetOption("Debug",0)
  ObjectsToUpdate = {}
  local j = 1
  local opt = SELF:GetOption("SegmentGroup")
  while opt ~= "" do
    table.insert(ObjectsToUpdate, opt)
    j = j + 1
    opt = SELF:GetOption("SegmentGroup" .. j)
  end
  ShadeSegmentsGradually = tonumber(SELF:GetOption("ShadeSegmentsGradually", 0))
  LargestMeterFilled = -1
  if #ObjectsToUpdate > 0 then
    SetColors(1)
    SetColors(0)
  end
end

function Update()
  local InterpolatedPosition = GetInterpolatedPosition()
  if #ObjectsToUpdate > 0 then
    SetColors(InterpolatedPosition)
  end
  return InterpolatedPosition
end

function GetInterpolatedPosition()
  local PlaybackState = MeasureState:GetValue()
  if PlaybackState == 0 then return 0 end -- playback stopped; we can stop here

  local Duration = MeasureDuration:GetValue()
  if Duration == 0 then return 0 end -- playback stopped; we can stop here

  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  local ActualPosition = MeasurePosition:GetValue()
  if LastDuration ~= Duration -- new track
     or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval -- skip, or our counting is off
     then -- reset our guess to the measured position
    LastDuration = Duration
    InterpolatedPosition = ActualPosition
  elseif PlaybackState == 1 then -- playing; increment
    InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
    if Debug ~= 0 then
      SKIN:Bang('!SetVariable', 'DebugOffset', math.floor((InterpolatedPosition - ActualPosition)*1000))
    end
  end
  return clamp(InterpolatedPosition / Duration, 0, 1)
end

function SetColors(Value) -- set the right objects as bright
  local MeterToShade, IndividualPercent = math.modf(Value * NumberOfSegments)
  LargestMeterToFill = MeterToShade - 1 -- last completely filled shape
  if LargestMeterFilled ~= LargestMeterToFill then
    local color, low, high
    if LargestMeterToFill > LargestMeterFilled then -- filling more shapes (most commonly, just one shape)
      color = ActiveColor
      low   = clamp(LargestMeterFilled + 1,  0, NumberOfSegments)
      high  = clamp(LargestMeterToFill,     -1, NumberOfSegments - 1)
    else -- unfilling shapes already filled
      color = InactiveColor
      low   = clamp(LargestMeterToFill + 1 + (ShadeSegmentsGradually > 0 and 1 or 0),  0, NumberOfSegments)     -- gradual shading will partially color one
      high  = clamp(LargestMeterFilled +     (ShadeSegmentsGradually > 0 and 1 or 0), -1, NumberOfSegments - 1) -- gradual shading needs erasing
    end
    for idx, name in pairs(ObjectsToUpdate) do
      for i = low, high do
        SKIN:Bang('!SetOption', name .. i, ColorField, color)
        SKIN:Bang('!UpdateMeter', name .. i)
      end
    end
    LargestMeterFilled = LargestMeterToFill
  end
  if ShadeSegmentsGradually > 0 and 0 <= MeterToShade and MeterToShade < NumberOfSegments then
    local IndividualColorValue = IndividualPercent * ActiveColorValue + (1 - IndividualPercent) * InactiveColorValue
    local IndividualColor = IndividualColorValue .. "," .. IndividualColorValue .. "," .. IndividualColorValue
    for idx, name in pairs(ObjectsToUpdate) do
      SKIN:Bang('!SetOption', name .. MeterToShade, ColorField, IndividualColor)
      SKIN:Bang('!UpdateMeter', name .. MeterToShade)
    end
  end
end

function clamp(var, low, high)
  return var < low and low or (var > high and high or var)
end
