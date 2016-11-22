function Initialize()
  MeasureDuration = SKIN:GetMeasure('mDuration')
  MeasurePosition = SKIN:GetMeasure('mPosition')
  MeasureState    = SKIN:GetMeasure('mStateButton')
  ResetInterval   = SELF:GetNumberOption('ResetInterval', 2)
  ClockThisTick   = os.clock()
end

function Update()
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
  end

  return math.min(InterpolatedPosition / Duration, 1)
end

--based on original Progress.lua by Kaelri (Kaelri@gmail.com), modified by Monochromatope