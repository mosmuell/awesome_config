--      ██╗  ██╗███████╗██╗   ██╗███████╗
--      ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝
--      █████╔╝ █████╗   ╚████╔╝ ███████╗
--      ██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║
--      ██║  ██╗███████╗   ██║   ███████║
--      ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
--
-- Inspired from: https://github.com/WillPower3309/awesome-dotfiles/tree/master/awesome

-- ===================================================================
-- Initialization
-- ===================================================================

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Notification library
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Define mod keys
local modkey = "Mod4"
local altkey = "Mod1"

-- define module table
local keys = {}

-- ===================================================================
-- MOUSE BINDINGS
-- ===================================================================

keys.desktopbuttons = gears.table.join(
  awful.button({}, 3, function()
    mymainmenu:toggle()
  end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
)

-- ===================================================================
-- DESKTOP KEY BINDINGS
-- ===================================================================

keys.globalkeys = gears.table.join(

  -- =========================================
  -- HELP PAGE
  -- =========================================
  awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

  -- Focus on tags
  awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),

  -- awful.key({ modkey, }, "w", function() mymainmenu:show() end,
  --     { description = "show main menu", group = "awesome" }),

  -- =========================================
  -- RELOAD / QUIT AWESOME
  -- =========================================

  -- Standard program
  awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "x", awesome.quit, { description = "quit awesome", group = "awesome" }),

  -- =========================================
  -- NUMBER OF MASTER / COLUMN CLIENTS
  -- =========================================

  awful.key({ modkey }, "m", function()
    awful.tag.incnmaster(1, nil, true)
  end, { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "m", function()
    awful.tag.incnmaster(-1, nil, true)
  end, { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey }, "n", function()
    awful.tag.incncol(1, nil, true)
  end, { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Shift" }, "n", function()
    awful.tag.incncol(-1, nil, true)
  end, { description = "decrease the number of columns", group = "layout" }),

  -- =========================================
  -- GAP CONTROL
  -- =========================================

  -- Gap control
  awful.key({ modkey, "Shift" }, "minus", function()
    awful.tag.incgap(5, nil)
  end, { description = "increment gaps size for the current tag", group = "gaps" }),
  awful.key({ modkey }, "minus", function()
    awful.tag.incgap(-5, nil)
  end, { description = "decrement gap size for the current tag", group = "gaps" }),

  -- =========================================
  -- LAYOUT SELECTION/MANIPULATION
  -- =========================================

  awful.key({ modkey }, "space", function()
    awful.layout.inc(1)
  end, { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function()
    awful.layout.inc(-1)
  end, { description = "select previous", group = "layout" }),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function()
    awful.client.swap.byidx(1)
  end, { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function()
    awful.client.swap.byidx(-1)
  end, { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function()
    awful.screen.focus_relative(1)
  end, { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function()
    awful.screen.focus_relative(-1)
  end, { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, { description = "go back", group = "client" }),

  -- =========================================
  -- CLIENT MINIMIZATION
  -- =========================================

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

  -- =========================================
  -- SPAWN APPLICATION KEY BINDINGS
  -- =========================================

  -- -- dmenu
  -- awful.key({ modkey }, "d", function()
  --     awful.util.spawn("dmenu_run")
  -- end,
  --     { description = "launch dmenu", group = "launcher" }),

  -- Lua prompt
  awful.key({ modkey, "Shift" }, "p", function()
    awful.prompt.run({
      prompt = "Run Lua code: ",
      textbox = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval",
    })
  end, { description = "lua execute prompt", group = "awesome" }),

  -- Terminal
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end, { description = "open a terminal", group = "launcher" }),

  -- firefox
  awful.key({ modkey, "Shift" }, "f", function()
    awful.spawn("firefox")
  end, { description = "Open browser (firefox)", group = "launcher" }),

  -- spotify
  awful.key({ modkey, "Shift" }, "s", function()
    awful.spawn("flatpak run com.spotify.Client")
  end, { description = "Open Spotify", group = "launcher" }),

  -- Ranger
  awful.key({ modkey }, "e", function()
    awful.spawn(terminal .. " -e ranger")
  end, { description = "show the menubar", group = "launcher" }),

  -- Menubar
  awful.key({ modkey }, "d", function()
    menubar.show()
  end, { description = "show the menubar", group = "launcher" }),

  -- =========================================
  -- FUNCTION KEYS
  -- =========================================

  -- Brightness
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn("brightnessctl s +5%", false)
  end, { description = "+5%", group = "hotkeys" }),
  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn("brightnessctl s 5%-", false)
  end, { description = "-5%", group = "hotkeys" }),

  -- Pulseaudio volume control
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
    awesome.emit_signal("volume_change")
  end, { description = "volume up", group = "hotkeys" }),
  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
    awesome.emit_signal("volume_change")
  end, { description = "volume down", group = "hotkeys" }),
  awful.key({}, "XF86AudioMicMute", function()
    awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle", false)
    awesome.emit_signal("volume_change")
  end, { description = "toggle mute microphone", group = "hotkeys" }),
  awful.key({}, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
    awesome.emit_signal("volume_change")
  end, { description = "toggle mute", group = "hotkeys" }),
  awful.key({}, "XF86AudioNext", function()
    awful.spawn("exec playerctl next", false)
  end, { description = "next music", group = "hotkeys" }),
  awful.key({}, "XF86AudioPrev", function()
    awful.spawn("exec playerctl previous", false)
  end, { description = "previous music", group = "hotkeys" }),
  awful.key({}, "XF86AudioPlay", function()
    awful.spawn("playerctl play-pause", false)
  end, { description = "play/pause music", group = "hotkeys" }),
  awful.key({}, "XF86AudioPause", function()
    awful.spawn("playerctl play-pause", false)
  end, { description = "play/pause music", group = "hotkeys" }),

  -- Screenshots
  awful.key({ modkey }, "Print", function()
    awful.util.spawn_with_shell("maim | xclip -selection clipboard -t image/png")
  end, { description = "Screenshot to clipboard", group = "launcher" }),
  awful.key({ modkey, "Shift" }, "Print", function()
    awful.util.spawn_with_shell("maim -s | xclip -selection clipboard -t image/png")
  end, { description = "Screenshot selection to clipboard", group = "launcher" }),

  awful.key({}, "Print", function()
    awful.util.spawn_with_shell('maim "$HOME/Pictures/Screenshot from $(date +%F) $(date +%H-%M-%S).png"')
  end, { description = "Screenshot to file", group = "launcher" }),
  awful.key({ "Shift" }, "Print", function()
    awful.util.spawn_with_shell('maim -s "$HOME/Pictures/Screenshot from $(date +%F) $(date +%H-%M-%S).png"')
  end, { description = "Screenshot selection to file", group = "launcher" })
)

