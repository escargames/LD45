mode.gameover = {}
mode.story = {}

function mode.gameover.start()
    animation = 0
end

function mode.gameover.update()
    animation += 1/60
    if (animation > 2) and cbtnp(g_btn_confirm) then
        state = "menu"
    end
end

function mode.gameover.draw()
    local dx = flr(min(animation, 1) * 56)
    local dy = flr(min(animation, 1) * 36)
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 4)
    dx -= 4 dy -= 3
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 9)

    font_outline(1)
    if animation >= 1.2 then
        print("Game Over", 40, 38, 8)
    end
    if animation >= 1.5 then
        print("You did well !", 26, 52, 15)
        if game.story < 8 then
            print("Alas, Cookie was", 16, 64, 15)
            print("nowhere to be found.", 16, 74, 15)
            print("Maybe next time?", 16, 84, 15)
        end
    end
    font_outline()
end

function mode.story.start()
    game.story += 1
    animation = 0
    gametexts = {
        {
            w = 116, h = 112,
            "Your poster is still",
            "here, but no one called.",
            "",
            "         MISSING:",
            "           Cookie",
            "",
            "My sweet Cookie",
            "disappeared last night.\nDescription: the cutest.\nPlease call Grandma."
        }, {
            w = 110, h = 40,
            "Keep finding cats",
            "but Cookie's still",
            "nowhere to be found.",
        }, {
            w = 110, h = 40,
            "When I find him, I am",
            "going to cuddle the",
            "shit out of him.",
        }, {
            w = 114, h = 60,
            "The moving could have",
            "scared him. The new",
            "house is not what he's",
            "used to. I really hope",
            "he's okay.",
        }, {
            w = 122, h = 56,
            "Cookie, if you come back","I'll never grumble again","when you sharpen your","claws on the wall.","Promise."
        }, {
            w = 96, h = 50,
            "There is tuna fish", "waiting for you in", "the house.", "Your favorite.",
        }, {
            w = 100, h = 32,
            "I'll let you sleep on", "the bed next to me.",
        }, {
            w = 110, h = 86,
            "Cookie! You had me","worried sick! Missed","your friend from the","old house huh?",
            "","Come on, there's","plenty of room","for both of you."
        }
    }
end

function mode.story.update()
    animation += 1/60
    if (animation > 2) and cbtnp(g_btn_confirm) then
        prev_state = "test"
        state = "test"
    end
end

function mode.story.draw()
    local gt = gametexts[game.story]
    local dx = flr(min(animation, 1) * gt.w / 2)
    local dy = flr(min(animation, 1) * gt.h / 2)
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 1)
    dx -= 3 dy -= 3
    smoothrectfill(64 - dx, 64 - dy, 64 + dx, 64 + dy, 5, 13)

    font_outline(1)
    for i=1,#gt do
        if animation > 1 + i / 5 then
            print(gt[i], 64 - gt.w / 2 + 6, 64 - gt.h / 2 - 2 + 9 * i, 12)
        end
    end
    font_outline()
end

