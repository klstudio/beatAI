local M={ }

--[[ node structure
-- node returns "Success" or "Failure" or "Running"
node = {
           type = "leaf" or "Sequence"
           name = nil
           tick = tick function
           child = nil
           state = "Active" or "Inactive"
           action = function or nil
           stop = function or nil
           runningChild = nil  -- last running child index
       }
--]]

local function printNode(node)
    print("node = { ")
    print("        name = ", node.name)
    print("        type = ", node.type)
    print("        state = ", node.state)
    print("       }")
end

local function tickLeaf( node )
    --print("--tickLeaf")
    --printNode(node)
    assert(node.action ~= nil)

    local ret = node.action()

    if  ret == "Running"then
        node.state = "Active"
    else 
        node.state = "Inactive"
    end

    return ret 
end

local function tickSequence( node )
    local i 
    local ret = "Success"

    if node.state == "Inactive" then
        -- start this subtree
        assert(node.runningChild == nil)
        i = 1
    elseif node.state == "Active" then
        i = node.runningChild
    end

    while node.child[i] and ret == "Success" do
        --print("tick node child ", i)
        ret = node.child[i].tick( node.child[i] )
        i = i + 1
    end

    if ret == "Running" then
        node.state = "Active"
        node.runningChild = i - 1
    else
        node.state = "Inactive"
        node.runningChild = nil
    end

    return ret
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

    return parent
end

function M.createLeafNode(action, stopAction)
    local node = {}
    node.type = "leaf"
    node.tick = tickLeaf
    node.child = nil
    node.runningChild = nil
    node.state = "Inactive"
    node.action = action
    node.stop = stopAction
    print("createLeafNode", action, stopAction)
    return node
end

function M.createComposite(type, ...)
    local node = {}
    node.type = type
    node.runningChild = nil
    node.child={}
    node.state = "Inactive"
    node.action = nil
    node.stop = nil

    if type == "Sequence" then
        node.tick = tickSequence
    elseif type == "Priority" then
    end

    for i, v in ipairs{...} do
        M.addNode(node, v)
    end

    return node
end


return M

