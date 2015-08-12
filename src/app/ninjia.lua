local M={}
local physics=require "app.physics"
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
    anim[name] = {frames=frames, animation=animation}   -- table need be explicitly created
end

--ninjia = { id, sprite, state, v, a, orientation }
function M.new( id )
   local ninjia={sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") ),
                 id = id,
                 state = "Idle",
                 orientation = right,

                 -- physics
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

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

local function runAnimation( ninjia, state )
    ninjia.sprite:runAction( cc.RepeatForever:create( cc.Animate:create(anim[state].animation) ) )
end

function M.setState(ninjia, state)
    ninjia.sprite:stopAllActions()
    runAnimation( ninjia, state )
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
    ninjia.v.x, ninjia.v.y = 0, 4   -- per frame   
    ninjia.a.x, ninjia.a.y = 0, -0.1
    M.setState(ninjia, "Jump")
end

-- move ninjia for n frame based on current p, v, a
local function updatePhysics(ninjia, n)
    local px, py = ninjia.sprite:getPosition()
    n = n or 1

    px = px + ninjia.v.x * n
    py = py + ninjia.v.y * n

    ninjia.v.x = ninjia.v.x + ninjia.a.x * n
    ninjia.v.y = ninjia.v.y + ninjia.a.y * n

    M.setPosition(ninjia, cc.p(px, py) )
end

--direction {x, y} vector
function M.run(ninjia, direction)
    --only left right for now
    local o
    if drection.x>0 then
        o = "right";
    else if direction.x < 0 then
        o = "left";
    end
    M.setOrientation(ninjia, o)
end

function M.stopRun(ninjia)
    ninjia.v.x, ninjia.v.y = 0, 0
    ninjia.a.x, ninjia.a.y = 0, 0
    M.setState(ninjia, "Idle")
end


-- AI logic
-- position {x=, y=}
-- action return value 0 running -1 failed 1 success
local function containsPoint(bounds, p)
    if p.x >= bounds.lb.x and p.y >= bounds.lb.y 
       and p.x <= bounds.rt.x and p.y <= bounds.rt.y then
       return true
    end
    return false 
end

local function reachedPosition(ninjia, pos)
    local px, py = ninjia.sprite:getPosition()
    local bounds = { lb = { x = px-30, y = py-30 },
                     rt = { x = px+30, y = py+30 },
                   }
    return containsPoint(bounds, pos)
end

function M.generateActions(ninjia, world)
    function _runTo(ninjia, pos)
        print("runTo: ninjia id", ninjia.id)
        local ninjia_px, ninjia_py = ninjia.sprite:getPosition()
        if reachedPosition(ninjia, pos) then
            --stop run
            M.stopRun(ninjia)
            return bt.Success
        end
        --if not in run state or direction is not the same, set running towards position
        local direction = { x = pos.x - ninjia_px, y = pos.y-ninjia_py}
        local o

        if drection.x>0 then
            o = "right";
        else if direction.x < 0 then
            o = "left";
        end

        if ninjia.state ~= "Run" or (ninjia.state == "Run" and ninjia.orientation != o) then
            M.run(ninjia, direction)
        end

        return bt.Running
        -- there's no path finding so _runTo never returns Failure
    end

    return { runTo=_runTo }
end

function M.think(ninjia, world, dt)
    --All sorts of events check
        --collision test
    --evaluate btree
    -- if there's event, abort last and evaluate the tree from beginnning
    bt.tick(ninjia.bt_tree)

    --update ninjia physics
    updatePhysics(ninjia, 1)
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
      

