module ListenerHelper
	def send_nudge(to, content, outreach)
			 
		# set up a client to talk to the Twilio REST API 
		client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token) 
	 
		# Get user
		receiver = Roster.find_by_id(to)

		# From number
		from_number = '15126400026'

		if receiver then
			client.account.messages.create({
				:from => from_number, 
				:to => receiver.number, 
				:body => content,  
			})
		
			#log outreach
			receiver.texts.create(body: content, number: from_number, outreach: outreach)
		end
	end
end
