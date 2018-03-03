package jp.go.aist.rtm.rtcbuilder.lua.manager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.go.aist.rtm.rtcbuilder.generator.param.ConfigSetParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.IdlFileParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.ServiceArgumentParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.ServiceClassParam;
import jp.go.aist.rtm.rtcbuilder.generator.param.idl.ServiceMethodParam;

/**
 * Lua�\�[�X���o�͂���ۂɎg�p����郆�[�e�B���e�B
 */
public class LuaConverter {
	protected Map<String, String> mapType;
	protected Map<String, String> mapTypeArgs;

	private final String dirIn = "in";
	private final String dirOut = "out";
	private final String dirInOut = "inout";

	private final String idlLongLong = "longlong";
	private final String idlUnsignedLong = "unsignedlong";
	private final String idlUnsignedLongLong = "unsignedlonglong";
	private final String idlUnsignedShort = "unsignedshort";
	private final String idlString = "string";
	private final String idlWstring = "wstring";
	private final String idlVoid= "void";
	//
	private final String luaLongLong = "longlong";
	private final String luaUnsignedLong = "ulong";
	private final String luaUnsignedLongLong = "ulonglong";
	private final String luaUnsignedShort = "ushort";
	private final String luaString = "string";
	//
	private final String luaLongLongParam = "long long";
	private final String luaUnsignedLongParam = "unsigned long";
	private final String luaUnsignedLongLongParam = "unsigned long long";
	private final String luaUnsignedShortParam = "unsigned short";
	//

	public LuaConverter() {
		mapType = new HashMap<String, String>();
		mapType.put(idlLongLong, luaLongLong);
		mapType.put(idlUnsignedLong, luaUnsignedLong);
		mapType.put(idlUnsignedLongLong, luaUnsignedLongLong);
		mapType.put(idlUnsignedShort, luaUnsignedShort);
		//
		mapTypeArgs = new HashMap<String, String>(mapType);
		mapTypeArgs.put(idlLongLong, luaLongLongParam);
		mapTypeArgs.put(idlUnsignedLong, luaUnsignedLongParam);
		mapTypeArgs.put(idlUnsignedLongLong, luaUnsignedLongLongParam);
		mapTypeArgs.put(idlUnsignedShort, luaUnsignedShortParam);
		//
//		mapTypeArgsCmnt = new HashMap(mapTypeArgs);
		//
	}

	/**
	 * CORBA�^����Lua�^�֌^��ϊ�����(TypeDef�l��)
	 *
	 * @param strCorba CORBA�^
	 * @return Lua�^
	 */
	public String convCORBA2LuaTypeDef(String strCorba, ServiceClassParam scp) {
		String strType = scp.getTypeDef().get(strCorba).getOriginalDef();
		String result = "";
		if(strType.endsWith("[]")) {
			strType = strType.substring(0, strType.length()-2);
		}

		if( strType.equals(luaString)) {
			result = "(omniORB.tcInternal.tv_string,0)";
		} else {
			result = "omniORB.tcInternal.tv_" + strType;
		}
		return result;
	}
	/**
	 * CORBA�^����Lua�^�֌^��ϊ�����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return Lua�^
	 */
	public String convCORBA2Lua(String strCorba) {
		String result = mapType.get(strCorba);
		if( result == null ) result = strCorba;

		return result;
	}
	/**
	 * CORBA�^����Lua�^�֌^��ϊ�����(�R�����g�p)
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return Lua�^
	 */
	public String convCORBA2LuaArg(String strCorba) {
		String result = mapTypeArgs.get(strCorba);
		if( result == null ) result = strCorba;

		return result;
	}
	/**
	 * CORBA�^����Lua�^�֌^��ϊ�����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return Lua�^
	 */
	public String convCORBA2Lua4IDL(String strCorba, ServiceClassParam scp) {
		String strType = (scp.getTypeDef().get(strCorba) == null) ? null : scp
				.getTypeDef().get(strCorba).getOriginalDef();
		String result = "";
		if( strType==null) {
			if(strCorba.equals(idlString)) {
				result = "(omniORB.tcInternal.tv_string,0)";
			} else if(strCorba.equals(idlWstring)) {
				result = "(omniORB.tcInternal.tv_wstring,0)";
			} else {
				result = mapType.get(strCorba);
				if( result == null ) result = strCorba;
				result = "omniORB.tcInternal.tv_" + result;
			}
		} else {
			result = "omniORB.typeMapping[\"IDL:" + strCorba + ":1.0\"]";
		}
		return result;
	}
	/**
	 * ���\�b�h���̓p�����[�^�̌^���擾����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return ���̓p�����[�^
	 */
	public String selectInParamType(ServiceMethodParam smp, ServiceClassParam scp) {
		String result = "";
		int intHit = 0;

		for(ServiceArgumentParam arg : smp.getArguments() ) {
			if(arg.getDirection().equals(dirIn) || arg.getDirection().equals(dirInOut)) {
				result = result + convCORBA2Lua4IDL(arg.getType(),scp) + ", ";
				intHit++;
			}
		}
		if( intHit > 1 ) result = result.substring(0, result.length()-2 );
		result = "(" + result;
		return result;
	}

