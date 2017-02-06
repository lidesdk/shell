-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        init.lua
-- // Purpose:     Initialize framework
-- // Author:      Dario Cano [dario.canohdz@gmail.com]
-- // Created:     2016/01/03
-- // Copyright:   (c) 2014 Dario Cano
-- // License:     MIT License/X11 license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--
-- GNU/Linux x86 LuaRocks version: /usr/bin/luarocks-5.1 2.3.0
-- Windows x86 LuaRocks version:

package = "lide"
version = "0.0-0"

source = { 
  url = "https://github.com/lidesdk/framework/archive/master.zip",
  dir = 'framework-master'
}

description = {
  summary = "Lua framework",
    detailed = [[Lide framework allows you to design and make professional applications with native controls and dialogs in different platforms such as Windows or Linux.]],
    homepage = "http://lide-framework.rtfd.io",
    license = "MIT/X11"
}

supported_platforms = {
  "win32", "linux", "windows"
}

dependencies = {
  "lua == 5.1"
}

build = { type = 'builtin', modules = {}, install = {},
  platforms = { 
    linux   = { install = {} },
    windows = { install = {} },
  }
}

build.platforms.linux.install.lib = {
  ['wx'] = 'bin/x86/wx.so',
}

build.platforms.linux.arch = 'x86_64'

--build.platforms.arch.install.lib = {
--  ['wx'] = 'bin/x86/wx.so',
--}

build.platforms.windows.install.lib = {
  ['wx'] = 'bin/x86/wx.dll',
}

build.install.lua = {
  ['lide.init'] = 'init.lua',
  ['lide.core.init']        = 'core/init.lua',
  ['lide.core.base']        = 'core/base.lua',
  ['lide.core.thlua']       = 'core/thlua.lua',
  ['lide.core.error']       = 'core/error.lua',
  ['lide.core.file']        = 'core/file.lua',
  ['lide.core.folder']      = 'core/file.lua',
  ['lide.core.oop.init']    = 'core/oop/init.lua',
  ['lide.core.oop.yaci']    = 'core/oop/yaci.lua',
  ['lide.classes.init']     = 'classes/init.lua',
  ['lide.classes.boxsizer'] = 'classes/boxsizer.lua',
  ['lide.classes.event']    = 'classes/event.lua',
  ['lide.classes.font']     = 'classes/font.lua',
  ['lide.classes.gridtable']= 'classes/gridtable.lua',
  ['lide.classes.item']     = 'classes/item.lua',
  ['lide.classes.menu']     = 'classes/menu.lua',
  ['lide.classes.object']   = 'classes/object.lua',
  ['lide.classes.store']    = 'classes/store.lua',
  ['lide.classes.timer']    = 'classes/timer.lua',
  ['lide.classes.widget']   = 'classes/widget.lua',

  --> Copy Widgets:
  ['lide.classes.widgets.control'] = 'classes/widgets/control.lua',  
  ['lide.classes.widgets.form']    = 'classes/widgets/form.lua',  
  ['lide.classes.widgets.panel']   = 'classes/widgets/panel.lua',  
  ['lide.classes.widgets.window']  = 'classes/widgets/window.lua',  

  --> Copy controls:
  ['lide.classes.controls.button'  ] = 'classes/controls/button.lua',
  ['lide.classes.controls.combobox'] = 'classes/controls/combobox.lua',
  ['lide.classes.controls.grid']     = 'classes/controls/grid.lua',
  ['lide.classes.controls.htmlview'] = 'classes/controls/htmlview.lua',
  ['lide.classes.controls.image']    = 'classes/controls/image.lua',
  ['lide.classes.controls.label']    = 'classes/controls/label.lua',
  ['lide.classes.controls.progress'] = 'classes/controls/progress.lua',
  ['lide.classes.controls.textbox']  = 'classes/controls/textbox.lua',
  ['lide.classes.controls.textctrl'] = 'classes/controls/textctrl.lua',
  ['lide.classes.controls.toolbar']  = 'classes/controls/toolbar.lua',
  ['lide.classes.controls.listbox']  = 'classes/controls/listbox.lua',
}