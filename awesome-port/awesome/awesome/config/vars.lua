local _M = {}

local awful = require'awful'

_M.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.spiral,
}

_M.tags = {'1', '2', '3', '4', '5'}

return _M
