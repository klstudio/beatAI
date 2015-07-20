local M={}

local cache = cc.SpriteFrameCache:getInstance()
cache:addSpriteFrames("ninjia.plist")

local animFrames_Idle = {}
local anim = {}

local function initAnimation()
    for i = 0,9 do
        local frame = cache:getSpriteFrame( string.format("Idle__%02d.png", i) )
        animFrames_Idle[i] = frame
    end
    anim["Idle"] = cc.Animation:createWithSpriteFrames( animFrames_Idle, 0.3 )
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
    ninjia.sprite:runAction( ccRepeatForever:create( cc.Animate:create(anim[state]) ) )
end


return M
      

