class ListenerController < ApplicationController
	def webook
		begin
			#Capture text date from params
			body = params[:Body]
			from = params[:From].to_i.to_s
			sender = Roster.find_by_number(from)

			#Setup sentimiental with defaults
			shrink = Sentimental.new
			shrink.load_defaults
			shrink.load_senti_file('lib/assets/sentoverride.txt')
			#Use Sentimental to analyze sentiment
			sentiment = shrink.sentiment(body).to_s

			#Store to db
			if sender then
				sender.texts.create(body: body, number: from, sentiment: sentiment)
				
				#Evaluate last outreach
				last_outreach = Text.where("texts.roster_id = #{sender.id} and texts.outreach is not null").last.outreach

				#Begin response logic
				if (last_outreach == 'absence') && (sentiment == 'positive') then

					message = "I'm glad things sound alright. Did you know your grade from last week's lab assignment is available? Would you like me to tell you the results?"
					
					send_nudge(sender.id, message, "grade_result")
				
				elsif (last_outreach == 'absence') && ((sentiment == 'negative') || (sentiment == 'neutral')) then

					message = "Hmmm, it sounds like it might be helpful for me to loop in your advisor to see if we can help. Would you be alright with me notifying your advisor?"

					send_nudge(sender.id, message, "advisor")

				elsif (last_outreach == 'advisor') && (sentiment == 'positive') then

					message = "Alright, I've reached out to your advisor. They should be in contact shortly to see how we can help!"

					send_nudge(sender.id, message, "advisor_positive")

				elsif (last_outreach == 'advisor') && ((sentiment == 'negative') || (sentiment == 'neutral')) then

					message = "Okay, it sounds like I should hang tight. I'll log this conversation in your file and hold off on notifying your advisor"

					send_nudge(sender.id, message, "advisor_negative")

				elsif (last_outreach == 'grade_result') && (sentiment == 'positive') then

					message = "Your lab assignment 14 grade is 93.2%. Nice work! You were above the average of 82.7% and above the median of 81%"

					send_nudge(sender.id, message, "grade_result_positive")

				elsif (last_outreach == 'grade_result') && ((sentiment == 'negative') || (sentiment == 'neutral')) then

					message = "Hmmm, sounds like you'd rather me keep it a secret then! Alrighty!"

					send_nudge(sender.id, message, "grade_result_negative")

				elsif (last_outreach == 'grade_result_positive') || (last_outreach == 'grade_result_negative') || (last_outreach == 'advisor_negative') || (last_outreach == 'advisor_positive') then

					message = "Well, this is a little awkward; Master Michael says I'm still in training. I'll probably stop responding at this point because I no longer know how to react, but I'll pass your texts onto your advisor."

					send_nudge(sender.id, message, "ok")

				end

				#Give twilio success response
				render :nothing => true, :status => 200
			else
				render :nothing => true, :status => 202
			end

		rescue
			render :nothing => true, :status => 400
		end
	end

	def nudger
		member = Roster.find_by_id(params[:member])
		if member then 
			#message
			message = "Hey #{member.name}, I noticed you were absent from BIO-151 yesterday. Is everything okay?"
			
			#nudge
			send_nudge(params[:member], message, "absence")
			
			#success flash
			flash[:success] = "#{member.name} has been nudged!"
		else
			flash[:danger] = "Not nudgeable."
		end
		redirect_to(root_url)

	end

	def reset
		member = Roster.find_by_id(params[:member])
		if member then
			member.texts.delete_all
			flash[:success] = "#{member.name}'s text history has been reset."
		else
			flash[:danger] = "Cannot reset."
		end
		redirect_to(root_url)
	end

	def index
		@roster_array = Roster.all.to_a
	end


end
