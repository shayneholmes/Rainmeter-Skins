function Initialize()
  -- Get variables from external state
  TimerEndOfTimer=tonumber(SKIN:GetVariable('TimerEndOfTimer', '0'))
  ColorTimerArc=(SKIN:GetVariable('ColorTimerArc', '0,255,0,255'))
  TimerCount=tonumber(SKIN:GetVariable('TimerCount', '0'))
  ActiveTimerCount=tonumber(SKIN:GetVariable('ActiveTimerCount', '0'))
  FlashTimeoutSeconds=tonumber(SKIN:GetVariable('FlashTimeoutSeconds', '30'))
  TimeMeasure=SKIN:GetMeasure('MeasureTime')
  TimeOffset=0 -- represents the offset between os.clock() and Rainmeter time
  AlarmAtEnd=0 -- if turned on, alarm plays at end
  EndOfTimerHash=1
  Flashing=0
end

function Update()
  TimerEndOfTimer=tonumber(SKIN:GetVariable('TimerEndOfTimer', '0'))
  if TimerEndOfTimer == nil then 
    TimerEndOfTimer = 0
  end
  if TimeOffset == 0 then 
    TimeOffset=TimeMeasure:GetValue() - os.clock()
  end
  CurrentTime = os.clock() + TimeOffset
  if TimerEndOfTimer == 0 then
    returnVal = -1
    if Flashing > 0 and Flashing <= CurrentTime then
      Flashing = 0
      SKIN:Bang('!SetVariable', 'Flashing', Flashing)
    end
  elseif TimerEndOfTimer > CurrentTime then
    returnVal = TimerEndOfTimer - CurrentTime
  else
    -- timer ends now
    SetVariable('TimerEndOfTimer', 0)
    SetVariable('TimerCount', '(#TimerCount#+#ActiveTimerCount#)')
    SetVariable('ActiveTimerCount ', '0')
    SKIN:Bang('!CommandMeasure', 'MeasureAhkWindowMessaging', 'SendMessage 16687 1 0')
    if AlarmAtEnd == 1 then
      SKIN:Bang('!execute [Play Alarm.Wav]') 
      Flashing = FlashTimeoutSeconds + TimeMeasure:GetValue()
      SKIN:Bang('!SetVariable', 'Flashing', Flashing)
    end
    returnVal = -1
  end
  return returnVal
end

function StartTimerAPI(duration, color, active)
  StartTimerHelper(duration, color, active)
  AlarmAtEnd = 0
end

function StartTimer(duration, color, active)
  StartTimerHelper(duration, color, active)
  AlarmAtEnd = 1
  SKIN:Bang('!CommandMeasure', 'MeasureAhkWindowMessaging', 'SendMessage 16687 0 #TimerDuration#')
end

function StartTimerHelper(duration, color, active)
  duration = tonumber(duration or 0)
  active = active or 0
  Flashing = 0
  SKIN:Bang('!SetVariable', 'Flashing', Flashing)
  SetVariable('ColorTimerArc', color)
  if duration <= 0 then 
    endoftimer = 0
  else
    endoftimer = duration * 60 + TimeMeasure:GetValue()
  end
  SetVariable('TimerEndOfTimer', endoftimer)
  -- riffing on https://www.cs.hmc.edu/~geoff/classes/hmc.cs070.200101/homework10/hashfuncs.html
  EndOfTimerHash = ((1+EndOfTimerHash)*TimeMeasure:GetValue()*0.5*(math.sqrt(5)-1)) % 1
  SetVariable('EndOfTimerHash', EndOfTimerHash)
  SetVariable('ActiveTimerCount', active)
  SKIN:Bang('!UpdateMeasure', 'MeasureTimerScript')
  SKIN:Bang('!Update')
end

function SetVariable(variablename, value)
  if value == nil then
    value = '#' .. variablename .. '#'
  else
    SKIN:Bang('!SetVariable', variablename, value)
  end
  SKIN:Bang('!WriteKeyValue', 'Variables', variablename, value, '#@#state.inc')
end