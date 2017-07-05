# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/wkt_to_geojson"

describe LogStash::Filters::WktToGeojson do
  describe "Convert WKT to GeoJSON" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
            field => "geometry"
        }
      }
    CONFIG
    end

    sample("geometry" => "POLYGON ((0.0 0.0, 5.0 0.0, 5.0 5.0, 0.0 5.0, 0.0 0.0), (2.0 2.0, 2.0 3.0, 3.0 3.0, 3.0 2.0, 2.0 2.0))") do
      expect(subject.get('geo_json')).to eq("{\"type\":\"Polygon\",\"coordinates\":[[[0.0,0.0],[5.0,0.0],[5.0,5.0],[0.0,5.0],[0.0,0.0]],[[2.0,2.0],[2.0,3.0],[3.0,3.0],[3.0,2.0],[2.0,2.0]]]}")
    end
  end

  describe "Write to target field" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
          field => "geometry"
          target => "geoff_jason"
        }
      }
    CONFIG
    end

    sample("geometry" => "GEOMETRYCOLLECTION(POINT(3 5), LINESTRING(-2 0, -3 -4))") do
      expect(subject.get('geoff_jason')).to eq("{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[3.0,5.0]},{\"type\":\"LineString\",\"coordinates\":[[-2.0,0.0],[-3.0,-4.0]]}]}")
      expect(subject.get('geometry')).to eq("GEOMETRYCOLLECTION(POINT(3 5), LINESTRING(-2 0, -3 -4))")
    end
  end

  describe "Handle invalid input" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
          field => "geometry"
        }
      }
    CONFIG
    end

    sample("geometry" => "MULTIPOLYGON((()))") do
      expect(subject).to_not include("geo_json")
      expect(subject.get('geometry')).to eq("MULTIPOLYGON((()))")
      expect(subject.get('tags')).to include('_wkt_parse_failure')
    end
  end

  describe "Handle nil input" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
          field => "geometry"
          tag_on_parse_failure => [ "oppsie" ]
        }
      }
    CONFIG
    end

    sample("geometry" => nil) do
      expect(subject).to_not include("geo_json")
      expect(subject.get('geometry')).to eq(nil)
      expect(subject.get('tags')).to include('oppsie')
    end
  end

  describe "Handle absent field" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
          field => "not_a_field"
        }
      }
    CONFIG
    end

    sample("geometry" => "GEOMETRYCOLLECTION(POINT(3 5), LINESTRING(-2 0, -3 -4))") do
      expect(subject).to_not include("geo_json")
    end
  end
end
