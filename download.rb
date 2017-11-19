require 'mechanize'
require 'active_support'

USERNAME = 'todo'
PASSWORD = 'todo'
CHALLENGES = {
  '1': 'todo',
  '2': 'todo',
  '3': 'todo'
}

agent = Mechanize.new
page = agent.get('https://www.rbcbank.com')
page = page.links_with(text: 'RBC Bank (U.S.) Online Banking').last.click
form = page.form('rbunxcgi')
form.K1 = USERNAME
form.Q1 = PASSWORD
page = agent.submit(form, form.buttons.last)
form = page.form('continueform')
field_title = form.field_with(name: 'SIP_PVQ_ANS').node['title']
challenge_num = field_title.match(/password (\d+)/)[1]
form.SIP_PVQ_ANS = CHALLENGES[challenge_num]
page = agent.submit(form, form.buttons.last)
page = agent.submit(page.forms.last, page.forms.last.buttons.last)
page = page.link_with(text: 'Credit Card').click
page = page.link_with(text: 'Download My Account Activity').click
form = page.form('downloadActivityForm')
account_field = form.field_with(name: 'number')
account_option = account_field.options.detect { |f| f.text =~ /Credit Card/ }
account_field.value = account_option.value
page = agent.submit(form, form.buttons.last)
dl_script = page.xpath('//script').detect { |s| s.content =~ /downloadFile/ }.content
dl_path = dl_script.match(/downloadFile\(\) {.*window.open\("(.*)"\)/m)[1]
puts page.get(dl_path).content
