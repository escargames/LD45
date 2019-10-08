
msg_queue = {}

-- style: 1==center 2==bottom
function open_message(text,style,header,fn)
    local m = { text=text, header=header, style=style, fn=fn, h=0, cursor="", opening=true }
    m.wanted_h = 6 + 8
    for i=1,#text do if sub(text,i,i)=="\n" then m.wanted_h += 8 end end
    if style==g_style_question then m.wanted_h += 8 end
    m.text_width = font_width(text)
    add(msg_queue, m)
end

function has_message()
    return #msg_queue > 0
end

function message_cam_y()
    local m = msg_queue[1]
    --if m and m.style==2 then return max(m.h - 14, 0) / 2 end
    return 0
end

function update_message()
    local m = msg_queue[1]
    if not m then return end
    if m.close then
        m.close += 1/20
        if m.close > 1 then
            del(msg_queue, m)
            if m.fn then m.fn(m.answer) end
            return
        end
        m.h = m.wanted_h * max(0, 1 - m.close)
    elseif m.wait then
        if cbtnp(0) then m.answer = (m.answer + 1) % 3 + 1 end
        if cbtnp(1) then m.answer = m.answer % 3 + 1 end
        m.wait += 1/30
        m.cursor = m.style == g_style_bottom and m.wait % 1 > .4 and "⬇️" or ""
        if cbtnp(4) then
            sfx(g_sfx_select)
            m.close = 0
        end
    elseif m.display then
        local tmp = m.display
        m.display += (btn(4) and 1.5 or .3)
        if flr(tmp)!=flr(m.display) then sfx(g_sfx_type) end
        if m.display >= #m.text then m.wait = 0 m.answer = 1 end
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
    local c1 = { 0xbf, 0xba, 0xba }
    local c2 = { 14, 8, 8 }
    local w,h = ({m.text_width+8, 128 - 4, 128 - 4})[m.style], m.h
    local x,y = ({60-m.text_width/2, 2, 2})[m.style], ({80 - h / 2, 127 - h - 2, 127 - h - 2})[m.style]
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
    if m.style==g_style_question and m.answer then
        local ch={"♥", "@", "|"}
        for i=1,3 do
            local dot=i==m.answer and "➡️" or ""
            print(dot, x + 24 + i * 20, y + h - 10)
            print(ch[i], x + 30 + i * 20, y + h - 10)
        end
    end
    clip()
end

