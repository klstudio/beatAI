
local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

function PlayScene:onCreate()
    -- create game view and add it to stage
    --[[
    self.gameView_ = GameView:create()
        :addEventListener(GameView.events.PLAYER_DEAD_EVENT, handler(self, self.onPlayerDead))
        :start()
        :addTo(self)
    --]]
    cc.LayerColor:create(cc.c4b(50,50,50,255)):addTo(self)

end

return PlayScene

