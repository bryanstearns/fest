class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable,
         :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  has_many :picks, dependent: :destroy

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  validates :name, :presence => true
end
