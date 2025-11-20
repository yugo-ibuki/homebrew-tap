class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "4de476f9b58f4a9f22196b2d0963d710315eb33096f9d2509cce275f0b14313e"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"dot-claude-sync", "--version"
  end
end
