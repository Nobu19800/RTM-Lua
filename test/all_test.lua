local luaunit = require "luaunit"

local lcovtools = require("lcovtools")

lcovtools.start(true)
require "openrtm"
lcovtools.stop()

require "BufferStatus_test"
require "ComponentActionListener_test"
require "ConfigAdmin_test"
require "ConnectorListener_test"
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
require "NamingManager_test"
require "NamingServiceNumberingPolicy_test"
require "NodeNumberingPolicy_test"
require "NumberingPolicy_test"
require "NVUtil_test"
require "ObjectManager_test"
require "OpenHRPExecutionContext_test"
require "OutPort_test"
require "OutPortBase_test"
require "OutPortConsumer_test"
require "OutPortDSConsumer_test"
require "OutPortDSProvider_test"
require "OutPortProvider_test"
require "OutPortPullConnector_test"
require "OutPortPushConnector_test"
require "PeriodicExecutionContext_test"
require "PortAdmin_test"
require "PortBase_test"
require "PortConnectListener_test"
require "Properties_test"
require "PublisherFlush_test"
require "RingBuffer_test"
require "RTCUtil_test"
require "RTObject_test"
require "RTObjectStateMachine_test"
require "SdoConfiguration_test"
require "SdoServiceAdmin_test"
require "SimulatorExecutionContext_test"
require "StateMachine_test"
require "SystemLogger_test"
require "StringUtil_test"
require "TimeValue_test"


lcovtools.start(true)
luaunit.LuaUnit.run()


lcovtools.stop()

lcovtools.start(true)

local ORB_Dummy_test = require "ORB_Dummy_test"
ORB_Dummy_test()

lcovtools.stop()


--lcovtools.dump(io.stdout)

local f = io.open("result/result.xml", "w")
--f:write(lcovtools.dump())
lcovtools.dump(f)
f:close()




