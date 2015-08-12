local nj=require "app.ninjia"
local physics=require "app.physics"
local bt=require "app.BehaviorTree"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

--local scheduler = cc.Director:getInstance():getScheduler()

-- main loop of game play --
function PlayScene:runFrame(dt)
    -- like doom 3 code game loop is AI driven

    --player think first
    nj.think(self.ninjia[1], self, dt)

    --other enities
    
    return self
end

-- based on CCNode
function PlayScene:onEnter()
    print("playscene onEnter ... ")
    local ninjia_actions = nj.generateActions(self.ninjia[1], self)
    local root = bt.createLeafNode(ninjia_actions.runTo)
    self.ninjia[1].bt_root = root
end

function PlayScene:onExit()
    print("playscene onExit ... ")
end

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)
    self.ninjia = {}
    self.solidBox = {}

    -- To Do: release sprite
    self.ninjia[1] = nj.new(1)

    self:addChild( self.ninjia[1].sprite )
    nj.setPosition( self.ninjia[1], cc.p( s.width/2-280, s.height/2) )

    nj.setState( self.ninjia[1], "Idle" )
    nj.setOrientation( self.ninjia[1], "right")
    
    -- to do: unschedule when exit
    self:scheduleUpdate( handler(self, self.step) )
    self.frameNum = 0
end

return PlayScene

