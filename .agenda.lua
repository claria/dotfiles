local string = string
local tostring = tostring
local io = { popen = io.popen }
local print = print
local os = os
local table = table
local pairs = pairs
--local timer = timer
local capi = {
  mouse = mouse,
  screen = screen
}

local awful = require("awful")
local naughty = require("naughty")
local beautiful = require('beautiful')

--home = os.getenv("HOME")
--confdir = home .. "/.config/awesome"
--themes = confdir .. "/themes"
--active_theme = themes .. "/colored"
--beautiful.init(active_theme .. "/theme.lua")

module("agenda")

local popup

function addToWidget(mywidget)
  mywidget:connect_signal('mouse::enter', function ()
    popup = naughty.notify({
      title = "Google Calendar\n" .. gcaltoday,
      text = gcaldata,
      timeout = 0,
      fg = white,
      bg = blue,
      --screen = mouse.screen,
      ontop = true,
      border_color = black,
    })
  end)
  mywidget:connect_signal('mouse::leave', function () naughty.destroy(popup) end)
  mywidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      update_gcal()
    end)
    ))
end

function update_gcal()
  local f = io.popen("gcalcli --nocolor agenda")
  gcaldata = f:read("*all")
  f:close()
  --gcaldata = awful.util.pread("gcalcli --nocolor agenda")
  gcaldata = string.gsub(gcaldata, "%$(%w+)", "%1")
  gcaldata = gcaldata:match( "(.-)%s*$")
  gcaltoday = os.date("%A, %d. %B")
  return nil
end

--gcaltimer = timer({ timeout = 1800 })
--gcaltimer:connect_signal("timeout", function() update_gcal() end)
--gcaltimer:start()

update_gcal()
