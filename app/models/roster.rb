class Roster < ActiveRecord::Base
	has_many(:texts)
end
