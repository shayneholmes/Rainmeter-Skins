function Initialize()
  DebugMessage=SKIN:GetVariable('Debug', '')
  LeftCircle=SKIN:GetMeter('LeftCircle')
  RightCircle=SKIN:GetMeter('RightCircle')
  Message=SKIN:GetMeter('Message')
end

function Update()
end

function AlignCircles()
  SKIN:Bang('!UpdateMeter', 'Message') -- accurately determine height
  CircleRadius = Message:GetH()/2
  if CircleRadius > 50 then
    SKIN:Bang('!SetOption', 'Message', 'Padding', "10,10,10,10")
    CircleRadius = 0
  else
    SKIN:Bang('!SetOption', 'Message', 'Padding', "0,10,0,10")
  end

  SKIN:Bang('!UpdateMeter', 'Message') -- include new padding in measurements
    
  X = Message:GetX()
  Y = Message:GetY()
  W = Message:GetW()
  H = Message:GetH()
  LeftCircle:SetX(X)
  LeftCircle:SetY(Y+H/2)
  RightCircle:SetX(X+W-CircleRadius)
  RightCircle:SetY(Y+H/2)
  RightCircle:SetW(CircleRadius*2)
  
  SKIN:Bang('!SetOption', 'LeftCircle', 'LineLength', CircleRadius)
  SKIN:Bang('!SetOption', 'RightCircle', 'LineLength', CircleRadius)
  
  X = tonumber(SKIN:GetVariable('PSCREENAREAX',0)) + tonumber(SKIN:GetVariable('PSCREENAREAWIDTH',0)) - W - CircleRadius*2 - 100
  Y = tonumber(SKIN:GetVariable('PSCREENAREAY',0)) + tonumber(SKIN:GetVariable('PSCREENAREAHEIGHT',0)) - H - 100
  
  SKIN:Bang('!Redraw') -- update boundaries
  SKIN:Bang('!Move', X, Y) -- move skin
end

function SetVariable(variablename, value)
  SKIN:Bang('!SetVariable', variablename, value)
end
