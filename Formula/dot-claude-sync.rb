class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "c41f03cd0177345125cbdb683fd1d8d4f54923ac268690255fc076320956f406"
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
