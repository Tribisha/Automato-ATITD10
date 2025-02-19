dofile("ui_utils.inc");
dofile("settings.inc");
dofile("constants.inc");
dofile("screen_reader_common.inc");
dofile("common.inc");
dofile("serialize.inc");

----------------------------------------
--          Global Variables          --
----------------------------------------
imgTake = "Take.png";
imgEverything = "Everything.png";
imgToMake = "toMake.png";
imgToRepair = "toRepair.png"
brickNames = { "Bricks", "Clay Bricks", "Firebricks" };
brickImages = { "makeBricks.png", "makeClayBricks.png", "makeFirebricks.png" };
typeOfBrick = 1;
brickHotkeys = { "b", "c", "f" };
gridWidth = 9;
gridHeight = 9;

maxRGBDiff = 1000;
maxHueDiff = 1000;
brickOffset = {};
brickOffset[0] = 35 / 125;
brickOffset[1] = 30 / 122;
delay = 60;
timeout = 45 * 1000;

black = 0x000000ff;

arrangeWindows = true;
unpinWindows = true;
local isContinueMaking = true;
----------------------------------------

function doit()
  local macroStartTime = lsGetTimer();
  promptParameters();
  askForWindow("Make sure your chats are minimized and brick rack menus"
  .. " are pinned then hover ATITD window and press Shift to continue.");
  if pinnedMode then
    if(arrangeWindows) then
      arrangeInGrid(false, false, 350, 110, nil, 10, 20);
    end
      while(isContinueMaking) do
        checkBreak();
        if not repairRack() then
          break;
        end
        if not makeBricks() then
          break;
        end
      lsSleep(75);
      end
    elseif hotkeyMode then
      arrangeWindows = false;
      brickHotkeyMode();
    end
  lsPlaySound("Complete.wav")
  lsMessageBox("Elapsed Time:", getElapsedTime(macroStartTime), 1)
end

