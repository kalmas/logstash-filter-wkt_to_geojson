# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "rgeo"
require "rgeo-geojson"

class LogStash::Filters::WktToGeojson < LogStash::Filters::Base

  config_name "wkt_to_geojson"

  config :in_field, :validate => :string, :default => "message"
  config :out_field, :validate => :string

  public
  def register
    @parser = RGeo::WKRep::WKTParser.new()
  end # def register

  public
  def filter(event)

    if @out_field.nil?
      @out_field = @in_field
    end

    geo = @parser.parse(event.get(@in_field))
    json = RGeo::GeoJSON.encode(geo)

    event.set(@out_field, json.to_s)

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::WktToGeojson
