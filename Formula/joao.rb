class Joao < Formula
  desc "A very WIP configuration manager"
  homepage "https://git.rob.mx/nidito/joao"
  version "v0.0.0+alpha.8"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "915bc66dc592418b314abe77e66ee4ab2c1915875723e22ca38f3a42e1f5c131" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "2ff17bc3c91d122fbdaa6b33a9f5d702bc0e7491b2c85988971de50fb8f7887b" # darwin_arm64
      end
    end
    on_linux do
      sha256 "bef65904f03124d1950e83d600883dab3a450e0bcf7455a3533c9a8c83b50326" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "abdb022f6a94a2826cb3d61e63bc30349f9700cdb7b25dd9136e26e4080ff226" # linux_arm64
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
