cask "jdkvalhalla" do
  arch arm: "aarch64", intel: "x64"

  version "27-jep401ea3+1-1,1"
  # Installs to: /Library/Java/JavaVirtualMachines/jdk-valhalla.jdk
  # Supports: macOS ARM64 (Apple Silicon) and x64 (Intel)
  sha256 arm:   "d97c8e0d90d95b81bf99cfef0b1e1edebeb07655fc84c42e6ed99d882aebe76b",
         intel: "64d2deee65c221b7fbdfb936d42981987c1505a6057a1847e5fdb37afabb103a"

  url "https://download.java.net/java/early_access/valhalla/27/#{version.csv.second}/openjdk-#{version.csv.first}_macos-#{arch}_bin.tar.gz"
  name "JDK Valhalla"
  desc "Project Valhalla JDK - Value Classes and Objects (JEP 401)"
  homepage "https://jdk.java.net/valhalla/"

  postflight do
    staged_root = staged_path.realpath
    candidates = Dir["#{staged_root}/jdk-*.jdk"]
    odie "Expected exactly one JDK bundle in #{staged_root}, found #{candidates.length}" if candidates.length != 1

    jdk_src = Pathname(candidates.first).realpath
    odie "Staged JDK bundle #{jdk_src} is not a directory" unless jdk_src.directory?
    odie "Resolved JDK path escapes staging area" unless jdk_src.to_s.start_with?(staged_root.to_s)

    jdk_target = Pathname("/Library/Java/JavaVirtualMachines/jdk-valhalla.jdk")
    if jdk_target.exist?
      ohai "Removing existing JDK at #{jdk_target}"
      removal = system_command "/bin/rm",
                               args: ["-rf", jdk_target.to_s],
                               sudo: true
      odie "Failed to remove existing JDK at #{jdk_target}" unless removal.success?
    end

    ohai "Installing JDK Valhalla to #{jdk_target}"
    install = system_command "/usr/bin/ditto",
                             args: ["--noqtn", jdk_src.to_s, jdk_target.to_s],
                             sudo: true
    odie "Failed to install JDK to #{jdk_target}" unless install.success?
  end

  uninstall delete: "/Library/Java/JavaVirtualMachines/jdk-valhalla.jdk"
end
