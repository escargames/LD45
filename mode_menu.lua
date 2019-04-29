mode.menu = {}

function mode.menu.start()
    main = true
    cursor_x = 36
    cursor_y = {50, 64, 78}
    levels = {"Blablabla", "Hihihi", "Prout"}
    pos = 1
end

function mode.menu.update()
    local max = main and #cursor_y or #levels
    pos += ((btnp(2) and (pos > 1) and -1) or (btnp(3) and (pos < max) and 1 or 0))
    cursor_x = main and 36 or 61

    if pos == 1 and (btnp(4) or btnp(1)) and main then
        main = false
    elseif main == false and btnp(4) then
        state = "test"
    elseif main == false and (btnp(5) or btnp(0)) then
        pos = 1
        main = true
    end
end

function mode.menu.draw()
    cls(3)
    draw_menu_ui()
    font_outline(1)
    print("Cute Little Game", 12, 8, 8)
    print("by Niarkou and Sam", 28, 18, 15)
    print("Play", 5, cursor_y[1], (pos == 1 and main and 9 or 12))
    print("Help", 5, cursor_y[2], (pos == 2 and main and 9 or 12))
    print("About", 5, cursor_y[3], (pos == 3 and main and 9 or 12))
    draw_menu_play()
    draw_menu_help()
    draw_menu_debug()
    font_outline()
end

function draw_menu_ui()
    palt(0, false)
    map(0, 48, 0, 0, 16, 16)
    palt(5, true)
    spr(64, cursor_x, cursor_y[pos])
    palt()
end

function draw_menu_play()
    if main and pos == 1 or (not main) then
        print("Levels", 70, 35, 9)
        for i = 1, #levels do
            print(levels[i], 75, 35 + 16*i, pos == i and not main and 9 or 11)
        end
    end
end

function draw_menu_help()
    if main and pos==2 then
        print("Controls", 68, 35, 9)
        print("arrows: move", 60, cursor_y[1], 12)
        print("W or Z: shoot", 60, cursor_y[2], 12)
        print("X: action", 60, cursor_y[3], 12)
    elseif main and pos==3 then
        print("About", 68, 35, 9)
        print("A tiny game", 60, cursor_y[1], 12)
        print("made by Sam", 60, cursor_y[1] + 10, 12)
        print("and Niarkou", 60, cursor_y[1] + 20, 12)
        print("in 72h, for", 60, cursor_y[1] + 30, 12)
        print("LD Jam 44!", 60, cursor_y[1] + 40, 12)
    end
end

function draw_menu_debug()

end
