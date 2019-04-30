pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ld44
-- by niarkou and sam

#include escarlib/p8u.lua
--#include escarlib/logo.lua
#include escarlib/btn.lua
#include escarlib/draw.lua
--#include escarlib/print.lua
#include escarlib/random.lua
--#include escarlib/fonts/double_homicide.lua
#include escarlib/fonts/lilabit.lua
#include escarlib/font.lua
--load_font(double_homicide,14)
load_font(lilabit,14)

#include map.lua
#include collisions.lua
#include constants.lua

mode = {}
#include mode_test.lua
#include mode_menu.lua
#include mode_play.lua
#include mode_extra.lua

function _init()
    poke(0x5f34, 1)
    cartdata("ld44")
    state = "menu"
    music(2, 300)
end

function _update60()
    if state != prev_state then
        mode[state].start()
        prev_state = state
    end
    mode[state].update()
end

function _draw()
    mode[prev_state].draw()
end

__gfx__
0000000033b33b335555555133333b3333b3333355555551555555513333b3b366653333333333333333b3b333333ccccc733333ccccccccccccccccffffffff
0000000055555555555555515555333bb3335555555555515555555533333b336665366db3b3366d36653b3333ccccccccc7c733ccc7cccccc7cccccffff8fff
00000000555555555556555155555533335555555556555155565555b3b3333355d336653b333665365d33333ccccccccccc7c73ccccccccccccc6ccfff8a8ff
000000005566655555565551555555133555555556655551555566553b3333333336655d3336655d333365333cccccc6ccccc7c3ccccc6cccccc7cccfff383ff
000000005555555555565551566555515555665555555553355555553333b3b3333665333336653366d35533cc6cccccc6cccc7ccccccc7cccccccccfff3b3ff
0000000055555555555555515556555155565555555551333355555533333b333665d6633665d66366533665ccccccccccccccc7cccccccccc7cccccfff3b3ff
000000001111111155555551555555515555555511113b3b33331111b3b33333366636533666365355533665cccccc7cccc7cccccc6ccccccccc6cccfff333ff
0000000033b33333555555515555555155555551333333b33b3333333b333333355533333555333333333553ccccccccccccccccccccccccccccccccffffffff
fffffff00ffffffff000000ff000000ffff00ffff000000fffffffff94949494333336653333366566533333cccccccccc6cccccccccccccccccccccffffffff
fffff004200fffff0133d31003bbdb30ff0be0ff02222220ffffffff555555553665366533653665665366d3cccc6cccccccccccccccccccccc7ccccffffffff
fff0042428200fff03d333100bdbbb30f0ebbb0f04444420ffffff0f55555555365d355d335d355d5d336653dccccccccccccccccc7ccc6cccccccccffefffff
f00424442828200f033331d00bbbb3d00bbbb38004222420fff009b0556665553333653333336533336655d3cdccccccc7ccccccccccccccc6ccccccfe7effff
04242424282828e0033d31100bbdb3300bbeb33004444420f00ab0b05555555566d3553333335533336653333cdcccc7ccccccc3c6ccccccccccdcccf3e3ffff
04244424288828e0f043120ff04b320f0b4b3230f004200ffab0b0b09494949466533665b3b33665665d33333dcdcccccccc7c33ccccc7ccccccccccf3b3ffff
0424244428ee28e0f044420ff044420ff004400fff0420ffffb0ffffc4c4c4c4555336653b3336656663b3b333dcdcccccccc333cccccc6cccccccccf3b3ffff
04242426622e2ee0ff0000ffff0000fffff00ffffff00fffffffffffcccccccc333335533333355355533b3333333dccccc33333ccccccccccccccccf333ffff
0442266666622ee0ff0000ffff0000ffffffffffff000000000000ff45555554ff00ffffffffffffff0ffffff000000ffff0000ff0000fffffffffffffffffff
04066666666660e0f042e20ff051d10fff0000fff01111111111110f95555559f0770ffffffffffff0ba00ff01111110ff03bbb00bb330fffffffffffffff9ff
00666662262267000442eee00551ddd0f051d10ff05dddddddddd10f4556555406d770fffff000fff0b0b9ff05dddd10f03bbbb3b3b3330fffff2fffffef939f
f06666624624670f042222e0051111d00551ddd0f05dddddddddd10f955655590667770fff06770ff0b0bfff05555510f0bbabbbbbbb330ffff262fffe8e393f
f06622677677670f0666666006666660051111d0f05dddddddddd10f455655540d667770f0d66770f0b0bfff0000000003bb93bbab3b3330fff323fff3e33b3f
f07624666666670f067667600676676006766760f05dddddddddd10f955555590d666d70f0d66d70ffffffff0d7767700bbbbbbbbb3bb330fff3b3fff3b33b3f
f07724777557770f065665600656656006566560f05555555555510f45555554f0d6660fff0d660fffffffff0d5565500bbbbbb9b3b33330fff3b3fff3b3333f
ff000000000000fff000000ff000000ff000000ff00000000000000f95555559ff0000fffff000ffffffffff0d6666600babbbb23333a330fff333fff333ffff
ffffffffffffffff0d666660f0d666666666660ff0d666666666660f33b33b335555555155555551555555510d666660f0bb90b20322330f3333333322998899
ffffffffffffffff0d767670f0d677676777660ff0d677676777660f555555555556555555565551555655550d767670ff0bb20b032330ff33b333b322998899
ffffffffffffffff0d565650f0d655656555660ff0d655656555660f555555555556555555565551555655550d565650fff0bb2332200fff3333333399229988
ffffffffffffffff0d666660f0d666666666660ff0d666666666660f566566555665665556655551555566550d666660ffff0004220fffff3b333b3399229988
ffffffffffffffff0d650560f0d650505666660ff0d666666666660f555655555555555555565551555655550d666660ffffff04220fffff33b3b33388992299
ffffffffffffffff0d607060f0d607070666660ff0d776776776760f555655555555555555565551555655550d776770fffff0444220ffff333b333388992299
ffffffffffffffff0dd070d0f0dd07070ddddd0ff0d556556556560f555555511111111155555551555555510d556550fffff0444420ffff3b3333b399889922
fffffffffffffffff000000fff000000000000fff0d666666666660f555555513333333355555551555555510d666660ffffff00000fffff3333333399889922
55550555500555555555555555000055550000555500005555555555555555555555555555555555555555555555555555555555555555555555555555555555
55003005040555555005005550777705507777055077770555000555555555555555555555555555555555555555555555555555555555555555555555555555
50883bb009a0555508e0e70507766660067777700666667050c67055555555555555555555555555555555555555555555555555555555555555555555555555
08ee8b0509aa05550288880507660005066777700600006050cc6055555151555555555555555555555555555555555555555555555555555555555555555555
08e8880509aaa005502880550600f2f000666600002ff20050dcc055551515155555555555555555555555555555555555555555555555555555555555555555
02888805509aaaa05502055550fff4f00f0000f00f4ff4f055000555515151515555555555555555555555555555555555555555555555555555555555555555
502280555509aa0555505555550fff0550ffff0550ffff0555555555551515155555555555555555555555555555555555555555555555555555555555555555
55000555555000555555555555500055550000555500005555555555555151555555555555555555555555555555555555555555555555555555555555555555
50055555555005555550055555500555555005555550055555555555555555555555555555555555555555555555555555555555555555555555555555555555
06705555550aa0555502805555028055550280555502805555500555555055555555555555555555555555555555555555555555555555555555555555555555
0d6705005509a05550028055550280555502800550028055550aa055550a05555555555555555555555555555555555555555555555555555555555555555555
50d670a0550990550f04800555008055500480f00f04800550499a05550905555555555555555555555555555555555555555555555555555555555555555555
550d6a0555049055504800f0550f00550f048005500480f050499a05550905555555555555555555555555555555555555555555555555555555555555555555
55509c055550055550c4700550707c0550c4170550714c0555044055550405555555555555555555555555555555555555555555555555555555555555555555
550900c0550490555507c05550c000555500dc0550cd005555500555555055555555555555555555555555555555555555555555555555555555555555555555
55005500555005555550055555055555555500555500555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55000555000555555555555555555555dd5555555555555555555555555555555505505555555555555555555505505555555555555555555555555555555555
50ee7050e7705555d555555d5555555500d555555555555555555555555555555095090555555555555555555065060555555555555555555555555555555555
5088e70288e055550d5555d055dddd55500ddd55555dddd5555555555555555509444405055555555555555506dddd0555555555555555555555555555555555
0e888828888e055550dddd055d0000d5500000d555d00005005555555555555504474705d0555555005555550d07070555555555555555555555555555555555
02888888888e05555000000550000005550000055d0000004400005500000055504747050d000055d00000555061016055555555555555555555555555555555
02888888888e055555000055d050050d55500000500000555044940544949405504444055d060d0506060d0550dd6d0555555555555555555555555555555555
5028888888805555555005550555555055550005d0000555509440555444405555000055506dd0555dddd0555500005555555555555555555555555555555555
5028888888e05555555005555555555555550055000555555404054550404055555555555d0d05d550d0d0555555555555555555555555555555555555555555
550288888e0555555555555555555555555555555555555555555555555555550666660000666660000000000000000000100100009933330099333000000000
55502888e05555555550055555555555555005555555555555500555555555556777776006777776000000000000000001601610044493000444930300000000
5555002005555555550ee055555555555506605555555555550aa0555555555567f1f100067f1f10000000000000000016cccc10444549004445490000000000
555555055555555550e86e0555000055506c76055500005550a96a055500005506ffff00006ffff011000000000000001cc7c710454444904544449000000000
555555555555555550888e0550eeee0550ccc6055066660550999a0550aaaa0500dffd0000dffd00cc1111001111110001c7c710344444403444444000003300
555555555555555550288e05028886e0501cc60501ccc76050499a05049996a00ddddddfddddddf001cc6c10cc6c6c1001cccc10334544433345444300033530
555555555555555550228805022288805011cc050111ccc050449905044499900ffdddffffdddff0016cc1000cccc10000111100300444333004443000035300
555555555555555555000055500000055500005550000005550000555000000500c70c700c70c7000c1c10c001c1c10000000000300003300300030000003000
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f300f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070707070707070707070707070707000000000e200000000000000000000f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70e370e3707070e3707070707070e37000000000000000000000410000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070707070707070707070707070707000f14100000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070707070707070e3707070707000000000000000f200000000000000f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
10101010101030e370707070707070700000000000000000000000e200000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070707070207070e37070707070700000000000000000f000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070e3702070707070707070e37000f0000000000000000000000000f100f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070e370702070707070e37070707000000000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
e3707070707020707070e3707070707000000000e20000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070707070207070e370707070707000000000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70e3707070702070707070707070707000000000000000f100000000e2000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070e37070702070707070e37070e370f100000000000000000000000000f000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070707070702070e370707070707070000000f0000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070401010105070707070707070e37080900000000000a0a18180a090a19181f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
e370207070e37070e3e37070e370707000000000f00000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70702070707070707070707070707070000000000000000000000000f2000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
__gff__
0000000000000000000000101010100001010101010100000000001010101000010101010101010001010001010100000101010101010100000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f132c2d130713070713071307073f2c2d07101107070710110707073f070702070707070707220707073f070707070707020707070707073f07070707072526072b070707073f070707070207070707070707073f072c2d070707070707070707073f070707070b0d0d0e0c070707073f0707020707073e070707073e073f3f
3f073c3d141307070707070707073f3c3d07202124222320210715073f2c2d020b0d0e1e1d0d0e1e0c073f073e2c2d073e021207232207073f070723070733340732230707073f070704013923070707070707073f073c3d07072c2d0707072c2d073f0707070b0e1d1c1b1c070707073f3e0702252607072526070707073f3f
3f071307101107070707040101013f072804010101010101010101013f3c3d0617010101010103071d073f07073c3d070702073e1a2c2d073f01010101010101010101032b073f072402240207070401031507073f07070707153c3d0707073c3d073f0101030d0d0d0c0401010101013f073e023334252635360707073e3f3f
3f131407202107071407020707073f0707022c2d072c2d0b0e0c07073f0707220e071011101102151e073f070707070707021307073c3d073f2526072b25262526252602322b3f070706010524070223020707073f07072c2d0707072c2d070707073f0707020d0d0d0d270d0e0c18073f0812022526353635363e0707073f3f
3f071307190808180818020707133f2324023c3d073c3d0d0d1d0a073f07070b1c142021202102070e073f010101031011020707070707073f353623323536353633340207323f070724070b0c2202223a0101013f07073c3d0707073c3d070707073f0707021b0d0d1c021b1e1c18073f181402333433343334070707073f3f
3f2c2d07070707070707390707073f01010518180a13241b1e1c08073f07071d13040101010105140d073f281a0802202102072c2d073e073f353604033334333404013837033f070b0d0d0e0d230207022407073f070707072c2d070707040101013f070706011701010507070708073f09280601010101010310113e073f3f
3f3c3d14070707070707020707073f07070707071908180818081a073f07071b1e270e0d1d1e0e0d1c073f29190a06010139143c3d0707073f333406380101010139072b06053f070d1e1e0d0e070601050707073f072c2d073c3d072c2d020707073f070b0d0d0d0c07070715081a073f1a0a08180b0e0d0c02202107073f3f
3f070714141307070707020713073f070707070707070707070707073f070707070207070707070707073f073e07070707020707070707073f070707070707070702233207073f071b0d0d0d1c072422220707073f073c3d070707073c3d020707073f071b0e0e0e1c070707070707073f232224071b1e1d1c02290707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f07070707073e070707070707073f07070b0c0207070707070707073f07070707070702070707073e073f070707070601010307070707073f070707070712070707070707073f070707020707070707070707073f070707073e07070707073e07073f070702070707280707073e07073f070707070707020707070707073f3f
3f120704010101010101010307073f073e1d1e02073e0707141328073f07073e07101102073e070707073f073e2c2d072c2d02073e072c2d3f07293e140a0819080907283e123f3e070702252607073e070713073f072204010101010101030707073f142902073e070b0d1e0c0714073f0725262b25260207070707073e3f3f
3f070702280707101107280207073f07070d0e3a010103070707073e3f3e070707202102290707073e073f07073c3d073c3d020707073c3d3f07070707180b1e0c1a070707073f07101102353625262b072807073f010105252610111011021207073f0729021307220e281b1c0707073f3e35363b3536021225262b3e073f3f
3f073e06033e07202107070207133f07281d1e0214123a01010307073f070707040101380101010101013f0707072c2d0707021011073e073f010101010117171701010101013f07202102333435363b070707073f0707073334202120210207073e3f070706010101170101031307073f073334323536021335363b07073f3f
3f07072802071409143e070207073f07070e1e0601010513140601013f070728022212241323142422073f3e07073c3d3e070220210401013f07133e070a1b0e1c0a071413073f01010138010335363b2b3e07073f07133e070401010101050707073f073e070707290d290702073e073f0101010333340212333432073e3f3f
3f0101010507140a140707023e073f073e0d0e0d1d1e0d0e0d0c07073f07070405080a1a0918190a0a073f070401010101013801010507073f072807071a18190908070707073f0707232526023334323207073e3f070707070225262b25260707073f07140b0c07071d0707060101013f07252606010105080a191a07073f3f
3f07073e070714081407070207073f07071b1d1e0d0e0d1d1e1c3e073f073e02071422132412222214073f070214131312141312121407073f07070713283e14070707293e073f07073e333406010101030707073f07071407023334323334073e073f07070e1d0d1e1c1307070728283f07333425262b0707073e0707073f3f
3f07290707070707073e070207073f0707073e0707070707070707073f0707020707070707073e0707073f070214070707070707073e07073f3e0707070707070712070707073f070707073e0707072202073e073f3e0707070207070707070707073f3e071b1c28070707073e0707073f3e0707333432070707070707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f2c2d073f070207073f07140207243f1011073f07022c2d3f2c2d07073f0714072224073f070702073f072526252625260207070707073f070707070707072526252625263f07150b0c073f0728043907073f07070707073e073f0704010103073e3f07073e070707073f3f3f3f3f3f3f0707073e0707070707070707073f3f
3f3c3d243f070603133f01010507073f2021243f07023c3d3f3c3d2c2d3f0101010101013f072202133f3e35363536353602073e0707073f07070707073e073536353635363f0101170d3e3f0728020207133f070403072229073f070222230207073f07040103290a283f3f3f3f3f3f3f070b0d1e0e0d1e1d0c073e07073f3f
3f0101013f101102133f14070723073f2c2d073f070207223f07073c3d3f0707130707073f220405073f07333433343536020707073e073f101112131011143334333433343f073e1b1c073f0722060507073f0138053e0707073f070601013801013f07022802070a073f3f3f3f3f3f3f3e0e18191a0a09081d070707073f3f
3f242c2d3f202102073f3f3f3f3f3f3f3c3d073f070601013f070401013f3f3f3f3f3f3f3f010507243f010101010333340212070707073f202122232021040101010101013f3f3f3f3f3f3f07070707073e3f070707071407073f073e07070713073f07060139070a073f3f3f3f3f3f3f070d08070707131a0e0710113e3f3f
3f073c3d3f3f3f3f3f3f07240401013f0103073f2c2d2c2d3f07022c2d3f0707020723243f071307073f071410110601013925260707073f010101010101392526192526073f070707073e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f071407073e07073f3e0707020707073f3f3f3f3f3f3f071d0914070707181e072021073f3f
3f3f3f3f3f070213073f0101052c2d3f0702073f3c3d3c3d3f07023c3d3f0704050707243f3f3f3f3f3f07072021131011023334073e073f072526252629023536083334073f18090a3e073f0707142c2d07073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3e1e19040101010101010101013f3f
3f1313133f140207073f1307073c3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0702130707073f3f3f3f3f3f07073e070720210601030707073f073334333407023334090707073f1a280103073f0707133c3d01013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f071b0d022907070728073e07073f3f
3f0101013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f073e07070707070707020707073f0707070707070209081a0707073f0a190802073f101107070715073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0707070207073e1207070707073f3f
3f1314133f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f202107070707073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
__sfx__
0105000009317163171d3170000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
0104000029317253172131722317293172f3170000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
010200000b6100d6100e6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000155510f551081511b5011f5011a5010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000f0000f0001800018000180000e0000e00018000180000d0000d0000b0000b0000e0000e0000e00000000130001300018000180001200012000100001000013000130001300012000120001200012000
01140000000000000014000140000c00015000150001400014000177001770012000120001500015000150000c0001a0001a0001900019000177001770017000170001a0001a0001a00019000190001900019000
011600000e54415540005021a5401d54015540215401c502225401a54022540165400e54015540005001a5401d54015540215401c500225401a5402254016540135401a5401f5001f540225401a5402654000500
01160000275402b540275401b5401f5401a540265001b5401f5401b540275402b540265401c5000e54015540005001a5401d540155402154000500225401a5402254016540155401354011540105400e5400e545
011600000252002520025200000000000000000000000000000000000000000000000252002520025200000000000000000000000000000000000000000000000752007520075200000000000000000000000000
011600000000000000000000000007500075000750000000000000000000000135001350013500000000000000000000000000000000000000000000000000000000000000000000000000000000000252002520
011600002254000000225401a5402254021540195001f540000001f540185401f5401d540000001b540000001b540155401b5401a540225401a54022540215401a5001f540000001f540185401f5401d5401a500
011600000252002520025200000000000000000000000000000000000000000000000252002520025200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000e050150501a0501c0501d05021050220001d0501c0501a0501c0501d05022050000001d050210501d0501c0501a0501805000000160501a050160501805016050150500000015050150501805018000
0114000002020090200e0201002011020150200000011020100200e02010020110201602000000110201502011020100200e0200c020000000a0200e0200a0200c0200a020090200900009020090200c02000000
011400002671026710267102671026710267102110029710297102971029710297102971000000247102471024710247102471024710247002271022710227102271022710227100000021710217102171000000
011400001d03024030290302b0302c03030030220002c0302b030290302b0302c03031030000002c030300302c0302b0302903027030000002503029030250302703025030240300000024030240302703018000
0114000011020180201d0201f020200202402022000200201f0201d0201f0202002025020000002002024020200201f0201d0201b02000000190201d020190201b02019020180200000018020180201b02018000
011400003271032710327103271032710327102110035710357103571035710357103571000000307103071030710307103071030710247002e7102e7102e7102e7102e7102e710000002d7102d7102d71000000
011300000e050150501a0501c0501d05021050220001d0501c0501a0501c0501d05022050000001d050210501d0501c0501a0501805000000160501a050160501805016050150500000015050150501805018000
0113000002020090200e0201002011020150200000011020100200e02010020110201602000000110201502011020100200e0200c020000000a0200e0200a0200c0200a020090200900009020090200c02000000
011300002671026710267102671026710267102110029710297102971029710297102971000000247102471024710247102471024710247002271022710227102271022710227100000021710217102171000000
011300001d03024030290302b0302c03030030220002c0302b030290302b0302c03031030000002c030300302c0302b0302903027030000002503029030250302703025030240300000024030240302703018000
0113000011020180201d0201f020200202402022000200201f0201d0201f0202002025020000002002024020200201f0201d0201b02000000190201d020190201b02019020180200000018020180201b02018000
011300003271032710327103271032710327102110035710357103571035710357103571000000307103071030710307103071030710247002e7102e7102e7102e7102e7102e710000002d7102d7102d71000000
__music__
01 0c0e4c4d
02 0d0f4344
01 14555444
00 54154344
00 14151644
00 57151657
00 17155644
00 57184344
00 57181644
00 1a1b4344
00 5a1b1c44
00 411b5c44
00 1d1b5c44
00 5d1e4344
02 5d1e1c44

