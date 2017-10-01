require 'capybara'
require 'capybara/dsl'
require 'securerandom'

session = Capybara::Session.new(:selenium)

argument = ARGV[0]
usersNumber = argument.to_i

for i in 0..usersNumber-1 do

  session.visit "http://post-shift.ru/api.php?action=new"

  newEmailPage = session.html

  email = newEmailPage[/#{"Email: "}(.*?)#{"Key:"}/m, 1]
  key = newEmailPage[/#{"Key: "}(.*?)#{"</pre>"}/m, 1]

  username = SecureRandom.hex(8)
  password = SecureRandom.hex(8)

  session.visit "https://dev.by/registration/"

  session.fill_in('user_username', with: username)
  session.fill_in('user_email', :with  => email)
  session.fill_in('user_password', :with => password)
  session.fill_in('user_password_confirmation', :with => password)
  session.check('user_agreement')
  session.find('input[name="commit"]').click

  if session.first('.block-alerts') == nil
    puts "Unable to register"
    session.visit "http://post-shift.ru/api.php?action=delete&key=" + key
    break
  end

  devLetterPage = ""
  loop do
    sleep 3
    session.visit "http://post-shift.ru/api.php?action=getmail&key=" + key + "&id=1"
    devLetterPage = session.html
    break if devLetterPage != "<html><head></head><body>Error: Letter not found.</body></html>"
  end

  link = devLetterPage[/#{"n=\"3D"}(.*?)#{"\"><\/h"}/m, 1]

  session.visit "https://dev.by/confirmation?confirmation_token=" + link

  if session.first('.block-alerts') == nil
    puts "Unable to confirm registration"
  else
    puts username + " : " + password
  end

  session.visit "http://post-shift.ru/api.php?action=delete&key=" + key

end










