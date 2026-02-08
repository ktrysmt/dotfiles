import sys
import os
import datetime
import fnmatch
import time

import pyauto
from keyhac import *


def configure(keymap):

    # Common func
    def to_local_path(s):
        if os.path.exists(s):
            return s
        return None

    def delay(sec=0.05):
        time.sleep(sec)

    def get_username():
        return os.environ['USERNAME']

    def execute_path(s, arg=None):
        if s:
            if s.startswith("http") or to_local_path(s):
                keymap.ShellExecuteCommand(None, s, arg, None)()

    keymap.editor = r"C:\Program Files\Notepad++\notepad++.exe"
    keymap.setFont("Cica", 14)
    keymap.setTheme("black")

    keymap.replaceKey(29, "Back")
    keymap.replaceKey(28, "Return")
    keymap.replaceKey(242, 244)

    keymap.clipboard_history.maxnum = 0
    keymap.clipboard_history.enableHook(False)

    # Global keymap which affects any windows
    keymap_global = keymap.defineWindowKeymap()

    keymap_global["LCtrl-OpenBracket"] = "Esc"  # ESC

    keymap_global["LCtrl-H"] = "Up"  # カーソル上
    keymap_global["LCtrl-Colon"] = "Down"  # カーソル下 
    keymap_global["LCtrl-L"] = "Right"  # カーソル右 
    keymap_global["LCtrl-K"] = "Left"  # カーソル左 
    keymap_global["LCtrl-J"] = "Home"  # 行の先頭
    keymap_global["LCtrl-Semicolon"] = "End"  # 行の末尾

    keymap_global["LCtrl-Shift-H"] = "Shift-Up"  # カーソル上
    keymap_global["LCtrl-Shift-Colon"] = "Shift-Down"  # カーソル下
    keymap_global["LCtrl-Shift-L"] = "Shift-Right"  # カーソル右
    keymap_global["LCtrl-Shift-K"] = "Shift-Left"  # カーソル左
    keymap_global["LCtrl-Shift-J"] = "Shift-Home"  # 行の先頭
    keymap_global["LCtrl-Shift-Semicolon"] = "Shift-End"  # 行の末尾

    keymap_global["LCtrl-Up"] = "LWin-Tab"
    keymap_global["LCtrl-Left"] = "LWin-LCtrl-Left"
    keymap_global["LCtrl-Right"] = "LWin-LCtrl-Right"
    keymap_global["LCtrl-Alt-R"] = keymap.command_ReloadConfig

    # keymap_global["LAlt-G"] = "LWin-1"  # WindowsTerminal.exe

    # Terminal
    keymap_wez = keymap.defineWindowKeymap(
        exe_name="WindowsTerminal.exe")
    keymap_wez["LCtrl-H"] = ["LCtrl-H"]
    keymap_wez["LCtrl-Colon"] = ["LCtrl-Colon"]
    keymap_wez["LCtrl-L"] = ["LCtrl-L"]
    keymap_wez["LCtrl-K"] = ["LCtrl-K"]
    keymap_wez["LCtrl-J"] = ["LCtrl-J"]
    keymap_wez["LCtrl-Semicolon"] = ["LCtrl-Semicolon"]

    keymap_wez["LCtrl-Shift-H"] = ["LCtrl-Shift-H"]
    keymap_wez["LCtrl-Shift-Colon"] = ["LCtrl-Shift-Colon"]
    keymap_wez["LCtrl-Shift-L"] = ["LCtrl-Shift-L"]
    keymap_wez["LCtrl-Shift-K"] = ["LCtrl-Shift-K"]
    keymap_wez["LCtrl-Shift-J"] = ["LCtrl-Shift-J"]
    keymap_wez["LCtrl-Shift-Semicolon"] = ["LCtrl-Shift-Semicolon"]

    def wezterm_ctrl_c():
        keymap.getWindow().setImeStatus(0)
        keymap.InputKeyCommand("LCtrl-C")()
    keymap_wez["LCtrl-C"] = wezterm_ctrl_c

    def wezterm_ctrl_space():
        keymap.getWindow().setImeStatus(0)
        keymap.InputKeyCommand("LCtrl-Space")()
    keymap_wez["LCtrl-Space"] = wezterm_ctrl_space

    def wezterm_ctrl_s():
        keymap.getWindow().setImeStatus(0)
        keymap.InputKeyCommand("LCtrl-S")()
    keymap_wez["LCtrl-S"] = wezterm_ctrl_s

    def wezterm_ctrl_w():
        keymap.getWindow().setImeStatus(0)
        keymap.InputKeyCommand("LCtrl-W")()
    keymap_wez["LCtrl-W"] = wezterm_ctrl_w

    # Global hot key
    # https://zenn.dev/awtnb/books/adf6c5162a9f08/viewer/1728cd
    # ウィンドウを探す
    def find_window(exe_name, class_name=None, text=""):
        found = [None]

        def _callback(wnd, arg):
            if not wnd.isVisible():
                return True
            if not fnmatch.fnmatch(wnd.getProcessName(), exe_name):
                return True
            if class_name and not fnmatch.fnmatch(wnd.getClassName(), class_name):
                return True
            found[0] = wnd.getLastActivePopup()
            return False
