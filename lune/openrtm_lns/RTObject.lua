local openrtm  = require "openrtm"

local RTObject = {}


function RTObject:new(manager, comp)
	local obj = {}
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	obj._comp = comp
	function obj:onInitialize()
		return self._comp:onInitialize()
	end
	function obj:onFinalize()
		return self._comp:onFinalize()
	end
	function obj:onStartup(ec_id)
		return self._comp:onStartup(ec_id)
	end
	function obj:onShutdown(ec_id)
		return self._comp:onShutdown(ec_id)
	end
	function obj:onActivated(ec_id)
		return self._comp:onActivated(ec_id)
	end
	function obj:onDeactivated(ec_id)
		return self._comp:onDeactivated(ec_id)
	end
	function obj:onExecute(ec_id)
		return self._comp:onExecute(ec_id)
	end
	function obj:onAborting(ec_id)
		return self._comp:onAborting(ec_id)
	end
	function obj:onError(ec_id)
		return self._comp:onError(ec_id)
	end
	function obj:onReset(ec_id)
		return self._comp:onReset(ec_id)
	end
	function obj:onStateUpdate(ec_id)
		return self._comp:onStateUpdate(ec_id)
	end
	function obj:onRateChanged(ec_id)
		return self._comp:onRateChanged(ec_id)
	end

	function obj:bindParameter_int(param_name, var, def_val, trans)
		return self:bindParameter(param_name, var, def_val, trans)
	end

	function obj:bindParameter_real(param_name, var, def_val, trans)
		return self:bindParameter(param_name, var, def_val, trans)
	end

	function obj:bindParameter_str(param_name, var, def_val, trans)
		return self:bindParameter(param_name, var, def_val, trans)
	end

	function obj:bindParameter_vec(param_name, var, def_val, trans)
		return self:bindParameter(param_name, var, def_val, trans)
	end


	
	return obj
end


return RTObject
