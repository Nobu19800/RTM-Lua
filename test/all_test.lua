local luaunit = require "luaunit"

local lcovtools = require("lcovtools")

lcovtools.start(true)
require "openrtm"
lcovtools.stop()

require "BufferStatus_test"
require "ComponentActionListener_test"
require "ConfigAdmin_test"
require "CORBA_RTCUtil_test"
require "CORBA_SeqUtil_test"
require "CorbaConsumer_test"
require "CorbaNaming_test"
require "CorbaPort_test"
require "DataPortStatus_test"
require "ECFactory_test"
require "ExecutionContextBase_test"
require "ExecutionContextProfile_test"
require "ExecutionContextWorker_test"
require "Factory_test"
require "GlobalFactory_test"
require "InPort_test"
require "InPortBase_test"
require "InPortConsumer_test"
require "InPortDSConsumer_test"
require "InPortDSProvider_test"
require "InPortProvider_test"
require "InPortPullConnector_test"
require "InPortPushConnector_test"
require "ListenerHolder_test"
require "LogstreamFile_test"
require "Manager_test"
require "ManagerActionListener_test"
require "ManagerConfig_test"
require "ManagerServant_test"
require "ModuleManager_test"
require "NVUtil_test"
require "ObjectManager_test"


lcovtools.start(true)
luaunit.LuaUnit.run()


lcovtools.stop()

--lcovtools.dump(io.stdout)

local f = io.open("result.xml", "w")
--f:write(lcovtools.dump())
lcovtools.dump(f)
f:close()




