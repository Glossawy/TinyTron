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


class Tournament
  attr_reader :players,:matchesA, :matchesB
  attr_accessor :indexA, :indexB
  
  def initialize()
    @players = []
    @matchesA = []
    @matchesB = []
      
    @indexA = 0
    @indexB = 0
  end
  
  def addPlayer(player_name)
    players.push(player_name)
  end
  
  def addScore(player_name, value)
    for i in 0...players.size
      if(players[i].name == player_name)
          players[i].addScore(value)
      end
    end
    players.sort! {|x,y| y<=>x}
  end
  
  def addMatch(id, match)
    if id == "A" 
      matchesA.push(match)
    else matchesB.push(match)
    end
  end 
end
