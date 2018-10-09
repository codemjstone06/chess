class Piece < ApplicationRecord
  belongs_to :game , optional: true
  belongs_to :user , optional: true

  
  
  def captured?(new_x, new_y)
    target_move = Piece.where(coordinate_x: new_x, coordinate_y: new_y).first
    if defined?(target_move.user_id)
      if(target_move.user_id == self.user_id)
        raise RuntimeError
      else
        target_move.update_attributes(coordinate_x: nil, coordinate_y: nil, captured: true)
      end
    end

  end

  def is_capture_valid?(new_x, new_y)
    target_piece = Piece.where(coordinate_x: new_x, coordinate_y: new_y).first
    (!target_piece || target_piece.user == self.user) ? false : true

  end

  def move_to!(new_x, new_y)
    captured?(new_x, new_y) ? nil : update_attributes(coordinate_x: new_x, coordinate_y: new_y, move: true)
  end

  def is_occupied?(x,y)
    # search the pieces database and see if x, y are occupied 
      @piece = Piece.where(coordinate_x: x,  coordinate_y: y).present?   
  end


  def is_diagonal_move?(x_target, y_target)
    if (self.coordinate_x - x_target).abs == (self.coordinate_y - y_target).abs
      return true
    end
    false
  end

  def is_vertical_move?(x_target, y_target)
    if self.coordinate_x == x_target && self.coordinate_y != y_target
      return true
    end
    false
  end

  def is_horizontal_move?(x_target, y_target)
    if self.coordinate_x != x_target && self.coordinate_y == y_target
      return true
    end
    false
  end


