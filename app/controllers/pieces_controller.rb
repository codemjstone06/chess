class PiecesController < ApplicationController

  def show
    @selected_piece = Piece.find(params[:id])
    @game = @selected_piece.game
  end

  def update
    @selected_piece = Piece.find(params[:id])
    # @selected_piece.move_to!(params[:piece][:coordinate_x].to_i, params[:piece][:coordinate_y].to_i)
    @selected_piece.move_to!(params[:coordinate_x].to_i, params[:coordinate_y].to_i)

    @game = @selected_piece.game
    redirect_to game_path(@game)
  end


  private

  def piece_params
    params.require(:piece).permit(:id, :game_id, :user_id, :type, :coordinate_x, :coordinate_y, :piece_color, :captured)
  end

end
