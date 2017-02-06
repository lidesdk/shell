-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        oop.lua
-- // Purpose:     OOP Model for Lide
-- // Author:      Julien Patte [julien.patte AT gmail DOT com]
-- // Created:     25/02/2007
-- // Modified:    Dario Cano (Lide SDK Compatibility Modifications ) [thdkano@gmail.com]
-- // Copyright:   (c) 2007 Julien Patte
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////

-----------------------------------------------------------------------------------
-- Yet Another Class Implementation (version 1.2.0)
--
-- Julien Patte [julien.patte AT gmail DOT com] - 25 Feb 2007
--
-- Inspired from code written by Kevin Baca, Sam Lie, Christian Lindig and others
-- Thanks to Damian Stewart and Frederic Thomas for their interest and comments
-----------------------------------------------------------------------------------

do	-- keep local things inside

local subclassof = function ( class, baseClass )
   lide.__store_classes[ class:name() ] = lide.__store_classes[baseClass] : subclass ( class:name() )
   local _env = getfenv(1)
   _env[class:name()] = lide.__store_classes[class:name()]
   setfenv(1, _env)
   return lide.__store_classes[class:name()]
end

local global = function ( class, bGlobal )
   local _env = getfenv(1)
   local class_name = class:name()

   if bGlobal == false then     
      
      if rawget(_env, class_name) then
         _env[class_name] = nil
      end

   elseif bGlobal == true then
      _env[class:name()] = lide.__store_classes[class:name()]
   end
   
   setfenv(1, _env)

   return lide.__store_classes[class:name()]
end

-- auxiliary function, which creates constants for classes
--
-- Usage:
--
--  "Class_Name" : enum {
--     CONSTANT    = 0,
--     ANOTHER_VAL = 1,  
--  }
--
--  print(Class_Name.CONSTANT)
--

local function class_enum ( class, enums_tbl )
   mt = getmetatable(class);
   mt.__index = table.join(mt.__index, enums_tbl);
   setmetatable(class, mt);
end


-- associations between an BaseObject an its meta-informations
-- e.g its class, its "lower" BaseObject (if any), ...
local metaObj = { }
setmetatable(metaObj, {__mode = "k"})

local function getprotected( inst, field )
   repeat
      if inst then
         if getmetatable(inst) and getmetatable(inst).__protected[field] then
            return getmetatable(inst).__protected[field]
         end
         inst = inst.super
      end
   until not inst
end

-----------------------------------------------------------------------------------
-- internal function 'duplicate'
-- return a shallow copy of table t

local function duplicate(t)
   local t2 = {}
   for k,v in pairs(t) do t2[k] = v end
   return t2
end

local function duplicateAll(t)
   local t2, mt2, mt = {}, {}, getmetatable(t)
   for k,v in pairs(t) do t2[k] = v end
   if mt then for k,v in pairs(mt) do mt2[k] = v end 
      setmetatable(t2, mt2)
   end
   return t2
end

-----------------------------------------------------------------------------------
-- internal function 'newInstance'

