class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "c74891aa81556980633cb3433cf74f5e1d1ce78276fa4e4fb76ab1d2b2df04da"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"dot-claude-sync", "--version"
  end
end
