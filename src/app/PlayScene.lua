local nj=require "app.ninjia"
local physics=require "app.physics"
local bt=require "app.BehaviorTree"
local aiNinjia = require "app.aiNinjia"

local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

--[[
    playScen = { ... cocos2d-x
                 ninjia ={},
                 frameNum,
                 levelMap,  -- TMXTileMap
               }

--]]

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
    local param={ ninjia=self.ninjia[1], world=self, position = {x=s.width - 120, y= s.height/2 } } 
    local runTo, stopRunTo = aiNinjia.getAction("runTo", param)
    local runRightNode = bt.createLeafNode(runTo, stopRunTo)
    runRightNode.name = "run right"

    local param2={ ninjia=self.ninjia[1], world=self, position = {x=100, y= s.height/2 } } 
    local runBack, stopRunBack = aiNinjia.getAction("runTo", param2)
    local runBackNode = bt.createLeafNode(runBack, stopRunBack)
    runBackNode.name = "run left"

    local seqNode = bt.createComposite("Sequence", nil, runRightNode, runBackNode)
    seqNode.name = "run right and left"

    local jump_param={ninjia=self.ninjia[1], world=self} 
    local jumpOver, stopJumpOver = aiNinjia.getAction("jumpOver", jump_param)
    local jumpOverNode = bt.createLeafNode(jumpOver, stopJumpOver, aiNinjia.getValidate("closeToHole", jump_param) )
    jumpOverNode.name = "jump over"

    local selectorNode = bt.createComposite("Selector", nil, jumpOverNode, seqNode)
    selectorNode.name = "priority selector"

    self.ninjia[1].bt_root = selectorNode
    print("end of create behavior tree")
    -- end of create behavior tree
end

function PlayScene:onExit()
    print("playscene onExit ... ")
    self.ninjia[1].bt_root = nil
end

function PlayScene:loadLevelMap(levelId)
    local map = cc.TMXTiledMap:create("level1.tmx")
    self:addChild(map, 10)
    self.levelMap = map

    local  pChildrenArray = map:getChildren()
    local  child = nil
    local  pObject = nil
    local i = 0
    --[[
    local len = table.getn(pChildrenArray)
    for i = 0, len-1, 1 do
        pObject = pChildrenArray[i + 1]
        child = pObject

        if child == nil then
            break
        end
        child:getTexture():setAntiAliasTexParameters()
    end
    --]]
    local metaLayer = map:getLayer("meta")
    metaLayer:setVisible(false)
end

function PlayScene:onCreate()
    local s = cc.Director:getInstance():getWinSize()
    print("window size width ", s.width, "  height ", s.height)

    -- background
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self, 0)
    self.ninjia = {}

    self.dummy_hole = false     -- to test conditional behavior tree node

    -- To Do: release sprite
    self.ninjia[1] = nj.new(1)

    self:addChild( self.ninjia[1].sprite, 20)
    nj.setPosition( self.ninjia[1], cc.p( s.width/2-280, s.height/2) )

    --nj.setState( self.ninjia[1], "Idle" )
    nj.setState( self.ninjia[1], "Idle" )
    nj.setOrientation( self.ninjia[1], "right")
    
    -- to do: unschedule when exit
    self:scheduleUpdate( handler(self, self.runFrame) )
    self.frameNum = 0

    -- register touch handler
    local function onTouchesBegan(touches, event)
        if self.dummy_hole == false then
            self.dummy_hole = true
        else
            self.dummy_hole = false
        end
        print("onTouchesBegan dummy_hole ", self.dummy_hole)
    end

    local listener = cc.EventListenerTouchAllAtOnce:create()    
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    self:loadLevelMap(1)


end

return PlayScene