local function newInstance(class, ...) 

   local function makeInstance(class, virtuals)
      local inst = duplicate(virtuals)
      metaObj[inst] = { obj = inst, class = class }
  
      if class:super()~=nil then
         inst.super = makeInstance(class:super(), virtuals)
         metaObj[inst].super = metaObj[inst.super]	-- meta-info about inst
         metaObj[inst.super].lower = metaObj[inst]
      else 
         inst.super = {}
      end 
      
      class.static.__prvtflds   = {}
      class.static.__protected  = {}

      setmetatable(inst, duplicateAll(class.static))
      
      getmetatable(inst).__events = {}

      if inst[ class:name() ] then
         getmetatable(inst).__init = inst[ class:name()]
      else
         getmetatable(inst).__init = function () end
      end   

      return inst
   end

   local inst = makeInstance(class, metaObj[class].virtuals) 
   
   inst:init (...) -- [Llamada original]
   
   --public, private, protected = nil, nil, nil
    
   return inst -- lide.instances[#lide.instances]
end

-----------------------------------------------------------------------------------
-- internal function 'makeVirtual'

local function makeVirtual(class, fname) 
  local func = class.static[fname]
  if func == nil then 
    func = function() error("Attempt to call an undefined abstract method '"..fname.."'") end
   end
  metaObj[class].virtuals[fname] = func
end

-----------------------------------------------------------------------------------
-- internal function 'trycast'
-- try to cast an instance into an instance of one of its super- or subclasses

local function tryCast(class, inst) 
  local meta = metaObj[inst]
  if meta.class==class then return inst end -- is it already the right class?
  
  while meta~=nil do	-- search lower in the hierarchy
    if meta.class==class then return meta.obj end
    meta = meta.lower
  end
  
  meta = metaObj[inst].super  -- not found, search through the superclasses
  while meta~=nil do	
    if meta.class==class then return meta.obj end
    meta = meta.super
  end
  
  return nil -- could not execute casting
end

-----------------------------------------------------------------------------------
-- internal function 'secureCast'
-- same as trycast but raise an error in case of failure

local function secureCast(class, inst) 
  local casted = tryCast(class, inst)
  if casted == nil then 
	error("Failed to cast " .. tostring(inst) .. " to a " .. class:name())
  end
  return casted
end

-----------------------------------------------------------------------------------
-- internal function 'classMade'

local function classMade(class, obj) 
  if metaObj[obj]==nil then return false end -- is this really an BaseObject?
  return (tryCast(class,obj) ~= nil) -- check if that class could cast the BaseObject
end


-----------------------------------------------------------------------------------
-- internal function 'callup'
-- Function used to transfer a method call from a class to its superclass

local callup_inst
local callup_target

local function callup(inst, ...)
  return callup_target(callup_inst, ...)	-- call the superclass' method
end


-----------------------------------------------------------------------------------
-- internal function 'subclass'

local function inst_init_def(inst,...) 
   inst.super:init() 
end

local function inst_newindex(inst, key, value)

   -- First check if this field isn't already defined as private
   -- then check if isn't defined higher in the hierarchy
   if getmetatable(inst).__prvtflds[key] then
      getmetatable(inst).__prvtflds[key] = value   -- Update the old value
   
   elseif getprotected(inst, key) then
      -- protected
         repeat
            if inst then
               if getmetatable(inst) and getmetatable(inst).__protected[key] then
                  getmetatable(inst).__protected[key] = value
               end
               inst = inst.super
            end
         until not inst

   elseif inst.super[key] ~= nil then
	   inst.super[key] = value;		               -- Update the old value
   else 
  	   rawset(inst,key,value); 	        	         -- Create the field
   end
end

local function subclass(baseClass, name) 
   if type(name)~="string" then name = "Unnamed" end
  
   local theClass = {}

	-- need to copy everything here because events can't be found through metatables
   local b = baseClass.static
   local inst_stuff = { 
      __type = 'object', __lideobj = true,
      __tostring=b.__tostring, __eq=b.__eq, __add=b.__add, __sub=b.__sub, 
	   __mul=b.__mul, __div=b.__div, __mod=b.__mod, __pow=b.__pow, __unm=b.__unm, 
	   __len=b.__len, __lt=b.__lt, __le=b.__le, __concat=b.__concat, __call=b.__call,
   }
 
   inst_stuff.__newindex = inst_newindex
   
   function inst_stuff.class() return theClass end
   function inst_stuff.__index(inst, key) -- Look for field 'key' in instance 'inst'

      -- 1. Si el entorno permite acceder a valores privados:
      --    - El constructor de una clase
      --       1 - La llamada al constructor de una superclase dentro de la definicion de un constructor
      --       2 - Intento de acceder a un valor privado de 'self' 
          
      local type = lide.core.lua.type

      -- Si estamos dentro del constructor de una clase:
      do
         -- Para cuando hagamos [ self.super:init ]  
         if (key == 'init' or key == 'new') and getmetatable(inst).__init then
            function protected ( tFields )
              local _, self = debug.getlocal(2,1) -- get 'self'
              for field, value in next, tFields do
                 getmetatable(self).__protected[field] = value
              end
               --lide.core.error.lperr ('protected: not supported', 0)
            end

            function private ( tFields )
               local _, self = debug.getlocal(2,1) -- get 'self'
               for field, value in next, tFields do
                  getmetatable(self).__prvtflds[field] = value
               end
            end
            
            function public ( tFields )
               local _, self = debug.getlocal(2,1) -- get 'self'    
               for field, value in next, tFields do
                  rawset(self, field, value)
                  --getmetatable(self)[field] = value
               end
            end

            return getmetatable(inst).__init
         end
      end
     
      local function existsMethodAll ( inst, methodName )
         repeat
            if getmetatable(inst) [methodName] then
               return true, getmetatable(inst) [methodName]
            end
            inst = inst.super
         until not inst
      end
      
      local function isamethod( inst, foo )
         if getmetatable(inst) then
            repeat
               for methodName, method in pairs(getmetatable(inst) or {}) do
                  if method == foo then
                     return true, method
                  end
               end
               inst = inst.super
            until not inst
         end
         return false
      end

      do
         local dbginfo = debug.getinfo(2)
         local _, self = debug.getlocal(2,1) -- get 'self'

         if inst then
            -- Chequeamos si la funcion desde la que se hizo la llamada, esta definida como un metodo
            -- dentro de la clase o una de sus superclases:

            if isamethod(inst, dbginfo.func) then
               
               if (dbginfo.name == 'init') then
                  return getmetatable(inst).__prvtflds[key] or getprotected(inst, key)
               end

               if getprotected(inst, key) then
                  --io.stdout : write '>OK protected: '
                  return getprotected(inst, key) 
               end

               if getmetatable(inst).__prvtflds[key] 
               and getmetatable(inst:class()).__index.static[dbginfo.name] 
               or (dbginfo.name == 'init') then
                  --io.stdout : write '[ OK private ]: '
                  return getmetatable(inst).__prvtflds[key]
               end
            end
         end
      end

      ----------------------------------------------------------------------------------------------
      -- static values:
      local res = inst_stuff[key]     -- Is it present?
      if res ~= nil then 
         return res                    -- Okay, return it
      end 
            
         res = inst.super[key]  		                              -- Is it somewhere higher in the hierarchy?
	      if type(res)=='function' and res ~= callup then 		-- If it is a method of the superclass,
            callup_inst = inst.super  		                     -- we will need to do a special forwarding
		      callup_target = res  			                     -- to call 'res' with the correct 'self'
		      return callup 					                        -- The 'callup' function will do that
	      end   
        
      return res
   end
 
  local class_stuff = {
    enum = class_enum,
    subclassof = subclassof, global = global,
    static = inst_stuff, made = classMade, new = newInstance,
    subclass = subclass, virtual = makeVirtual, cast = secureCast, trycast = tryCast 
  }

  metaObj[theClass] = { virtuals = duplicate(metaObj[baseClass].virtuals) }

  function class_stuff.name(class) return name end
  function class_stuff.super(class) return baseClass end
  function class_stuff.inherits(class, other) 
	return (baseClass==other or baseClass:inherits(other)) 
  end
 
  local function newmethod(class, name, meth)
	inst_stuff[name] = meth;
	if metaObj[class].virtuals[name]~=nil then 
		metaObj[class].virtuals[name] = meth	
	end
  end
  
  local function tos() return ("class "..name) end
  setmetatable(theClass, { __type = 'class', __lideobj = true, __newindex = newmethod, __index = class_stuff, 
	__tostring = tos, __call = newInstance } )
 
  return theClass
end

-----------------------------------------------------------------------------------
-- The 'BaseObject' class

local BaseObject = { }

local function obj_newitem() error "May not modify the class 'BaseObject'. Subclass it instead." end
local obj_inst_stuff = {}
obj_inst_stuff.__index = obj_inst_stuff
obj_inst_stuff.__newindex = obj_newitem
function obj_inst_stuff.class() return BaseObject end
--function obj_inst_stuff.__tostring(inst) return ("a "..inst:class():name()) end

local obj_class_stuff = { static = obj_inst_stuff, made = classMade, new = newInstance,
	subclass = subclass, cast = secureCast, trycast = tryCast }

function obj_class_stuff.name(class) return "BaseObject" end
function obj_class_stuff.super(class) return nil end
function obj_class_stuff.inherits(class, other) return false end
metaObj[BaseObject] = { virtuals={} }

local function tos() return ("class BaseObject") end
setmetatable(BaseObject, { __newindex = obj_newitem, __index = obj_class_stuff, 
	__tostring = tos, __call = newInstance,
})

----------------------------------------------------------------------
-- function 'newclass'
function newclass(name, baseClass)
   baseClass = baseClass or BaseObject
   return  baseClass:subclass(name)
end
end 

local new_class = newclass; newclass = nil

return new_class
-- end of code
