#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <iostream>
//#include <locale>
//#include <codecvt>
#include <tchar.h>



inline int run_python(const char *file_name, int argc, char *argv[])
{
	char Path[MAX_PATH + 1];

	if (0 != GetModuleFileName(NULL, Path, MAX_PATH)) {

		char drive[MAX_PATH + 1];
		char dir[MAX_PATH + 1];
		char fname[MAX_PATH + 1];
		char ext[MAX_PATH + 1];

		_splitpath(Path, drive, dir, fname, ext);


		std::string cmd = "python ";
		cmd = cmd + "\"";
		cmd = cmd + drive;

		cmd = cmd + dir;
		cmd = cmd + file_name;
		cmd = cmd + "\"";
		cmd = cmd + " ";

		for (int i = 1; i < argc; i++)
		{
			cmd = cmd + "\"";
			cmd = cmd + argv[i];
			cmd = cmd + "\"";
			cmd = cmd + " ";

		}

		//std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> cv;
		//std::cout << cmd.c_str() << std::endl;

		//std::wstring wcommand = cv.from_bytes(cmd);
		//LPTSTR lpcommand = new TCHAR[wcommand.size() + 1];
		/*LPTSTR lpcommand = new TCHAR[cmd.size() + 1];
		_tcscpy(lpcommand, cmd.c_str());

		STARTUPINFO si;
		ZeroMemory(&si, sizeof(si));
		si.cb = sizeof(si);
		PROCESS_INFORMATION pi;
		ZeroMemory(&pi, sizeof(pi));

		if (!CreateProcess(NULL, lpcommand, NULL, NULL, FALSE, 0,
		NULL, NULL, &si, &pi))
		{
		delete lpcommand;
		return -1;
		}
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
		delete lpcommand;
		*/
		if (system(cmd.c_str()) == -1)
		{
			return -1;
		}

		return 0;



	}
	else
	{
		return -1;
	}

}