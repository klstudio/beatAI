local M={}
local physicsNinjia=require "app.physicsNinjia"
local bt=require "app.BehaviorTree"

local anim = {}

local cache = cc.SpriteFrameCache:getInstance()
cache:addSpriteFrames("ninjia.plist")

local function initAnimation(name, getframe, interval)
    local frames={}
    interval = interval or 0.1

    for i = 0,9 do
        local frame = getframe(i)
        frames[i] = frame
        --print(frame)
    end

    local animation = cc.Animation:createWithSpriteFrames( frames, interval )
    --To Do: release at some point
    animation:retain()
    anim[name] = {frames=frames, animation=animation}   -- table need be explicitly created
end

--ninjia = { id, sprite, state, v, a, orientation }
function M.new( id )
   local ninjia={sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") ),
                 id = id,
                 state = "Idle",
                 orientation = right,

                 -- physics
                 width = 64,
                 height = 64,
                 speed = 0,
                 v = {x=0, y=0},  -- velocity
                 a = {x=0, y=0},   -- acceleration
                 -- local AABB
                 --[[aabb = { min = { x=, y= },
                          max = { x=, y= },
                        }
                 --]]
                 -- behavior tree
                 bt_root = {},
                }
   return ninjia
end

local function runAnimation( ninjia, state )
    ninjia.sprite:runAction( cc.RepeatForever:create( cc.Animate:create(anim[state].animation) ) )
end

function M.setState(ninjia, state)
    ninjia.sprite:stopAllActions()
    print("setState: ninjia ", ninjia.id, " ", state)
    runAnimation( ninjia, state )
    ninjia.state = state
end


--just change face orientation. doesn't touch velocity or acceleration
function M.setOrientation(ninjia, o)
    if o == "left" then
        ninjia.sprite:setFlipX(true)
    else
        ninjia.sprite:setFlipX(false)
    end
    ninjia.orientation = o
end


function M.jump(ninjia)
    ninjia.speed = 8
    if ninjia.orientation == "right" then
        ninjia.v.x, ninjia.v.y = 5, ninjia.speed
    else
        ninjia.v.x, ninjia.v.y = -5, ninjia.speed
    end

    --ninjia.a.x, ninjia.a.y = 0, -0.1
    M.setState(ninjia, "Jump")
end

function M.stopJump(ninjia)
    ninjia.v.x, ninjia.v.y = 0, 0
    ninjia.a.x, ninjia.a.y = 0, 0
    ninjia.speed = 0
    M.setState(ninjia, "Idle")
end

--direction {x, y} vector
function M.run(ninjia, direction)
    --only left right for now
    local o
    if direction.x>0 then
        o = "right";
    elseif direction.x < 0 then
        o = "left";
	else
		print("cannot determine orientation")
    end
    M.setOrientation(ninjia, o)
    ninjia.speed = 3
    ninjia.a.x = 0
    ninjia.a.y = 0
    if o == "right" then
        ninjia.v.x = ninjia.speed
    elseif o == "left" then
        ninjia.v.x = -ninjia.speed
    end
    M.setState(ninjia, "Run")
end

function M.setPosition( ninjia, p )
    physicsNinjia.setPosition(ninjia, p)
end

function M.stopRun(ninjia)
    ninjia.v.x, ninjia.v.y = 0, 0
    ninjia.a.x, ninjia.a.y = 0, 0
    ninjia.speed = 0
    M.setState(ninjia, "Idle")
end

function M.closeToHole( ninjia, world )
   return physicsNinjia.closeToHole(ninjia, world)
end

function M.checkGround( ninjia, world )
    return physicsNinjia._checkGround( ninjia, world)
end

function M.think(ninjia, world, dt)
    --All sorts of events check
        --collision test
    --evaluate btree
    -- if there's event, abort last and evaluate the tree from beginnning
    --print("ninjia - think")
    bt.tick(ninjia.bt_root)

    --update ninjia physics
    physicsNinjia.updatePhysics(ninjia,world, 1)
end

-- the following code get run once when required
initAnimation("Idle", function (i)
                        return cache:getSpriteFrame( string.format("Idle__%03d.png", i) )
                      end
             )
initAnimation("Run", function (i)
                        return cache:getSpriteFrame( string.format("Run__%03d.png", i) )
                     end
             )
initAnimation("Throw", function (i)
                        return cache:getSpriteFrame( string.format("Throw__%03d.png", i) )
                       end
             )
initAnimation("Dash", function (i)
                        return cache:getSpriteFrame( string.format("Run__%03d.png", i) )
                       end,
               0.05
             )
initAnimation("Jump", function (i)
                        return cache:getSpriteFrame( string.format("Jump__%03d.png", i) )
                       end,
               0.2
             )
return M
