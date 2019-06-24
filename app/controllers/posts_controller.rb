class PostsController < ApplicationController
  include ControllerSecurity

  before_action :set_post, only: [:show, :show_external, :edit, :update, :destroy, :save_for_later]
  before_action :only_admin, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.order(published: :desc).paginate page: params[:page], per_page: 50
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  def feed
    request.format = :rss
    @posts = Post.order(published: :desc).first(10)
    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  def show_external
    @post.update(views: @post.views + 1)
    render layout: false
  end

  def show_by_slug
    @post = Post.where(slug: params[:slug]).first
    if @post
      @post.update(views: @post.views + 1)
      @is_article = true
      @meta_article_section = @post.source.name
      @meta_article_published_time = @post.published.iso8601
      @meta_description = @post.clean_content[0..200]
      @meta_title = "#{@post.title}#{ ' - ' + @post.source.name unless @post.internal?} - FBA Digest"
      @meta_image = @post.final_image_url
      @has_footer = true
      @original_url = request.original_url
      commontator_thread_show(@post)
    else
      render_not_found
    end
  end

  def save_for_later
    if current_user
      if @post.is_saved_by?(current_user)
        @post.saved_posts.where(user_id: current_user.id).first.destroy
      else
        @post.saved_posts.create(user_id: current_user.id)
      end
      if current_user.has_saved_posts?
        render json: {status: true}
      else
        render json: {status: false}
      end
    else
      render json: {status: false}
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        Rails.cache.delete('posts')
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        Rails.cache.delete('posts')
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content, :slug, :category_id, :source_id, :external_url, :image_url, :published)
    end
end
