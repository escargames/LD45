
function new_world()
    return {
        score = 0,
        map = new_map(),
    }
end

function new_game()
    game = {}
    game.world = new_world()
    -- spawn player on tile #1
    game.player = { x = game.world.map[1].x + 6, y = game.world.map[1].y + 3, dir = 1 }
    game.region = { x = -1000, y = -1000 }
    game.bullet = {}
end

function draw_bg()
    map(0, 0, game.region.x * 8, game.region.y * 8, 64, 32)
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(64, 0, game.region.x * 8, game.region.y * 8 - 2, 64, lines)
end

function draw_player()
    spr(18, game.player.x * 8, game.player.y * 8)
end

function draw_bullet()
    foreach(game.bullet, function(b)
        spr(42, b.x, b.y)
    end)
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
    print("bullets="..#game.bullet, 1, 29, 9)
end

function mode.test.start()
    new_game()
end

function mode.test.update()
    update_bullet()
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

    for i = 0,3 do
        if btn(i) then
            game.player.dir = i
        end
    end
    
    if cbtnp(4) then
        add(game.bullet, {x = game.player.x * 8, y = game.player.y * 8 + 2, dir = game.player.dir})
    end
end

function update_bullet()
    foreach(game.bullet, function(b)
        b.x += ((b.dir == 0) and -1 or ((b.dir == 1) and 1 or 0)) * 1.5
        b.y += ((b.dir == 2) and -1 or ((b.dir == 3) and 1 or 0)) * 1.5

        if abs(b.x - game.player.x * 8) > 70 or abs(b.y - game.player.y * 8) > 70 then
            del(game.bullet, b)
        end
    end)
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    draw_bg()
    draw_player()
    draw_bullet()
    draw_fg()
    camera()

    draw_ui()
    draw_debug()
end

