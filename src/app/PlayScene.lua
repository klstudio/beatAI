local nj=require "app.ninjia"
local physics=require "app.physics"
--local bt=require "app.BehaviorTree"
--local aiNinjia = require "app.aiNinjia"

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

    --check ninjia state
    if self.ninjia[1].state == "Dead" then
        self:onNinjiaDead()
        return
    end

    if self.ninjia[1].state == "Success" then
        self:onNinjiaSuccess()
        return
    end

    --player think first
    nj.think(self.ninjia[1], self, dt)

    --other enities
    

    return self
end

-- based on CCNode
function PlayScene:onEnter()
    print("playscene onEnter ... ")
    print("loading level 1 ai ...")
    local ai = require "app.aiScript"
    ai.setEnv(self.ninjia[1], self)
    self.ninjia[1].bt_root = ai.aiGetBehaviorTree()
    print("end of create behavior tree")

    -- attach behavior tree to ninjia
    --[[
    local s = cc.Director:getInstance():getWinSize()
    local param={ ninjia=self.ninjia[1], world=self, position = {x=s.width - 300, y= nil} } 
    local runTo, stopRunTo = aiNinjia.getAction("runTo", param)
    local runRightNode = bt.createLeafNode(runTo, stopRunTo)
    runRightNode.name = "run right"

    local param2={ ninjia=self.ninjia[1], world=self, position = {x=200, y=nil } } 
    local runBack, stopRunBack = aiNinjia.getAction("runTo", param2)
    local runBackNode = bt.createLeafNode(runBack, stopRunBack)
    runBackNode.name = "run left"

    local seqNode = bt.createComposite("Sequence", nil, runRightNode, runBackNode)
    seqNode.name = "run right and left"

    local jump_param={ninjia=self.ninjia[1], world=self} 
    local jump, stopJump = aiNinjia.getAction("jump", jump_param)
    local jumpNode = bt.createLeafNode(jump, stopJump, aiNinjia.getValidate("closeToHole", jump_param) )
    jumpNode.name = "jump"

    local selectorNode = bt.createComposite("Selector", nil, jumpNode, seqNode)
    selectorNode.name = "priority selector"

    self.ninjia[1].bt_root = selectorNode
    print("end of create behavior tree")
    --]]
    -- end of create behavior tree
end

function PlayScene:onExit()
    print("playscene onExit ... ")
    self.ninjia[1].bt_root = nil
end

function PlayScene:onNinjiaDead()
    local text = string.format("Level Completed")
    nj.setState(self.ninjia[1], "Dead")
    cc.Label:createWithSystemFont(text, "Arial", 96)
        :align(display.CENTER, display.center)
        :addTo(self, 20)

    -- add exit button
    local exitButton = cc.MenuItemImage:create("ExitButton.png", "ExitButton.png")
        :onClicked(function()
            self:getApp():enterScene("MainScene")
        end)
    cc.Menu:create(exitButton)
        :move(display.cx, display.cy - 200)
        :addTo(self, 20)
end

function PlayScene:onNinjiaSuccess()
    -- add game over text
    local text = string.format("Level Failed")
    cc.Label:createWithSystemFont(text, "Arial", 100)
        :align(display.CENTER, display.center)
        :addTo(self, 20)

    -- add exit button
    local exitButton = cc.MenuItemImage:create("ExitButton.png", "ExitButton.png")
        :onClicked(function()
            self:getApp():enterScene("MainScene")
        end)
    cc.Menu:create(exitButton)
        :move(display.cx, display.cy - 200)
        :addTo(self, 20)
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

    local actionLayer = map:getLayer("action")
    actionLayer:setVisible(false)
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

    self:addChild( self.ninjia[1].sprite, 50)
    nj.setPosition( self.ninjia[1], cc.p( 50, s.height-200) )

    --nj.setState( self.ninjia[1], "Idle" )
    nj.setState( self.ninjia[1], "Idle" )
    nj.setOrientation( self.ninjia[1], "right")
    
    -- to do: unschedule when exit
    self:scheduleUpdate( handler(self, self.runFrame) )
    self.frameNum = 0

    -- register touch handler
    local function onTouchesBegan(touches, event)
          local touchLocation = touches[1]:getLocation()
          print("Touch event pos.x ", touchLocation.x, " pos.y ", touchLocation.y)
          nj.processTouch(self.ninjia[1], self, touchLocation)
    end

    local listener = cc.EventListenerTouchAllAtOnce:create()    
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    --listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    self:loadLevelMap(1)

end



return PlayScene

