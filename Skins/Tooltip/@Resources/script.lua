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
  
  if (SKIN:GetVariable('Alignment',"") == "Screen") then
    X = tonumber(SKIN:GetVariable('PWORKAREAX',0)) + tonumber(SKIN:GetVariable('PWORKAREAWIDTH',0)) - W - CircleRadius*2 - 50
    Y = tonumber(SKIN:GetVariable('PWORKAREAY',0)) + tonumber(SKIN:GetVariable('PWORKAREAHEIGHT',0)) - H - 20
  else
    X = tonumber(SKIN:GetVariable('AlignmentX',0)) - W/2
    Y = tonumber(SKIN:GetVariable('AlignmentY',0)) - H/2
  end
  
  SKIN:Bang('!Redraw') -- update boundaries
  SKIN:Bang('!Move', X, Y) -- move skin
end

function SetVariable(variablename, value)
  SKIN:Bang('!SetVariable', variablename, value)
end