function promptParameters()
  scale = 1.1;
  local z = 0;
  local is_done = nil;
  while not is_done do
    checkBreak();
    local y = 40;
    lsSetCamera(0,0,lsScreenX*scale,lsScreenY*scale);

    lsPrintWrapped(10, y-35, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
      "Bricks V2.0 - Rewrite by Rhaom for T9\n\n");

    typeOfBrick = readSetting("typeOfBrick",typeOfBrick);
    lsPrint(10, y-5, z, scale, scale, 0xFFFFFFff, "Type of Brick:");
    typeOfBrick = lsDropdown("typeOfBrick", 155, 35, 0, 150, typeOfBrick, brickNames);
    writeSetting("typeOfBrick",typeOfBrick);
    y = y + 32;

    lsPrintWrapped(10, y+5, z+10, lsScreenX - 20, 0.7, 0.7, 0xffff40ff,
      "Global Settings\n-------------------------------------------");

    if pinnedMode then
      arrangeWindows = readSetting("arrangeWindows",arrangeWindows);
      arrangeWindows = CheckBox(10, y+30, z, 0xFFFFFFff, " Arrange windows (Grid format)", arrangeWindows, 0.65, 0.65);
      writeSetting("arrangeWindows",arrangeWindows);

      unpinWindows = readSetting("unpinWindows",unpinWindows);
      unpinWindows = CheckBox(10, y+50, z, 0xFFFFFFff, " Unpin windows on exit", unpinWindows, 0.65, 0.65);
      writeSetting("unpinWindows",unpinWindows);
      y = y + 62;
    else
      unpinWindows = readSetting("unpinWindows",unpinWindows);
      unpinWindows = CheckBox(10, y+30, z, 0xFFFFFFff, " Unpin windows on exit", unpinWindows, 0.65, 0.65);
      writeSetting("unpinWindows",unpinWindows);
      y = y + 42;
    end

    lsPrintWrapped(10, y+15, z+10, lsScreenX - 20, 0.7, 0.7, 0xffff40ff,
    "Mode Settings\n---------------------------------------");

    if pinnedMode then
      pinnedModeColor = 0x80ff80ff;
    else
      pinnedModeColor = 0xffffffff;
    end
    if hotkeyMode then
      hotkeyModeColor = 0x80ff80ff;
    else
      hotkeyModeColor = 0xffffffff;
    end

    pinnedMode = readSetting("pinnedMode",pinnedMode);
    hotkeyMode = readSetting("hotkeyMode",hotkeyMode);

    if not hotkeyMode then
      pinnedMode = CheckBox(10, y+50, z, pinnedModeColor, " Pinned Window Mode", pinnedMode, 0.65, 0.65);
      writeSetting("pinnedMode",pinnedMode);
		  y = y + 22;
		else
		  pinnedMode = false
		end

    if not pinnedMode then
      hotkeyMode = CheckBox(10, y+50, z, hotkeyModeColor, " Hotkey Mode", hotkeyMode, 0.65, 0.65);
      writeSetting("hotkeyMode",hotkeyMode);
		  y = y + 22;
		else
		  hotkeyMode = false
    end

    y = y + 50
    if pinnedMode then
      helpText = "Uncheck Pinned Mode to switch to Hotkey Mode"
    elseif hotkeyMode then
      helpText = "Uncheck Hotkey Mode to switch to Pinned Mode"
    else
      helpText = "Check Hotkey or Pinned Mode to Begin"
    end

    lsPrint(10, y+3, z, 0.65, 0.65, 0xFFFFFFff, helpText);


    if hotkeyMode then
      lsPrint(10, y+30, z, 0.8, 0.8, 0xFFFFFFff, "Grid width:");
      gridWidth = readSetting("gridWidth",gridWidth);
      is_done, gridWidth = lsEditBox("gridWidth", 110, y+28, z, 50, 30, scale, scale,
                                  0x000000ff, gridWidth);
      if not tonumber(gridWidth) then
        is_done = nil;
        lsPrint(165, y+35, z+10, 0.68, 0.68, 0xFF2020ff, "MUST BE A NUMBER");
        gridWidth = 1;
      end
      gridWidth = tonumber(gridWidth);
      writeSetting("gridWidth",gridWidth);
      y = y + 32;

      lsPrint(10, y+30, z, 0.8, 0.8, 0xFFFFFFff, "Grid height:");
      gridHeight = readSetting("gridHeight",gridHeight);
      is_done, gridHeight = lsEditBox("gridHeight", 110, y+28, z, 50, 30, scale, scale,
                                  0x000000ff, gridHeight);
      if not tonumber(gridHeight) then
        is_done = nil;
        lsPrint(165, y+30, z+10, 0.68, 0.68, 0xFF2020ff, "MUST BE A NUMBER");
        gridHeight = 1;
      end
      gridHeight = tonumber(gridHeight);
      writeSetting("gridHeight",gridHeight);
      y = y + 32;
    end

    lsPrintWrapped(10, y+30, z+10, lsScreenX - 20, 0.7, 0.7, 0xD0D0D0ff,
	  "Stand where you can reach all brick racks with all ingredients on you.");

	if pinnedMode or hotkeyMode then
		if lsButtonText(10, lsScreenY - 30, z, 100, 0x00ff00ff, "Begin") then
				is_done = 1;
			end
	end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFF0000ff,
      "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(tick_delay);
  end
end

function repairRack()
  local result = true;
  srReadScreen();
  repair = findAllImages("repair.png");
  for i=1,#repair do
    clickText(repair[i]);
    lsSleep(75);
    srReadScreen();
      if(srFindImage("bricks/" .. imgToRepair,5000)) then
        result = false;
        cleanup();
        lsSleep(100);
        closePopUp();
      end
    lsSleep(50);
  end
  return result;
end

function makeBricks()
  local result = true;
  -- Click pin ups to refresh the window
  clickAllImages("ThisIs.png");
  statusScreen("Making bricks");
  srReadScreen();
  local ThisIsList;
  ThisIsList  = findAllImages("ThisIs.png");
    for i=1,#ThisIsList do
      local x = ThisIsList[i][0]-75;
      local y = ThisIsList[i][1];
      local width = 350;
      local height = 110;
        local p = srFindImageInRange("bricks/" .. brickImages[typeOfBrick], x, y, width, height);
        if(p) then
          safeClick(p[0]+4,p[1]+4);
          lsSleep(75);
          srReadScreen();
            if(srFindImage("bricks/" .. imgToMake,5000)) then
              cleanup();
              result = false;
              lsSleep(100);
              closePopUp();
            end
        else
          p = srFindImageInRange("bricks/" .. imgTake, x, y, width, height, 5000);
          if(p) then
            safeClick(p[0]+4,p[1]+4);
            lsSleep(75);
            srReadScreen();
            p = srFindImage("bricks/" .. imgEverything, 5000);
            if(p) then
              safeClick(p[0]+4,p[1]+4);
              lsSleep(75);
              srReadScreen();
            end
          end
        end
    end
	  return result;
