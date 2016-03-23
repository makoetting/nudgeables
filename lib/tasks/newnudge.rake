namespace :nudge do

	task :new => :environment do
		account_sid = 'AC66da300635ff9cda0036591fea72289b' 
		auth_token = '7a6bf3fe25b32ce52be9f6d81454bd67' 
	 
		# set up a client to talk to the Twilio REST API 
		@client = Twilio::REST::Client.new(account_sid, auth_token) 
	 
		@client.account.messages.create({
			:from => '+15126400026', 
			:to => '2108442272', 
			:body => 'Hey there',  
		})
	end

end
