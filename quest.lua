
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
            { x=13, y=5, text="Today I made my fisrt sign!⬇️Hope someone will read it.⬇️I am so exited!" },
            { x=15, y=5, text="What kind of shorts do clouds wear?⬇️...⬇️Thunderwear." },
            { x=17, y=5, text="If you like my funny puns, don't forget to engrave a thumb up" },
            { x=19, y=5, text="Would you like to hear a construction joke?⬇️...⬇️Still working on it." },
            { x=21, y=5, text="To support my work, you can also tip me." },
            { x=23, y=5, text="Can a kangaroo jump higher than a cliff?⬇️...⬇️Of course, cliffs can't jump!" },
            { x=25, y=5, text="To the person who invented zero: thanks for nothing." },
            { x=27, y=5, text="I find potatoes jokes very appeeling." },
            { x=27, y=5, text="What do you call a man with a rubber toe?⬇️...⬇️Roberto." },
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

