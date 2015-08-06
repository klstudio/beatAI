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
                 v = {x=0, y=0},  -- velocity
                 a = {x=0, y=0},   -- acceleration
                 -- local AABB
                 aabb = { min = { x=, y= },     
                          max = { x=, y= },
                        }
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
function M.move(ninjia, n)
    local px, py = ninjia.sprite:getPosition()
    n = n or 1

    px = px + ninjia.v.x * n
    py = py + ninjia.v.y * n

    ninjia.v.x = ninjia.v.x + ninjia.a.x * n
    ninjia.v.y = ninjia.v.y + ninjia.a.y * n

    M.setPosition(ninjia, cc.p(px, py) )
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
initAnimation("Jump", function (i) 
                        return cache:getSpriteFrame( string.format("Jump__%03d.png", i) )
                       end,
               0.2
             )
return M
      

