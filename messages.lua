
msg_queue = {}

-- style: 1==center 2==bottom
function open_message(text,style)
    local m = { text=text, style=style, h=0, cursor="", opening=true }
    m.wanted_h = 6 + 8
    for i=1,#text do if sub(text,i,i)=="\n" then m.wanted_h += 8 end end
    add(msg_queue, m)
end

function has_message()
    return #msg_queue > 0
end

function message_cam_y()
    local m = msg_queue[1]
    if m and m.style==2 then return max(m.h - 14, 0) / 2 end
    return 0
end

function update_message()
    local m = msg_queue[1]
    if not m then return end
    if m.close then
        m.close += 1/20
        if m.close > 1 then del(msg_queue, m) return end
        m.h = m.wanted_h * max(0, 1 - m.close)
    elseif m.wait then
        m.wait += 1/30
        m.cursor = ""
        if cbtnp(4) then m.close = 0 end
    elseif m.display then
        m.display += (btn(4) and 1.5 or .3)
        if m.display >= #m.text then m.wait = 0 end
        m.cursor = m.display % 6 < 4 and "█" or ""
        m.h = m.wanted_h
    elseif m.opening then
        m.h += 1
        if m.h >= m.wanted_h then m.display = 0 end
    end
end

function draw_message()
    local m = msg_queue[1]
    if not m then return end
    local c1 = { 0xbf, 0xba }
    local c2 = { 14, 8 }
    local w,h = ({92, 128 - 4})[m.style], m.h
    local x,y = ({18, 2})[m.style], ({70 - h / 2, 127 - h - 2})[m.style]
    if h then
        fillp(0x6699)
        smoothrectfill(x, y, x + w - 1, y + h, 5, c1[m.style])
        fillp()
        smoothrect(x, y, x + w - 1, y + h, 5, 1)
        if h >= 4 then
            smoothrect(x + 1, y + 1, x + w - 2, y + h - 1, 3, c2[m.style])
        end
    end
    clip(x + 4, y + 4, w - 6, h - 6)
    if m.display then
        local i = m.display
        print(sub(m.text,1,i)..m.cursor, x + 4, y + 4)
    end
    if m.wait and m.style==g_style_bottom then
        if m.wait % 1 > .4 then
            print("⬇️", x + w - 12, y + h - 9)
        end
    end
    clip()
end

