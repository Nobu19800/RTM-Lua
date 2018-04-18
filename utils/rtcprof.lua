---------------------------------
--! @file rtcd.lua
--! @brief RTC-Daemonの起動
---------------------------------


local openrtm  = require "openrtm"

local manager = openrtm.Manager

manager:init(arg)
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()
