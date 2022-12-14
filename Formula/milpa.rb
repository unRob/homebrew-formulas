class Milpa < Formula
  desc "Tool to care for one's own garden of scripts"
  homepage "https://milpa.dev"
  version "0.0.0-alpha.33"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "d26e694dccd052e0e7d83a2e782ad4536d5970e49808d081b335cb00e3933e82"
      on_arm do
        arch = "arm64"
        sha256 "4dedc495e1390ae212977925e7e31df4fc07357c06b88edfcca0e579aa165b4e"
      end
    end
    on_linux do
      sha256 "2470366f1e43972daa21d183965f3cecc0b3c16d90dbf5a7c6442f8ed32b9ecc"
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "5e1a7fcf3b2282c672b503cd097ffab24d0d7127b60a71fc3560c79cce7faa7d"
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
