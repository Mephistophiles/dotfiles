-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local awesome = assert(awesome)
local client = assert(client)
local screen = assert(screen)
local root = assert(root)

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- External libraries
local unistd = require("posix.unistd")
local vicious = require("vicious")
local scratch = require("scratch")
local lfs = require("lfs") -- filesystem library


-- CONSTS
local AWESOMEWM_DIR = gears.filesystem.get_configuration_dir()
local WALLPAPERS_DIR = AWESOMEWM_DIR .. "/wallpapers/"
local USER_ID = unistd.getuid()
local XIDLEHOOK_SOCKET = string.format("/var/run/user/%d/xidlehook.socket", USER_ID)
local CAFFEINE_OFF_ICON = string.format("%s/icons/my-caffeine-off-symbolic.svg", AWESOMEWM_DIR)
local CAFFEINE_ON_ICON = string.format("%s/icons/my-caffeine-on-symbolic.svg", AWESOMEWM_DIR)

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.

local wallpapers = (function()
    local wallpapers = {}

    for file in lfs.dir(WALLPAPERS_DIR) do
        if file ~= "." and file ~= ".." then
            table.insert(wallpapers, WALLPAPERS_DIR .. file)
        end
    end

    return wallpapers
end)()

math.randomseed(os.time())
local selected_wallpaper = wallpapers[math.random(1, #wallpapers)]

beautiful.wallpaper = function()
    return selected_wallpaper
end

local terminal = "kitty"
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function dir_is_empty(dir)
    local file_is_ignored = setmetatable({
        ".",
        "hidpp_battery_",
    }, {
        __call = function(self, file)
            for _, item in ipairs(self) do
                if gears.string.startswith(file, item) then
                    return true
                end
            end

            return false
        end,
    })

    for file in lfs.dir(dir) do
        if not file_is_ignored(file) then
            return false
        end
    end

    return true
end

local function get_total_memory()
    local pipe = io.popen("awk '/MemTotal/ {print $2}' /proc/meminfo", "r")

    if not pipe then
        return 0
    end

    local total_memory = pipe:read("*l")
    pipe:close()

    return tonumber(total_memory) or 0
end

local function has_battery()
    return not dir_is_empty("/sys/class/power_supply")
end

local SKIP = setmetatable({}, {
    __call = function(self)
        return self
    end,
})

local function caffeine_widget_toggle_active(widget, active)
    local needed_active
    local needed_icon
    local needed_action

    if active ~= nil then
        needed_active = active
    else
        needed_active = not widget.data.active
    end

    if needed_active then
        needed_icon = CAFFEINE_ON_ICON
        needed_action = "Disable"
    else
        needed_icon = CAFFEINE_OFF_ICON
        needed_action = "Enable"
    end

    awful.spawn({ "xidlehook-client", "--socket", XIDLEHOOK_SOCKET, "control", "--action", needed_action })

    widget.data.active = needed_active
    widget.image = needed_icon
end

local caffeine_widget = wibox.widget({
    data = {
        active = false,
    },
    widget = wibox.widget.imagebox,
})
caffeine_widget_toggle_active(caffeine_widget, false)

caffeine_widget:connect_signal("button::press", function()
    caffeine_widget_toggle_active(caffeine_widget)
end)

local text_cpu_widget = wibox.widget.textbox()
vicious.register(text_cpu_widget, vicious.widgets.cpu, "CPU: $1%")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, "MEM: $1% SWP: $5%")
local total_memory = get_total_memory()
local top_mem_usage_widget = awful.widget.watch(
    [[bash -c "ps -eo rss,comm --sort=-rss --no-header | head -1 | awk '{print \$1,\" \",\$1,\" \",\$2}' | numfmt --to=iec --from-unit=1024 --field 1"]],
    15,
    function(widget, stdout)
        local pretty_memory, bytes, comm = table.unpack(gears.string.split(stdout, " "))

        if tonumber(bytes) > total_memory / 8 then
            widget:set_visible(true)
            widget:set_text(pretty_memory .. " " .. comm)
        else
            widget:set_visible(false)
        end
    end
)

local battery_widget = has_battery()
        and (function()
            local widget = wibox.widget.textbox()

            vicious.register(widget, vicious.widgets.bat, "BAT: $2%", 60, "BAT0")

            return widget
        end)()
    or SKIP

-- local volume_widget = require('awesome-wm-widgets.volume-widget.volume')

local pushlocker_widget = wibox.widget.textbox()
pushlocker_widget:buttons(awful.util.table.join(table.unpack({
    awful.button({}, 1, function()
        local _, _, ret = os.execute("timeout 2s pushlockctl check")

        if ret == 0 then
            awful.spawn("pushlockctl lock", false)
        elseif ret == 2 then
            awful.spawn("pushlockctl unlock", false)
        end
    end),
})))

local update_pushlocker_text = function()
    local ip_route_handle = io.popen("ip route list exact 192.168.161.0/24", "r")

    if ip_route_handle == nil then
        pushlocker_widget.text = ""
        pushlocker_widget.visible = false
        return
    end

    local ip_route_out = ip_route_handle:read("*a")
    local has_vpn = ip_route_out and ip_route_out:match("^192.168.161.0/24") ~= nil

    ip_route_handle:close()

    if not has_vpn then
        pushlocker_widget.text = ""
        pushlocker_widget.visible = false
        return
    end

    awful.spawn.easy_async("timeout 2s pushlockctl check", function(stdout, _, _, exit_code)
        stdout = stdout:gsub("\n", "")

        pushlocker_widget.visible = true

        if stdout == "Unknown error" or exit_code == 101 or exit_code == 124 then
            pushlocker_widget.text = " 🔥 Server Error "
        elseif exit_code == 0 then
            pushlocker_widget.text = " ⚡️ "
        elseif exit_code == 1 then
            pushlocker_widget.text = " 🚧 " .. stdout .. " "
        elseif exit_code == 2 then
            pushlocker_widget.text = " 👷 Locked by me "
        elseif exit_code == 101 or exit_code == 124 then
            pushlocker_widget.text = " 🔥 Server Error "
        end
    end)
end

local has_redminer = function()
    return select(1, os.execute("~/bin/redminer timer list_porcelain"))
end

local redminer_widget = has_redminer()
        and awful.widget.watch(string.format("%s/redminer.sh", AWESOMEWM_DIR), 5, function(widget, stdout)
            if #stdout == 0 then
                widget:set_visible(false)
            else
                widget:set_markup(stdout)
                widget:set_visible(true)
            end
        end)
    or SKIP

local current_dm_version = awful.widget.watch(
    { string.format("%s/dm_version.sh", AWESOMEWM_DIR) },
    5,
    function(widget, stdout)
        if stdout and #stdout > 0 then
            widget:set_visible(true)
            widget:set_text(" v" .. stdout .. " ")
        else
            widget:set_visible(false)
        end
    end
)

local cpu_temp_widget = awful.widget.watch(
    { "bash", "-c", [[sensors 'k10temp-*' -u | grep input: | head | cut -d' ' -f4 | head -1]] },
    5,
    function(widget, stdout)
        if not stdout or #stdout == 0 then
            return
        end
        local temp = tonumber(stdout)

        widget:set_text(string.format("%.1f℃", temp))
    end
)

gears.timer({
    timeout = 3,
    call_now = true,
    autostart = true,
    callback = function()
        update_pushlocker_text()
    end,
})

local separator = wibox.widget({
    widget = wibox.widget.separator,
    orientation = "vertical",
    forced_width = 8,
    color = "#444444",
    visible = true,
})

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Create a textclock widget
    local mytextclock = wibox.widget.textclock()
    local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
    local cw = calendar_widget({
        theme = "nord",
        placement = "top_right",
        radius = 8,
    })
    mytextclock:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            cw.toggle()
        end
    end)

    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    local left_widgets = {
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        s.mytaglist,
        s.mypromptbox,
    }

    local right_widgets = {
        layout = wibox.layout.fixed.horizontal,
        spacing = 5,
    }

    for widget in
        gears.table.iterate({
            current_dm_version,
            redminer_widget,
            pushlocker_widget,
            caffeine_widget,
            -- volume_widget({widget_type = 'arc', device = 'default'}),
            text_cpu_widget,
            cpu_widget(),
            cpu_temp_widget,
            mem_widget,
            top_mem_usage_widget,
            battery_widget,
            separator,
            mykeyboardlayout,
            separator,
            wibox.widget.systray(),
            separator,
            mytextclock,
            s.mylayoutbox,
        }, function(item)
            if item == SKIP then
                return false
            end

            return true
        end)
    do
        table.insert(right_widgets, widget)
    end

    -- Add widgets to the wibox
    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        left_widgets,
        s.mytasklist, -- Middle widget
        right_widgets,
    })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "Up",   function () awful.screen.focus_relative(-1) end,
              {description = "focus the next screen", group = "client"}),
    awful.key({ modkey,           }, "Down", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({modkey,            }, [[\]], function() awful.spawn(AWESOMEWM_DIR .. 'awesome-lock.sh lock 2') end,
              {description = 'lock a screen', group = 'launcher'}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    -- DMenu
    awful.key({ modkey }, "d", function() awful.spawn('rofi -modes "run,window,ssh" -show run', false) end),
    awful.key({ modkey, "Shift" }, "d", function() awful.spawn('rofi -modi drun -show drun', false) end),
    -- Rofi greenclip
    awful.key({ modkey }, "c", function() awful.spawn('rofi -modi "clipboard:greenclip print" -show clipboard', false) end),
    -- wallpaper
    awful.key({ modkey, "Shift" }, "w", function ()
        awful.spawn('rofi -modi "wallpaper:'..AWESOMEWM_DIR..'/set_wallpaper.sh" -show wallpaper', false)
    end,
              {description = "Select wallpaper", group = "awesome"}),
    -- Media
    awful.key({}, 'XF86AudioRaiseVolume',
              function() awful.spawn('amixer -q set Master 2%+', false) end,
              {description = 'increase volume level', group = 'awesome'}),
    awful.key({}, 'XF86AudioLowerVolume',
              function() awful.spawn('amixer -q set Master 2%-', false) end,
              {description = 'decrease volume level', group = 'awesome'}),
    awful.key({}, 'XF86AudioMute',
              function() awful.spawn('amixer -q set Master toggle', false) end,
              {description = 'toggle volume', group = 'awesome'}),

    awful.key({}, 'XF86MonBrightnessUp',
              function() awful.spawn('brightnessctl set +15', false) end,
              {description = 'increase brightness', group = 'awesome'}),
    awful.key({}, 'XF86MonBrightnessDown',
              function() awful.spawn('brightnessctl set 15-', false) end,
              {description = 'decrease brightness', group = 'awesome'})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, 'b',
        function()
            local myscreen = awful.screen.focused()
            myscreen.mywibox.visible = not myscreen.mywibox.visible
        end,
        {description = 'toggle statusbar', group = 'client'}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),

    -- working toggle titlebar
    awful.key({ modkey, "Control" }, "t",
        function (c)
            awful.titlebar.toggle(c)
        end,
        {description = "Show/Hide Titlebars", group="client"}),

    awful.key({modkey, 'Shift'}, '-', function(c) scratch.pad.set(c) end,
              {description = 'make the currently focused window a scratchpad', group = 'client'}),
    awful.key({modkey}, '-', function() scratch.pad.toggle() end,
              {description = 'show the scratchpad window', group = 'client'})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autorun
local lock_scr = string.format("%sawesome-lock.sh", AWESOMEWM_DIR)

local function autorun(cmd)
    awful.spawn("pkill " .. cmd[1])

    awful.spawn.once(cmd, awful.spawn_once)
end
autorun({ "flameshot" })
autorun({ "greenclip", "daemon" })
autorun({ "solaar", "config", "MX Master 2S", "dpi", "4000" })
autorun({ "setxkbmap", "us,ru", "-option", "grp:alt_shift_toggle,grp_led:scroll", "-option", "caps:backspace" })
autorun({
    "xidlehook",
    "--socket", XIDLEHOOK_SOCKET,
    "--not-when-fullscreen",
    "--timer", "60",
    lock_scr .. " lock 1",
    lock_scr .. " unlock 1",
    "--timer", "30",
    lock_scr .. " lock 2",
    lock_scr .. " unlock 2",
})
-- }}}
