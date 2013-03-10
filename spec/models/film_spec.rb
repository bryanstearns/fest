require 'spec_helper'

describe Film do
  let(:festival) { create(:festival, :with_films) }

  context "retrieving by name" do
    subject { festival.films }

    it "returns them in sorted order" do
      subject.by_name.map(&:name).should eq(subject.map(&:name).sort)
    end
  end

  [:short_name, :sort_name].each do |attr|
    context "when #{attr} is not set" do
      subject { build(:film, festival: festival,
                      name: "Young Frankenstein",
                      attr => '') }
      it "defaults to the name" do
        subject.should be_valid
        subject.send(attr).should == "Young Frankenstein"
      end
    end
  end
end
