class Bbcecko < Formula
  desc "Simple, friendly C++ editor for students: highlight, Run, readable errors"
  homepage "https://github.com/brdloush/bbcecko"
  url "https://github.com/brdloush/bbcecko/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3396a7179df1afa33d30791064c4dc3610e1860a06b03164118931dbb89b0193"
  license "MIT"
  head "https://github.com/brdloush/bbcecko.git", branch: "main"

  depends_on "adwaita-icon-theme"
  depends_on "gtk4"
  depends_on "gtksourceview5"

  # babashka runs the app. It is not in homebrew-core, and depending on the
  # borkdude/brew tap would make every user tap it by hand first, so the
  # formula carries its own copy, private to this keg.
  on_macos do
    on_arm do
      resource "babashka" do
        url "https://github.com/babashka/babashka/releases/download/v1.13.229/babashka-1.13.229-macos-aarch64.tar.gz"
        sha256 "2d96ff06ce66883caa873fb717941a58c45523e3db9d91424e9f81b038896331"
      end
    end
    on_intel do
      resource "babashka" do
        url "https://github.com/babashka/babashka/releases/download/v1.13.229/babashka-1.13.229-macos-amd64.tar.gz"
        sha256 "5d7aff8ffa8237f6e12cf879fde98777d9378e7fa78bb943815c3cfba184d78f"
      end
    end
  end
  on_linux do
    on_intel do
      resource "babashka" do
        url "https://github.com/babashka/babashka/releases/download/v1.13.229/babashka-1.13.229-linux-amd64.tar.gz"
        sha256 "a98c90a0530943dfa9a0b03bcccbc2030777a6ce094af303d5bb47d77e193299"
      end
    end
  end

  def install
    resource("babashka").stage { (libexec/"bin").install "bb" }
    bb = libexec/"bin/bb"
    # one jar with the app, gtkiccup and Replicant: nothing to fetch at run time
    system bb, "--config", "bb.edn", "uberjar", "bbcecko.jar", "-m", "bbcecko.main"
    libexec.install "bbcecko.jar"
    (bin/"bbcecko").write <<~SH
      #!/bin/bash
      # Started from a terminal with no argument: the current folder is the root.
      if [ $# -eq 0 ] && [ -t 1 ]; then export BBCECKO_CWD="$PWD"; fi
      exec "#{bb}" -Xmx256m -cp "#{libexec}/bbcecko.jar" -m bbcecko.main -- "$@"
    SH
  end

  def caveats
    <<~EOS
      Start it with:
        bbcecko                 # the folder you are in (from a terminal)
        bbcecko ~/skola/cpp     # a folder with your programs

      bbCéčko compiles with Apple's clang++. If it says the compiler is
      missing, install the command line tools:
        xcode-select --install

      Check that everything is in place:
        bbcecko --doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bbcecko --version")
  end
end
