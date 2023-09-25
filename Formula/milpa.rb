class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-beta.1"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "27358406976615b9f853291cf20b651b021491fcd050641e387bd440f195f3f6" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "d287f4841b702228d707c58eabb7466608ffbe32938e144830e3a2f1e23bc7f1" # darwin_arm64
      end
    end
    on_linux do
      sha256 "8a3303f3a91c8c331450d5e637fd64e2fc46416addd894e8a1ed6e2391e6cb6c" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "1904c1a228fbbfb9174d5138bdcd02f465361ca30d14660816f19e5a8b1ee728" # linux_arm64
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

    prefix.install "milpa"
    prefix.install "compa"
    prefix.install ".milpa"
    prefix.install "CHANGELOG.md"
    prefix.install "LICENSE.txt"
    prefix.install "README.md"

    bin.install_symlink prefix/"milpa"
    bin.install_symlink prefix/"compa"

    with_env(MILPA_ROOT: prefix) do
      generate_completions_from_executable(bin/"compa", "__generate_completions", base_name: "milpa")
    end
  end

  test do
    system "#{bin}/milpa" "--version"
  end
end
