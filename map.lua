
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
    return {w=w, h=h, bg={}, fg={}, dc={}}
end

function void(x, y)
    local s = mget(x, y)
    return (s == 63) or (s == 0)
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
        for y = 0,h-1 do for x = 0,w-1 do
            local bg = mget(tx+x, ty+y)
            local fg,dc = 0,0
            if fget(bg, 0) then
                fg = bg
                bg = 7
                --dc = 37 -- shadows?
            elseif bg == 7 and rnd() > 0.8 then
                bg = 62
            elseif bg == 7 and rnd() > 0.8 then
                dc = ccrnd({15, 31, 46, 47})
            end
            left.bg[y*w+x] = bg
            right.bg[y*w+w-1-x] = g_mirror[bg] or bg
            left.fg[y*w+x] = fg
            right.fg[y*w+w-1-x] = g_mirror[fg] or fg
            left.dc[y*w+x] = dc
            right.dc[y*w+w-1-x] = g_mirror[dc] or dc
            -- handle exits
            if y == 0   and exit_n[bg] then left.exit_n = x right.exit_n = w-1-x end
            if y == h-1 and exit_s[bg] then left.exit_s = x right.exit_s = w-1-x end
            if x == 0   and exit_w[bg] then left.exit_w = y right.exit_e = y end
            if x == w-1 and exit_e[bg] then left.exit_e = y right.exit_w = y end
        end end
        add(g_chunks, left)
        add(g_chunks, right)
    end
end end

function remove_overlaps(map, candidates)
    for tc in all(candidates) do
        local ok = true
        for t in all(map) do
            if t.x >= tc.x + g_chunks[tc.chunk].w then
            elseif t.y >= tc.y + g_chunks[tc.chunk].h then
            elseif tc.x >= t.x + g_chunks[t.chunk].w then
            elseif tc.y >= t.y + g_chunks[t.chunk].h then
            else ok = false break end
        end
        if not ok then del(candidates, tc) end
    end
end

function grow_map(map, id, depth)
    local tile = map[id]
    local chunk = g_chunks[tile.chunk]
    local old_count = #map
    -- try to connect to the north
    if chunk.exit_n and not tile.next_n then
        local candidates = {}
        for i=1,#g_chunks do
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
            add(map, ccrnd(candidates))
            tile.next_n = #map
        end
    end
    -- try to connect to the south
    if chunk.exit_s and not tile.next_s then
        local candidates = {}
        for i=1,#g_chunks do
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
            add(map, ccrnd(candidates))
            tile.next_s = #map
        end
    end
    -- try to connect to the west
    if chunk.exit_w and not tile.next_w then
        local candidates = {}
        for i=1,#g_chunks do
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
            add(map, ccrnd(candidates))
            tile.next_w = #map
        end
    end
    -- try to connect to the east
    if chunk.exit_e and not tile.next_e then
        local candidates = {}
        for i=1,#g_chunks do
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
            add(map, ccrnd(candidates))
            tile.next_e = #map
        end
    end
    if depth > 0 and #map > old_count then
        for new_tile = old_count + 1, #map do
            grow_map(map, new_tile, depth - 1)
        end
    end
end

function new_map(seed, depth)
    srand(seed)
    local map = {}
    -- initialise world with one tile
    map[1] = { chunk = flr(crnd(1,1+#g_chunks)), x = 16384, y = 16384 }
    -- grow world
    grow_map(map, 1, depth)
    return map
end

