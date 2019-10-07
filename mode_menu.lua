mode.menu = {}

function mode.menu.start()
end

function mode.menu.update()
    if btnp(4) then
        state = "play"
    end
end

function mode.menu.draw()
    cls(1)
    font_outline(0)
    print("The Legend\n of Nothing", 14, 28, 8, 2)
    print("by Niarkou and Sam", 34, 64, 15)
    if time()%1<0.5 then
        print("Press 🅾️ to start", 35, 80, 15)
    end
    font_outline()
end

