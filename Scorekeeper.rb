require 'yaml'
require './Tournament'

Shoes.app(title: "Scorekeeper - TinyTron", width: 800, height: 600, resizable: false){

	@setUp = false
	@filePath = "NONE"
	@updateDirectory = "NONE"
	@roomID = "NONE"

	@currentIndex = 0

	@updateCount = 0
	@counter = 5

	#Information Panel
	flow(width: 1.0, height: 0.10){
		background white
		@titleID = title
	}

	#Shows the current match.
	flow(width: 0.35, height: 0.90){
		border black, strokewidth: 2.5
		stack(){
			flow(margin_top: 20, margin_left: 20, margin_right: 20, margin_bottom: 20){
				#Players and the input boxes for their placing
				flow(){
					@line1 = edit_line(width: 50)
					@name1 = para "Player1"
				}
				flow(){
					@line2 = edit_line(width: 50)
					@name2 = para "Player2"
				}
				flow(){
					@line3 = edit_line(width: 50)
					@name3 = para "Player3"
				}
				flow(){
					@line4 = edit_line(width: 50)
					@name4 = para "Player4"
				}
			}
			#Next Button
			flow(margin: 20, margin_top: 10){
				@next = button "Submit & Move To Next Match"
			}

			flow(margin_top: 10, margin_left: 50) {
				@trunc_last_names = check;
				@trunc_last_names.checked = true
				para "Truncate Last Names"
			}

			@trunc_last_names.click() do
				populate
			end

			#When clicked, verify that each textbox has a number from 0-4. If yes, put the values into an update request and refresh.
			@next.click(){
				if(p isValidInput(@line1) && isValidInput(@line2) && isValidInput(@line3) && isValidInput(@line4))
					send_update_request()
				else
					alert("INVALID INPUT - All lines must have numbers between 0 and 4.")
				end
			}
		}
	}
	#Shows all upcoming matches
	flow(width: 0.65, height: 0.90) do
		border black, strokewidth: 2.5
		@upcoming = stack(scroll: true, width: 1.0, height: 1.0)
	end

	# See WriteServer.rb for Dissent
	every(1) do
		if(@roomID == "NONE")
			while(!(@roomID == "A" || @roomID == "B"))
				@roomID = ask("Please enter the Room ID (A or B)").upcase
			end
			@titleID.replace(" #{@roomID}")
		end

		if(@filePath == "NONE")
			alert("Please select the tournament file.")
			@filePath = ask_open_file()
			populate
		end

		if(@updateDirectory == "NONE")
			alert("Please select the tournament update directory.")
			@updateDirectory = ask_open_folder()
		end

		if(@counter >= 5)
			@updateCount += 1
			if populate
				@counter = 0
			else
				@updateCount -= 1
			end
		end

		@counter += 1
	end

	# Deserialize tourney data, and update the Scorekeeper UI.
	def populate
		log "Updating Iteration ##{@updateCount}"

		tourneyFile = File.open(@filePath,"r")
		tourney = YAML.load(tourneyFile)
		tourneyFile.close

		#Get Current Index and a List of Players for the current room.

		if(@roomID == "A")
			@currentIndex = tourney.indexA
			player_list = tourney.matchesA
		else
			@currentIndex = tourney.indexB
			player_list = tourney.matchesB
		end

		log "Cur Index: #{@currentIndex}"
		log "Player List Size: #{player_list.size}"

		#Update the Current Match View
		if(@currentIndex >= player_list.size)
			alert("Match Queue is now Empty. Exiting Scorekeeper. Have a nice day :D")
			exit()
		end


		currentMatch = player_list[@currentIndex]
		sanitize_players(currentMatch, "N/A")

		@name1.replace(currentMatch[0])
		@name2.replace(currentMatch[1])
		@name3.replace(currentMatch[2])
		@name4.replace(currentMatch[3])

		#Populate the Upcoming Match View
		upcomingMatches = player_list[@currentIndex+1..player_list.size]
		log "Upcoming: #{upcomingMatches}"
		@upcoming.clear

		# TODO Sanitize to upcomingMatches.each
		(0...upcomingMatches.size).each do |i|
			upcomingMatchText = ""

			sanitize_players(upcomingMatches[i])
			(0...upcomingMatches[i].size).each do |j|
				if upcomingMatches[i][j].strip.empty? then
					if(!(upcomingMatches[i][j] == upcomingMatches[i].last || upcomingMatches[i][j+1].strip.empty?) && (j > 0 && !upcomingMatchs[i][j-1].strip.empty?))
						upcomingMatchText = upcomingMatchText + " vs. "
					end
					next
				end

				upcomingMatchText = upcomingMatchText + trim_name(upcomingMatches[i][j], @trunc_last_names.checked?)

				if(!(upcomingMatches[i][j] == upcomingMatches[i].last || upcomingMatches[i][j+1].strip.empty?))
					upcomingMatchText = upcomingMatchText + " vs. "
				end
			end
			@upcoming.append{
				para upcomingMatchText, margin: 10, margin_right: 15, size: "xx-small"
			}
		end

		return true
	end

	#######################################################################################
	# Extracts User Information, writes into an Array and then writes that out to a YAML file
	#
	# This will block while the last Update File still exists
	######################################################################################
	def send_update_request()
		p1 = [@name1.text,@line1.text.to_i]
		p2 = [@name2.text,@line2.text.to_i]
		p3 = [@name3.text,@line3.text.to_i]
		p4 = [@name4.text,@line4.text.to_i]

		updateArray = [p1,p2,p3,p4]

		log "Update Array YAML:"
		log updateArray.to_yaml


		while(File.file?(@updateDirectory + "\\Update.#{@roomID}"))
			sleep 1
		end

		fileName = File.open(@updateDirectory + "\\Update.#{@roomID}","w")
		YAML.dump(updateArray,fileName)
		fileName.close

		@line1.text = ""
		@line2.text = ""
		@line3.text = ""
		@line4.text = ""

		alert("Success!")
	end

	#######################################################################################
	# Trims every word except for the first in any string. Such That:
	# 'Foo Bar' becomes 'Foo B.'
	# 'Fizz Buzz FizzBuzz' becomes 'Fizz B. F.'
	######################################################################################
	def trim_name(name, bool_check=true)
		if !bool_check then return name end

		new_name = ""
		bits = name.split ' '

		bits.each do |part|
			if(part == bits.first)
				new_name = part
			else
				new_name += " #{part.slice(0).upcase}."
			end
		end

		return new_name
	end

	def isValidInput(value)
		if value.text.empty? then return false end

		check = value.text.to_i
		check.between?(0,4)
	end
}


