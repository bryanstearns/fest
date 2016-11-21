require 'rails_helper'
require 'axlsx'

describe FfffRatingsXlsx do
  let(:festival)  { create(:festival, :with_films_and_screenings) }
  let!(:ffff_users) { create_list(:user, 2, :with_ratings, ffff: true,
                                  festival: festival) }
  let!(:non_ffff_users) { create_list(:user, 1, :with_ratings,
                                      festival: @festival) }
  let(:films) { festival.films.by_name }
  let(:workbook) { Axlsx::Workbook.new }
  let(:presenter) { FfffRatingsXlsx.new(workbook, festival) }
  subject { presenter }

  [:title, :heading, :integer, :float, :film_name].each do |style|
    it "should provide a '#{style}' style" do
      presenter.style(style).should_not be_nil
    end
  end

  it "should render both pages" do
    expect(presenter).to receive(:make_sheet).twice
    presenter.render
  end

  context "making a sheet" do
    let(:name) { "Alphabetical" }
    subject { presenter.make_sheet(name, films) }
    it "adds a sheet to the workbook" do
      expect { subject }.to change { workbook.worksheets.count }.by(1)
    end

    it "adds the title to the sheet" do
      subject['A1'].value.should ==
          "ffff AGGREGATED RATING PROJECT - PIFF " +
              "#{festival.starts_on.year - 1977} " +
              "FEBRUARY #{festival.starts_on.year}"
    end

    it "adds column headings" do
      subject['A2'].value.should == "Title"
      subject['A2:G2'].map(&:value).should == presenter.static_headings
      cleaned = subject['H2:I2'].map do |cell|
        cell.value.gsub("\n",' ')
      end
      cleaned.should == ffff_users.map(&:name).sort
    end

    it "adds film rows to the table" do
      films.each_with_index do |film, index|
        subject["A#{index + 3}"].value.should == film.name
      end
    end

    it "adds a summary row to the table" do
      subject["A#{3 + films.count + 1}"].value.should == "Total films seen:"
    end
  end
end
