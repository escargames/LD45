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

        -- needs to be somewhere else...
        skin = 1+flr(rnd(4)),
        eyes = 1+flr(rnd(2)),
        clothes = 1+flr(rnd(5)),
        hair = 1+flr(rnd(6))
    }
end

function new_living(x, y, dir, id, data)
    local e = new_entity(x, y, dir)
    e.r = 0.5 -- not too much otherwise fire kills us easily
    e.id = id
    e.data = data
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
    foreach(game.world.map.plants, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_plant, data=o, xoff=-4, yoff=-4 })
    end)
    game.junk = {}
    game.spawn = 0
    game.music = 0
    game.tick = 0 -- reference for all animations
    -- deprecated
    game.balls = {}
    game.score = 0
    game.cats = 0
    game.explosions = {}
    -- create maze
    --create_maze(64,0,63,29)
    --create_maze(66,2,58,22)
    -- create bg
    for j=0,15 do for i=0,15 do mset(127-i,63-j,46) end end
end

function draw_bg()
    for n=0,9 do
        map(112, 48, -128, -128 + 128*n, 16, 16) -- left
        map(112, 48, -128 + 128*n, -128, 16, 16) -- top
        map(112, 48, 128*8, -128 + 128*n, 16, 16) -- right
        map(112, 48, -128 + 128*n, 8*46, 16, 16) -- bottom
    end
    map(0, 0, 0, 0, 128, 46)
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
        if s.d < 16 and xor(top,s.y<=game.player.y) then
            if s.id == g_id_person then
                draw_person(s)
            elseif s.id == g_id_cat then
                draw_cat(s)
            elseif s.id == g_id_raccoon then
                draw_raccoon(s)
            elseif s.id == g_spr_fire then
                draw_fire(s)
            elseif s.id >= 0 then
                spr(s.id, s.x*8+s.xoff, s.y*8+s.yoff)
                if s.grown then -- for plants
                    spr(53+s.grown, s.x*8+s.xoff, s.y*8+s.yoff-4)
                end
            end
        end
    end)
end

local cl1 = { 5, 6, 0, 0 }
local cl2 = { 12, 14, 8, 10, 4 }
local cl3 = { 2, 3, 4, 5, 6, 10 }
local cl4 = { 13, 14 }

function draw_person(p)
    local x,y = p.x*8, p.y*8
    --spr(g_shadow, p.x * 8 - 4, p.y * 8 - 5)
    --if p.shot > 0 and rnd() > 0.5 then
    --    for i = 0,15 do pal(i,7) end
    --end
    if p.dead then
        clip(0,33,128,32) -- clip at the feet of the player
        y+=p.dead*8
    elseif p.in_water then
        clip(0,33,128,32)
        y+=4
    elseif p.jump then
        local k=sin(p.jump/4)
        y-=8*k*k
    end
    local oldpal = msave(0x5f00,0x20)
    pal(7,cl1[p.skin])
    pal(12,cl2[p.clothes])
    pal(13,cl2[p.clothes]+1)
    spr(82 + (p.dir < 2 and 0 or 2) + flr(p.walk*4%2), x - 4, y - 6)
    pal(14,cl3[p.hair])
    pal(15,cl3[p.hair]+1)
    pal(8,cl4[p.eyes])
    spr(66 + max(1, p.dir), x - 4, y - 11 + flr(p.anim*2.6%2), 1, 1, p.dir == 0)
    clip()
    oldpal.restore()
end

function draw_fire(o)
    for dx=0,7 do
        local x=o.x*8-4+dx
        local y=o.y*8+2-3*sin(dx/14)
        for c=8,11 do
            local dy=rnd(4-cos(dx/7))
            rectfill(x,y,x,y-dy,c)
            y-=dy
        end
    end
    spr(g_spr_fire, o.x*8-4, o.y*8-4)
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

function draw_balls()
    foreach(game.balls, function(b)
        spr(b.spr, b.x * 8 - 4, b.y * 8 - 4)
    end)
end

