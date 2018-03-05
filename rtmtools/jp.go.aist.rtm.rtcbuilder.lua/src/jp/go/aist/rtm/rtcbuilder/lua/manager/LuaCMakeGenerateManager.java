package jp.go.aist.rtm.rtcbuilder.lua.manager;

import java.io.InputStream;
import java.util.List;
import java.util.Map;

import jp.go.aist.rtm.rtcbuilder.generator.GeneratedResult;
import jp.go.aist.rtm.rtcbuilder.generator.param.RtcParam;
import jp.go.aist.rtm.rtcbuilder.manager.CMakeGenerateManager;
import jp.go.aist.rtm.rtcbuilder.template.TemplateUtil;
import static jp.go.aist.rtm.rtcbuilder.IRtcBuilderConstants.*;
import static jp.go.aist.rtm.rtcbuilder.util.RTCUtil.form;
import static jp.go.aist.rtm.rtcbuilder.lua.IRtcBuilderConstantsLua.LANG_LUA;
import static jp.go.aist.rtm.rtcbuilder.lua.IRtcBuilderConstantsLua.LANG_LUA_ARG;

public class LuaCMakeGenerateManager extends CMakeGenerateManager {

	static final String TEMPLATE_PATH_LUA = "jp/go/aist/rtm/rtcbuilder/lua/template";

	public LuaCMakeGenerateManager() {
	}

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
	public Map<String, Object> createContextMap(RtcParam rtcParam) {
		Map<String, Object> map = super.createContextMap(rtcParam);
		map.put("templateLua", TEMPLATE_PATH_LUA);
		return map;
	}

	// RTM 1.0系
	@Override
	public List<GeneratedResult> generateTemplateCode10(
			Map<String, Object> contextMap) {
		List<GeneratedResult> result = super.generateTemplateCode10(contextMap);

		GeneratedResult gr;
		RtcParam rtcParam = (RtcParam) contextMap.get("rtcParam");
		if(0<rtcParam.getServicePorts().size()) {
			gr = generatePostinstIin(contextMap);
			result.add(gr);
			gr = generatePrermIn(contextMap);
			result.add(gr);
			gr = generateCMakeWixPatchXmlIn(contextMap);
			result.add(gr);
		}
		
		return result;
	}

	// 1.0系 (CMake)

	@Override
	public GeneratedResult generateCMakeLists(Map<String, Object> contextMap) {
		String outfile = "CMakeLists.txt";
		String infile = "cmake/CMakeLists.txt.vsl";
		GeneratedResult result = generateLua(infile, outfile, contextMap); 
		//result.setNotBom(true);
		return result;
	}

	// 1.0系 (CMake/cpack_resources)
	public GeneratedResult generatePostinstIin(Map<String, Object> contextMap) {
		String outfile = "postinst.in";
		String infile = "cmake/postinst.in.vsl";
		return generateLua(infile, outfile, contextMap);
	}

	public GeneratedResult generatePrermIn(Map<String, Object> contextMap) {
		String outfile = "prerm.in";
		String infile = "cmake/prerm.in.vsl";
		return generateLua(infile, outfile, contextMap);
	}

	public GeneratedResult generateCMakeWixPatchXmlIn(Map<String, Object> contextMap) {
		String outfile = "cmake/wix_patch.xml.in";
		String infile = "cmake/wix_patch.xml.in.vsl";
		return generateLua(infile, outfile, contextMap);
	}
	
	@Override
	public GeneratedResult generateCmakeCPackOption(Map<String, Object> contextMap) {
		String outfile = "cmake/cpack_options.cmake.in";
		String infile = "cmake/cpack_options_cmake.in.vsl";
		GeneratedResult result = generateLua(infile, outfile, contextMap); 
		//result.setNotBom(true);
		return result;
	}
	
	@Override
	public GeneratedResult generateSrcCMakeLists(Map<String, Object> contextMap) {
		String outfile = "src/CMakeLists.txt";
		String infile = "cmake/SrcCMakeLists.txt.vsl";
		GeneratedResult result = generateLua(infile, outfile, contextMap); 
		//result.setNotBom(true);
		return result;
	}
	/////
	public GeneratedResult generateLua(String infile, String outfile,
			Map<String, Object> contextMap) {
		try {
			String template = TEMPLATE_PATH_LUA + "/" + infile;
			ClassLoader cl = Thread.currentThread().getContextClassLoader();
			InputStream ins = cl.getResourceAsStream(template);
			GeneratedResult gr = TemplateUtil.createGeneratedResult(ins,
					contextMap, outfile);
			if (ins != null) {
				ins.close();
			}
			return gr;
		} catch (Exception e) {
			throw new RuntimeException(form(MSG_ERROR_GENERATE_FILE,
					new String[] { "CMake", outfile }), e);
		}
	}

}
