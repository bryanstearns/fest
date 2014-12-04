require 'spec_helper'

describe ScreeningsHelper, type: :helper do
  helper ScreeningsHelper
  describe 'describing other screenings' do
    [
      [0, 0, 'No other screenings.'],
      [1, 1, 'One earlier and one later screening:'],
      [2, 1, 'Two earlier and one later screening:'],
      [1, 2, 'One earlier and two later screenings:'],
      [12, 2, '12 earlier and two later screenings:']
    ].each do |earlier, later, expected|
      context "with #{earlier} earlier and #{later} later" do
        let(:earlier_doubles) { Array.new(earlier, double(starts_at: 2.days.ago)) }
        let(:later_doubles) { Array.new(later, double(starts_at: 2.days.from_now)) }
        let(:other) { earlier_doubles + later_doubles }
        it "says #{expected.inspect}" do
          helper.other_screenings_caption(Time.current, other)\
            .should == expected
        end
      end
    end
  end
end
