lide.log = {}

setmetatable(lide.log, { __call = function ( self, text, ... )
	if self.printlog then
		io.stdout:write(text:format(...) .. '\n');
	else -- to txt...
	end
end})

return lide.log 