---------------------------------
--! @file Composite.lua
--! @brief 複合コンポーネントのサンプル
---------------------------------



local openrtm  = require "openrtm"





local manager = openrtm.Manager
manager:init(arg)
	
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()

