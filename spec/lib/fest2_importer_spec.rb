require 'spec_helper'
require 'fest2_importer'

module Fest2Importer
  class Dummy
    cattr_accessor :connection_name
    def self.establish_connection(connection_name)
      self.connection_name = connection_name
    end
    include Fest2Importer::Importable
  end
end

describe 'An importable model class' do
  subject { Fest2Importer::Dummy }

  it 'connects to the right database' do
    subject.connection_name.should eq('fest2_snapshot')
  end
end

describe 'An importable model instance' do
  subject { Fest2Importer::Dummy.new }

  it 'raises if the model class doesn\'t override #import' do
    proc { subject.import }.should raise_error(NotImplementedError)
  end
end

describe 'Importing a Festival' do
  let(:old_attributes) {
    {
        'name'=>'My Festival 2008',
        'slug'=>'my_2008',
        'location'=>'Portland, Oregon',
        'url'=>'http://myfest.example.com/',
        'film_url_format'=>'http://myfest.example.com/films/*',
        'starts'=>'Thu, 07 Feb 2008',
        'ends'=>'Sat, 23 Feb 2008',
        'public'=>true,
        'scheduled'=>true,
        'slug_group'=>'my'
    }
  }
  let(:new_attributes) {
    old_attributes.except('starts', 'ends', 'url',
                          'film_url_format', 'slug')\
                  .merge('starts_on' => old_attributes['starts'],
                         'ends_on' => old_attributes['ends'],
                         'main_url' => old_attributes['url'])
  }
  subject { Fest2Importer::Festival.new(old_attributes,
                                        without_protection: true) }

  it 'creates a new festival' do
    lambda {
      subject.import
    }.should change(Festival, :count).by(1)
  end
end