	/**
	 * ���\�b�h���̓p�����[�^�̖��̂��擾����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return ���̓p�����[�^
	 */
	public String selectInParamName(ServiceMethodParam smp, ServiceClassParam scp) {
		String result = "";
		int count = 0;
		for(ServiceArgumentParam arg : smp.getArguments() ) {
			if(arg.getDirection().equals(dirIn) || arg.getDirection().equals(dirInOut)) {
				if(count == 0)
				{
					result =  arg.getName();
				}
				else
				{
					result =  result + ", " + arg.getName();
				}
				count++;
			}
		}
		return result;
	}

	/**
	 * ���\�b�h�o�̓p�����[�^�̌^���擾����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return �o�̓����[�^
	 */
	public String selectOutParamType(ServiceMethodParam smp, ServiceClassParam scp) {
		String result = "";
		int intHit = 0;

		if(!smp.getIsVoid()) {
			result = result + convCORBA2Lua4IDL(smp.getType(),scp) + ", ";
			intHit++;
		}
		for(ServiceArgumentParam aug : smp.getArguments() ) {
			if(aug.getDirection().equals(dirOut) || aug.getDirection().equals(dirInOut)) {
				result = result + convCORBA2Lua4IDL(aug.getType(),scp) + ", ";
				intHit++;
			}
		}
		if( intHit > 1 ) result = result.substring(0, result.length()-2 );
		return result;
	}
	/**
	 * ���\�b�h�o�̓p�����[�^�̖��̂��擾����
	 *
	 * @param strCorba CORBA�^
	 * @param scp �T�[�r�X�N���X
	 * @return �o�̓p�����[�^
	 */
	public String selectOutParamName(ServiceMethodParam smp, ServiceClassParam scp) {
		String result = "";
		boolean blnHit = false;

		if( !smp.getType().equals(idlVoid) ) {
			result = " result";
		}
		for(ServiceArgumentParam arg : smp.getArguments() ) {
			if(arg.getDirection().equals(dirOut) || arg.getDirection().equals(dirInOut)) {
				if( result.length()>0 ) result += ",";
				result =  result + " " + arg.getName();
				blnHit = true;
			}
		}
		if( smp.getType().equals(idlVoid) && !blnHit) {
			result = " None";
		}
		return result;
	}
	/**
	 * Sequence�^�����f����
	 *
	 * @param type ���ؑΏی^
	 * @return ���،���
	 */
	public String convPortInit(String type) {
		if( this.isSequence(type) )
			return "[]";
		return "0";
	}
	/**
	 * Sequence�^�����f����
	 *
	 * @param type ���ؑΏی^
	 * @return ���،���
	 */
	private boolean isSequence(String type) {
		if( type.toLowerCase().endsWith("seq") )
			return true;
		return false;
	}
	/**
	 * �p�����[�^�̏����l���擾����
	 *
	 * @param config �Ώۃp�����[�^
	 * @return �����l
	 */
	public boolean isString(String type) {
		if( type.toLowerCase().equals(luaString) )
			return true;
		return false;
	}
	/**
	 * �p�����[�^�̏����l���擾����
	 *
	 * @param config �Ώۃp�����[�^
	 * @return �����l
	 */
	public String convDefaultVal(ConfigSetParam config) {
		String defVal = config.getDefaultVal();
		if( config.getName().startsWith("vector") ) {
			String[] eachVal = defVal.split(",");
			String result = "";
			for(int intIdx=0;intIdx<eachVal.length;intIdx++) {
				if(intIdx>0) result += ", ";
				result = result + eachVal[intIdx];
			}
			result = "[" + result + "]";
			return result;
		} else if(isString(config.getType()) ) {
			return "'" + defVal + "'";
		} else {
			return defVal;
		}
	}

