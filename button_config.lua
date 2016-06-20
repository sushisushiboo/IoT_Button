-- button_main.lua -- IoTボタン --

require "gpio_pins" -- ピン定義のロード

-- ピンアサイン
LED_MON = GPIO4 
-- IO4(2) : [o] 動作モニタ用LED 
gpio.mode(LED_MON, gpio.OUTPUT) 
GPO_LED_REMOTE_LATCH_CLK = GPIO5 
-- IO5(1) : [o] リモート制御LED用ラッチクロック 
LED_REMOTE = GPIO5 
gpio.mode(GPO_LED_REMOTE_LATCH_CLK, gpio.OUTPUT) 
GPI_MODE = GPIO12 
-- IO12(6): [i/o] 動作切り替え/ボタン入力ラッチクリア 
GPO_BTN_LATCH_CLR = GPIO12 
GPI_BTN_LATCH_Q = GPIO13 
-- IO13(7): [i] ボタン入力ラッチ入力 
gpio.mode(GPI_BTN_LATCH_Q, gpio.INPUT) 
I2C_SDA = GPIO2 
-- IO2: I2C_SDA(2.2Kでプルアップ) 
I2C_SCL = GPIO14 
-- IO14: I2C_SCL(2.2Kでプルアップ) 
-- IO16 : ->RSTに接続(deep sleep解除用） 
GPO_LED_REMOTE_LATCH_DATA = GPIO0 
-- IO0(3): モード切替 H:Flash Load, L:Flash Write、[o] リモート制御LED用ラッチデータ 
gpio.mode(GPO_LED_REMOTE_LATCH_DATA, gpio.OUTPUT)

timer_id = {}
timer_id[LED_REMOTE] = 0;
timer_id[LED_MON] = 1;

local function led_on_impl(_led)
	if LED_REMOTE == _led then
		gpio.write(GPO_LED_REMOTE_LATCH_DATA, gpio.HIGH)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.LOW)
		tmr.delay(100)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.HIGH)
		tmr.delay(100)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.LOW)
	else
		gpio.write(_led, gpio.HIGH)
	end
end

function led_on(_led)
	print("led ".._led.." on")
	tmr.stop(timer_id[_led])
	led_on_impl(_led)
end

local function led_off_impl(_led)
	if LED_REMOTE == _led then
		gpio.write(GPO_LED_REMOTE_LATCH_DATA, gpio.LOW)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.LOW)
		tmr.delay(100)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.HIGH)
		tmr.delay(100)
		gpio.write(GPO_LED_REMOTE_LATCH_CLK, gpio.LOW)
	else
		gpio.write(_led, gpio.LOW)
	end
end

function led_off(_led)
	print("led ".._led.." off")
	tmr.stop(timer_id[_led])
	led_off_impl(_led)
end

led_blink_state = {}
led_blink_state[LED_MON] = 0;
led_blink_state[LED_REMOTE] = 0;

function led_blink(_led, period_ms)
	print("led ".._led.." blink")
	tmr.stop(timer_id[_led])
	tmr.alarm(timer_id[_led], period_ms, 1, function()
		if 1 == led_blink_state[_led] then
			led_blink_state[_led] = 0
			led_off_impl(_led)
		else
			led_blink_state[_led] = 1
			led_on_impl(_led)
		end
	end)
end
