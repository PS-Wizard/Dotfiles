local _M = {}

local awful = require'awful'
local beautiful = require'beautiful'
local wibox = require'wibox'

local apps = require 'config.apps'
local mod = require 'bindings.mod'

_M.textclock = wibox.widget.textclock()

function _M.create_promptbox() return awful.widget.prompt() end

function _M.create_taglist(s)
   return awful.widget.taglist{
      screen = s,
      filter = awful.widget.taglist.filter.all,
      buttons = {
         awful.button{
            modifiers = {},
            button    = 1,
            on_press  = function(t) t:view_only() end,
         },
         awful.button{
            modifiers = {mod.super},
            button    = 1,
            on_press  = function(t)
               if client.focus then
                  client.focus:move_to_tag(t)
               end
            end,
         },
         awful.button{
            modifiers = {},
            button    = 3,
            on_press  = awful.tag.viewtoggle,
         },
         awful.button{
            modifiers = {mod.super},
            button    = 3,
            on_press  = function(t)
               if client.focus then
                  client.focus:toggle_tag(t)
               end
            end
         },
         awful.button{
            modifiers = {},
            button    = 4,
            on_press  = function(t) awful.tag.viewprev(t.screen) end,
         },
         awful.button{
            modifiers = {},
            button    = 5,
            on_press  = function(t) awful.tag.viewnext(t.screen) end,
         },
      }
   }
end

function _M.create_battery_widget()
   return wibox.widget {
      {   
         id = 'battery_icon',
         widget = wibox.widget.imagebox,
         image = beautiful.battery_icon
      },
      {   
         id = 'battery_text',
         widget = wibox.widget.textbox,
         text = "100%",
      },
      layout = wibox.layout.fixed.horizontal,
   }
end

function _M.create_wibox(s)
   s.promptbox = _M.create_promptbox()
   s.taglist = _M.create_taglist(s)

   return awful.wibar{
      screen = s,
      position = 'top',
      widget = {
         layout = wibox.layout.align.horizontal,
         -- left widgets
         {
            layout = wibox.layout.fixed.horizontal,
            _M.create_battery_widget(),
         },
         -- middle widgets
         {
            layout = wibox.layout.fixed.horizontal,
            expand = "outside",
            s.taglist,
            s.promptbox,
         },
         -- right widgets
         {
            layout = wibox.layout.fixed.horizontal,
            _M.textclock,
         }
      }
   }
end

return _M