	/**
	 * �f�[�^�|�[�g�������p���\�b�h����Ԃ�
	 *
	 * @param rtcType �|�[�g�̌^
	 * @return ���������\�b�h��
	 */
	public String getDataportInitMethodName(String rtcType) {

		//module�����t���Ă��Ȃ��f�[�^�^�i::���t���Ă��Ȃ��j�́A
		//�������()��t���ăf�t�H���g�R���X�g���N�^�����ɂ���
		if(!rtcType.matches(".*::.*")) return rtcType + "()";
		String methodName = "::"+rtcType;

		//module�����uRTC�v�̂Ƃ��͐e�f�[�^�^�ł���uTime�v�̃R���X�g���N�^�������ɓ��ꂽ
		//�R���X�g���N�^�������ɓ���R���X�g���N�^������ɂ��ĕԂ�
		//����ȊO��module���̏ꍇ�A()��t���������̃f�t�H���g�R���X�g���N�^��Ԃ�
//		if(rtcType.startsWith("RTC::")) {
//			methodName = methodName + "(RTC.Time(0,0)";
//		}
//		else {
//			methodName = methodName + "()";
//		}

		return methodName;
	}

	/**
	 * �f�[�^�|�[�g�ϐ��^��`�ϐ���Ԃ�
	 *
	 * @param rtcType �|�[�g�̌^
	 * @return �ϐ��^��`�ϐ�
	 */
	public String getTypeDefinition(String rtcType) {
		String methodName = rtcType.replace("::", "._d_");
		return methodName;
	}

	public String convFullName(String source) {
		if(source.contains("::")) {
			return source.replace("::", ".");

		}
		return "_GlobalIDL." + source;
	}

	public String getModuleName(String source) {
		if(source.contains("::")) {
			int index = source.lastIndexOf("::");
			return source.substring(0, index);

		}
		return "_GlobalIDL";
	}

	public String convToLower(String source) {
		return source.toLowerCase();
	}

	public String convModuleName(IdlFileParam source) {
		List<String> addedList = new ArrayList<String>();
		StringBuilder strWork;
		StringBuilder result = new StringBuilder();

		boolean existGlobal = false;
		for(ServiceClassParam target : source.getServiceClassParams() ) {
			strWork = new StringBuilder();
			if(target.getName().contains("::")) {
				int index = target.getName().lastIndexOf("::");
				strWork.append("import ");
				strWork.append(target.getName().substring(0, index));
				strWork.append(", ");
				strWork.append(target.getName().substring(0, index));
				strWork.append("__POA");
			} else {
				if(!existGlobal) {
					strWork.append("import ");
					strWork.append("_GlobalIDL, _GlobalIDL__POA");
					existGlobal = true;
				}
			}
			//
			if(addedList.contains(strWork.toString())==false) {
				result.append(strWork.toString()).append(System.getProperty("line.separator"));
				addedList.add(strWork.toString());
			}
		}
		return result.toString();
	}

	public String convModuleNameAll(List<IdlFileParam> sourceList) {
		List<String> addedList = new ArrayList<String>();
		StringBuilder strWork;
		StringBuilder result = new StringBuilder();

		boolean existGlobal = false;
		for(IdlFileParam source : sourceList) {
			for(ServiceClassParam target : source.getServiceClassParams() ) {
				strWork = new StringBuilder();
				if(target.getName().contains("::")) {
					int index = target.getName().lastIndexOf("::");
					strWork.append("import ");
					strWork.append(target.getName().substring(0, index));
					strWork.append(", ");
					strWork.append(target.getName().substring(0, index));
					strWork.append("__POA");
				} else {
					if(!existGlobal) {
						strWork.append("import ");
						strWork.append("_GlobalIDL, _GlobalIDL__POA");
						existGlobal = true;
					}
				}
				if(addedList.contains(strWork.toString())==false) {
					result.append(strWork.toString()).append(System.getProperty("line.separator"));
					addedList.add(strWork.toString());
				}
			}
		}
		return result.toString();
	}
}
