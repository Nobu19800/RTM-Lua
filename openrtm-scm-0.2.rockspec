package = "openrtm"
version = "scm-0.2"
source = {
   url = "https://github.com/Nobu19800/RTM-Lua/archive/master.zip",
   dir = "openrtm-master",
}

description = {
   summary = "Robot Software Platform for the Lua language",
   detailed = [[
      
   ]],
   homepage = "https://github.com/Nobu19800/RTM-Lua/wiki",
   license = "MIT"
}


dependencies = {
   "lua >= 5.1"
   --,"oil >= 4.0beta"
   --,"LUA-RFC-4122-UUID-Generator >= 0.0"
}


build = {
    type = "builtin",
    modules = {
        openrtm = "lua/openrtm.lua",
        ["openrtm.Async"] = "lua/openrtm/Async.lua",
        ["openrtm.BufferBase"] = "lua/openrtm/BufferBase.lua",
        ["openrtm.BufferStatus"] = "lua/openrtm/BufferStatus.lua",
        ["openrtm.CdrBufferBase"] = "lua/openrtm/CdrBufferBase.lua",
        ["openrtm.CdrRingBuffer"] = "lua/openrtm/CdrRingBuffer.lua",
        ["openrtm.ClockManager"] = "lua/openrtm/ClockManager.lua",
        ["openrtm.ComponentActionListener"] = "lua/openrtm/ComponentActionListener.lua",
        ["openrtm.ConfigAdmin"] = "lua/openrtm/ConfigAdmin.lua",
        ["openrtm.ConfigurationListener"] = "lua/openrtm/ConfigurationListener.lua",
        ["openrtm.ConnectorBase"] = "lua/openrtm/ConnectorBase.lua",
        ["openrtm.ConnectorListener"] = "lua/openrtm/ConnectorListener.lua",
        ["openrtm.CorbaConsumer"] = "lua/openrtm/CorbaConsumer.lua",
        ["openrtm.CorbaNaming"] = "lua/openrtm/CorbaNaming.lua",
        ["openrtm.CorbaPort"] = "lua/openrtm/CorbaPort.lua",
        ["openrtm.CORBA_IORUtil"] = "lua/openrtm/CORBA_IORUtil.lua",
        ["openrtm.CORBA_RTCUtil"] = "lua/openrtm/CORBA_RTCUtil.lua",
        ["openrtm.CORBA_SeqUtil"] = "lua/openrtm/CORBA_SeqUtil.lua",
        ["openrtm.CPUAffinity"] = "lua/openrtm/CPUAffinity.lua",
        ["openrtm.DataFlowComponentBase"] = "lua/openrtm/DataFlowComponentBase.lua",
        ["openrtm.DataPortStatus"] = "lua/openrtm/DataPortStatus.lua",
        ["openrtm.DefaultConfiguration"] = "lua/openrtm/DefaultConfiguration.lua",
        ["openrtm.DefaultPeriodicTask"] = "lua/openrtm/DefaultPeriodicTask.lua",
        ["openrtm.ECFactory"] = "lua/openrtm/ECFactory.lua",
        ["openrtm.ExecutionContextBase"] = "lua/openrtm/ExecutionContextBase.lua",
        ["openrtm.ExecutionContextProfile"] = "lua/openrtm/ExecutionContextProfile.lua",
        ["openrtm.ExecutionContextWorker"] = "lua/openrtm/ExecutionContextWorker.lua",
        ["openrtm.ExtTrigExecutionContext"] = "lua/openrtm/ExtTrigExecutionContext.lua",
        ["openrtm.Factory"] = "lua/openrtm/Factory.lua",
        ["openrtm.FactoryInit"] = "lua/openrtm/FactoryInit.lua",
        ["openrtm.GlobalFactory"] = "lua/openrtm/GlobalFactory.lua",
        ["openrtm.Guard"] = "lua/openrtm/Guard.lua",
        ["openrtm.InPort"] = "lua/openrtm/InPort.lua",
        ["openrtm.InPortBase"] = "lua/openrtm/InPortBase.lua",
        ["openrtm.InPortConnector"] = "lua/openrtm/InPortConnector.lua",
        ["openrtm.InPortConsumer"] = "lua/openrtm/InPortConsumer.lua",
        ["openrtm.InPortCorbaCdrConsumer"] = "lua/openrtm/InPortCorbaCdrConsumer.lua",
        ["openrtm.InPortCorbaCdrProvider"] = "lua/openrtm/InPortCorbaCdrProvider.lua",
        ["openrtm.InPortDirectConsumer"] = "lua/openrtm/InPortDirectConsumer.lua",
        ["openrtm.InPortDirectProvider"] = "lua/openrtm/InPortDirectProvider.lua",
        ["openrtm.InPortDSConsumer"] = "lua/openrtm/InPortDSConsumer.lua",
        ["openrtm.InPortDSProvider"] = "lua/openrtm/InPortDSProvider.lua",
        ["openrtm.InPortProvider"] = "lua/openrtm/InPortProvider.lua",
        ["openrtm.InPortPullConnector"] = "lua/openrtm/InPortPullConnector.lua",
        ["openrtm.InPortPushConnector"] = "lua/openrtm/InPortPushConnector.lua",
        ["openrtm.InPortSHMConsumer"] = "lua/openrtm/InPortSHMConsumer.lua",
        ["openrtm.InPortSHMProvider"] = "lua/openrtm/InPortSHMProvider.lua",
        ["openrtm.Listener"] = "lua/openrtm/Listener.lua",
        ["openrtm.ListenerHolder"] = "lua/openrtm/ListenerHolder.lua",
        ["openrtm.LocalServiceAdmin"] = "lua/openrtm/LocalServiceAdmin.lua",
        ["openrtm.LocalServiceBase"] = "lua/openrtm/LocalServiceBase.lua",
        ["openrtm.LogstreamBase"] = "lua/openrtm/LogstreamBase.lua",
        ["openrtm.LogstreamFile"] = "lua/openrtm/LogstreamFile.lua",
        ["openrtm.Manager"] = "lua/openrtm/Manager.lua",
        ["openrtm.ManagerActionListener"] = "lua/openrtm/ManagerActionListener.lua",
        ["openrtm.ManagerConfig"] = "lua/openrtm/ManagerConfig.lua",
        ["openrtm.ManagerServant"] = "lua/openrtm/ManagerServant.lua",
        ["openrtm.ModuleManager"] = "lua/openrtm/ModuleManager.lua",
        ["openrtm.NamingManager"] = "lua/openrtm/NamingManager.lua",
        ["openrtm.NamingServiceNumberingPolicy"] = "lua/openrtm/NamingServiceNumberingPolicy.lua",
        ["openrtm.NodeNumberingPolicy"] = "lua/openrtm/NodeNumberingPolicy.lua",
        ["openrtm.NumberingPolicy"] = "lua/openrtm/NumberingPolicy.lua",
        ["openrtm.NumberingPolicyBase"] = "lua/openrtm/NumberingPolicyBase.lua",
        ["openrtm.NVUtil"] = "lua/openrtm/NVUtil.lua",
        ["openrtm.ObjectManager"] = "lua/openrtm/ObjectManager.lua",
        ["openrtm.OpenHRPExecutionContext"] = "lua/openrtm/OpenHRPExecutionContext.lua",
        ["openrtm.OutPort"] = "lua/openrtm/OutPort.lua",
        ["openrtm.OutPortBase"] = "lua/openrtm/OutPortBase.lua",
        ["openrtm.OutPortConnector"] = "lua/openrtm/OutPortConnector.lua",
        ["openrtm.OutPortConsumer"] = "lua/openrtm/OutPortConsumer.lua",
        ["openrtm.OutPortCorbaCdrConsumer"] = "lua/openrtm/OutPortCorbaCdrConsumer.lua",
        ["openrtm.OutPortCorbaCdrProvider"] = "lua/openrtm/OutPortCorbaCdrProvider.lua",
        ["openrtm.OutPortDirectConsumer"] = "lua/openrtm/OutPortDirectConsumer.lua",
        ["openrtm.OutPortDirectProvider"] = "lua/openrtm/OutPortDirectProvider.lua",
        ["openrtm.OutPortDSConsumer"] = "lua/openrtm/OutPortDSConsumer.lua",
        ["openrtm.OutPortDSProvider"] = "lua/openrtm/OutPortDSProvider.lua",
        ["openrtm.OutPortProvider"] = "lua/openrtm/OutPortProvider.lua",
        ["openrtm.OutPortPullConnector"] = "lua/openrtm/OutPortPullConnector.lua",
        ["openrtm.OutPortPushConnector"] = "lua/openrtm/OutPortPushConnector.lua",
        ["openrtm.OutPortSHMConsumer"] = "lua/openrtm/OutPortSHMConsumer.lua",
        ["openrtm.OutPortSHMProvider"] = "lua/openrtm/OutPortSHMProvider.lua",
        ["openrtm.PeriodicECSharedComposite"] = "lua/openrtm/PeriodicECSharedComposite.lua",
        ["openrtm.PeriodicExecutionContext"] = "lua/openrtm/PeriodicExecutionContext.lua",
        ["openrtm.PeriodicTask"] = "lua/openrtm/PeriodicTask.lua",
        ["openrtm.PeriodicTaskFactory"] = "lua/openrtm/PeriodicTaskFactory.lua",
        ["openrtm.PortAdmin"] = "lua/openrtm/PortAdmin.lua",
        ["openrtm.PortBase"] = "lua/openrtm/PortBase.lua",
        ["openrtm.PortCallBack"] = "lua/openrtm/PortCallBack.lua",
        ["openrtm.PortConnectListener"] = "lua/openrtm/PortConnectListener.lua",
        ["openrtm.PortProfileHelper"] = "lua/openrtm/PortProfileHelper.lua",
        ["openrtm.Process"] = "lua/openrtm/Process.lua",
        ["openrtm.Properties"] = "lua/openrtm/Properties.lua",
        ["openrtm.PublisherBase"] = "lua/openrtm/PublisherBase.lua",
        ["openrtm.PublisherFlush"] = "lua/openrtm/PublisherFlush.lua",
        ["openrtm.PublisherNew"] = "lua/openrtm/PublisherNew.lua",
        ["openrtm.PublisherPeriodic"] = "lua/openrtm/PublisherPeriodic.lua",
        ["openrtm.RingBuffer"] = "lua/openrtm/RingBuffer.lua",
        ["openrtm.RTCUtil"] = "lua/openrtm/RTCUtil.lua",
        ["openrtm.RTObject"] = "lua/openrtm/RTObject.lua",
        ["openrtm.RTObjectStateMachine"] = "lua/openrtm/RTObjectStateMachine.lua",
        ["openrtm.SdoConfiguration"] = "lua/openrtm/SdoConfiguration.lua",
        ["openrtm.SdoOrganization"] = "lua/openrtm/SdoOrganization.lua",
        ["openrtm.SdoService"] = "lua/openrtm/SdoService.lua",
        ["openrtm.SdoServiceAdmin"] = "lua/openrtm/SdoServiceAdmin.lua",
        ["openrtm.SdoServiceConsumerBase"] = "lua/openrtm/SdoServiceConsumerBase.lua",
        ["openrtm.SdoServiceProviderBase"] = "lua/openrtm/SdoServiceProviderBase.lua",
        ["openrtm.SharedMemory"] = "lua/openrtm/SharedMemory.lua",
        ["openrtm.Singleton"] = "lua/openrtm/Singleton.lua",
        ["openrtm.StateMachine"] = "lua/openrtm/StateMachine.lua",
        ["openrtm.StringUtil"] = "lua/openrtm/StringUtil.lua",
        ["openrtm.SystemLogger"] = "lua/openrtm/SystemLogger.lua",
        ["openrtm.Task"] = "lua/openrtm/Task.lua",
        ["openrtm.TimeMeasure"] = "lua/openrtm/TimeMeasure.lua",
        ["openrtm.Timer"] = "lua/openrtm/Timer.lua",
        ["openrtm.TimeValue"] = "lua/openrtm/TimeValue.lua",
        ["openrtm.Typename"] = "lua/openrtm/Typename.lua",
        ["openrtm.version"] = "lua/openrtm/version.lua"
    },
   install = {
      bin = {
         ["idl.BasicDataType"] = "idl/BasicDataType.idl",
         ["idl.CosEvent"] = "idl/CosEvent.idl",
         ["idl.CosEventComm"] = "idl/CosEventComm.idl",
         ["idl.CosNaming"] = "idl/CosNaming.idl",
         ["idl.CosNotification"] = "idl/CosNotification.idl",
         ["idl.CosNotifyComm"] = "idl/CosNotifyComm.idl",
         ["idl.DataPort"] = "idl/DataPort.idl",
         ["idl.ExtendedDataTypes"] = "idl/ExtendedDataTypes.idl",
         ["idl.InterfaceDataTypes"] = "idl/InterfaceDataTypes.idl",
         ["idl.Manager"] = "idl/Manager.idl",
         ["idl.OpenRTM"] = "idl/OpenRTM.idl",
         ["idl.RTC"] = "idl/RTC.idl",
         ["idl.SDOPackage"] = "idl/SDOPackage.idl"
      }
   }
}