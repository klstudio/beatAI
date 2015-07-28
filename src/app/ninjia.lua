local M={}

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
                 v = cc.p(0, 0),  -- velocity
                 a = cc.p(0,0),   -- acceleration
                 orientation = right,
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

function M.physicsStep(ninjia)
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
return M
      

