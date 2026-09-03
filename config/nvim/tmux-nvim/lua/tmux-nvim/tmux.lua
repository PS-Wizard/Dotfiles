local M = {}

-- AI agents this plugin recognizes. Names are matched as words in the pane
-- title and as the pane's current command. Extend the list as needed.
M.AGENTS = {
  "pi", "cursor", "fx", "codex", "opencode", "claude", "gemini",
  "copilot", "aider", "droid", "amp", "grok", "kimi", "kilocode",
  "cline", "qwen", "goose", "crush", "hermes", "kiro", "devin",
}

-- pi sets OSC title to /tmp/pi-clipboard-*.png or similar, so pane_title is
-- the strongest signal; each agent gets its own title hint below.
M.TITLE_HINTS = {
  "/tmp/pi", "pi-clipboard",
}

function M.agent_name(pane)
  local title = (pane.title or ""):lower()
  local cmd = (pane.command or ""):lower()
  for _, name in ipairs(M.AGENTS) do
    if cmd == name or cmd:find("^" .. name .. "[%-%.]") or title:find("%f[%a]" .. name .. "%f[%A]") then
      return name
    end
  end
  for _, hint in ipairs(M.TITLE_HINTS) do
    if title:find(hint:lower(), 1, true) then
      return "pi"
    end
  end
  return nil
end

function M.is_agent_pane(pane)
  return M.agent_name(pane) ~= nil
end

function M.is_inside()
  local t = vim.env.TMUX
  return t ~= nil and t ~= ""
end

function M.list_panes()
  if not M.is_inside() then return nil, "not inside tmux (no $TMUX)" end
  local r = vim.system({ "tmux", "list-panes", "-a", "-F", "#{pane_id}|#{window_index}|#{pane_index}|#{pane_current_command}|#{pane_title}|#{pane_active}|#{session_name}|#{window_name}" }, { text = true }):wait()
  if r.code ~= 0 then
    return nil, "tmux list-panes failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
  end
  local out = {}
  for line in r.stdout:gmatch("[^\n]+") do
    local pane_id, win_idx, pane_idx, cmd, title, active, sess, win = line:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)")
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
        raw = line,
      }
      pane.is_agent = M.is_agent_pane(pane)
      table.insert(out, pane)
    end
  end
  if #out == 0 then return nil, "no tmux panes found" end
  -- smart sort: agent panes first, then non-active before active, then pane_id
  table.sort(out, function(a, b)
    if a.is_agent ~= b.is_agent then return a.is_agent end
    if a.active ~= b.active then return not a.active end
    return a.pane_id < b.pane_id
  end)
  return out
end

function M.display(pane)
  local active = pane.active and "●" or "○"
  local loc = string.format("%s:%s.%s", pane.session, pane.window_index, pane.pane_index)
  local title = pane.title ~= "" and pane.title or pane.command
  local agent = M.agent_name(pane)
  if title:find("/tmp/pi", 1, true) or agent == "pi" then
    title = vim.fn.fnamemodify(title, ":t") .. " [pi]"
  elseif agent then
    title = title .. " [" .. agent .. "]"
  end
  local win = pane.window ~= "" and (" " .. pane.window) or ""
  return string.format("%s %s · %s%s · %s", active, pane.pane_id, loc, win, title)
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
    vim.notify("tmux-nvim: no tmux panes found", vim.log.levels.WARN)
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
