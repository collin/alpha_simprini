files = Dir["test/**/*.coffee"]
for file in files
  content = open(file).read

  new_content = content.
                gsub(': (test) ', ', ').    # there is no test in qunit
                gsub('test.', '').          # but the api is the same
                gsub(/done\(\)\n?/, '').    # only you never call done
                gsub(/^[ ]+\"/, 'test "')   # and each test goes into the test method

  File.open file, "w" do |file|
    file.write new_content
  end

  puts file
end
