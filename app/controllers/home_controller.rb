class HomeController < ApplicationController
  include HomeHelper
  include Spritzer

  def index
    @environments = ['re','qa','stage','prod']
    if params[:env]
      @active = params[:env]
    else
      @active = 're'
    end
    @repos = get_repos(@active)
    @config = Spritzer[@active]
  end

  def package
    @environments = ['re','qa','stage','prod']
    @active = params[:env]
    @package = params[:package]
    @packageinfo = get_package_info(@package, @active)
    @repos = get_repos(@active)
    @config = Spritzer[@active]

    respond_to do |format|
      format.html # package.html.erb
    end
  end

  def search
    @environments = ['re','qa','stage','prod']
    @active = params[:env]
    @package = params[:package]
    @config = Spritzer[@active]
    @repos = get_repos(@active)

    if params[:page]
      @active_page = params[:page]
      @count = package_count(@package, @active)
      @paginate = @count > 30
      @num_pages = @count / 30

      if @count % 30 != 0
        @num_pages += 1
      end

      if params[:op]
        if params[:op] == "l"
          @packages = get_packages_back(@package, @active, params[:ref])
        elsif params[:op] == "g"
          if @active_page == @num_pages.to_s
            @packages = get_packages_forward_last(@package, @active, params[:ref], @count % 30)
          else
            @packages = get_packages_forward(@package, @active, params[:ref])
          end
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
    @environments = ['re','qa','stage','prod']
    @active = params[:env]
    @repo = params[:repo]
    @config = Spritzer[@active]
    @repos = get_repos(@active)
    @recently_added = get_recent_packages(@repo, @active)

    respond_to do |format|
      format.html # repo.html.erb
    end
  end
end
