package jp.go.aist.rtm.rtcbuilder.lua.manager;

import static jp.go.aist.rtm.rtcbuilder.IRtcBuilderConstants.*;
import static jp.go.aist.rtm.rtcbuilder.lua.IRtcBuilderConstantsLua.*;
import static jp.go.aist.rtm.rtcbuilder.util.RTCUtil.*;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.go.aist.rtm.rtcbuilder.generator.GeneratedResult;
import jp.go.aist.rtm.rtcbuilder.generator.param.RtcParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.IdlFileParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.ServiceClassParam;
import jp.go.aist.rtm.rtcbuilder.lua.ui.Perspective.LuaProperty;
import jp.go.aist.rtm.rtcbuilder.manager.GenerateManager;
import jp.go.aist.rtm.rtcbuilder.template.TemplateHelper;
import jp.go.aist.rtm.rtcbuilder.template.TemplateUtil;
import jp.go.aist.rtm.rtcbuilder.ui.Perspective.LanguageProperty;

/**
 * Luaファイルの出力を制御するマネージャ
 */
public class LuaGenerateManager extends GenerateManager {

	static final String TEMPLATE_PATH = "jp/go/aist/rtm/rtcbuilder/lua/template";

	static final String MSG_ERROR_GENERATE_FILE = "Lua generation error. [{0}]";

	@Override
	public String getTargetVersion() {
		return RTM_VERSION_100;
	}

	@Override
	public String getManagerKey() {
		return LANG_LUA;
	}

	@Override
	public String getLangArgList() {
		return LANG_LUA_ARG;
	}

	@Override
	public LanguageProperty getLanguageProperty(RtcParam rtcParam) {
		LanguageProperty langProp = null;
		if (rtcParam.isLanguageExist(LANG_LUA)) {
			langProp = new LuaProperty();
		}
		return langProp;
	}

	/**
	 * ファイルを出力する
	 *
	 * @param generatorParam
	 * @return 出力結果のリスト
	 */
	public List<GeneratedResult> generateTemplateCode(RtcParam rtcParam) {
		List<GeneratedResult> result = new ArrayList<GeneratedResult>();

		if (!rtcParam.isLanguageExist(LANG_LUA)) {
			return result;
		}

		List<IdlFileParam> allIdlFileParams = new ArrayList<IdlFileParam>();
		allIdlFileParams.addAll(rtcParam.getProviderIdlPathes());
		allIdlFileParams.addAll(rtcParam.getConsumerIdlPathes());
		List<IdlFileParam> allIdlFileParamsForBuild = new ArrayList<IdlFileParam>();
		allIdlFileParamsForBuild.addAll(allIdlFileParams);
		allIdlFileParamsForBuild.addAll(rtcParam.getIncludedIdlPathes());

		// IDLファイル内に記述されているServiceClassParamを設定する
		for (IdlFileParam idlFileParam : allIdlFileParams) {
			for (ServiceClassParam serviceClassParam : rtcParam.getServiceClassParams()) {
				if (idlFileParam.getIdlPath().equals(serviceClassParam.getIdlPath())){
					if (!idlFileParam.getServiceClassParams().contains(serviceClassParam)){
						idlFileParam.addServiceClassParams(serviceClassParam);
					}
				}
			}
		}

		Map<String, Object> contextMap = new HashMap<String, Object>();
		contextMap.put("template", TEMPLATE_PATH);
		contextMap.put("rtcParam", rtcParam);
		contextMap.put("tmpltHelper", new TemplateHelper());
		contextMap.put("tmpltHelperLua", new TemplateHelperLua());
		contextMap.put("luaConv", new LuaConverter());
		contextMap.put("allIdlFileParam", allIdlFileParams);
		contextMap.put("idlPathes", rtcParam.getIdlPathes());
		contextMap.put("allIdlFileParamBuild", allIdlFileParamsForBuild);

		return generateTemplateCode10(contextMap);
	}

