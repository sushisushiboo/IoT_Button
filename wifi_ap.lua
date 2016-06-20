-- wifi_ap
local wifiAp = {}
local wifi_ap_cfg ={}
wifi_ap_cfg.ssid = "IoT_Button"
wifi_ap_cfg.pwd = "iotbutton"

function wifiAp.Start(callback)
    print("wifi ap start"..wifi_ap_cfg)
    wifi.setmode(wifi.SOFTAP)
    tmr.alarm(0, 1000, 0, function()
        wifi.ap.config(wifi_ap_cfg)
    end)
end

return wifiAp

