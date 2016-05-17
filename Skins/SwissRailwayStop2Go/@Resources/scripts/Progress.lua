function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
end

function Update()
-- smooth out the system clock on the minute
  CurrentClock = os.clock() -- os.clock() has millisecond resolution but may not be stable for long
  CurrentMinute = math.floor((os.time()+1)/60) -- os.time() has 1-second resolution but is stable; sync up at 59 seconds past the minute to make minute jumps tight
  if (not TimeOffset or (LastMinute ~= CurrentMinute)) then
    TimeOffset = MeasureTime:GetValue() - CurrentClock
    LastMinute = CurrentMinute
  end
  SmoothTime = CurrentClock + TimeOffset
  return SmoothTime
end
