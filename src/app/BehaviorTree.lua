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
local function tickLeaf( node )
    if node.state ~= state.Reset or node.state ~= state.Running then
        return state.Failure
    end

    if action == nil then
        print("leaf node ", node, " 's action is nil")
        return false
    end
    node.state =  node.action()
    return node.state
end

function M.tick( node )
    return node.tick(node)
end

function M.createLeafNode(action, stopAction)
    local node = {}
    node.type = leaf
    node.tick = tickLeaf
    node.child = nil
    node.state = state.Reset
    node.action = action
    node.stop = stopAction
    return node
end

function M.addNode(parent, node)
    assert(parent.type ~= leaf)
    if not parent.child then
        parent.child = {}
    end
    local c = parent.child
    c[#c+1] = node

    return parent
end

return M

--Three Ways of Cultivating Game AI
--validate node

