-- devicehub.netへのmqttでのapi

require "devicehub_config"

local devicehub = {}


-- subscribeとpublishを行う
function devicehub.getAndSend( finishCallback, sendValue, timeoutCallback, getDisable, sendDisable)

  finished = false

  light = "0"

  m = mqtt:Client(CLIENT_ID, 120, "", "")

  m:on("message" , function(conn,topic,data) 
	if data ~= nil then 
		tmr.stop(3)
		print(data)
		local pack = cjson.decode(data)
		tmr.delay(1*1000*1000)
		light = pack.state
		if finished and finishCallback then
			finishCallback(light)
		end
		finished = true
	end
  end)

  m:on("offline", function()
	print("offline")
  end)

  function connected()
	if getDisable then
		tmr.stop(3)
		print("get diabled")
		if sendDisabled then
			print("send diabled")
			if finishCallback then
				finishCallback(light)
			end
		else
			finished = true
			publish(sendValue)
		end
	else
		subscribe()
	end
  end

  function subscribe()
	m:subscribe("/a/"..API_KEY.."/p/"..PROJECT_ID.."/d/"..DEVICE_ID.."/actuator/"..ACTUATOR.."/state", 
		2, 
		function() 
			print("subscribed")
			if sendDisabled then
				print("send diabled")
				finished = true
			else
				publish(sendValue)
			end
		end
	) 
  end

  function publish(value)
	local sensor_data = {}
	sensor_data["value"] = value
	data = cjson.encode(sensor_data)
	m:publish("/a/"..API_KEY.."/p/"..PROJECT_ID.."/d/"..DEVICE_ID.."/sensor/"..SENSOR.."/data", data, 
		2, 0, 
		function()
			print("published:"..data) 
			if finished and finishCallback then
				finishCallback(light)
			end
			finished = true
		end
	) 
  end

  m:connect(SERVER_URL, SERVER_PORT,0, connected)

  if timeoutCallback then
	tmr.alarm(3, 10*1000, 0, function() -- 10秒
		-- タイマー発火
		m:close()
		print("mqtt timeout")
		timeoutCallback()
	end)
  end

end -- end of function

return devicehub