function draw_ui()
    -- inventory
    local x = 128 - 15
    local function disp(id)
        smoothrectfill(x,2,x+11,13,2,7,1)
        spr(id,x+2,4)
        x -= 14
    end
    if game.inventory.boots then disp(g_spr_boots) end
    if game.inventory.gloves then disp(g_spr_gloves) end
    if game.inventory.can then disp(g_spr_can) end
    if game.inventory.suit then disp(g_spr_suit) end
    if game.inventory.ball then disp(g_spr_ball) end
    for i=1,game.inventory.nkeys do disp(g_spr_key) end
end

function mode.play.start()
    init_game()
    init_quest(game.quest)
end

function respawn()
    game.spawn = 0
    local s = game.quest.save or game.quest.start
    game.player.x = s.x
    game.player.y = s.y
    game.player.dead = nil
    reset_map(game.world.map)
    -- reset specials
    foreach(game.specials, function(o)
        if o.id==g_spr_boulder or o.id==g_spr_fire then
            o.x = o.data.x+.5
            o.y = o.data.y+.5
        end
    end)
end

function mode.play.update()
    if game.dead then
        if cbtnp(4) then
            game.dead = false
            respawn()
        end
        return
    end

    -- update animations (even if paused)
    update_anims()
    update_music()
    update_quest(game.quest)
    update_message()

    -- if a message is displayed, update that part
    if not has_message() then
        -- otherwise update the logic
        update_balls()
        update_world(game.world)
        update_player(game.player)
    end
end

-- convert dx,dy to a direction (0,1,2,3)
function atan3(dx,dy)
    return ({1,2,0,3,1})[flr(4*atan2(dx,dy)+1.5)]
end

function update_player(p)
    -- handle death conditions
    if p.dead then
        palette(min(8,flr(p.dead*4)))
        p.dead += 1/60
        p.dir = ({0,2,1,3})[1+flr(p.dead*6)%4]
        if p.dead > 2 then
            game.dead = true
        end
        return
    end

    p.in_water = not p.jump and in_water(p.x, p.y, 0.6, 0.4)

    if p.in_water and not game.inventory.suit then
        sfx(g_sfx_drown)
        p.dead = 0
    end

    -- compute player direction
    local dx = (btn(0) and -1 or (btn(1) and 1 or 0)) / 12
    local dy = (btn(2) and -1 or (btn(3) and 1 or 0)) / 12

    -- handle action button
    if cbtnp(4) and not p.push then
        -- look for a special object
        local s
        foreach(game.specials, function(o)
            -- check that the player is facing the object
            if o.d<1 and p.dir==atan3(-o.dx,-o.dy) then s=o end
        end)
        if not s then
            if game.inventory.ball then
                shoot(p)
            end
        elseif s.id==g_spr_boulder and game.inventory.gloves then
            p.push=0
            p.boulder=s
        else
            quest_activate(game.quest,s)
        end
    end

    -- handle jump
    if p.jump then
        p.jump -= 1/12
        if p.jump > 0 then
            dx = p.jdx
            dy = p.jdy
        else
            p.jump = nil
        end
    elseif cbtnp(5) then
        if game.inventory.boots then
            sfx(g_sfx_jump)
            p.jump = 2
            -- find destination cell
            local cx = flr(p.x + ({-2,2,0,0})[p.dir+1])+0.5
            local cy = flr(p.y + ({0,0,-2,2})[p.dir+1])+0.5
            p.jdx = (cx - p.x) / 24
            p.jdy = (cy - p.y) / 24
        elseif not p.warned then
            open_message("I cannot jump without\nmy boots...\nI really have nothing!",g_style_center)
            p.warned = true
        end
    end

    -- handle pushing
    if p.push then
        if p.push == 0 then
            sfx(g_sfx_push)
            p.pdx = ({-1,1,0,0})[p.dir+1]
            p.pdy = ({0,0,-1,1})[p.dir+1]
        end
        p.push += 1/32
        p.boulder.id = 0
        if p.push >= 1 or block_walk(p.boulder.x + p.pdx*0.5, p.boulder.y + p.pdy*0.5, 0.5, 0.5) then
            p.boulder.x = flr(p.boulder.x) + 0.5
            p.boulder.y = flr(p.boulder.y) + 0.5
            p.push = nil
        else
            -- make the player go slower
            dx = p.pdx / 32
            dy = p.pdy / 32
            p.boulder.x += dx
            p.boulder.y += dy
        end
        p.boulder.id = g_spr_boulder
    end

    -- move if no collisions
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
        if (rnd() > 0.6) sfx(g_sfx_walk)
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
end

