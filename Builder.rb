require 'yaml'
require './Tournament'
require './ListLoader'

Shoes.app(title: "TinyTron - Builder", resizable: false, width: 650, height: 500) do
	# Create Text Box and Generate Button
	@text = edit_box(width: 1.0, height: 0.9)
	@list_count = 0
	@player_cache = []

	stack() do
		flow() do
			@generate = button("Generate Tournament")
			@sorter = button("Sort Current List")
			@loader = button("Load From File")
			@total = para "#{@list_count} Players"
		end
	end

	####################################################################
	# Load List of Players from Either a CSV or standard text file
	####################################################################
	@loader.click() do
		path = ask_open_file
		tmp_str = ""

		if path.downcase.include? ".csv"
			loader = CSVLoader.new
		elsif path.downcase.include? ".yml"
			loader = YAMLLoader.new
		else
			loader = LineLoader.new
		end

		log "Loading using LoaderType #{loader.get_list_type} from file at #{path}"

		loader.load_list(path)
		loader.list.each { |e| tmp_str += "#{e.strip}\n"}

		@text.text = tmp_str
	end

	#######################################################################################
	# Sort Current List, Alternate between A-Z Sort and Z-A Sort (If Already A-Z)
	# Although the extra sort for comparison may be slightly more expensive, ideally
	# it will run in pretty close to O(N) time if already sorted.
	######################################################################################
	@sorter.click() do
		temp_str = ""
		equal_cache = true

		# Sort Player Cache and return as new array to temp_cache, check for array equality
		temp_cache = @player_cache.sort {|x, y| x.downcase <=> y.downcase}
		(0...temp_cache.size).each do |i|
			if temp_cache[i] != @player_cache[i]
				equal_cache = false
				break
			end
		end

		# If @player_cache was not already sorted, replace it with the sorted cache
		# If @player_cache was sorted, sorted in place in order of Z-A
		if !equal_cache
			@player_cache = temp_cache
		else
			@player_cache.sort!{|x, y| y.downcase <=> x.downcase}
		end

		# Create one String and set text in EditText
		@player_cache.each do |name|
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

	# Every 1 Second
	every(1) do
		@list_count = getListSize
		@total.text = "#{@list_count} Players"
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