-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lide/classes/store.lua
-- // Purpose:     Store class
-- // Author:      Dario Cano [thdkano@gmail.com]
-- // Modified by: 
-- // Created:     20/03/2016
-- // Copyright:   (c) 2014-2016 Dario Cano
-- // License:     lide license
-- /////////////////////////////////////////////////////////////////////////////////////////////////

--- import libraries
local check = lide.core.base.check

-- define the class:
local Store = class 'Store' : global(false)

-- define class constructor:
function Store:Store ( fields )
	protected {
		__allitems = {}
	}
end

-- Add a new value, the first param is the value to store.
function Store:add ( value )
	if (value ~= nil) then
		self.__allitems[ # self.__allitems +1 ] = value
	else
		error 'The value to add in the store can\'t be nil.'	
	end

	return self.__allitems[ # self.__allitems ] -- return added item
end

function Store:get ( tvalue )
    -- Si le entregamos una tabla:
    -- seria asi: 
     -- store:get { field = valorquetiene } -- retorna el item
    if type (tvalue) == 'table' then
        for k,v in next, tvalue do
            tvalue, tosearch = k,v
        end
    end

    for index, item in pairs(self.__allitems) do
        if item:get(tvalue) == tosearch then
            return item
        end
    end
end

return Store