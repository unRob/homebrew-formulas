class Joao < Formula
  desc "A very WIP configuration manager"
  homepage "https://git.rob.mx/nidito/joao"
  version "v0.0.0+alpha.6"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "c817dd2229ddf5513c5b2d4f14e7a12af381ca98a30cefb555c31709a0179d6f"
      on_arm do
        arch = "arm64"
        sha256 "66ab6dd45e4499a0c8ba8fee5f0ac4c3aaddea67a16d2380688e3133ae4b669b"
      end
    end
    on_linux do
      sha256 "2bb9a13b28edf534b428771136a9ae5d895d08a1d3c157936e3faa5f08e82f17"
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "933de75dc3e3b1ab7910172a6e03be9f38f24c6aa0a45e585dfe14de7a7a2ae6"
      end
    end
    url "https://cdn.rob.mx/tools/joao/#{version}/joao-#{os}-#{arch}.tgz"
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
