# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/wkt_to_geojson"

describe LogStash::Filters::WktToGeojson do
  describe "Convert WKT to GeoJSON" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {}
      }
    CONFIG
    end

    sample("message" => "POLYGON ((0.0 0.0, 5.0 0.0, 5.0 5.0, 0.0 5.0, 0.0 0.0), (2.0 2.0, 2.0 3.0, 3.0 3.0, 3.0 2.0, 2.0 2.0))") do
      expect(subject).to include("message")
      expect(subject.get('message')).to eq("{\"type\"=>\"Polygon\", \"coordinates\"=>[[[0.0, 0.0], [5.0, 0.0], [5.0, 5.0], [0.0, 5.0], [0.0, 0.0]], [[2.0, 2.0], [2.0, 3.0], [3.0, 3.0], [3.0, 2.0], [2.0, 2.0]]]}")
    end
  end

  describe "Read from input field" do
    let(:config) do <<-CONFIG
      filter {
        wkt_to_geojson {
          in_field => "wkt"
        }
      }
    CONFIG
    end

    sample("wkt" => "Point(-122.1 47.2)") do
      expect(subject).to include("wkt")
      expect(subject.get('wkt')).to eq("{\"type\"=>\"Point\", \"coordinates\"=>[-122.1, 47.2]}")
    end
  end

  describe "Write to output field" do
      let(:config) do <<-CONFIG
        filter {
          wkt_to_geojson {
            out_field => "geo_json"
          }
        }
      CONFIG
      end

      sample("message" => "GeometryCollection(Point(3 5), LineString(-2 0, -3 -4))") do
        expect(subject).to include("geo_json")
        expect(subject.get('geo_json')).to eq("{\"type\"=>\"GeometryCollection\", \"geometries\"=>[{\"type\"=>\"Point\", \"coordinates\"=>[3.0, 5.0]}, {\"type\"=>\"LineString\", \"coordinates\"=>[[-2.0, 0.0], [-3.0, -4.0]]}]}")
        expect(subject.get('message')).to eq("GeometryCollection(Point(3 5), LineString(-2 0, -3 -4))")
      end
    end
end
