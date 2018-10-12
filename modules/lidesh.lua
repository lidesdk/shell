repeat
   io.stdout:write "> "
   local cmd_str = io.stdin:read()

   if cmd_str ~= "exit" then
      if cmd_str:sub(1,1) == "=" then
         loadstring("print("..cmd_str:sub(2,#cmd_str)..")")()
      else
         local code = loadstring(cmd_str)
         if not code then
	    print '[lide] Syntax error'
	 else
	    code()
	 end
      end
   end
until cmd_str == 'exit'
