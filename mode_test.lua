
-- debug
--local debug_tiles = true

function new_world()
    return {
        map = new_map(0x1234, 12),
    }
end

function new_game()
    game = {}
    game.world = new_world()
    -- spawn player on tile #1
    game.player = {
        x = game.world.map.startx,
        y = game.world.map.starty,
        movements = {},
        lives = 2,
        maxlives = 6,
        dir = 1,
        trail = { off=0 }
    }
    game.region = { x = -1, y = -1 }
    game.bullet = {}
    game.score = 0
    game.cats = 0
end

function draw_bg()
    map(0, 0, game.region.x * 8, game.region.y * 8, 40, 32)
    map(80, 0, game.region.x * 8, game.region.y * 8, 40, 32)
    if debug_tiles then
        for i=1,#game.world.map do
            local tile = game.world.map[i]
            local chunk = g_chunks[tile.chunk]
            fillp(band(rotl(0xebd7.ebd7,rnd(16)),0xffff)+.5)
            rect(tile.x * 8, tile.y * 8, (tile.x + chunk.w) * 8 - 1, (tile.y + chunk.h) * 8 - 1, 9)
            pico8_print(i, tile.x * 8 + 2, tile.y * 8 + 2, 8)
            pico8_print(tile.x.."\n"..tile.y, tile.x * 8 + 2, tile.y * 8 + 10, 9)
            fillp()
        end
        -- this should never be shown
        rect(game.region.x * 8, game.region.y, (game.region.x + 40) * 8, (game.region.y + 32) * 8, 10)
    end
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(40, 0, game.region.x * 8, game.region.y * 8 - 2, 40, lines)
end

function draw_fg()
    local lines = ceil(game.player.y - game.region.y + 0.25)
    map(40, lines, game.region.x * 8, (game.region.y + lines) * 8 - 2, 40, 32 - lines)
end

