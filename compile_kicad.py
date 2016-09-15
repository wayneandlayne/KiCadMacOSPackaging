#!/usr/bin/env python
import os
import subprocess
import shutil

NUM_OF_CORES = 6


def get_git_shortsha():
    revno = subprocess.check_output(["git", "rev-parse", '--short', 'HEAD'], cwd="kicad")
    return revno


def which(program_name):
    return subprocess.check_output(["which", program_name]).strip()


CMAKE_SETTINGS = ["-DDEFAULT_INSTALL_PATH=/Library/Application Support/kicad",
                  "-DCMAKE_C_COMPILER=" + which("clang"),
                  "-DCMAKE_CXX_COMPILER=" + which("clang++"),
                  "-DCMAKE_OSX_SYSROOT=" + os.path.join(os.getcwd(), "MacOSX10.9.sdk"),
                  "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.9",
                  "-DwxWidgets_CONFIG_EXECUTABLE=../wx/wx-bin/bin/wx-config",
                  "-DKICAD_SCRIPTING=ON",
                  "-DKICAD_SCRIPTING_MODULES=ON",
                  "-DKICAD_SCRIPTING_WXPYTHON=ON",
                  "-DPYTHON_EXECUTABLE=" + which("python"),
                  "-DPYTHON_SITE_PACKAGE_PATH=" + os.path.realpath("wx/wx-bin/lib/python2.7/site-packages"),
                  "-DCMAKE_INSTALL_PREFIX=../bin",
                  "-DCMAKE_BUILD_TYPE=Release"]


def run_cmake():
    shutil.rmtree("build", ignore_errors=True)
    os.makedirs("build")
    os.chdir("build")
    cmd = ["cmake"]
    cmd.extend(CMAKE_SETTINGS)
    cmd.extend(["../kicad"])

    print cmd

    subprocess.call(cmd)
    os.chdir("..")


def build_kicad():
    os.chdir("build")
    cmd = ["make", "-j" + str(NUM_OF_CORES)]
    subprocess.check_call(cmd)
    os.chdir("..")

def compile_kicad():
    shortsha = get_git_shortsha()
    print shortsha
    run_cmake()
    build_kicad()

    with open("notes/cmake_settings", "w") as cmake_settings_log:
        cmake_settings_log.write("\n".join(CMAKE_SETTINGS))
    with open("notes/build_revno", "w") as build_revno_log:
        build_revno_log.write(shortsha)


if __name__ == "__main__":
    compile_kicad()
