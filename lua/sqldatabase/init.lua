	if  not lide.luasql then
		luasql = require 'luasql.sqlite3'
	end
	
	local env = luasql.sqlite3()

	local sqldatabase = class 'sqldatabase'

	function sqldatabase:sqldatabase( database, driver )
		private {
			database = database,
			driver   = driver,
		}
	end

	function sqldatabase.exec( query )
		
	end

	local function select( dbConnection, tbName, rowNames, sCond )
		local query, con, res = "select %s from %s %s", env:connect(dbConnection), {}
		
		--print(query:format(rowNames, tbName, sCond or ""))

		local cur = assert(
			con:execute(
			query:format(rowNames, tbName, sCond or "")
		))
		
		local row = cur:fetch ({}, "a")
		while row do
			local this = #res+1
			res[this] = {}
			for rowname, rowvalue in pairs(row) do
				res[this][rowname] = rowvalue
			end
			row = cur:fetch ({}, "a")
		end
		cur:close()
		con:close()
		return res
	end

	function sqldatabase:select ( to_select )	
		local query = to_select
		local con   = env:connect(self.database)
		res = {}
		--print(query:format(rowNames, tbName, sCond or ""))

		local cur = assert(
			con:execute(
				query
				--query:format(rowNames, tbName, sCond or "")
		))
		
		local row = cur:fetch ({}, "a")
		while row do
			local this = #res+1
			res[this] = {}
			for rowname, rowvalue in pairs(row) do
				res[this][rowname] = rowvalue
			end
			row = cur:fetch ({}, "a")
		end
		cur:close()
		con:close()
		return res
	end

	function sqldatabase:getTables ( ... )
		-- body
	end

	function sqldatabase:createTable ( ... )
		-- body
	end

return sqldatabase