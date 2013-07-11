class CartsController < ApplicationController
  include HomeHelper
  include Spritzer
  require 'json'

  before_filter :configs, :only => [:index, :show, :create, :new, :edit]

  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @carts }
    end
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    @cart = Cart.find(params[:id])
    @manifest = JSON.parse(@cart.manifest.gsub('\'', '"'))
    @pretty = JSON.pretty_generate(@manifest)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cart }
    end
  end

  # GET /carts/new
  # GET /carts/new.json
  def new
    @cart = Cart.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cart }
    end
  end

  # GET /carts/1/edit
  def edit
    @cart = Cart.find(params[:id])
    @manifest = JSON.parse(@cart.manifest.gsub('\'', '"'))
    @repo = @manifest['repo_items'].keys[0]
    @rpms = @manifest['repo_items'][@repo].to_a
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(params[:cart])

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render json: @cart, status: :created, location: @cart }
      else
        format.html { render action: "new" }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /carts/1
  # PUT /carts/1.json
  def update
    @cart = Cart.find(params[:id])

    puts "THIS IS UPDATE LAWL"

    respond_to do |format|
      if @cart.update_attributes(params[:cart])
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_rpms
    @cart = Cart.find(params[:id])

    @rpms = []
    puts params
    params.keys.each do |key|
      if key.match('rpm') and params[key] == "1"
        @rpms.append(key)
      end
    end
    @manifest = JSON.parse(@cart.manifest.gsub('\'', '"'))
    @repo = @manifest['repo_items'].keys[0]
    @manifest['repo_items'][@repo] = @rpms

    @manifest_str = JSON.dump(@manifest)

    @cart.manifest = @manifest_str

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy

    respond_to do |format|
      format.html { redirect_to carts_url }
      format.json { head :no_content }
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
