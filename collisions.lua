
function has_flag(x,y,flag)
    local bg = mget(x, y)
    return fget(bg, flag)
end

function block_walk(x,y,w,h,dir)
    local x1,x2,y1,y2 = flr(x-w/2),flr(x+w/2),flr(y-h/2),flr(y+h/2)
    if x1!=x2 then
        if fget(mget(min(x1,x2),y1),1) or fget(mget(max(x1,x2),y1),0) or
           fget(mget(min(x1,x2),y2),1) or fget(mget(max(x1,x2),y2),0) then
            return true
        end
    end
    if y1!=y2 then
        if fget(mget(x1,min(y1,y2)),3) or fget(mget(x1,max(y1,y2)),2) or
           fget(mget(x2,min(y1,y2)),3) or fget(mget(x2,max(y1,y2)),2) then
            return true
        end
    end
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

