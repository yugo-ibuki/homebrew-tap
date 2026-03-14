cask "huge-mouse" do
  version "0.1.2"
  sha256 "fdf0bfb3c73da3ab2588a593026a6a6d8e545a09dd7e5a2a4f05a4acceddc6ee"

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
