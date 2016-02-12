function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
  -- make time run fast for first 58 seconds, then sit for two seconds
  HowOftenToWait = 60 -- top of the minute
  HowLongToWait = 2 -- delay each time
  GainRatio = (HowOftenToWait + HowLongToWait) / HowOftenToWait - 1
end

function Update()
  if not TimeOffset then
    TimeOffset = MeasureTime:GetValue() - os.clock()
  end
  local TimeValue = os.clock() + TimeOffset
  TimeValue = TimeValue + math.min((TimeValue % HowOftenToWait) * GainRatio,HowOftenToWait-(TimeValue % HowOftenToWait))
  return TimeValue
end
