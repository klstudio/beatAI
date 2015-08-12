local M={}
local nj=require "app.ninjia"
local bt=require "app.BehaviorTree"

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

    function _runTo()
        print("runTo: ninjia id", ninjia.id)
        local pos = param.position
        local ninjia_px, ninjia_py = ninjia.sprite:getPosition()

        if reachedPosition(ninjia, pos) then
            --stop run
            nj.stopRun(ninjia)
            return bt.state.Success
        end
        --if not in run state or direction is not the same, set running towards position
        local direction = { x = pos.x - ninjia_px, y = pos.y-ninjia_py}
        local o

        if drection.x>0 then
            o = "right";
        elseif direction.x < 0 then
            o = "left";
		else
			print("cannot determine orientation")
        end

        if ninjia.state ~= "Run" or (ninjia.state == "Run" and ninjia.orientation ~= o) then
            nj.run(ninjia, direction)
        end

        return bt.state.Running
        -- there's no path finding so _runTo never returns Failure
    end

    function _stopRunTo()
        nj.stopRun(ninjia)
    end

    if action == "runTo" then
        return _runTo, _stopRunTo
    end
end


return M

