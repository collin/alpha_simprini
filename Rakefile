abort "Use Ruby 1.9 to build Alpha Simprini" unless RUBY_VERSION["1.9"]

require 'rake-pipeline'
require 'pathology-rake'
require 'colored'
require 'github_uploader'

def done
  puts "Done".green
end

def err(*args)
  STDERR.puts(*args)
end

def build
  Rake::Pipeline::Project.new("Assetfile")
end

def doc_build
  Rake::Pipeline::Project.new("Assetfile-docs")
end

desc "Strip trailing whitespace for CoffeeScript files in packages"
task :strip_whitespace do
  Dir["{src,test}/**/*.coffee"].each do |name|
    body = File.read(name)
    File.open(name, "w") do |file|
      file.write body.gsub(/ +\n/, "\n")
    end
  end
end

desc "Compile CoffeeScript..."
task :coffeescript do
  puts "Compiling CoffeeScript"
  `coffee -co lib/ src/`
  `coffee -co tmp/test test/`
  done
end

desc "Build Alpha Simprini Distribution"
task :dist => [:coffeescript, :build] do
end

desc "Build Alpha Simprini"
task :build do
  puts "Building Alpha Simprini..."
  build.invoke
  done
end

desc "Clean build artifacts from previous builds"
task :clean do
  puts "Cleaning build..."
  `rm -rf ./lib/*`
  build.clean
  done
end

desc "upload versions"
task :upload => :test do
  load "./version.rb"
  uploader = GithubUploader.setup_uploader
  # TODO: release a raw distribution
  # GithubUploader.upload_file uploader, "Alpha Simprini-#{AS_VERSION}.js", "Alpha Simprini #{AS_VERSION}", "dist/alpha_simprini.js"
  GithubUploader.upload_file uploader, "alpha_simprini-#{AS_VERSION}-spade.js", "Alpha Simprini #{AS_VERSION} (minispade)", "dist/alpha_simprini-spade.js"
  GithubUploader.upload_file uploader, "alpha_simprini-#{AS_VERSION}.html", "Alpha Simprini #{AS_VERSION} (html_package)", "dist/alpha_simprini.html"

  # GithubUploader.upload_file uploader, 'Alpha Simprini-latest.js', "Current Alpha Simprini", "dist/alpha_simprini.js"
  GithubUploader.upload_file uploader, 'alpha_simprini-latest-spade.js', "Current Alpha Simprini (minispade)", "dist/alpha_simprini-spade.js"
end

desc "Create json document object"
task :doc do
  puts "Building Alpha Simprini Docs".blue
  doc_build.invoke
  done
end

task :phantomjs do
  unless system("which phantomjs > /dev/null 2>&1")
    abort "PhantomJS is not installed. Download from http://phantomjs.org"
  end
end

desc "Install development dependencies with hip"
task :vendor => :dist do
  system "hip install --file=dist/alpha_simprini.html --out=./vendor --dev"
end

def test_url(tests)
  url = "file://localhost#{File.dirname(__FILE__)}/test/index.html"
  files = Dir["tmp/test/**/*.js"]
  if tests == :all
    files.reject! {|file| file[/helper\.js/]}
  else
    files = Dir["tmp/test/**/*.js"]
    files = files.find_all do |test|
      test[tests]
    end
  end
  url += "?tests=#{files.join ','}"

  url += "&debug=1" if ENV["DEBUG"]
  url
end

def exec_test(tests=:all)
  cmd = %|phantomjs ./test/qunit/run-qunit.js "#{test_url(tests)}"|

  # Run the tests
  err "Running tests"
  err cmd
  
  if success = system(cmd)
    err "Tests Passed".green
  else
    err "Tests Failed".red
    exit(1)
  end 
end

task :exec_test, [:tests] do |t, args|
  exec_test(args[:tests])
end

task :open_test, [:tests] do |t, args|
  tests = args[:tests] || :all
  system %|echo "#{test_url(tests)}" \|pbcopy|
  puts "url for tests is now in your clipboard".green
end

desc "Run tests with phantomjs"
task :test, [:tests] => [:phantomjs, :dist, :vendor] do |t, args|
    exec_test(args[:tests] || :all)
end

desc "tag/upload release"
task :release, [:version] => [:clean, :test] do |t, args|
  unless args[:version] and args[:version].match(/^[\d]+\.[\d]+\.[\d].*$/)
    raise "SPECIFY A VERSION curent version: #{AS_VERSION}"
  end
  File.open("./version.rb", "w") do |f| 
    f.write %|AS_VERSION = "#{args[:version]}"|
  end

  system "git add version.rb"
  system "git commit -m 'bumped version to #{args[:version]}'"
  system "git tag #{args[:version]}"
  system "git push origin master"
  system "git push origin #{args[:version]}"
  Rake::Task[:upload].invoke
end

SourceFiles = FileList[File.expand_path("src/**/*.coffee")]

CLASS_FILTER = /^([\w+\.?]+) = ([\w+\.?]+).extend.+$/
X_CLASS_FILTER = /^([\w+\.?]+)\._class "([\w]+)", ([\w+\.?]+), .+$/
MODULE_FILTER = /^([ ]*?)module ([\w+\.?]+)[ ]*?$/

desc "upgrade syntax to newer ruby like syntax"
file :rewrite_alpha_simprini_ruby_modules, SourceFiles do |t|
  SourceFiles.each do |file|
    content = File.open(file).read
    content.gsub!(CLASS_FILTER) do |match|
      print "."
      name = $2.split(".")
      unless name.length > 1
        STDERR.puts "Cannot define class outside a namespace #{$2} \n  @ #{input.fullpath}"
      end
      extender = if $2 && $2 != "Pathology.Object"
        " < #{$2}"
      else
        ""
      end

      puts %|class #{$1}#{extender}\n|
    end

    content.gsub!(X_CLASS_FILTER) do |match|
      print "."
      extender = if $3 && $3 != "Pathology.Object"
        " < #{$3}"
      else
        ""
      end
      puts %|class #{$1}.#{$2}#{extender}\n|
    end

    # content.gsub!(MODULE_FILTER) do
    #   print "."
    #   name = $2.split(".")
    #   if name.length == 1
    #     puts %|#{$1}this.#{$2} = Pathology.Namespace.new "#{$2}"\n|
    #   else
    #     key = name.pop
    #     puts %|#{$1}#{name * '.'}._module "#{key}", ({delegate, include, def, defs}) ->\n|
    #   end
    # end

    File.open(file, "w+") do |handle|
      handle.write content
    end
  end
end
