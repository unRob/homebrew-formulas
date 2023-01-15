class Joao < Formula
  desc "A very WIP configuration manager"
  homepage "https://git.rob.mx/nidito/joao"
  version "v0.0.0+alpha.3"
  license "Apache-2.0"
  stable do
    os = "darwin"
    arch = "amd64"
    on_macos do
      sha256 "95beb98d4abdb0d185446d60a5ee6014b7c8f77ef9df7d8947e6c68c117ae99a"
      on_arm do
        arch = "arm64"
        sha256 "7a24acb8cdd92c9e6c081e24a2306cacfdd44d9cc940fdf96c561e0d5ce31b05"
      end
    end
    on_linux do
      sha256 "6562ea5a03d48ee87cace0380fd17847a9faefc5713ac35f28f3fb269fce2b40"
      os = "linux"
      on_arm do
        arch = "arm64"
        sha256 "0b23e54a54067de5787280dec6d48e3bd20db7dd001680260e1b435f368474aa"
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
