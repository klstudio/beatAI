local nj=require "app.ninjia"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

--local scheduler = cc.Director:getInstance():getScheduler()

function PlayScene:physicsStep(dt)
    local ninjia = self.ninjia[1]

end

function PlayScene:step(dt)
    self:physicsStep(dt)
    return self
end

-- based on CCNode
function PlayScene:onEnter()
    print("playscene onEnter ... ")
end

function PlayScene:onExit()
    print("playscene onExit ... ")
end

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)
    self.ninjia = {}

    -- To Do: release sprite
    self.ninjia[1] = nj.new(1)
    self.ninjia[2] = nj.new(2)
    self.ninjia[3] = nj.new(3)
    self.ninjia[4] = nj.new(4)

    self:addChild( self.ninjia[1].sprite )
    nj.setPosition( self.ninjia[1], cc.p( s.width/2-280, s.height/2) )

    self:addChild( self.ninjia[2].sprite )
    nj.setPosition( self.ninjia[2], cc.p( s.width/2-80, s.height/2) )

    self:addChild( self.ninjia[3].sprite )
    nj.setPosition( self.ninjia[3], cc.p( s.width/2+80, s.height/2) )

    self:addChild( self.ninjia[4].sprite )
    nj.setPosition( self.ninjia[4], cc.p( s.width/2+180, s.height/2) )

    nj.setState( self.ninjia[1], "Idle" )
    nj.setOrientation( self.ninjia[1], "left")
    nj.setState( self.ninjia[2], "Run" )
    nj.setState( self.ninjia[3], "Throw" )
    nj.setOrientation( self.ninjia[3], "left")
    nj.setState( self.ninjia[4], "Dash" )

    -- to do: unschedule when exit
    self:scheduleUpdate( handler(self, self.step) )
    self.frameNum = 0
end

return PlayScene

