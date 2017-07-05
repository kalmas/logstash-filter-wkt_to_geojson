# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'geo_ruby'
require 'geo_ruby/ewk'
require 'geo_ruby/geojson'

class LogStash::Filters::WktToGeojson < LogStash::Filters::Base

  config_name "wkt_to_geojson"

  config :source, :validate => :string, :required => true
  config :target, :validate => :string, :default => 'geo_json'
  config :tag_on_failure, :validate => :array, :default => [ '_wkt_parse_failure' ]

  public
  def register
  end # def register

  public
  def filter(event)

    wkt = event.get(@source)

    begin
      factory = GeoRuby::SimpleFeatures::GeometryFactory::new()
      ewkt_parser = GeoRuby::SimpleFeatures::EWKTParser::new(factory)
      ewkt_parser.parse(wkt)

      if (factory.geometry.nil?)
        raise "Failed to parse to SimpleFeature"
      end

      event.set(@target, factory.geometry.to_json)
      factory.geometry.to_json
    rescue Exception => e
      @logger.error('WKT Parse Error',
          :wkt => wkt, :exception => e)
      @tag_on_failure.each { |tag| event.tag(tag) }
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::WktToGeojson
