-- a simple telnet server 

function startServer()
    print("start simple telnet server at port 2323") 
    s=net.createServer(net.TCP)
    s:listen(2323, function(c)
        print("connected")
        con_std = c
        function s_output(str)
            if(con_std~=nil) then 
                con_std:send(str)
            end
        end
        node.output(s_output, 0) -- re-direct output to function s_ouput.
        c:on("receive", function(c,l)
            node.input(l) -- works like pcall(loadstring(l)) but support multiple separate line
        end)
        c:on("disconnection", function(c)
            print("disconnected")
            con_std = nil
            node.output(nil) -- un-regist the redirect output function, output goes to serial
        end)
    end)
end

tmr.alarm(0, 1000, 1, function()
    if wifi.sta.status() == 5 then
        tmr.stop(0)
        startServer()
    else
        print("WIFI connecting ...")
    end
end)