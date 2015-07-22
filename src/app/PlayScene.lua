local nj=require "app.ninjia"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)

    self.ninjia1 = nj.new(1)
    self.ninjia2 = nj.new(2)
    self.ninjia3 = nj.new(3)
    self.ninjia4 = nj.new(4)

    self:addChild( self.ninjia1.sprite )
    nj.setPosition( self.ninjia1, cc.p( s.width/2-280, s.height/2) )

    self:addChild( self.ninjia2.sprite )
    nj.setPosition( self.ninjia2, cc.p( s.width/2-80, s.height/2) )

    self:addChild( self.ninjia3.sprite )
    nj.setPosition( self.ninjia3, cc.p( s.width/2+80, s.height/2) )

    self:addChild( self.ninjia4.sprite )
    nj.setPosition( self.ninjia4, cc.p( s.width/2+180, s.height/2) )

    nj.setState( self.ninjia1, "Idle" )
    nj.setOrientation( self.ninjia1, "left")
    nj.setState( self.ninjia2, "Run" )
    nj.setState( self.ninjia3, "Throw" )
    nj.setOrientation( self.ninjia3, "left")
    nj.setState( self.ninjia4, "Dash" )
end

return PlayScene

