-- @author Malody Hoe / GitHub: madhoe / Twitter: maddhoexD
-- Structure of Script Measure:
---- CellLayers=
---- SegmentGroup=
---- SegmentGroupN=
---- where N is an ordered number from 2

function Initialize()
  -- mDuration = SKIN:GetMeasure('mDuration')
  -- mPosition = SKIN:GetMeasure('mPosition')
  -- mState = SKIN:GetMeasure('mStateButton')
  -- mState = SKIN:GetMeasure('mStateButton')
  
  -- InterpolatedPosition = 0
  -- LastDuration = 0
  -- ClockThisTick = os.clock()
  -- ClockLastTick = ClockThisTick
  -- ResetInterval = SELF:GetNumberOption('ResetInterval', 2) -- if the difference (in seconds) between intepolated and actual is higher than this, it will instantly reset

  ActiveColorValue = 255
  InactiveColorValue = 96
  ActiveColor = 0 .. "," .. ActiveColorValue .. "," .. 0
  InactiveColor = InactiveColorValue .. "," .. InactiveColorValue .. "," .. InactiveColorValue

  DecayAmount=0.9
  DecayCutoff=32
  
  TransmuteProbability=0.05
  
  NewLetterProbability=0.05
  
  ValidCharacters = "0123456789ABCDEF"
  NumberOfValidCharacters = string.len(ValidCharacters)
  
  CellLayers = SKIN:ParseFormula(SELF:GetOption('CellLayers'))
  CellCols = SKIN:ParseFormula(SELF:GetOption('CellCols'))
  CellRows = SKIN:ParseFormula(SELF:GetOption('CellRows'))

  LayerStrings = {}

  s = EmptyLayerString()
  for i = 0, CellLayers-1 do
    LayerStrings[i] = s
  end

  ActiveLayer = 0
  
  ColorField = SELF:GetOption("ColorField", "SolidColor")
  ObjectsToUpdate = {}
  local opt = SELF:GetOption("SegmentGroup")
  if opt ~= "" then -- fetch more groups
    j = 1
    while true do
      if opt == "" then break end
      table.insert(ObjectsToUpdate, opt)
      j = j + 1
      opt = SELF:GetOption("SegmentGroup" .. j)
    end
  end
  -- ShadeSegmentsGradually = tonumber(SELF:GetOption("ShadeSegmentsGradually", 0))
  -- LastMeterSet = 0

  -- Debug = SELF:GetOption("Debug",0)
end

function Update()
  -- local Duration = mDuration:GetValue()
  -- local ActualPosition = mPosition:GetValue()
  -- local State = mState:GetValue() == 1 and 1 or 0
  -- local Stopped = mState:GetValue() == 0 and 1 or 0
  
  -- ClockLastTick = ClockThisTick
  -- ClockThisTick = os.clock()
  
  -- if LastDuration ~= Duration or math.abs(InterpolatedPosition - ActualPosition) > ResetInterval then
    -- -- track change or skip
    -- LastDuration = Duration
    -- InterpolatedPosition = ActualPosition
  -- end 
  
  -- if Stopped == 1 or Duration == 0 then -- stopped or no track
    -- returnVal = 0
  -- else
    -- if State == 1 then -- playing
      -- InterpolatedPosition = InterpolatedPosition + (ClockThisTick - ClockLastTick)
    -- end
    -- if Debug ~= 0 then
      -- SKIN:Bang('!SetVariable', 'DebugOffset', math.floor((InterpolatedPosition - ActualPosition)*1000))
    -- end
    -- returnVal = math.min(InterpolatedPosition / Duration, 0.999)
  -- end
  -- if #ObjectsToUpdate > 0 then
    -- SetColors(returnVal)
  -- end
  -- return returnVal
  AdvanceLayers()

  ActiveLayer = ((ActiveLayer + 1) % CellLayers)
end

function AdvanceLayers()
  for idx, name in pairs(ObjectsToUpdate) do
    for i = 0, CellLayers-1, 1 do
      if (ActiveLayer == i) then -- bright layer
        LayerStrings[i] = TransmuteLayerString(AdvanceLayer(LayerStrings[(i - 1) % CellLayers]))
        -- LayerStrings[ActiveLayer] = TransmuteLayerString(AdvanceLayer(LayerStrings[(ActiveLayer - 1 % CellLayers)]))
        for x = 0, CellCols-1, 1 do
          if (math.random() <= NewLetterProbability) then
            LayerStrings[i] = SetCharacterAtPosition(LayerStrings[i], GetRandomCharacter(), math.floor(math.random()*CellCols), 0)
          end
        end
      end
      SKIN:Bang('!SetOption', name .. i, ColorField, ActiveColor .. "," .. 255 * 0.85 ^ ((ActiveLayer - i) % CellLayers))
      SKIN:Bang('!SetOption', name .. i, "Text", LayerStrings[i])
      SKIN:Bang('!UpdateMeter', name .. i)
    end
  end  
end

function GetRandomCharacter()
  index = math.ceil(math.random() * NumberOfValidCharacters)
  return string.sub(ValidCharacters, index, index)
end

function EmptyLayerString()
  return string.rep(string.rep(" ", CellCols) .. "\n", CellRows)
end

function SetCharacterAtPosition(str, chr, x, y)
  pos = y*(CellCols+1)+x+1
  return string.sub(str, 1, pos-1) .. chr .. string.sub(str, pos+1, -1)
end

function AdvanceLayer(str)
  return string.rep(" ", CellCols) .. "\n" .. string.sub(str, 1, (CellRows-1)*(CellCols+1))
end

function TransmuteLayerString(str)
  return string.gsub(str, "[^ \n]", GetRandomCharacter)
end

function GetCharacterAtPosition(str, chr, x, y)
  pos = y*(CellCols+1)+x+1
  return string.sub(str, 1, pos-1) .. chr .. string.sub(str, pos+1, -1)
end

--based on http://nomnuggetnom.deviantart.com/art/Muziko-for-Rainmeter-314928622
--by Kaelri (Kaelri@gmail.com, http://kaelri.deviantart.com/)
  