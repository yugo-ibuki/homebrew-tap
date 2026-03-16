cask "huge-mouse" do
  version "0.1.6"
  sha256 "2fbf0656380182ca7ff5def2eab5209564e86d2e993baef77d2682be5c3ce250"

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
