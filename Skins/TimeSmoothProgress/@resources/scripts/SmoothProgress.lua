-- @author Malody Hoe / GitHub: madhoe / Twitter: maddhoexD

function Initialize()
  StartTime = SKIN:ParseFormula(SKIN:GetVariable("StartTime"))
  Duration = SKIN:ParseFormula(SKIN:GetVariable("Duration"))
  mTime = SKIN:GetMeasure('mTime')
  
  InterpolatedTime = 0
  LastDuration = 0
  ClockThisTick = os.clock()
  ClockLastTick = ClockThisTick
  ResetInterval = SELF:GetNumberOption('ResetInterval', 2) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset

end

function Update()
  local ActualTime = (mTime:GetValue() % 86400) -- 24 hours
  
  ClockLastTick = ClockThisTick
  ClockThisTick = os.clock()
  
  if math.abs(InterpolatedTime - ActualTime) > ResetInterval then
    -- time is off by a lot; reset
    InterpolatedTime = ActualTime
  end 
  
  InterpolatedTime = InterpolatedTime + (ClockThisTick - ClockLastTick)
  returnVal = math.min((InterpolatedTime - StartTime) / Duration, 1)
  -- make it move really fast for debug
  -- returnVal = math.min((returnVal * 500) % 1, 0.999)
  return returnVal
  
end

--based on http://nomnuggetnom.deviantart.com/art/Muziko-for-Rainmeter-314928622
--by Kaelri (Kaelri@gmail.com, http://kaelri.deviantart.com/)
