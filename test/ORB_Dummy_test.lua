
local ORB_Dummy_test = function()
    package.loaded["openrtm.Manager"] = nil
    ORB_Dummy_ENABLE = true
    local Manager = require "openrtm.Manager"


    oil.main(function()end)
    ORB_Dummy.types:lookup("::RTC::ReturnCode_t")
    ORB_Dummy.types:lookup("::RTC::ExecutionKind")
    ORB_Dummy.types:lookup("::RTC::LifeCycleState")
    ORB_Dummy.types:lookup("::OpenRTM::PortStatus")
    ORB_Dummy.types:lookup("::RTC::PortInterfacePolarity")

    ORB_Dummy:newservant({}, "name", "idl")
    ORB_Dummy:tostring({})
    local encoder = ORB_Dummy:newencoder()
    encoder:put({},"data_type")

    local decoder = ORB_Dummy:newdecoder("cdr")
	decoder:get("data_type")
	
	ORB_Dummy:loadidlfile("")

    ns = Dummy_NameServer.new()
    ns:rebind({{id="id",kind="kind"}},{})
    ns:unbind({{id="id",kind="kind"}})
    ns:bind_new_context({{id="id",kind="kind"}})
    ns:resolve({{id="id",kind="kind"}})

    local inportcdr = Manager.Dummy_InPortCDR.new()
	inportcdr:push("data")
	local outportcdr = Manager.Dummy_OutPortCDR.new()
	outportcdr:pull()

	local inportcdr = ORB_Dummy:newproxy("IOR:Dummy",nil,"IDL:omg.org/RTC/DataPushService:1.0")
	inportcdr:push("data")
	local outportcdr = ORB_Dummy:newproxy("IOR:Dummy",nil,"IDL:omg.org/RTC/DataPullService:1.0")
	outportcdr:pull()

    package.loaded["openrtm.Manager"] = nil
    ORB_Dummy_ENABLE = false
    local Manager = require "openrtm.Manager"
end

return ORB_Dummy_test