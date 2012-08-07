# def run_all_tests
#   print `clear`
#   puts "Tests run #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
#   test_files = `find test |grep coffee | tr "\\n" " "`
#   cleaned = test_files.split(" ").reject{|path| path["helper"]}.join(" ")
#   puts "nodeunit #{cleaned}"
#   puts `nodeunit #{cleaned}`
# end

# def run_tests(m)
#   return if m.to_s["helper"]
#   print `clear`
#   puts "Tests run @ #{m} an #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
#   puts `nodeunit #{m}`
# end

# run_all_tests
# watch("(lib)(/.*)+.coffee") { |m|
#   hit = m.to_s
#   hit.gsub!(/^lib\/alpha_simprini/, "test")
#   run_tests(hit)
# }
# watch("(test)(/.*)+.coffee") { |m| run_tests(m) }

require "rake"
load File.expand_path("./Rakefile")

def build
  Rake::Task["build"].reenable
  Rake::Task["build"].invoke
end

watch "(test)(/.*)+.coffee" do |match|
  hit = match.to_s
  puts hit
  puts hit =~ /tmp/
  return if hit["tmp"]
  puts "coffee -co tmp/#{File.dirname hit} #{hit}" 
  system "coffee -co tmp/#{File.dirname hit} #{hit}"
  build
end

watch "(src)(/.*)+.coffee" do |match|
  hit = match.to_s
  puts "coffee -co #{File.dirname hit.sub('src', 'lib')} #{hit}"
  system "coffee -co #{File.dirname hit.sub('src', 'lib')} #{hit}"
  build
end

@interrupted = false

# Ctrl-C
Signal.trap "INT" do
  if @interrupted
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5

    # run_all_tests
    @interrupted = false
  end
end
