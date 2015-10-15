-- @author Malody Hoe / GitHub: madhoe / Twitter: maddhoexD
-- Structure of Script Measure:
---- NumberOfSegments=
---- ColorField=
---- ShadeSegmentsGradually=
---- SegmentGroupN=
---- where N is an ordered number from 0

function Initialize()
  mDuration = SKIN:GetMeasure('mDuration')
  mPosition = SKIN:GetMeasure('mPosition')
  mState = SKIN:GetMeasure('mStateButton')
  mState = SKIN:GetMeasure('mStateButton')
  
  InterpolatedPosition = 0
  LastDuration = 0
  ClockThisTick = os.clock()
  ClockLastTick = ClockThisTick
  ResetInterval = SELF:GetNumberOption('ResetInterval', 1) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset

  ActiveColorValue = 255
  InactiveColorValue = 96
  ActiveColor = ActiveColorValue .. "," .. ActiveColorValue .. "," .. ActiveColorValue
  InactiveColor = InactiveColorValue .. "," .. InactiveColorValue .. "," .. InactiveColorValue

  NumberOfSegments = SKIN:ParseFormula(SKIN:GetVariable('NumberOfSegments'))
  ObjectsToUpdate = {}
  j = 0
  while true do
    local opt = SELF:GetOption("SegmentGroup" .. j)
    if opt == "" then break end
    table.insert(ObjectsToUpdate, opt)
    j = j + 1
  end
  ColorField = SELF:GetOption("ColorField", "SolidColor")
  ShadeSegmentsGradually = tonumber(SELF:GetOption("ShadeSegmentsGradually", 0))
  LastMeterSet = 0

  DebugMeasure = SELF:GetOption("DebugMeasure","")
end

function Update()
  local Duration = mDuration:GetValue()
  local ActualPosition = mPosition:GetValue()
  local State = mState:GetValue() == 1 and 1 or 0
  local Stopped = mState:GetValue() == 0 and 1 or 0
  
  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  if LastDuration ~= Duration or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval then -- track change or skip
    LastDuration = Duration
    InterpolatedPosition = ActualPosition
  end 
  
  if Stopped == 1 or Duration == 0 then -- stopped or no track
    returnVal = 0
  else
    if State == 1 then -- playing
      InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
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

--based on http://nomnuggetnom.deviantart.com/art/Muziko-for-Rainmeter-314928622
--by Kaelri (Kaelri@gmail.com, http://kaelri.deviantart.com/)
