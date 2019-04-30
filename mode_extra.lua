mode.gameover = {}

function mode.gameover.start()
    animation = 0
end

function mode.gameover.update()
    animation += 1/60
    if (animation > 2) and cbtnp(g_btn_confirm) then
        state = "menu"
    end
end

function mode.gameover.draw()
    local dx = flr(min(animation, 1) * 56)
    local dy = flr(min(animation, 1) * 36)
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 4)
    dx -= 4 dy -= 3
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 9)

    font_outline(1)
    if animation >= 1.2 then
        print("Game Over", 40, 38, 8)
    end
    if animation >= 1.5 then
        print("You did well !", 26, 52, 15)
        print("Alas, Cookie was", 16, 64, 15)
        print("nowhere to be found.", 16, 74, 15)
        print("Maybe next time?", 16, 84, 15)
    end
    font_outline()
end