#            _found = pyauto.Window.find(class_name, text)
        pyauto.Window.enum(_callback, None)
        return found[0]

    def activate_window(wnd):  # 最大10回アクティブ化にトライする
        if wnd.isMinimized():
            wnd.restore()
        trial = 0
        while trial < 10:
            trial += 1
            try:
                wnd.setForeground()
                if pyauto.Window.getForeground() == wnd:
                    wnd.setForeground(True)
                    return True
            except:
                return False
        return False

    def pseudo_cuteExec(exe_name, class_name, exe_path, text):  # クロージャ生成
        def _executer():
            found_wnd = find_window(exe_name, class_name, text)
            if found_wnd == None:
                shellExecute(None, exe_path, "", "")
            else:
                if found_wnd != keymap.getWindow():
                    if activate_window(found_wnd):
                        return None
        return _executer

    username = get_username()  # キー入力でウィンドウのアクティブ化
    for key, params in {
        "LAlt-A": (
            "brave.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe" % username,
            "",
        ),
        "LAlt-O": (
            "Obsidian.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Obsidian\Obsidian.exe" % username,
            "",
        ),
        "LAlt-E": (
            "Code.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Microsoft VS Code\Code.exe" % username,
            "",
        ),
        "LAlt-G": (
            "WindowsTerminal.exe",
            "CASCADIA_HOSTING_WINDOW_CLASS",
            r"%windir%\system32\cmd.exe",
            "Terminal",
        ),
    }.items():
        keymap_global[key] = pseudo_cuteExec(*params)

    # Window management
    # LAlt-Up/Down/Left/Right/Enter/Shift-Left/Shift-Right
    def window_maximize():
        keymap.getTopLevelWindow().maximize()
        return

    def window_snap(snap="left", shift=False):
        wnd = keymap.getTopLevelWindow()
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        bit = 15
        thin = 5
        if shift:
            center = round((mntr_right - mntr_left) / 4)
        else:
            center = round((mntr_right - mntr_left) / 2)
        if snap == "right":
            to_rect = (center - bit, mntr_top, mntr_right + thin, mntr_bottom + thin)
        else:
            to_rect = (mntr_left - thin, mntr_top, center, mntr_bottom + thin)
        set_wnd_rect(to_rect)

    def window_left():
        window_snap("left")
        return

    def window_right():
        window_snap("right")
        return

    def window_shift_left():
        window_snap("left", True)
        return

    def window_shift_right():
        window_snap("right", True)
        return

    def window_centerize():
        wnd = keymap.getTopLevelWindow()
        if wnd.isMaximized():
            return None
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        width = wnd_right - wnd_left
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        center = (mntr_right - mntr_left) / 2
        lx = int(center - width / 2)
        to_rect = (lx, mntr_top, lx + width, mntr_bottom)
        set_wnd_rect(to_rect)

    def get_monitor_areas():
        monitors = pyauto.Window.getMonitorInfo()
        main_monitor_first = sorted(monitors, key=lambda x: x[2], reverse=True)
        non_taskbar_areas = list(map(lambda x: x[1], main_monitor_first))
        return non_taskbar_areas

    def set_wnd_rect(rect):
        wnd = keymap.getTopLevelWindow()
        if list(wnd.getRect()) == rect:
            wnd.maximize()
        else:
            if wnd.isMaximized():
                wnd.restore()
                delay()
            wnd.setRect(rect)
    keymap_global["LAlt-Up"] = window_maximize
    keymap_global["LAlt-Down"] = "LWin-Down"
    keymap_global["LAlt-Left"] = window_left
    keymap_global["LAlt-Right"] = window_right
    keymap_global["LAlt-Enter"] = window_centerize
    keymap_global["LAlt-Shift-Left"] = window_shift_left
    keymap_global["LAlt-Shift-Right"] = window_shift_right        trial = 0
       while trial < 10:
            trial += 1
            try:
                wnd.setForeground()
                if pyauto.Window.getForeground() == wnd:
                    wnd.setForeground(True)
                    return True
            except:
                return False
        return False

    def pseudo_cuteExec(exe_name, class_name, exe_path, text):  # クロージャ生成
        def _executer():
            found_wnd = find_window(exe_name, class_name, text)
            if found_wnd == None:
                shellExecute(None, exe_path, "", "")
            else:
                if found_wnd != keymap.getWindow():
                    if activate_window(found_wnd):
                        return None
        return _executer

    username = get_username()  # キー入力でウィンドウのアクティブ化
    for key, params in {
        "LAlt-A": (
            "brave.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe" % username,
            "",
        ),
        "LAlt-O": (
            "Obsidian.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Obsidian\Obsidian.exe" % username,
            "",
        ),
        "LAlt-E": (
            "Code.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Microsoft VS Code\Code.exe" % username,
            "",
        ),
        "LAlt-G": (
            "WindowsTerminal.exe",
            "CASCADIA_HOSTING_WINDOW_CLASS",
            r"%windir%\system32\cmd.exe",
            "Terminal",
        ),
    }.items():
        keymap_global[key] = pseudo_cuteExec(*params)

    # Window management
    # LAlt-Up/Down/Left/Right/Enter/Shift-Left/Shift-Right
    def window_maximize():
        keymap.getTopLevelWindow().maximize()
        return

    def window_snap(snap="left", shift=False):
        wnd = keymap.getTopLevelWindow()
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        bit = 15
        thin = 5
        if shift:
            center = round((mntr_right - mntr_left) / 4)
        else:
            center = round((mntr_right - mntr_left) / 2)
        if snap == "right":
            to_rect = (center - bit, mntr_top, mntr_right + thin, mntr_bottom + thin)
        else:
            to_rect = (mntr_left - thin, mntr_top, center, mntr_bottom + thin)
        set_wnd_rect(to_rect)

    def window_left():
        window_snap("left")
        return

    def window_right():
        window_snap("right")
        return

    def window_shift_left():
        window_snap("left", True)
        return

    def window_shift_right():
        window_snap("right", True)
        return

    def window_centerize():
        wnd = keymap.getTopLevelWindow()
        if wnd.isMaximized():
            return None
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        width = wnd_right - wnd_left
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        center = (mntr_right - mntr_left) / 2
        lx = int(center - width / 2)
        to_rect = (lx, mntr_top, lx + width, mntr_bottom)
        set_wnd_rect(to_rect)

    def get_monitor_areas():
        monitors = pyauto.Window.getMonitorInfo()
        main_monitor_first = sorted(monitors, key=lambda x: x[2], reverse=True)
        non_taskbar_areas = list(map(lambda x: x[1], main_monitor_first))
        return non_taskbar_areas

    def set_wnd_rect(rect):
        wnd = keymap.getTopLevelWindow()
        if list(wnd.getRect()) == rect:
            wnd.maximize()
        else:
            if wnd.isMaximized():
                wnd.restore()
                delay()
            wnd.setRect(rect)
    keymap_global["LAlt-Up"] = window_maximize
    keymap_global["LAlt-Down"] = "LWin-Down"
    keymap_global["LAlt-Left"] = window_left
    keymap_global["LAlt-Right"] = window_right
    keymap_global["LAlt-Enter"] = window_centerize
    keymap_global["LAlt-Shift-Left"] = window_shift_left
    keymap_global["LAlt-Shift-Right"] = window_shift_right
       while trial < 10:
            trial += 1
            try:
                wnd.setForeground()
                if pyauto.Window.getForeground() == wnd:
                    wnd.setForeground(True)
                    return True
            except:
                return False
        return False

    def pseudo_cuteExec(exe_name, class_name, exe_path, text):  # クロージャ生成
        def _executer():
            found_wnd = find_window(exe_name, class_name, text)
            if found_wnd == None:
                shellExecute(None, exe_path, "", "")
            else:
                if found_wnd != keymap.getWindow():
                    if activate_window(found_wnd):
                        return None
        return _executer

    username = get_username()  # キー入力でウィンドウのアクティブ化
    for key, params in {
        "LAlt-A": (
            "brave.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe" % username,
            "",
        ),
        "LAlt-O": (
            "Obsidian.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Obsidian\Obsidian.exe" % username,
            "",
        ),
        "LAlt-E": (
            "Code.exe",
            "Chrome_WidgetWin_1",
            r"C:\Users\%s\AppData\Local\Programs\Microsoft VS Code\Code.exe" % username,
            "",
        ),
        "LAlt-G": (
            "WindowsTerminal.exe",
            "CASCADIA_HOSTING_WINDOW_CLASS",
            r"%windir%\system32\cmd.exe",
            "Terminal",
        ),
    }.items():
        keymap_global[key] = pseudo_cuteExec(*params)

    # Window management
    # LAlt-Up/Down/Left/Right/Enter/Shift-Left/Shift-Right
    def window_maximize():
        keymap.getTopLevelWindow().maximize()
        return

    def window_snap(snap="left", shift=False):
        wnd = keymap.getTopLevelWindow()
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        bit = 15
        thin = 5
        if shift:
            center = round((mntr_right - mntr_left) / 4)
        else:
            center = round((mntr_right - mntr_left) / 2)
        if snap == "right":
            to_rect = (center - bit, mntr_top, mntr_right + thin, mntr_bottom + thin)
        else:
            to_rect = (mntr_left - thin, mntr_top, center, mntr_bottom + thin)
        set_wnd_rect(to_rect)

    def window_left():
        window_snap("left")
        return

    def window_right():
        window_snap("right")
        return

    def window_shift_left():
        window_snap("left", True)
        return

    def window_shift_right():
        window_snap("right", True)
        return

    def window_centerize():
        wnd = keymap.getTopLevelWindow()
        if wnd.isMaximized():
            return None
        wnd_left, wnd_top, wnd_right, wnd_bottom = wnd.getRect()
        width = wnd_right - wnd_left
        mntr_left, mntr_top, mntr_right, mntr_bottom = get_monitor_areas()[0]
        center = (mntr_right - mntr_left) / 2
        lx = int(center - width / 2)
        to_rect = (lx, mntr_top, lx + width, mntr_bottom)
        set_wnd_rect(to_rect)

    def get_monitor_areas():
        monitors = pyauto.Window.getMonitorInfo()
        main_monitor_first = sorted(monitors, key=lambda x: x[2], reverse=True)
        non_taskbar_areas = list(map(lambda x: x[1], main_monitor_first))
        return non_taskbar_areas

    def set_wnd_rect(rect):
        wnd = keymap.getTopLevelWindow()
        if list(wnd.getRect()) == rect:
            wnd.maximize()
        else:
            if wnd.isMaximized():
                wnd.restore()
                delay()
            wnd.setRect(rect)
    keymap_global["LAlt-Up"] = window_maximize
    keymap_global["LAlt-Down"] = "LWin-Down"
    keymap_global["LAlt-Left"] = window_left
    keymap_global["LAlt-Right"] = window_right
    keymap_global["LAlt-Enter"] = window_centerize
    keymap_global["LAlt-Shift-Left"] = window_shift_left
    keymap_global["LAlt-Shift-Right"] = window_shift_right
