
function has_flag(x,y,flag)
    local bg = mget(x, y)
    return fget(bg, flag)
end

function block_object(list,x,y)
    for i=1,#list do
        local o = list[i]
        if max(abs(x-o.x),abs(y-o.y)) <= .5 then return true end
    end
    return false
end

function block_walk(x,y,w,h)
    local x1,x2,y1,y2 = flr(x-w/2),flr(x+w/2),flr(y-h/2),flr(y+h/2)
    if x1!=x2 then
        if has_flag(x1,y1,1) or has_flag(x2,y1,0) or
           has_flag(x1,y2,1) or has_flag(x2,y2,0) then
            return true
        end
    end
    if y1!=y2 then
        if has_flag(x1,y1,3) or has_flag(x1,y2,2) or
           has_flag(x2,y1,3) or has_flag(x2,y2,2) then
            return true
        end
    end
    if block_object(game.world.map.signs,x,y) then return true end
    if block_object(game.world.map.chests,x,y) then return true end
    --if band(f,0xf)!=0 then
       -- this tile has collisions, we need to check them
    --end
    return false
end

function block_fly(x,y,w,h)
    if w or h then
        return block_fly(x-w/2,y-h/2) or block_fly(x+w/2,y-h/2)
            or block_fly(x-w/2,y+h/2) or block_fly(x+w/2,y+h/2)
    end
    return false
end

