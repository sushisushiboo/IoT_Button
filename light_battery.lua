-- devucehubからsubscribeしてLEDを制御
-- バッテリー電圧をdevicehubにpublish
-- バッテリー電圧が閾値以下ならiftttに通知

--light_battery.lua

devicehub = require "devicehub"

function lightAndBattery()

	local battery_voltage = adc.read(0) * 3
	print( "battery voltage : "..battery_voltage.."[mV]" )

	-- devucehubからsubscribeしてLEDを制御
	-- バッテリー電圧をdevicehubにpublish
	devicehub.getAndSend(
		-- getValueCallback
		function(value)
			print("devicehub light:"..value)
			local sleeptime = 0
			if 1 == value or "1" == value then
				print("リモート制御LED:ON")
				led_on(LED_REMOTE)
				sleeptime = 30
			else
				print("リモート制御LED:OFF")
				led_off(LED_REMOTE)
				sleeptime = 60
			end
			print("sleep "..sleeptime.." sec")
			tmr.delay(100*1000)
			node.dsleep(sleeptime*1000*1000)
		end,
		-- publicValue
		battery_voltage,
		-- timeoutCallback
		function()
			print("subscribe timeout")
			print("sleep 10 sec")
			tmr.delay(100*1000)
			node.dsleep(10*1000*1000)
		end
	)
	
	-- バッテリー電圧が閾値以下ならiftttに通知
	require "ifttt"

	local th = 1800
	if 1800 > battery_voltage then
		print("batter voltage below "..th.."[mV]")
		sendNoticeToIFTTT( "battery low", battery_voltage, "" ) 
	end

end -- end of function
