local M={}
local nj=require "app.ninjia"

function M.step(world, dt)
    --print("physics step dt = ", dt)
    local ninjia = world.ninjia[1]
    --to do dynamic collision detection

    --update ninjia
    nj.step(ninjia, 1)  -- 1 frame

    --static collision detection for now

end

return M

