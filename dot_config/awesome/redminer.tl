-- #!/usr/bin/env lua

local record AwesomeWidget
  foreground: string
  text: string
end


local function displaytime(timestamp: integer): string
  timestamp = math.floor(timestamp / 60)
  local minutes =  timestamp % 60
  timestamp = math.floor(timestamp / 60)
  local hours =    timestamp

  return string.format("%02dh %02dm", hours, minutes)
end

local function get_stats(total_left: integer, running: integer, suspended: integer, staged: integer, current_ticket: string): string
  local prefix = ""

  if current_ticket then
    prefix = current_ticket .. " "
  end
    
  return string.format("%s%s left [%d/%d/%d]", prefix, displaytime(total_left), running, suspended, staged)
end

function string.split(self: string, delimiter: string): {string}
  local out = {}

  for word in self:gmatch("([^" .. delimiter .. "]+)") do
    table.insert(out, word)
  end

  return out
end

local function main(): AwesomeWidget
  local redminer_out = io.popen("redminer timer status date today all porcelain"):read("*line")
  local total_wasted_s, running_s, suspended_s, staged_s, current_ticket = table.unpack(redminer_out:split(";"))
  local total_wasted = math.floor(tonumber(total_wasted_s))
  local running = math.floor(tonumber(running_s))
  local suspended = math.floor(tonumber(suspended_s))
  local staged = math.floor(tonumber(staged_s))
  local total_left = 8 * 3600 - total_wasted
  local foreground: string

  if suspended > 0 then
    foreground = "yellow"
  end

  if running > 0 then
    foreground = "red"
  end

  if total_left > 0 then
      return { foreground = foreground, text = get_stats(total_left, running, suspended, staged, current_ticket) }
  end
end

local widget = main()

if widget then
  if widget.foreground then
    print(string.format('<span foreground="%s">%s</span>', widget.foreground, widget.text))
  else
    print(string.format('<span>%s</span>', widget.text))
  end
end
