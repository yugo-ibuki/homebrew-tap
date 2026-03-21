cask "unitmux" do
  version "0.4.0"
  sha256 "a2bbc0d38f613f019aa078212055f57ee713e891abe320de826d5ec551e506eb"

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
