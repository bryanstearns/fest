
# "Ascertain" the revision we're running (so named so it'll come before
# the cache initializer, which uses this info).

def determine_revision
  # Note the revision number we're running, and a
  # more-informative string containing it.
  number = `git log -1`.split(' ')[1][0...8] rescue '???'
  details = "#{Rails.env} #{number} #{`hostname -f`.strip}"
  return number, details
end

SOURCE_REVISION_NUMBER, SOURCE_REVISION_DETAILS = determine_revision
