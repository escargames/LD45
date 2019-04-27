
-- build a table for left-right mirroring
local mirror = {
    3, 4, 5, 6, -- roads
    9, 10, 25, 26, -- paths
    11, 12, 27, 28, -- rivers
    16, 17, 32, 33, -- houses
}
g_mirror = {}
for i = 1,#mirror do g_mirror[mirror[i]] = mirror[bxor(i-1,1)+1] end

-- tables for map exits
local exit_n = {[2]=true, [5]=true, [6]=true}
local exit_s = {[2]=true, [3]=true, [4]=true}
local exit_w = {[1]=true, [3]=true, [5]=true}
local exit_e = {[1]=true, [4]=true, [6]=true}

function new_chunk(w, h)
    return {w=w, h=h, bg={}, fg={}}
end

-- parse the map to create chunks
g_chunks = {}
for ty = 1,63 do for tx = 1,127 do
    if mget(tx,ty) != 63 and mget(tx-1,ty-1) == 63 and mget(tx-1,ty) == 63 and mget(tx,ty-1) == 63 then
        local w, h = 1, 1
        while mget(tx + w, ty) != 63 do w += 1 end
        while mget(tx, ty + h) != 63 do h += 1 end
        local left, right = new_chunk(w, h), new_chunk(w, h)
        for y = 0,h-1 do for x = 0,w-1 do
            local bg = mget(tx+x, ty+y)
            local fg = 0
            if fget(bg, 0) then
                fg = bg
                bg = 7
            end
            left.bg[y*w+x] = bg
            right.bg[y*w+w-1-x] = g_mirror[bg] or bg
            left.fg[y*w+x] = fg
            right.fg[y*w+w-1-x] = g_mirror[fg] or fg
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

function new_game()
    game = {}
    game.world = new_world()
    -- spawn player on tile #1
    game.player = { x = game.world.map[1].x + 6, y = game.world.map[1].y + 3 }
    game.region = { x = -1000, y = -1000 }
end

function grow_map(map, id, depth)
    local tile = map[id]
    local chunk = g_chunks[tile.chunk]
    local added_tiles = {}
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
        add(map, ccrnd(candidates))
        add(added_tiles, #map)
        tile.next_n = #map
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
        add(map, ccrnd(candidates))
        add(added_tiles, #map)
        tile.next_s = #map
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
        add(map, ccrnd(candidates))
        add(added_tiles, #map)
        tile.next_w = #map
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
        add(map, ccrnd(candidates))
        add(added_tiles, #map)
        tile.next_e = #map
    end
    if depth > 0 then
        for new_tile in all(added_tiles) do
            grow_map(map, new_tile, depth - 1)
        end
    end
end

function new_world()
    local world = {
        score = 0,
        map = {},
    }
    -- initialise world with one tile
    world.map[1] = { chunk = flr(crnd(1,1+#g_chunks)), x = 1000, y = 1000 }
    -- grow world with depth 10
    --grow_map(world.map, 1, 10)
    grow_map(world.map, 1, 4)

--[[
    for cy = 1,40 do
        local l = {}
        world.map[cy] = l
        for cx = 1,20 do
            local cell = {}
            cell.tile = flr(crnd(1,1+#g_chunks))
            --cell.tile = flr(crnd(1,37))
            l[cx] = cell
        end
    end
]]
    return world
end

function draw_bg()
    map(0, 0, game.region.x * 8, game.region.y * 8, 64, 32)
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(64, 0, game.region.x * 8, game.region.y * 8 - 2, 64, lines)
end

function draw_player()
    spr(18, game.player.x * 8, game.player.y * 8)
end

function draw_fg()
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(64, lines, game.region.x * 8, (game.region.y + lines) * 8 - 2, 64, 32 - lines)
end

function draw_ui()
end

function draw_debug()
    local cpu = 100*stat(1)
    print("cpu="..cpu, 100, 1, 8)
    print("x="..game.player.x, 1, 1, 7)
    print("y="..game.player.y, 1, 7, 7)
    print("reg.x="..game.region.x, 1, 17, 9)
    print("reg.y="..game.region.y, 1, 23, 9)
end

function mode.test.start()
    new_game()
end

function mode.test.update()
    -- if the player is outside the region, refill the map!
    if abs(game.player.x - 32 - game.region.x) > 23 or
       abs(game.player.y - 16 - game.region.y) > 7 then
        game.region.x = flr(game.player.x / 8 + 0.5) * 8 - 32
        game.region.y = flr(game.player.y / 8 + 0.5) * 8 - 16

        -- xxx: inefficient!
        for y = 0,31 do
            memset(0x2000 + y*128, 7, 0x40)
            memset(0x2040 + y*128, 0, 0x40)
        end
        for tile in all(game.world.map) do
            local chunk = g_chunks[tile.chunk]
            if tile.x < game.region.x + 64 and
               tile.y < game.region.y + 32 and
               tile.x + chunk.w >= game.region.x and
               tile.y + chunk.h >= game.region.y then
                for y = 0,chunk.h-1 do
                    for x = 0,chunk.w-1 do
                        mset(tile.x - game.region.x + x,
                             tile.y - game.region.y + y,
                             chunk.bg[y * chunk.w + x])
                        mset(tile.x - game.region.x + x + 64,
                             tile.y - game.region.y + y,
                             chunk.fg[y * chunk.w + x])
                    end
                end
            end
        end
--[[
        for my = 0,32 do
            for mx = 0,64 do
                local x = game.region.x + mx
                local y = game.region.y + my
                local cell = game.world.map[flr(y/8)][flr(x/13)]
                local m = 0
                if cell then
                    m = g_chunks[cell.tile][y%8*13+x%13]
                end
                mset(mx, my, m)
            end
        end
--]]
    end
    game.player.x += (btn(0) and -1 or (btn(1) and 1 or 0)) / 8
    game.player.y += (btn(2) and -1 or (btn(3) and 1 or 0)) / 8
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    draw_bg()
    draw_player()
    draw_fg()
    camera()

    draw_ui()
    draw_debug()
end

