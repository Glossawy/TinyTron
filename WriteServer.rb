require 'yaml'
require './Tournament'

Shoes.app(title: "WriteServer - TinyTron", width: 800, height: 600, resizable: false) do


	@updateDirectory = "NONE"
	@tourneyPath = "NONE"
	@paused = false

	# Top -- System Info/Server State
	stack(height: 0.5, width: 1.0, margin: 10) do
		# Title + Server State and Button
		flow do
			@infoTitle = subtitle "System Info - Server Status: Running"
			@pauseButton = button("Toggle On/Off")
			@pauseButton.displace(40, 10)
			@pauseButton.click() do
				if(!@paused)
					@infoTitle.text = "System Info - Server Status: Paused"
					@paused = true
				else
					@infoTitle.text = "System Info - Server Status: Running"
					@paused = false
				end
			end
		end

		# System Environment Description. Basically Dumps Every System Environmental Variable
		flow(scroll: true, height: 0.8, width: 1.0, margin_bottom: 10) do
			border black, strokewidth: 2.5
			stack(scroll: true, height: 1.0, width: 1.0, margin: 10) do
				ENV.each_key do |key|
					flow(height: 20, width:1.0){
						inscription strong("#{key}:")
						inscription ENV[key]
					}
				end
			end
		end
	end

	# Bottom -- Server Starting Parameters and Cache Contents
	stack(height: 0.5, width: 1.0, margin: 10) do
		subtitle "TinyTron Server Parameters"
		flow(height: 0.8, width: 1.0) do
			border black, strokewidth: 2.5
			stack scroll: true, height: 1.0, width: 1.0, margin: 10 do
				@updateInsc = flow height: 20
				@tourneyInsc = flow height: 20
				@cacheInsc = stack margin_top: 10
			end
		end
	end

	# Should we move most of this stuff out? The only thing being done every iteration
	# is Update Processing and Param Updates
	#
	# Initialization should be done ON INITIALIZATION. Not AFTER INITIALIZATION. Not even a single second after.
	every(1) do
		# Initialize Path to Tournament File
		if(@tourneyPath == "NONE")
			alert("Please select the tournament file.")
			@tourneyPath = ask_open_file()

			plog @tourneyPath
			update_cache
		end

		# Initialize Path to Update Directory
		if(@updateDirectory == "NONE")
			alert("Please select the tournament update directory.")
			@updateDirectory = ask_open_folder()
		end

		# If not paused, check for updates and then update the GUI
		if(!@paused)
			if((val = update_check) != nil)
				process val
			end

			update_param_info
		end
	end

	#######################################################################################
	# Process Update File by ID ("A" or "B")
	#
	# Locks Update File (to prevent Client/Server Desync) and proceeds to add player scores
	# based on what numerical ranking the player was given by Scorekeeper. The index is then
	# incremented and the resuilts written out to the Tournament File.
	#
	# The Tournament File is locked for the duration of this process.
	# Raises: IOError if Update File does not exist.
	######################################################################################
	def process(id)
		if(!File.file?("#{@updateDirectory}\\Update.#{id}"))
			raise IOError, "Update for #{id} does not exist!"
		end

		yaml_file = File.open("#{@updateDirectory}\\Update.#{id}", "r+")
		yaml_data = YAML.load yaml_file
		plog "YAML Update Data:\n#{yaml_data}"

		File.open(@tourneyPath, "r+") do |f|
			@tourneyCache = YAML.load f

			(0...yaml_data.size).each do |i|
				score = 0
				case yaml_data[i][1]
					when 1
						score = 400
					when 2
						score = 300
					when 3
						score = 200
					when 4
						score = 100
				end

				@tourneyCache.addScore(yaml_data[i][0], score)
			end

			@tourneyCache.indexA = @tourneyCache.indexA + 1 if(id == "A")
			@tourneyCache.indexB = @tourneyCache.indexB + 1 if(id == "B")

			f.seek 0
			f.write @tourneyCache.to_yaml
		end

		yaml_file.close
		File.delete(yaml_file)
	end

	#######################################################################################
	# Updates Tournament Cache from File
	######################################################################################
	def update_cache(file = @tourneyPath)
		File.open(file, "r+") do |h|
			@tourneyCache = YAML.load h
		end
	end

	#######################################################################################
	# Returns the Index of the next Update to process
	# Returns nil otherwise
	######################################################################################
	def update_check
		if(File.file?("#{@updateDirectory}\\Update.A"))
			return "A"
		elsif (File.file?("#{@updateDirectory}\\Update.B"))
			return "B"
		end
	end

	#######################################################################################
	# Updates Inscriptions
	######################################################################################
	def update_param_info
		info = {"Update Dir" => @updateDirectory, "Tourney Path" => @tourneyPath, "Current Cache" => "\n#{@tourneyCache}"}

		@updateInsc.clear
		@updateInsc.append{
			inscription strong("Update Directory: ")
			inscription @updateDirectory
		}

		@tourneyInsc.clear
		@tourneyInsc.append{
			inscription strong("Tourney Path: ")
			inscription @tourneyPath
		}

		@cacheInsc.clear
		@cacheInsc.append{
			inscription strong("Cached YAML Data:"), margin_bottom: 0
			inscription @tourneyCache
		}
	end
end