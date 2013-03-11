shared_examples 'something with an email address' do
  subject { build(described_class.name.downcase.to_sym, email: email) }

  ['foo@tom.com', 'foo@bar.tom.com', 'foo@1620.com',
   'foo@adult.net', 'foo@yeah.net', 'foo@bar.ru',
   'foo@bar.cn', 'foo@sex.com', 'foo@yeah.net'].each do |bad_email|
    context "with blocked address #{bad_email}" do
      let(:email) { bad_email }
      it 'disallows it' do
        subject.should_not be_valid
        subject.should have(1).error_on(:email)
      end
    end
  end

  ['foo@example.com', 'foo@atom.com', 'foo@tom.com.uk'].each do |good_email|
    context "with good address #{good_email}" do
      let(:email) { good_email }
      it 'allows it' do
        subject.should be_valid
        subject.should have(0).errors_on(:email)
      end
    end
  end
end
