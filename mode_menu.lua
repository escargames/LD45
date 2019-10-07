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
    print("The Legend of Nothing", 12, 28, 8)
    print("by Niarkou and Sam", 28, 38, 15)
    font_outline()
end

