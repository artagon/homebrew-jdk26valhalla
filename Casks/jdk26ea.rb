cask "jdk26ea" do
  arch arm: "aarch64", intel: "x64"

  version "26-jep401ea2+1-1,1"
  # Installs to: /Library/Java/JavaVirtualMachines/jdk-26-valhalla.jdk
  # Supports: macOS ARM64 (Apple Silicon) and x64 (Intel)
  sha256 arm:   "26212c92153332de17848411dcf918ebf79997569e0732d156d19f38fd1b455d",
         intel: "0aa98bba51f82fc6170515d4c900ed92b345632d8baae74aa9a0ac9c5d3b26b1"

  url "https://download.java.net/java/early_access/valhalla/26/#{version.csv.second}/openjdk-#{version.csv.first}_macos-#{arch}_bin.tar.gz"
  name "JDK 26 Valhalla"
  desc "Project Valhalla JDK 26 - Value Classes and Objects (JEP 401)"
  homepage "https://jdk.java.net/valhalla/"

  postflight do
    require "pathname"

    staged_root = staged_path.realpath
    candidates = Dir["#{staged_root}/jdk-*.jdk"]
    odie "Expected exactly one JDK bundle in #{staged_root}, found #{candidates.length}" if candidates.length != 1

    jdk_src = Pathname(candidates.first).realpath
    odie "Staged JDK bundle #{jdk_src} is not a directory" unless jdk_src.directory?
    odie "Resolved JDK path escapes staging area" unless jdk_src.to_s.start_with?(staged_root.to_s)

    jdk_target = Pathname("/Library/Java/JavaVirtualMachines/jdk-26-valhalla.jdk")
    if jdk_target.exist?
      ohai "Removing existing JDK at #{jdk_target}"
      removal = system_command "/bin/rm",
                               args: ["-rf", jdk_target.to_s],
                               sudo: true
      odie "Failed to remove existing JDK at #{jdk_target}" unless removal.success?
    end

    ohai "Installing JDK 26 Valhalla to #{jdk_target}"
    install = system_command "/usr/bin/ditto",
                             args: ["--noqtn", jdk_src.to_s, jdk_target.to_s],
                             sudo: true
    odie "Failed to install JDK to #{jdk_target}" unless install.success?
  end

  uninstall delete: "/Library/Java/JavaVirtualMachines/jdk-26-valhalla.jdk"
end
