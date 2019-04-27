pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by niarkou and sam

--
-- config
--

config = {
    intro = {},
    menu = {},
    levels = {},
    ready = {},
    play = {},
    finished = {},
    pause = {},
}

g_btn_confirm = 4
g_btn_back = 5
g_btn_jump = 4
g_btn_call = 5

-- menu navigation sfx
g_sfx_navigate = 38
g_sfx_confirm = 39

-- gameplay sfx
g_sfx_death = 37
g_sfx_happy = 36
g_sfx_saved = 32
g_sfx_jump = 35
g_sfx_ladder = 34
g_sfx_footstep = 33

-- sprites
g_spr_player = 18
g_spr_follower = 20
g_spr_exit = 26
g_spr_portal = 38
g_spr_spikes = 36
g_spr_happy = 37
g_spr_count = 48

g_fill_amount = 2
g_solid_time = 80
g_win_frames = 40
g_lose_frames = 80

g_palette = {
    { 5, 13,  6 }, -- no color
    { 2,  8, 14 }, -- red
    { 1, 12,  6 }, -- blue
    { 4,  9, 10 }, -- yellow
    { 3, 11,  6 }, -- green
}

g_intro = {
    "episode 43",
    "<sacrifices must be made",
    "",
    "a long time ago,",
    "in a garden far,",
    "far away. . .",
    "",
    "the cats escaped!",
    "",
    "grandma must return",
    "them home safe. but",
    "<the journey is perilous",
    "and cats don't listen.",
    "",
    ". . . will she succeed",
    "eventually? it's only",
    "up to you. good luck!",
}

g_levels = {
    {  0,  0, 16,  7, "kittens" }, -- level 1
    {  0,  7, 16,  9, "lose to win" }, -- level 2
    {  0, 16, 16, 13, "    old game\nwith new twist" }, -- level 3
    { 32,  0,  7, 16, "death is useful" }, -- level 4
    { 48,  0, 16, 16, "you control the\nplayer, not the\n  environment" },
    { 16,  0, 16, 16, "too good to be\n   impossible" }, -- test level
    { 16, 16, 16, 12, "the future \n is the past"},
    { 64,  0, 16, 16, "     thinking\nout of the box" },
    {  0, 29, 23, 20, "worst game ever"},
    {  0, 49,  9, 15, "maximum game feels"},
    { 23, 32, 22, 12, "the beginning\n is the end"},
    { 26, 48, 16, 16, "don't teleporters"},
}

g_ong_level = 0
g_levels_unlocked = {true}

-- font
#include escarlib/fonts/double_homicide.lua
#include escarlib/font.lua
load_font(double_homicide,14)

-- background image
#include escarlib/p8u.lua
#include background.lua

--
-- levels
--

function make_world(level)
    world = { x = 0, y = 0, w = 0, h = 0 }
    -- initialise world with level information
    if level > 0 and level <= #g_levels then
        world.x = g_levels[level][1]
        world.y = g_levels[level][2]
        world.w = g_levels[level][3]
        world.h = g_levels[level][4]
        world.name = g_levels[level][5]
    end
    world.spikes = {}
    world.portals = {}
    world.cats = {}
    world.spikes_lut = {} -- fixme: not very nice
    world.goal = {}
    world.saved = { 0, 0, 0, 0, 0 }
    world.numbercats = { 0, 0, 0, 0, 0 }
    -- analyse level to find where the exit and traps are
    for y=world.y,world.y+world.h-1 do
        for x=world.x,world.x+world.w-1 do
            local sprite = mget(x, y)
            if sprite == g_spr_exit then
                world.exit = {x = 8 * x + 8, y = 8 * y + 12}
            elseif sprite == g_spr_spikes then
                local s = {x = 8 * x + 4, y = 8 * y + 4, fill = 0, solid = 0}
                add(world.spikes, s)
                world.spikes_lut[x + y / 256] = s
            elseif sprite >= g_spr_portal and sprite < g_spr_portal + 4 then
                local direction = sprite - g_spr_portal
                local p = {x = 8 * x + 4, y = 8 * y + 4, d = direction}
                foreach(world.portals, function(p2)
                    if not p2.other then
                        p2.other = p
                        p.other = p2
                    end
                end)
                add(world.portals, p)
            elseif sprite >= g_spr_follower and sprite < g_spr_follower + 5 then
                local color = sprite - g_spr_follower + 1
                local spawn_count = mget(x, y - 1) - g_spr_count + 1
                local save_count = mget(x + 1, y) - g_spr_count + 1
                -- if count is above, it's a spawner
                if spawn_count > 0 and spawn_count < 16 then
                    local dir = x > world.x + world.w/2
                    for i=1,spawn_count do
                        local dx = i * (i % 2 * 2 - 1)
                        add(world.cats, new_cat(8 * x + 4 + dx, 8 * y - rnd(4), color, dir))
                    end
                    world.numbercats[color] += spawn_count
                -- otherwise, if count is on the right, it's a save goal
                elseif save_count > 0 and save_count < 16 then
                    world.goal[color] = (world.goal[color] or 0) + save_count
                end
            elseif sprite == g_spr_player then
                local dir = x > world.x + world.w/2
                world.player = new_player(8 * x + 8, 8 * y, dir)
            end
        end
    end
    -- detect walls for grass
    for y=0,world.h-1 do
        for x=0,world.w-1 do
            local wx = 8 * (world.x + x)
            local wy = 8 * (world.y + y)
            local sprite = 0
            local b1 = wall(wx, wy) and not wall(wx, wy - 4)
            local b2 = wall(wx + 4, wy) and not wall(wx + 4, wy - 4)
            local b3 = wall(wx, wy + 4) and not wall(wx, wy)
            local b4 = wall(wx + 4, wy + 4) and not wall(wx + 4, wy)
            if b1 and b2 then sprite = 28
            elseif b3 and b4 then sprite = 29
            elseif b1 then sprite = 44
            elseif b2 then sprite = 45
            elseif b3 then sprite = 30
            elseif b4 then sprite = 31
            end
            mset(128 - world.w + x, 64 - world.h + y, sprite)
        end
    end
