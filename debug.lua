
local old_draw = _draw
local cpu_hist = {}

function _draw()
    old_draw()

    font_outline(1)
    print(stat(7).." fps", 89, 26, 8)
    if game then
        print("x="..game.player.x, 2, 2, 11)
        print("y="..game.player.y, 2, 10, 11)
    end
    local cpu = 100*stat(1)
    local max_cpu = cpu
    add(cpu_hist, cpu)
    if #cpu_hist > 50 then
        for i=1,50 do
            cpu_hist[i] = cpu_hist[i+1]
            max_cpu = max(max_cpu, cpu_hist[i])
        end
        cpu_hist[51] = nil
    end
    print("cpu="..ceil(cpu), 89, 12, 14)
    print("max="..ceil(max_cpu), 89, 19, 8)
    font_outline()
end

