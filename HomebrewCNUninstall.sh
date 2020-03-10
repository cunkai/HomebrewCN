#!/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby

require "English"
require "fileutils"
require "optparse"
require "pathname"

# Default options
options = {
  :force               => false,
  :quiet               => false,
  :dry_run             => false,
  :skip_cache_and_logs => false,
}

# global status to indicate whether there is anything wrong.
@failed = false

module Tty
  module_function

  def blue
    bold 34
  end

  def red
    bold 31
  end

  def reset
    escape 0
  end

  def bold(code = 39)
    escape "1;#{code}"
  end

  def escape(code)
    "\033[#{code}m" if STDOUT.tty?
  end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map { |arg| arg.gsub " ", "\\ " }.unshift(first).join(" ")
  end
end

class Pathname
  def resolved_path
    symlink? ? dirname+readlink : self
  end

  def /(other)
    self + other.to_s
  end

  def pretty_print
    if symlink?
      puts to_s + " -> " + resolved_path.to_s
    elsif directory?
      puts to_s + "/"
    else
      puts to_s
    end
  end
end

def ohai(*args)
  puts "#{Tty.blue}==>#{Tty.bold} #{args.shell_s}#{Tty.reset}"
end

def warn(warning)
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system(*args)
  return if Kernel.system(*args)

  warn "Failed during: #{args.shell_s}"
  @failed = true
end

####################################################################### script

homebrew_prefix_candidates = []

OptionParser.new do |opts|
  opts.banner = "Homebrew Uninstaller\nUsage: ./uninstall [options]"
  opts.summary_width = 16
  opts.on("-pPATH", "--path=PATH", "Sets Homebrew prefix. Defaults to /usr/local.") do |p|
    homebrew_prefix_candidates << Pathname.new(p)
  end
  opts.on("--skip-cache-and-logs", "Skips removal of HOMEBREW_CACHE and HOMEBREW_LOGS.") do
    options[:skip_cache_and_logs] = true
  end
  opts.on("-f", "--force", "Uninstall without prompting.") { options[:force] = true }
  opts.on("-q", "--quiet", "Suppress all output.") { options[:quiet] = true }
  opts.on("-d", "--dry-run", "Simulate uninstall but don't remove anything.") do
    options[:dry_run] = true
  end
  opts.on_tail("-h", "--help", "Display this message.") do
    puts opts
    exit
  end
end.parse!

if homebrew_prefix_candidates.empty? # Attempt to locate Homebrew unless `--path` is passed
  prefix =
    begin
      `brew --prefix`
    rescue
      ""
    end
  homebrew_prefix_candidates << Pathname.new(prefix.strip) unless prefix.empty?
  prefix =
    begin
      begin
        `command -v brew`
      rescue
        `which brew`
      end
    rescue
      ""
    end
  homebrew_prefix_candidates << Pathname.new(prefix.strip).dirname.parent unless prefix.empty?
  homebrew_prefix_candidates << Pathname.new("/usr/local") # Homebrew default path
  homebrew_prefix_candidates << Pathname.new("#{ENV["HOME"]}/.linuxbrew") # Linuxbrew default path
end

HOMEBREW_PREFIX = homebrew_prefix_candidates.find do |p|
  next unless p.directory?
  if p.to_s == "/usr/local" && File.exist?("/usr/local/Homebrew/.git")
    next true
  end

  (p/".git").exist? || (p/"bin/brew").executable?
end
abort "Failed to locate Homebrew!" if HOMEBREW_PREFIX.nil?

HOMEBREW_REPOSITORY = if (HOMEBREW_PREFIX/".git").exist?
  (HOMEBREW_PREFIX/".git").realpath.dirname
elsif (HOMEBREW_PREFIX/"bin/brew").exist?
  (HOMEBREW_PREFIX/"bin/brew").realpath.dirname.parent
end
abort "Failed to locate Homebrew!" if HOMEBREW_REPOSITORY.nil?

HOMEBREW_CELLAR = if (HOMEBREW_PREFIX/"Cellar").exist?
  HOMEBREW_PREFIX/"Cellar"
else
  HOMEBREW_REPOSITORY/"Cellar"
end

gitignore =
  begin
    (HOMEBREW_REPOSITORY/".gitignore").read
  rescue Errno::ENOENT
    `curl -fsSL https://raw.githubusercontent.com/Homebrew/brew/master/.gitignore`
  end
abort "Failed to fetch Homebrew .gitignore!" if gitignore.empty?

homebrew_files = gitignore.split("\n")
                          .select { |line| line.start_with? "!" }
                          .map { |line| line.chomp("/").gsub(%r{^!?/}, "") }
                          .reject { |line| %w[bin share share/doc].include?(line) }
                          .map { |p| HOMEBREW_REPOSITORY/p }
if HOMEBREW_PREFIX.to_s != HOMEBREW_REPOSITORY.to_s
  homebrew_files << HOMEBREW_REPOSITORY
  homebrew_files += %w[
    bin/brew
    etc/bash_completion.d/brew
    share/doc/homebrew
    share/man/man1/brew.1
    share/man/man1/brew-cask.1
    share/zsh/site-functions/_brew
    share/zsh/site-functions/_brew_cask
    var/homebrew
  ].map { |p| HOMEBREW_PREFIX/p }
