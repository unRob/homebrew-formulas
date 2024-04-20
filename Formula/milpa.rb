class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-beta.5"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "87b601299da433deadd83720457e27a8699dc1044dd8ce34c58bdb8c52e8e84c" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "11eb4a7240832f5d9593d4f106caa4c0d62eb170a5034efd4ee0e14a8b9d8fc9" # darwin_arm64
      end
    end
    on_linux do
      sha256 "b11c69a3bf867b4e3ccc747b8ed53955dff8a2411405ffa9875b955297969800" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "b96da3de9bba47fcf59c220c4dd52b3f3cc1ecca1e60f39da6ae80eb9ab68d18" # linux_arm64
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
