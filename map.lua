
-- save the cartridge map in lua memory for future use
g_map = {}
for i=0,0x400 do g_map[i+1] = peek4(0x2000+i*4) end

function load_map()
    -- restore saved map
    for i=0,0x400 do poke4(0x2000+i*4,g_map[i+1]) end
    local map = {
        collapses={},
    }
    -- parse the map and replace collapsibles with water etc.
    for ty = 0,63 do for tx = 0,127 do
        local id = mget(tx,ty)
        local function special(list, src, dst)
            if id == src then
                add(list, {x=tx+.5,y=ty+.5})
                mset(tx,ty,dst)
            end
        end
        special(map.collapses, g_spr_collapse, g_spr_water)
    end end
    return map
end

