-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
-- Widgets
local battery_widget = require("widgets.battery")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- tag names
local names = { "1  ", "2  ", "3  ", "4  ", "5  ", "6 ", "7 ", "8  ", "9  ", "10  " }

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
    awesome.connect_signal("debug::error", function(err)
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
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
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
    -- awful.layout.suit.corner.nw,
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
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local cw = calendar_widget({
    theme = 'nord',
    placement = 'top_middle',
    start_sunday = false,
    radius = 8,
    -- with customized next/previous (see table above)
    previous_month_button = 1,
    next_month_button = 3,
})
mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- -- Each screen has its own tag table.
    -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    -- Each screen has its own tag table.
    local layouts = { awful.layout.layouts[1] }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))
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

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher, -- awesome symbol used as a launcher
            s.mytaglist,
            s.mypromptbox,
        },
        -- s.mytasklist, -- Middle widget
        { -- Middle widget
            mytextclock,
            layout = wibox.container.place,
            valign = 'center',
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray({screen = awful.screen.focused()}),
            battery_widget({ show_current_level = true, display_notification = true, font = require("theme.theme").font }),
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),

    -- Focus on tags
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),

    -- awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    --     { description = "go back", group = "tag" }),

    -- awful.key({ modkey, }, "j",
    --     function()
    --         awful.client.focus.byidx(1)
    --     end,
    --     { description = "focus next by index", group = "client" }
    -- ),
    -- awful.key({ modkey, }, "k",
    --     function()
    --         awful.client.focus.byidx(-1)
    --     end,
    --     { description = "focus previous by index", group = "client" }
    -- ),
    awful.key({ modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "x", awesome.quit,
        { description = "quit awesome", group = "awesome" }),

    -- Master and column manipulation
    awful.key({ modkey }, "m", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "m", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey }, "n", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Shift" }, "n", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),

    -- Swap layout
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    -- awful.key({ modkey, "Control" }, "n",
    --     function()
    --         local c = awful.client.restore()
    --         -- Focus restored client
    --         if c then
    --             c:emit_signal(
    --                 "request::activate", "key.unminimize", { raise = true }
    --             )
    --         end
    --     end,
    --     { description = "restore minimized", group = "client" }),

    awful.key({ modkey, "Shift" }, "p",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),

    -- =========================================
    -- SPAWN APPLICATION KEY BINDINGS
    -- =========================================

    -- -- dmenu
    -- awful.key({ modkey }, "d", function()
    --     awful.util.spawn("dmenu_run")
    -- end,
    --     { description = "launch dmenu", group = "launcher" }),

    -- Terminal
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),

    -- firefox
    awful.key({ modkey, "Shift" }, "f", function()
        awful.spawn("firefox")
    end,
        { description = "Open browser (firefox)", group = "launcher" }),

    -- spotify
    awful.key({ modkey, "Shift" }, "s", function()
        awful.spawn("flatpak run com.spotify.Client")
    end,
        { description = "Open Spotify", group = "launcher" }),

    -- Ranger
    awful.key({ modkey }, "e", function()
        awful.spawn(terminal .. " -e ranger")
    end,
        { description = "show the menubar", group = "launcher" }),

    -- Menubar
    awful.key({ modkey }, "d", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" }),

    -- =========================================
    -- FUNCTION KEYS
    -- =========================================

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp",
        function()
            awful.spawn("brightnessctl s +5%", false)
        end,
        { description = "+5%", group = "hotkeys" }
    ),
    awful.key({}, "XF86MonBrightnessDown",
        function()
            awful.spawn("brightnessctl s 5%-", false)
        end,
        { description = "-5%", group = "hotkeys" }
    ),

    -- Pulseaudio volume control
    awful.key({}, "XF86AudioRaiseVolume",
        function()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
            awesome.emit_signal("volume_change")
        end,
        { description = "volume up", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioLowerVolume",
        function()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
            awesome.emit_signal("volume_change")
        end,
        { description = "volume down", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioMicMute",
        function()
            awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle", false)
            awesome.emit_signal("volume_change")
        end,
        { description = "toggle mute microphone", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioMute",
        function()
            awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
            awesome.emit_signal("volume_change")
        end,
        { description = "toggle mute", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioNext",
        function()
            awful.spawn("exec playerctl next", false)
        end,
        { description = "next music", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioPrev",
        function()
            awful.spawn("exec playerctl previous", false)
        end,
        { description = "previous music", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioPlay",
        function()
            awful.spawn("playerctl play-pause", false)
        end,
        { description = "play/pause music", group = "hotkeys" }
    ),
    awful.key({}, "XF86AudioPause",
        function()
            awful.spawn("playerctl play-pause", false)
        end,
        { description = "play/pause music", group = "hotkeys" }
    ),

    -- Screenshots
    awful.key({ modkey, "Shift" }, "Print", function()
        awful.util.spawn_with_shell("maim -s | xclip -selection clipboard -t image/png")
    end,
        { description = "Screenshot", group = "launcher" })
)

clientkeys = gears.table.join(
-- Handling window states
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, }, "o", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),

    -- Layout control
    awful.key({ modkey, "Shift" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),

    -- awful.key({ modkey, }, "n",
    --     function(c)
    --         -- The client currently has the input focus, so it cannot be
    --         -- minimized, since minimized clients can't have the focus.
    --         c.minimized = true
    --     end,
    --     { description = "minimize", group = "client" }),

    -- Resize windows
    awful.key({ modkey, "Control" }, "Up", function(c)
        if c.floating then
            c:relative_move(0, 0, 0, -10)
        else
            awful.client.incwfact(0.025)
        end
    end,
        { description = "Floating Resize Vertical -", group = "client" }),
    awful.key({ modkey, "Control" }, "Down", function(c)
        if c.floating then
            c:relative_move(0, 0, 0, 10)
        else
            awful.client.incwfact(-0.025)
        end
    end,
        { description = "Floating Resize Vertical +", group = "client" }),
    awful.key({ modkey, "Control" }, "Left", function(c)
        if c.floating then
            c:relative_move(0, 0, -10, 0)
        else
            awful.tag.incmwfact(-0.025)
        end
    end,
        { description = "Floating Resize Horizontal -", group = "client" }),
    awful.key({ modkey, "Control" }, "Right", function(c)
        if c.floating then
            c:relative_move(0, 0, 10, 0)
        else
            awful.tag.incmwfact(0.025)
        end
    end,
        { description = "Floating Resize Horizontal +", group = "client" }),

    -- Moving floating windows
    awful.key({ modkey, "Shift" }, "Down", function(c)
        c:relative_move(0, 10, 0, 0)
    end,
        { description = "Floating Move Down", group = "client" }),
    awful.key({ modkey, "Shift" }, "Up", function(c)
        c:relative_move(0, -10, 0, 0)
    end,
        { description = "Floating Move Up", group = "client" }),
    awful.key({ modkey, "Shift" }, "Left", function(c)
        c:relative_move(-10, 0, 0, 0)
    end,
        { description = "Floating Move Left", group = "client" }),
    awful.key({ modkey, "Shift" }, "Right", function(c)
        c:relative_move(10, 0, 0, 0)
    end,
        { description = "Floating Move Right", group = "client" }),

    -- Maximize unmaximize
    awful.key({ modkey, }, "r",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "k",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Control" }, "j",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Control" }, "l",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" }),
    awful.key({ modkey, "Control" }, "h",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" }),

    -- Moving window focus works between desktops
    awful.key({ modkey, }, "j", function(c)
        awful.client.focus.global_bydirection("down")
        c:lower()
    end,
        { description = "focus next window up", group = "client" }),
    awful.key({ modkey, }, "k", function(c)
        awful.client.focus.global_bydirection("up")
        c:lower()
    end,
        { description = "focus next window down", group = "client" }),
    awful.key({ modkey, }, "l", function(c)
        awful.client.focus.global_bydirection("right")
        c:lower()
    end,
        { description = "focus next window right", group = "client" }),
    awful.key({ modkey, }, "h", function(c)
        awful.client.focus.global_bydirection("left")
        c:lower()
    end,
        { description = "focus next window left", group = "client" }),

    -- Moving windows between positions works between desktops
    awful.key({ modkey, "Shift" }, "h", function(c)
        awful.client.swap.global_bydirection("left")
        c:raise()
    end,
        { description = "swap with left client", group = "client" }),
    awful.key({ modkey, "Shift" }, "l", function(c)
        awful.client.swap.global_bydirection("right")
        c:raise()
    end,
        { description = "swap with right client", group = "client" }),
    awful.key({ modkey, "Shift" }, "j", function(c)
        awful.client.swap.global_bydirection("down")
        c:raise()
    end,
        { description = "swap with down client", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function(c)
        awful.client.swap.global_bydirection("up")
        c:raise()
    end,
        { description = "swap with up client", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
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
    { rule = {},
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA", -- Firefox addon DownThemAll.
            "copyq", -- Includes session name in class.
            "pinentry",
        },
        class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin", -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer"
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
            "Event Tester", -- xev.
        },
        role = {
            "AlarmWindow", -- Thunderbird's calendar.
            "ConfigManager", -- Thunderbird's about:config.
            "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true } },

    -- Add titlebars to normal clients and dialogs
    -- { rule_any = {type = { "normal", "dialog" }
    { rule_any = { type = { "dialog" }
    }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "1" on screen 1.
    { rule = { class = "firefox" },
        properties = { screen = 1, tag = names[1] } },

    { rule = { class = "rambox" },
        properties = { screen = 1, tag = names[9] } },

    { rule = { class = "Spotify" },
        properties = { screen = 1, tag = names[10] } },

    { rule = { class = "libreoffice-writer" },
        properties = { screen = 1, tag = names[4] } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

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
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
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
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            -- awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Gaps
beautiful.useless_gap = 5

---------------------------------------
-- Autostart applications on startup --
---------------------------------------

-- List of apps to run on start-up
local run_on_start_up = {
    "xcompmgr &",
    "flatpak run com.synology.SynologyDrive",
    "/opt/Rambox/rambox &",
    "nm-applet &",
    "blueman-applet",
    "lxpolkit &",
}

-- Run all the apps listed in run_on_start_up

-- Shell command that will only run the apps if awesome hasn't been started yet
local shell_command = 'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";'
for _, app in ipairs(run_on_start_up) do
    shell_command = shell_command .. app .. ";"
end

-- pipe commands to bash to allow command to be shell agnostic
awful.spawn.with_shell(shell_command)
