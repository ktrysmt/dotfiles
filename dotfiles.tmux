# prefix
unbind C-b
set -g prefix C-a
 
# 256色ターミナル
set -g default-terminal screen-256color
 
# mouse
set -g mode-mouse on
set -g mouse-resize-pane on
set -g mouse-select-pane on
set -g mouse-select-window on
 
# UTF8 Support
setw -g utf8 on
# コピーモードのキーバインドをviライクにする
setw -g mode-keys vi
# ウィンドウ名が実行中のコマンド名になるのを止める
setw -g automatic-rename off
# ウィンドウの開始番号を1にする
set -g base-index 1
# ペインの開始番号を1にする
set -g pane-base-index 1
 
# status
set -g status-fg white
set -g status-bg colour235
 
set -g status-left '#[fg=green,bold][#20(whoami)@#H]#[default]'
set -g status-right '#[fg=white][%Y/%m/%d(%a)%H:%M]#[default]'
set -g status-right-bg black
 
# window-status-current
setw -g window-status-current-fg black
setw -g window-status-current-bg white
 
# pane-active-border
set -g pane-active-border-fg white
set -g pane-active-border-bg black

# scroll
set-window-option -g mode-mouse on
set -g terminal-overrides 'xterm*:smcup@:rmcup@'
set-option -g history-limit 100000

