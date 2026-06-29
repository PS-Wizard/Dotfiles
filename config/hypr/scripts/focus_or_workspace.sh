#!/bin/sh

dir="$1"
ws="$2"

active=$(hyprctl -j activewindow)
target=$(hyprctl -j clients | jq -r --argjson active "$active" --arg dir "$dir" '
  [ .[]
    | select(.mapped)
    | select(.address != $active.address)
    | select(.workspace.id == $active.workspace.id)
    | select(.monitor == $active.monitor)
    | . as $w
    | ($active.at[0]) as $ax1
    | ($active.at[0] + $active.size[0]) as $ax2
    | ($active.at[1]) as $ay1
    | ($active.at[1] + $active.size[1]) as $ay2
    | ($w.at[0]) as $wx1
    | ($w.at[0] + $w.size[0]) as $wx2
    | ($w.at[1]) as $wy1
    | ($w.at[1] + $w.size[1]) as $wy2
    | ($active.fullscreenClient > 0 and ($dir == "d" or $dir == "u")) as $fullscreen_vertical
    | if $fullscreen_vertical then
        select(($dir == "d" and $wy1 > $ay1) or ($dir == "u" and $wy1 < $ay1))
        | {
            address: .address,
            primary: (if $dir == "d" then ($wy1 - $ay1) else ($ay1 - $wy1) end),
            secondary: (((($wx1 + $wx2) / 2) - (($ax1 + $ax2) / 2)) | abs)
          }
      elif $dir == "d" then
        select(.visible)
        | select(([ $ax2, $wx2 ] | min) > ([ $ax1, $wx1 ] | max))
        | select($wy1 >= $ay2)
        | {
            address: .address,
            primary: ($wy1 - $ay2),
            secondary: (((($wx1 + $wx2) / 2) - (($ax1 + $ax2) / 2)) | abs)
          }
      elif $dir == "u" then
        select(.visible)
        | select(([ $ax2, $wx2 ] | min) > ([ $ax1, $wx1 ] | max))
        | select($wy2 <= $ay1)
        | {
            address: .address,
            primary: ($ay1 - $wy2),
            secondary: (((($wx1 + $wx2) / 2) - (($ax1 + $ax2) / 2)) | abs)
          }
      elif $dir == "l" then
        select(.visible)
        | select(([ $ay2, $wy2 ] | min) > ([ $ay1, $wy1 ] | max))
        | select($wx2 <= $ax1)
        | {
            address: .address,
            primary: ($ax1 - $wx2),
            secondary: (((($wy1 + $wy2) / 2) - (($ay1 + $ay2) / 2)) | abs)
          }
      else
        select(.visible)
        | select(([ $ay2, $wy2 ] | min) > ([ $ay1, $wy1 ] | max))
        | select($wx1 >= $ax2)
        | {
            address: .address,
            primary: ($wx1 - $ax2),
            secondary: (((($wy1 + $wy2) / 2) - (($ay1 + $ay2) / 2)) | abs)
          }
      end
  ]
  | sort_by(.primary, .secondary)
  | .[0].address // empty
')

if [ -n "$target" ]; then
    hyprctl dispatch "hl.dsp.focus({window='address:${target}'})" >/dev/null 2>&1
elif [ -n "$ws" ]; then
    hyprctl dispatch "hl.dsp.focus({workspace='${ws}'})" >/dev/null 2>&1
fi
