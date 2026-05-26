cask "unitmux" do
  version "0.7.0"
  sha256 "19ef5cf3f632fc9b0007ef41a02d098b1742d4ab8431e7cacdb7099fd4ea78cf"

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
