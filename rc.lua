
-- {{{ Required Libraries

awful           = require("awful")
awful.rules     = require("awful.rules")
awful.autofocus = require("awful.autofocus")
wibox           = require("wibox")
beautiful       = require("beautiful")
naughty         = require("naughty")
vicious         = require("vicious")
vicious.contrib = require("vicious.contrib")
notmuchhoover   = require("notmuchhoover")
calendar2       = require("calendar2")
agenda          = require("agenda")
-- }}}

-- {{{ Autostart

function run_once(cmd)
 findme = cmd
 firstspace = cmd:find(" ")
 if firstspace then
  findme = cmd:sub(0, firstspace-1)
 end
 awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end 

run_once("/usr/bin/nitrogen --restore")
run_once("xrdb /home/aem/.Xresources")
--run_once("compton -cGb")
run_once("nm-applet")

-- }}}

-- {{{ Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
 naughty.notify({ preset = naughty.config.presets.critical,
 title = "Oops, there were errors during startup!",
 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
 in_error = false
 awesome.connect_signal("debug::error", function (err)
  -- Make sure we don't go into an endless error loop
  if in_error then return end
  in_error = true

  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Oops, an error happened!",
  text = err })
  in_error = false
 end)
end
-- }}}

-- {{{ Variable Definitions

-- Useful Paths
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
themes = confdir .. "/themes"

-- Choose Your Theme
active_theme = themes .. "/colored"

-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(active_theme .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "tabbed -c xterm -into"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "geany"
browser = "chromium"
fileman = "thunar " .. home
cli_fileman = terminal .. " -title Ranger -e ranger "
music = terminal .. " -title Music -e ncmpcpp "
lock = "slock"
suspend = "systemctl suspend"
hibernate = "systemctl hibernate"
reboot = "systemctl reboot"
poweroff = "systemctl poweroff"
exit = "systemctl exit"
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
 awful.layout.suit.floating,
 awful.layout.suit.tile,
 -- awful.layout.suit.tile.left,
 awful.layout.suit.tile.bottom,
 awful.layout.suit.tile.top,
 -- awful.layout.suit.fair,
 -- awful.layout.suit.fair.horizontal,
 -- awful.layout.suit.spiral,
 -- awful.layout.suit.spiral.dwindle,
 awful.layout.suit.max,
 -- awful.layout.suit.max.fullscreen,
 -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
 -- Each screen has its own tag table.
 tags[s] = awful.tag({ "base", "term", "web", "mail", "chat", "read", "work", "media" }, s,
 -- tags[s] = awful.tag({ "¹", "´", "²", "©", "ê", "º" }, s,
 { layouts[2], layouts[2], layouts[2],
 layouts[2], layouts[2], layouts[2], layouts[2], layouts[2]
})

-- awful.tag.seticon(active_theme .. "/widgets/arch_10x10.png", tags[s][1])
-- awful.tag.seticon(active_theme .. "/widgets/cat.png", tags[s][2])
-- awful.tag.seticon(active_theme .. "/widgets/dish.png", tags[s][3])
-- awful.tag.seticon(active_theme .. "/widgets/mail.png", tags[s][4])
-- awful.tag.seticon(active_theme .. "/widgets/phones.png", tags[s][5])
-- awful.tag.seticon(active_theme .. "/widgets/pacman.png", tags[s][6])

end

-- }}}

-- {{{
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
{ "open terminal", terminal },
{ "Lock" , lock } ,
{ "Logout", awesome.quit},
{ "Suspend", suspend },
{ "Hibernate", hibernate },
{ "Reboot", reboot },
{ "Shutdown", poweroff }
  } 
 })

 mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
 menu = mymainmenu })

 -- }}}



 -- {{{ Wibox

 -- {{{ Clock

 mytextclock = awful.widget.textclock()
 mytextclockicon = wibox.widget.imagebox()
 mytextclockicon:set_image(beautiful.widget_clock)
 agenda.addToWidget(mytextclockicon)
 calendar2.addCalendarToWidget(mytextclock)

 -- }}}

 -- {{{ Volume

 volicon = wibox.widget.imagebox()
 volicon:set_image(beautiful.widget_vol)
 volumewidget = wibox.widget.textbox()

 vicious.register(volumewidget, vicious.contrib.pulse, '<span color=\"#7788af\">$1%</span>', 2)
 --Register buttons
 volumewidget:buttons(awful.util.table.join(
 awful.button({ }, 1, function () awful.util.spawn("pavucontrol", false) end),
 awful.button({ }, 3, function () vicious.contrib.pulse.toggle() end),
 awful.button({ }, 4, function () vicious.contrib.pulse.add(5) end),
 awful.button({ }, 5, function () vicious.contrib.pulse.add(-5) end)
 ))

 -- }}}

 -- {{{ Net

 netdownicon = wibox.widget.imagebox()
 netdownicon:set_image(beautiful.widget_netdown)
 netupicon = wibox.widget.imagebox()
 netupicon:set_image(beautiful.widget_netup)


 wifidowninfo = wibox.widget.textbox()
 vicious.cache(vicious.widgets.net)
 vicious.register(wifidowninfo, vicious.widgets.net, "<span color=\"#ce5666\">${wlan0 down_kb}</span>", 5)

 wifiupinfo = wibox.widget.textbox()
 vicious.cache(vicious.widgets.net)
 vicious.register(wifiupinfo, vicious.widgets.net, "<span color=\"#87af5f\">${wlan0 up_kb}</span>", 7)

 -- }}}

 -- {{{ Battery state
 -- Initialize widget
 baticon = wibox.widget.imagebox()
 baticon:set_image(beautiful.widget_batt)
 batwidget = wibox.widget.textbox()
 -- Register widget
 vicious.register(batwidget, vicious.widgets.bat,
 function (widget,args)
  batt_color = beautiful.fg_green

  if args[2] < 2 then
   batt_color = beautiful.fg_red
   if args[1] == "-" then
    naughty.notify({
     text = "hybernating to disk now",
     title = "Critical Battery",
     position = "top_right",
     timeout = 30,
     fg=black,
     bg=red,
     ontop = true,
     screen = mouse.screen,
    })
   end
  elseif args[2] < 10 then

   batt_color = beautiful.fg_red
   if args[1] == "-" then
    naughty.notify({
     text = "charge now",
     title = "Low Battery",
     position = "top_right",
     timeout = 3,
     fg=white,
     bg=blue,
     screen = mouse.screen,
     ontop = true,
    })
   end


  elseif args[2] < 50 then
   batt_color = beautiful.fg_yellow

  end


  return string.format('<span color="' .. batt_color .. '">%s%s%%</span>',
  args[1],
  args[2]
  )
 end, 61, "BAT0")
 -- }}}


 -- {{{ Cpu

 cpuicon = wibox.widget.imagebox()
 cpuicon:set_image(beautiful.widget_cpu)
 cpuwidget = wibox.widget.textbox()
 vicious.register( cpuwidget, vicious.widgets.cpu, "<span color=\"#8faf5f\">$1%</span>", 3)
 cpuicon:buttons(awful.util.table.join(
 awful.button({ }, 1, function () awful.util.spawn("".. terminal.. " -geometry 80x18 -e saidar -c", false) end)
 ))
 -- }}}

 -- {{{ Ram

 memicon = wibox.widget.imagebox()
 memicon:set_image(beautiful.widget_mem)
 memwidget = wibox.widget.textbox()
 vicious.register(memwidget, vicious.widgets.mem, "<span color=\"#7788af\">$2 MB</span>", 1)
 memicon:buttons(awful.util.table.join(
 awful.button({ }, 1, function () awful.util.spawn("".. terminal.. " -e htop", false) end)
 ))
 -- }}}
 -- {{{ HDD
 hddicon = wibox.widget.imagebox()
 hddicon:set_image(beautiful.widget_fs)
 hddwidget = wibox.widget.textbox()
 vicious.register(hddwidget, vicious.widgets.fs, '<span color="#7788af">/:${/ used_p}% h:${/home used_p}%</span>', 60)

 -- }}}

 -- {{{ Maildir widget
 mailfolders = {"/home/aem/Mail/GMAIL/INBOX","/home/aem/Mail/CERN/INBOX"}
 mailicon = wibox.widget.imagebox()
 mailicon:set_image(beautiful.widget_gmail)
 maildirwidget = wibox.widget.textbox()
 vicious.register(maildirwidget, vicious.widgets.mdir, '<span color="' .. beautiful.fg_magenta .. '">$1</span>', 27,mailfolders )
 notmuchhoover.addToWidget(maildirwidget,"is:inbox and is:unread",30)
 -- }}}




 -- {{{ Spacers

 rbracket = wibox.widget.textbox()
 rbracket:set_text(']')
 lbracket = wibox.widget.textbox()
 lbracket:set_text('[')
 line = wibox.widget.textbox()
 line:set_text('|')
 space = wibox.widget.textbox()
 space:set_text(' ')

 -- }}}

 -- {{{ Layout

 -- Create a wibox for each screen and add it
 mywibox = {}
 mybottomwibox = {}
 mypromptbox = {}
 mylayoutbox = {}
 mytaglist = {}
 mytaglist.buttons = awful.util.table.join(
 awful.button({ }, 1, awful.tag.viewonly),
 awful.button({ modkey }, 1, awful.client.movetotag),
 awful.button({ }, 3, awful.tag.viewtoggle),
 awful.button({ modkey }, 3, awful.client.toggletag),
 awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
 awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
 )
 mytasklist = {}
 mytasklist.buttons = awful.util.table.join(
 awful.button({ }, 1, function (c)
  if c == client.focus then
   c.minimized = true
  else
   -- Without this, the following
   -- :isvisible() makes no sense
   c.minimized = false
   if not c:isvisible() then
    awful.tag.viewonly(c:tags()[1])
   end
   -- This will also un-minimize
   -- the client, if needed
   client.focus = c
   c:raise()
  end
 end),
 awful.button({ }, 3, function ()
  if instance then
   instance:hide()
   instance = nil
  else
   instance = awful.menu.clients({ width=250 })
  end
 end),
 awful.button({ }, 4, function ()
  awful.client.focus.byidx(1)
  if client.focus then client.focus:raise() end
 end),
 awful.button({ }, 5, function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
 end))

 for s = 1, screen.count() do

  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()

  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 0, height =14 })

  -- Widgets that are aligned to the left
  left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(space)
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(netdownicon)
  right_layout:add(wifidowninfo)
  right_layout:add(netupicon)
  right_layout:add(wifiupinfo)
  right_layout:add(memicon)
  right_layout:add(memwidget)
  right_layout:add(cpuicon)
  right_layout:add(cpuwidget)
  right_layout:add(hddicon)
  right_layout:add(hddwidget)
  right_layout:add(volicon)
  right_layout:add(volumewidget)
  right_layout:add(mailicon)
  right_layout:add(maildirwidget)
  right_layout:add(baticon)
  right_layout:add(batwidget)
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(mytextclockicon)
  right_layout:add(mytextclock)
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together
  layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)

 end

 -- }}}

 -- }}}

 -- {{{ Mouse Bindings

 root.buttons(awful.util.table.join(
 awful.button({ }, 4, awful.tag.viewnext),
 awful.button({ }, 5, awful.tag.viewprev)
 ))

 -- }}}

 -- {{{ Key Bindings

 -- {{{ Global keys
 globalkeys = awful.util.table.join(
 awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
 awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
 awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

 awful.key({ modkey,           }, "j",
 function ()
  awful.client.focus.byidx( 1)
  if client.focus then client.focus:raise() end
 end),
 awful.key({ modkey,           }, "k",
 function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
 end),
 awful.key({ modkey,           }, ".", function () mymainmenu:show({keygrabber=true}) end),

 -- Layout manipulation
 awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
 awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
 awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
 awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
 awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
 awful.key({ modkey,           }, "Tab",
 function ()
  awful.client.focus.history.previous()
  if client.focus then
   client.focus:raise()
  end
 end),

 -- Standard program
 awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
 awful.key({ modkey,           }, "w", function () awful.util.spawn("chromium") end),
 awful.key({ modkey,           }, "t", function () awful.util.spawn("thunderbird") end),
 awful.key({ modkey,           }, "g", function () awful.util.spawn("gajim") end),
 awful.key({ modkey,           }, "v", function () awful.util.spawn("gvim") end),
 awful.key({ modkey,           }, "q", function () awful.util.spawn("thunar") end),

 awful.key({ altkey, "Control" }, "l", function () awful.util.spawn(lock) end),
 awful.key({ modkey, "Control" }, "r", awesome.restart),
 awful.key({ modkey, "Shift"   }, "q", awesome.quit),

 awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
 awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
 awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
 awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
 awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
 awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
 awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
 awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

 awful.key({ modkey, "Control" }, "n", awful.client.restore),
 awful.key({ }, "XF86AudioLowerVolume", function () vicious.contrib.pulse.add(-5) end),
 awful.key({ }, "XF86AudioRaiseVolume", function () vicious.contrib.pulse.add(5) end),
 awful.key({ }, "XF86AudioMute", function () vicious.contrib.pulse.toggle() end),
 awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -10% -time 0")  end),
 awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight +10% -time 0") end),
 awful.key({ }, "XF86Display", function () awful.util.spawn("toggle-display") end),
 -- Prompt
 awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

 awful.key({ modkey }, "x",
 function ()
  awful.prompt.run({ prompt = "Run Lua code: " },
  mypromptbox[mouse.screen].widget,
  awful.util.eval, nil,
  awful.util.getdir("cache") .. "/history_eval")
 end)
 )
 -- }}}

 clientkeys = awful.util.table.join(
 awful.key({ altkey            }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
 awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
 awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
 awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
 awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
 awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
 awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
 awful.key({ modkey,           }, ",",      function (c) c.minimized = not c.minimized    end),
 awful.key({ modkey,           }, "m",
 function (c)
  c.maximized_horizontal = not c.maximized_horizontal
  c.maximized_vertical   = not c.maximized_vertical
 end)
 )

 -- Compute the maximum number of digit we need, limited to 9
 keynumber = 0
 for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
 end

 -- Bind all key numbers to tags.
 -- Be careful: we use keycodes to make it works on any keyboard layout.
 -- This should map on the top row of your keyboard, usually 1 to 9.
 for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
  awful.key({ modkey }, "#" .. i + 9,
  function ()
   screen = mouse.screen
   if tags[screen][i] then
    awful.tag.viewonly(tags[screen][i])
   end
  end),
  awful.key({ modkey, "Control" }, "#" .. i + 9,
  function ()
   screen = mouse.screen
   if tags[screen][i] then
    awful.tag.viewtoggle(tags[screen][i])
   end
  end),
  awful.key({ modkey, "Shift" }, "#" .. i + 9,
  function ()
   if client.focus and tags[client.focus.screen][i] then
    awful.client.movetotag(tags[client.focus.screen][i])
   end
  end),
  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
  function ()
   if client.focus and tags[client.focus.screen][i] then
    awful.client.toggletag(tags[client.focus.screen][i])
   end
  end))
 end

 clientbuttons = awful.util.table.join(
 awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
 awful.button({ modkey }, 1, awful.mouse.client.move),
 awful.button({ modkey }, 3, awful.mouse.client.resize))

 -- Set keys
 root.keys(globalkeys)

 -- }}}

 -- {{{ Rules
 awful.rules.rules = {
  { rule = { }, properties = {
   focus = true,      size_hints_honor = false,
   keys = clientkeys, buttons = clientbuttons,
   border_width = beautiful.border_width,
   border_color = beautiful.border_normal,
   floating = false}
  },
  { rule = { class = "Exe"}, properties = {floating = true} },
  { rule = { class = "Gajim", instance= "gajim" },
  properties = { tag = tags[screen.count()][5],
  floating = false } }, 
  { rule = { class = "Chromium"},
  properties = { floating = false } },
  { rule = { class = "Thunderbird"},
  properties = { tag = tags[screen.count()][4] } },
  { rule = { class = "geany" },
  properties = { tag = tags[screen.count()][1] } },
  { rule = { class = "Xmessage", instance = "xmessage" },
  properties = { floating = true },
  callback = awful.titlebar.add  },
  { rule = { class = "URxvt", instance = "oimapcheck" },
  properties = { floating = false,tag = tags[screen.count()][6] } },
  { rule = { class = "jetbrains-pycharm"},
  properties = { floating = true } },
 }
 -- }}}
 --
 --
 -- {{{ Signals

 -- Signal function to execute when a new client appears.
 client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
   end
  end)

  if not startup then
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   awful.client.setslave(c)

   -- Put windows in a smart way, only if they does not set an initial position.
   if not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
   end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(awful.titlebar.widget.iconwidget(c))

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(awful.titlebar.widget.floatingbutton(c))
   right_layout:add(awful.titlebar.widget.maximizedbutton(c))
   right_layout:add(awful.titlebar.widget.stickybutton(c))
   right_layout:add(awful.titlebar.widget.ontopbutton(c))
   right_layout:add(awful.titlebar.widget.closebutton(c))

   -- The title goes in the middle
   local title = awful.titlebar.widget.titlewidget(c)
   title:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
    client.focus = c
    c:raise()
    awful.mouse.client.move(c)
   end),
   awful.button({ }, 3, function()
    client.focus = c
    c:raise()
    awful.mouse.client.resize(c)
   end)
   ))

   -- Now bring it all together
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_right(right_layout)
   layout:set_middle(title)

   awful.titlebar(c):set_widget(layout)
  end
 end)

 client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
 client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

 -- }}}
