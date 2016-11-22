function Initialize()
  mDuration = SKIN:GetMeasure('MeasureDuration')
  mPosition = SKIN:GetMeasure('MeasurePosition')
  mState    = SKIN:GetMeasure('MeasureStateButton')
  
  InterpolatedPosition = 0
  LastDuration = 0
  ClockThisTick = os.clock()
  ClockLastTick = ClockThisTick
  ResetInterval = SELF:GetNumberOption('ResetInterval', 2) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset
end

function Update()
  -- the pattern "and X or Y" is a ternary operator (http://lua-users.org/wiki/ExpressionsTutorial)
  
  local Stopped = mState:GetValue() == 0 and 1 or 0
  
  if Stopped == 1 or Duration == 0 then -- stopped or no track
    return 0
  end

  local Duration = mDuration:GetValue()
  local ActualPosition = mPosition:GetValue()
  
  if LastDuration ~= Duration or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval then
    -- track change or skip
    LastDuration = Duration
    InterpolatedPosition = ActualPosition
  end 
  
  local State = mState:GetValue() == 1 and 1 or 0

  if State == 1 then -- playing; recalculate
    ClockLastTick = ClockThisTick
    ClockThisTick = os.clock()
    
    if ClockLastTick ~= 0 then
      InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
    end
  else
    ClockThisTick = 0
  end

  return math.min(InterpolatedPosition / Duration, 0.9999)
end

--based on http://nomnuggetnom.deviantart.com/art/Muziko-for-Rainmeter-314928622
--by Kaelri (Kaelri@gmail.com, http://kaelri.deviantart.com/)
