local M={}

local cache = cc.SpriteFrameCache:getInstance()
cache:addSpriteFrames("ninjia.plist")

function M.new( id )
   local ninjia={}
   ninjia.sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") )
   ninjia.id = id
   return ninjia
end

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

return M
      

