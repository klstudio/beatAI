local M={}

local cache = cc.SpriteFrameCache:getInstance()
cache:addSpriteFrames("ninjia.plist")

local anim = {}

local function initAnimation(name, getframe)
    local frames={}
    for i = 0,9 do
        local frame = getframe(i)
        frames[i] = frame
        print(frame)
    end
    local animation = cc.Animation:createWithSpriteFrames( frames, 0.1 )
    anim[name] = {frames=frames, animation=animation}
end

function M.new( id )
   local ninjia={}
   ninjia.sprite = cc.Sprite:createWithSpriteFrame( cache:getSpriteFrame("Idle__001.png") )
   ninjia.id = id
   return ninjia
end

function M.setPosition( ninjia, p )
    ninjia.sprite:setPosition( p )
end

function M.runAnimation( ninjia, state )
    ninjia.sprite:runAction( cc.RepeatForever:create( cc.Animate:create(anim[state].animation) ) )
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
return M
      