end

function brickHotkeyMode()
  local nw;
	local size;
	local se;
	local done = false;
  while(not done) do
    srReadScreen();
    nw = promptForRack("northwestern");
    size = getRackSize(nw);
    srSetMousePos(nw[0],nw[1]);
      if(promptOkay("Press ok if the mouse is at the northwestern corner of the northwestern brick rack.")) then
        srSetMousePos(nw[0]+size[0],nw[1]+size[1]);
        done = promptOkay("Press ok if the mouse is at the southeastern corner of the northwestern brick rack.");
      end
  end
	done = false;
    while(not done) do
      se = promptForRack("southeastern");
      srSetMousePos(se[0],se[1]);
      done = promptOkay("Press ok if the mouse is at the northwestern corner of the southeastern brick rack.");
    end
	local distanceApart = {};
	distanceApart[0] = (se[0] - nw[0]) / (gridWidth-1);
	distanceApart[1] = (se[1] - nw[1]) / (gridHeight-1);
	brickOffset[0] = brickOffset[0] * size[0];
	brickOffset[1] = brickOffset[1] * size[1];
	local racks = {};
    for x=1,gridWidth do
      racks[x] = {};
      for y=1,gridHeight do
        checkBreak();
        racks[x][y] = {};
        racks[x][y].x = nw[0]+(distanceApart[0] * (x-1)) + brickOffset[0];
        racks[x][y].y = nw[1]+(distanceApart[1] * (y-1)) + brickOffset[1];
        racks[x][y].color = 0;
        racks[x][y].lastTime = 0;
      end
      end
	x = 1;
	y = 1;
	local dx = 1;
	srReadScreen();
	startTime = lsGetTimer();
	local needDelay;
    while(true) do
      checkBreak();
      elapsed = lsGetTimer() - startTime;
      hours = math.floor(elapsed/60/60/1000);
      elapsed = elapsed - hours*60*60*1000;
      minutes = math.floor(elapsed/60/1000);
      elapsed = elapsed - minutes*60*1000;
      seconds = math.floor(elapsed/1000);
      statusScreen(string.format("Elapsed: %02d:%02d:%02d",hours,minutes,seconds));
        if(racks[x][y].color == black) then
          racks[x][y].color = brightestOf9(racks[x][y].x,racks[x][y].y,5);
        end
      needDelay = false;
        if(brickRackReady(racks,x,y) or racks[x][y].lastTime < lsGetTimer() - timeout) then
          srSetMousePos(racks[x][y].x,racks[x][y].y);
          lsSleep(150);
          srKeyEvent("r") -- Repair brick moulds
          closePopUp();
          lsSleep(150);
          srKeyEvent("t"..brickHotkeys[typeOfBrick]);
          lsSleep(150);
          needDelay = true;
          racks[x][y].color = black;
          racks[x][y].lastTime = lsGetTimer();
        end
      x = x + dx;
        if(x < 1 or x > gridWidth) then
          srReadScreen();
            if(srFindImage("bricks/" .. imgToMake,5000)) then
              cleanup();
              lsSleep(100);
              closePopUp();
              break;
            end
            if(y == gridHeight) then
              x = 1;
              dx = 1;
              y = 1;
            else
              y = y + 1;
              dx = dx * -1;
              x = x + dx;
            end
          else
            if(needDelay) then
              lsSleep(delay);
            end
          end
        end
end

function brickRackReady(racks,x,y)
	local c = brightestOf9(racks[x][y].x,racks[x][y].y,5);
	local theSame = 0;
	local different = 0;
	local half = (gridWidth * gridHeight / 2);
	for i=1,gridWidth do
		for j=1,gridHeight do
			if(racks[i][j].color ~= black) then
				if(compareColor(racks[i][j].color,c) > 45) then
					different = different + 1;
					if(different > half) then
						return true;
					end
				else
					theSame = theSame + 1;
					if(theSame > half) then
						return false;
					end
				end
			end
		end
	end
	return (different > theSame);
end

