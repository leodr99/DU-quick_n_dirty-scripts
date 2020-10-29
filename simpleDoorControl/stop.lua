--[[unit.stop()]]
for i=1, #screens do
    screens[i].deactivate()
end
for i=1, #doors do
    doors[i].deactivate()
end
