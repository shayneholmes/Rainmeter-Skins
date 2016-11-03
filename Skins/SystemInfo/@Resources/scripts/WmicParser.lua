-- Use this script to fetch and format values from WMIC (the Windows Management Interface Console app)
-- Parameters:
---- Format: A format string. [MeasureName]s will be replaced by their values, then {Formulas} will be parsed by Rainmeter
---- WmicMeasure: Measure (probably a RunCommand) that contains the data from a WMIC run

function Initialize()
  wmicFormatString = SELF:GetOption("Format")
  maxRows = tonumber(SELF:GetOption("MaxRows", "NaN"))
  wmicMeasureName = SELF:GetOption("WmicMeasure")
  if (wmicMeasureName == "MeasureWmicMemPhysical") then
    debugVar = 1024
  end
end

function Update()
  local wmicOutput = SKIN:GetMeasure(wmicMeasureName):GetStringValue()
  local items = parseWmicTable(wmicOutput)
  if #items > 0 then
    -- replace formatString with fieldnames if present
    outputLines = {}
    if (not maxRows or maxRows == 0) then
      maxRows = #items
    else
      maxRows = math.min(#items, maxRows)
    end
    for idx = 1, maxRows do
      item = items[idx]
      formatString = wmicFormatString:gsub("%[.-%]", substituteFieldName):gsub("{.-}", parseFormula)
      table.insert(outputLines, formatString)
    end
    return table.concat(outputLines, "\n")
  end
end

function parseWmicTable(str)
  fields = nil -- global
  local items = {}

  local i = 1
  for line in string.gmatch(str, "[^\n]*\n") do
    if not string.match(line, "=") then
      if items[i] then
        i = i + 1
      end
    else
      if not items[i] then 
        items[i] = {}
      end
      for k, v in string.gmatch(line, "(%w+)=(.+)\n") do
        items[i][k] = v
      end
    end
  end

  return items
end

function formatAsSize(stringValue)
  if not stringValue then
    return 0
  end
  sizeSuffixTable = {"B", "KB", "MB", "GB", "TB"}
  local sizeIndex = 1
  local value = tonumber(stringValue)
  while (value > 1024) do
    value = value / 1024
    sizeIndex = sizeIndex + 1
  end
  formattedValue = string.format("%4.2f%s", value, sizeSuffixTable[sizeIndex])
  return formattedValue
end

function substituteFieldName(fieldReference)
  local fieldName = fieldReference:sub(2, -2)
  if string.match(fieldName, "s:") then
    return formatAsSize(item[fieldName:sub(3)])
  else
    return item[fieldName]
  end
end

function parseFormula(formula)
	return SKIN:ParseFormula("(" .. formula:sub(2, -2) .. ")")
end

function dprint(str)
  if debugVar then
    print(str)
  end
end