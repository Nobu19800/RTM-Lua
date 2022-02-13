local idl = require "oil.corba.idl"
local Version = idl.Version



local TaggedComponentSeq = idl.sequence{idl.struct{
	{name = "tag"           , type = idl.ulong   },
	{name = "component_data", type = idl.OctetSeq},
}}
local profileidl = idl.struct{
    {name = "host"        , type = idl.string        },
    {name = "port"        , type = idl.ushort        },
    {name = "object_key"  , type = idl.OctetSeq      },
    {name = "components"  , type = TaggedComponentSeq},
}

local ComponentBody = idl.struct{
	{name = "target_supports", type = idl.ushort},
	{name = "target_requires", type = idl.ushort},
	{name = "port", type = idl.ushort},
}

local Integrity = 2
local Confidentiality = 4
local DetectReplay = 8
local DetectMisordering = 16
local EstablishTrustInTarget = 32
local EstablishTrustInClient = 64
local NoDelegation = 128


local Tag = 1


local function hextochar(hex)
    return char(tonumber(hex, 16))
end

local SSLIOPProfiler = {}

SSLIOPProfiler.new = function(orb)
    local obj = {}
    setmetatable(obj, {__index=orb.IIOPProfiler})
    obj.tag = Tag
    obj._orb = orb

    function obj:decodeurl(data)
        local temp, objectkey = data:match("^([^/]*)/(.*)$")
        if temp then
            data = temp
            objectkey = objectkey:gsub("%%(%x%x)", hextochar)
        else
            objectkey = ""
        end
        local major, minor
        major, minor, temp = data:match("^(%d+).(%d+)@(.+)$")
        if not minor then
            minor = 1
        else
            minor = tonumber(minor)
        end

        if (major and major ~= "1") then
            return nil, Exception{ "INTERNAL", minor = 0,
                "$protocol $major.$minor not supported",
                error = "badversion",
                protocol = "IIOP",
                major = major,
                minor = minor,
            }
        end
        if temp then data = temp end
        local host, port = data:match("^([^:]+):(%d*)$")
        if port then
            port = tonumber(port)
        else
            port = 2809
            if data == ""
                then host = "*"
                else host = data
            end
        end
        local supported = Integrity + Confidentiality + DetectReplay + DetectMisordering  
                        + NoDelegation + EstablishTrustInClient + EstablishTrustInTarget
        local required = supported
        local encoder = self.codec:encoder(true)
        local component = {
			target_supports = supported,
			target_requires = required,
			port = port,
		}
        encoder:struct(component, ComponentBody)
        local components = {{ tag=self._orb.SSLIOPComponentCodec.tag, component_data=encoder:getdata() }}
        

        encoder = self.codec:encoder(true)
        encoder:struct({major=1,minor=minor}, Version)
        encoder:struct({
            components = components,
            host = host,
            port = port,
            object_key = objectkey
        }, profileidl)
        
        return {
            tag = Tag,
            profile_data = encoder:getdata(),
        }
    end
    return obj
end


return SSLIOPProfiler
