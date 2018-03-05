package jp.go.aist.rtm.rtcbuilder.lua.manager;

import java.util.ArrayList;
import java.util.List;

import jp.go.aist.rtm.rtcbuilder.IRtcBuilderConstants;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.IdlFileParam;
import jp.go.aist.rtm.rtcbuilder.lua.IRtcBuilderConstantsLua;
import jp.go.aist.rtm.rtcbuilder.util.StringUtil;

/**
 * テンプレートを出力する際に使用されるヘルパー Lua用
 */
public class TemplateHelperLua {
	//
	public String convertDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_DEFAULT_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_DEFAULT_OFFSET_LUA);
	}
	public String convertAuthorDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_DEFAULT_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_AUTHOR_OFFSET_LUA);
	}
	public String convertModuleDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_MODULE_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_DEFAULT_OFFSET_LUA);
	}
	public String convertDescDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_DESC_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_DESC_OFFSET_LUA);
	}
	public String convertTypeDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_UNIT_PREFIX_LUA, IRtcBuilderConstants.DOC_UNIT_OFFSET);
	}
	public String convertNumberDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_NUMBER_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_NUMBER_OFFSET_LUA);
	}
	public String convertSemanticsDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_SEMANTICS_PREFIX_LUA, IRtcBuilderConstants.DOC_SEMANTICS_OFFSET);
	}
	public String convertFrequencyDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_FREQUENCY_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_FREQUENCY_OFFSET_LUA);
	}
	public String convertCycleDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_CYCLE_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_CYCLE_OFFSET_LUA);
	}
	public String convertInterfaceLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_NUMBER_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_NUMBER_OFFSET_LUA);
	}
	public String convertDetailLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_DETAIL_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_DETAIL_OFFSET_LUA);
	}
	public String convertUnitDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_UNIT_PREFIX_LUA, IRtcBuilderConstants.DOC_UNIT_OFFSET);
	}
	public String convertRangeDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_RANGE_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_RANGE_OFFSET_LUA);
	}
	public String convertConstraintDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_CONSTRAINT_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_CONSTRAINT_OFFSET_LUA);
	}
	public String convertPreDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_PRE_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_PRE_OFFSET_LUA);
	}
	public String convertPostDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_POST_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_POST_OFFSET_LUA);
	}
	public String convertActivityDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_ACTIVITY_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_ACTIVITY_OFFSET_LUA);
	}
	public String convertPreShDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_PRESH_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_PRE_OFFSET_LUA);
	}
	public String convertPostShDocLua(String source) {
		return StringUtil.splitString(source, IRtcBuilderConstantsLua.DOC_DEFAULT_WIDTH,
				IRtcBuilderConstantsLua.DOC_POSTSH_PREFIX_LUA, IRtcBuilderConstantsLua.DOC_POST_OFFSET_LUA);
	}
	//
	public boolean hasDataPortType(List<IdlFileParam> targetFiles) {
		for(IdlFileParam target : targetFiles) {
			if(target.isDataPort()) return true;
		}
		return false;
	}

	public List<String> getDataPortTypes(List<IdlFileParam> targetFiles) {
		List<String> result = new ArrayList<String>();
		List<String> check = new ArrayList<String>();
		check.add("RTC");
		check.add("OpenRTM_aist");

		for(IdlFileParam target : targetFiles) {
			if(target.isDataPort()==false) continue;
			String targetType = "";
			for(String targetTypes : target.getTargetType()) {
				if( targetTypes.contains("::") ) {
					String[] types = targetTypes.split("::");
					/////
					targetType = types[0];
					if(check.contains(targetType)==false) {
						check.add(targetType);
						result.add(targetType);
					}
//					StringBuilder builder = new StringBuilder();
//					for(int index=0;index<types.length-1;index++) {
//						if(index!=0) builder.append(".");
//						builder.append(types[index]);
//						targetType = builder.toString();
//						if(check.contains(targetType)==false) {
//							check.add(targetType);
//							result.add(targetType);
//						}
//					}

				} else {
					targetType = "_GlobalIDL";
					if(check.contains(targetType)==false) {
						check.add(targetType);
						result.add(targetType);
					}
				}
			}
		}
		return result;
	}
	public String convertServiceInterfaceName(String source) {
		return "IDL:"+source.replace("::", "/") + ":1.0";
	}
}
