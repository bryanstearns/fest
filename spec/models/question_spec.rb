require 'spec_helper'

describe Question do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:question) }
end
