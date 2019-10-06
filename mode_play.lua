mode.play = {}

function new_world()
    return {
        map = load_map(),
    }
end

function new_entity(x, y, dir)
    return {
        x = x, y = y,
        dir = dir,
        cooldown = 0,
        anim = rnd(128),
        walk = rnd(128),
        shot = 0,
    }
end

function new_living(x, y, dir, id, name)
    local e = new_entity(x, y, dir)
    e.id = id
    e.name = name
    return e
end

function new_bat(x, y)
    local e = new_entity(x, y, 0)
    e.lives = 2
    return e
end

function new_slime(x, y, spr)
    local e = new_entity(x, y, 0)
    e.spr = spr
    e.lives = 5
    return e
end

function new_player(x, y)
    local e = new_entity(x, y, 1)
    e.movements = {}
    e.weapon = 1
    e.lives = 6
    e.maxlives = 6
    e.trail = { off=0 }
    return e
end

function init_game()
    game = {}
    game.world = new_world()
    game.quest = new_quest()
    game.player = new_player(game.quest.start.x, game.quest.start.y)
    game.specials = {}
    game.msg = {}
    game.tick = 0 -- reference for all animations
    -- deprecated
    game.bullets = {}
    game.bats = {}
    game.slimes = {}
    game.score = 0
    game.cats = 0
    game.explosions = {}
end

function draw_bg()
    map(0, 0, 0, 0, 128, 64)
    draw_ground_tiles()
    draw_other_tiles(false)
end

function draw_fg()
    draw_other_tiles(true) -- top layer
end

function draw_ground_tiles()
    foreach(game.world.map.collapses, function(c)
        local x, y = c.x*8, c.y*8
        if c.t2 then
            x += rnd(c.t2)-rnd(c.t2)
            y += rnd(c.t2)-rnd(c.t2)
        end
        spr(g_spr_collapse, x-4, y-4)
        if c.t1 then
            for n=1,8*c.t1 do
                pset(x+rnd(n)-rnd(n),y+rnd(n)-rnd(n),crnd(4,7))
            end
        end
    end)
end

function draw_other_tiles(top)
    local function xor(b1,b2) return (not b1)!=(not b2) end
    foreach(game.specials, function(s)
        if xor(top,s.y<=game.player.y) then
            if s.id == g_id_person then
                draw_person(s)
            elseif s.id == g_id_cat then
                draw_cat(s)
            elseif s.id == g_id_raccoon then
                draw_raccoon(s)
            else
                spr(s.id, s.x*8+s.xoff, s.y*8+s.yoff)
            end
        end
    end)
end

function draw_person(p)
    --spr(g_shadow, p.x * 8 - 4, p.y * 8 - 5)
    --if p.shot > 0 and rnd() > 0.5 then
    --    for i = 0,15 do pal(i,7) end
    --end
    spr(82 + (p.dir < 2 and 0 or 2) + flr(p.walk*4%2), p.x * 8 - 4, p.y * 8 - 6)
    spr(66 + max(1, p.dir), p.x * 8 - 4, p.y * 8 - 11 + flr(p.anim*2.6%2), 1, 1, p.dir == 0)
    --for i = 0,15 do pal(i,i) end
end

function draw_cat(o)
    spr(70 + flr(t() * 3 % 2), o.x * 8 - 4, o.y * 8 - 6, 1, 1, o.dir == 0)
    spr(72, o.x * 8 - (o.dir == 0 and 6 or 2), o.y * 8 - 7 - flr(t() * 2.5 % 2), 1, 1, o.dir == 0)
end

function draw_raccoon(o)
    spr(73 + flr(t() * 3 % 2), o.x * 8 - 4, o.y * 8 - 6, 1, 1, o.dir == 0)
    spr(75, o.x * 8 - (o.dir == 0 and 6 or 2), o.y * 8 - 7 - flr(t() * 2.5 % 2), 1, 1, o.dir == 0)
end