# Define method using x and y target coordinates to see if move is horizontal
  def check_horizontal(x_target, y_target)
    #left to right
    if coordinate_x < x_target
      (coordinate_x+1..x_target-1).each do |x|
        return true if is_occupied?(x, y_target)
      end
        return false
    end
    #righ to left
    if x_target < coordinate_x
      (x_target+1..coordinate_x-1).each do |x|
        return true if is_occupied?(x, y_target)
      end
        return false
    end
  end

  # Define method using x and y target coordinates to see if move is vertical
  def check_vertical(x_target, y_target)
    #bottom to top
    if coordinate_y < y_target
      (coordinate_y+1..y_target-1).each do |y|
        return true if is_occupied?(x_target, y)
    end
        return false
    end
    #top to bottom
    if y_target < coordinate_y
      (y_target+1..coordinate_y-1).each do |y|
        return true if is_occupied?(x_target, y)
      end
        return false
    end

  end


 # Define method using x and y target coordinates to see if move is diaganol
  def check_diaganol(x_target, y_target)

    x = coordinate_x
    y = coordinate_y
                

    #top to bottom and left to right
    if x < x_target and y > y_target
      while x < x_target do 
        x = x + 1 
        y = y - 1
        return true if is_occupied?(x, y)
      end
    end

    #top to bottom and right to left
    if x > x_target and y > y_target
      while x > x_target do 
        x = x - 1 
        y = y - 1
        return true if is_occupied?(x, y)
      end
    end

    #bottom to top and right to left
    if x > x_target and y < y_target
      while x > x_target do 
        x = x - 1 
        y = y + 1
        
        return true if is_occupied?(x, y)
      end
    end

    #bottom to top and left to right
    if x < x_target and y < y_target
      while x < x_target do 
        x = x + 1 
        y = y + 1
        return true if is_occupied?(x, y)
      end
    end

    return false
  end
  

  def is_obstructed?(x_target, y_target)
    x_position_change = (x_target - coordinate_x).abs
    y_position_change = (y_target - coordinate_y).abs

    # is the path valid
   if x_target > 7 || x_target < 0 || y_target > 7 || y_target < 0
    raise 'Outside of bounds of game'
   end

    # is the path horizontal
    if  y_position_change == 0 && x_position_change > 0

     check_horizontal(x_target, y_target)
    
    # is the path vertical
    elsif x_position_change == 0 && y_position_change > 0

      check_vertical(x_target, y_target)

    # is the path diaganol
    elsif x_position_change == y_position_change

      check_diaganol(x_target, y_target) 

    else
      raise "Error Invalid move"
    end

  end

  def white_rook_queenside
    white_rook_queenside = Piece.where(type: "Rook", game_id: game_id, coordinate_x: 0, coordinate_y: 7, move: false)
    white_rook_queenside.present?
  end

  def white_rook_kingside
    white_rook_queenside = Piece.where(type: "Rook", game_id: game_id, coordinate_x: 7, coordinate_y: 7, move: false)
    white_rook_kingside.present?
  end

  def white_king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 7, move: false)
    white_king.present? 
  end

  def black_rook_queenside
    white_rook_queenside = Piece.where(type: "Rook", game_id: game_id, coordinate_x: 0, coordinate_y: 0, move: false)
    white_rook_queenside.present?
  end

  def black_rook_kingside
    white_rook_queenside = Piece.where(type: "Rook", game_id: game_id, coordinate_x: 7, coordinate_y: 0, move: false)
    white_rook_kingside.present?
  end

  def black_king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 0, move: false)
    white_king.present? 
  end

 
    
  # castle queenside white
  def can_castle_queenside_white?(rook_x, rook_y)
    if white_king == true && is_obstructed?(rook_x, rook_y) == false
      castle!(rook_x, rook_y)
    end
  end
  # castle kingside white
  def can_castle_kingside_white?(rook_x, rook_y)
    if white_king == true && is_obstructed?(rook_x, rook_y) == false
      castle!(rook_x, rook_y)
    end
  end
    
  # castle queenside black
  def can_castle_queenside_black?(rook_x, rook_y)
    if black_king == true && is_obstructed?(rook_x, rook_y) == false
      castle!(rook_x, rook_y)
    end
  end

  # castle kingside black
  def can_castle_kingside_black?(rook_x, rook_y)
    if black_king == true && is_obstructed?(rook_x, rook_y) == false
      castle!(rook_x, rook_y)
    end
  end
  

  def can_castle?(rook_x, rook_y) 

    if white_rook_queenside == true
      can_castle_queenside_white(rook_x, rook_y)

    elsif white_rook_kingside == true
      can_castle_kingside_white(rook_x, rook_y)

    elsif black_rook_queenside == true
      can_castle_queenside_black(rook_x, rook_y)

    elsif black_rook_kingside == true
      can_castle_kingside_black(rook_x, rook_y)

    end

    return false

  end
    
  def castle_queenside_white!(rook_x, rook_y)
    # move rook queenside
    rook_queenside_white = Piece.where(type: "Rook", coordinate_x: rook_x, coordinate_y: rook_y, game_id: game_id).first
    rook_queenside_white.update_attributes(coordinate_x: 2, coordinate_y: 7)
    # move king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 7, move: false).first
    white_king.update_attributes(coordinate_x: 1, coordinate_y: 7)
  end
        
  def castle_kingside_white!(rook_x, rook_y)
    # move rook queenside
    rook_queenside_white = Piece.where(type: "Rook", coordinate_x: rook_x, coordinate_y: rook_y, game_id: game_id).first
    rook_queenside_white.update_attributes(coordinate_x: 5, coordinate_y: 7)
    # move king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 7, move: false).first
    white_king.update_attributes(coordinate_x: 6, coordinate_y: 7)
  end
        
  def castle_queenside_black!(rook_x, rook_y)
    # move rook queenside
    rook_queenside_black = Piece.where(type: "Rook", coordinate_x: rook_x, coordinate_y: rook_y, game_id: game_id).first
    rook_queenside_black.update_attributes(coordinate_x: 0, coordinate_y: 2)
    # move king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 7, move: false).first
    white_king.update_attributes(coordinate_x: 0, coordinate_y: 1)
  end

  def castle_kingside_black!(rook_x, rook_y)
    # move rook queenside
    rook_queenside_black = Piece.where(type: "Rook", coordinate_x: rook_x, coordinate_y: rook_y, game_id: game_id).first
    rook_queenside_black.update_attributes(coordinate_x: 0, coordinate_y: 5)
    # move king
    white_king = Piece.where(type: "King", game_id: game_id, coordinate_x: 4, coordinate_y: 7, move: false).first
    white_king.update_attributes(coordinate_x: 0, coordinate_y: 6)
  end

end