function Update()
  -- smooth out the system clock
  CurrentTime = os.time()
  CurrentClock = os.clock()
  if CurrentTime ~= LastTime then -- tick
    LastTime = CurrentTime
    TimeOffset = LastTime - CurrentClock
  end
  return CurrentClock + TimeOffset
end