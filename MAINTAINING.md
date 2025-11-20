# Homebrew Tap メンテナンスガイド

このドキュメントは `yugo-ibuki/homebrew-tap` の管理方法をまとめたものです。

## 📚 目次

- [Homebrewのtapの仕組み](#homebrewのtapの仕組み)
- [リポジトリ構成](#リポジトリ構成)
- [新しいツールの追加](#新しいツールの追加)
- [既存ツールの更新](#既存ツールの更新)
- [便利なコマンド集](#便利なコマンド集)
- [トラブルシューティング](#トラブルシューティング)

---

## Homebrewのtapの仕組み

### 基本概念

**推奨構成**: 1つのtapリポジトリに複数のFormula

```
github.com/yugo-ibuki/
├── tool-a/                    # ツールAのソースコード
├── tool-b/                    # ツールBのソースコード
├── dot-claude-sync/          # 既存ツール
└── homebrew-tap/             # 1つのtapリポジトリ（全ツール用）
    └── Formula/
        ├── tool-a.rb
        ├── tool-b.rb
        └── dot-claude-sync.rb
```

### ユーザー側の使い方

```bash
# 一度だけtapを追加
brew tap yugo-ibuki/tap

# 各ツールをインストール
brew install tool-a
brew install tool-b
brew install dot-claude-sync
```

### ポイント

- ✅ 各ツールのソースコードは別々のリポジトリで管理
- ✅ Formulaは全て `homebrew-tap` に集約
- ✅ ユーザーは `brew tap yugo-ibuki/tap` を一度実行するだけ
- ✅ メンテナンスが容易（1つのリポジトリで全てのFormulaを管理）

---

## リポジトリ構成

### 現在の構成

```
homebrew-tap/
├── .github/
│   └── workflows/          # CI/CD設定（将来的に）
├── Formula/
│   └── dot-claude-sync.rb  # 各ツールのFormula
├── README.md               # ユーザー向けドキュメント
└── MAINTAINING.md          # このファイル（メンテナー向け）
```

### Formulaファイルの基本構造

```ruby
class ToolName < Formula
  desc "ツールの簡潔な説明"
  homepage "https://github.com/yugo-ibuki/tool-name"
  url "https://github.com/yugo-ibuki/tool-name/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "SHA256ハッシュ値"
  license "MIT"

  depends_on "go" => :build  # ビルド時の依存関係

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"tool-name", "--version"
  end
end
```

---

## 新しいツールの追加

### 手順

#### 1. ツールのソースコード（別リポジトリ）を準備

```bash
# 例：awesome-cli というツールを作る
github.com/yugo-ibuki/awesome-cli/
├── main.go
├── go.mod
├── go.sum
├── LICENSE
└── README.md
```

#### 2. 最初のリリースを作成

```bash
cd ~/ghq/github.com/yugo-ibuki/awesome-cli

# コードを完成させる
git add .
git commit -m "Initial release"
git push

# リリースタグを作成
git tag v1.0.0
git push origin v1.0.0
```

#### 3. SHA256ハッシュを取得

```bash
# 方法1: curlで取得
curl -sL https://github.com/yugo-ibuki/awesome-cli/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256

# 方法2: brewコマンドで取得
brew fetch --build-from-source https://github.com/yugo-ibuki/awesome-cli/archive/refs/tags/v1.0.0.tar.gz 2>&1 | grep SHA256
```

#### 4. tapリポジトリにFormulaを追加

```bash
cd ~/ghq/github.com/yugo-ibuki/homebrew-tap

# Formulaファイルを作成
cat > Formula/awesome-cli.rb << 'EOF'
class AwesomeCli < Formula
  desc "Your awesome CLI tool"
  homepage "https://github.com/yugo-ibuki/awesome-cli"
  url "https://github.com/yugo-ibuki/awesome-cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "ここに取得したSHA256ハッシュ"
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

#### 5. テスト & コミット

```bash
# スタイルチェック
brew style yugo-ibuki/tap

# 監査
brew audit --strict Formula/awesome-cli.rb

# ローカルでインストールテスト
brew install --build-from-source awesome-cli

# 動作確認
awesome-cli --version

# 問題なければコミット
git add Formula/awesome-cli.rb
git commit -m "Add awesome-cli formula"
git push
```

---

## 既存ツールの更新

### 完全なワークフロー

例：`dot-claude-sync` を v0.1.3 → v0.1.4 に更新

#### 1. ツールのソースコードを更新

```bash
cd ~/ghq/github.com/yugo-ibuki/dot-claude-sync

# コードを修正・機能追加
vim main.go

# テストを実行
go test ./...

# コミット
git add .
git commit -m "Add new feature"
git push
```

#### 2. 新しいリリースを作成

```bash
# 新しいバージョンのタグを作成
git tag v0.1.4

# タグをプッシュ（これでGitHubのReleasesページに表示される）
git push origin v0.1.4
```

#### 3. SHA256ハッシュを取得

```bash
# 新しいバージョンのSHA256を取得
curl -sL https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz | shasum -a 256
```

#### 4. Formulaを更新

```bash
cd ~/ghq/github.com/yugo-ibuki/homebrew-tap

# Formulaファイルを編集
vim Formula/dot-claude-sync.rb
```

**更新箇所**:
```ruby
class DotClaudeSync < Formula
  desc "Synchronize .claude directories across multiple projects"
  homepage "https://github.com/yugo-ibuki/dot-claude-sync"
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz"  # ← バージョン変更
  sha256 "新しいハッシュ値"  # ← 新しいSHA256に変更
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"dot-claude-sync", "--version"
  end
end
```

#### 5. テスト & コミット

```bash
# スタイルチェック
brew style yugo-ibuki/tap

# 監査
brew audit --strict Formula/dot-claude-sync.rb

# 既存バージョンをアンインストール
brew uninstall dot-claude-sync

# 新しいバージョンをインストールしてテスト
brew install --build-from-source dot-claude-sync

# バージョン確認
dot-claude-sync --version  # v0.1.4 と表示されることを確認

# 問題なければコミット
git add Formula/dot-claude-sync.rb
git commit -m "Update dot-claude-sync to v0.1.4"
git push
```

#### 6. ユーザー側の更新

ユーザーは以下のコマンドで最新版にアップデートできます：

```bash
brew update
brew upgrade dot-claude-sync
```

---

## 便利なコマンド集

### 開発・テスト用

```bash
# Formula の構文チェック
brew style Formula/tool-name.rb

# Formula の詳細な監査
brew audit --strict Formula/tool-name.rb

# ローカルでビルド（実際にインストールはしない）
brew install --build-from-source --verbose --debug Formula/tool-name.rb

# インストール済みツールのアンインストール
brew uninstall tool-name

# Formula の情報を表示
brew info yugo-ibuki/tap/tool-name
```

### SHA256取得の簡単な方法

```bash
# URLから直接SHA256を計算
curl -sL <tarball-url> | shasum -a 256

# 例
curl -sL https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz | shasum -a 256
```

### brew コマンドでのテスト

```bash
# Formula のテストを実行
brew test yugo-ibuki/tap/tool-name

# 依存関係の確認
brew deps yugo-ibuki/tap/tool-name

# Formula の詳細情報
brew info --json yugo-ibuki/tap/tool-name | jq
```

### Git操作

```bash
# 現在のtapの場所を確認
brew --repository yugo-ibuki/tap

# tap を最新状態に更新
brew update

# tap を削除（開発時のリセット用）
brew untap yugo-ibuki/tap

# tap を再追加
brew tap yugo-ibuki/tap
```

---

## トラブルシューティング

### よくある問題と解決方法

#### 1. SHA256が一致しないエラー

**症状**:
```
Error: SHA256 mismatch
Expected: abc123...
Actual: def456...
```

**解決方法**:
```bash
# 正しいSHA256を再取得
curl -sL <tarball-url> | shasum -a 256

# Formula を更新して再度テスト
```

#### 2. Formula が見つからない

**症状**:
```
Error: No available formula with the name "yugo-ibuki/tap/tool-name"
```

**解決方法**:
```bash
# tap を更新
brew update

# tap を削除して再追加
brew untap yugo-ibuki/tap
brew tap yugo-ibuki/tap

# Formula ファイル名を確認（クラス名と一致しているか）
ls -la Formula/
```

#### 3. ビルドエラー

**症状**:
```
Error: Failed to build tool-name
```

**解決方法**:
```bash
# 詳細なログを見る
brew install --build-from-source --verbose --debug tool-name

# 依存関係を確認
brew deps tool-name

# Go のバージョンを確認（Go プロジェクトの場合）
go version
```

#### 4. テストが失敗する

**症状**:
```
Error: test failed
```

**解決方法**:
```bash
# テストセクションを確認
cat Formula/tool-name.rb

# 実際にコマンドが実行できるか確認
/opt/homebrew/bin/tool-name --version

# Formula のテストを詳細モードで実行
brew test --verbose tool-name
```

### デバッグのヒント

```bash
# Formula のパスを確認
brew formula yugo-ibuki/tap/tool-name

# Formula の内容を表示
brew cat yugo-ibuki/tap/tool-name

# インストールログを確認
brew install --verbose tool-name 2>&1 | tee install.log

# Homebrew のキャッシュをクリア
rm -rf $(brew --cache)
```

---

## 参考リンク

- [Homebrew Documentation](https://docs.brew.sh/)
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Style Guide](https://docs.brew.sh/Formula-Cookbook#style-guide)
- [How to Create a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)

---

## メンテナンスチェックリスト

新しいツールを追加する際のチェックリスト：

- [ ] ツールのソースコードリポジトリにLICENSEファイルが存在する
- [ ] リリースタグが作成されている（例: v1.0.0）
- [ ] SHA256ハッシュが正しく取得できている
- [ ] Formula ファイルのクラス名がファイル名と一致している
- [ ] `brew style` が通る
- [ ] `brew audit --strict` が通る
- [ ] ローカルでインストールテストが成功する
- [ ] `--version` や `--help` などの基本コマンドが動作する
- [ ] README.md にツールの情報を追加（必要に応じて）

既存ツールを更新する際のチェックリスト：

- [ ] ソースコードリポジトリに新しいタグが作成されている
- [ ] 新しいバージョンの SHA256 ハッシュを取得済み
- [ ] Formula の `url` と `sha256` を更新済み
- [ ] `brew audit --strict` が通る
- [ ] 古いバージョンをアンインストールして新バージョンをテスト済み
- [ ] バージョン番号が正しく表示される
- [ ] コミットメッセージが明確（例: "Update tool-name to v1.2.3"）
