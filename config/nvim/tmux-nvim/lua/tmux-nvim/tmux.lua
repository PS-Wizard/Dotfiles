local M = {}

function M.is_agent_pane(pane)
  return pane.marker ~= nil
end

function M.is_inside()
  local t = vim.env.TMUX
  return t ~= nil and t ~= ""
end

function M.list_panes()
  if not M.is_inside() then return nil, "not inside tmux (no $TMUX)" end
  local r = vim.system({ "tmux", "list-panes", "-a", "-F", "#{pane_id}|#{window_index}|#{pane_index}|#{pane_current_command}|#{pane_title}|#{pane_active}|#{session_name}|#{window_name}|#{@agent_marker}" }, { text = true }):wait()
  if r.code ~= 0 then
    return nil, "tmux list-panes failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
  end
  local out = {}
  for line in r.stdout:gmatch("[^\n]+") do
    local pane_id, win_idx, pane_idx, cmd, title, active, sess, win, marker = line:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)")
    if pane_id then
      local pane = {
        pane_id = pane_id,
        window_index = win_idx,
        pane_index = pane_idx,
        command = cmd,
        title = title,
        active = active == "1",
        session = sess,
        window = win,
        marker = marker ~= "" and marker or nil,
        raw = line,
      }
      pane.is_agent = M.is_agent_pane(pane)
      if pane.marker then
        table.insert(out, pane)
      end
    end
  end
  if #out == 0 then return nil, "no marked tmux panes (Prefix+Enter to mark)" end
  table.sort(out, function(a, b)
    if a.active ~= b.active then return not a.active end
    return a.marker < b.marker
  end)
  return out
end

function M.display(pane)
  local active = pane.active and "●" or "○"
  local cmd = pane.command ~= "" and (" · " .. pane.command) or ""
  return string.format("%s %s%s", active, pane.marker, cmd)
end

-- unambiguous resolve: smart scoping to agent title (pi sets /tmp/pi-clipboard-*.png).
-- Mirrors herdr-nvim's tab-scoped resolve: narrowest unambiguous match wins.
function M.resolve(list)
  if #list == 1 then return list[1] end
  -- single agent pane in workspace -> unambiguous (common: one pi pane)
  local agents = {}
  for _, p in ipairs(list) do if p.is_agent then table.insert(agents, p) end end
  if #agents == 1 then return agents[1] end
  local cur = vim.env.TMUX_PANE
  if cur then
    local others = {}
    for _, p in ipairs(list) do if p.pane_id ~= cur then table.insert(others, p) end end
    if #others == 1 then return others[1] end
    -- single non-current agent pane -> even with many panes, target is clear
    local other_agents = {}
    for _, p in ipairs(list) do if p.is_agent and p.pane_id ~= cur then table.insert(other_agents, p) end end
    if #other_agents == 1 then return other_agents[1] end
  end
  return nil
end

function M.pick(panes, on_choice)
  if #panes == 0 then
    vim.notify("tmux-nvim: no marked tmux panes (Prefix+Enter to mark)", vim.log.levels.WARN)
    return
  end
  local ok_fzf, fzf = pcall(require, "fzf-lua")
  if ok_fzf and fzf and fzf.fzf_exec then
    local items = {}
    local map = {}
    for _, p in ipairs(panes) do
      local d = M.display(p)
      table.insert(items, d)
      map[d] = p
    end
    fzf.fzf_exec(items, {
      prompt = "Tmux pane> ",
      winopts = { title = " tmux panes ", height = 0.4, width = 0.6 },
      actions = {
        ["default"] = function(selected)
          if selected and selected[1] then
            local p = map[selected[1]]
            if p then on_choice(p) end
          end
        end,
      },
    })
    return
  end
  -- fallback: vim.ui.select
  vim.ui.select(panes, { prompt = "Send to tmux pane", format_item = M.display }, function(p)
    if p then on_choice(p) end
  end)
end

return M
