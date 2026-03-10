class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-beta.6"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "7edbcac6eb98f5e8aa5b7379d90071cab301133dcee33189d0869ea5f0b42ae0" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "72895a155a425005ecfb4f00ca92344251b5b489e4687e2ef95e3298680e4033" # darwin_arm64
      end
    end
    on_linux do
      sha256 "a593154a2ed34f2d6cefa01c09983b86a30adee0bdd1568b07425de0046c109b" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "12e18cdb0748b3d487d9ce7adfb107ff9f03202af9771d0f3c728d812d63f25d" # linux_arm64
      end
    end
    url "https://github.com/unRob/milpa/releases/download/#{version}/milpa-#{os}-#{arch}.tgz"
    # https://github.com/unRob/milpa/releases/download/VERSION/milpa-OS-ARCH.tgz.shasum # shasum-url
  end

  livecheck do
    url "https://milpa.dev/.well-known/milpa/latest-version" # version-check-url
    regex(/.+/i)
    strategy :page_match, &:to_s
  end

  head do
    url "https://github.com/unRob/milpa.git", branch: "main"
    depends_on "go"
  end

  def install
    if build.head?
      with_env(CGO_ENABLED: "0") do
        system "go", "build", "-ldflags" "-s -w -X main.version=#{version}-homebrew-head"
      end
    end
    # we're not going to use a system-wide place for global repos
    inreplace "milpa" do |s|
      s.gsub!(%r{/usr/local/lib/milpa}, prefix)
    end
    # instead, we're using a homebrew-maintained one
    global_repos = etc / "milpa" / "repos"
    global_repos.mkpath
    # link it to the installation prefix
    ln_s global_repos, prefix

    # user repos dir can't be created with homebrew because $HOME is off limits
    user_repos = share / "milpa" / "repos"
    user_repos.mkpath

    prefix.install "milpa"
    prefix.install "compa"
    prefix.install ".milpa"
    prefix.install "CHANGELOG.md"
    prefix.install "LICENSE.txt"
    prefix.install "README.md"

    bin.install_symlink prefix/"milpa"
    bin.install_symlink prefix/"compa"

    with_env(MILPA_ROOT: prefix, XDG_DATA_HOME: share) do
      generate_completions_from_executable(bin/"compa", "__generate_completions", base_name: "milpa")
    end
  end

  def caveats
    header = <<~EOF
      You should create ~/.local/share/milpa/repos if it doesn't already exist.
      Homebrew does not allow packages to write anything to $HOME:

        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/milpa/repos"

      milpa works best when shell completions are enabled, follow along
      Homebrew's instructions for your shell:

        https://docs.brew.sh/Shell-Completion
    EOF
  end

  test do
    ENV["XDG_DATA_HOME"] = share

    system "#{bin}/milpa" "--version"
  end
end
