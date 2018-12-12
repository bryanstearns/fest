require "spec_helper"

describe Mailer, type: :mailer do
  describe "feedback" do
    let(:question) { build(:question, name: "Bob Smith", email: "bob@example.com") }
    let(:mail) { Mailer.feedback(question) }

    it "renders the headers" do
      mail.subject.should eq("Festival Fanatic feedback received")
      mail.to.should eq([Mailer::FESTFAN])
      mail.from.should eq([Mailer::FESTFAN])
    end

    it "renders the body" do
      mail.body.encoded.should match('Feedback received from <a target="_blank" rel="noopener" href="mailto:')
    end
  end
end
