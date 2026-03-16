#!/usr/bin/env bash
# =============================================================================
# macOS defaults settings
# =============================================================================
# read で現在値を確認してから write で書き込む。
# 項目ごとに値を調整して使う。
#
# 最後に killall Dock Finder SystemUIServer で反映。
# =============================================================================

# --- Dock ---

# Dock の位置 (default: bottom)
defaults read com.apple.dock orientation
defaults write com.apple.dock orientation -string "left"

# アイコンサイズ px (default: 48)
defaults read com.apple.dock tilesize
defaults write com.apple.dock tilesize -int 36

# 拡大エフェクト (default: 0)
defaults read com.apple.dock magnification
defaults write com.apple.dock magnification -bool false

# 拡大時サイズ (default: 64)
defaults read com.apple.dock largesize
defaults write com.apple.dock largesize -int 64

# 自動非表示 (default: 0)
defaults read com.apple.dock autohide
defaults write com.apple.dock autohide -bool true

# 非表示の遅延 秒 (default: 0.5)
defaults read com.apple.dock autohide-delay
defaults write com.apple.dock autohide-delay -float 0

# 非表示アニメーション速度 (default: 0.5)
defaults read com.apple.dock autohide-time-modifier
defaults write com.apple.dock autohide-time-modifier -float 0.5

# 最近使ったアプリ表示 (default: 1)
defaults read com.apple.dock show-recents
defaults write com.apple.dock show-recents -bool false

# 起動バウンスアニメーション (default: 1)
defaults read com.apple.dock launchanim
defaults write com.apple.dock launchanim -bool true

# 最小化エフェクト genie/scale (default: genie)
defaults read com.apple.dock mineffect
defaults write com.apple.dock mineffect -string "scale"

# Spaces の自動並べ替え (default: 1)
defaults read com.apple.dock mru-spaces
defaults write com.apple.dock mru-spaces -bool false

# 起動中インジケータ (default: 1)
defaults read com.apple.dock show-process-indicators
defaults write com.apple.dock show-process-indicators -bool true

# 起動中アプリのみ表示 (default: 0)
defaults read com.apple.dock static-only
defaults write com.apple.dock static-only -bool false

# --- Keyboard ---

# キーリピート速度 小=速い (default: 6)
defaults read NSGlobalDomain KeyRepeat
defaults write NSGlobalDomain KeyRepeat -int 2

# リピート開始遅延 小=短い (default: 25)
defaults read NSGlobalDomain InitialKeyRepeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# フルキーボードアクセス 3=全コントロール (default: 0)
defaults read NSGlobalDomain AppleKeyboardUIMode
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# 自動大文字 (default: 1)
defaults read NSGlobalDomain NSAutomaticCapitalizationEnabled
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# 自動ピリオド (default: 1)
defaults read NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# スペル自動修正 (default: 1)
defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# スマートクォート (default: 1)
defaults read NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# スマートダッシュ (default: 1)
defaults read NSGlobalDomain NSAutomaticDashSubstitutionEnabled
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# テキスト自動補完 (default: 1)
defaults read NSGlobalDomain NSAutomaticTextCompletionEnabled
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false

# 長押しで特殊文字 false=キーリピート優先 (default: 1)
defaults read NSGlobalDomain ApplePressAndHoldEnabled
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# fn キーの動作 0:なし/1:入力ソース/2:絵文字 (default: 2)
defaults read com.apple.HIToolbox AppleFnUsageType
defaults write com.apple.HIToolbox AppleFnUsageType -int 1

# --- Trackpad ---

# タップでクリック (default: 0)
defaults read com.apple.AppleMultitouchTrackpad Clicking
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# 3本指ドラッグ (default: 0)
defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# 2本指で右クリック (default: 1)
defaults read com.apple.AppleMultitouchTrackpad TrackpadRightClick
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# タップでクリック Bluetooth (default: 0)
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# 3本指ドラッグ Bluetooth (default: 0)
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# トラッキングスピード (default: 1)
defaults read NSGlobalDomain com.apple.trackpad.scaling
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3

# ナチュラルスクロール (default: 1)
defaults read NSGlobalDomain com.apple.swipescrolldirection
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# タップ動作 currentHost (default: 0)
defaults -currentHost read NSGlobalDomain com.apple.mouse.tapBehavior
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Finder ---

# 隠しファイル表示 (default: 0)
defaults read com.apple.finder AppleShowAllFiles
defaults write com.apple.finder AppleShowAllFiles -bool true

