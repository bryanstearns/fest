class Mailer < ActionMailer::Base
  layout 'mailer'
  add_template_helper(QuestionsHelper)
  FESTFAN = 'festfan@festivalfanatic.com'
  default from: FESTFAN

  def feedback(question)
    @question = question
    mail to: FESTFAN, subject: 'Festival Fanatic feedback received'
  end
end
