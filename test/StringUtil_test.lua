local luaunit = require "luaunit"
local StringUtil = require "openrtm.StringUtil"


TestStringUtil = {}


function TestStringUtil:test_string()
	luaunit.assertEquals(StringUtil.eraseHeadBlank(" test"), "test")
	luaunit.assertEquals(StringUtil.eraseTailBlank("test "), "test")
	luaunit.assertEquals(StringUtil.eraseBothEndsBlank(" test "), "test")
	luaunit.assertEquals(StringUtil.normalize(" Test "), "test")
	luaunit.assertIsTrue(StringUtil.isEscaped("te\\st",3))
	luaunit.assertEquals(StringUtil.unescape("te\\st"), "test")
	luaunit.assertEquals(#StringUtil.split("test2,test2,test3",","), 3)
	luaunit.assertIsTrue(StringUtil.toBool("yes","yes","no"))
	luaunit.assertIsFalse(StringUtil.toBool("no","yes","no"))
	luaunit.assertIsFalse(StringUtil.toBool("dummy","yes","no",false))
	luaunit.assertEquals(StringUtil.otos(1), "1")
	luaunit.assertIsTrue(StringUtil.in_value({["key1"]="test1",["key2"]="test2"},"test1"))
	luaunit.assertIsFalse(StringUtil.in_value({["key1"]="test1",["key2"]="test2"},"dummy"))
	luaunit.assertIsTrue(StringUtil.in_key({["key1"]="test1",["key2"]="test2"},"key1"))
	luaunit.assertIsFalse(StringUtil.in_key({["key1"]="test1",["key2"]="test2"},"dummy"))
	local tbl1 = {"test1","test2"}
	local tbl2 = StringUtil.copy(tbl1)
	luaunit.assertEquals(tbl2[1], "test1")
	local tbl1 = {["key1"]="test1",["key2"]="test2"}
	local tbl2 = StringUtil.deepcopy(tbl1)
	luaunit.assertEquals(tbl2["key1"], "test1")
	local tbl1 = {"test1","test2","test1"}
	local tbl2 = StringUtil.unique_sv(tbl1)
	luaunit.assertEquals(#tbl2, 2)
	luaunit.assertEquals(StringUtil.flatten({"test1","test2"}), "test1, test2")
	luaunit.assertEquals(StringUtil.table_count(tbl1,"test1"), 2)
	luaunit.assertEquals(StringUtil.table_index(tbl1,"test2"), 2)
	luaunit.assertIsTrue(StringUtil.includes(tbl1,"test2"))
	luaunit.assertIsFalse(StringUtil.includes(tbl1,"dummy"))
	luaunit.assertIsTrue(StringUtil.includes("test1,test2","test2"))
	local ret, _list = StringUtil._stringToList({"0","0"},"1,2,3")
	luaunit.assertIsTrue(ret)
	luaunit.assertEquals(_list[1], "1")
	luaunit.assertEquals(_list[2], "2")
	local ret, _list = StringUtil._stringToList({0,0},"1,2,3")
	luaunit.assertIsTrue(ret)
	luaunit.assertEquals(_list[1], 1)
	luaunit.assertEquals(_list[2], 2)

	local ret, value = StringUtil.stringTo(0,"1")
	luaunit.assertIsTrue(ret)
	luaunit.assertEquals(value, 1)
	local ret, value = StringUtil.stringTo("0","1")
	luaunit.assertIsTrue(ret)
	luaunit.assertEquals(value, "1")
	local ret, value = StringUtil.stringTo({0,0},"1,2")
	luaunit.assertIsTrue(ret)
	luaunit.assertEquals(#value, 2)

	local ret = StringUtil.createopt("adlf:o:p:")
	luaunit.assertIsFalse(ret["a"].optarg)
	luaunit.assertIsTrue(ret["f"].optarg)
	
	local opts = StringUtil.getopt({"-o","test1","-a"},"adlf:o:p:")
	for i, opt in ipairs(opts) do
		if opt.id == "o" then
			luaunit.assertEquals(opt.optarg, "test1")
		end
	end

	local dirname1 = "C:\\test1\\test2\\test3.txt"
	luaunit.assertEquals(StringUtil.dirname(dirname1),"C:\\test1\\test2\\")
	local dirname2 = "/test1/test2/test3.txt"
	luaunit.assertEquals(StringUtil.dirname(dirname2),"/test1/test2/")


	luaunit.assertEquals(StringUtil.basename(dirname1),"test3.txt")
	luaunit.assertEquals(StringUtil.basename(dirname2),"test3.txt")


	luaunit.assertEquals(StringUtil.getKeyCount({["key1"]="test1",["key2"]="test2"}),2)

	luaunit.assertIsTrue(StringUtil.isURL("https://www.tmp.openrtm.org"))
	luaunit.assertIsFalse(StringUtil.isURL(dirname1))

	luaunit.assertIsTrue(StringUtil.isAbsolutePath(dirname1))
	luaunit.assertIsTrue(StringUtil.isAbsolutePath(dirname2))
	luaunit.assertIsFalse(StringUtil.isAbsolutePath("..\\test.txt"))

	local ret = StringUtil.urlparam2map("param?key1=value1&key2=value2")
	luaunit.assertEquals(ret["key1"],"value1")
	luaunit.assertEquals(ret["key2"],"value2")
end


local Manager = require "openrtm.Manager"
if Manager.is_main() then
	luaunit.LuaUnit.run()
end