-- =========================================
-- BINDING KEY NUMBERS TO TAGS
-- =========================================

for i = 1, 10 do
  keys.globalkeys = gears.table.join(
    keys.globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
    end, { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

-- ===================================================================
-- CLIENT KEY BINDINGS
-- ===================================================================

keys.clientkeys = gears.table.join(
  -- Handling window states
  awful.key({ modkey }, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "q", function(c)
    c:kill()
  end, { description = "close", group = "client" }),
  awful.key({ modkey }, "o", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
  awful.key({ modkey }, "t", function(c)
    c.ontop = not c.ontop
  end, { description = "toggle keep on top", group = "client" }),

  -- Layout control
  awful.key({ modkey, "Shift" }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" }),
  awful.key({ modkey }, "p", function(c)
    c:move_to_screen()
  end, { description = "move to screen", group = "client" }),

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
  end, { description = "Floating Resize Vertical -", group = "client" }),
  awful.key({ modkey, "Control" }, "Down", function(c)
    if c.floating then
      c:relative_move(0, 0, 0, 10)
    else
      awful.client.incwfact(-0.025)
    end
  end, { description = "Floating Resize Vertical +", group = "client" }),
  awful.key({ modkey, "Control" }, "Left", function(c)
    if c.floating then
      c:relative_move(0, 0, -10, 0)
    else
      awful.tag.incmwfact(-0.025)
    end
  end, { description = "Floating Resize Horizontal -", group = "client" }),
  awful.key({ modkey, "Control" }, "Right", function(c)
    if c.floating then
      c:relative_move(0, 0, 10, 0)
    else
      awful.tag.incmwfact(0.025)
    end
  end, { description = "Floating Resize Horizontal +", group = "client" }),

  -- Moving floating windows
  awful.key({ modkey, "Shift" }, "Down", function(c)
    c:relative_move(0, 10, 0, 0)
  end, { description = "Floating Move Down", group = "client" }),
  awful.key({ modkey, "Shift" }, "Up", function(c)
    c:relative_move(0, -10, 0, 0)
  end, { description = "Floating Move Up", group = "client" }),
  awful.key({ modkey, "Shift" }, "Left", function(c)
    c:relative_move(-10, 0, 0, 0)
  end, { description = "Floating Move Left", group = "client" }),
  awful.key({ modkey, "Shift" }, "Right", function(c)
    c:relative_move(10, 0, 0, 0)
  end, { description = "Floating Move Right", group = "client" }),

  -- Maximize unmaximize
  awful.key({ modkey }, "r", function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "k", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Control" }, "l", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),
  awful.key({ modkey, "Control" }, "h", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),

  -- Moving window focus works between desktops
  awful.key({ modkey }, "j", function(c)
    awful.client.focus.global_bydirection("down")
    c:lower()
  end, { description = "focus next window up", group = "client" }),
  awful.key({ modkey }, "k", function(c)
    awful.client.focus.global_bydirection("up")
    c:lower()
  end, { description = "focus next window down", group = "client" }),
  awful.key({ modkey }, "l", function(c)
    awful.client.focus.global_bydirection("right")
    c:lower()
  end, { description = "focus next window right", group = "client" }),
  awful.key({ modkey }, "h", function(c)
    awful.client.focus.global_bydirection("left")
    c:lower()
  end, { description = "focus next window left", group = "client" }),

  -- Moving windows between positions works between desktops
  awful.key({ modkey, "Shift" }, "h", function(c)
    awful.client.swap.global_bydirection("left")
    c:raise()
  end, { description = "swap with left client", group = "client" }),
  awful.key({ modkey, "Shift" }, "l", function(c)
    awful.client.swap.global_bydirection("right")
    c:raise()
  end, { description = "swap with right client", group = "client" }),
  awful.key({ modkey, "Shift" }, "j", function(c)
    awful.client.swap.global_bydirection("down")
    c:raise()
  end, { description = "swap with down client", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function(c)
    awful.client.swap.global_bydirection("up")
    c:raise()
  end, { description = "swap with up client", group = "client" })
)

keys.clientbuttons = gears.table.join(
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

return keys
