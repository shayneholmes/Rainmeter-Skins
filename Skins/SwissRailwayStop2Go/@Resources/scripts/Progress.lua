function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
  CheckTimePollingInterval = 5 -- in seconds
  ResyncTime = true -- for first run
end

function Update()
  local CurrentClock = os.clock()
  if ResyncTime then
    TimeOffset = MeasureTime:GetValue() - CurrentClock
    ResyncTime = false
  end
  local SmoothTime = CurrentClock + TimeOffset
  if (not LastCheck) or (SmoothTime > LastCheck + CheckTimePollingInterval) then
    if (math.abs(SmoothTime - MeasureTime:GetValue()) > 1) then
      ResyncTime = true
    end
    LastCheck = SmoothTime
  end
  return SmoothTime
end
