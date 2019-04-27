
-- build a table for left-right mirroring
local mirror = {
    3, 4, 5, 6, -- roads
    9, 10, -- paths
    11, 12, 27, 28, 13, 29, -- rivers
    16, 17, 32, 33, -- houses
}
g_mirror = {}
for i = 1,#mirror do g_mirror[mirror[i]] = mirror[bxor(i-1,1)+1] end

-- parse the map to create chunks
g_chunks = {}
for ty = 0,63 do for tx = 0,127 do
    if mget(tx,ty) != 63 and mget(tx-1,ty-1) == 63 and mget(tx-1,ty) == 63 and mget(tx,ty-1) == 63 then
        local w, h = 1, 1
        while mget(tx + w, ty) != 63 do w += 1 end
        while mget(tx, ty + h) != 63 do h += 1 end
        local left, right = {w=w, h=h}, {w=w, h=h}
        for y = 0,h-1 do for x = 0,w-1 do
            local sprite = mget(tx+x, ty+y)
            left[y*w+x] = sprite
            right[y*w+w-1-x] = g_mirror[sprite] or sprite
        end end
        add(g_chunks, left)
        add(g_chunks, right)
    end
end end

function new_game()
    game = {}
    game.world = new_world()
    game.player = { x = 136, y = 180 }
    game.region = { x = -1000, x = -1000 }
end

function new_world()
    local world = {
        score = 0,
        map = {},
    }
    -- generate a large map
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
    return world
end

function draw_world()
    local x = game.region.x
    local y = game.region.y
    map(0, 0, x * 8, y * 8, 64, 32)
end

function draw_player()
    spr(18, game.player.x * 8, game.player.y * 8)
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
        game.region.x = flr(game.player.x - 32)
        game.region.y = flr(game.player.y - 16)
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
    end
    game.player.x += (btn(0) and -1 or (btn(1) and 1 or 0)) / 8
    game.player.y += (btn(2) and -1 or (btn(3) and 1 or 0)) / 8
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    draw_world()
    draw_player()
    camera()

    draw_ui()
    draw_debug()
end

