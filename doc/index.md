# OpenRTM Lua��
## �T�v
���̃y�[�W�ł�OpenRTM Lua�łɂ��Đ������܂��B

### RT�~�h���E�F�A�Ƃ́H
[RT�~�h���E�F�A(RTM)](http://www.openrtm.org/openrtm/ja)�̓\�t�g�E�F�A���W���[����g�ݍ��킹�ă��{�b�g�V�X�e�����\�z���邽�߂̕W���K�i�ł��B
�\�t�g�E�F�A���W���[����**RT�R���|�[�l���g(RTC)**�A���{�b�g�V�X�e����**RT�V�X�e��**�ƌĂт܂��B
������RT�~�h���E�F�A�̎����Ƃ��Ĉȉ��̂悤�Ȃ��̂�����܂��B


|����|���쌳|����|OS|�R�����g|
|:---|:---|:---|:---|:---|
|[OpenRTM-aist](http://www.openrtm.org/openrtm/ja)|�Y����|C++�AJava�APython|Windows�AUbuntu�ADebian�AFedora�AVxWorks�AQNX�BMac�͌����ł̓T�|�[�g���Ă��Ȃ��B|�����Ƃ��g���Ă���RTM����(�L���g���Ă���Ƃ͌����Ă��Ȃ�)�BOpenRTM-aist�ɂ̓L���[�A�v���P�[�V�����ƌĂׂ���̂������Ȃ����ߍ�����s���Ă��Ȃ��B|
|[OpenRTM.NET](http://www.sec.co.jp/robot/openrtmnet/introduction.html)|SEC|.NET(C#�AVisual Basic.NET��)|Windows|.NET��RT�~�h���E�F�A�B�X�V�̕p�x�����Ȃ��A�ŋ߂͂��܂�g���Ă��Ȃ��BGUI���A��ʂ̃A�v���P�[�V���������B|
|[RTM on Android](http://www.sec.co.jp/robot/rtm_on_android/introduction.html)|SEC|Java|Android|Android��RT�~�h���E�F�A�B�g���Ă��Ȃ��B|
|HRTM|�{�cR&D|C++|Windows�AUbuntu�AVxWorks|FSM4RTC�̃T�|�[�g���B�I�[�v���\�[�X�ł͂Ȃ����ߊO���ł͎g���Ă��Ȃ��B|
|[OpenRTM-erlang](https://github.com/gbiggs/openrtm-erl)|�Y����|Erlang|Linux�H|Erlang�͂��܂�g�������Ƃ������̂ł悭������܂���BRTC�������Ă������ɍċN������̂͌��Ă��Ėʔ����B|
|RTMSafety|SEC|C����|QNX�ATOPPERS�AETAS RTA-OS�AOS�Ȃ�|�@�\���S�̔F�ؑΉ���RT�~�h���E�F�A�B�g�������ƂȂ��B|
|OPRoS|ETRI|||�悭�m��܂���|
|GostaiRTC|GOSTAI�ATHALES|C++||�悭�m��܂���|
|[ReactiveRTM](https://github.com/zoetrope/ReactiveRTM)||.NET|Windows�H|�g�������ƂȂ��ł��B|


### OpenRTM Lua�ł̓���

OpenRTM Lua�ł��g�p���邱�Ƃɂ��A�����̃A�v���P�[�V�������RTC���N������C++��Python��RTC�Ɛڑ�������ALua�̃��C�u���������p����RTC���쐬����Ƃ��������ł��܂��B


OpenRTM Lua�łɂ͈ȉ���3�̓���������܂��B
#### �y��
�\�t�g�E�F�A�ꎮ��2MB���x�ƁA����RT�~�h���E�F�A�̎����ɔ�ׂĔ��Ɍy�ʂł��B

Lua(1.84MB)>LuaJIT(2.14MB)>>>>Python(7.65MB)>=C++(8.05MB)>>>Java(��)

<!-- 
���쒆�̃������g�p�ʂ�Python�łƔ�r���ď������Ȃ��Ă��܂��B

�ȉ���ConsoleIn�R���|�[�l���g���s���̃������g�p�ʂł��B

C++(2.1MB)>>>Lua(12.5MB)>Python(15.3MB)>>Java(22.0MB)
-->

#### ���̃\�t�g�E�F�A�ւ̑g�ݍ��݂��\
Lua�X�N���v�e�B���O�@�\�̂���\�t�g�E�F�A�ł���Αg�ݍ��݉\�ł��B

�ȉ��͎茳�œ���m�F�����\�t�g�E�F�A�ł��B

AviUtl��NScripter2��ł�RTC���N���ł��܂����A���p���͊F���ł��B

���̃V�~�����[�^�A�Q�[���J���c�[�����Ƒ����������ł��B

��F

* V-REP(���{�b�g�V�~�����[�^), https://www.youtube.com/watch?v=EaQ2oOxfhSY
* BizHawk(�Q�[���G�~�����[�^), https://www.youtube.com/watch?v=5dYfUjRzzQ8
* Laputan Blueprints(���̃V�~�����[�^), https://www.youtube.com/watch?v=FS52TlHDKiU
* AviUtl(����ҏW�\�t�g)
* NScripter2(�X�N���v�g�G���W��)
* LOVE(2D�Q�[���G���W��)
* Celestia(3D�V�̃V�~�����[�^)
* OpenResty(WEB�A�v���T�[�o�[), https://www.youtube.com/watch?v=_-Kw8qv_keo, https://www.youtube.com/watch?v=4qxKCBcIIEE

##### ���p�菇

* [V�]REP��œ��삷��RTC�̍쐬���@](V�]REP��œ��삷��RTC�̍쐬���@)
* [BizHawk��œ��삷��RTC�̍쐬���@](BizHawk��œ��삷��RTC�̍쐬���@)
* [Laputan Blueprints��œ��삷��RTC�̍쐬���@](Laputan-Blueprints��œ��삷��RTC�̍쐬���@)
* [OpenResty��œ��삷��RTC�̍쐬���@](OpenResty��œ��삷��RTC�̍쐬���@)


#### ����
JIT�R���p�C����LuaJIT���p�ɂ��AC++�ɕC�G���鑬�x�œ��삪�\�ł��B

* [��������](��������)

### OpenRTM Lua�ł��g�����ɂ��ARTM���[�U�[�ɂƂ��Ẵ����b�g
������RTM�ɑΉ����Ă��Ȃ��A�v���P�[�V������RTC�����邱�Ƃɂ��A�l�X��RT�V�X�e�����J���\�ɂȂ�܂��B

�܂�Python�ł͏������x���A�������g�p�ʂ��傫��������LuaJIT�œ��삷��RTC�Ŏ������邱�ƂŁA�X�N���v�g����ɂ������I�ȊJ���ƍ����ȏ����𗼗������邱�Ƃ��\�ł��B

### OpenRTM Lua�ł��g�����ɂ��A��RTM���[�U�[�ɂƂ��Ẵ����b�g
Lua�X�N���v�g�@�\���T�|�[�g���Ă���A�v���P�[�V������l�X�ȃf�o�C�X�A���邢�͑��̃A�v���P�[�V�����Ɛڑ��\�ɂ��܂��B
�Ⴆ��Laputan Blueprints��̎ԁA��s�@����LEGO Mindstorms EV3�̃f�o�C�X�ő��삷��Ƃ������Ƃ��ł��܂��B


## �_�E�����[�h

* [�_�E�����[�h](�_�E�����[�h)

## ����m�F
�_�E�����[�h�����t�@�C����W�J���āA�o�b�`�t�@�C�����N������ƃT���v���R���|�[�l���g���N�����܂��B
�T���v���R���|�[�l���g�̎��s�ɂ̓C���X�g�[���s�v�ł��B

* ConsoleIn.bat
* ConsoleOut.bat
* SeqIn.bat
* SeqOut.bat
* MyServiceConsumer.bat
* MyServiceProvider.bat
* ConfigSample.bat

RTSystemEditor�A�l�[���T�[�o�[��OpenRTM-aist�̂��̂��g�p���Ă��������B

* [OpenRTM-aist](http://www.openrtm.org/openrtm/ja/node/6026)

openrtm.org�������Ă���ꍇ�͈ȉ��̃T�C�g������肵�Ă��������B
* [openrtm.github.io](https://openrtm.github.io/)

## �C���X�g�[�����@

* [Windows](Windows�ւ̃C���X�g�[���菇)
* [Ubuntu](Ubuntu�ւ̃C���X�g�[���菇)

## RTC�쐬���@

��OpenRTM-aist 1.2.0��RTC Builder���g���ꍇ��[RTC�쐬�菇](RTC�쐬�菇)���Q�l�ɂ��Ă��������B

�T���v�����ɁARTC�쐬���@��������܂��B



### ���W���[�����[�h
�ȉ��̂悤�Ƀ��W���[���̃��[�h���s���܂��B

<pre>
local openrtm  = require "openrtm"
</pre>

### RTC�̎d�l���`
�ȉ��̂悤��RTC�̎d�l���`�����e�[�u�����쐬���܂��B

<pre>
local consolein_spec = {
  ["implementation_id"]="ConsoleIn",
  ["type_name"]="ConsoleIn",
  ["description"]="Console output component",
  ["version"]="1.0",
  ["vendor"]="Vendor Name",
  ["category"]="example",
  ["activity_type"]="DataFlowComponent",
  ["max_instance"]="10",
  ["language"]="Lua",
  ["lang_type"]="script"}
</pre>

### RTC�̃e�[�u���쐬
RTC�̃e�[�u�����쐬����֐����`���܂��B

<pre>
local ConsoleIn = {}
ConsoleIn.new = function(manager)
	local obj = {}
	-- RTObject�����^�I�u�W�F�N�g�ɐݒ肷��
	setmetatable(obj, {__index=openrtm.RTObject.new(manager)})
	-- ���������̃R�[���o�b�N�֐�
	function obj:onInitialize()
	   (�ȗ�)
	end
	-- �A�N�e�B�u��Ԃ̎��̎��s�֐�
	function obj:onExecute(ec_id)
	   (�ȗ�)
	end

	return obj
end
</pre>

### �f�[�^�|�[�g
�A�E�g�|�[�g�A�C���|�[�g�A�T�[�r�X�|�[�g��onInitialize�֐��Œǉ����܂��B

#### �A�E�g�|�[�g
<pre>
ConsoleIn.new = function(manager)
	(�ȗ�)
	-- �f�[�^�i�[�ϐ�
	obj._d_out = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- �A�E�g�|�[�g����
	obj._outOut = openrtm.OutPort.new("out",obj._d_out,"::RTC::TimedLong")
	(�ȗ�)
	function obj:onInitialize()
		-- �|�[�g�ǉ�
		self:addOutPort("out",self._outOut)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

�f�[�^�̏o�͂��s���ꍇ�́A`self._d_out`�ɑ��M�f�[�^���i�[��A`self._outOut`��write�֐������s���܂��B

<pre>
-- �o�̓f�[�^�i�[
self._d_out.data = 1
-- �f�[�^��������
self._outOut:write()
</pre>

#### �C���|�[�g
<pre>
ConsoleOut.new = function(manager)
	(�ȗ�)
	-- �f�[�^�i�[�ϐ�
	obj._d_in = openrtm.RTCUtil.instantiateDataType("::RTC::TimedLong")
	-- �C���|�[�g����
	obj._inIn = openrtm.InPort.new("in",obj._d_in,"::RTC::TimedLong")
	(�ȗ�)
	function obj:onInitialize()
		-- �|�[�g�ǉ�
		self:addInPort("in",self._inIn)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

`openrtm.RTCUtil.instantiateDataType`�֐��ɂ��A�f�[�^���i�[����ϐ����������ł��܂��B

`openrtm.OutPort.new("out",self._d_out,"::RTC::TimedLong")`�̂悤�ɁA�f�[�^�^�͕�����Ŏw�肷��K�v������܂��B


���̓f�[�^��ǂݍ��ޏꍇ�́A`self._inIn`��read�֐����g�p���܂��B


<pre>
-- �o�b�t�@�ɐV�K�f�[�^�����邩���m�F
if self._inIn:isNew() then
	-- �f�[�^�ǂݍ���
	local data = self._inIn:read()
	print("Received: ", data.data)
end
</pre>

`isNew`�֐��ŐV�K�f�[�^�̗L�����m�F�ł��܂��B

### �T�[�r�X�|�[�g

#### �v���o�C�_

�v���o�C�_���̃T�[�r�X�|�[�g�𐶐����邽�߂ɂ́A�܂��v���o�C�_�̃e�[�u�����쐬���܂��B

<pre>
local MyServiceSVC_impl = {}
MyServiceSVC_impl.new = function()
	local obj = {}
		(�ȗ�)
	function obj:echo(msg)
		(�ȗ�)
	end
	function obj:get_echo_history()
		(�ȗ�)
	end
	function obj:set_value(value)
		(�ȗ�)
	end
	function obj:get_value()
		(�ȗ�)
	end
	function obj:get_value_history()
		(�ȗ�)
	end

	return obj
end
</pre>

onInitialize�֐����Ń|�[�g�̐����A�o�^���s���܂��B

<pre>
MyServiceProvider.new = function(manager)
	(�ȗ�)
	-- �T�[�r�X�|�[�g����
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- �v���o�C�_�I�u�W�F�N�g����
	obj._myservice0 = MyServiceSVC_impl.new()
	(�ȗ�)
	function obj:onInitialize()
		-- �T�[�r�X�|�[�g�Ƀv���o�C�_�I�u�W�F�N�g��o�^
		self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, "idl/MyService.idl", "IDL:SimpleService/MyService:1.0")
		-- �|�[�g�ǉ�
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

`self._myServicePort:registerProvider("myservice0", "MyService", self._myservice0, "../idl/MyService.idl", "IDL:SimpleService/MyService:1.0")`�̂悤�ɁAIDL�t�@�C�����A�C���^�[�t�F�[�X���𕶎���Ŏw�肷��K�v������܂��B

### �T�[�r�X�|�[�g

#### �R���V���[�}

�R���V���[�}���̃T�[�r�X�|�[�g��ǉ�����ɂ́A�ȉ��̂悤��onInitialize�֐����Ń|�[�g�̐����A�ǉ����s���܂��B
`self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "../idl/MyService.idl")`�̂悤��IDL�t�@�C�����𕶎���Ŏw�肷��K�v������܂��B

<pre>
MyServiceConsumer.new = function(manager)
	(�ȗ�)
	-- �T�[�r�X�|�[�g����
	obj._myServicePort = openrtm.CorbaPort.new("MyService")
	-- �R���V���[�}�I�u�W�F�N�g����
	obj._myservice0 = openrtm.CorbaConsumer.new("IDL:SimpleService/MyService:1.0")
	(�ȗ�)
	function obj:onInitialize()
		-- �T�[�r�X�|�[�g�ɃR���V���[�}�I�u�W�F�N�g��o�^
		self._myServicePort:registerConsumer("myservice0", "MyService", self._myservice0, "idl/MyService.idl")
		-- �|�[�g�ǉ�
		self:addPort(self._myServicePort)

		return self._ReturnCode_t.RTC_OK
	end
</pre>

�I�y���[�V�������Ăяo���ꍇ�́ACorbaConsumer��_ptr�֐��ŃI�u�W�F�N�g���t�@�����X���擾���Ċ֐����Ăяo���܂��B

<pre>
self._myservice0:_ptr():set_value(val)
</pre>

### �R���t�B�M�����[�V�����p�����[�^�ݒ�
�R���t�B�O���[�V�����p�����[�^�̐ݒ�ɂ́A�܂�RTC�̎d�l�ɃR���t�B�O���[�V�����p�����[�^��ǉ����܂��B

<pre>
local configsample_spec = {
  (�ȗ�)
  ["conf.default.int_param0"]="0",
  ["conf.default.int_param1"]="1",
  ["conf.default.double_param0"]="0.11",
  ["conf.default.double_param1"]="9.9",
  ["conf.default.str_param0"]="hoge",
  ["conf.default.str_param1"]="dara",
  ["conf.default.vector_param0"]="0.0,1.0,2.0,3.0,4.0"}
</pre>

onInitialize�֐��ŕϐ����o�C���h���܂��B
�l��`_value`�Ƃ����L�[�Ɋi�[����܂��B

<pre>
ConfigSample.new = function(manager)
	(�ȗ�)
	-- �R���t�B�M�����[�V�����p�����[�^���o�C���h����ϐ�
	obj._int_param0 = {_value=0}
	(�ȗ�)
	function obj:onInitialize()
		-- �R���t�B�M�����[�V�����p�����[�^��ϐ��Ƀo�C���h����
		self._int_param0 = {_value=0}
		(�ȗ�)


		self:bindParameter("int_param0", self._int_param0, "0")
		(����)
		return self._ReturnCode_t.RTC_OK
	end
</pre>


### �R�[���o�b�N��`
onExecute�R�[���o�b�N�Ȃǂ��`����ꍇ�ɂ��Ă��A�֐����`���ď������L�q���܂��B

<pre>
	function obj:onExecute(ec_id)
		io.write("Please input number: ")
		local data = tonumber(io.read())
		self._d_out.data = data
		openrtm.OutPort.setTimestamp(self._d_out)
		self._outOut:write()
		return self._ReturnCode_t.RTC_OK
	end
</pre>



### RTC�N���̊֐���`


�ȉ��̂悤��RTC�̓o�^�A�����֐����`���܂��B

<pre>
ConsoleIn.Init = function(manager)
	local prof = openrtm.Properties.new({defaults_map=consolein_spec})
	manager:registerFactory(prof, ConsoleIn.new, openrtm.Factory.Delete)
end

local MyModuleInit = function(manager)
	ConsoleIn.Init(manager)
	local comp = manager:createComponent("ConsoleIn")
end
</pre>

### �}�l�[�W���N��
�ȉ��̂悤��RTC�����֐���ݒ肵�ă}�l�[�W�����N�����܂��B

<pre>
local manager = openrtm.Manager
manager:init(arg)
manager:setModuleInitProc(MyModuleInit)
manager:activateManager()
manager:runManager()
</pre>


## ���C�Z���X
MIT���C�Z���X

## �ˑ����C�u����

* [Lua-5.1](https://www.lua.org/)(MIT���C�Z���X)
* [OiL-0.4](https://webserver2.tecgraf.puc-rio.br/~maia/oil/index.html)(MIT���C�Z���X)
* [LuaIDL](https://github.com/LuaDist/luaidl)(MIT���C�Z���X)
* [loop](https://github.com/LuaDist/loop)(MIT���C�Z���X)
* [LuaSocket](https://github.com/diegonehab/luasocket)(MIT���C�Z���X)
* [LuaLogging](https://github.com/Neopallium/lualogging)(MIT���C�Z���X)
* [LUA-RFC-4122-UUID-Generator](https://github.com/tcjennings/LUA-RFC-4122-UUID-Generator)(MIT���C�Z���X)

* [MoonScript](http://moonscript.org)(MIT���C�Z���X)
* [LPeg](https://luarocks.org/modules/gvvaughan/lpeg)(MIT���C�Z���X)
* [argparse](https://github.com/mpeterv/argparse)(MIT���C�Z���X)

## ����RTM�����ƃf�[�^�|�[�g�ʐM����ꍇ�ɂ���
OpenRTM-aist 1.0�n�t����DataPort.idl��OiL�ł͓ǂݍ��߂Ȃ����߁AOpenRTM-aist 2.0�t����DataPort.idl���K�v�ɂȂ�܂��B
����AOpenRTM-aist 1.2�ȑO�A�����OpenRTM.NET�ƒʐM�����i�͂���܂��񂪁A�J������OpenRTM-aist 2.0�Ƃ͒ʐM�ł��܂��B

Python�ł�OpenRTM-aist 2.0(�J����)�̃C���X�g�[�����@��������܂��B

�܂�OpenRTM-aist���C���X�g�[���[�ŃC���X�g�[�����Ă��������B
����[TortoiseSVN](https://ja.osdn.net/projects/tortoisesvn/)���ňȉ�����OpenRTM-aist Python�� 2.0�̃\�[�X�R�[�h����肵�܂��B

* http://svn.openrtm.org/OpenRTM-aist-Python/trunk/OpenRTM-aist-Python/

setup.py�̈ȉ��̕�����ύX���܂��B

<pre>
#pkg_data_files_win32 = [("Scripts", ['OpenRTM_aist/utils/rtcd/rtcd_python.exe'])]
pkg_data_files_win32 = []
</pre>

OpenRTM-aist Python�� 2.0�̃\�[�X�R�[�h�̃f�B���N�g���Ɉړ����Ĉȉ��̃R�}���h�����s����ƁA�C���X�g�[���[�ŃC���X�g�[������OpenRTM-aist���㏑�����܂��B���p�X�ɓ��{�ꂪ�܂܂�Ă���ꍇ�Ɏ��s���邱�Ƃ�����܂��B���̏ꍇ�̓f�B���N�g����ύX���ăR�}���h�����s���Ă��������B

<pre>
python setup.py build
python setup.py install
</pre>

## LuaJIT�̗��p

* [LuaJIT�̗��p](LuaJIT�̗��p)

## �J������

* [�J������](�J������)

## �����[�X�m�[�g

* [�����[�X�m�[�g](�����[�X�m�[�g)

## ���������[�X�ł̒ǉ��A�C������

* [���������[�X�ł̒ǉ��A�C������](���������[�X�ł̒ǉ��A�C������)
