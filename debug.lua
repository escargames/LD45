
do
    local old_draw = _draw
    local cpu_hist = {}
    local on=false
    local c=0

    function _draw()
        old_draw()

        if btnp(1,1) then
            game.inventory.nkeys = 3
            game.inventory.boots = true
            game.inventory.gloves = true
            game.inventory.can = true
            game.inventory.suit = true
            game.inventory.ball = true
        end
        if btnp(3,1) then on = not on end
        if not on then return end

        c=c%2+0.5
        --font_outline(1)
        pico8_print(stat(7).." fps", 99, 26, c)
        if game then
            pico8_print("x="..game.player.x, 2, 2, c)
            pico8_print("y="..game.player.y, 2, 10, c)
            pico8_print("dead="..tostr(game.player.dead), 2, 18, c)
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
        pico8_print("cpu="..ceil(cpu), 99, 12, c)
        pico8_print("max="..ceil(max_cpu), 99, 19, c)
        --font_outline()
    end
end

