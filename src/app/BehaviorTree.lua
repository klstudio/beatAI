local M={ }

--[[ node structure
-- node returns "Success" or "Failure" or "Running"
node = {
           type = "leaf" or "Sequence"
           name = nil
           validate = validation function 
           tick = tick function
           child = nil
           state = "Active" or "Inactive"
           action = function or nil
           stop = function or nil   stop action
           activeChild = nil  -- last active(running) child index
       }
--]]

local function printNode(node)
    print("node = { ")
    print("        name = ", node.name)
    print("        type = ", node.type)
    print("        state = ", node.state)
    print("       }")
end

local function validate( node )
    local ret = true
    if node.validate then
        ret = node.validate()
    end
    return ret
end

local function stop(node)
    if node.state ~= "Active" then
        return
    end

    if node.type == "leaf" then
        node.state = "Inactive"
        if node.stop then
            node.stop()
        end
    else
    end
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

--selector (priority 'or')
local function tickSelector( node )
    local i = 1
    local validatedChild = nil
    local ret = nil

    --validate first
    while node.child[i] do
        --print("try to validate ", i)
        if validate( node.child[i] ) then
            --print("ch ", i, " is validated")
            validatedChild = node.child[i]
            break
        end
        i = i + 1
    end

    if validatedChild then
       -- stop last running btree
       if node.state == "Active" and node.activeChild ~= i then
           stop(node.child[node.activeChild])
       end
       ret = validatedChild.tick(validatedChild)
    else
       if node.state == "Active" and node.activeChild then
           stop(node.child[node.activeChild])
       end
       ret = "Failure"
    end

    if ret == "Running" then
        node.state = "Active"
        node.activeChild = i
    else
        node.state = "Inactive"
        node.activeChild = nil
    end
    return ret
end

local function tickSequence( node )
    local i 
    local ret = "Success"

    if node.state == "Inactive" then
        -- start this subtree
        assert(node.activeChild == nil)
        i = 1
    elseif node.state == "Active" then
        i = node.activeChild
    end

    while ret == "Success" and node.child[i] and validate( node.child[i] )  do
        --print("tick node child ", i)
        ret = node.child[i].tick( node.child[i] )
        i = i + 1
    end

    if ret == "Running" then
        node.state = "Active"
        node.activeChild = i - 1
    else
        if node.child[i] and validate( node.child[i] ) == false then
            ret = "Failure"
            if node.child[i].state == "Active" then
                stop(node.child[i])
            end
        end
        node.state = "Inactive"
        node.activeChild = nil
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

function M.createLeafNode(action, stopAction, validate)
    local node = {}
    node.type = "leaf"
    node.tick = tickLeaf
    node.child = nil
    node.activeChild = nil
    node.state = "Inactive"
    node.action = action
    node.stop = stopAction
    node.validate = validate
    print("createLeafNode", action, stopAction)
    return node
end

function M.createComposite(type, validate, ...)
    local node = {}
    node.type = type
    node.activeChild = nil
    node.child={}
    node.state = "Inactive"
    node.action = nil
    node.stop = nil
    node.validate = validate

    if type == "Sequence" then
        node.tick = tickSequence
    elseif type == "Selector" then
        node.tick = tickSelector
    end

    for i, v in ipairs{...} do
        M.addNode(node, v)
    end

    return node
end


return M

