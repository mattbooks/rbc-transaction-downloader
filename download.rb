require 'mechanize'
require 'active_support'
require 'active_support/core_ext'
require 'highline/import'

highline = HighLine.new($stdin, $stderr)

agent = Mechanize.new
page = agent.get('https://www.rbcbank.com')
page = page.links_with(text: 'RBC Bank (U.S.) Online Banking').last.click
form = page.form('rbunxcgi')
form.K1 = highline.ask('username: ')
form.Q1 = highline.ask('password: ') { |q| q.echo = false }
page = agent.submit(form, form.buttons.last)
form = page.form('continueform')
field_title = form.field_with(name: 'SIP_PVQ_ANS').node['title'].chomp
form.SIP_PVQ_ANS = highline.ask(field_title) { |q| q.echo = false }
page = agent.submit(form, form.buttons.last)
page = agent.submit(page.forms.last, page.forms.last.buttons.last)
page = page.link_with(text: 'Credit Card').click
page = page.link_with(text: 'Download My Account Activity').click
form = page.form('downloadActivityForm')
account_field = form.field_with(name: 'number')
account_option = account_field.options.detect { |f| f.text =~ /Credit Card/ }
account_field.value = account_option.value
form.field_with(name: 'fromDate').value = Time.now.to_date.last_month.beginning_of_month
form.field_with(name: 'toDate').value = Time.now.to_date.last_month.end_of_month
form.radiobutton_with(name: 'formatType', value: 'CSV').check
page = agent.submit(form, form.buttons.last)
dl_script = page.xpath('//script').detect { |s| s.content =~ /downloadFile/ }.content
dl_path = dl_script.match(/downloadFile\(\) {.*window.open\("(.*)"\)/m)[1]
puts agent.get(dl_path).content.chomp ''
