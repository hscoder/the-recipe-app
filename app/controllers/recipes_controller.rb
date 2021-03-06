class RecipesController < ApplicationController
  before_action :logged_in_user, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    if params[:user_id] && !User.exists?(params[:user_id])
      flash[:danger] = "User not found!"
      redirect_to users_path
    else
      @recipe = Recipe.new(user_id: params[:user_id])
      3.times do
        @recipe.ingredients.build
      end
      3.times do
        @recipe.instructions.build
      end
    end
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      flash[:success] = "Recipe created!"
      redirect_to user_recipe_path(@recipe.user, @recipe)
    else
      render :new
    end
  end

  def edit
    if params[:user_id]
      user = User.find_by(id: params[:user_id])
      if user.nil?
        flash[:danger] = "User not found!"
        redirect_to to users_path
      else
        @recipe = user.recipes.find_by(id: params[:id])
        redirect_to user_recipes_path(user), alert: "Recipe not found!" if @recipe.nil?
      end
    end
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update_attributes(recipe_params)
      flash[:success] = "Recipe updated!"
      redirect_to recipe_path(@recipe)
    else
      render :edit
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:danger] = "Recipe deleted!"
    redirect_to user_recipes_path(@recipe.user)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :description, :user_id, instructions_attributes: [:content], ingredient_ids: [], ingredients_attributes: [:name], category_ids: [], categories_attributes: [:name])
  end
end
