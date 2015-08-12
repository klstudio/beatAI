local M={ 
            Success = 1,
            Failure = -1,
            Running = 0,
            Invalid = -2,
        }

--[[ node structure
node = {
           type = leaf or
           action = function or nil
           child = nil
           state = Success or Failure or Running or invalid
       }
--]] 
local function tickLeaf( node )
    if action == nil then
        print("leaf node ", node, " 's action is nil")
        return false
    en
    node.state =  node.action()
    return node.state
end

function M.tick( node )
    if node.type == leaf then
        return M.tickLeaf(node)
    end 
end

function M.createLeafNode(action)
    local node = {}
    node.type = leaf
    node.child = nil
    node.state = invalid
    node.action = action
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