function draw_player()
    -- trail
    for i = 1,game.cats do
        local item = game.player.trail[(game.player.trail.off - 2 - i * 10) % #game.player.trail + 1]
        if item then
            spr(122 - flr(sin(t() * 1.5 + i / 7) / 2), item.x * 8, item.y * 8, 1, 1, item.dir == 0)
            spr(124, item.x * 8 + (item.dir == 0 and -2 or 2), item.y * 8 + flr(sin(t() * 1.2 + i / 5) / 2), 1, 1, item.dir == 0)
        end
    end
    -- player
    spr(82 + (game.player.dir < 2 and 0 or 2) - flr(sin(t()*2)*.5), game.player.x * 8 - 4, game.player.y * 8 - 6)
    spr(66 + max(1, game.player.dir), game.player.x * 8 - 4, game.player.y * 8 - 10 + flr(sin(t()*1.3)*.5), 1, 1, game.player.dir == 0)
end

function draw_bullet()
    foreach(game.bullet, function(b)
        spr(64, b.x * 8 - 4, b.y * 8 - 4)
    end)
end

function draw_ui()
    for i = 1,game.player.maxlives do
        sspr(7 - i % 2 * 7, 48, 7, 16, i * 7 - 4, 3)
        if i == game.player.lives then
            palt(2,true) palt(7,true) palt(8,true) palt(14,true)
        end
    end
    palt()
end

cpu_hist = {}
function draw_debug()
    font_outline(1)
    pico8_print(stat(7).." fps", 89, 20, 8)
    pico8_print("x="..game.player.x, 2, 2, 7)
    pico8_print("y="..game.player.y, 2, 11, 7)
    pico8_print("rx="..game.region.x, 2, 24, 9)
    pico8_print("ry="..game.region.y, 2, 33, 9)
    pico8_print("bullets="..#game.bullet, 2, 42, 9)
    pico8_print("tiles="..#game.world.map, 2, 51, 9)
    local cpu = 100*stat(1)
    local max_cpu = cpu
    add(cpu_hist, cpu)
    if #cpu_hist > 50 then
        for i=1,50 do
            cpu_hist[i] = cpu_hist[i+1]
            max_cpu = max(max_cpu, cpu_hist[i])
        end
        cpu_hist[51] = nil
    end
    pico8_print("cpu="..ceil(cpu), 89, 2, 14)
    pico8_print("max="..ceil(max_cpu), 89, 11, 8)
    font_outline()
end

function mode.test.start()
    new_game()
end

function mode.test.update()
    update_bullet()
    update_map()

    -- record a trail behind the player
    if band(btn(), 0xf) != 0 then
        local t = {x=game.player.x, y=game.player.y, dir=game.player.dir}
        local len = max(#game.player.trail, 10 * game.cats + 10)
        while #game.player.trail < len do
            add(game.player.trail, t)
        end
        game.player.trail[game.player.trail.off] = t
        game.player.trail.off = game.player.trail.off % len + 1
    end

    local dx = (btn(0) and -1 or (btn(1) and 1 or 0)) / 8
    local dy = (btn(2) and -1 or (btn(3) and 1 or 0)) / 8
    if not block_walk(game.player.x + dx, game.player.y, 0.6, 0.4) then
        game.player.x += dx
    end
    if not block_walk(game.player.x, game.player.y + dy, 0.6, 0.4) then
        game.player.y += dy
    end

    for i = 0,3 do
        if cbtnp(i) then
            add(game.player.movements, i)
        elseif not btn(i) then
            del(game.player.movements, i)
        end
    end
    game.player.dir = game.player.movements[1] or game.player.dir
    
    if cbtnp(5) then
        game.cats += 1
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

        if block_fly(b.x, b.y) then
            del(game.bullet, b)
        elseif abs(b.x - game.player.x) > 9 or abs(b.y - game.player.y) > 9 then
            del(game.bullet, b)
        end
    end)
end

function update_map()
    -- if the player approaches the region boundaries, move the map!
    -- we have a 40x32 zone but we won't redraw all of it
    local rx, ry, rw, rh = 0, 0, 40, 32
    if game.region.x < 0 then
        game.region.x = flr(game.player.x / 10 + 0.5) * 10 - 20
        game.region.y = flr(game.player.y / 8 + 0.5) * 8 - 16
    elseif abs(game.player.x - 20 - game.region.x) > 11 then
        local right = game.player.x - 20 > game.region.x
        game.region.x += (right and 10 or -10)
        rx = right and 30 or 0
        rw = 10
        memcpy(right and 0x2000 or 0x200a, right and 0x200a or 0x2000, 0xff6)
    elseif abs(game.player.y - 16 - game.region.y) > 7 then
        local down = game.player.y - 16 > game.region.y
        game.region.y += (down and 8 or -8)
        ry = down and 24 or 0
        rh = 8
        memcpy(down and 0x2000 or 0x2400, down and 0x2400 or 0x2000, 0xc00)
    else
        return
    end

    -- initialise the new part of the map
    for y=ry,ry+rh-1 do
        local off = 0x2000 + y * 128
        for p = off+rx, off+rx+rw-1 do
            local tile = 7
            if rnd() > 0.2 then tile = ccrnd({19,20}) end
            local bg,fg,dc = gen_tiles(tile)
            poke(p, bg)
            poke(p+40, fg)
            poke(p+80, dc)
        end
    end

    for tile in all(game.world.map) do
        local chunk = g_chunks[tile.chunk]
        local dx, dy = game.region.x - tile.x, game.region.y - tile.y
        local x0 = max(0, dx + rx)
        local x1 = min(chunk.w - 1, dx + rx + rw - 1)
        local y0 = max(0, dy + ry)
        local y1 = min(chunk.h - 1, dy + ry + rh - 1)
        for y = y0,y1 do
            local o = y * chunk.w
            for x = x0,x1 do
                mset(x - dx, y - dy, chunk.bg[o + x])
                mset(x - dx + 40, y - dy, chunk.fg[o + x])
                mset(x - dx + 80, y - dy, chunk.dc[o + x])
            end
        end
    end
end

function mode.test.draw()
    cls(0)

    camera(game.player.x * 8 - 64, game.player.y * 8 - 64)
    palt(0,false) palt(15,true)
    draw_bg()
    palt() palt(0,false) palt(5,true)
    draw_player()
    draw_bullet()
    palt() palt(0,false) palt(15,true)
    draw_fg()
    camera()

    palt() palt(0,false) palt(5,true)
    draw_ui()
    --draw_debug()
end

