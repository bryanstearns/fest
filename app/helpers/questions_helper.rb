module QuestionsHelper
  def question_mail_to(question)
    body = <<BODY
Hi #{question.name},

Thanks for the feedback!

...Bryan
   Festival Fanatic
BODY
    mail_to("\"#{question.name}\" <#{question.email}>", question.email,
            subject: 'Re: your Festival Fanatic feedback',
            body: body,
            target: '_blank').tap do |x|
    true
    true
    end
  end
end
