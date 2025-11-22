class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "54f52acdc6ee126e2176d5e3055f17ac4104939a2ddecb2e268220566be9f60f"
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
