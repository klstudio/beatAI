local nj=require "app.ninjia"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)

    local ninjia1 = nj.new(1)
    local ninjia2 = nj.new(2)
    local ninjia3 = nj.new(3)
    local ninjia4 = nj.new(4)

    self:addChild( ninjia1.sprite )
    nj.setPosition( ninjia1, cc.p( s.width/2-280, s.height/2) )

    self:addChild( ninjia2.sprite )
    nj.setPosition( ninjia2, cc.p( s.width/2-80, s.height/2) )

    self:addChild( ninjia3.sprite )
    nj.setPosition( ninjia3, cc.p( s.width/2+80, s.height/2) )

    self:addChild( ninjia4.sprite )
    nj.setPosition( ninjia4, cc.p( s.width/2+180, s.height/2) )

    nj.setState( ninjia1, "Idle" )
    nj.setOrientation( ninjia1, "left")
    nj.setState( ninjia2, "Run" )
    nj.setState( ninjia3, "Throw" )
    nj.setOrientation( ninjia3, "left")
    nj.setState( ninjia4, "Dash" )
end

return PlayScene

