function Initialize()
  MeasureTime = SKIN:GetMeasure('MeasureTime')
end

function Update()
  if not TimeOffset then
    TimeOffset = MeasureTime:GetValue() - os.clock()
  end
  local TimeValue = os.clock() + TimeOffset
  local OffBy = TimeValue-MeasureTime:GetValue()
  SKIN:Bang('!SetVariable', 'DebugOffset', OffBy)
  if math.abs(OffBy) >= 1 then
    SKIN:Bang('!SetOption', 'MeterClockBackground', 'LineColor', '255,0,0,255')
    SKIN:Bang('!UpdateMeter', 'MeterClockBackground')
  end
  
  return TimeValue
end
