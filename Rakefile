require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = './test/**/*_test.rb'
end

desc "Update bundled certs"
task :update_certs do
  require "faraday"

  fetch_file "https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt",
    File.expand_path("../lib/data/ca-certificates.crt", __FILE__)
end

desc "Update OpenAPI specification"
task :update_spec do
  require "faraday"

  ["fixtures.json", "fixtures.yaml", "spec.json", "spec.yaml"].map { |file|
    Thread.new do
      fetch_file "https://raw.githubusercontent.com/stripe/openapi/master/spec/#{file}",
        File.expand_path("../spec/#{file}", __FILE__)
    end
  }.map { |t| t.join }
end

#
# helpers
#

def fetch_file(url, dest)
  File.open(dest, 'w') do |file|
    resp = Faraday.get(url)
    unless resp.status == 200
      abort("bad response when fetching: #{url}\n" \
        "Status #{resp.status}: #{resp.body}")
    end
    file.write(resp.body)
    puts "Successfully fetched: #{url}"
  end
end
