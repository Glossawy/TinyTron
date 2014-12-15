require 'yaml'
require './Tournament'

Shoes.app(title: 'TinyTron - Builder', width: 400, height: 300) do
    @text = edit_box(width: 1.0, height: 0.9)

    stack() do
      @generate = button('Generate Tournament')
    end
    
    @generate.click() do
      if confirm('Are you sure that you want to generate a tournament?')
        tourney = generateTournament
        fileName = File.open(ask_save_file,"w+")
        YAML.dump(tourney,fileName)
        fileName.close 
        alert('Success!')
      end
    end
    
  def generateTournament
      tourney = Tournament.new
      #Populate Players
      playerNames = @text.text.split $/
      debug "MOD #{playerNames.size % 4.0} #{playerNames.size}"

      # Account for cases where we don't have a player count that is divisible by 4
      (1..(4-playerNames.size % 4.0)).each { |x| playerNames.push "NONE-#{x}"}

      # Register with Tournament
      playerNames.each { |name| tourney.addPlayer(Player.new name) }

      #Build Matches
      gameCount = ask('How many games does each player get to play?').to_i
      aIndex = 0
      bIndex = 0
      games = []

      while(gameCount > 0)
        games.concat(buildMatches(playerNames.dup,4))
        gameCount -= 1
      end

      (0...games.size).each do |j|
        if j % 2 == 0
          p "A #{j} #{aIndex}"
          tourney.addMatch('A',games[j])
          aIndex += 1
        else
          p "B #{j} #{bIndex}"
          tourney.addMatch('B',games[j])
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

end