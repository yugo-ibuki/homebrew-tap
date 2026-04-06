cask "unitmux" do
  version "0.6.0"
  sha256 "bb7eb67f35cfec18f875cd7e59d01b182b2264339867d9a3b81f7e54daba8a47"

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
