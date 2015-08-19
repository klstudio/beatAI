local M={}
--[[
    AABB= { min = { x, y}, max = {x, y} }
--]]

 
--AABB-AABB Intersection
--Two AABBs only overlap if they overlap on all axes
function M.IntersectAABBAABB(a, b)
    if a.max.x < b.min.x or a.min.x > b.max.x then return false end
    if a.max.y < b.min.y or a.min.y > b.max.y then return false end
    return true     
end

--point in box
--p = {x, y} b:AABB
function M.PointInBox(p, b)
    if p.x < b.min.x or p.x > b.max.x then return false end
    if p.y < b.min.y or p.y > b.max.y then return false end
    return true
end

-- p0, p1 {x, y} b: AABB
function M.IntersectSegmentAABB(p0, p1, b)
    local minx, maxx, miny, maxy
    if p0.x < p1.x then
        minx, maxx = p0.x, p1.x
    else 
        minx, maxx = p1.x, p0.x
    end

    if p0.y < p1.y then
        miny, maxy = p0.y, p1.y
    else
        miny, maxy = p1.y, p0.y
    end

    if maxx < b.min.x or minx > b.max.x then return false end
    if maxy < b.min.y or miny < b.max.y then return false end
    return true
end

return M

