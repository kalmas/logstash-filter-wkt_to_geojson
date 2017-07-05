Gem::Specification.new do |s|
  s.name          = 'logstash-filter-wkt_to_geojson'
  s.version       = '0.1.2'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash filter to convert WKT geography shapes to GeoJSON.'
  s.homepage      = 'https://github.com/kalmas/logstash-filter-wkt_to_geojson'
  s.authors       = ['kalmas']
  s.email         = 'kylealmas@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  s.add_dependency 'georuby', '2.5.2'

  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  
  s.add_development_dependency 'logstash-devutils', '~> 0'
end
