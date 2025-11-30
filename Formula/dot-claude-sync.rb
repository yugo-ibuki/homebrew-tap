class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "169d4ed714d2b9459ffb7659b6953f827fa8d01d1b85814054151630ebbf9a92"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
    system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/"dcs"), "./cmd/dcs"
  end

  test do
    system bin/"dot-claude-sync", "--version"
  end
end
