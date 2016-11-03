-- Structure of Script Measure:
---- IncFile= the file to generate (@include this in the .ini file)
---- Metrics= a something-delimited list of system info variables
---- ShowAllMetrics= 1 to show all available metrics, 0 to use the Metrics field

function Initialize()
  meterTemplate = [===[
[KeyValueLabel%%]
MeterStyle=TextStyle|LabelTextStyle|ShowHide
Meter=String
Text=VALUE NAME
Group=Meter|Label|ShowHide

[KeyValueValue%%]
MeterStyle=TextStyle|ValueTextStyle|ShowHide
Meter=String
MeasureName=MeasureVALUENAME
Group=Meter|Value|ShowHide
]===]

  measureTemplates = {}
  dependencyTemplates = {}
  dependencies = {}
  dependenciesNeedingActivation = {}
  populateSystemInfoMeasures()
  
  local outputMeasures = {}
  local outputMeters = {}
  
  local metricsToDisplay = {}
	local valuesParameterString = SELF:GetOption("Metrics")
  for value in string.gmatch(valuesParameterString, "%a+") do
    table.insert(metricsToDisplay,value)
  end
  
  local displayAllMeasures = tonumber(SELF:GetOption("ShowAllMetrics","0"))>0
  if displayAllMeasures then
    metricsToDisplay = {}
    for k,v in pairs(measureTemplates) do
      table.insert(metricsToDisplay,k)
    end
    table.sort(metricsToDisplay)
  end
  
  -- compute if there are dependencies that need filling
  deps = {}
  for key, value in pairs(metricsToDisplay) do
    if (dependencies[value]) then
      table.insert(deps, dependencies[value])
    end
  end
  
  deps = dedup(deps)
	
  for key, value in pairs(deps) do
    outputMeasures[value] = dependencyTemplates[value]
    table.insert(dependenciesNeedingActivation, value)
  end

  local i = 1
  for key, value in pairs(metricsToDisplay) do
    if (measureTemplates[value]) then
      outputMeasures[value] = measureTemplates[value]
    end
    table.insert(outputMeters, "" .. doSub(meterTemplate, i, value))
    if (not measureTemplates[value]) then
      table.insert(outputMeters, "Text=<Unknown value name>")
    end
    i = i + 1
  end
 
  outputText = ""
  for key, value in pairs(outputMeasures) do
    outputText = outputText .. value .. "\n"
  end

  for key, value in pairs(outputMeters) do
    outputText = outputText .. value .. "\n"
  end
  
  local file = io.open(SKIN:MakePathAbsolute(SELF:GetOption("IncFile")), "w")
	file:write(outputText)
	file:close()
end

function Update()
  -- Only runs once since we have UpdateDivider set to -1
  -- Run the WMIC commands (if any)
  if not hasRun then
    hasRun = 1
    s = ""
    for k, v in pairs(dependenciesNeedingActivation) do
      s = s .. "[!CommandMeasure Measure" .. v .. [=[ "Run"]]=]
    end
    SKIN:Bang(s)
  end
end

-- does all the substitution!
function doSub(str, i, value)
  local formattedValue = value:gsub("(%a)(%u)(%l)", "%1 %2%3"):gsub("(%l)(%u)", "%1 %2")
	return str:gsub("%%%%", i):gsub("VALUENAME", value):gsub("VALUE NAME", formattedValue)
end

-- read available system info measures from the include file
function populateSystemInfoMeasures()
  populateSystemInfoMeasuresFromFile()
  populateRegistryMeasures()
  populateSysInfoMeasures()
  populateWmicMeasures()
end

function populateSystemInfoMeasuresFromFile()
  local oldValue = nil
  local currentMeasureLines = {}
  for line in io.lines(SKIN:MakePathAbsolute(SELF:GetOption("MeasuresIncFile"))) do 
    newValue = string.match(line, "^%[Measure(.-)%]")
    if newValue then
      if (oldValue) then
        measureTemplates[oldValue] = table.concat(currentMeasureLines, "\n")
        currentMeasureLines = {}
      end
      oldValue = newValue
    end
    table.insert(currentMeasureLines, line)
  end
  if (oldValue) then
    measureTemplates[oldValue] = table.concat(currentMeasureLines, "\n")
  end
end

function populateRegistryMeasures()
  local measureTemplate = [===[
[Measure%1]
Measure=Registry
RegHKey=%2
RegKey=%3
RegValue=%4
UpdateDivider=-1
Substitute="":"-"
]===]

  at(measureTemplate, "WindowsEdition", "HKEY_LOCAL_MACHINE", [[Software\Microsoft\Windows NT\CurrentVersion]], "EditionID")
  at(measureTemplate, "WindowsBuild", "HKEY_LOCAL_MACHINE", [[Software\Microsoft\Windows NT\CurrentVersion]], "BuildLab")
