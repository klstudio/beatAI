local M={}

local bt=require "app.BehaviorTree"
local aiNinjia = require "app.aiNinjia"

M.ninjia = nil
M.world = nil

function M.setEnv(_ninjia, _world)
    M.ninjia = _ninjia
    M.world = _world
end

-- naming convention: starting with capital letter

--actions
local function RunTo(px, py)
    local param = { ninjia = M.ninjia, world = M.world,
                    position = { x = px, y = py }
                  }
    local runTo, stopRunTo = aiNinjia.getAction("runTo", param)
    local runToNode = bt.createLeafNode(runTo, stopRunTo)
    runToNode.name = "run to "..px
    print("created node ", runToNode.name, " py = ", py)
    return runToNode
end

local function Jump()
    local param = { ninjia = M.ninjia, world = M.world }
    local jump, stopJump = aiNinjia.getAction("jump", param)
    local jumpNode = bt.createLeafNode(jump, stopJump, nil, param) 
    jumpNode.name = "jump"
    return jumpNode
end

local function JumpHole()
    local param = { ninjia = M.ninjia, world = M.world }
    local node = Jump()
    node.validate = aiNinjia.getValidate("closeToHole", param)
    node.name = "jump on hole"
    return node
end
--end of actions

--decorator
local function ForceFailure( child )
    local forceFailureNode = bt.createDecorator( "ForceFailure", nil, child )
    forceFailureNode.name = "Force Failure"
    return forceFailureNode
end

local function LoopTillSuccess( child )
    local node = bt.createDecorator( "LoopTillSuccess", nil, child )
    node.name = "Loop till success"
    return node
end

--end of decorator

--composite
local function Priority(...)
    local priorityNode = bt.createComposite("Priority", nil, ... )
    priorityNode.name = "priority"
    return priorityNode
end

local function Sequence(...)
    local seqNode = bt.createComposite("Sequence", nil, ...)
    seqNode.name = "sequence"
    return seqNode
end
--end of composite
function M.aiGetBehaviorTree()
    return Sequence(   
                       LoopTillSuccess(
                                           Priority(   
                                                       ForceFailure(
                                                                       JumpHole()
                                                                    ),
                                                       RunTo(1000, nil) 
                                                   )
                                       ),
                       LoopTillSuccess(
                                           Priority(   
                                                       ForceFailure(
                                                                       JumpHole()
                                                                   ),
                                                       RunTo(150, nil)
                                                   )
                                       )
                   )
end

return M
