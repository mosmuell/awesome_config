-------------------------------------------------
-- Pipewire Volume Widget for Awesome Window Manager
-- Shows the volume status using the pactl tool
--
-- This script was inspired by
-- https://github.com/vivien/i3blocks-contrib/tree/master/volume-pipewire
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volume-widget

-- @author Mose Mueller
-- @copyright 2022 Mose Mueller
-------------------------------------------------

local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

local HOME = os.getenv("HOME")
local PATH_TO_ICONS = HOME .. '/.config/awesome/icons/'
local PATH_TO_VOLUME_ICONS = PATH_TO_ICONS .. "/volume/"

-- local sink_name
local sink_description
local sink_volume
local sink_muted
local volume_icon_name

local volume_widget = {}
local function worker(user_args)
    local args = user_args or {}

    local font = args.font or 'DejaVuSansMono Nerd Font 12'
    local path_to_icons = PATH_TO_VOLUME_ICONS
    local margin_left = args.margin_left or 0
    local margin_right = args.margin_right or 0

    local display_notification = args.display_notification or true
    local display_notification_onClick = args.display_notification_onClick or true
    local position = args.notification_position or "top_right"
    local timeout = args.timeout or 0.5

    if not gfs.dir_readable(path_to_icons) then
        naughty.notify {
            title = "Volume Widget",
            text = "Folder with icons doesn't exist: " .. path_to_icons,
            preset = naughty.config.presets.critical
        }
    end

    local icon_widget = wibox.widget {
        {
            id = "icon",
            widget = wibox.widget.imagebox,
            resize = true
        },
        -- valign = 'center',
        -- layout = wibox.container.place,
        layout = wibox.container.margin,
        top = 5,
        bottom = 5,
    }
    local level_widget = wibox.widget {
        font = font,
        widget = wibox.widget.textbox
    }

    volume_widget = wibox.widget {
        icon_widget,
        level_widget,
        layout = wibox.layout.fixed.horizontal,
    }
    local notification
    local function show_volume_status(volumeType)
        naughty.destroy(notification)
        notification = naughty.notify {
            text = "Volume: " .. sink_volume .. "%",
            title = sink_description,
            icon = path_to_icons .. volumeType .. ".svg",
            icon_size = dpi(16),
            position = position,
            timeout = 5, hover_timeout = 0.5,
            width = 200,
            screen = mouse.screen
        }
    end

    watch([[sh -c 'pactl list sinks  |  grep "Name: $(pactl get-default-sink)" -A7 | grep "Name:\|Description: \|Volume: \(front-left\|mono\)\|Mute:"']]
        , timeout,
        function(widget, stdout)
            for line in stdout:gmatch("[^\r\n]+") do
                -- if line:match("Name: ") then
                --     sink_name = string.sub(line, string.find(line, ":") + 2)
                -- end
                if line:match("Description") then
                    sink_description = string.sub(line, string.find(line, ":") + 2)
                end
                if line:match("Volume") then
                    sink_volume = tonumber(string.sub(string.match(line, "[0-9]*%%"), 1, -2))
                    level_widget.markup = " " .. sink_volume .. "% "
                end
                if line:match("Mute") then
                    sink_muted = string.sub(line, string.find(line, ":") + 2)
                end
            end

            if sink_muted == "no" then
                if (sink_volume >= 0 and sink_volume < 10) then volume_icon_name = "audio-volume-very-low-symbolic"
                elseif sink_volume < 50 then volume_icon_name = "audio-volume-low-symbolic"
                elseif sink_volume < 90 then volume_icon_name = "audio-volume-medium-symbolic"
                else volume_icon_name = "audio-volume-high-symbolic"
                end
            else
                volume_icon_name = 'audio-volume-muted-symbolic'
            end

            -- Update popup text
            -- battery_popup.text = string.gsub(stdout, "\n$", "")
            widget.icon:set_image(PATH_TO_VOLUME_ICONS .. volume_icon_name .. ".svg")
        end,
        icon_widget)

    if display_notification then
        volume_widget:connect_signal("mouse::enter", function() show_volume_status(volume_icon_name) end)
        volume_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
    elseif display_notification_onClick then
        volume_widget:connect_signal("button::press", function(_, _, _, button)
            if (button == 1) then show_volume_status(volume_icon_name) end
            if (button == 3) then show_volume_status(volume_icon_name) end
        end)
        volume_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
    end

    return wibox.container.margin(volume_widget, margin_left, margin_right)
end

return setmetatable(volume_widget, { __call = function(_, ...) return worker(...) end })
