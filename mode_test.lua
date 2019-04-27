function mode.test.update()
    if cbtnp(g_btn_confirm) then
        state = "menu"
    end
    game.player.x += (btn(0) and -1 or (btn(1) and 1 or 0)) / 8
    game.player.y += (btn(2) and -1 or (btn(3) and 1 or 0)) / 8
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    draw_world()
    draw_player()
    camera()

    draw_ui()
    --draw_debug()
end


