class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "187207aafa9ae23218d5398e48614110cd5d0c51af4dc8c6d16336864273d3eb"
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
