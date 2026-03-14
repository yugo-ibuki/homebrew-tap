cask "huge-mouse" do
  version "0.1.0"
  sha256 "d1c4b2fde7afb9a372e0ba42d4ed8caab31a703b1bb0c91b2b8cdf1cd3308b72"

  url "https://github.com/yugo-ibuki/huge-mouse/releases/download/v#{version}/huge-mouse-#{version}.dmg"
  name "Huge Mouse"
  desc "Send input to tmux sessions from a floating desktop app"
  homepage "https://github.com/yugo-ibuki/huge-mouse"

  app "Huge Mouse.app"

  zap trash: [
    "~/Library/Application Support/huge-mouse",
    "~/Library/Preferences/com.yugo-ibuki.huge-mouse.plist",
    "~/Library/Saved Application State/com.yugo-ibuki.huge-mouse.savedState"
  ]
end
