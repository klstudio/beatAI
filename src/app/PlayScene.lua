local nj=require "app.ninjia"
local physics=require "app.physics"
local bt=require "app.BehaviorTree"
local aiNinjia = require "app.aiNinjia"

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

    -- attach behavior tree to ninjia
    local s = cc.Director:getInstance():getWinSize()
    local param={ ninjia=self.ninjia[1], wolrd=self, position = {x=s.width - 120, y= s.height/2 } } 
    local runTo, stopRunTo = nj.getAction("runTo", param)

    self.ninjia[1].bt_root = bt.createLeafNode(runTo, stopRunTo)
end

function PlayScene:onExit()
    print("playscene onExit ... ")
    self.ninjia[1].bt_root = nil
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

