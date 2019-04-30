mode.menu = {}
-- print 

function foprint(text,x,y,col,toff,dur)
	if (time()*4-toff)%dur<.5 then
		print(text,x,y+1,col)
	else
		print(text,x,y,col)
	end
end

-------------

seed = 1

function mode.menu.start()
    main = true
    cursor_x = 36
    cursor_y = {50, 64, 78}
    cursor_y_nm = {50, 70}
    pos = 1
end

function mode.menu.update()
    local max = main and #cursor_y or 2
    pos += ((btnp(2) and (pos > 1) and -1) or (btnp(3) and (pos < max) and 1 or 0))
    cursor_x = main and 36 or 61

    if pos == 1 and btnp(4) and main then
        main = false
    elseif main == false and btnp(4) and pos == 1 then
        state = "test"
    elseif main == false and btnp(5) then
        pos = 1
        main = true
    elseif main == false then
        seed += ((btnp(0) and (tonum(seed) > 1) and -1) or (btnp(1) and 1 or 0))
    end
end

function mode.menu.draw()
    cls(3)
    draw_menu_ui()
    font_outline(1)
    print("Finding Cookie", 12, 8, 8)
    print("by Niarkou and Sam", 28, 18, 15)
    print("Game", 5, cursor_y[1], (pos == 1 and main and 9 or 12))
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
    palt(15, true)
    map(16, 48, 0, 0, 16, 16)
    palt(15, false)
    palt(5, true)
    if t() * 3 % 1 > 0.4 then
        if main then
            spr(64, cursor_x, cursor_y[pos])
        else
            spr(64, cursor_x, cursor_y_nm[pos])
        end
    end
    palt()
end

function draw_menu_play()
    if main and pos == 1 or (not main) then
        print("Play!", 80, 50, pos == 1 and not main and 9 or 11)
        print("Seed:", 80, 70, pos == 2 and not main and 9 or 11)
        while #tostr(seed) < 5 do seed = "0"..seed end
        print(tostr(seed), 79, 81, 9)
        if not main and pos == 2 then
            foprint("⬅️", 70, 81, 13, 0, 2)
            foprint("➡️", 108, 81, 13, 1, 2)
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
