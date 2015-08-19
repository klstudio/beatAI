local M={}
local physicsNinjia=require "app.physics"

local function tileCoordForPosition(map, p)
    local tileSize = map:getTileSize()
    local mapSize = map:getMapSize()
    local tx = math.floor( p.x / tileSize.width )
    local ty = math.floor( (mapSize.height * tileSize.height - p.y)  / tileSize.height )

    return tx, ty
end

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

local function checkGround(ninjia, world, newPos)
    local tpr = {x=newPos[1]+30, y=newPos[2]-45}
    local tpl = {x=newPos[1]-30, y=newPos[2]-45}
    --To Do: check Ground based on orientation for inverse gravity, climbing walls
    local metaLayer = world.levelMap:getLayer("meta")

    local s = metaLayer:getLayerSize()
    --print("meta layer width ", s.width, " height ", s.height)

    --To Do: check tile coord validity
    tpr.x, tpr.y = tileCoordForPosition( world.levelMap, cc.p(tpr.x, tpr.y) )
    tpl.x, tpl.y = tileCoordForPosition( world.levelMap, cc.p(tpl.x, tpl.y) )
    print("newPos.x ", newPos[1], " newPos.y ", newPos[2])
    print("tpr.x ", tpr.x, ", tpr.y ", tpr.y)
    print("tpl.x ", tpl.x, ", tpl.y ", tpl.y)

    local tile_r =  metaLayer:getTileAt( cc.p(tpr.x, tpr.y) )
    local tile_l =  metaLayer:getTileAt( cc.p(tpl.x, tpl.y) )

    --get tile property
    if tile_r and tile_l then
        local gid_r = metaLayer:getTileGIDAt(cc.p(tpr.x,tpr.y))
        local gid_l = metaLayer:getTileGIDAt(cc.p(tpl.x,tpl.y))
        world.levelMap:getPropertiesForGID(gid_r)
        return true
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
        ninjia.a.y = 0
        ninjia.v.y = 0
        ninjia.v.x = 0
        --push ninjia to be on top of
    else
        ninjia.a.x, ninjia.a.y = 0, -0.1
    end

    M.setPosition(ninjia, cc.p(px, py) )
end

return M

