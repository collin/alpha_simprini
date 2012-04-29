abort "Use Ruby 1.9 to build Pathology" unless RUBY_VERSION["1.9"]

require 'rake-pipeline'

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

desc "Compile CoffeeScript"
task :coffeescript => :clean do
  puts "Compiling CoffeeScript"
  `coffee -co lib/ src/`
  puts "Done"
end

desc "Build Pathology"
task :dist => [:coffeescript, :strip_whitespace] do
  puts "Building Pathology..."
  build.invoke
  puts "Done"
end

desc "Clean build artifacts from previous builds"
task :clean do
  puts "Cleaning build..."
  `rm -rf ./lib/*`
  build.clean
  puts "Done"
end
