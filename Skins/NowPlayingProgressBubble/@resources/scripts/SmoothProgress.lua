function Initialize()
  MeasureDuration = SKIN:GetMeasure('MeasureDuration')
  MeasurePosition = SKIN:GetMeasure('MeasurePosition')
  MeasureState    = SKIN:GetMeasure('MeasureStateButton')
  ResetInterval = SELF:GetNumberOption('ResetInterval', 2) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset
  ClockThisTick = os.clock()
  InterpolatedPosition = 0
end

function Update()
  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  PlaybackState = MeasureState:GetValue()

  if PlaybackState == 0 then -- playback stopped; we can stop here
    return 0
  end
  
  if Duration == nil then
    GetTrackDuration()
  end

  local ActualPosition = MeasurePosition:GetValue()
  
  if math.abs(InterpolatedPosition - ActualPosition) > ResetInterval -- skip, or our counting is off
     then -- reset our guess to the measured position
    InterpolatedPosition = ActualPosition
  end 
  
  if PlaybackState == 1 then -- playing; increment
    InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
  end

  return math.min(InterpolatedPosition / Duration, 0.9999)
end

function GetTrackDuration()
  Duration = MeasureDuration:GetValue()
end