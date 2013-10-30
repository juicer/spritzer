class HomeController < ApplicationController
  include HomeHelper
  include Spritzer

  before_filter :configs

  def index
    @recently_added = get_recent_packages("", @active)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def package
    @package = params[:package]
    @packageinfo = get_package_info(@package, @active)
    respond_to do |format|
      format.html # package.html.erb
    end
  end

  def search
    @package = params[:package]
    if params[:page]
      @active_page = params[:page]
      @count = package_count(@package, @active)
      @paginate = @count > 30
      @num_pages = @count / 30

      if @count % 30 != 0
        @num_pages += 1
      end

      if params[:op]
        # Less than
        if params[:op] == "l"
          @packages = get_packages_back(@package, @active, params[:ref])
        # Greater than
        elsif params[:op] == "g"
          if @active_page == @num_pages.to_s
            @packages = get_packages_forward_last(@package, @active, params[:ref], @count % 30)
          else
            @packages = get_packages_forward(@package, @active, params[:ref])
          end
        # A specific page
        elsif params[:op] == 'p'
          @packages = get_package_page(@package, @active, params[:page])
        else
          @error = true
        end
      else
        @packages = get_packages(@package, @active)
      end
    end

    respond_to do |format|
      format.html # search.html.erb
    end
  end

  def repo
    @repo = params[:repo]
    @recently_added = get_recent_packages(@repo, @active)
    respond_to do |format|
      format.html # repo.html.erb
    end
  end

  private
  def configs
    @environments = Spritzer.keys
    if params[:env]
      @active = params[:env]
    else
      @active = @environments[0]
    end
    @repos = get_repos(@active)
    @config = Spritzer[@active]
  end
end
