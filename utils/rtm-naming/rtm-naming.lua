#!/usr/bin/env lua



local oil    = require "oil"
local naming = require "oil.corba.services.naming"
local assert = require "oil.assert"
local Arguments = require "loop.compiler.Arguments"

local args = Arguments{
	_optpat = "^%-%-(%w+)(=?)(.-)$",
	port = 2809,
	host = "",
}

local argidx, errmsg = args(...)

oil.main(function()
	local orb = nil
	if args.host == "" then
		args.host = nil
	end
	
	if oil.VERSION == "OiL 0.6" then
		orb = oil.init{flavor = "cooperative;corba;", host=args.host, port=args.port}
	else
		orb = oil.init{flavor = "cooperative;corba;intercepted;typed;base;", host=args.host, port=args.port}
	end

	assert.exception = function(args)
		error(orb:newexcept(args))
	end

	orb:loadidlfile("CosNaming.idl")
	
	ns = orb:newservant(naming.new())


	if oil.VERSION == "OiL 0.6" then

		ns.__new_context = ns.new_context
		ns.new_context = function(self)
			local nc = self:__new_context()
			local ns = orb:newservant(nc, nil, "IDL:omg.org/CosNaming/NamingContext:1.0")
			return ns
		end
	else
		ns.__destroy = ns.destroy
		ns.destroy = function(self)
			self.bindings.size = function(self)
				return #self
			end
			ns:__destroy()
		end

		
		ns.__list = ns.list
		ns.list = function(self, how_many)
			self.bindings.size = function(self)
				return #self
			end
			return ns:__list(how_many)
		end

		ns.__new_context = ns.new_context
		ns.new_context = function(self)
			local nc = self:__new_context()
			local ns = orb:newservant(nc, nil, "IDL:omg.org/CosNaming/NamingContext:1.0")

			ns.__destroy = ns.destroy
			ns.destroy = function(self)
				self.bindings.size = function(self)
					return #self
				end
				ns:__destroy()
			end

			ns.__list = ns.list
			ns.list = function(self, how_many)
				self.bindings.size = function(self)
					return #self
				end
				return ns:__list(how_many)
			end

			return ns
		end
	end

	  
	orb:run()
end)
