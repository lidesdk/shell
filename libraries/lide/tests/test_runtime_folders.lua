assert(app, 'test runtime: "app" value doesn\'t exists.')
assert(app.sourcefolder , 'test runtime folders: value app.sourcefolder doesn\'t exists.')
assert(app.workingfolder, 'test runtime folders: value app.workingfolder doesn\'t exists.')

print (('Source folder: %s'):format(app.sourcefolder))
print (('Working folder: %s'):format(app.workingfolder))