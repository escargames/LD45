
-- save the cartridge map in lua memory for future use
g_map = {}
for i=0,0x400 do g_map[i+1] = peek4(0x2000+i*4) end

function load_map()
    -- restore saved map
    for i=0,0x400 do poke4(0x2000+i*4,g_map[i+1]) end
    --srand(bxor(seed, 0xa472.39f3))
    local map = {
        startx=17.5, starty=12.5,
        signs={},
        chests={},
        keys={},
        collapses={},
    }
    -- parse all levels
    for ty = 0,63 do for tx = 0,127 do
        local id = mget(tx,ty)
        local function special(list, src, dst)
            if id == src then
                add(list, {x=tx+.5,y=ty+.5})
                mset(tx,ty,dst)
            end
        end
        special(map.signs,  g_spr_sign,  g_spr_ground)
        special(map.chests, g_spr_chest, g_spr_ground)
        special(map.keys,   g_spr_key,   g_spr_ground)
        special(map.collapses, g_spr_collapse, g_spr_water)
    end end
    return map
end

function void(x, y)
    local s = mget(x, y)
    return (s == 63) or (s == 0)
end

--[[
for ty = 1,63 do for tx = 1,127 do
    if void(tx+1,ty+1) then
        -- ignore this tile
    elseif not void(tx,ty) and void(tx-1,ty-1) and void(tx-1,ty) and void(tx,ty-1) then
        local w, h = 1, 1
        while not void(tx + w, ty) do w += 1 end
        while not void(tx, ty + h) do h += 1 end
        local left, right = new_chunk(w, h), new_chunk(w, h)
        local exits = 0
        for y = 0,h-1 do for x = 0,w-1 do
            local bg,fg,dc = gen_tiles(mget(tx+x, ty+y))
            local loff,roff = y*w+x,y*w+w-1-x
            if fg == 21 then
                add(left.signs, {x=x+.5,y=y+.5})
                add(right.signs, {x=w-1-x+.5,y=y+.5})
            elseif fg == 61 then -- lower-right corner of a big tree
                add(left.trees, {x=x,y=y})
                add(right.trees, {x=w-1-x,y=y})
            elseif fget(bg, 4) then
                left.water = true
                right.water = true
            end
            left.bg[loff] = bg
            right.bg[roff] = g_mirror[bg] or bg
            left.fg[loff] = fg
            right.fg[roff] = g_mirror[fg] or fg
            left.dc[loff] = dc
            right.dc[roff] = g_mirror[dc] or dc
            -- handle exits
            if y == 0   and exit_n[bg] then exits += 1 left.exit_n = x right.exit_n = w-1-x end
            if y == h-1 and exit_s[bg] then exits += 1 left.exit_s = x right.exit_s = w-1-x end
            if x == 0   and exit_w[bg] then exits += 1 left.exit_w = y right.exit_e = y end
            if x == w-1 and exit_e[bg] then exits += 1 left.exit_e = y right.exit_w = y end
        end end
        left.exits = exits
        right.exits = exits
        add(g_chunks, left)
        add(g_chunks, right)
    end
end end
]]--

