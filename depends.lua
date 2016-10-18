package.path  = './ourlibs/?.lua'
package.cpath = './ourlibs/?.so'

local http_socket = require('socket.http')
local https_socket = require('ssl.https')
local url_parser = require('socket.url')
local ltn12 = require('ltn12')
local json = require('cjson.safe')
local xml = require('xml')
local md5sum = require('md5') -- TODO: Make modular?
local base64 = require('base64')
