require 'yaml'
require './Tournament'

Shoes.app(title: "TinyTron - Builder", width: 400, height: 300) do
    @text = edit_box(width: 1.0, height: 0.9)
    stack() do
      @generate = button("Generate Tournament")
    end
    
    @generate.click() do
      if confirm("Are you sure that you want to generate a tournament?")  
        tourney = generateTournament
        fileName = File.open(ask_save_file,"w+")
        YAML.dump(tourney,fileName)
        fileName.close 
        alert("Success!")
      end
    end
    
  def generateTournament
      tourney = Tournament.new
      #Populate Players
      playerNames = @text.text.split $/
      p "MOD #{playerNames.size % 4.0} #{playerNames.size}"
      
      #Elegant Code Duct Tape.
      if(playerNames.size % 4.0 == 1)
        playerNames.push("NONE-1")
        playerNames.push("NONE-2")
        playerNames.push("NONE-3")
      elsif(playerNames.size % 4.0 == 2)
        playerNames.push("NONE-1")
        playerNames.push("NONE-2")
      elsif(playerNames.size % 4.0 == 3)
        playerNames.push("NONE-1")
      end
      
      for i in 0...playerNames.size
        tourney.addPlayer(Player.new(playerNames[i]))
      end
      
      
      #Build Matches
      gameCount = ask("How many games does each player get to play?").to_i
      games = []
      
      for k in 0...gameCount
        games.concat(buildMatches(playerNames.dup,4))
      end
      
      p games
        
        
      aIndex = 0
      bIndex = 0
      
      p games.size
        
      for j in 0...(games.size)
        
        if j % 2 == 0
          p "A #{j} #{aIndex}"
          tourney.addMatch("A",games[j])
          aIndex = aIndex + 1
        else
          p "B #{j} #{bIndex}"
          tourney.addMatch("B",games[j])
          bIndex = bIndex + 1
        end
        
      end
      
      tourney
  end
    
  def buildMatches(playerNames, matchSize)
    bigSet = []
    matchNumber = playerNames.size / matchSize
    for i in 0...matchNumber
      set = []
      for j in 0...matchSize
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
    bigSet
  end

end