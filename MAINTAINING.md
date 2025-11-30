# Homebrew Tap メンテナンスガイド

## 📚 目次

- [リリース手順](#リリース手順)
- [新しいツールの追加](#新しいツールの追加)
- [トラブルシューティング](#トラブルシューティング)

---

## リリース手順

### クイックリファレンス

新バージョンをリリースする際の手順：

```bash
# 1. ツールのリポジトリでタグを作成
cd ~/ghq/github.com/yugo-ibuki/TOOL_NAME
git tag v1.2.3
git push origin v1.2.3

# 2. SHA256を取得
curl -sL "https://github.com/yugo-ibuki/TOOL_NAME/archive/refs/tags/v1.2.3.tar.gz" | shasum -a 256

# 3. Formulaを更新
cd ~/ghq/github.com/yugo-ibuki/homebrew-tap
vim Formula/TOOL_NAME.rb  # urlとsha256を更新

# 4. テスト
brew audit --strict Formula/TOOL_NAME.rb
brew uninstall TOOL_NAME 2>/dev/null || true
brew install --build-from-source Formula/TOOL_NAME.rb
TOOL_NAME --version

# 5. デプロイ
git add Formula/TOOL_NAME.rb
git commit -m "Update TOOL_NAME to v1.2.3"
git push origin main
```

### 詳細な手順

#### 1. ソースコードリポジトリでリリースタグを作成

```bash
cd ~/ghq/github.com/yugo-ibuki/TOOL_NAME

# テストを実行
go test ./...

# タグを作成してプッシュ
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

#### 2. SHA256ハッシュを取得

```bash
NEW_VERSION="1.2.3"
REPO_NAME="TOOL_NAME"
curl -sL "https://github.com/yugo-ibuki/${REPO_NAME}/archive/refs/tags/v${NEW_VERSION}.tar.gz" | shasum -a 256
```

#### 3. Formulaファイルを更新

```bash
cd ~/ghq/github.com/yugo-ibuki/homebrew-tap
vim Formula/${REPO_NAME}.rb
```

更新内容：
```ruby
class ToolName < Formula
  desc "Your tool description"
  homepage "https://github.com/yugo-ibuki/TOOL_NAME"
  url "https://github.com/yugo-ibuki/TOOL_NAME/archive/refs/tags/v1.2.3.tar.gz"  # ← 変更
  sha256 "a1b2c3d4e5f6..."  # ← 取得したSHA256
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"TOOL_NAME", "--version"
  end
end
```

#### 4. 検証とテスト

```bash
# スタイルチェック
brew style Formula/${REPO_NAME}.rb

# 監査
brew audit --strict Formula/${REPO_NAME}.rb

# インストールテスト
brew uninstall ${REPO_NAME} 2>/dev/null || true
brew install --build-from-source Formula/${REPO_NAME}.rb

# 動作確認
${REPO_NAME} --version
${REPO_NAME} --help
```

#### 5. コミット＆デプロイ

```bash
git add Formula/${REPO_NAME}.rb
git commit -m "Update ${REPO_NAME} to v${NEW_VERSION}"
git push origin main
```

#### 6. 動作確認

```bash
brew update
brew upgrade ${REPO_NAME}
${REPO_NAME} --version
```

---

## 新しいツールの追加

### 基本手順

#### 1. ソースコードを準備

```bash
# 新しいリポジトリを作成
github.com/yugo-ibuki/awesome-cli/
├── main.go
├── go.mod
├── LICENSE
└── README.md
```

#### 2. 最初のリリースを作成

```bash
cd ~/ghq/github.com/yugo-ibuki/awesome-cli
git tag v1.0.0
git push origin v1.0.0
```

#### 3. SHA256を取得

```bash
curl -sL https://github.com/yugo-ibuki/awesome-cli/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
```

#### 4. Formulaを作成

```bash
cd ~/ghq/github.com/yugo-ibuki/homebrew-tap

cat > Formula/awesome-cli.rb << 'EOF'
class AwesomeCli < Formula
  desc "Your awesome CLI tool"
  homepage "https://github.com/yugo-ibuki/awesome-cli"
  url "https://github.com/yugo-ibuki/awesome-cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "ここに取得したSHA256"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"awesome-cli", "--version"
  end
end
EOF
```

#### 5. テスト＆デプロイ

```bash
brew audit --strict Formula/awesome-cli.rb
brew install --build-from-source awesome-cli
awesome-cli --version

git add Formula/awesome-cli.rb
git commit -m "Add awesome-cli formula"
git push
```

---

## トラブルシューティング

### SHA256が一致しない

```bash
# Formula内のURLを使用して再取得
FORMULA_URL=$(grep 'url' Formula/${REPO_NAME}.rb | sed 's/.*"\(.*\)".*/\1/')
curl -sL "$FORMULA_URL" | shasum -a 256
```

### タグが作成されていない

```bash
# リモートのタグを確認
git ls-remote --tags https://github.com/yugo-ibuki/${REPO_NAME}

# タグを作成
git tag v1.2.3
git push origin v1.2.3
```

### ビルドエラー

```bash
# 詳細なログを確認
brew install --build-from-source --verbose --debug Formula/${REPO_NAME}.rb

# ソースコードで直接ビルドできるか確認
cd ~/ghq/github.com/yugo-ibuki/${REPO_NAME}
git checkout v1.2.3
go build
```

---

## 便利なコマンド

```bash
# Formula のスタイルチェック
brew style Formula/tool-name.rb

# Formula の監査
brew audit --strict Formula/tool-name.rb

# Formula の情報を表示
brew info yugo-ibuki/tap/tool-name

# Formula のテスト
brew test yugo-ibuki/tap/tool-name

# tap の更新
brew update

# tap の再インストール
brew untap yugo-ibuki/tap
brew tap yugo-ibuki/tap
```

---

## 参考リンク

- [Homebrew Documentation](https://docs.brew.sh/)
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [How to Create a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
