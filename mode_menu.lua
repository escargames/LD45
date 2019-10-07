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
    font_outline()
end

