require 'spec_helper'

describe FilmsHelper, type: :helper do
  helper FilmsHelper
  helper Countries::Helpers

  describe "translating duration" do
    it "should use minutes for less than an hour" do
      expect(hours_and_minutes(36.minutes)).to eq("36 minutes")
    end

    it "should use hours and minutes for an hour or more" do
      expect(hours_and_minutes(97.minutes)).to eq("1 hour 37 minutes")
    end

    it "shouldn't mention minutes for even hours" do
      expect(hours_and_minutes(120.minutes)).to eq("2 hours")
    end
  end

  describe "film details" do
    let(:countries) { '' }
    let(:page_number) { nil }
    let(:festival) { double("festival", main_url: "http://example.com/") }
    let(:film) { double("film", countries: countries, countries?: countries.present?,
                                duration: 90.minutes, festival: festival,
                                page_number: page_number, page_number?: page_number,
                                url_fragment: nil) }
    it "shows duration" do
      expect(film_details(film)).to match(/1 hour 30 minutes/)
    end
    context "with countries" do
      let(:countries) { 'gb' }
      it "has flags" do
        expect(film_details(film)).to match(%r{<img alt="United Kingdom" class="flag-icon flag-icon-gb".* title="United Kingdom" />})
      end
    end
    context "with a page number" do
      let(:page_number) { 12 }
      it "includes it" do
        expect(film_details(film)).to match(/, page 12/)
      end
      context "and a url fragment, when the festival has main_url" do
        before { allow(film).to receive(:url_fragment).and_return('1234') }
        it "makes it a link" do
          expect(film_details(film, festival)).to match(%r{, <a href="http://example.com/1234"})
        end
      end
    end
  end
end
