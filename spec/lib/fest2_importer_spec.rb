require 'spec_helper'

unless ENV["TRAVIS"]
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

  describe Fest2Importer::Importable do
    after(:each) do
      subject.fake_slug = nil
      subject.time_offset = 0.seconds
    end
    it 'stores values for faking time and slug' do
      subject.fake_slug = 'fake'
      subject.fake_slug.should eq('fake')
      subject.time_offset = 5.minutes
      subject.time_offset.should eq(5.minutes)
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
          'starts'=> Date.parse('Thu, 07 Feb 2008'),
          'ends'=> Date.parse('Sat, 23 Feb 2008'),
          'public'=>true,
          'scheduled'=>true,
          'slug_group'=>'my',
          'revised_at'=> Time.zone.parse('2008-01-05 16:37:58'),
          'created_at'=> Time.zone.parse('2008-01-04 16:37:58'),
          'updated_at'=> Time.zone.parse('2008-01-06 16:37:58'),
          'updates_url' => nil
      }
    }
    let(:new_attributes) {
      old_attributes.except('starts', 'ends', 'url',
                            'film_url_format')\
                    .merge('starts_on' => old_attributes['starts'],
                           'ends_on' => old_attributes['ends'],
                           'main_url' => old_attributes['url'],
                           'slug_group' => 'my')
    }
    subject { Fest2Importer::Festival.new(old_attributes,
                                          without_protection: true) }

    it 'creates a new festival with the right attributes' do
      -> {
        subject.import
      }.should change(Festival, :count).by(1)

      Festival.last.attributes.except('id').should eq(new_attributes)
    end
  end
end
