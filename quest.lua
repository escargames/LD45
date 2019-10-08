
function new_quest()
    return {
        start = { x=5, y=28 },
        --start = { x=15, y=26 },
        -- a chest
        chests = {
            { x=52, y=10, item="ball",
              text="You found a ball\n for the cats" },
            { x=18, y=09, item="boots",
              text="You found a pair of boots!\nYou can now jump with ❎." },
            { x=9, y=34, item="suit",
              text="You found a bathing suit!\nYou can now swim." },
            { x=66.5, y=8, item="gloves",
              text="You found a pair of\ngloves! You can now\npush boulders with 🅾️." },
        },
        boulders = {
            10,13,  11,13,  12,15,  13,13,  11,31,  14,30,  12,32,  13,30,  12,30,  11,33,  13,33,  15,32,  15,33,
            12,34,  14,31,  6,32,  14,32,  1,37,
            0,38,  2,38,  6,44,  7,43,
            23,38,  23,37,  24,37,  20,40,  21,40,  22,40,  23,40,  24,40,  21,41,  23,41,  20,42,  23,42,  24,42,  23,43,  22,44,
            13,39,  14,39,  15,39,  12,41,  14,40,  15,40,  17,40,  11,42,  12,43,
            23,7,
            57,23,
            30,29,
            48,25,
        },
        keys = {
            { x=18, y=21 },
            { x=22, y=38 },
            { x=40, y=16 },
            { x=78, y=26 }, -- gloves
        },
        triggers = {
            { x=2, y=28, f=function()
                  open_message("Wow.\nWhy am I waking up here?",g_style_center)
              end },
            { x=1, y=22, f=function()
                open_message("There must have been one\nof those storms again.",g_style_center)
              end },
            { x=2, y=15, f=function()
                open_message("I hope nobody's\nhurt. Better check\nif everyone's ok.",g_style_center)
              end },
            { x=10, y=8, f=function()
                open_message("Storms have destroyed\nthe landscape.\nEverything is fragile now.",g_style_center)
              end },
            { x=113, y=40, f=function()
                open_message("Finally home\non my island!",g_style_center)
                open_message("While I was busy\ncatching up with\neveryone,",g_style_center)
                open_message("All my friends\nwere reconstructing\nmy house!",g_style_center)
                open_message("What a kind\nthing to do!",g_style_center)
              end },
        },
        signs = {
            { x=2,  y=18, text={"Did you know that signs\nsaved your progress? ♥\nNow you do!"} },
            { x=13, y=6, text={"Today I made my fisrt sign!\nHope someone will read it.\nI am so exited!"} },
            { x=17, y=3, text={"Oh no, there's a spelling\nmistake in my first sign..."} },
            { x=59, y=17, text={"What kind of shorts do\nclouds wear?","...","Thunderwear."} },
            { x=59, y=27, text={"If you like my funny puns,\ndon't forget to engrave a\nthumb up."} },
            { x=27, y=31, text={"Would you like to hear\na construction joke?","...","Still working on it."} },
            { x=8, y=36, text={"To support my work,\nyou can also tip me."} },
            { x=48, y=41, text={"Can a kangaroo jump higher\nthan a cliff?","...","Of course, cliffs can't jump!"} },
            { x=116, y=35, text={"To the person who invented\nzero: thanks for nothing."} },
            { x=21, y=15, text={"I find potatoes jokes\nvery...","appeeling."} },
            { x=19, y=7, text={"The ravine of the death.\nReserved to people who\ncan jump."} },
            { x=33, y=1, text={"Be careful on your way to\nthe other side of the lake!"} },
            { x=19, y=20, text={"You should know that\neverytime you read a sign\nyour progress is saved."} },
            { x=9, y=41, text={"What do you call a man with\na rubber toe?","...","Roberto."} },
        },
        living = {
            { x=1, y=2, id=g_id_cat, dir=1, name="Botox" },
            { x=91, y=2, id=g_id_cat, dir=1, name="Juno" },
            { x=24, y=35, id=g_id_cat, dir=0, name="Grocha" },
            { x=116, y=41, id=g_id_cat, dir=0, name="Yoyo" },
            { x=52, y=23,  id=g_id_raccoon, dir=0, name="Lulu" },
            { x=67, y=5,  id=g_id_raccoon, dir=0, name="Damdam" },
            { x=84, y=38,  id=g_id_raccoon, dir=0, name="Sammy" },

            { x=15, y=25,  id=g_id_person, name="Frdy",
              text = { "Good morning!",
                       "Did the storm do any damage\nto your lovely home?",
                       "I just can't believe my\nbeloved plants are still\nintact!",
                       "I heard the storm destroyed\na house by the lake.","I am going there to help\nrebuilding it!",
                       "Can you water my plants\nwhile I am gone?", -- question followed by answers
                       { "Thank you my dear friend!\nMy plants mean so much\nto me.","Taking care of them\nand watching them grow is\nmy biggest joy in the world." }, -- ♥
                       { "Don't worry,\nI am sure you will find it\nvery easy and relaxing!\nYou will do great." },              -- ?
                       { "Aww, I didn't know you\nloved gardening too!","We should get together\nsometimes when I come back,\nI would love to hear about\nyour plants." },     -- !
                       function()
                           sfx(g_sfx_loot1)
                           sfx(g_sfx_loot2)
                           open_message("You received a\nwatering can!",g_style_center)
                           game.inventory.can = true
                       end,
              },
              text2 = { "My plants are so beautiful\nbecause of you!\nI hope you enjoyed\ntaking care of them."},
            },

            { x=25, y=22,  id=g_id_person, name="Clemon",
              text = { "Well be with you, gentleman!",
                       "Let me narrate a riddle\nfor thee:",
                       "Is this a raccoon\nthat I see before me,\nthe muzzle toward\nmy hand?","Come, let me clutch thee.",
                       "I have thee not,\nand yet I see thee thrice.",
              },
              text2 = { "O, brave!","Intelligent party\nto the advantages\nof the very all of all.\nThis told, I joy."}
            },

            { x=26, y=4,  id=g_id_person, name="Marjolaine",
              text = { "Hey there!","What a storm huh?",
                       "My two grand-daughters\nare so light and tiny\nthey were lifted\nby the wind!",
                       "If by any chance you find\nthem on your way,\nwould you be kind enough\nto send them back to me?","I have been worrying\nlike hell.",  -- question followed by answers
                       { "You are right, I should\ntake care of myself and\ntry not to worry too much.","Thank you,\nit helps to know\nthat I am not alone." }, -- ♥
                       { "Yes it was a\nvery strong wind!\nThey love storms so much,\nthey couldn't resist\ngoing out." },              -- ?
                       { "They are ressourceful\nlittle girls!","I would not be surprised\nif they found their\nway home by themselves!" },     -- !
              },
              text2 = { "Thank you for sending\nback my girls."}
            },

            { x=90, y=26,  id=g_id_person, name="Charlene",
              text = { "Well,\nthat was a fun adventure!\nFor a minute,\nI was a bird!",
              "My grandma says storms\nare a lot more common now\nthan in the past.",
              "...",
              "Sometimes it makes me\nso sad and scared\nto see the world\nfalling appart.",  -- question followed by answers
                       { "You are so sweet.\nI could really use\nsomeone to talk to,\nthank you so much.","I promise I will not stay alone\nand come to you whenever I feel anxious." }, -- ♥
                       { "My friends and I\nhave so much ideas\non how to improve things!",
                       "We are already taking part\nin some peaceful actions\nto change things,\nyou should come by sometimes." },              -- ?
                       { "That's inspiring!\nI agree, collective action\ncan feel very empowering." },     -- !
              }
            },

            { x=54, y=39,  id=g_id_person, name="Alix",
              text = { "You, here?\nWhat a nice surprise!\nCome sit next to me.","I promise not to bore you\nwith science facts.",
              "...",
              "...",
              "So, I have been reading.","Did you know that\nthe temperature of\nlightning is around\n20000°C?",  -- question followed by answers
                       { "No, you are amazing!","After all,\nit is you who gave me\nmy very first science book\na while ago." }, -- ♥
                       { "I learned it in\na book my grandma found.\nOh! That's the one!\nWhere did you find it?" },              -- ?
                       { "Amazing, right?\nScience facts are\nso fascinating.","Did you know that\none day on Venus\nis longer than a year\non Earth?" },     -- !
              }
            },

            { x=112, y=33, id=g_id_person, name="Claire",
              text = { "Hi, I'm Claire. I made this\ngame with Sam here.\nThanks for trying our game,\nwe love you!"
                     },
            },
            { x=113, y=33, id=g_id_person, name="Sam",
              text = { "Hi, I'm Sam. I made this game\nwith Claire here.\nCongratulations on reaching\nthe final island!"
                     },
            },

            -- the fire puzzle
            { x=6,  y=36, id=g_spr_fire, dir=3, },
            { x=20, y=39, id=g_spr_fire, dir=1, },
            { x=15, y=43, id=g_spr_fire, dir=1, },
            { x=15, y=42, id=g_spr_fire, dir=1, },
            { x=15, y=41, id=g_spr_fire, dir=1, },
            { x=11, y=38, id=g_spr_fire, dir=3, },
            { x=12, y=38, id=g_spr_fire, dir=3, },
            { x=0,  y=41, id=g_spr_fire, dir=1, },
            --{ x=0,  y=42, id=g_spr_fire, dir=1, },
            { x=5,  y=43, id=g_spr_fire, dir=1, },
            { x=8,  y=38, id=g_spr_fire, dir=3, },
            { x=19, y=34, id=g_spr_fire, dir=1, },
        },
    }