else
  homebrew_files << HOMEBREW_REPOSITORY/".git"
end
homebrew_files << HOMEBREW_CELLAR
homebrew_files << HOMEBREW_PREFIX/"Caskroom"

unless options[:skip_cache_and_logs]
  homebrew_files += %W[
    #{ENV["HOME"]}/Library/Caches/Homebrew
    #{ENV["HOME"]}/Library/Logs/Homebrew
    /Library/Caches/Homebrew
    #{ENV["HOME"]}/.cache/Homebrew
    #{ENV["HOMEBREW_CACHE"]}
    #{ENV["HOMEBREW_LOGS"]}
  ].map { |p| Pathname.new(p) }
end

if RUBY_PLATFORM.to_s.downcase.include? "darwin"
  homebrew_files += %W[
    /Applications
    #{ENV["HOME"]}/Applications
  ].map { |p| Pathname.new(p) }.select(&:directory?).map do |p|
    p.children.select do |app|
      app.resolved_path.to_s.start_with? HOMEBREW_CELLAR.to_s
    end
  end.flatten
end

homebrew_files = homebrew_files.select(&:exist?).sort

unless options[:quiet]
  warn "This script #{options[:dry_run] ? "would" : "will"} remove:"
  homebrew_files.each(&:pretty_print)
end

if STDIN.tty? && (!options[:force] && !options[:dry_run])
  STDERR.print "是否确实要卸载Brew程序？这将删除您安装过的软件包！确认卸载输入Y回车，放弃卸载输入N回车："
  abort unless gets.rstrip =~ /y|yes/i
  STDERR.print "开始删除，遇到 Password: 请输入电脑开机密码回车"
end

ohai "Removing Homebrew installation..." unless options[:quiet]
paths = %w[Frameworks bin etc include lib opt sbin share var]
        .map { |p| HOMEBREW_PREFIX/p }
        .select(&:exist?)
        .map(&:to_s)
if paths.any?
  args = %w[-E] + paths + %w[-regex .*/info/([^.][^/]*\.info|dir)]
  if options[:dry_run]
    args << "-print"
  else
    args += %w[-exec /bin/bash -c]
    args << "/usr/bin/install-info --delete --quiet {} \"$(dirname {})/dir\""
    args << ";"
  end
  puts "Would delete:" if options[:dry_run]
  system "/usr/bin/find", *args
  args = paths + %w[-type l -lname */Cellar/*]
  if options[:dry_run]
    args << "-print"
  else
    args += %w[-exec unlink {} ;]
  end
  puts "Would delete:" if options[:dry_run]
  system "/usr/bin/find", *args
end

homebrew_files.each do |file|
  if options[:dry_run]
    puts "Would delete #{file}"
  else
    begin
      FileUtils.rm_rf(file)
    rescue => e
      warn "Failed to delete #{file}"
      puts e.message
      @failed = true
    end
  end
end

# Invalidate sudo timestamp before exiting
at_exit { Kernel.system "/usr/bin/sudo", "-k" }

def sudo(*args)
  ohai "/usr/bin/sudo", *args
  system "/usr/bin/sudo", *args
end

ohai "Removing empty directories..." unless options[:quiet]
paths = %w[bin etc include lib opt sbin share var
           Caskroom Cellar Homebrew Frameworks]
        .map { |p| HOMEBREW_PREFIX/p }
        .select(&:exist?)
        .map(&:to_s)
if paths.any?
  args = paths + %w[-name .DS_Store]
  if options[:dry_run]
    args << "-print"
  else
    args << "-delete"
  end
  puts "Would delete:" if options[:dry_run]
  sudo "/usr/bin/find", *args
  args = paths + %w[-depth -type d -empty]
  if options[:dry_run]
    args << "-print"
  else
    args += %w[-exec rmdir {} ;]
  end
  puts "Would remove directories:" if options[:dry_run]
  sudo "/usr/bin/find", *args
end

if options[:dry_run]
  exit
else
  if HOMEBREW_PREFIX.to_s != "/usr/local" && HOMEBREW_PREFIX.exist?
    sudo "rmdir", HOMEBREW_PREFIX.to_s
  end
  if HOMEBREW_PREFIX.to_s != HOMEBREW_REPOSITORY.to_s && HOMEBREW_REPOSITORY.exist?
    sudo "rmdir", HOMEBREW_REPOSITORY.to_s
  end
end

unless options[:quiet]
  if @failed
    warn "Homebrew partially uninstalled (but there were steps that failed)!"
    puts "To finish uninstalling rerun this script with `sudo`."
  else
    ohai "Homebrew uninstalled!"
  end
end

residual_files = []
residual_files.concat(HOMEBREW_REPOSITORY.children) if HOMEBREW_REPOSITORY.exist?
residual_files.concat(HOMEBREW_PREFIX.children) if HOMEBREW_PREFIX.exist?
residual_files.uniq!

unless residual_files.empty? || options[:quiet]
  puts "The following possible Homebrew files were not deleted:"
  residual_files.each(&:pretty_print)
  puts "You may wish to remove them yourself.\n"
end

exit 1 if @failed