
class Game < ApplicationRecord
  belongs_to :user_white, class_name: 'User', optional: true
  belongs_to :user_black, class_name: 'User', optional: true
  has_many :pieces

  
  scope :available, -> { where(user_white_id: nil) }

  attr_accessor(:king, :king_x, :king_y)

  def piece_at(x, y)
    pieces.where(coordinate_x: x, coordinate_y: y).first
  end
  
  def populate_the_game 


    # Pawn creation for white and black player
    (0..7).each do |b|
      Pawn.create(coordinate_x: b, coordinate_y: 1, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    end

    (0..7).each do |w|
      Pawn.create(coordinate_x: w, coordinate_y: 6, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)
    end

    # King creation for white and black player
    King.create(coordinate_x: 4, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    King.create(coordinate_x: 4, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)

    # Bishop creation for white and black player
    Bishop.create(coordinate_x: 2, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Bishop.create(coordinate_x: 5, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Bishop.create(coordinate_x: 2, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)
    Bishop.create(coordinate_x: 5, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)

    # Rook creation for white and black player
    Rook.create(coordinate_x: 0, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Rook.create(coordinate_x: 7, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Rook.create(coordinate_x: 0, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)
    Rook.create(coordinate_x: 7, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)

    # Knight creation for white and black player

    Knight.create(coordinate_x: 1, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Knight.create(coordinate_x: 6, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Knight.create(coordinate_x: 1, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)
    Knight.create(coordinate_x: 6, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)

    # Queen creation for white and black player

    Queen.create(coordinate_x: 3, coordinate_y: 0, piece_color: 'black', user_id: self.user_black_id, game_id: self.id)
    Queen.create(coordinate_x: 3, coordinate_y: 7, piece_color: 'white', user_id: self.user_white_id, game_id: self.id)

  end

  def is_check?(user)
    @check_piece = nil
    if user == user_black
      @king = pieces.where(type: "King", user_id: user_black).first
      @king_x = @king.coordinate_x
      @king_y = @king.coordinate_y
      user_white.pieces.where(game: self.id).each do |piece|      
        return true if is_valid_capture_occupied?(piece) == true
      end
      return false
    end

    if user == user_white
    @king = pieces.where(type: "King", user_id: user_white).first
    @king_x = @king.coordinate_x
    @king_y = @king.coordinate_y
    
      user_black.pieces.where(game: self.id).each do |piece|
        return true if is_valid_capture_occupied?(piece) == true
      end
      
    return false
    end
  end


  def is_valid_capture_occupied?(piece)
    # puts "____#{piece.inspect}"
     if piece.type != "King"
          
          if piece.valid_move?(@king_x,@king_y) == true
            
            if piece.is_capture_valid?(@king_x,@king_y) && piece.is_occupied?(@king_x,@king_y)
              @check_piece = piece
              puts "Check piece is#{@check_piece.inspect}"
              return true
            end

          end  
        
        end
  end

  
  def checkmate?(user)
    @user = user
    if is_check?(@user) == true
    
      king_moves = [  
        [@king_x+1, @king_y+1],
        [@king_x+1, @king_y],
        [@king_x+1, @king_y-1],
        [@king_x, @king_y+1],
        [@king_x, @king_y-1],
        [@king_x-1, @king_y+1],
        [@king_x-1, @king_y],
        [@king_x-1, @king_y-1]
      ]   

      #check surrounding spaces to see if king can move to avoid checkmate      
      king_moves.each do |move|
         #is move in bounds?
        if king.boundaries(move[0], move[1]) == true
          #is space empty?
          if pieces.where(coordinate_x: move[0], coordinate_y: move[1]).first == nil 
              puts "><><#{@check_piece.inspect}"
            return false 
          end
        end
      end
      puts "checkmate!"
      return true
    else  
      puts "no way bozo!"
      return false
   end

  end
  
  
  
end
  
