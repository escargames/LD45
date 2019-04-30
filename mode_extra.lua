mode.gameover = {}

function mode.gameover.start()
    animation = 0
end

function mode.gameover.update()
    animation += 1/60
    if cbtnp(g_btn_confirm) then
        state = "menu"
    end
end

function mode.gameover.draw()
    local dx = flr(min(animation, 1) * 48)
    local dy = flr(min(animation, 1) * 36)
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 4)
    dx -= 4 dy -= 3
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 9)
    if animation >= 1.5 then
        font_outline(1)
        print("Game Over", 30, 50, 10)
    end
end

