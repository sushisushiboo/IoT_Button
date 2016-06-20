-- wifi_sta

WIFI_STA_SSID = "your_ssid"
WIFI_STA_PSK = "your_psk"
dofile("wifi_sta_config.lua")
print("ssid:"..WIFI_STA_SSID)
print("psk:"..WIFI_STA_PSK)

local wifiSta = {}

local timer_id_wifi = 2

function wifiSta.Connect(callback)
	wifi.setmode(wifi.STATION)
	wifi.sta.config(WIFI_STA_SSID, WIFI_STA_PSK)
	wifi.sta.connect()

	-- 20秒間リトライする
	count = 0
	function checkConnection(callback)
    		if 5 == wifi.sta.status() then 
			-- STATION_GOT_IP
			tmr.stop(timer_id_wifi)
        		print(wifi.sta.getip())
			if callback then
				callback(true)
			end
    		end
		count = count + 1
		if 20 <= count then
			tmr.stop(timer_id_wifi)
			if callback then
				callback(false)
			end
		else
	   		print( "connectting to wifi AP ..."..count )
		end
	end

	tmr.alarm(timer_id_wifi, 1000, 1, function()
		checkConnection(callback)
	end)
end

return wifiSta
