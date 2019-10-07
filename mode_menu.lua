mode.menu = {}

function mode.menu.start()
    create_maze(60,4,20,20)
    palette(0)
end

function mode.menu.update()
    if btnp(4) then
        state = "play"
    end
end

function mode.menu.draw()
    cls(13)
    map(62,6,0,0,16,16)
    for i=1,50 do x=rnd(200) y=rnd(128) line(x,y-32,x-20,y+52,ccrnd({13,7})) end

    font_outline(1)
    print("The Legend\n of Nothing", 14, 28, 8, 2)
    print("by Niarkou and Sam", 34, 64, 15)
    if time()%1<0.5 then
        print("Press 🅾️ to start", 30, 100, 11)
    end
    font_outline()
end