# 拡張子を常に表示 (default: 0)
defaults read NSGlobalDomain AppleShowAllExtensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# パスバー (default: 0)
defaults read com.apple.finder ShowPathbar
defaults write com.apple.finder ShowPathbar -bool true

# ステータスバー (default: 0)
defaults read com.apple.finder ShowStatusBar
defaults write com.apple.finder ShowStatusBar -bool true

# デフォルト表示形式 icnv:アイコン/Nlsv:リスト/clmv:カラム/Flwv:ギャラリー (default: icnv)
defaults read com.apple.finder FXPreferredViewStyle
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# デスクトップにHD表示 (default: 0)
defaults read com.apple.finder ShowHardDrivesOnDesktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# 拡張子変更の警告 (default: 1)
defaults read com.apple.finder FXEnableExtensionChangeWarning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# タイトルバーにフルパス (default: 0)
defaults read com.apple.finder _FXShowPosixPathInTitle
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# フォルダを先頭に表示 (default: 0)
defaults read com.apple.finder _FXSortFoldersFirst
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# .DS_Store をネットワークボリュームに作らない (default: 0)
defaults read com.apple.desktopservices DSDontWriteNetworkStores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# .DS_Store を USB に作らない (default: 0)
defaults read com.apple.desktopservices DSDontWriteUSBStores
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Screenshot ---

# ファイル形式 png/jpg/pdf/tiff (default: png)
defaults read com.apple.screencapture type
defaults write com.apple.screencapture type -string "png"

# 影の無効化 (default: 0)
defaults read com.apple.screencapture disable-shadow
defaults write com.apple.screencapture disable-shadow -bool true

# 撮影後のサムネイル (default: 1)
defaults read com.apple.screencapture show-thumbnail
defaults write com.apple.screencapture show-thumbnail -bool false

# 保存先 (default: ~/Desktop)
defaults read com.apple.screencapture location
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# --- System ---

# スクロールバー表示 Automatic/WhenScrolling/Always (default: Automatic)
defaults read NSGlobalDomain AppleShowScrollBars
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# スクロールアニメーション (default: 1)
defaults read NSGlobalDomain NSScrollAnimationEnabled
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool true

# ウィンドウリサイズ速度 (default: 0.2)
defaults read NSGlobalDomain NSWindowResizeTime
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# 印刷ダイアログ拡張 (default: 0)
defaults read NSGlobalDomain PMPrintingExpandedStateForPrint
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# 印刷ダイアログ拡張2 (default: 0)
defaults read NSGlobalDomain PMPrintingExpandedStateForPrint2
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# 新規をiCloudに保存 (default: 1)
defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# クラッシュレポート形式 crashreport/none/server (default: crashreport)
defaults read com.apple.CrashReporter DialogType
defaults write com.apple.CrashReporter DialogType -string "none"

# アップデート自動チェック (default: 1)
defaults read com.apple.SoftwareUpdate AutomaticCheckEnabled
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# ダークモード (default: 未設定=Light)
defaults read NSGlobalDomain AppleInterfaceStyle
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# アクセントカラー -1:Graphite/0:Red/1:Orange/2:Yellow/3:Green/5:Purple/6:Pink (default: 未設定=Blue)
defaults read NSGlobalDomain AppleAccentColor
defaults write NSGlobalDomain AppleAccentColor -int -1

# --- Hot Corners ---
# 0:無効 2:Mission Control 4:デスクトップ 5:スクリーンセーバー開始
# 6:SS無効 10:スリープ 11:Launchpad 12:通知センター 13:ロック 14:クイックメモ

# 左上 (default: 0)
defaults read com.apple.dock wvous-tl-corner
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# 右上 (default: 0)
defaults read com.apple.dock wvous-tr-corner
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# 左下 (default: 0)
defaults read com.apple.dock wvous-bl-corner
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# 右下 (default: 0)
defaults read com.apple.dock wvous-br-corner
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# --- Safari ---

# 開発メニュー (default: 0)
defaults read com.apple.Safari IncludeDevelopMenu
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# フルURL表示 (default: 0)
defaults read com.apple.Safari ShowFullURLInSmartSearchField
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# パスワード自動入力 (default: 1)
defaults read com.apple.Safari AutoFillPasswords
defaults write com.apple.Safari AutoFillPasswords -bool true

# --- Apps ---

# TextEdit: プレーンテキストをデフォルトに (default: 1)
defaults read com.apple.TextEdit RichText
defaults write com.apple.TextEdit RichText -bool false

# Mail: コピーに名前を含む (default: 1)
defaults read com.apple.mail AddressesIncludeNameOnPasteboard
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# --- Restart ---

killall Dock Finder SystemUIServer 2>/dev/null || true
