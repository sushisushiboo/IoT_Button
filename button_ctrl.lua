-- button_ctrl.lua

-- (1) ボタン入力ラッチ読み取り
-- H: ボタン押下動作
-- ・ボタン押下をiFTTTに通知
-- L: なにもしない
-- (2) ボタン入力ラッチクリア

require "ifttt"

function clearButtonLatch()
	gpio.mode( GPO_BTN_LATCH_CLR, gpio.OUTPUT )
	gpio.write( GPO_BTN_LATCH_CLR, gpio.LOW )
	tmr.delay( 100 )
	gpio.write( GPO_BTN_LATCH_CLR, gpio.HIGH )
	tmr.delay( 100 )
end

function buttonCtrl(callback)
	-- (1) ボタン入力ラッチ読み取り
	if gpio.HIGH == gpio .read( GPI_BTN_LATCH_Q ) then
		print( "button pushed! and restarted" )
		-- ・ボタン押下をiFTTTに通知
		sendNoticeToIFTTT("button", "", "", function()
			-- (2) ボタン入力ラッチクリア
			print( "button pushed latch clear" )
			clearButtonLatch()
			if callback then
				callback()
			end
		end)
	else
		print( "restarted!" )
		if callback then
			callback()
		end
	end

end
