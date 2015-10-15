-- @author Malody Hoe / GitHub: madhoe / Twitter: maddhoexD
-- Structure of Script Measure:
---- NumberOfSegments=
---- ColorField=
---- ShadeSegmentsGradually=
---- SegmentGroupN=
---- where N is an ordered number from 0

-- Implements a PID controller (https://en.wikipedia.org/wiki/PID_controller)

function Initialize()
  mDuration = SKIN:GetMeasure('mDuration')
  mPosition = SKIN:GetMeasure('mPosition')
  mState = SKIN:GetMeasure('mStateButton')
  mState = SKIN:GetMeasure('mStateButton')
  
  InterpolatedPosition = 0
  LastDuration = 0
  LastPosition = 0
  ClockCounter = 0
  ClockScalarNextPeriod = 1 -- Starting point
  ClockThisTick = os.clock()
  ClockLastTick = ClockThisTick
  ClockLastPeriod = ClockThisTick
  ResetInterval = SELF:GetNumberOption('ResetInterval', 5) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset
  -- for robustness checking
  DebugID = os.clock()
  DebugClockScalar = 1.0 -- for testing robustness of PID controller
  -- variables for PID controller
  Kp = 0.00
  Ki = 0.00
  Kd = 0.00
  -- internal state of PID controller
  ErrorPLast = 0
  ErrorP = 0
  ErrorD = 0
  ErrorI = 0
  ActiveColorValue = 255
  InactiveColorValue = 96
  ActiveColor = ActiveColorValue .. "," .. ActiveColorValue .. "," .. ActiveColorValue
  InactiveColor = InactiveColorValue .. "," .. InactiveColorValue .. "," .. InactiveColorValue
  StartCountdown = 1 -- ticks to throw out on startup; the first one is always slow
  FirstAlignment = 1 -- on refresh, this always starts off something like a second off

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
  local Total = mDuration:GetValue()
  local ActualPosition = mPosition:GetValue()
  local State = mState:GetValue() == 1 and 1 or 0
  local Stopped = mState:GetValue() == 0 and 1 or 0
  
  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  if LastDuration ~= Total or (ActualPosition - LastPosition) > 2 or (ActualPosition - LastPosition) < 0 or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval then -- track change or skip
    -- print("track realignment due to skip, track change, or being paused for a while.")
    LastPosition = ActualPosition
    InterpolatedPosition = ActualPosition
    LastDuration = Total
    ClockLastPeriod = ClockThisTick
  end 
  
  if StartCountdown > 0 then
    StartCountdown = StartCountdown - 1
    returnVal = InterpolatedPosition / Total
  elseif Stopped == 1 or Total == 0 then -- stopped or no track
    returnVal = 0
  elseif State == 1 then -- playing
    if math.abs(ActualPosition - LastPosition) >= 1 then -- new tick; align with clock and adjust PID values
      if FirstAlignment == 1 then
        FirstAlignment = 0
        InterpolatedPosition = ActualPosition
      end
      ErrorP = InterpolatedPosition - ActualPosition
      ErrorI = ErrorI + ErrorP
      ErrorD = ErrorP - ErrorPLast
      ErrorPLast = ErrorP
      ClockScalarNextPeriod = 1 - (ErrorP * Kp + ErrorI * Ki + ErrorD * Kd)
      if DebugMeasure ~= "" then
        SKIN:Bang('!SetVariable', 'DebugOffset', math.floor(ErrorP * 1000))
        SKIN:Bang('!SetVariable', 'DebugMultiple', ClockScalarNextPeriod)
        SKIN:Bang('!SetVariable', 'DebugErrorP', ErrorP)
        SKIN:Bang('!SetVariable', 'DebugErrorI', ErrorI)
        SKIN:Bang('!SetVariable', 'DebugErrorD', ErrorD)
      end
      -- debug for PID analysis
      print("Smooth," .. 
        DebugID .. "," ..
        ClockThisTick .. "," ..
        DebugClockScalar .. "," .. 
        Kp .. "," .. 
        Ki .. "," .. 
        Kd .. "," .. 
        ErrorP .. "," .. 
        ErrorI .. "," .. 
        ErrorD .. "," .. 
        ClockScalarNextPeriod
        )
      -- print("Ahead by " .. math.floor((InterpolatedPosition - ActualPosition) * 1000) .. " ms")
      -- print("Clock since last: " .. os.clock() - ClockLastPeriod)
      -- print("Special scalar: " .. ClockScalarNextPeriod)

      LastPosition = ActualPosition
      ClockLastPeriod = ClockThisTick
    end
    InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick) * ClockScalarNextPeriod * DebugClockScalar
    returnVal = math.min(InterpolatedPosition / Total, 0.999)
  else -- paused, reset clock
    -- print("Paused. Resetting clock.")
    LastPosition = ActualPosition
    -- InterpolatedPosition = ActualPosition
    LastDuration = Total
    ClockLastPeriod = ClockThisTick
    ClockScalarNextPeriod = 1
    returnVal = math.min(InterpolatedPosition / Total, 0.999)
  end
  -- print("tick: " .. (os.clock() - ClockLastTick) )
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
