class Bbcecko < Formula
  desc "Simple, friendly C++ editor for students: highlight, Run, readable errors"
  homepage "https://github.com/brdloush/bbcecko"
  url "https://github.com/brdloush/bbcecko/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3396a7179df1afa33d30791064c4dc3610e1860a06b03164118931dbb89b0193"
  license "MIT"
  head "https://github.com/brdloush/bbcecko.git", branch: "main"

  depends_on "borkdude/brew/babashka"
  depends_on "gtk4"
  depends_on "gtksourceview5"
  depends_on "adwaita-icon-theme"

  def install
    bb = Formula["borkdude/brew/babashka"].opt_bin/"bb"
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
