
messages = {}

function messages.update()
    -- compute stuff
    if not game.msg.wanted_h then
        game.msg.wanted_h = 6 + 8
        for i=1,#game.msg.text do if sub(game.msg.text,i,i)=="\n" then game.msg.wanted_h += 8 end end
        game.msg.cursor = ""
        game.msg.open = 0
        game.msg.h = 0
    end

    if game.msg.close then
        game.msg.close += 1/20
        if game.msg.close > 1 then game.msg = {} return end
        game.msg.h = game.msg.wanted_h * (1 - game.msg.close)
    elseif game.msg.wait then
        game.msg.wait += 1/30
        game.msg.cursor = ""
        if cbtnp(4) then game.msg.close = 0 end
    elseif game.msg.display then
        game.msg.display += (btn(4) and 1.5 or .3)
        if game.msg.display >= #game.msg.text then game.msg.wait = 0 end
        game.msg.cursor = game.msg.display % 6 < 4 and "█" or ""
        game.msg.h = game.msg.wanted_h
    elseif game.msg.open then
        game.msg.open += 1/30
        if game.msg.open > 1 then game.msg.display = 0 end
        game.msg.h = game.msg.wanted_h * game.msg.open
    end
end

function messages.draw()
    local m = 2 -- margin
    local h = game.msg.h
    if h then
        smoothrectfill(m, 127 - h - m, 127 - m, 127 - m, 5, 15)
        smoothrect(m, 127 - h - m, 127 - m, 127 - m, 5, 1)
        smoothrect(m + 2, 127 - h - m + 2, 127 - m - 2, 127 - m - 2, 3, 14)
    end
    if game.msg.display then
        clip(m + 2, 127 - h - m + 2, 127 - 2 * m - 4, h - 4)
        local i = game.msg.display
        print(sub(game.msg.text,1,i)..game.msg.cursor, m + 4, 127 - h - m + 4)
        clip()
    end
    if game.msg.wait then
        if game.msg.wait % 1 > .4 then
            print("⬇️", 127 - m - 11, 127 - m - 9)
        end
    end
end

