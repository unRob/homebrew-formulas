class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-beta.3"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "fbca674344863154e4f6ac52772a23f3d3fd14ec158b3a0205eb771c3b8e3be6" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "1e19634b496ba8795b3e025a54f7588f90b9556b7e66f5eb032861618a11de22" # darwin_arm64
      end
    end
    on_linux do
      sha256 "104d5a1ffbb82974ec139a287e924102c5611df2a9764b53353d6d1d6f025978" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "ac83a7229a4f7633b0f6b6fc39dfedcffdd2ccf9ade6d32b4b2fd783f42614f0" # linux_arm64
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
