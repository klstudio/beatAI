local M={}


local anim = {}

-- each state must have corresponding animation
local states = {
    ["Idle"] = { v=cc.p(0,0), a=cc.p(0,0) },
    ["Run"] = { v=cc.p(1,0), a=cc.p(0,0)},
    ["Dash"] = { v=cc.p(3,0), a=cc.p(0,0)},
}

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
    print("interval = ", interval)
    local animation = cc.Animation:createWithSpriteFrames( frames, interval )
    anim[name] = {frames=frames, animation=animation}   -- table need be explicitly created
end

--ninjia = { id, sprite, velocity, a, g }
function M.new( id )
   local ninjia={sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") ),
                 id = id,
                 state = "Idle",
                 v = cc.p(0, 0),  -- velocity
                 a = cc.p(0,0),   -- acceleration
                }
   return ninjia
end

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

function M.runAnimation( ninjia, state )
    ninjia.sprite:runAction( cc.RepeatForever:create( cc.Animate:create(anim[state].animation) ) )
end

function M.setState(ninjia, state)
    ninjia.sprite:stopAllActions()
    M.runAnimation( ninjia, state )
    ninjia.v = states[state].v
    ninjia.a = states[state].a
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
      

