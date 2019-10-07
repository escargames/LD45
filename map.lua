
-- save the cartridge map in lua memory for future use
g_map = {}
for i=0,0x400 do g_map[i+1] = peek4(0x2000+i*4) end

function load_map()
    -- restore saved map
    for i=0,0x400 do poke4(0x2000+i*4,g_map[i+1]) end
    local map = {
        collapses={},
        plants={},
        junk={},
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
        special(map.plants, g_spr_plant, g_spr_ground)
    end end
    return map
end

function reset_map(m)
    foreach(m.junk, function(o)
        add(m.collapses, {x=o.x, y=o.y})
    end)
    m.junk={}
end

function create_maze(x,y,w,h)
    -- memset everything to zero
    local p=0x2000+128*y+x
    for j=0,h-1 do
        memset(p+128*j,0,w)
    end
    -- create a maze
    local c={x=band(rnd(w),254)+1,y=band(rnd(h),254)+1}
    local s={}
    local n
    local function test(x2,y2)
        if x2>0 and y2>0 and x2<w-1 and y2<h-1 and mget(x+x2,y+y2)==0 then
            add(n,{x=x2,y=y2})
        end
    end
    repeat
        mset(x+c.x,y+c.y,1)
        n={}
        test(c.x+2,c.y) test(c.x-2,c.y)
        test(c.x,c.y+2) test(c.x,c.y-2)
        if #n>0 then
            add(s,c)
            local p=n[1+flr(rnd(#n))]
            mset(x+c.x/2+p.x/2, y+c.y/2+p.y/2, 1)
            c=p
        else
            c=s[#s]
            s[#s]=nil
        end
    until #s==0
    -- create path
    mset(x+1,y+h-1,1)
    -- fix tiles
    local function doeach(f) for j=y,y+h-1 do for i=x,x+w-1 do f(i,j) end end end
    -- put rocks
    doeach(function(i,j) if mget(i,j)==1 and mget(i,j+1)==0 then mset(i,j+1,62) end end)
    -- put water in holes
    doeach(function(i,j) if mget(i,j)==0 then mset(i,j,39) end end)
    -- white tiles
    local bad = {[62]=true, [39]=true}
    local lut = {3,1,2,36,51,49,50,4,19,17,18,20,35,33,34}
    doeach(function(i,j) if mget(i,j)==1 then
        local m=0
        if not bad[mget(i-1,j)] then m+=1 end
        if not bad[mget(i+1,j)] then m+=2 end
        if not bad[mget(i,j-1)] then m+=4 end
        if not bad[mget(i,j+1)] then m+=8 end
        mset(i,j,lut[m])
    end end)
end

