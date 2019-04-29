
-- build a table for left-right mirroring
local mirror = {
    3, 4, 5, 6, 57, 58, -- roads
    9, 10, 25, 26, -- paths
    11, 12, 27, 28, -- rivers
    16, 17, 32, 33, -- houses
    37, 38, 51, 52, 53, 54, -- buildings
    44, 45, 60, 61, -- trees
}
g_mirror = {}
for i = 1,#mirror do g_mirror[mirror[i]] = mirror[bxor(i-1,1)+1] end

-- tables for map exits
local exit_n = {[2]=true, [5]=true, [6]=true}
local exit_s = {[2]=true, [3]=true, [4]=true}
local exit_w = {[1]=true, [3]=true, [5]=true}
local exit_e = {[1]=true, [4]=true, [6]=true}

function new_chunk(w, h)
    return {w=w, h=h, exits=0, signs={}, bg={}, fg={}, dc={}}
end

function void(x, y)
    local s = mget(x, y)
    return (s == 63) or (s == 0)
end

function gen_tiles(bg)
    local fg,dc = 0,0
    if fget(bg, 0) then
        --dc = 37 -- shadows?
        return 7, bg, 0
    elseif bg == 7 and rnd() > 0.8 then
        bg = 62
    elseif bg == 7 and rnd() > 0.8 then
        return bg, 0, ccrnd({22, 42})
    elseif bg == 7 and rnd() > 0.8 then
        return bg, 0, ccrnd({15, 31, 46, 47})
    end
    return bg, 0, 0
end

-- parse the map to create chunks
g_chunks = {}
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

function remove_overlaps(map, candidates)
    for chunk_desc in all(candidates) do
        local chunk = g_chunks[chunk_desc.chunk]
        local ok = true
        if #map.signs + #chunk.signs > map.nsigns then
            ok = false
        else for t in all(map) do
            if t.x >= chunk_desc.x + chunk.w then
            elseif t.y >= chunk_desc.y + chunk.h then
            elseif chunk_desc.x >= t.x + g_chunks[t.chunk].w then
            elseif chunk_desc.y >= t.y + g_chunks[t.chunk].h then
            else ok = false break end
        end end
        if not ok then del(candidates, chunk_desc) end
    end
end

function append_map(map, chunk_desc)
    add(map, chunk_desc)
    local chunk = g_chunks[chunk_desc.chunk]
    -- add chunk items to the global map
    for s in all(chunk.signs) do
        add(map.signs, {x = chunk_desc.x + s.x, y = chunk_desc.y + s.y})
    end
end

function grow_map(map, id, depth)
    local tile = map[id]
    local chunk = g_chunks[tile.chunk]
    local old_count = #map
    -- try to connect to the north
    if chunk.exit_n and not tile.next_n then
        local candidates = {}
        for i=2,#g_chunks do
            local new_chunk = g_chunks[i]
            if new_chunk.exit_s then
                add(candidates, {
                    chunk = i,
                    x = tile.x + chunk.exit_n - new_chunk.exit_s,
                    y = tile.y - new_chunk.h,
                    next_s = id,
                })
            end
        end
        remove_overlaps(map, candidates)
        if #candidates > 0 then
            append_map(map, ccrnd(candidates))
            tile.next_n = #map
        end
    end
    -- try to connect to the south
    if chunk.exit_s and not tile.next_s then
        local candidates = {}
        for i=2,#g_chunks do
            local new_chunk = g_chunks[i]
            if new_chunk.exit_n then
                add(candidates, {
                    chunk = i,
                    x = tile.x + chunk.exit_s - new_chunk.exit_n,
                    y = tile.y + chunk.h,
                    next_n = id,
                })
            end
        end
        remove_overlaps(map, candidates)
        if #candidates > 0 then
            append_map(map, ccrnd(candidates))
            tile.next_s = #map
        end
    end
    -- try to connect to the west
    if chunk.exit_w and not tile.next_w then
        local candidates = {}
        for i=2,#g_chunks do
            local new_chunk = g_chunks[i]
            if new_chunk.exit_e then
                add(candidates, {
                    chunk = i,
                    x = tile.x - new_chunk.w,
                    y = tile.y + chunk.exit_w - new_chunk.exit_e,
                    next_e = id,
                })
            end
        end
        remove_overlaps(map, candidates)
        if #candidates > 0 then
            append_map(map, ccrnd(candidates))
            tile.next_w = #map
        end
    end
    -- try to connect to the east
    if chunk.exit_e and not tile.next_e then
        local candidates = {}
        for i=2,#g_chunks do
            local new_chunk = g_chunks[i]
            if new_chunk.exit_w then
                add(candidates, {
                    chunk = i,
                    x = tile.x + chunk.w,
                    y = tile.y + chunk.exit_e - new_chunk.exit_w,
                    next_w = id,
                })
            end
        end
        remove_overlaps(map, candidates)
        if #candidates > 0 then
            append_map(map, ccrnd(candidates))
            tile.next_e = #map
        end
    end
    if depth > 0 and #map > old_count then
        for new_tile = old_count + 1, #map do
            grow_map(map, new_tile, depth - 1)
        end
    end
end

function new_map(seed, depth, nsigns)
    srand(seed)
    local map
    repeat
        map = { startx=16384, starty=16384, signs={}, nsigns=nsigns }
        -- initialise world with one tile and grow it
        append_map(map, { chunk = 1, x = map.startx - 4, y = map.starty - 5 })
        grow_map(map, 1, depth)
    until #map.signs == map.nsigns
    return map
end