end

function init_quest(q)
    game.inventory = {
        nkeys = 0
    }
    foreach(q.chests, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_chest, data=o, xoff=-4, yoff=-4 })
    end)
    foreach(q.keys, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_key, data=o, xoff=-4, yoff=-4, noblock=true })
    end)
    foreach(q.triggers, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=1, id=g_id_trigger, data=o, noblock=true })
    end)
    for i=1,#q.boulders,2 do
        local o = {x=q.boulders[i], y=q.boulders[i+1]}
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=1, id=g_spr_boulder, data=o, xoff=-4, yoff=-6 })
    end
    foreach(q.signs, function(o)
        add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_sign, data=o, xoff=-4, yoff=-6 })
    end)
    foreach(q.living, function(o)
        add(game.specials, new_living(o.x+.5, o.y+.5, o.dir or 3, o.id, o))
    end)
end

function update_quest(q)

end

function quest_touch(q,o)
    if o.id==g_spr_key then
        sfx(g_sfx_key)
        game.inventory.nkeys += 1
        del(game.specials,o)
    elseif o.id==g_id_trigger then
        o.data.f()
        del(game.specials,o)
    elseif o.id==g_spr_fire then
        sfx(g_sfx_drown)
        game.player.dead = 0
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
            q.save = { x=game.player.x, y=game.player.y }
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
    elseif o.id==g_spr_plant and not o.grown and game.inventory.can then
        sfx(g_sfx_plant)
        o.grown=flr(rnd(2))
    elseif o.id==g_id_person then
        q.current=0
        local function next_msg()
            q.current += 1
            local i=q.current
            if i<=#o.data.text then
                if type(o.data.text[i+1])==type({}) then
                    open_message(o.data.text[i], g_style_question, o.data.name,
                        function(answer)
                            foreach(o.data.text[i+answer], function(t) open_message(t,g_style_bottom,o.data.name) end)
                            q.current += 3 -- skip answers
                            next_msg()
                        end)
                elseif type(o.data.text[i])==type(function()end) then
                    o.data.text[i](next_msg)
                else
                    open_message(o.data.text[i],g_style_bottom,o.data.name,next_msg)
                end
            end
        end
        next_msg()
    elseif o.id==g_id_cat then
        sfx(g_sfx_pet)
        open_message("You pet "..o.data.name.." the\ncat. How adorable! ♥",g_style_center)
    elseif o.id==g_id_raccoon then
        sfx(g_sfx_pet)
        open_message("You pet "..o.data.name.." the\nraccoon. How cute! ♥",g_style_center)
    end
end

