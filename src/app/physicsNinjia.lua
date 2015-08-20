local M={}
local physicsNinjia=require "app.physics"

local function tileCoordForPosition(map, p)
    local tileSize = map:getTileSize()
    local mapSize = map:getMapSize()
    local tx = math.floor( p.x / tileSize.width )
    local ty = math.floor( (mapSize.height * tileSize.height - p.y)  / tileSize.height )

    return tx, ty
end

local function getGroundLevel(world, tile)
    local tileSize = world.levelMap:getTileSize()
    local px, py = tile:getPosition()

    --print("tile pos.x ", px, "tile pos.y ", py)
    return py+tileSize.height
end

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end



--TileMap anchor point left bottom
--Tile anchor point left bottom too
local function checkGround(ninjia, world, newPos)
    local tpr = {x=newPos.x+30, y=newPos.y-46}
    local tpl = {x=newPos.x-30, y=newPos.y-46}
    --print("pos.x ", tpr.x, " pos.y ", tpr.y)
    --print("pos.x ", tpl.x, " pos.y ", tpl.y)
    --To Do: check Ground based on orientation for inverse gravity, climbing walls
    local metaLayer = world.levelMap:getLayer("meta")

    local s = metaLayer:getLayerSize()
    --print("meta layer width ", s.width, " height ", s.height)

    --To Do: check tile coord validity
    tpr.x, tpr.y = tileCoordForPosition( world.levelMap, cc.p(tpr.x, tpr.y) )
    tpl.x, tpl.y = tileCoordForPosition( world.levelMap, cc.p(tpl.x, tpl.y) )
    local mapPos = cc.p(world.levelMap:getPosition())
    --world.levelMap:setPosition(cc.p(20,100))
    --print("mapPos.x ", mapPos.x, " mapPos.y ", mapPos.y)
    --print("tpr.x ", tpr.x, ", tpr.y ", tpr.y)
    --print("tpl.x ", tpl.x, ", tpl.y ", tpl.y)

    local tile_r =  metaLayer:getTileAt( cc.p(tpr.x, tpr.y) )
    local tile_l =  metaLayer:getTileAt( cc.p(tpl.x, tpl.y) )

    if tile_r == nil and tile_l == nil then return false end
    local ground_y = nil 

    --get tile property
    if tile_l then
        local gid_l = metaLayer:getTileGIDAt(cc.p(tpl.x,tpl.y))
        local property = world.levelMap:getPropertiesForGID(gid_l)
        if property["solid"] then 
            ground_y = getGroundLevel(world, tile_l)
        end
    end

    if tile_r then
        local gid_r = metaLayer:getTileGIDAt(cc.p(tpr.x,tpr.y))
        local property = world.levelMap:getPropertiesForGID(gid_r)
        local tmp
        if property["solid"] then 
            tmp = getGroundLevel(world, tile_r)
            if ground_y then
                if tmp > ground_y then ground_y = tmp end
            else
                ground_y = tmp
            end
        end
    end

    if ground_y then
        --update newPos.y (push back)
        local s = ninjia.sprite:getContentSize()
        newPos.y = ground_y + s.height/2 - 3
    else 
        return false
    end

    return true
end


-- move ninjia for n frame based on current p, v, a
function M.updatePhysics(ninjia, world, n)
    local px, py = ninjia.sprite:getPosition()
    n = n or 1

    px = px + ninjia.v.x * n
    py = py + ninjia.v.y * n
    local newPos = { x=px, y=py}

    ninjia.v.x = ninjia.v.x + ninjia.a.x * n
    ninjia.v.y = ninjia.v.y + ninjia.a.y * n

    --collision detection with new position
    --determine ground or air state
    if checkGround(ninjia, world, newPos ) then
        ninjia.a.y = 0
        ninjia.v.y = 0
        --ninjia.v.x = 0
        --push ninjia to be on top of
    else
        ninjia.a.x, ninjia.a.y = 0, -0.1
    end

    M.setPosition(ninjia, cc.p(newPos.x, newPos.y) )
end

return M

