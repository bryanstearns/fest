class User < ActiveRecord::Base
  devise :confirmable, :database_authenticatable, :lockable,
         :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
end
