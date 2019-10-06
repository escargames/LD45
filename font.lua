
do
    local data =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
        "abcdefghijklmnopqrstuvwxyz"..
        "0123456789.,:;?!\"-'()="
    local widths = {
        4,4,4,4,4,4,4,4,1,3,4,4,5,5,5,4,5,4,4,5,4,5,7,5,5,4,
        4,4,3,4,4,2,4,4,1,2,4,1,5,4,4,4,4,3,3,2,4,5,5,4,4,4,
        4,2,4,4,4,4,4,4,4,4,1,2,1,2,4,1,3,4,1,2,2,3,
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
        local old1,old2 = peek4(0x5f00),peek4(0x5f04)
        if outline>0 then
            for i=1,7 do pal(i,max(1,i-5)) end
            pal(7,1)
            local function sspr2(sx, sy, sw, sh, x, y)
                sspr(sx, sy, sw, sh, x-1, y)
                sspr(sx, sy, sw, sh, x+1, y)
                sspr(sx, sy, sw, sh, x, y-1)
                sspr(sx, sy, sw, sh, x, y+1)
            end
            do_work(x0, y, sspr2)
        end
        pal(7,c)
        do_work(x0, y, sspr)
        poke4(0x5f00,old1)poke4(0x5f04,old2)
    end
    function font_outline(s) outline=s or 0 end
end

