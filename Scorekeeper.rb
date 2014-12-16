require 'yaml'
require './Tournament'

Shoes.app(title: "Scorekeeper - TinyTron", width: 800, height: 600, resizable: true){

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
	flow(width: 0.5, height: 0.90){
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
			#Next and Skip Button
			flow(margin_top: 10, margin_left: 20, margin_right: 20, margin_bottom: 20){
				@next = button "Next"
			}

			#When clicked, verify that each textbox has a number from 0-4. If yes, put the values into an update request and refresh.
			@next.click(){
				if(p isValidInput(@line1) && isValidInput(@line2) && isValidInput(@line3) && isValidInput(@line4))
					sendUpdateRequest()
				else
					alert("INVALID INPUT - All lines must have numbers between 0 and 4.")
				end
			}
		}
	}
	#Shows all upcoming matches
	flow(width: 0.5, height: 0.90){
		border black, strokewidth: 2.5
		@upcoming = stack(scroll: true, width: 350, height: 500)
	}

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
		end

		if(@updateDirectory == "NONE")
			alert("Please select the tournament update directory.")
			@updateDirectory = ask_open_folder()
		end

		if(@counter == 5)
			@updateCount += 1
			if populate
				@counter = 0
			else
				@updateCount -= 1
			end
		end

		@counter += 1
	end

	#Unserialize tourney data, and update the Scorekeeper UI.
	def populate

		log "Updating Iteration ##{@updateCount}"

		tourneyFile = File.open(@filePath,"r+")
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
		sanitize_players(currentMatch)

		@name1.replace(currentMatch[0])
		@name2.replace(currentMatch[1])
		@name3.replace(currentMatch[2])
		@name4.replace(currentMatch[3])

		#Populate the Upcoming Match View
		upcomingMatches = player_list[@currentIndex+1..player_list.size]
		upcomingMatchText = ""

		log "Upcoming: #{upcomingMatches}"

		@upcoming.clear

		(0...upcomingMatches.size).each do |i|
			(0...upcomingMatches[i].size).each do |j|
				upcomingMatchText = upcomingMatchText + upcomingMatches[i][j]
				if(upcomingMatches[i][j] != upcomingMatches[i].last)
					upcomingMatchText = upcomingMatchText + " vs. "
				end
			end
			@upcoming.append{
				para upcomingMatchText
			}

			upcomingMatchText.clear
		end

		return true
	end

	def sendUpdateRequest()
		p1 = [@name1.text,@line1.text.to_i]
		p2 = [@name2.text,@line2.text.to_i]
		p3 = [@name3.text,@line3.text.to_i]
		p4 = [@name4.text,@line4.text.to_i]

		updateArray = [p1,p2,p3,p4]

		log "Update Array YAML:"
		log updateArray.to_yaml

		fileName = File.new(@updateDirectory + "\\Update.#{@roomID}","w")
		YAML.dump(updateArray,fileName)
		fileName.close

		@line1.text = ""
		@line2.text = ""
		@line3.text = ""
		@line4.text = ""

		alert("Success!")
	end

	def isValidInput(value)
		check = value.text.to_i
		check.between?(0,4)
	end
}