function draw_player(p)
    -- trail
    for i = 1,game.cats do
        local item = p.trail[(p.trail.off - 2 - i * 10) % #p.trail + 1]
        if item then
            spr(102 + flr((t() * 3 + i / 7) % 2), item.x * 8 - 4, item.y * 8 - 6, 1, 1, item.dir == 0)
            spr(104, item.x * 8 - (item.dir == 0 and 6 or 2), item.y * 8 - 7 - flr((t() * 2.5 + i / 5) % 2), 1, 1, item.dir == 0)
        end
    end
    -- player
    draw_person(p)
end

function draw_bullets()
    foreach(game.bullets, function(b)
        spr(b.spr, b.x * 8 - 4, b.y * 8 - 4)
    end)
end

function draw_slimes()
    foreach(game.slimes, function(s)
        if s.shot > 0 and rnd() > 0.5 then
            for i = 0,15 do pal(i,7) end
        end
        spr(s.spr + flr(s.anim * 2 % 2), s.x * 8 - 4, s.y * 8 - 4)
        for i = 0,15 do pal(i,i) end
    end)
end

function draw_bats()
    foreach(game.bats, function(b)
        if b.shot > 0 and rnd() > 0.5 then
            for i = 0,15 do pal(i,7) end
        end
        spr(g_bat + (b.dir < 2 and 0 or 2) + flr(b.anim * 3 % 2), b.x * 8 - 4, b.y * 8 - 4, 1, 1, b.dir == 0)
        for i = 0,15 do pal(i,i) end
    end)
end

function draw_ui()
    font_outline(1)
--[[
    for i = 1,game.player.maxlives do
        if i > game.player.lives then
            palt(2,true) palt(7,true) palt(8,true) palt(14,true)
        end
        sspr(7 - i % 2 * 7, 48, 7, 16, i * 7 - 4, 3)
    end
    palt()
    palt(0,false) palt(5,true)
    spr(g_coin + flr(t()*2%2), 6, 114)
    spr(g_heart, 23, 114)
    spr(g_sword, 80, 114)
    palt()
    print(game.player.maxlives / 2, 32, 114, 7)

    local score = tostr(game.score)
    while #score < 6 do score = "0"..score end
    print(score, 90, 2, 7)
]]--
    font_outline()
end

cpu_hist = {}
function draw_debug()
    font_outline(1)
    print(stat(7).." fps", 89, 26, 8)
    print("x="..game.player.x, 2, 2, 11)
    print("y="..game.player.y, 2, 10, 11)
--[[
    pico8_print("bullets="..#game.bullets, 2, 42, 10)
    pico8_print("tiles="..#game.world.map, 2, 48, 10)
    pico8_print("bats="..#game.bats, 2, 54, 10)
    pico8_print("slimes="..#game.slimes, 2, 60, 10)
]]--
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
    print("cpu="..ceil(cpu), 89, 12, 14)
    print("max="..ceil(max_cpu), 89, 19, 8)
    font_outline()
end

function mode.play.start()
    local p = {
        1,
        0, 128, 133, 5, 134, 6, 7,
        --1, 131, 3, 139, 11, 138, 135,
        --2, 132, 136, 137, 9, 10, 7,
        8, 137, 9, 10,
        140, 12, 139, 138,
    } for i=1,#p do pal(i-1,p[i],1) end
    init_game()
    init_quest(game.quest)
end

function mode.play.update()

    -- update animations (even if paused)
    update_anims()
    update_quest(game.quest)

    -- if a message is displayed, update that part
    if game.msg.text then
        messages.update()
    else
        -- otherwise updat ethe logic
        update_bullets()
        update_world(game.world)
        update_player(game.player)
    end

    if cbtnp(5) then
        game.msg.text = "Hey there! What a storm,\nhuh? My two granddaughters\nare so light and tiny they\nwere lifted by the wind!"
    --    game.cats += 1
    --game.score += flr(rnd(80))
    end
end

function update_player(p)
    -- handle death conditions
    if p.dead then
        p.dead += 1/60
        p.dir = ({0,2,1,3})[1+flr(p.dead*6)%4]
        return
    end

    if is_drowning(p.x, p.y, 0.6, 0.4) then
        p.dead = 0
    end

    -- move player
    local dx = (btn(0) and -1 or (btn(1) and 1 or 0)) / 12
    local dy = (btn(2) and -1 or (btn(3) and 1 or 0)) / 12
    if not block_walk(p.x + dx, p.y, 0.6, 0.4) then
        p.x += dx
    end
    if not block_walk(p.x, p.y + dy, 0.6, 0.4) then
        p.y += dy
    end

    -- choose player orientation from user controls
    for i = 0,3 do
        if cbtnp(i) then
            add(p.movements, i)
        elseif not btn(i) then
            del(p.movements, i)
        end
    end
    if #p.movements > 0 then
        p.walk += 1/60
        p.dir = p.movements[1]
        --if (rnd() > 0.6) sfx(g_sfx_walk)
    end

    -- record a trail behind the player
    if band(btn(), 0xf) != 0 then
        local t = {x=p.x, y=p.y, dir=p.dir}
        local len = max(#p.trail, 10 * game.cats + 10)
        while #p.trail < len do
            add(p.trail, t)
        end
        p.trail[p.trail.off] = t
        p.trail.off = p.trail.off % len + 1
    end

    p.shot -= 1/60

    -- handle shoots
    if cbtnp(4) then
        local bx = p.x
        local by = p.y - 0.25
        local vx = ((p.dir == 0) and -1 or ((p.dir == 1) and 1 or 0)) / 4
        local vy = ((p.dir == 2) and -1 or ((p.dir == 3) and 1 or 0)) / 4
        local dx, dy = vy, -vx

        sfx(g_sfx_shoot)
        if p.weapon == 1 or p.weapon == 3 then
            add(game.bullets, {spr = g_apple, x = bx, y = by, vx = vx, vy = vy})
        end
        if p.weapon == 2 or p.weapon == 3 then
            add(game.bullets, {spr = g_apple, x = bx, y = by, vx = 0.8 * vx + 0.2 * dx, vy = 0.8 * vy + 0.2 * dy})
            add(game.bullets, {spr = g_apple, x = bx, y = by, vx = 0.8 * vx - 0.2 * dx, vy = 0.8 * vy - 0.2 * dy})
        end
        for i = 1,game.cats do
            local item = p.trail[(p.trail.off - 2 - i * 10) % #p.trail + 1]
            if item then
                add(game.bullets, {spr = g_banana, x = item.x + crnd(-0.4,0.4), y = item.y + crnd(-0.4,0.4), vx = vx, vy = vy})
            end
        end
    end
end

function update_world(w)
    local p = game.player
    -- spawn stuff if necessary
--[[
    for i=1,w.map.nsigns do
        local sign = w.map.signs[i]
        local visible = (abs(sign.x - p.x) < 16) and (abs(sign.y - p.y) < 16)
        if visible and not w.signs[i] then
            for i = 1,5 do
                add(game.bats, new_bat(sign.x + 3 * sin(i / 5), sign.y + 3 * cos(i / 5)))
            end
            w.signs[i] = {} -- spawned
        end
    end
    for i=1,#w.map.water do
        local water = w.map.water[i]
        local visible = (abs(water.x - p.x) < 16) and (abs(water.y - p.y) < 16)
        if visible and not w.swamps[i] then
            local color = g_slime + 2 * flr(rnd(3))
            for i = 1,6 do
                add(game.slimes, new_slime(water.x + crnd(-5,5), water.y + crnd(-5,5), color))
            end
            w.swamps[i] = {} -- spawned
        end
    end
]]
    -- tick collapsibles
    local tx, ty = flr(p.x)+.5, flr(p.y)+.5
    foreach(game.world.map.collapses, function(c)
        if c.t2 then
            c.t2 += 1/32
            if c.t2 >= 1 then
                del(game.world.map.collapses, c)
            end
        elseif c.t1 then
            c.t1 += 1/64
            if c.t1 >= 1 then
                c.t2 = 0
                sfx(g_sfx_collapse)
            end
        elseif c.x==tx and c.y==ty then
            c.t1 = 0
        end
    end)
    -- tick monsters
    foreach(game.bats, function(b)
        b.anim += 1/60
        b.shot -= 1/60
        local visible = (abs(b.x - p.x) < 10) and (abs(b.y - p.y) < 10)
        if visible then
            -- find a point near the player
            local dx = p.x - b.x
            local dy = p.y - b.y
            local n = sqrt(dx*dx+dy*dy)
            b.cooldown -= 1/60
            if b.cooldown < 0 then
                add(game.bullets, {spr = g_energy, x = b.x, y = b.y, vx = dx / n / 8, vy = dy / n / 8})
                b.cooldown = crnd(1,4)
                b.dir = 1 - b.dir
            end
            if (b.dir == 0) n = -n
            local ex = dy / n * 8
            local ey = -dx / n * 8
            -- new destination
            dx -= ex
            dy -= ey
            n = sqrt(dx*dx+dy*dy)
            b.x += dx / n / 16
            b.y += dy / n / 16
            -- shot by a bullet?
            foreach(game.bullets, function(bul)
                if bul.spr != g_energy and
                    max(abs(bul.x-b.x),abs(bul.y-b.y)) < 0.5 then
                     b.lives -= 1
                     b.shot = 1
                     del(game.bullets, bul)
                end
            end)
        end
        if b.lives <= 0 then
            game.score += 100
            del(game.bats, b)
        end
    end)
    foreach(game.slimes, function(s)
        s.anim += 1/60
        s.shot -= 1/60
        local distx = abs(s.x - p.x)
        local disty = abs(s.y - p.y)
        local visible = max(distx, disty) < 10
        if visible then
            if s.plan then
                if s.cooldown > 3 then
                elseif s.cooldown > 2 then
                    s.x += crnd(-.05,.05)
                else
                    s.x -= 0.3 * (s.x - s.plan.x)
                    s.y -= 0.3 * (s.y - s.plan.y)
                end
            else
                -- find a point near the player
                local dx = p.x - s.x
                local dy = p.y - s.y
                local n = sqrt(dx*dx+dy*dy)
                local ex = s.x + dx / n * 2 + crnd(-2,2)
                local ey = s.y + dy / n * 2 + crnd(-2,2)
                if not block_fly(ex, ey, 0.6, 0.4) then
                    s.plan = {x=ex,y=ey}
                    s.cooldown = crnd(4,6)
                end
            end
            s.cooldown -= 1/60
            if s.cooldown < 0 then
                s.plan = nil
            end
            -- shot by a bullet?
            foreach(game.bullets, function(bul)
                if bul.spr != g_energy and
                    max(abs(bul.x-s.x),abs(bul.y-s.y)) < 0.5 then
                     s.lives -= 1
                     s.shot = 1
                     del(game.bullets, bul)
                end
            end)
        end
        if s.lives <= 0 then
            game.score += 70
            del(game.slimes, s)
            return
        end
        if max(distx, disty) < 0.5 then
            if game.player.shot < 0 then
                game.player.lives = max(0, game.player.lives - 1)
                game.player.shot = 1
            end
        end
    end)
end

function update_bullets()
    foreach(game.bullets, function(b)
        b.x += b.vx
        b.y += b.vy

        if block_fly(b.x, b.y) then
            del(game.bullets, b)
        else
            local dx = abs(b.x - game.player.x)
            local dy = abs(b.y - game.player.y)
            if max(dx, dy) > 9 then
                del(game.bullets, b)
            else
                if b.spr == g_energy and (max(dx, dy) < 0.5) then
                    if game.player.shot < 0 then
                        game.player.lives = max(0, game.player.lives - 1)
                        game.player.shot = 1
                    end
                    del(game.bullets, b)
                end
            end
        end
    end)
end

function update_anims()

    game.tick += 1
    game.player.anim += 1/60

    -- scroll water
    if game.tick % 40 == 0 then
        for y=0,7 do
            local p=sget(56,16+y)
            for x=0,6 do sset(56+x,16+y,sget(57+x,16+y)) end
            sset(56+7,16+y,p)
        end
    end
    -- scroll waterfall
    if game.tick % 3 == 0 then
        local l=128/2
        local p=3*8*l+56/2
        local a,b = peek4(p+7*l),peek4(p+4+7*l)
        for q=p+6*l,p,-l do poke4(q+l,peek4(q)) poke4(q+4+l,peek4(q+4)) end
        poke4(p,a)poke4(p+4,b)
    end
    --for i=rnd(12),2 do sset(crnd(56,64),crnd(16,24),ccrnd({6,6,7,7,7})) end
    --for i=1,10 do sset(crnd(56,64),crnd(16,24),13) end
end

function mode.play.draw()
    cls(0)

    local cam_x, cam_y = game.player.x * 8 - 64, game.player.y * 8 - 64
    if game.msg.h then
        cam_y += game.msg.h / 2
    end
    camera(cam_x, cam_y)
    draw_bg()
    draw_player(game.player)
    draw_slimes()
    draw_bullets()
    draw_fg()
    draw_bats()
    camera()
    draw_ui()

    if game.msg.text then
        messages.draw()
    end

    draw_debug()
end

