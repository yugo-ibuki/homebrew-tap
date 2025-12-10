class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "673d66be4896d731446bd821b19f9b871d2bfe3cf0a3638f3d0bfe69bbc0ee37"
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
