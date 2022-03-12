---------------------------------
--! @file Composite.lua
--! @brief 複合コンポーネントのサンプル
---------------------------------



local openrtm  = require "openrtm"





local manager = openrtm.Manager
manager:init(arg)
manager:activateManager()
manager:runManager()

