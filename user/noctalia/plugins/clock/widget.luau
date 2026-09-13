local month = {
  "Jan",
  "Fév",
  "Mar",
  "Avr",
  "Mai",
  "Jun",
  "Jul",
  "Aou",
  "Sép",
  "Oct",
  "Nov",
  "Déc",
}
local wday = {
  "日",
  "月",
  "火",
  "水",
  "木",
  "金",
  "土",
}

local function do_update()
  local d = os.date "*t"
  barWidget.setText(("%s %d  %02d:%02d  %s"):format(month[d.month], d.day, d.hour, d.min, wday[d.wday]))
  barWidget.setTooltip(noctalia.formatTime "%c")
end

-- noctalia.setUpdateInterval(noctalia.nowMs() % 60_000)
-- update = function()
--   do_update()
--   noctalia.setUpdateInterval(60_000)
--   update = do_update
-- end

noctalia.setUpdateInterval(1000)
update = do_update
