cask "unitmux" do
  version "0.5.1"
  sha256 "75461116acce7c0b942f55a446d8a5f64f1543a61a44fe6e5cbedf58846de3f4"

  url "https://github.com/yugo-ibuki/unitmux/releases/download/v#{version}/unitmux-#{version}.dmg"
  name "Unitmux"
  desc "Unifies your AI coding sessions into a single floating interface"
  homepage "https://github.com/yugo-ibuki/unitmux"

  app "Unitmux.app"

  zap trash: [
    "~/Library/Application Support/unitmux",
    "~/Library/Preferences/com.yugo-ibuki.unitmux.plist",
    "~/Library/Saved Application State/com.yugo-ibuki.unitmux.savedState",
  ]
end
