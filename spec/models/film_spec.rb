require 'spec_helper'

describe Film do
  context "retrieving by name" do
    let(:festival) { create(:festival, :with_films) }
    subject { festival.films }

    it "returns them in sorted order" do
      subject.by_name.map(&:name).should eq(subject.map(&:name).sort)
    end
  end
end
