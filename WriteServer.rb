require 'yaml'
require './Tournament'

Shoes.app(title: "WriteServer - TinyTron", width: 800, height: 600, resizable: false) do

	@updateDirectory = "NONE"
	@tourneyPath = "NONE"

	every(1) do

		if(@tourneyPath == "NONE")
			alert("Please select the tournament file.")
			@tourneyPath = ask_open_file()

			plog @tourneyPath

			File.open(@tourneyPath, "r+") do |f|
				@tourneyCache = YAML.load(f)
			end
		end

		if(@updateDirectory == "NONE")
			alert("Please select the tournament update directory.")
			@updateDirectory = ask_open_folder()
		end


		if(processUpdate("A") || processUpdate("B"))
			File.open(@tourneyPath,"w") do |h|
				h.write @tourneyCache.to_yaml()
			end
		end

	end

	def processUpdate(id)

		if(File.file?("#{@updateDirectory}\\Update.#{id}"))
			yamlData = File.open("#{@updateDirectory}\\Update.#{id}", "r+")
			updateData = YAML.load(yamlData)
			plog "YAML Update Data:\n#{updateData}"

			(0...updateData.size).each do |i|

				case updateData[i][1]
					when 1
						score = 400
					when 2
						score = 300
					when 3
						score = 200
					when 4
						score = 100
					else score = 0
				end

				@tourneyCache.addScore(updateData[i][0],score)
			end

			@tourneyCache.indexA = @tourneyCache.indexA + 1 if(id == "A")
			@tourneyCache.indexB = @tourneyCache.indexB + 1 if(id == "B")

			yamlData.close()
			File.delete("#{@updateDirectory}\\Update.#{id}")
			return true
		end

		return false
	end

end