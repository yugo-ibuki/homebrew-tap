class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "ef86baed0929da1ce8c460ed206bb84821a332c9bfe33a1ff4f2e9765996a898"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"dot-claude-sync", "--version"
  end
end