end

--
-- constructors
--

function new_game()
    score = 0
    saved = 0
    particles = {}
    selectcolor = 1
    selectcolorscreen = false
    color = {1, 2, 3, 4, 5}
    make_world(level)
end

function new_entity(x, y, dir)
    return {
        x = x, y = y,
        dir = dir,
        anim = rnd(128),
        walk = rnd(128),
        climbspd = 0.5,
        grounded = false,
        ladder = false,
        jumped = false,
        jump = 0, fall = 0,
        cooldown = 0,
    }
end

function new_player(x, y, dir)
    local e = new_entity(x, y, dir)
    e.can_jump = true
    e.spd = 1.0
    e.spr = g_spr_player
    e.pcolors = { 5, 6 }
    e.call = 1
    return e
end

function new_cat(x, y, color, dir)
    local e = new_entity(x, y, dir)
    e.spd = crnd(0.4, 0.6)
    e.plan = {}
    e.color = color
    e.spr = g_spr_follower + e.color - 1
    e.pcolors = g_palette[e.color]
    return e
end

--
-- useful functions
--

function jump()
    if btn(2) or btn(g_btn_jump) then
        return true end
end

-- cool btnp(): ignores autorepeat

do
    local ub = _update_buttons
    local oldstate, state = 0, btn()
    function _update_buttons()
        ub()
        oldstate, state = state, btn()
    end
    function cbtnp(i)
        local bitfield = band(btnp(), bnot(oldstate))
        return not i and bitfield or band(bitfield, 2^i) != 0
    end
end

-- cool random

function crnd(a, b)
  return min(a, b) + rnd(abs(b - a))
end

