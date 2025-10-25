class Jdk26valhalla < Formula
  desc "JDK 26 Project Valhalla - Value Classes and Objects (JEP 401)"
  homepage "https://jdk.java.net/valhalla/"
  version "26-jep401ea2+1-1"
  on_macos do
    if Hardware::CPU.arm?
      url "https://download.java.net/java/early_access/valhalla/26/1/openjdk-26-jep401ea2+1-1_macos-aarch64_bin.tar.gz"
      sha256 "26212c92153332de17848411dcf918ebf79997569e0732d156d19f38fd1b455d"
    else
      url "https://download.java.net/java/early_access/valhalla/26/1/openjdk-26-jep401ea2+1-1_macos-x64_bin.tar.gz"
      sha256 "0aa98bba51f82fc6170515d4c900ed92b345632d8baae74aa9a0ac9c5d3b26b1"
    end
  end
  on_linux do
    if Hardware::CPU.arm?
      url "https://download.java.net/java/early_access/valhalla/26/1/openjdk-26-jep401ea2+1-1_linux-aarch64_bin.tar.gz"
      sha256 "bbbec59d4ae05c8ad7b0c5a38c6b5a485fdf1b3141593fe383e3b80c58303c98"
    else
      url "https://download.java.net/java/early_access/valhalla/26/1/openjdk-26-jep401ea2+1-1_linux-x64_bin.tar.gz"
      sha256 "27d12e7ed51b0a9e94c6356adb4c42a50a8861031e1bc833b3f6b7a3212bed55"
    end
  end
  def install
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end
  test do
    (testpath/"Hello.java").write <<~JAVA
      class Hello {
          public static void main(String[] args) {
              System.out.println("hi");
          }
      }
    JAVA
    system "#{bin}/javac", "--enable-preview", "--release", "26", "Hello.java"
    assert_match(/26|26-jep401ea2/, shell_output("#{bin}/java --enable-preview Hello"))
  end
end
