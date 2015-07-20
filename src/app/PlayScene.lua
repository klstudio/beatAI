local nj=require "app.ninjia"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)

    local ninjia1 = nj.new(1)
    local ninjia2 = nj.new(2)

    self:addChild( ninjia1.sprite )
    nj.setPosition( ninjia1, cc.p( s.width/2-280, s.height/2) )

    self:addChild( ninjia2.sprite )
    nj.setPosition( ninjia2, cc.p( s.width/2-80, s.height/2) )

    print(ninjia1.id)
    print(ninjia2.id)
end

return PlayScene

