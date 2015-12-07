function Initialize()
  filename=SELF:GetOption("FilePath")
  playcount=0
  updatesPerRefresh=60 -- try twice, wait this number of updates
  updatesLeft=-1
end

function Update()
  if updatesLeft >= 0 then
    if updatesLeft == 0 then
      RefreshPlayCount()
    end
    updatesLeft = updatesLeft - 1
  end
  return playcount
end

function Refresh()
  RefreshPlayCount()
  updatesLeft = updatesPerRefresh
end

function RefreshPlayCount()
  playcount=tonumber(string.match(ReadFile(filename),'%d+'))
end

-- from http://docs.rainmeter.net/snippets/read-write-file/
function ReadFile(FilePath)
	-- HANDLE RELATIVE PATH OPTIONS.
	FilePath = SKIN:MakePathAbsolute(FilePath)

	-- OPEN FILE.
	local File = io.open(FilePath)

	-- HANDLE ERROR OPENING FILE.
	if not File then
    return "0"
	end

	-- READ FILE CONTENTS AND CLOSE.
	local Contents = File:read('*all')
  print("Got file: " .. Contents)
	File:close()

	return Contents
end