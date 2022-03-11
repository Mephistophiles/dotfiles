local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local io = _tl_compat and _tl_compat.io or io; local math = _tl_compat and _tl_compat.math or math; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local _tl_table_unpack = unpack or table.unpack

local AwesomeWidget = {}





local function displaytime(timestamp)
   timestamp = math.floor(timestamp / 60)
   local minutes = timestamp % 60
   timestamp = math.floor(timestamp / 60)
   local hours = timestamp

   return string.format("%02dh %02dm", hours, minutes)
end

local function get_stats(total_left, running, suspended, staged, current_ticket)
   local prefix = ""

   if current_ticket then
      prefix = current_ticket .. " "
   end

   return string.format("%s%s left [%d/%d/%d]", prefix, displaytime(total_left), running, suspended, staged)
end

function string.split(self, delimiter)
   local out = {}

   for word in self:gmatch("([^" .. delimiter .. "]+)") do
      table.insert(out, word)
   end

   return out
end

local function main()
   local redminer_out = io.popen("redminer timer status date today all porcelain"):read("*line")
   local total_wasted_s, running_s, suspended_s, staged_s, current_ticket = _tl_table_unpack(redminer_out:split(";"))
   local total_wasted = math.floor(tonumber(total_wasted_s))
   local running = math.floor(tonumber(running_s))
   local suspended = math.floor(tonumber(suspended_s))
   local staged = math.floor(tonumber(staged_s))
   local total_left = 8 * 3600 - total_wasted
   local foreground

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
