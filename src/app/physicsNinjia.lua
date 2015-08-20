local M={}
local physicsNinjia=require "app.physics"

local function tileCoordForPosition(map, p)
    local tileSize = map:getTileSize()
    local mapSize = map:getMapSize()
    local tx = math.floor( p.x / tileSize.width )
    local ty = math.floor( (mapSize.height * tileSize.height - p.y)  / tileSize.height )

    return tx, ty
end

local function getTileForPosition( map, p, layerName )
    local tp = {x=nil, y=nil}
    local s = map:getContentSize()
    -- map position
    local mp = cc.p(map:getPosition())

    --check validity
    local l, b, r, t = mp.x, mp.y, mp.x+s.width-1, mp.y+s.height-1
    if p.x < l or p.y < b or p.x > r or p.y > t then return false end

    tp.x, tp.y = tileCoordForPosition( map, cc.p(p.x, p.y) )
    local layer = map:getLayer(layerName)
    local tile =  layer:getTileAt( cc.p(tp.x, tp.y) )
    return tile, tp.x, tp.y
end

local function isSolidTile( map, pos )
    local tile, tx, ty = getTileForPosition(map, pos, "meta")
    if tile then
        local metaLayer = map:getLayer("meta")
        local gid = metaLayer:getTileGIDAt(cc.p(tx,ty))
        local property = map:getPropertiesForGID(gid)
        if property["solid"] then 
            return true
        end
    end
    return false
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

--Tile anchor point left bottom too
local function getTileBoundaries(world, tile)
    local tileSize = world.levelMap:getTileSize()
    local px, py = tile:getPosition()
    local left, bottom = px, py 
    local right = px+tileSize.width-1 
    local top = py+tileSize.height-1

    return left, bottom, right, top
end

local function checkWalls(ninjia, world, newPos) 
    local s = ninjia.sprite:getContentSize()
    local tpr = {x=newPos.x+s.width/2+1, y=newPos.y - 30}
    local tpl = {x=newPos.x-s.width/2-1, y=newPos.y - 30}
    local topl = {x=newPos.x-20, y=newPos.y + s.height/2 + 1}
    local topr = {x=newPos.x+20, y=newPos.y + s.height/2 + 1}
    if isSolidTile( world.levelMap, tpr ) then
        --print("right wall newPos.x ", newPos.x, " newPos.y ", newPos.y)
        local tile = getTileForPosition(world.levelMap, tpr, "meta")
        local tl = getTileBoundaries(world, tile)
        newPos.x = tl - s.width/2 
        return "right"
    elseif isSolidTile( world.levelMap, tpl ) then
        local tile = getTileForPosition(world.levelMap, tpl, "meta")
        local l, b, r, t = getTileBoundaries(world, tile)
        newPos.x = r + s.width/2 
        return "left"
    elseif isSolidTile( world.levelMap, topl) then
        local tile = getTileForPosition(world.levelMap, topl, "meta")
        local l, b, r, t = getTileBoundaries(world, tile)
        newPos.y = b - s.height/2 
        return "top"
    elseif isSolidTile( world.levelMap, topr) then
        local tile = getTileForPosition(world.levelMap, topr, "meta")
        local l, b, r, t = getTileBoundaries(world, tile)
        newPos.y = b - s.height/2 
        return "top"
    end
    return nil
end

--TileMap anchor point left bottom
--Tile anchor point left bottom too
local function checkGround(ninjia, world, newPos)
    local tpr = {x=newPos.x+15, y=newPos.y-45}
    local tpl = {x=newPos.x-15, y=newPos.y-45}
    local metaLayer = world.levelMap:getLayer("meta")
    local s = metaLayer:getLayerSize()

    --To Do: check Ground based on orientation for inverse gravity, climbing walls
    --To Do: check tile coord validity
    local tile_r, tile_l
    tile_r, tpr.x, tpr.y = getTileForPosition( world.levelMap, cc.p(tpr.x, tpr.y), "meta")
    tile_l, tpl.x, tpl.y = getTileForPosition( world.levelMap, cc.p(tpl.x, tpl.y), "meta")

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
    local bumpWall = checkWalls(ninjia, world, newPos) 
    if bumpWall == "right" then
        if ninjia.a.x > 0 then ninjia.a.x = 0 end
    elseif bumpWall == "left" then
        if ninjia.a.x < 0 then ninjia.a.x = 0 end
    elseif bumpWall == "top" then
    end
    

    if checkGround(ninjia, world, newPos ) then
        ninjia.a.y = 0
        ninjia.v.y = 0
        --ninjia.v.x = 0
        --push ninjia to be on top of
    else
        ninjia.a.y = -0.3
    end


    M.setPosition(ninjia, cc.p(newPos.x, newPos.y) )
end

return M

