
do
    local data =
        ".,:;\"-()"..
        "0123456789"..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
        "?!'"..
        "abcdefghijklmnopqrstuvwxyz"
    local widths = {
        2,2,2,2,3,4,3,3,
        5,3,5,5,5,5,5,5,5,5,
        5,5,5,5,5,5,5,5,2,4,6,4,7,6,6,5,6,5,4,6,5,6,7,6,6,5,
        5,2,1,
        5,5,4,5,5,3,5,5,2,3,5,2,8,5,5,5,5,4,4,3,5,5,7,5,5,5,
    }
    local x0,y0 = 48,40
    local params = {}
    local outline = 0

    for i=1,#data do
        local w = widths[i]
        if x0 + w > 128 then
            y0 += 8
            x0 = 0
        end
        params[sub(data,i,i)] = { x=x0, y=y0, w=w }
        x0 += w
    end

    pico8_print = print
    function print(str, x0, y, c)
        local function do_work(x0, y, blit)
            local x = x0
            for i=1,#str do
                local ch = sub(str,i,i)
                local param = params[ch]
                if ch==" " then
                    x += 3
                elseif ch=="\n" then
                    x = x0
                    y += 8
                elseif param then
                    blit(param.x, param.y, param.w, 8, x, y)
                    x += param.w + 1
                end
            end
        end
        if outline>0 then
            local old1,old2 = peek4(0x5f10),peek4(0x5f14)
            pal(7,1)
            do_work(x0+1, y, sspr)
            do_work(x0-1, y, sspr)
            do_work(x0, y+1, sspr)
            do_work(x0, y-1, sspr)
            pal(7,c)
            poke4(0x5f10,old1)poke4(0x5f14,old2)
        end
        do_work(x0, y, sspr)
    end
    function font_outline(s) outline=s end
end

