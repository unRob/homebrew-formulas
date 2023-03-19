class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-alpha.39"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "364da8833ae8a58311116197222739dd982d4258d2a743e3e51f72af7bfd6cae"
      on_arm do
        arch = "arm64"
        sha256 "d9d96567f38909e87695b22ce3ba45470f551aea3f83a77babf080bc00064d91"
      end
    end
    on_linux do
      sha256 "ef6591bbc14ca2c1887468d630d2275c149de7e20d10a68f534bb4dc02d5707b"
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "c6fa847fe0f9ba4597d9d84425a4af15efa246ed48bb5b97592a825f1c528a58"
      end
    end
    url "https://github.com/unRob/milpa/releases/download/#{version}/milpa-#{os}-#{arch}.tgz"
  end

  livecheck do
    url "https://milpa.dev/.well-known/milpa/latest-version"
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
