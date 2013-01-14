class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable,
         :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  has_many :picks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :admin, :name, :email, :password, :password_confirmation, :remember_me,
                  as: :admin

  validates :name, :presence => true

  def subscription_for(festival_id, options={})
    festival_id = festival_id.id unless festival_id.is_a? Integer
    rel = subscriptions.where(festival_id: festival_id)
    if options[:create]
      rel.first_or_create!({ festival_id: festival_id },
                           as: :subscription_creator)
    else
      rel.first
    end
  end

  def has_screenings_for?(festival)
    picks.where(['festival_id = ? and screening_id is not null', festival.id]).any?
  end

  def has_priorities_for?(festival)
    picks.where(['festival_id = ? and priority is not null', festival.id]).any?
  end
end
