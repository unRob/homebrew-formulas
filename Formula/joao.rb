class Joao < Formula
  desc "A very WIP configuration manager"
  homepage "https://git.rob.mx/nidito/joao"
  version "v0.0.0+alpha.11"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "4bd9484ab2e9733a7cce95285734fa89e1a91687faa490ca172021721f613577" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "11f237cc7d31ecf2aaf22d63069236af872a531e7e31939b168a4ca8cf1cbfc6" # darwin_arm64
      end
    end
    on_linux do
      sha256 "b799be0f3b4c793628cfa45257ec2bbcb252dee2217a11a0ab80d9d8a271c77f" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "355a3d076dfafe5518e0f002c11540a3ed3590b5cd05bd8260fbc66368ba4b7d" # linux_arm64
      end
    end
    url "https://cdn.rob.mx/tools/joao/#{version}/joao-#{os}-#{arch}.tgz"
    # https://cdn.rob.mx/tools/joao/VERSION/joao-OS-ARCH.tgz.shasum # shasum-url
  end

  livecheck do
    url "https://cdn.rob.mx/tools/joao/latest-version" # version-check-url
    regex(/.+/i)
    strategy :page_match, &:to_s
  end

  head do
    url "https://git.rob.mx/nidito/joao.git", branch: "main"
    depends_on "go"
  end

  def install
    if build.head?
      with_env(CGO_ENABLED: "0") do
        system "go", "build", "-ldflags" "-s -w -X git.rob.mx/nidito/joao/pkg/version.Version=#{version}-homebrew-head", "-trimpath"
      end
    end

    prefix.install "joao"

    bin.install_symlink prefix/"joao"
    generate_completions_from_executable(bin/"joao", "__generate_completions", base_name: "joao")
  end

  test do
    system "#{bin}/joao" "--version"
  end
end