function brightestOf9(x, y, size)
	local max = black;
	local delta = math.floor(size/2);
    for i=x-delta,x+delta do
      for j=y-delta,y+delta do
        max = brightestOf2(max,srReadPixelFromBuffer(i,j));
      end
    end
	return max;
end

function brightestOf2(left,right)
	local leftRGB = parseColor(left);
	local rightRGB = parseColor(right);
	local leftTotal = 0;
	local rightTotal = 0;
    for i=0,2 do
      leftTotal = leftTotal + leftRGB[0];
      rightTotal = rightTotal + rightRGB[0];
    end
	if(leftTotal > rightTotal) then
		return left;
	end
	return right;
end

function getRackSize(position)
	local x = position[0]+1;
	local y = position[1]+1;
	local lastX = x;
	local lastY = y;
	srSetMousePos(x,y);
	srKeyEvent("t");
	lsSleep(150);
	srReadScreen();
	local c = srReadPixelFromBuffer(x,y);
	local misses = 0;
	while(misses < 3) do
		checkBreak();
		x = x + 1;
		if(compareColorEx(c,srReadPixelFromBuffer(x,y),maxRGBDiff,maxHueDiff)) then
			misses = 0;
			lastX = x;
		else
			misses = misses + 1;
		end
		srSetMousePos(x,y);
		lsSleep(10);
	end
	x = lastX;
	srSetMousePos(x,y);
	misses = 0;
	x = (position[0] + lastX) / 2;
	y = position[1] + 2;
	while(misses < 3) do
		checkBreak();
		y = y + 1;
		if(compareColorEx(c,srReadPixelFromBuffer(x,y),maxRGBDiff,maxHueDiff)) then
			misses = 0;
			lastY = y;
		else
			misses = misses + 1;
		end
		srSetMousePos(x,y);
		lsSleep(10);
	end
	x = position[0] + 2;
	y = (position[1] + lastY) / 2;
	while(misses < 3) do
		checkBreak();
		x = x + 1;
		if(compareColorEx(c,srReadPixelFromBuffer(x,y),maxRGBDiff,maxHueDiff)) then
			misses = 0;
			lastX = x;
		else
			misses = misses + 1;
		end
		srSetMousePos(x,y);
		lsSleep(10);
	end
	x = lastX;
	y = lastY;
	srSetMousePos(x,y);
	return makePoint(x-position[0],y-position[1]);
end

function getRackPos(start)
	local x = start[0];
	local y = start[1];
	local origX = x;
	local lastX = x;
	local lastY = y;
	local c = srReadPixelFromBuffer(x,y);
	local misses = 0;
	while(misses < 3) do
		checkBreak();
		x = x - 1;
		if(compareColorEx(c,srReadPixelFromBuffer(x,y),maxRGBDiff,maxHueDiff)) then
			misses = 0;
			lastX = x;
		else
            lsPrintln(maxRGBDiff..","..maxHueDiff);
			misses = misses + 1;
		end
		srSetMousePos(x,y);
		lsSleep(10);
	end
	x = lastX;
	srSetMousePos(x,y);
	misses = 0;
	lastX = x;
	x = origX;
	while(misses < 3) do
		checkBreak();
		y = y - 1;
		if(compareColorEx(c,srReadPixelFromBuffer(x,y),maxRGBDiff,maxHueDiff)) then
			misses = 0;
			lastY = y;
		else
			misses = misses + 1;
		end
		srSetMousePos(x,y);
		lsSleep(10);
	end
	y = lastY;
	x = lastX;
	srSetMousePos(x,y);
	return makePoint(x,y);
end

function promptForRack(position)
	statusScreen("Put your mouse over the " .. position .. " brick rack and tap the Ctrl button.");
	waitForKeypress(true);
	local pos = makePoint(srMousePos());
	statusScreen("Release the Ctrl button.");
	waitForKeyrelease();
	lsSleep(150);
	srKeyEvent("t");
	statusScreen("");
	lsSleep(150);
	srReadScreen();
	return getRackPos(pos);
end

function cleanup()
  if(unpinWindows) then
    closeAllWindows();
  end
end

function closePopUp()
  while 1 do
    srReadScreen()
    local ok = srFindImage("OK.png")
	    if ok then
	      statusScreen("Found and Closing Popups ...", nil, 0.7);
	      srClickMouseNoMove(ok[0]+5,ok[1]);
	      lsSleep(100);
	    else
	      break;
	    end
  end
end
