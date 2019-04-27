pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ld44
-- by niarkou and sam

#include escarlib/p8u.lua
#include escarlib/btn.lua
#include escarlib/draw.lua
#include escarlib/random.lua
#include escarlib/fonts/double_homicide.lua
#include escarlib/font.lua
load_font(double_homicide,14)

#include collisions.lua

mode = {
    test = {},
    menu = {},
    play = {},
}

#include mode_test.lua
#include mode_menu.lua
#include mode_play.lua

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

-- world
world = {}
game = {}

function new_game()
    game = {}
    game.world = new_world()
    game.player = { x = 11, y = 9 }
end

function new_world()
    world.score = 0
    return world
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

--
-- useful functions
--

function jump()
    if btn(2) or btn(g_btn_jump) then
        return true end
end

--
-- standard pico-8 workflow
--

function _init()
    poke(0x5f34, 1)
    cartdata("ld44")
    new_game()
    state = "test"
end

function _update60()
    mode[state].update()
end

function _draw()
    mode[state].draw()
end

function draw_world()
    local x = flr(game.player.x - 10)
    local y = flr(game.player.y - 10)
    map(x, y, x * 8, y * 8, 20, 20)
end

function draw_ui()
end

function draw_player()
    spr(18, game.player.x * 8, game.player.y * 8)
end

--
-- moving
--

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

function update_player()
    if world.lose then
        return -- do nothing, we died!
    end
    if not btn(g_btn_call) then
        selectcolor = 1
        update_entity(game.player, btn(0), btn(1), jump(), btn(3))
        selectcolorscreen = false
    elseif btn(g_btn_call) then
        update_entity(game.player)
        selectcolorscreen = true
        if btnp(0) and selectcolor > 1 then
            sfx(g_sfx_navigate)
            selectcolor -= 1
        elseif btnp(1) and selectcolor < #num then
            sfx(g_sfx_navigate)
            selectcolor += 1
        end
        game.player.call = num[selectcolor]
    end
    -- did we die in spikes or some other trap?
    if trap(game.player.x - 2, game.player.y) or
       trap(game.player.x + 2, game.player.y) then
        sfx(g_sfx_death)
        world.lose = g_lose_frames
        death_particles(game.player.x, game.player.y)
    end
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