	// RTM 1.0系
	@SuppressWarnings("unchecked")
	public List<GeneratedResult> generateTemplateCode10(
			Map<String, Object> contextMap) {
		List<GeneratedResult> result = new ArrayList<GeneratedResult>();
		RtcParam rtcParam = (RtcParam) contextMap.get("rtcParam");
		List<IdlFileParam> allIdlFileParams = (List<IdlFileParam>) contextMap
				.get("allIdlFileParam");

		GeneratedResult gr;
		gr = generateLuaSource(contextMap);
		result.add(gr);

		/*
		if ( 0<allIdlFileParams.size() ) {
			gr = generateIDLCompileBat(contextMap);
			result.add(gr);
			gr = generateIDLCompileSh(contextMap);
			result.add(gr);
			gr = generateDeleteBat(contextMap);
			result.add(gr);
		}
		*/

		for (IdlFileParam idlFileParam : rtcParam.getProviderIdlPathes()) {
			contextMap.put("idlFileParam", idlFileParam);
			gr = generateSVCIDLExampleSource(contextMap);
			result.add(gr);
		}
		//////////
		gr = generateLuaTestSource(contextMap);
		result.add(gr);
		for (IdlFileParam idlFileParam : rtcParam.getConsumerIdlPathes()) {
			contextMap.put("idlFileParam", idlFileParam);
			gr = generateTestSVCIDLExampleSource(contextMap);
			result.add(gr);
		}

		return result;
	}

	// 1.0系 (Lua)

	public GeneratedResult generateLuaSource(Map<String, Object> contextMap) {
		RtcParam rtcParam = (RtcParam) contextMap.get("rtcParam");
		String outfile = rtcParam.getName() + ".lua";
		String infile = "lua/Lua_RTC.lua.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		result.setNotBom(true);
		//result.setEncode("UTF-8");
		return result;
	}

	public GeneratedResult generateSVCIDLExampleSource(
			Map<String, Object> contextMap) {
		IdlFileParam idlParam = (IdlFileParam) contextMap.get("idlFileParam");
		String outfile = idlParam.getIdlFileNoExt() + "_idl_example.lua";
		String infile = "lua/Lua_SVC_idl_example.lua.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		result.setNotBom(true);
		return result;
	}

	// 1.0系 (ビルド環境)


	public GeneratedResult generateIDLCompileBat(Map<String, Object> contextMap) {
		String outfile = "idlcompile.bat";
		String infile = "lua/idlcompile.bat.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		//result.setEncode("Shift_JIS");
		return result;
	}


	public GeneratedResult generateIDLCompileSh(Map<String, Object> contextMap) {
		String outfile = "idlcompile.sh";
		String infile = "lua/idlcompile.sh.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		//result.setNotBom(true);
		return result;
	}

	public GeneratedResult generateDeleteBat(Map<String, Object> contextMap) {
		String outfile = "delete.bat";
		String infile = "lua/delete.bat.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		//result.setEncode("Shift_JIS");
		return result;
	}

	//////////
	public GeneratedResult generateLuaTestSource(Map<String, Object> contextMap) {
		RtcParam rtcParam = (RtcParam) contextMap.get("rtcParam");
		String outfile = "test/" + rtcParam.getName() + "Test.lua";
		String infile = "lua/test/Lua_Test_RTC.lua.vsl";
		GeneratedResult result = generate(infile, outfile, contextMap);
		result.setNotBom(true);
		return result;
	}

	public GeneratedResult generateTestSVCIDLExampleSource(
			Map<String, Object> contextMap) {
		IdlFileParam idlParam = (IdlFileParam) contextMap.get("idlFileParam");
		String outfile = "test/" + idlParam.getIdlFileNoExt() + "_idl_example.lua";
		String infile = "lua/Lua_SVC_idl_example.lua.vsl";
		return generate(infile, outfile, contextMap);
	}
	//////////
	public GeneratedResult generate(String infile, String outfile,
			Map<String, Object> contextMap) {
		try {
			String template = TEMPLATE_PATH + "/" + infile;
			InputStream ins = getClass().getClassLoader().getResourceAsStream(
					template);
			GeneratedResult gr = TemplateUtil.createGeneratedResult(ins,
					contextMap, outfile);
			if (ins != null) {
				ins.close();
			}
			return gr;
		} catch (Exception e) {
			throw new RuntimeException(form(MSG_ERROR_GENERATE_FILE,
					new String[] { outfile }), e);
		}
	}

}
