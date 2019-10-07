
function new_quest()
    return {
        start = { x=11.5, y=6.5 },
        -- a chest
        chests = {
            { x=25, y=07, item="boots",
              text="You found a pair of boots!" },
            { x=18, y=09, item="rope",
              text="You found a rope!" },
            { x=34, y=15, item="",
              text="The chest was empty, lol!" },
        },
        keys = {
            { x=11, y=19 },
            { x=18, y=21 },
        },
        signs = {
            { x=13, y=5, text={"Today I made my fisrt sign!\nHope someone will read it.\nI am so exited!"} },
            { x=15, y=5, text={"Oh no, there's a spelling\nmistake in my first sign..."} },
            { x=17, y=5, text={"What kind of shorts do\nclouds wear?","...","Thunderwear."} },
            { x=19, y=5, text={"If you like my funny puns,\ndon't forget to engrave a\nthumb up."} },
            { x=21, y=2, text={"Would you like to hear\na construction joke?","...","Still working on it."} },
            { x=23, y=2, text={"To support my work,\nyou can also tip me."} },
            { x=25, y=2, text={"Can a kangaroo jump higher\nthan a cliff?","...","Of course, cliffs can't jump!"} },
            { x=27, y=5, text={"To the person who invented\nzero: thanks for nothing."} },
            { x=29, y=5, text={"I find potatoes jokes\nvery appeeling."} },
            { x=31, y=5, text={"What do you call a man with\na rubber toe?","...","Roberto."} },
        },
        living = {
            { x=12, y=10, id=g_id_cat, dir=1, name="Botox" },
            { x=14, y=8, id=g_id_raccoon, dir=0, name="Lulu" },
            { x=15, y=3, id=g_id_person, name="Yoyo" },
        },
    }
end

function init_quest(q)
    game.inventory = {
        nkeys = 0
    }
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

function quest_collect(q,o)
    if o.id==g_spr_key then
        --open_message("You found a key!", g_style_center, function()game.inventory.nkeys+=1 end)
        sfx(g_sfx_key)
        game.inventory.nkeys += 1
        del(game.specials,o)
    end
end

-- Activate a quest object
function quest_activate(q,o)
    if o.id==g_spr_sign then
        sfx(g_sfx_select)
        if game.player.dir==3 then
            open_message("The text is on the other\nside of the sign!",g_style_center)
        else
            foreach(o.data.text, function(t) open_message(t,g_style_bottom) end)
        end
    elseif o.id==g_spr_chest then
        if game.inventory.nkeys>0 then
            sfx(g_sfx_loot1)
            sfx(g_sfx_loot2)
            open_message(o.data.text,g_style_center)
            game.inventory.nkeys -= 1
            game.inventory[o.data.item] = true
            o.id=g_spr_chest_open
        else
            open_message("The chest is locked.",g_style_center)
        end
    elseif o.id==g_id_cat then
        sfx(g_sfx_pet)
        open_message("You pet "..o.name.." the\ncat. How adorable! ♥",g_style_center)
    elseif o.id==g_id_raccoon then
        sfx(g_sfx_pet)
        open_message("You pet "..o.name.." the\nraccoon. How cute! ♥",g_style_center)
    end
end

