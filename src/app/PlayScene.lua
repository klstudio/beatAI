
local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)
local ninjia = {}

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()
    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)
    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("ninjia.plist")

    ninjia.sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") )
    ninjia.sprite:setPosition( cc.p( s.width/2-80, s.height/2) )
    self:addChild(ninjia.sprite)

end

return PlayScene

