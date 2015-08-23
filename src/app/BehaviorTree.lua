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
           stopAction = function or nil   stop action
           activeChild = nil  -- last active(running) child index
       }
--]]

-- failure on validation means just to skip that node
local function printNode(node)
    print("node = { ")
    print("        name = ", node.name)
    print("        type = ", node.type)
    print("        state = ", node.state)
    if node.child then
        local i = 1
        for i = 1, #(node.child) do
            print("     child[", i, "].name = ", node.child[i].name)
        end
    end
    print("       }")
end

local function validate( node )
    local ret = true
    if node.validate then
        ret = node.validate(node)
    end
    return ret
end

function M.tick( node )
    --print("tick node ------->")
    --printNode(node)
    return node.tick(node)
end

local function stop(node)
    --print("stopping node ", node)
    --printNode(node)

    if node.state ~= "Active" then
        node.activeChild = nil
        return
    end

    node.state = "Inactive"

    if node.type == "leaf" then
        if node.stopAction then
            node.stopAction()
        end
        return
    else 
        if node.activeChild then
            --print("going to stop child ", node.activeChild)
            --printNode( node.child[] )
            stop(node.child[node.activeChild])
        end
        node.activeChild = nil
    end
end

local function tickLeaf( node )
    assert(node.action ~= nil)

    local ret = node.action()

    if  ret == "Running"then
        node.state = "Active"
    else 
        node.state = "Inactive"
    end

    if ret == "Success" then print(node.name, " returning success") end
    return ret 
end

-- Decorators
local function tickForceFailure( node )
    local ret 
    ret = M.tick( node.child )
    if ret == "Running" then
        node.state = "Active"
    else
        ret = "Failure"
        node.state = "Inactive"
    end
    return ret
end

local function tickLoopTillSuccess( node )
    local ret
    ret = M.tick( node.child )
    if ret == "Running" then
        node.state = "Active"
    elseif ret == "Failure" then
        print(node.child.name, " returns failure, keep running")
        ret = "Running"
        node.state = "Active"
    elseif ret == "Success" then
        node.state = "Inactive"
    end
    return ret
end

--Composites
--priority: always validate following priority order and run the first that's validated
local function tickPriority( node )
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
           --print("stoping node.activeChild = ", node.activeChild)
           --printNode(node.child[node.activeChild])
           stop(node.child[node.activeChild])
       end
       --ret = validatedChild.tick(validatedChild)
       ret = M.tick( validatedChild )
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
        -- ret = node.child[i].tick( node.child[i] )
        ret = M.tick( node.child[i] )
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

local function validateSequence(node)
    if not node.child then return false end
    return validate(node.child[1])
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


local function validatePriority(node)
    local i = 1

    if not node.child then return false end
    for i = 1, #(node.child) do
        if validate( node.child[i] ) then return true end
    end
    return false
end

local function validateDecorator(node)
    return validate(node.child)
end

function M.createLeafNode(action, stopAction, validate)
    local node = {}
    node.type = "leaf"
    node.tick = tickLeaf
    node.child = nil
    node.activeChild = nil
    node.state = "Inactive"
    node.action = action
    node.stopAction = stopAction
    node.validate = validate
    print("createLeafNode", action, stopAction)
    return node
end

function M.createDecorator(type, validate, childNode)
    local node = {}
    assert( childNode ~= nil)
    node.type = type
    node.activeChild = nil
    node.child=childNode
    node.state = "Inactive"
    node.action = nil
    node.stopAction = nil
    node.validate = validate or validateDecorator

    if type == "ForceFailure" then
        node.tick = tickForceFailure
    elseif type == "LoopTillSuccess" then
        node.tick = tickLoopTillSuccess
    end

    return node
end

function M.createComposite(type, validate, ...)
    local node = {}
    node.type = type
    node.activeChild = nil
    node.child={}
    node.state = "Inactive"
    node.action = nil
    node.stopAction = nil

    if type == "Sequence" then
        node.tick = tickSequence
        if validate then
            node.validate = validate
        else
            node.validate = validateSequence
        end
    elseif type == "Priority" then
        node.tick = tickPriority
        if validate then
            node.validate = validate
        else
            node.validate = validatePriority
        end
    end

    for i, v in ipairs{...} do
        M.addNode(node, v)
    end

    return node
end

return M

