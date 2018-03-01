package jp.go.aist.rtm.rtcbuilder.lua.ui.Perspective;

import java.util.ArrayList;
import java.util.List;

import jp.go.aist.rtm.rtcbuilder.ui.Perspective.LanguageProperty;

public class LuaProperty extends LanguageProperty {
	private String PerspectiveId = "org.lua.ldt.ui.LuaPerspective";
	private String PerspectiveName = "Lua";
	private String PluginId = "org.lua.ldt";

	public String getPerspectiveId() {
		return PerspectiveId;
	}

	public String getPerspectiveName() {
		return PerspectiveName;
	}

	public String getPluginId() {
		return PluginId;
	}

	@Override
	public List<String> getNatures() {
		List<String> natures = new ArrayList<String>();
		natures.add("org.lua.ldt.luaNature");
		return natures;
	}
}
