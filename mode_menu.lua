function mode.menu.start()
    cursor_x = {50, 65}
    pos = 1
end

function mode.menu.update()
    pos += ((btnp(2) and (pos > 1) and -1) or (btnp(3) and (pos < #cursor_x) and 1 or 0))
end

function mode.menu.draw()
    cls()
    csprint("ld44", 30, 9, 11)
    csprint("play", cursor_x[1], 6, (pos == 1 and 9 or 11))
    csprint("buttons", cursor_x[2], 6, (pos == 2 and 9 or 11))
    draw_menu_ui()
    draw_menu_debug()
end

function draw_menu_ui()
    line(40, cursor_x[pos], 40, cursor_x[pos] + 4, 11)
end

function draw_menu_debug()

end
