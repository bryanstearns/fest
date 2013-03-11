module BlockedEmailAddressChecks
  extend ActiveSupport::Concern

  BLOCKED_EMAIL_PATTERNS = [
      # tom.com or its subdomains
      /\@(.+\.)?tom\.com\z/,
      # yeah.net or its subdomains
      /\@(.+\.)?yeah\.net\z/,
      # anything where the second level is a number: 126.com
      /\@(.+\.)?\d+\.[^\.]+\z/,
      # anything *.ru or *.cn
      /\@.+\.(cn|ru)\z/,
      # anything with 'sex' or 'adult'
      /\@.*(adult|sex).+\z/
  ]

  def self.email_blocked?(email)
    BLOCKED_EMAIL_PATTERNS.any? {|p| p.match(email) }
  end

  included do
    validate :email_not_blocked
  end

  def email_not_blocked
    errors.add(:email,
               "cannot be used because of spam complaints; pick another.") \
      if email_blocked?
  end

  def email_blocked?
    BlockedEmailAddressChecks::email_blocked?(email)
  end
end
