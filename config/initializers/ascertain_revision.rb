
# "Ascertain" the revision we're running (so named so it'll come before
# the cache initializer, which uses this info).

def determine_revision
  # Note the revision number we're running, and a
  # more-informative string containing it.
  begin
    revision_path = Rails.root.join 'REVISION'
    digits = 8
    if File.exist? revision_path
      mod_date = File.mtime(revision_path)
      number = File.read(revision_path).strip[0...digits]
      extra = mod_date.strftime('%H:%M %a, %b %d %Y').gsub(' 0',' ')
    else
      number = `git log -1`.split(' ')[1][0...digits]
      extra = `git status -sb`.split("\n")[0].split(' ')[-1]
    end
  rescue
    number = '???'
    extra = ''
  end
  details = "#{Rails.env} #{number} #{extra} #{`hostname -f`.strip}"
  return number, details
end

SOURCE_REVISION_NUMBER, SOURCE_REVISION_DETAILS = determine_revision
