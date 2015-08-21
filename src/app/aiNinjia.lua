local M={}
local nj=require "app.ninjia"
--local bt=require "app.BehaviorTree"

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

-- action: name of action in string
-- param = {ninjia=, world=}
function M.getAction(action, param)
    local ninjia = param.ninjia
    local jmpOriginY = nil
    local world =  param.world

    local function _runTo()
        --print("runTo: ninjia id", ninjia.id)
        local pos = param.position
        local ninjia_px, ninjia_py = ninjia.sprite:getPosition()

        if reachedPosition(ninjia, pos) then
            --stop run
            nj.stopRun(ninjia)
            return "Success"
        end

        --if not in run state or direction is not the same, set running towards position
        if ninjia.state ~= "Run"  then
            --print("start run to ", pos.x, ", ", pos.y)
            local direction = { x = pos.x - ninjia_px, y = pos.y-ninjia_py}
            nj.run(ninjia, direction)
        end

        return "Running"
        -- there's no path finding so _runTo never returns Failure
    end

    local function _stopRunTo()
        print("stop runto")
        nj.stopRun(ninjia)
    end

    local function _jump()
        local ninjia_px, ninjia_py = ninjia.sprite:getPosition()
        if ninjia.state == "Jump" and ninjia.a.y == 0 then
            nj.stopJump(ninjia)
            print("jump returning success")
            return "Success"
        end

        if ninjia.state ~= "Jump" then
            -- start to jump
            jmpOriginY = ninjia_py
            nj.jump(ninjia)
        end
        
        return "Running"
    end

    local function _stopJump()
        print("stop jump")
        nj.stopJump(ninjia)
    end

    if action == "runTo" then
        return _runTo, _stopRunTo
    elseif action == "jump" then
        return _jump, _stopJump
    end
end

-- condition: name of condition type
-- param = {ninjia=, world=}
function M.getValidate(condition, param)
    local world = param.world
    local ninjia = param.ninjia

    local function _closeToHole(node)
        if node.state == "Active" then return true end
        return nj.closeToHole( ninjia, world )
    end

    if condition == "closeToHole" then
        return _closeToHole
    end
end

return M

