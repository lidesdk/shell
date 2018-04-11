file = arg[1]
print(file)
package.path = os.getenv 'LIDE_PATH' .. '/libraries/windows/x86/lua/?.lua;' 
			.. os.getenv 'LIDE_PATH' .. '/libraries/?.lua;' 

package.cpath = os.getenv 'LIDE_PATH' .. '/libraries/windows/x86/clibs/?.dll;' 

if file then
	assert( pcall(dofile, file) )
end