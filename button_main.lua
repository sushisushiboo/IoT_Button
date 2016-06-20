-- button_main.lua -- IoTボタン --

--file.rename("init.lua", "button_main.lua") -- 無限ループにならない保険

require "button_config" -- ピン定義のロード
wifiSta = require "wifi_sta"
--wifiAp = require "wifi_ap"
require "button_ctrl"

print("button_main.lua")

print("1. リモート制御用LED消灯、動作モニタ用LED点灯")

led_on(LED_MON)

print("2. 動作切り替え入力チェック")
gpio.mode(GPI_MODE, gpio.INPUT)
if gpio.HIGH == gpio.read(GPI_MODE) then
    print("通常モード")
    --   H: 
    print("(1) WiFi接続[wifi_sta.lua]")
    led_blink(LED_MON, 50)
    wifiSta.Connect(function(result)
        if result then
            -- OK:次に進む
	    led_on(LED_MON)
    	    print("wifi connected")
            print("(2) ボタン制御プログラムロード[button_ctrl.lua]")
            buttonCtrl()
	    -- (3) バッテリー監視動作 
	        -- ・バッテリー電圧をpublich(devicehub.com) 
        	-- ・バッテリー電圧低下時はiFTTTに通知 
	    -- (4) リモート制御用LED状態をsubscribe(devicehub.com)
        	-- ON : 30秒後に再起動 
        	-- OFF: 1分後に再起動
	    require "light_battery"
	    lightAndBattery()
        else
            -- NG:1分後に再起動
            print("sleep for 1min");
            tmr.delay(100*1000);
            node.dsleep(60*1000*1000)
        end
    end)
else
    print("デバッグモード")
    --   L: 
    print("(1) 動作モニター用LED点滅")
    led_blink(LED_MON, 500)
    led_off(LED_REMOTE)
    print("(2) wifi接続[wifi_sta.lua]")
    wifiSta.Connect(function(result)
        if result then
    	    print("wifi connected")
    	    print(wifi.sta.getip())
           print("OK: telnetサーバー起動[telnet.lua]")
           dofile("telnet.lua")
        else
	    led_blink(LED_MON, 50)
            --print("NG: wifi AP起動[wifi_ap.lua]")
            --wifiAp.Start( function()
            --    print("リモート制御用LED点滅")
            --    led_blink("LED_REMOTE")
            --    print("telnetサーバー起動[telnet.lua]")
            --    dofile("telnet.lua")
            --    print("動作切り替えチェック入力立下りエッジでwifi STAに切り替え")
            --    gpio.mode(GPI_MODE, gpio.INT)
            --    gpio.trig(GPI_MODE, "down", function() 
            --        print("モード切替入力立下りエッジ検出")
            --        -- STAならばなにもしない
            --        if wifi.STATION == wifi.getmode() then
            --            -- do nothing
            --        else
            --            wifiSta.Connect(function(result)
            --                if result then 
            --                    print("wifi ap connected") 
            --                    print( wifi.sta.getip() )
            --                end
            --            end)
            --        end
            --    end)
            --end)
        end
    end)
end

-- exit
