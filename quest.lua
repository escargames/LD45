
function new_quest()
    return {
        start = { x=11.5, y=6.5 },
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
            { x=13, y=5, text="Why hello there!⬇️Yes it's me!" },
            { x=15, y=5, text="What?" },
            { x=17, y=5, text="Wootwoot" },
            { x=19, y=5, text="Hello again" },
        },
        living = {
            { x=12, y=9, id=g_id_cat, dir=1, name="Botox" },
            { x=14, y=7, id=g_id_raccoon, dir=0, name="Lulu" },
            { x=14, y=3, id=g_id_person, name="Yoyo" },
        },
    }
end

function init_quest(q)
    foreach(q.chests, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, id=g_spr_chest, data=o, xoff=-4, yoff=-4 })
    end)
    foreach(q.keys, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, id=g_spr_key, data=o, xoff=-4, yoff=-4 })
    end)
    foreach(q.signs, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, id=g_spr_sign, data=o, xoff=-4, yoff=-6 })
    end)
    foreach(q.living, function(o)
        add(game.specials, new_living(o.x, o.y, o.dir or 3, o.id, o.name))
    end)
end

function update_quest(q)

end

