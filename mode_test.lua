
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
    rect(game.region.x * 8, game.region.y, (game.region.x + 64) * 8, (game.region.y + 32) * 8, 10)
    for tile in all(game.world.map) do
        local chunk = g_chunks[tile.chunk]
        fillp(0x5a5a.8)
        rect(tile.x * 8, tile.y * 8, (tile.x + chunk.w) * 8 - 1, (tile.y + chunk.h) * 8 - 1, 9)
        print(tile.x.."\n"..tile.y, tile.x * 8 + 2, tile.y * 8 + 2, 9)
        fillp()
    end
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(64, 0, game.region.x * 8, game.region.y * 8 - 2, 64, lines)
end

function draw_player()
    spr(18, game.player.x * 8, game.player.y * 8)
end

function draw_bullet()
    foreach(game.bullet, function(b)
        spr(42, b.x * 8, b.y * 8)
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
    coprint("cpu="..cpu, 100, 2, 8)
    coprint("x="..game.player.x, 2, 2, 7)
    coprint("y="..game.player.y, 2, 8, 7)
    coprint("reg.x="..game.region.x, 2, 18, 9)
    coprint("reg.y="..game.region.y, 2, 24, 9)
    coprint("bullets="..#game.bullet, 2, 30, 9)
    coprint("tiles="..#game.world.map, 2, 36, 9)
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
            for p=0x2000+y*128,0x203f+y*128 do
                poke(p, rnd() > 0.8 and 62 or 7)
            end
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
        local bx = game.player.x
        local by = game.player.y + 0.25
        local vx = ((game.player.dir == 0) and -1 or ((game.player.dir == 1) and 1 or 0)) / 4
        local vy = ((game.player.dir == 2) and -1 or ((game.player.dir == 3) and 1 or 0)) / 4
        local dx, dy = vy, -vx

        add(game.bullet, {x = bx, y = by, vx = 0.8 * vx + 0.2 * dx, vy = 0.8 * vy + 0.2 * dy})
        add(game.bullet, {x = bx, y = by, vx = 0.8 * vx - 0.2 * dx, vy = 0.8 * vy - 0.2 * dy})
    end
end

function update_bullet()
    foreach(game.bullet, function(b)
        b.x += b.vx
        b.y += b.vy

        if abs(b.x - game.player.x) > 9 or abs(b.y - game.player.y) > 9 then
            del(game.bullet, b)
        end
    end)
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    palt(0,false) palt(15,true)
    draw_bg()
    palt(0,true) palt(15,false)
    draw_player()
    draw_bullet()
    palt(0,false) palt(15,true)
    draw_fg()
    camera()

    draw_ui()
    draw_debug()
end

