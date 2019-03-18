class AddNameAndUserToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :name, :string
    add_column :questions, :user_id, :integer

    Question.reset_column_information
    Question.all.each do |question|
      unless question.user_id?
        user = User.where(email: question.email).first
        if user
          question.user ||= user
          question.name ||= user.name
        end
      end
      question.name ||= question.email
      question.save!
    end
  end
end
