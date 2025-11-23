# Homebrew Tap メンテナンスガイド

このドキュメントは `yugo-ibuki/homebrew-tap` の管理方法をまとめたものです。

## 📚 目次

- [Homebrewのtapの仕組み](#homebrewのtapの仕組み)
- [リポジトリ構成](#リポジトリ構成)
- [プライベートリポジトリの扱い](#プライベートリポジトリの扱い)
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
  sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  license "MIT"

  depends_on "go" => :build # ビルド時の依存関係

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system bin/"tool-name", "--version"
  end
end
```

---

## プライベートリポジトリの扱い

Homebrewのtapでプライベートリポジトリを使用する場合の考慮事項を説明します。

### パターン別の対応方法

#### 🟢 パターンA: すべてPublic（推奨・最も簡単）

```
✅ homebrew-tap リポジトリ: Public
✅ ツールのソースコード: Public
```

**メリット**:
- 設定不要、誰でもインストール可能
- `brew install yugo-ibuki/tap/tool-name` だけで動作
- メンテナンスが最も簡単

**デメリット**:
- コードが公開される

**使用例**: オープンソースツール、公開したいCLIツール

---

#### 🟡 パターンB: tapはPublic、ソースはPrivate

```
✅ homebrew-tap リポジトリ: Public
🔒 ツールのソースコード: Private
```

**メリット**:
- Formulaは公開、ソースコードは非公開
- 一定の条件下で利用可能

**デメリット**:
- ユーザーに認証設定が必要
- インストール時にGitHub Personal Access Tokenが必要
- 配布が複雑になる

**必要な設定**:

1. **GitHub Personal Access Tokenの作成**
   - GitHub Settings → Developer settings → Personal access tokens
   - `repo` スコープを付与

2. **Formulaファイルの調整**
   ```ruby
class ToolName < Formula
  desc "Private tool"
  homepage "https://github.com/yugo-ibuki/tool-name"
  url "https://github.com/yugo-ibuki/tool-name/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  license "MIT"

  depends_on "go" => :build

  def install
    # GitHub認証が必要な旨をユーザーに通知
    ohai "This formula requires GitHub authentication"
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  def caveats
    <<~EOS
      This formula installs from a private repository.
      You need to configure GitHub authentication:

      export HOMEBREW_GITHUB_API_TOKEN=your_github_token
    EOS
  end
end
   ```

3. **ユーザー側の設定**
   ```bash
   # 環境変数にトークンを設定
   export HOMEBREW_GITHUB_API_TOKEN=ghp_xxxxxxxxxxxx

   # または ~/.zshrc / ~/.bashrc に追加
   echo 'export HOMEBREW_GITHUB_API_TOKEN=ghp_xxxxxxxxxxxx' >> ~/.zshrc

   # インストール
   brew install yugo-ibuki/tap/tool-name
   ```

**制限事項**:
- タグ付きリリースのtarballへのアクセスに認証が必要
- SHA256の取得も認証が必要
  ```bash
  curl -sL -H "Authorization: token $GITHUB_TOKEN" \
    https://github.com/yugo-ibuki/private-repo/archive/refs/tags/v1.0.0.tar.gz | \
    shasum -a 256
  ```

---

#### 🔴 パターンC: 両方Private（企業内利用）

```
🔒 homebrew-tap リポジトリ: Private
🔒 ツールのソースコード: Private
```

**メリット**:
- 完全にプライベート
- 企業内ツール配布に最適

**デメリット**:
- 一般公開できない
- 複雑な認証設定が必要

**必要な設定**:

1. **プライベートtapの追加**
   ```bash
   # 認証付きでtapを追加
   brew tap yugo-ibuki/tap https://github.com/yugo-ibuki/homebrew-tap.git
   ```

2. **Git認証の設定**
   ```bash
   # SSH認証（推奨）
   git config --global url."git@github.com:".insteadOf "https://github.com/"

   # または HTTPS + Personal Access Token
   git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
   ```

3. **Homebrew環境変数**
   ```bash
   export HOMEBREW_GITHUB_API_TOKEN=your_token
   ```

**企業向けの推奨設定**:
```bash
# ~/.zshrc または ~/.bashrc に追加
export HOMEBREW_GITHUB_API_TOKEN=ghp_xxxxxxxxxxxx

# SSH鍵の設定（推奨）
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

### 推奨される使い分け

| 用途 | tap | ソースコード | パターン |
|------|-----|------------|---------|
| オープンソースツール | Public | Public | 🟢 A |
| 個人用ツール（公開したくない） | Public | Private | 🟡 B |
| 企業内ツール | Private | Private | 🔴 C |
| 商用ツール（制限配布） | Public | Private | 🟡 B |

### 現実的なアドバイス

#### オープンソース化を検討する場合

プライベートリポジトリを使うよりも、**可能であればPublicにすることを推奨**します：

**理由**:
- ✅ Homebrewの本来の使い方に沿っている
- ✅ ユーザーが認証設定不要で簡単にインストール可能
- ✅ コミュニティからのフィードバックを得られる
- ✅ ポートフォリオとして公開できる

**公開したくない部分がある場合の対処**:
- 設定ファイルのテンプレートのみ公開
- 秘密情報は環境変数で管理
- `.env.example` を用意してドキュメント化

#### どうしてもPrivateにする必要がある場合

**パターンB（tapはPublic、ソースはPrivate）の改善策**:

1. **ビルド済みバイナリの配布**
   ```ruby
class ToolName < Formula
  desc "Private tool"
  homepage "https://github.com/yugo-ibuki/tool-name"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/yugo-ibuki/tool-name/releases/download/v1.0.0/tool-name-darwin-arm64.tar.gz"
      sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    else
      url "https://github.com/yugo-ibuki/tool-name/releases/download/v1.0.0/tool-name-darwin-amd64.tar.gz"
      sha256 "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210"
    end
  end

  def install
    bin.install "tool-name"
  end
end
   ```

2. **GitHub Releasesでビルド済みバイナリを配布**
   - ソースコードはPrivate
   - Releasesのアセット（バイナリ）だけPublicに設定可能
   - CI/CDでクロスコンパイル

---

### まとめ

```
プライベートリポジトリの利用可否:
├─ tap自体          → Public推奨（Privateも可能だが複雑）
└─ ソースコード      → Public推奨（Privateは認証が必要）

推奨順:
1. 🥇 両方Public        → 最も簡単、推奨
2. 🥈 ビルド済みバイナリ配布 → Privateソースでも配布可能
3. 🥉 tapはPublic、ソースPrivate → 認証必要だが可能
4.    両方Private       → 企業内利用のみ
```

**一般公開ツールの場合**: **パターンA（両方Public）を強く推奨**します。

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

### デプロイ手順（クイックリファレンス）

ツールの新バージョンをリリース済みの場合、以下の手順でFormulaを更新・デプロイします：

```bash
# 1. 新しいバージョンのSHA256ハッシュを取得
curl -sL "https://github.com/yugo-ibuki/TOOL_NAME/archive/refs/tags/vX.Y.Z.tar.gz" | shasum -a 256

# 2. Formulaファイルを編集（urlとsha256を更新）
vim Formula/TOOL_NAME.rb

# 3. 監査を実行
brew audit --strict TOOL_NAME

# 4. ローカルで動作確認
brew uninstall TOOL_NAME
brew install --build-from-source TOOL_NAME
TOOL_NAME --version

# 5. コミット & プッシュ
git add Formula/TOOL_NAME.rb
git commit -m "Update TOOL_NAME to vX.Y.Z

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin main

# 6. tapを更新してインストール確認
brew update
brew upgrade TOOL_NAME
```

**重要**: SHA256ハッシュは必ず`curl | shasum`で取得すること。Formula内のURLと完全に一致する必要があります。

---

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
  url "https://github.com/yugo-ibuki/dot-claude-sync/archive/refs/tags/v0.1.4.tar.gz" # ← バージョン変更
  sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" # ← 新しいSHA256に変更
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
