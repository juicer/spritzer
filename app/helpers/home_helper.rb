module HomeHelper
  include Mongo
  include Spritzer

  def db(env)
    "Returns a MongoClient object to be used to find operations"
    return MongoClient.new(Spritzer[env]["database_host"], 27017)['pulp_database']
  end

  def get_package_info(package, env)
    fields = [ "_id", \
              "name", \
              "license", \
              "release", \
              "version", \
              "vendor", \
              "arch", \
              "buildhost", \
              "changelog", \
              "checksum", \
              "checksumtype", \
              "epoch", \
              "description", \
              "filename"]

    package_info = db(env)['units_rpm'].find({"filename" => package}, :fields => fields).to_a[0]

    # determine which repos package is in by checking the
    # repo_content_units collection for documents which match unit_id
    # to the package id
    package_info["repos"] = db(env)['repo_content_units'].find({"unit_id" => package_info["_id"], "repo_id" => Regexp.new(".*-#{env}")}, \
                                                               :fields => ["repo_id"]).to_a.collect {|repo| repo["repo_id"].gsub("-#{env}", "")}
    return package_info
  end

  def get_repos(env)
    return db(env)['repos'].find({"id" => Regexp.new(".*-#{env}")}, \
                          :fields => ["display_name"]).to_a.sort_by{|repo| repo["display_name"]}
  end

  def get_package_page(package, env, page)

    @count = db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*")}, \
                                       :fields => ["filename"]).count()
    @packages = db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*")}, \
                                          :fields => ["filename"]).sort({"filename" => 1}).skip((page.to_i-1)*30).limit(30).to_a
    return @packages.sort_by{|package| package['filename']}
  end

  def get_packages_back(package, env, less_than)
    @packages = db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*"), "filename" => {'$lt' => less_than}}, \
                               :fields => ["filename"]).sort({"filename" => -1}).limit(30).to_a
    return @packages.sort_by{|package| package['filename']}
  end

  def get_packages_forward(package, env, greater_than)
    return db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*"), "filename" => {'$gt' => greater_than}}, \
                                          :fields => ["filename"]).sort({"filename" => 1}).limit(30).to_a
  end

  def get_packages_forward_last(package, env, greater_than, last)
    if last != 0
      @packages = db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*"), "filename" => {'$gt' => greater_than}}, \
                                            :fields => ["filename"]).sort({"filename" => 1}).limit(last).to_a
    else
      @packages = db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*"), "filename" => {'$gt' => greater_than}}, \
                                            :fields => ["filename"]).sort({"filename" => 1}).limit(30).to_a
    end

    return @packages
  end

  def get_packages(package, env)
    return db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*")}, \
                                     :fields => ["filename"]).sort({"filename" => 1}).limit(30).to_a
  end

  def package_count(package, env)
    return db(env)['units_rpm'].find({"filename" => Regexp.new(".*#{package}.*")}, \
                                     :fields => ["id"]).count()
  end

  def get_recent_packages(name, env)
    package_ids = db(env)['repo_content_units'].find({"repo_id" => "#{name}-#{env}", 'unit_type_id' => 'rpm'}, :fields => ['created', 'unit_id']).sort({'created' => 1}).limit(5).to_a
    
    packages = []
    package_ids.each do |id|
      package = db(env)['units_rpm'].find({'_id' => id['unit_id']}, :fields => ['filename', 'created']).to_a[0]
      package['created'] = DateTime.parse(id['created'])
      packages.push(package)
    end

    puts packages
    
    return packages
  end
end
