
function bg_flag(x,y,flag)
    local bg = mget(x - game.region.x, y - game.region.y)
    return fget(bg, flag)
end

function fg_flag(x,y,flag)
    local fg = mget(x - game.region.x + 40, y - game.region.y)
    return fget(fg, flag)
end

function block_walk(x,y,w,h)
    if w or h then
        return block_walk(x-w/2,y-h/2) or block_walk(x+w/2,y-h/2)
            or block_walk(x-w/2,y+h/2) or block_walk(x+w/2,y+h/2)
    end
    return fg_flag(x,y, 0) -- foreground object
        or bg_flag(x,y, 4) -- water
end

function block_fly(x,y,w,h)
    if w or h then
        return block_fly(x-w/2,y-h/2) or block_fly(x+w/2,y-h/2)
            or block_fly(x-w/2,y+h/2) or block_fly(x+w/2,y+h/2)
    end
    return fg_flag(x,y, 0) -- foreground object
end

