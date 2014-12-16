class Player
	include Comparable

	attr_reader :name,:score

	def initialize(player_name)
		@name = player_name
		@score = 0
	end

	def addScore(value)
		@score = @score + value
	end

	def inspect
		"#{name}: #{score}"
	end

	def <=>(anOther)
		@score <=> anOther.score
	end

end

#################################################################
# Represents a Tournament Management System/Database.
# Organizes Players and Matches Appropriately
################################################################
class Tournament
	attr_reader :players,:matchesA, :matchesB
	attr_accessor :indexA, :indexB

	def initialize
		@players = []
		@matchesA = []
		@matchesB = []

		@indexA = 0
		@indexB = 0
	end

	###############################################
	# Register Player with Tournament
	##############################################
	def addPlayer(player)
		players.push(player)
	end

	#############################################
	# Add to player_name's Score
	############################################
	def addScore(player_name, value)

		# Do not give points to NONE Players or Empty Players
		if player_name.empty? || player_name.include?("NONE")
			return
		end

		(0...players.size).each do |i|
			if(players[i].name == player_name)
				players[i].addScore(value)
			end
		end
		players.sort! {|x,y| y<=>x}
	end

	##########################################
	# Register Match with Tournament
	#########################################
	def addMatch(id, match)
		if id == "A"
			matchesA.push(match)
		else
			matchesB.push(match)
		end
	end
end

$INTERNAL_TOURNEY_LOG_FLAG = true

#######################################################################
# Take any NONE players (e.g. "NONE-1") and convert them to ""
# or some custom string if provided as the second argument.     
######################################################################
def sanitize_players(list, repl_str="")
	log "Sanitizing #{list} with '#{repl_str}'"
	list.select{|s| s.include? "NONE"}.each{|s| s.replace repl_str}
	log "Sanitized to #{list}"
	return list
end

##########################################################################
# Toggle Log Flag -- Either Toggle Between True and False or explicity 
# set state as argument
##########################################################################
def toggle_logging(state=nil)

	if state == nil then
		$INTERNAL_TOURNEY_LOG_FLAG = !$INTERNAL_TOURNEY_LOG_FLAG
	elsif state.is_a?(TrueClas) || state.is_a?(FalseClass)
		$INTERNAL_TOURNEY_LOG_FLAG = state
	else
		raise ArgumentError, "Bad State! Non-Boolean State Argument: #{state} => #{state.class} Class", caller
	end

	return $INTERNAL_TOURNEY_LOG_FLAG
end

#########################################################################
# Log -- Write to Console If and Only If the internal log flag is true
#########################################################################
def log(message)
	if $INTERNAL_TOURNEY_LOG_FLAG then debug(message) end
end

########################################################################
# Priority Log -- Ignore Log Flag Checks, Always Prints to Console
########################################################################
def plog(message)
	debug message
end
