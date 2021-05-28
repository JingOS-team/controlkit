#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import sys

#git clone ssh://wangqiang@172.16.4.10:29418/JingOS/controlkit
#git clone ssh://wangqiang@172.16.4.10:29418/JingApps/calendar
CONFIG_SSH_ADDRESS = "ssh://wangqiang@172.16.4.10:29418/"
CONFIG_SOURCE_CODE_PATH = "source"

GLOBAL_CONFIG_INFO = [
    {
        "name": "kwin",   ### kwin
        "folder": "kwin",
        "second_folder": "",
        "git_path": "kwin",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
            "sudo apt install libmediainfo-dev libmpv-dev libexiv2-dev qml-module-qt-labs-platform qml-module-qtwebchannel wayland-protocols",
            "sudo apt build-dep plasma-phone-components plasma-workspace plasma-angelfish vvave calindori kwin"
        ]
    },
    {
        "name": "plasma-workspace",   ###桌面 
        "folder": "plasma-workspace/",
        "second_folder": "",
        "git_path": "JingApps/plasma-workspace",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "plasma-phone-components",   ### 桌面组件
        "folder": "plasma-phone-components/",
        "second_folder": "",
        "git_path": "JingApps/plasma-phone-components",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "repository",   ### assert
        "folder": "repository",
        "second_folder": "",
        "git_path": "JingApps/repository",
        "git_branch": "dev",
        "cmake_arg": "-DBUILD_EXAMPLES=ON -DCMAKE_INSTALL_PREFIX=/usr",
        "command_plus": [
        ]
    },

    {
        "name": "controlkit",   ### 公共控件
        "folder": "controlkit/",
        "second_folder": "",
        "git_path": "JingOS/controlkit",
        "git_branch": "dev",
        "cmake_arg": "-DBUILD_EXAMPLES=ON -DCMAKE_INSTALL_PREFIX=/usr",
        "command_plus": [
        ]
    },
    {
        "name": "calendar",  ### 日历
        "folder":"calendar",
        "second_folder": "",
        "git_path": "JingApps/calendar",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus":[
        ]
    },
    {
        "name": "recorder", ### 录音机
        "folder": "recorder",
        "second_folder": "",
        "git_path": "JingApps/recorder",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "clock", ### 时钟
        "folder": "clock",
        "second_folder": "",
        "git_path": "JingApps/clock",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "mediaplayer", ### 媒体播放器
        "folder": "mediaplayer",
        "second_folder": "",
        "git_path": "JingApps/mediaplayer",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "calculator",  ### 计算器
        "folder": "calculator",
        "second_folder": "",
        "git_path": "JingApps/calculator",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "browser",  ### 游览器
        "folder": "browser",
        "second_folder": "",
        "git_path": "JingApps/browser",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "photo",  ### 照片
        "folder": "photo",
        "second_folder": "",
        "git_path": "JingApps/photo",
        "git_branch": "dev",
        "cmake_arg": "-DCMAKE_INSTALL_PREFIX=/usr",
        "command_plus": [
        ]
    },
    {
        "name": "videoplayer",  ### 视频播插件
        "folder": "videoplayer",
        "second_folder": "/haruna-master/",
        "git_path": "JingApps/videoplayer",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
    {
        "name": "konsole",  ### Terminal
        "folder": "konsole",
        "second_folder": "",
        "git_path": "JingApps/konsole",
        "git_branch": "dev",
        "cmake_arg": "",
        "command_plus": [
        ]
    },
]


class InstallApp:
    def __init__(self):
        self.git_address= CONFIG_SSH_ADDRESS
        self.work_path = os.getcwd()
        self.sourc_code = self.work_path + '/' + CONFIG_SOURCE_CODE_PATH
        if not os.path.exists(self.sourc_code):
            os.mkdir(self.sourc_code)

    def initEnv(self):
        for var in GLOBAL_CONFIG_INFO:
            print "var:" + str(var)
            os.chdir(self.sourc_code)
            command = "git clone " + CONFIG_SSH_ADDRESS + var['git_path']
            print "initEnv  command:" + command
            os.system(command)
            for cm in var["command_plus"]:
                os.system(cm)

    def updateCode(self):
        for var  in GLOBAL_CONFIG_INFO:
            print "var:" + str(var)
            os.chdir(self.sourc_code + '/' + var['name'])
            command = "git checkout " + var['git_branch']
            os.system(command)
            command = "git pull"
            os.system(command)
            os.chdir(self.sourc_code)

    def build_install(self):
        for var  in GLOBAL_CONFIG_INFO:
            print "var:" + str(var)
            current_path = self.sourc_code + '/' + var['folder']
            os.chdir(current_path)
            build_path = current_path +  var['second_folder'] + "/build"
            if not os.path.exists(build_path):
                os.mkdir(build_path)
            os.chdir(build_path)
            command = "cmake ../ " + var['cmake_arg']
            os.system(command)
            command = "make -j8"
            os.system(command)
            command = "sudo make install"
            os.system(command)

    def exec_command(self):
        for var in GLOBAL_CONFIG_INFO:
            print "var.command_plus:" + var['command_plus']

if __name__ == '__main__':
    print(len(sys.argv))
    if len(sys.argv) < 2:
        sys.exit("please input pararm: [init|make]")
    param = sys.argv[1]

    app  = InstallApp()

    if param=="init":
        app.initEnv()
    elif param=="make":
        app.updateCode()
        app.build_install()




