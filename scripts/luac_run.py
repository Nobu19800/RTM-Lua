import os
import subprocess


def find_all_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            #print(root, file)
            name, ext = os.path.splitext(file)
            #print name
            if name != "Manager" and ext == ".lua":
                path = os.path.join(root, file)
                subprocess.call(["luac","-o",path,path])
                

find_all_files('./lua')