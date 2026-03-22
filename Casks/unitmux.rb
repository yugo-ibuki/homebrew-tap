cask "unitmux" do
  version "0.4.1"
  sha256 "97e2be4beed1458bafce494ffc51b308729406b27a5fb7d7c4ba75c362718a63"

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
