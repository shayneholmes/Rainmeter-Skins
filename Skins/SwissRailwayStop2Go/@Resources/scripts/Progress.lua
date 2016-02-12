function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
end

function Update()
-- smooth out the system clock on the minute
  CurrentClock = os.clock()
  if not TimeOffset then
    TimeOffset = MeasureTime:GetValue() - CurrentClock
  end
  if not alreadyRun then
    alreadyRun = true
    TimeOffset = TimeOffset + 1
  end
  SmoothTime = CurrentClock + TimeOffset
  SKIN:Bang("!SetVariable", "debugOffset", MeasureTime:GetValue() - SmoothTime)
  if SmoothTime % 60 >= 59 then -- top of the minute; resync
    TimeOffset = false
  end
  return SmoothTime
end
