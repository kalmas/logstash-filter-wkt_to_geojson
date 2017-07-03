# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "rgeo"
require "rgeo-geojson"
require "json"

class LogStash::Filters::WktToGeojson < LogStash::Filters::Base

  config_name "wkt_to_geojson"

  config :field, :validate => :string, :required => true
  config :target, :validate => :string, :default => 'geo_json'
  config :tag_on_parse_failure, :validate => :array, :default => [ '_wkt_parse_failure' ]

  public
  def register
    @parser = RGeo::WKRep::WKTParser.new()
    @encoder = RGeo::GeoJSON.coder()
  end # def register

  public
  def filter(event)

    wkt = event.get(@field)

    begin
      geo = @parser.parse(wkt)
      json = @encoder.encode(geo)
      event.set(@target, json.to_json)
    rescue Exception => e
      @logger.error('WKT Parse Error',
          :wkt => wkt, :exception => e)
      @tag_on_parse_failure.each { |tag| event.tag(tag) }
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::WktToGeojson
