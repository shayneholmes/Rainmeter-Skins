function Initialize()
  MeasureDuration = SKIN:GetMeasure('MeasureDuration')
  MeasurePosition = SKIN:GetMeasure('MeasurePosition')
  MeasureState    = SKIN:GetMeasure('MeasureStateButton')
  ResetInterval   = SELF:GetNumberOption('ResetInterval', 2) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset
  ClockThisTick   = os.clock()
end

function Update()
  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  PlaybackState = MeasureState:GetValue()

  if PlaybackState == 0 then -- playback stopped; we can stop here
    return 0
  end

  local Duration = MeasureDuration:GetValue()
  local ActualPosition = MeasurePosition:GetValue()
  
  if LastDuration ~= Duration -- new track
     or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval -- skip, or our counting is off
     then -- reset our guess to the measured position
    LastDuration = Duration
    InterpolatedPosition = ActualPosition
  end 
  
  if PlaybackState == 1 then -- playing; increment
    InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
  end

  return math.min(InterpolatedPosition / Duration, 1)
end