function shoot(p)
    local bx = p.x
    local by = p.y - 0.25
    local vx = ((p.dir == 0) and -1 or ((p.dir == 1) and 1 or 0)) / 4
    local vy = ((p.dir == 2) and -1 or ((p.dir == 3) and 1 or 0)) / 4
    local dx, dy = vy, -vx

    sfx(g_sfx_shoot)
    add(game.balls, {spr = g_spr_ball, x = bx, y = by, vx = vx, vy = vy})
end

function update_world(w)
    local p = game.player
    -- spawn stuff if necessary
    do end
    -- tick collapsibles
    local tx, ty = flr(p.x)+.5, flr(p.y)+.5
    foreach(game.world.map.collapses, function(c)
        if p.jump then
            -- do nothing!
        elseif c.t2 then
            c.t2 += 1/32
            if c.t2 >= 1 then
                add(game.world.map.junk, c)
                del(game.world.map.collapses, c)
            end
        elseif c.t1 then
            c.t1 += 1/64
            if c.t1 >= 1 then
                sfx(g_sfx_crumble)
                c.t2 = 0
            end
        elseif c.x==tx and c.y==ty then
            c.t1 = 0
        end
    end)
    -- tick specials
    foreach(game.specials, function(o)
        -- compute distance to player
        o.dx = p.x-o.x
        o.dy = p.y-o.y
        o.d = max(abs(o.dx),abs(o.dy))
        -- if close enough, try to collect item!
        if o.d < o.r and not p.dead then
            quest_touch(game.quest,o)
        end
        -- animate
        if o.anim then
            o.anim += 1/60
        end
        -- if moving, try moving
        if o.d < 20 and o.id==g_spr_fire then
            local dx = ({-0.1,0.1,0,0})[o.dir+1]
            local dy = ({0,0,-0.1,0.1})[o.dir+1]
            if not block_walk(o.x + dx, o.y + dy, 0.6, 0.6) then
                o.x += dx
                o.y += dy
            else
                o.dir = bxor(o.dir, 1)
            end
        end
    end)
end

function update_balls()
    foreach(game.balls, function(b)
        b.x += b.vx
        b.y += b.vy

        if block_fly(b.x, b.y) then
            del(game.balls, b)
        else
            local dx = abs(b.x - game.player.x)
            local dy = abs(b.y - game.player.y)
            if max(dx, dy) > 9 then
                del(game.balls, b)
            else
                if b.spr == g_energy and (max(dx, dy) < 0.5) then
                    if game.player.shot < 0 then
                        game.player.lives = max(0, game.player.lives - 1)
                        game.player.shot = 1
                    end
                    del(game.balls, b)
                end
            end
        end
    end)
end

function update_music()
    game.music -= 2
    if game.music < 0 then
        music(game.music % 2 * 4, 300)
        game.music += flr(60 * (75 + rnd(30)))
    end
end

function update_anims()

    game.spawn += 1/60
    game.tick += 1
    game.player.anim += 1/60

    -- scroll water
    if game.tick % 40 == 0 then
        local p=16*64+56/2
        for y=0,7 do
            poke4(p+y*64,rotr(peek4(p+y*64),4))
        end
    end
    -- scroll waterfall
    if game.tick % 3 == 0 then
        local p=24*64+56/2
        local saved = peek4(p+7*64)
        for q=p+6*64,p,-64 do poke4(q+64,peek4(q)) end
        poke4(p,saved)
    end
end

function mode.play.draw()
    if game.dead then
        palette(0)
        cls(1)
        print("YOU DIED", 26, 50, 8, 2, 3)
    else
        if game.spawn < 2 then palette(max(0, flr(8 - game.spawn*4))) end
        cls(7) -- should not be necessary
        local cam_x = game.player.x * 8 - 64
        local cam_y = game.player.y * 8 - 64 - message_cam_y()
        camera(cam_x, cam_y)
        draw_bg()
        draw_player(game.player)
        draw_balls()
        draw_fg()
        camera()
        draw_ui()
        draw_message()
    end
end

