
function new_quest()
    return {
        start = { x=12.5, y=8.5 },
        -- a chest
        chests = {
            { x=18, y=09, item="boots",
              text="You found a pair of boots!" },
            { x=25, y=07, item="rope",
              text="You found a rope!" },
            { x=34, y=15, item="",
              text="The chest was empty, lol!" },
        },
        keys = {
            { x=18, y=21 },
        },
        signs = {
            { x=13, y=5, text="Why hello there!" },
            { x=15, y=5, text="What?" },
            { x=17, y=5, text="Wootwoot" },
            { x=19, y=5, text="Hello again" },
        },
    }
end

function init_quest(q)
    foreach(q.chests, function(s)
        add(game.specials, { x=s.x+.5, y=s.y+.5, id=g_spr_chest, xoff=-4, yoff=-4 })
    end)
    foreach(q.keys, function(s)
        add(game.specials, { x=s.x+.5, y=s.y+.5, id=g_spr_key, xoff=-4, yoff=-4 })
    end)
    foreach(q.signs, function(s)
        add(game.specials, { x=s.x+.5, y=s.y+.5, id=g_spr_sign, xoff=-4, yoff=-6 })
    end)
end

function update_quest(q)

end

