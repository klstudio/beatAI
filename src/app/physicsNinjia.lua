local M={}

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

local function checkGround(ninjia, world, newPos)
    local tpr = {x=newPos[1]+30, y=newPos[2]+32}
    local tpl = {x=newPos[1]-30, y=newPos[2]+32}
    --To Do: check Ground based on orientation for inverse gravity, climbing walls
    local metaLayer = world.levelMap:getLayer("meta")

    local tile_r =  metaLayer:getTileAt( cc.p(tpr.x, tpr.y) )
    local tile_l =  metaLayer:getTileAt( cc.p(tpl.x, tpl.y) )

    --get tile property
    if tile_r and tile_l then
    end

    return false
end


-- move ninjia for n frame based on current p, v, a
function M.updatePhysics(ninjia, world, n)
    local px, py = ninjia.sprite:getPosition()
    n = n or 1

    px = px + ninjia.v.x * n
    py = py + ninjia.v.y * n

    ninjia.v.x = ninjia.v.x + ninjia.a.x * n
    ninjia.v.y = ninjia.v.y + ninjia.a.y * n

    --collision detection with new position
    --determine ground or air state
    if checkGround(ninjia, world, {px, py} ) then
    else
    end

    M.setPosition(ninjia, cc.p(px, py) )
end

return M

