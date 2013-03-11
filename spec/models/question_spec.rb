require 'spec_helper'
require 'support/shared_blocked_email_address_examples'

describe Question do
  it_behaves_like "something with an email address"

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:question) }
end