function ccrnd(tab)  -- takes a tab and choose randomly between the elements of the table
  n = flr(crnd(1, #tab+1))
  return tab[n]
end

-- rect with smooth sides

function smoothrect(x0, y0, x1, y1, r, col)
    line(x0, y0 + r, x0, y1 - r, col)
    line(x1, y0 + r, x1, y1 - r, col)
    line(x0 + r, y0, x1 - r, y0, col)
    line(x0 + r, y1, x1 - r, y1, col)
    clip(x0, y0, r, r)
    circ(x0 + r, y0 + r, r, col)
    clip(x0, y1 - r, r, r + 1)
    circ(x0 + r, y1 - r, r, col)
    clip(x1 - r, y0, r + 1, r)
    circ(x1 - r, y0 + r, r, col)
    clip(x1 - r, y1 - r, r + 1, r + 1)
    circ(x1 - r, y1 - r, r, col)
    clip()
end

-- rect filled with smooth sides

function smoothrectfill(x0, y0, x1, y1, r, col1, col2)
    circfill(x0 + r, y0 + r, r, col1)
    circfill(x0 + r, y1 - r, r, col1)
    circfill(x1 - r, y0 + r, r, col1)
    circfill(x1 - r, y1 - r, r, col1)
    rectfill(x0 + r, y0, x1 - r, y1, col1)
    rectfill(x0, y0 + r, x1, y1 -r, col1)
    smoothrect(x0, y0, x1, y1, r, col2)
end

--
-- standard pico-8 workflow
--

function _init()
    poke(0x5f34, 1)
    cartdata("rainbow_cats")
    state = "intro"
    music(0)
    scroll = 0
    particles = {}
    num = {1}
    jump_speed = 1
    fall_speed = 1
    -- create sin/cos table
    st, ct = {}, {}
    for i=0,128 do
        st[i] = sin(i / 128)
        ct[i] = cos(i / 128)
    end
end

function reset_menu()
    menu = {
        doordw = 128,
        doorx = 0,
        doorspd = 1,
        opening = false,
        rectpos = 1,
        high_y = 78,
        selectlevel = 1,
    }
end

function _update60()
    config[state].update()
end

function _draw()
    config[state].draw()
end

--
-- intro
--

function config.intro.update()
    scroll += 1 / 4
    if cbtnp(g_btn_confirm) or scroll > #g_intro * 16 + 160 then
        reset_menu()
        state = "menu"
    end
end

function config.intro.draw()
    cls(0)
    camera(-64,-64)
    for x=1,128,2 do
        local m = 3 + ((2+x%3) * scroll + 1450*sin(x/73)) % 200
        pset(m * ct[x], m * st[x], x%3+5)
        pset(m * -st[x], m * ct[x], x%3+5)
    end
    camera()
    font_outline(1)
    if scroll > 130 then
        --print("🅾️ skip", 74, 112 - 8.5 * abs(sin(t()/2)), 9)
        --pico8_print("🅾️ skip", 101, 121 - 3.5 * abs(sin(t()/2)), 0)
        pico8_print("🅾️ skip", 100, 120 - 3.5 * abs(sin(t()/2)), 9)
    end
    font_center(true)
    for i=1,#g_intro do
        local line = 128 + i * 16 - scroll
        if line >= -20 and line < 128 then
            local str = g_intro[i]
            if sub(str,1,1) == "<" then
                font_scale(0.9)
                str = sub(str, 2, #str)
            end
            print(str, 64, line, 10)
            font_scale()
        end
    end
    font_center()
    font_outline()
end

--
-- menu
--

function config.menu.update()
    open_door()
    choose_menu()
    update_levels_unlocked()
end

function config.menu.draw()
    cls(0)
    draw_background()
    draw_menu()
    --draw_debug()
end

function open_door()
    if cbtnp(g_btn_confirm) then
        sfx(g_sfx_confirm)
        if menu.rectpos == 1 then
            menu.opening = true
        elseif menu.rectpos == 2 then
            state = "levels"
        end
    end

    if menu.opening == true then
        menu.doordw -= mid(2, menu.doordw / 5, 3) * menu.doorspd
        menu.doorx += mid(2, menu.doordw / 5, 3) * menu.doorspd
    end

    if menu.doordw < 2 then
        menu.opening = false
        level = menu.selectlevel
        new_game()
        state = "ready"
    end
end

function choose_menu()
    if btnp(3) and menu.rectpos < 2 then
        sfx(g_sfx_navigate)
        menu.rectpos += 1
    elseif btnp(2) and menu.rectpos > 1 then
        sfx(g_sfx_navigate)
        menu.rectpos -= 1
    end
end

--
-- get ready screen
--

function config.ready.update()
    if cbtnp(g_btn_confirm) then
        sfx(g_sfx_confirm)
        state = "play"
    end
end

function config.ready.draw()
    draw_background()
    font_outline(1)
    font_center(true)
    print("level "..level..":", 64, 20, 7)
    print(g_levels[level][5], 64, 40, 14)
    font_center()
    print("🅾️ play", 4, 112 - 8.5 * abs(sin(t()/2)), 9)
    font_outline()
end

--
-- level finished screen
--

function config.finished.update()
    if cbtnp(g_btn_confirm) then
        sfx(g_sfx_confirm)
        if world.win and level == #g_levels then
            -- beat the game...
            reset_menu()
            state = "menu"
        else
            if (world.win) level += 1
            new_game()
            state = "ready"
        end
    elseif cbtnp(g_btn_back) then
        sfx(g_sfx_confirm)
        reset_menu()
        state = "menu"
    end
end

function config.finished.draw()
    draw_background()
    font_outline(1)
    font_center(true)
    if world.win then
        print("well done!", 64, 20, 7)
        font_center()
        print("🅾️ next", 4, 112 - 8.5 * abs(sin(t()/2)), 9)
        print("❎ back", 74, 112 - 8.5 * abs(cos(t()/2)), 9)
    else
        print("you failed!", 64, 20, 8)
        font_center()
        print("🅾️ retry", 4, 112 - 8.5 * abs(sin(t()/2)), 9)
        print("❎ back", 74, 112 - 8.5 * abs(cos(t()/2)), 9)
    end
    font_outline()
end

--
-- play
--

function config.play.update()
    update_particles()
    update_player()
    update_numbercats()
    update_cats()
    update_spikes()
    -- did we win?
    if world.win then
        world.win -= 1
        if world.win < 0 then
            state = "finished"
            keep_level(level)
        end
    elseif world.lose then
        world.lose -= 1
        if world.lose < 0 then
            state = "finished"
        end
    end
end

function config.play.draw()
    cls(0)
    -- player-centered camera if map is larger than screen, otherwise fixed camera
    camera(world.x * 8 + (world.w > 16 and mid(0, world.player.x - world.x * 8 - 64, world.w * 8 - 128) or 4 * world.w - 64),
           world.y * 8 + (world.h > 16 and mid(0, world.player.y - world.y * 8 - 64, world.h * 8 - 128) or 4 * world.h - 64))
    draw_world()
    draw_particles()
    draw_cats()
    draw_player()
    draw_grass()
    draw_player2()
    camera()
    draw_ui()
    --draw_debug()
end

function has_won()
    for i, num in pairs(world.goal) do
        if world.saved[i] < num then
            return false
        end
    end
    return true
end

function move_x(e, dx)
    if not wall_area(e.x + dx, e.y, 4, 4) then
        e.x += dx
    end
end

function move_y(e, dy)
    while wall_area(e.x, e.y + dy, 4, 4) do
        dy *= 7 / 8
        if abs(dy) < 0.00625 then return end
    end
    e.y += dy
    -- wrap around when falling
    if e.y > (world.y + world.h) * 8 + 16 then
        e.y = world.y * 8
    end
end

function update_particles()
    foreach (particles, function(p)
        p.x += p.vx or 0
        p.y += p.vy or 0
        p.vy = (p.vy or 0) + (p.gravity or 0)
        p.age -= 1
        if p.age < 0 then
            del(particles, p)
        end
    end)
end

function update_player()
    if world.lose then
        return -- do nothing, we died!
    end
    if not btn(g_btn_call) then
        selectcolor = 1
        update_entity(world.player, btn(0), btn(1), jump(), btn(3))
        selectcolorscreen = false
    elseif btn(g_btn_call) then
        update_entity(world.player)
        selectcolorscreen = true
        if btnp(0) and selectcolor > 1 then
            sfx(g_sfx_navigate)
            selectcolor -= 1
        elseif btnp(1) and selectcolor < #num then
            sfx(g_sfx_navigate)
            selectcolor += 1
        end
        world.player.call = num[selectcolor]
    end
    -- did we die in spikes or some other trap?
    if trap(world.player.x - 2, world.player.y) or
       trap(world.player.x + 2, world.player.y) then
        sfx(g_sfx_death)
        world.lose = g_lose_frames
        death_particles(world.player.x, world.player.y)
    end
end

function update_numbercats()
    if selectcolorscreen then
        num = {1}
        for i = 2, #world.numbercats do
            if world.numbercats[i] != 0 then
                add(num, i)
            end
        end
    end
end

function update_cats()
    foreach(world.cats, function(t)
        local old_x, old_y = t.x, t.y
        update_entity(t, t.plan[0], t.plan[1], t.plan[2], t.plan[3])
        for i = 0, 3 do
            t.plan[i] = false
        end
        -- update move plan if necessary
        if world.player.call == t.color and not selectcolorscreen then -- go left or right or up or down
            if rnd(2) > 1.99 then
                sfx(g_sfx_happy)
                t.happy = 20
            end
            if t.happy then
                t.happy -= 1
            end
            if t.x < world.player.x - 1 then
                t.plan[1] = true
            elseif t.x > world.player.x + 1 then
                t.plan[0] = true
            elseif t.y < world.player.y - 4 then
                t.plan[3] = true
            elseif t.y > world.player.y + 4 then
                t.plan[2] = true
            end
        end
        -- did we reach the exit?
        if world.exit and
           abs(t.x - world.exit.x) < 2 and
           abs(t.y - world.exit.y) < 2 then
            sfx(g_sfx_saved)
            saved += 1
            world.numbercats[t.color] -= 1
            world.saved[t.color] += 1
            world.saved[1] += 1
            del(world.cats, t)
            if has_won() then
                world.win = g_win_frames
            end
            -- save particles!
            for i=1,crnd(20,30) do
                add(particles, { x = t.x, y = t.y,
                                 vx = crnd(-.75,.75),
                                 vy = crnd(-.75,.75),
                                 gravity = -1/8,
                                 age = 20 + rnd(5), color = {6,15,7},
                                 r = { 0.5, 1, 1.5 } })
            end
        end
        -- did we die in spikes or some other trap?
        if trap(t.x, t.y) then
            sfx(g_sfx_death)
            s = world.spikes_lut[flr(t.x/8) + flr(t.y/8)/256]
            s.fill += 1
            world.numbercats[t.color] -= 1
            del(world.cats, t)
            death_particles(t.x, t.y)
        end
        if world.numbercats[world.player.call] <= 0 then
            world.player.call = 1
        end
    end)
end

function update_entity(e, go_left, go_right, go_up, go_down)
    -- portals
    local portal
    foreach(world.portals, function(p)
        if abs(p.x - e.x) < 6 and abs(p.y - e.y) < 2 then
            portal = p
        end
    end)

    -- update some variables
    e.anim += 1

    local old_x, old_y = e.x, e.y

    -- check x movement (easy)
    if go_left then
        e.dir = true
        e.walk += 1
        move_x(e, -e.spd)
    elseif go_right then
        e.dir = false
        e.walk += 1
        move_x(e, e.spd)
    end

    -- check for ladders and ground below
    local ladder = ladder_area(e.x, e.y, 0, 4)
    local ladder_below = ladder_area_down(e.x, e.y + 0.0125, 4)
    local ground_below = wall_area(e.x, e.y + 0.0125, 4, 4)
    local grounded = ladder or ladder_below or ground_below

    -- if inside a ladder, stop jumping
    if ladder then
        e.jump = 0
    end

    -- if grounded, stop falling
    if grounded then
        e.fall = 0
    end

    -- allow jumping again
    if e.jumped and not go_up then
        e.jumped = false
    end

    if go_up then
        -- up/jump button
        if ladder then
            move_y(e, -e.climbspd)
            ladder_middle(e)
        elseif grounded and e.can_jump and not e.jumped then
            e.jump = 20
            e.jumped = true
            e.walk = 8
            if state == "play" then
                sfx(g_sfx_jump)
            end
        end
    elseif go_down then
        -- down button
        if ladder or ladder_below then
            move_y(e, e.climbspd)
            ladder_middle(e)
        end
    end

    if e.jump > 0 then
        move_y(e, -mid(1, e.jump / 5, 2) * jump_speed)
        e.jump -= 1
        if old_y == e.y then
            e.jump = 0 -- bumped into something!
        end
    elseif not grounded then
        move_y(e, mid(1, e.fall / 5, 2) * fall_speed)
        e.fall += 1
    end

    if grounded and old_x != e.x then
        if last_move == nil or time() > last_move + 0.25 then
            last_move = time()
            sfx(g_sfx_footstep)
        end
    end

    if ladder and old_y != e.y then
        if last_move == nil or time() > last_move + 0.25 then
            last_move = time()
            sfx(g_sfx_ladder)
        end
    end

    e.grounded = grounded
    e.ladder = ladder

    -- footstep particles
    if (old_x != e.x or old_y != e.y) and rnd() > 0.5 then
        add(particles, { x = e.x + crnd(-3, 3),
                         y = e.y + crnd(2, 4),
                         vx = rnd(0.5) * (old_x - e.x),
                         vy = rnd(0.5) * (old_y - e.y) - 0.125,
                         age = 20 + rnd(5), color = e.pcolors,
                         r = { 0.5, 1, 0.5 } })
    end

    -- handle portals
    if portal and ((e.y < portal.y and old_y >= portal.y) or
                   (e.y > portal.y and old_y <= portal.y)) then
        e.x = portal.other.x
        e.y += portal.other.y - portal.y
    end
end

function update_spikes()
    foreach(world.spikes, function(s)
        local cx, cy = (s.x - 4) / 8, (s.y - 4) / 8
        local t = ccrnd({-1, 1})
        local other1 = world.spikes_lut[cx - t + cy / 256]
        local other2 = world.spikes_lut[cx + t + cy / 256]
        if other1 and other1.fill < s.fill then
            other1.fill += 1/16
            s.fill -= 1/16
        elseif other2 and other2.fill < s.fill then
            other2.fill += 1/16
            s.fill -= 1/16
        elseif s.fill >= g_fill_amount then
            s.fill = max(g_fill_amount, s.fill - 1/16)
            s.solid += 1
            if s.solid >= g_solid_time then
                mset(128 - world.x - world.w + cx, 64 - world.y - world.h + cy, 28)
            end
        end
    end)
end

-- walls, traps and ladders

function wall(x,y)
    local m = mget(x/8, y/8)
    return not fget(m, 4) and wall_or_ladder(x, y)
end

function wall_area(x,y,w,h)
    return wall(x-w,y-h) or wall(x-1+w,y-h) or
           wall(x-w,y-1+h) or wall(x-1+w,y-1+h) or
           wall(x-w,y) or wall(x-1+w,y) or
           wall(x,y-1+h) or wall(x,y-h)
end

function wall_or_ladder(x,y)
    local m = mget(x/8,y/8)
    if fget(m,5) and world then
        local spike = world.spikes_lut[flr(x/8) + flr(y/8)/256]
        if spike and spike.solid >= g_solid_time then
            return true
        end
    end
    if ((x%8<4) and (y%8<4)) return fget(m,0)
    if ((x%8>=4) and (y%8<4)) return fget(m,1)
    if ((x%8<4) and (y%8>=4)) return fget(m,2)
    if ((x%8>=4) and (y%8>=4)) return fget(m,3)
    return true
end

function wall_or_ladder_area(x,y,w,h)
    return wall_or_ladder(x-w,y-h) or wall_or_ladder(x-1+w,y-h) or
           wall_or_ladder(x-w,y-1+h) or wall_or_ladder(x-1+w,y-1+h) or
           wall_or_ladder(x-w,y) or wall_or_ladder(x-1+w,y) or
           wall_or_ladder(x,y-1+h) or wall_or_ladder(x,y-h)
end

function trap(x,y)
    local m = mget(x/8, y/8)
    return fget(m, 5)
end

function death_particles(x, y)
    for i=1,crnd(20,30) do
        add(particles, { x = x, y = y,
                         vx = crnd(-.75,.75),
                         vy = crnd(-.75,.75),
                         gravity = 1/32,
                         age = 20 + rnd(5), color = {2,8,14},
                         r = { 0.5, 1.5, 0.5 } })
    end
end

function ladder(x,y)
    local m = mget(x/8, y/8)
    return fget(m, 4) and wall_or_ladder(x,y)
end

function ladder_area_up(x,y,h)
    return ladder(x,y-h)
end

function ladder_area_down(x,y,h)
    return ladder(x,y-1+h)
end

function ladder_area(x,y,w,h)
    return ladder(x-w,y-h) or ladder(x-1+w,y-h) or
           ladder(x-w,y-1+h) or ladder(x-1+w,y-1+h)
end

function ladder_middle(e)
    local ladder_x = flr(e.x / 8) * 8
    if e.x < ladder_x + 4 then
        move_x(e, 1)
    elseif e.x > ladder_x + 4 then
        move_x(e, -1)
    end
end

--
-- level selection screen
--

function config.levels.update()
    if menu.high_y > 15 then
        menu.high_y -= 2
    end
    if btnp(0) and menu.selectlevel > 1 then
        menu.selectlevel -= 1
        sfx(g_sfx_menu)
    elseif btnp(1) and menu.selectlevel < #g_levels then
        menu.selectlevel += 1
        sfx(g_sfx_menu)
    end
    if cbtnp(g_btn_confirm) and menu.selectlevel <= #g_levels_unlocked then
        --reset_menu()
        state = "menu"
        menu.opening = true
        g_ong_level = menu.selectlevel
        sfx(g_sfx_menu)
    end
    if cbtnp(g_btn_back) then
        reset_menu()
        state = "menu"
    end
end

function config.levels.draw()
    cls(0)
    draw_background()
    font_outline(1)
    print("❎ back", 74, 112 - 8.5 * abs(sin(t()/2)), 9)
    if menu.selectlevel <= #g_levels_unlocked then
        print("🅾️ play", 4, 112 - 8.5 * abs(cos(t()/2)), 9)
    end
    font_outline()
    draw_level_selector()
end

function draw_level_selector()
    font_center(true)
    font_outline(1)
    print("levels", 64, menu.high_y - 10, 13)
    font_center()
    font_outline()
    local page = flr((menu.selectlevel - 1) / 6)
    for i = 1+page*6, min(6+page*6, #g_levels) do
        local dx = (i - 1) % 3 + 1
        local dy = flr((i - 1) % 6 / 3)
        local colors = i == menu.selectlevel and {14, 8} or
                       i > #g_levels_unlocked and { 6, 7 } or {15,9}
        smoothrectfill(-7 + 30*dx, 25 + 30*dy, 13 + 30*dx, 45 + 30*dy, 5, colors[1], colors[2])
        font_center(true)
        font_outline(1)
        print(tostr(i), 5 + 29*dx, 28 + 30*dy, colors[2])
        font_center()
        if dget(i) == 2 then
            font_outline(1, 1)
            print("★", 3 + 30*((i-1)%3 + 1), 37 + 30*flr((i-1)%6/3), 10)
        end
        font_outline()
    end
    font_center(true)
    font_outline(1)
    local name = menu.selectlevel <= #g_levels_unlocked and g_levels[menu.selectlevel][5] or "???"
    print(name, 64, 85, 7)
    font_center()
    font_outline()
    --for i = 1, 3 do
        --font_outline(0.5, 0.5)
        --print("★ ", 59 - 23 + (i - 1)*20, 85, 6, 10)
        --font_outline()
    --end
end

-- keeping levels won

function keep_level(level)
    dset(level, 2)
    dset(level + 1, max(dget(level + 1), 1))
    dset(level + 2, max(dget(level + 1), 2))
end

function update_levels_unlocked()
    for i = 1, #g_levels do
        if dget(i) == 2 then
            g_levels_unlocked[i] = true
            if i + 1 <= #g_levels then g_levels_unlocked[i + 1] = true end
            if i + 2 <= #g_levels then g_levels_unlocked[i + 2] = true end
        end
    end
end

--
-- drawing
--

function draw_background()
    for i=1,#background do poke4(0x5ffc+4*i,background[i]) end
end

function draw_menu()
    if state == "menu" then
        if menu.doordw > 126 then
            palt(0, false)
            palt(14, true)
            palt()
            local rect_y0 = 35 + 20 * menu.rectpos
            local rect_y1 = 52 + 20 * menu.rectpos
            smoothrectfill(38, rect_y0, 90, rect_y1, 7, 6, 0)
            font_outline(1, 0.5, 0.5)
            font_scale(1.5)
            print("r     b", 5, 24 + 4 * sin(t()+0.1), 8)
            print("a     o", 16, 24 + 4 * sin(t()+0.2), 12)
            print("i      w", 28, 24 + 4 * sin(t()+0.3), 10)
            print("n", 34, 24 + 4 * sin(t()+0.4), 11)
            print("cats", 84, 24 - 4 * sin(t()), 14)
            font_scale()
            font_center(true)
            font_outline(1, 0.5, 0.5)
            print("play", 64, 57, 9)
            print("levels", 64, 77, 9)
            font_outline()
            font_center(false)
            print("an ld43 game", 5, 100, 6)
            print("by niarkou & sam", 25, 113, 6)
        end
    elseif state == "pause" then
        font_scale(1.5)
        font_center(true)
        font_outline(1.5, 0.5, 0.5)
        print("game      ", 64, 32, 9)
        print("     over", 64, 32, 11)
        print("level "..g_ong_level, 64, 52, 3)
        font_outline(0.5, 0.5)
        --for i = 1,3 do
            --print("★ ", 64 - 30 + (i - 1)*20, 80, 10)
        --end
        font_outline()
        font_scale()
        font_center()
    end
end

function draw_world()
    -- fill spikes
    foreach(world.spikes, function(s)
        rectfill(s.x - 4, s.y + 4, s.x + 3, s.y + 4 - s.fill * 8 / g_fill_amount,
                 s.solid >= g_solid_time and 4 or 8)
    end)
    -- draw world
    palt(14, true)
    map(world.x, world.y, 8 * world.x, 8 * world.y, world.w, world.h, 128)
    palt(14, false)
    -- draw portals
    foreach(world.portals, function(p)
        local rx = p.d % 2 == 0 and 1 or 1.5
        local ry = 2.5 - rx
        for i=1,40 do
            local k = flr(rnd(128))
            local e = rnd(5)
            pset(p.x + e * rx * ct[k], p.y - 2 + e * ry * st[k], ({7, 7, 7, 12, 1})[ceil(e)])
        end
    end)
end

function draw_grass()
    map(128 - world.w, 64 - world.h, 8 * world.x, 8 * world.y - 2, world.w, world.h)
end

function draw_ui()
    font_outline(1)
    local cell = 0
    for color = 5, 1, -1 do
        if world.goal[color] and world.goal[color] > 0 then
            local x = 106 - 35 * cell
            for i=1,3 do pal(g_palette[3][i], g_palette[color][i]) end
            circfill(x - 6, 6, 4, 0)
            spr(66, x - 9, 3)
            pal()
            local c = world.saved[color] >= world.goal[color] and 11 or 14
            print(world.saved[color].."/"..world.goal[color], x, 2, c)
            cell += 1
        end
    end
    --if selectcolor > 1 then
        --local palette = g_palette[num[selectcolor]]
        --smoothrectfill(6, 3, 22, 17, 5, palette[2], 6)
        --print(world.numbercats[num[selectcolor]], 14, 4, palette[1])
    --end
    font_outline()
end

function draw_player()
    if world.lose then
        return -- do nothing, we died!
    end
    local player = world.player
    spr(68 + 2 * flr(player.walk / 8 % 4), player.x - 8, player.y - 4, 2, 1, player.dir)
end

function draw_player2()
    if world.lose then
        return -- do nothing, we died!
    end
    local player = world.player
    spr(80 + 2 * flr(player.anim / 16 % 2), player.x - 8, player.y - 11, 2, 2, player.dir)
    if selectcolorscreen then
        for i = 1, #num do
            local p = mid(world.x * 8 + #num*9, player.x, (world.x + world.w) * 8 - #num*9) - (#num-1)*7 + (i-1)*14
            local palette = g_palette[num[i]]
            rectfill((p - 4), player.y - 20, (p + 4), player.y - 12, palette[2])
            if i == 1 then
                line((p - 4), player.y - 20, (p + 4), player.y - 12, 7)
                line((p + 4), player.y - 20, (p - 4), player.y - 12, 7)
            else
                pico8_print(world.numbercats[num[i]], p - 1, player.y - 18, palette[1])
            end
            if i == selectcolor then
                rect((p - 5), player.y - 21, (p + 5), player.y - 11, 6)
            end
        end
    elseif player.call >= 2 then
        font_outline(1)
        font_scale(0.75)
        print("♪♪", player.x + 6 * cos(t() / 3), player.y - 24 - 4 * cos(t() / 2), g_palette[player.call][1])
        print("♪", player.x + 6 * sin(t() / 2), player.y - 24 - 4 * sin(t() / 3), g_palette[player.call][2])
        font_outline()
        font_scale()
    end
end

function draw_particles()
    foreach (particles, function(p)
        local t = p.age / 20
        circfill(p.x, p.y, p.r[1 + flr(t * #p.r)], p.color[1 + flr(t * #p.color)])
    end)
end

function draw_cats()
    foreach(world.cats, function(t)
        for i=1,3 do pal(g_palette[3][i], g_palette[t.color][i]) end
        spr(64 + flr(t.anim / 16 % 2), t.x - 4, t.y - 4, 1, 1, t.dir)
        spr(66, t.x - 4 + (t.dir and -2 or 2), t.y - 4 - flr(t.anim / 24 % 2), 1, 1, t.dir)
        pal()
        if t.happy and t.happy > 0 then
            palt(0,false)
            palt(15, true)
            spr(g_spr_happy, t.x - 4, t.y - 13)
            palt()
        end
    end)
end

function draw_debug()
    pico8_print("levels unlocked "..tostr(#g_levels_unlocked), 5, 5, 7)
end

__gfx__
0000000066666666f6666666666333333333366666666666f666666633333333ffffffffffffffffffffffff33333333333333333cccccccccccccc300000000
0000000066666666f6667666666666333366666666667666f666766633333333ffffffffffffffffffffffffccccc333333ccccc3cccccccccccccc300000000
0000000066666666f6667666666666633666666666667666f666766633333333ffffffffffffffffffffffffcccccc3333cccccc3cccccccccccccc300000000
0000000067766776f66666666776666336666776677666633666677633333333ffffffff3ffffffffffffff3ccccccc33ccccccc3cccccccccccccc300000000
0000000066666666f66666666666666336666666666666633666666633333333ffffffff3ffffffffffffff3ccccccc33ccccccc3cccccccccccccc300000000
0000000066666666f666766666667666f6667666666666633666666633333333ffffffff3ffffffffffffff3ccccccc33ccccccc33cccccccccccc3300000000
0000000066666666f666766666667666f6667666666666333366666633333333ffffffff33ffffffffffff33ccccccc33ccccccc333cccccccccc33300000000
00000000fffffffff666666666666666f6666666fff3333333333fff33333333ffffffff33333ffffff33333ccccccc33ccccccc333333333333333300000000
0000cccc09454490066666000000000000000000000022000000110000004400000033000000000000000000000000000c000000000000000000000000000000
0000c7760a0000a067777760000000000000000000028e200001c61000049a400003b63000000000000000000000000001d0df0d000000000000000000000000
0000c7760944459067f1f1000000000000000000000288200001cc10000499400003bb30000000000000004540000000111d11d1000000000000000000000000
0000c6660a0000a006ffff0000000000000000000002e82000016c100004a94000036b30000000000044004d4404450001d01011000000000000000000000000
cccc000009544490008ff800000000000000000000288820001ccc1000499940003bbb3000000000054444454444d4400000000000f0000000c00000000000c0
c77600000a0000a00888888f00000000000000000288e82001cc6c100499a94003bb6b300000000004d5455d5544544000000000d01d0dc0001d000000000d10
c7760000094454900ff888ff000000000000000002e88200016cc10004a99400036bb300000000000444522112d544000000000011d1d1d1d1d1d0000001d11d
c66600000a0000a000cc0cc000000000000000000022200000111000004440000033300000000000004d21111112540000000000010101100101d00000010d10
0944459000000000000000000000000000000000f00f00ff00c100000000000000001c0000006000044511101011d44000c00000000000c00000000000000000
0a0000a00000000000000000000000000000000007e0820f0c6c1600099999900061c6c0000666004452110101012544001d000000000d100000000000000000
09454490000000000000000000000000000000000e88820f0c6c1060966666690601c6c000606060d5d11010101115451dd1d0000001d1110000000000000000
0a0000a000000000000000000000000000000000f08820ff0c6c6666899999986666c6c0088868804451010101011d54010100000001010d0000000000000000
0000000009444590000000000000000000000000ff020fff0c6c1060088688800601c6c089999998045210000011254400000000000000000000000000000000
000000000a0000a0000000000000000000000000fff0ffff0c6c1600060606000061c6c096666669045101000001154000000000000000000000000000000000
0000000009454490000000000000000000000000ffffffff0c6c1000006660000001c6c00999999044d1100000101d4000000000000000000000000000000000
000000000a0000a0000000000000000000000000ffffffff00c100000006000000001c0000000000d45101000001155400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089898989
00007000000770000007770000070000000777000000770000077700000070000000700000700700007007000070770000000000000000000000000098989898
00077000000007000000070000070700000700000007000000000700000707000007070007707070077077000770007000000000000000000000000089898989
00007000000070000000700000077700000770000007700000007000000070000000770000707070007007000070070000000000000000000000000098989898
00007000000700000000070000000700000007000007070000007000000707000000070000707070007007000070700000000000000000000000000089898989
00007000000777000007700000000700000770000000700000007000000070000007700000700700007007000070777000000000000000000000000098989898
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089898989
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000098989898
00000000000000000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000160161000000000000022200000000000000000000000000000222000000000000000000000000000000000000000000000000000000000
000000000000000016cccc1000000000000028822800000000002220000000000002888228000000000022200000000000000000000000000000000000000000
11000000000000001cc7c710000000000002886ff820000000008882282e00000028886ff8200000000e28822820000000000000000000000000000000000000
cc1111001111110001c7c71000000000000286fff820000000066ff8882e0000002886fff8200000000e28886fff000000000000000000000000000000000000
01cc6c10cc6c6c1001cccc10000000000000286f882000000006ff8882c100000002286f880000000001128886ff100000000000000000000000000000000000
016cc1000cccc1000011110000000000000001c1ccc10000001cf2882cc10000000001ccc1c10000001cc12222c1000000000000000000000000000000000000
0c1c10c001c1c1000000000000000000000000111110000000011000111000000000001111100000000110001110000000000000000000000000000000000000
00000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006777777600000000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00067777777760000000667777660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677777766660000006777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006776676fff00000067777776676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00676ff6ff1f0000006776676ff60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088fff6ff15500000866ff6ff1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0678ffffeefff0000088fff6ff155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06776fffeeff000006776fffeefff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066000ffff0000006776fffeeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000066000ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300
f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300407070707070
70707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000
000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f3232300707070707070707070d0f300
f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000
000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000090f300
f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070
701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707000000000000000000090f300
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f3000000f3f3f3f3f3f3f3f3f3f3f300
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000070707070707070707070f300
f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300407070707070
70707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300407000000000000000000000f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000000000f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000070707070707011117070f300
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000
000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323
f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000
000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361
f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070
701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300
f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300407070707070
70707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000
000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323230000000000000000000000f323
f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000
000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361510000000000000000000000f361
f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070
701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370707070707070701111707070f370
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300
f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000
001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300000000000000001111000000f300
f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300407070707070
70707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f30040707070707070707070d0d0f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000
000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300000000000000000000009090f300
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
__gff__
00000000000000000000000000000000869f0000000000000000808000000000939c0000a000000000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f070707070707070707070707073f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f32
3f070707070707070707070707073f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f16
3f070704010101010101010101013f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f07
3f07070207070807070c0b0708073f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f07070207070807070d0e0708073f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f010105070708070707070708073f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00
3f07070707070908080808080a073f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f070707070707070707070707073f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f07
3f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f00
3f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f00
3f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00
3f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f32
3f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f16
3f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f07
3f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00040707070707070707070d0d3f00
3f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f000000000000000000000009093f00
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f323200000000000000000000003f32
3f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f161500000000000000000000003f16
3f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f070707070707070711110707073f07
3f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f000000000000000011110000003f00
