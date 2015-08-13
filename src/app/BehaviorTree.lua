local M={
            state = {
                        Success = 1,
                        Failure = -1,
                        Running = 0,
                        Reset = -2,
                    },
        }
local state= M.state

--[[ node structure
node = {
           type = leaf or
           child = nil
           tick = tick function
           state = Success or Failure or Running or Reset
           action = function or nil
           stop = function or nil
       }
--]]
local function printNode(node)
    print("node = { ")
    print("        type = ", node.type)
    print("        state = ", node.state)
    print("       }")
end

local function tickLeaf( node )
    --print("--tickLeaf")
    --printNode(node)
    if node.state ~= state.Reset and node.state ~= state.Running then
        return state.Failure
    end

    if node.action == nil then
        print("leaf node ", node, " 's action is nil")
        return false
    end
    node.state =  node.action()
    return node.state
end

local function tickSequence( node )
    if node.state == state.Reset then
    elseif node.state == state.Running then
    end
end

function M.tick( node )
    --print("tick node ", node)
    return node.tick(node)
end

function M.addNode(parent, node)
    assert(parent.type ~= leaf)
    if not parent.child then
        parent.child = {}
    end
    local c = parent.child
    c[#c+1] = node
    --To Do: reset child node

    return parent
end

function M.createLeafNode(action, stopAction)
    local node = {}
    node.type = "leaf"
    node.tick = tickLeaf
    node.child = nil
    node.state = state.Reset
    node.action = action
    node.stop = stopAction
    print("createLeafNode", action, stopAction)
    return node
end

function M.createComposite(type, ...)
    local node = {}
    node.type = type
    node.child={}
    node.state = state.Reset
    node.action = nil
    node.stop = nil

    if type == "Sequence" then
        node.tick = tickSequence
    end

    for i, v in ipairs{...} do
        M.addNode(node, v)
    end

    return node
end


return M

--Three Ways of Cultivating Game AI
--validate node

