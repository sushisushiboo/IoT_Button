-- ifttt.lua
require "ifttt_key"

-- IFTTTに通知する
function sendNoticeToIFTTT(value1, value2, value3, callback)
	local conn = net.createConnection(net.TCP, 0)

	-- 受信時
	conn:on("receive", function(conn, payload)
		--tmr.stop(0) -- タイムアウトタイマー停止
		print(payload) 
		conn:close()
		if callback then
			callback()
		end
	end) 

	-- 接続したらHTTPリクエスト送信
	conn:on("connection", function(c) 
		print("connected")
		local data = {}
		data[0] = "GET /trigger/test/with/key/IFTTT_KEY?value1="..value1.."&value2="..value2.."&value3="..value3.." HTTP/1.1\r\n"
		data[1] = "Host: maker.ifttt.com\r\n"
		data[2] = "Accept: */*\r\n" 
		data[3] = "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.)\r\n"
		data[4] = "Connection: closed\r\n"
		data[5] = "\r\n"
		conn:send(data[0]..data[1]..data[2]..data[3]..data[4]..data[5])
	end)

	-- 切断
	conn:on("disconnection", function()
		print("disconnected")
	end)

	-- 送信完了
	conn:on("sent", function(c)
		print("sent")
	end)

	conn:connect(80,"maker.ifttt.com") 

end
