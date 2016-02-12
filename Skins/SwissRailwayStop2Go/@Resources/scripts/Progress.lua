function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
end

function Update()
  if not TimeOffset then
    TimeOffset = MeasureTime:GetValue() - os.clock()
  end
  local ClockThisTick = os.clock() + TimeOffset
  return ClockThisTick
end