end

function populateSysInfoMeasures()
  local measureTemplate = [===[
[Measure%1]
Measure=Plugin
Plugin=SysInfo
SysInfoType=%2
UpdateDivider=-1
Substitute="":"-"
]===]

  at(measureTemplate, "ComputerName", "COMPUTER_NAME")
  at(measureTemplate, "UserName", "USER_NAME")
  at(measureTemplate, "OSVersion", "OS_VERSION")
  at(measureTemplate, "OSBits", "OS_BITS")
  at(measureTemplate, "PageSize", "PAGESIZE")
  at(measureTemplate, "IdleTime", "IDLE_TIME")
  at(measureTemplate, "HostName", "HOST_NAME")
  at(measureTemplate, "DomainName", "DOMAIN_NAME")
  at(measureTemplate, "DNSServer", "DNS_SERVER")
  at(measureTemplate, "SubnetMask", "NET_MASK")
  at(measureTemplate, "IPAddress", "IP_ADDRESS")
  at(measureTemplate, "DefaultGateway", "GATEWAY_ADDRESS")
  at(measureTemplate, "LanConnectivity", "LAN_CONNECTIVITY")
  at(measureTemplate, "InternetConnectivity", "INTERNET_CONNECTIVITY")
end

function populateWmicMeasures()
  local wmicTemplate = [===[
[Measure%1]
Measure=Plugin
Plugin=RunCommand
OutputType=ANSI
Parameter=%2
FinishAction=[!UpdateMeasureGroup Measure%1][!UpdateMeterGroup Meter]
Group=MeasureWmic
]===]
  local measureTemplate = [===[
[Measure%1]
Measure=Script
ScriptFile=#SCRIPT#WmicParser.lua
WmicMeasure=Measure%2
Group=Measure%2
UpdateDivider=-1
Format=%3
Group=Measure%2
MaxRows=%4
Substitute="":"-"
]===]
  
  wht(wmicTemplate, "WmicCPU", [[""wmic cpu list brief /format:list""]])

  wt(measureTemplate, "CPU", "WmicCPU", "[Name]")
  
  wht(wmicTemplate, "WmicLogicalDisk", [[""wmic logicaldisk where "FileSystem>0" get DeviceID, FileSystem, FreeSpace, Size /format:list""]])
  
  wt(measureTemplate, "FreeSpace",          "WmicLogicalDisk", "[DeviceID]%\\ [s:FreeSpace] [FileSystem]")
  wt(measureTemplate, "Volumes",            "WmicLogicalDisk", "[DeviceID]%\\ [s:Size] [FileSystem]")
  wt(measureTemplate, "VolumeUtilization",  "WmicLogicalDisk", "[DeviceID]%\\ {100-round([FreeSpace]/[Size]*10000)/100}%% [FileSystem]")
  wt(measureTemplate, "VolumeSpaceDetails", "WmicLogicalDisk", "[DeviceID]%\\ [s:Size] ({round([FreeSpace]/[Size]*1000)/10}%%) [FileSystem]")
  
  wht(wmicTemplate, "WmicNic", [[""wmic nic where "MACAddress>0" list brief /format:list""]])

  wt(measureTemplate, "MACAddress",   "WmicNic", "[MACAddress]", 1)
  wt(measureTemplate, "Network Card", "WmicNic", "[Name]", 1)

  wht(wmicTemplate, "WmicNicSpeed", [[""wmic nic where "Speed>0" list brief /format:list""]])

  wt(measureTemplate, "Network Speed", "WmicNicSpeed", "[s:Speed]/s", 1)
end

-- wht - wmic host template
function wht(...)
  template, name = ...
  template = st(...)
  dependencyTemplates[name] = template
end

-- wt - wmic template
function wt(...)
  template, name, wmicMeasure, fmt, maxRows = ...
  dependencies[name] = wmicMeasure
  if not maxRows then
    maxRows = 0
  end
  at(template, name, wmicMeasure, fmt, maxRows)
end

-- at - add template
function at(...)
  template, name = ...
  template = st(...)
  measureTemplates[name] = template
end

-- st - substitute template
function st(template, ...)
  local n = 1
  for key, var in pairs({...}) do
    template = template:gsub("%%" .. n, var)
    n = n + 1
  end
  return template
end

-- dedup - deduplicate a table
-- (sorts as a side effect)
function dedup(t)
  table.sort(t)
  local last = nil
  local i = 1
  while i < #t do
    while last == t[i] do
      table.remove(t, i)
    end
    last = t[i]
    i = i + 1
  end
  return t
end

