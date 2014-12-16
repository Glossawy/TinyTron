require 'yaml'
require './Tournament'

Shoes.app(title: "TinyTron - Builder", resizable: false, width: 600, height: 500) do
	# Create Text Box and Generate Button
	@text = edit_box(width: 1.0, height: 0.9)
	@list_count = 0
	@player_cache = []

	stack() do
		flow() do
			@generate = button("Generate Tournament")
			@sorter = button("Sort Current List")
			@total = para "Currently Counting #{@list_count} players"
		end
	end

	@sorter.click() do
		temp_str = ""
		@player_cache.sort_by!{|m| m.downcase}

		for name in @player_cache
			temp_str += name + "\n"
		end

		@text.text = temp_str
	end

	# On Click Event Handler
	@generate.click() do
		if confirm("Are you sure that you want to generate a tournament?")
			tourney = generateTournament
			fileName = File.open(ask_save_file, "w+")
			YAML.dump(tourney,fileName)
			fileName.close
			alert("Success!")
		end
	end

	every(1) do
		@list_count = getListSize
		@total.text = "Currently Counting #{@list_count} players"
		log "#{@list_count} -> #{@total.text}"
	end

	def generateTournament
		tourney = Tournament.new

		#Populate Players
		playerNames = @text.text.split $/
		plog "MOD #{playerNames.size % 4.0} FROM #{playerNames.size}"

		# Account for cases where we don"t have a player count that is divisible by 4
		(1..(4-playerNames.size % 4.0)).each { |x| playerNames.push "NONE-#{x}"}

		# Register with Tournament
		playerNames.each { |name| tourney.addPlayer(Player.new(name)) }

		#Build Matches
		gameCount = ask("How many games does each player get to play?").to_i
		aIndex = 0
		bIndex = 0
		games = []

		while(gameCount > 0)
			games.concat(buildMatches(playerNames.dup,4))
			gameCount -= 1
		end

		(0...games.size).each do |j|
			if j % 2 == 0
				log "A #{j} #{aIndex}"
				tourney.addMatch("A",games[j])
				aIndex += 1
			else
				log "B #{j} #{bIndex}"
				tourney.addMatch("B",games[j])
				bIndex += 1
			end
		end

		return tourney
	end

	def buildMatches(playerNames, matchSize)
		bigSet = []
		matchNumber = playerNames.size / matchSize

		matchNumber.times do
			set = []
			matchSize.times do
				if(set.size == 0)
					set.push(playerNames.first)
				else
					randI = rand(0...playerNames.size)
					set.push(playerNames[randI])
				end
				playerNames = playerNames.delete_if{|x| x == set.last}
			end
			bigSet.push(set)
		end

		if playerNames.size > 0
			bigSet.push(playerNames)
		end

		return bigSet
	end

	def getListSize
		list = @text.text.split $/

		@player_cache = list.select{|s| !s.empty?}
		return @player_cache.size
	end

end