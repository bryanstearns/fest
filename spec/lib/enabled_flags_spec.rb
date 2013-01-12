require 'spec_helper'
require 'enabled_flags'

describe EnabledFlags do
  after(:all) do
    subject.set_enabled_value(:changing, true)
  end

  it "should default to true" do
    subject.enabled?(:nonexistant).should eq(true)
  end

  it "should let me set and test a condition" do
    subject.enabled?(:changing).should eq(true)
    subject.set_enabled_value(:changing, false)
    subject.enabled?(:changing).should eq(false)
  end

  it "should complain if I set a non-boolean value" do
    expect { subject.set_enabled_value(:squirrel, :nuts) }\
           .to raise_error(ArgumentError)
  end
end
