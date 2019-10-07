
function msave(p,n)
    local m={}
    for i=1,n/4 do m[i]=peek4(p+(i-1)*4) end
    m.restore = function(p2)
        p2 = p2 or p
        for i=1,#m do poke4(p+(i-1)*4,m[i]) end
    end
    return m
end

do
    local data =
        " ♥ 🅾️❎ ⬇️ "..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
        "abcdefghijklmnopqrstuvwxyz"..
        "0123456789.,:;?!\"-'()=█"
    local widths = {
        16,7,73,9,9,14,8,40,
        4,4,4,4,4,4,4,4,1,3,4,4,5,5,5,4,5,4,4,5,4,5,7,5,5,4,
        4,4,3,4,4,2,4,4,1,2,4,1,5,4,4,4,4,3,3,2,4,5,5,4,4,4,
        4,2,4,4,4,4,4,4,4,4,1,2,1,2,4,1,3,4,1,2,2,3,4,
    }
    local x0,y0 = 0,32
    local params = {}
    local outline = nil

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
    function print(str, x0, y, c, scx, scy)
        scx = scx or 1
        scy = scy or scx
        local function do_work(x0, y, blit)
            local x = x0
            for i=1,#str do
                local ch = sub(str,i,i)
                local param = params[ch]
                if ch==" " then
                    x += 3 * scx
                elseif ch=="\n" then
                    x = x0
                    y += 8 * scx
                elseif param then
                    blit(param.x, param.y, param.w, 8, x, y, param.w * scx, 8 * scy)
                    x += (param.w + 1) * scx
                end
            end
        end
        local old = msave(0x5f00,0x20)
        if outline then
            for i=2,15 do palt(i,true) end
            pal(1,outline)
            local function sspr2(sx, sy, sw, sh, x, y, dw, dh)
                sspr(sx, sy, sw, sh, x-1, y, dw, dh)
                sspr(sx, sy, sw, sh, x+1, y, dw, dh)
                sspr(sx, sy, sw, sh, x, y-1, dw, dh)
                sspr(sx, sy, sw, sh, x, y+1, dw, dh)
            end
            do_work(x0, y, sspr2)
            palt()
        end
        pal(1,c or 1)
        do_work(x0, y, sspr)
        old.restore()
    end
    function font_width(str)
        local x,xmax = 0,0
        for i=1,#str do
            local ch = sub(str,i,i)
            local param = params[ch]
            if ch==" " then
                x += 3
            elseif ch=="\n" then
                xmax,x = max(x,xmax),0
            elseif param then
                x += param.w + 1
            end
        end
        return max(x,xmax)-1
    end
    function font_outline(s) outline=s end
end

