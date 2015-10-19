function Initialize()
  -- Get variables from external state
  TimerEndOfTimer=tonumber(SKIN:GetVariable('TimerEndOfTimer', '0'))
  ColorTimerArc=(SKIN:GetVariable('ColorTimerArc', '0,255,0,255'))
  TimerCount=tonumber(SKIN:GetVariable('TimerCount', '0'))
  ActiveTimerCount=tonumber(SKIN:GetVariable('ActiveTimerCount', '0'))
  TimeMeasure=SKIN:GetMeasure('MeasureTime')
  TimeOffset=0 -- represents the offset between os.clock() and Rainmeter time
end

function Update()
  TimerEndOfTimer=tonumber(SKIN:GetVariable('TimerEndOfTimer', '0'))
  if TimeOffset == 0 then 
    TimeOffset=TimeMeasure:GetValue() - os.clock()
  end
  CurrentTime = os.clock() + TimeOffset
  if TimerEndOfTimer == 0 then
    returnVal = -1
  elseif TimerEndOfTimer > CurrentTime then
    returnVal = TimerEndOfTimer - CurrentTime
  else
    -- timer ends now
    SKIN:Bang('!SetVariable', 'TimerEndOfTimer', 0)
    SKIN:Bang('!SetVariable', 'TimerCount', '(#TimerCount#+#ActiveTimerCount#)')
    SKIN:Bang('!WriteKeyValue', 'Variables', 'TimerCount', '(#TimerCount#+#ActiveTimerCount#)', '#@#state.inc')
    SKIN:Bang('!SetVariable', 'ActiveTimerCount ', '0')
    SKIN:Bang('!WriteKeyValue', 'Variables', 'ActiveTimerCount', '0', '#@#state.inc')
    SKIN:Bang('!CommandMeasure', 'MeasureAhkWindowMessaging', 'SendMessage 16687 1 0')
    SKIN:Bang('!EnableMeasure', 'flashCounter')
    returnVal = -1
  end
  return returnVal
end

function ChangeVar()
  MyVariable = 'Changed'
end