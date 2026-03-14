cask "huge-mouse" do
  version "0.0.1"
  sha256 "0dcb1efe4c1304a5d76127a56c07cb625e08d3427ae7f7ee9e2f11995040df47"

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
