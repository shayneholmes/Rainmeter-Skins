function Initialize()
  filename=SELF:GetOption("FilePath")
  playcount=0
end

function Update()
  return playcount
end

function Refresh()
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
	File:close()

	return Contents
end