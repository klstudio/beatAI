local M={}

--[[ node structure
node = {
           type = leaf or
           action = function or nil
           child = {}
       }
--]] 
function M.tickLeaf( node )
    if action == nil then
        print("leaf node ", node, " 's action is nil")
        return false
    end
    return node.action()
end

function M.tick( node )
    if node.type == leaf then
        return M.tickLeaf(node)
    end 
end

return M

