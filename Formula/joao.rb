class Joao < Formula
  desc "A very WIP configuration manager"
  homepage "https://git.rob.mx/nidito/joao"
  version "v0.0.0+alpha.9"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "c9abe85073f0e6b6d3cfc9fa317eddaa148e770b2ba48966f635030dbf845ec5" # darwin_amd64
      on_arm do
        arch = "arm64"
        sha256 "8b3be66c6bf80ba065dc739e417681078f33cbd1e232a3a7fa61d0baaef8de1d" # darwin_arm64
      end
    end
    on_linux do
      sha256 "7b1055764d7b0b25bb1e2274d51166ea96dfc526c87c54e082e00a3cc2fac449" # linux_amd64
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "7e14e0db8613d44e586872802338d4c2ae561576250bc885c1968077c2b83902" # linux_arm64
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
