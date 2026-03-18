cask "huge-mouse" do
  version "0.2.3"
  sha256 "c4185fcbcb55d75fc8a5d97e809b2848aac72b5d34363e3cc27fad938b370407"

  url "https://github.com/yugo-ibuki/huge-mouse/releases/download/v#{version}/huge-mouse-#{version}.dmg"
  name "Huge Mouse"
  desc "Send input to tmux sessions from a floating desktop app"
  homepage "https://github.com/yugo-ibuki/huge-mouse"

  app "Huge Mouse.app"

  zap trash: [
    "~/Library/Application Support/huge-mouse",
    "~/Library/Preferences/com.yugo-ibuki.huge-mouse.plist",
    "~/Library/Saved Application State/com.yugo-ibuki.huge-mouse.savedState",
  ]
end
