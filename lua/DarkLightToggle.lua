local jobId

local function shallowCopyPartOfTable(sourceTable, destTable, keys)
	for k, v in pairs(sourceTable) do
		if table.concat(keys, " "):find("%f[%a]" .. k .. "%f[%A]") then
			destTable[k] = v
		end
	end
end

local function setColorschemeBasedOnHour(dayColorscheme, nightColorscheme, dayColorschemeTimeRange, _isCallBack)
	if type(dayColorscheme) ~= "string" or type(nightColorscheme) ~= "string" then
		error("dayColorscheme and nightColorscheme need to be a string", 2)
	end
	if type(dayColorschemeTimeRange) ~= "table" then
		error("dayColorschemeTimeRange is required as a table", 2)
	end
	if type(dayColorschemeTimeRange["start"]) ~= "table" or type(dayColorschemeTimeRange["end"]) ~= "table" then
		error("dayColorschemeTimeRange [start] and [end] are required as table", 2)
	end
	if not tonumber(dayColorschemeTimeRange["start"]["hour"])
		or (dayColorschemeTimeRange["start"]["min"] and not tonumber(dayColorschemeTimeRange["start"]["min"]))
		or (dayColorschemeTimeRange["start"]["sec"] and not tonumber(dayColorschemeTimeRange["start"]["sec"]))
	then
		error("dayColorschemeTimeRange[start] [hour] is required as number. [min] and [sec] are optional as number", 2)
	end
	if not tonumber(dayColorschemeTimeRange["end"]["hour"])
		or (dayColorschemeTimeRange["end"]["min"] and not tonumber(dayColorschemeTimeRange["end"]["min"]))
		or (dayColorschemeTimeRange["end"]["sec"] and not tonumber(dayColorschemeTimeRange["end"]["sec"]))
	then
		error("dayColorschemeTimeRange[end] [hour] is required as number. [min] and [sec] are optional as number", 2)
	end
	dayColorschemeTimeRange["start"]["min"] = dayColorschemeTimeRange["start"]["min"] or "00"
	dayColorschemeTimeRange["start"]["sec"] = dayColorschemeTimeRange["start"]["sec"] or "00"
	dayColorschemeTimeRange["end"]["min"] = dayColorschemeTimeRange["end"]["min"] or "00"
	dayColorschemeTimeRange["end"]["sec"] = dayColorschemeTimeRange["end"]["sec"] or "00"
	local tmp = os.date("*t")
	shallowCopyPartOfTable(dayColorschemeTimeRange["start"], tmp, { "hour", "min", "sec" })
	local startTime = os.time(tmp)
	shallowCopyPartOfTable(dayColorschemeTimeRange["end"], tmp, { "hour", "min", "sec" })
	local endTime = os.time(tmp)
	if (startTime >= endTime) then
		 endTime = endTime + (24 * 60 * 60)
	end
	local colorscheme
	local alternateColorscheme
	local currTime = os.time()
	if (currTime >= startTime and currTime < endTime) then
		colorscheme = dayColorscheme
		alternateColorscheme = nightColorscheme
	else
		colorscheme = nightColorscheme
		alternateColorscheme = dayColorscheme
	end
	if not pcall(function () vim.cmd("colorscheme " .. colorscheme) end) then
		print("setting colorscheme to " .. colorscheme .. " failed, trying to set colorscheme to " .. alternateColorscheme)
		if not pcall(function () vim.cmd("colorscheme " .. alternateColorscheme) end) then
			print("setting colorscheme to " .. alternateColorscheme .. " failed")
			return 2
		end
		print("setting colorscheme to " .. alternateColorscheme .. " succedeed but " .. colorscheme .. " colorscheme is not valid, you should check that")
		return 1
	end
	local function callBack(_, exitCode)
		if exitCode ~= 0 then
			return
		end
		setColorschemeBasedOnHour(dayColorscheme, nightColorscheme, dayColorschemeTimeRange, true)
	end
	if not _isCallBack and jobId then
		vim.fn.jobstop(jobId)
	end
	if colorscheme == dayColorscheme then
		jobId = vim.fn.jobstart("sleep " .. endTime - currTime, { on_exit = callBack })
	elseif colorscheme == nightColorscheme and currTime >= endTime then
		jobId = vim.fn.jobstart("sleep " .. (startTime + 24 * 60 * 60) - currTime, { on_exit = callBack })
	elseif colorscheme == nightColorscheme and currTime < startTime then
		jobId = vim.fn.jobstart("sleep " .. startTime - currTime, { on_exit = callBack })
	end
	return 0
end

return { setup = setColorschemeBasedOnHour }
