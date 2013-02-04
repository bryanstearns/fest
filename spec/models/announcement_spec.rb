require 'spec_helper'

describe Announcement do
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:contents) }
end
