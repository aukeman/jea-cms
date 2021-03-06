module JeaCmsImpl

  @@TAG_REGEXP = /{{{([^}]+)}}}/

  def JeaCmsImpl.sub( str, subs )

    mutable_subs=subs.clone
    mutable_subs.default=''

    mutable_str=str.clone
    
    tags=str.scan(@@TAG_REGEXP).map {|m| m[0].strip }.select {|s| ! s.empty?}

    ([''] + tags).each do |tag|

      tag_sub=/{{{\s*#{tag}\s*}}}/

      if File.exist? tag
        replacement=JeaCmsImpl.sub_file_contents tag, mutable_subs
      elsif tag.include? File::SEPARATOR
        replacement=''
      else
        replacement=mutable_subs[tag]
      end

      mutable_str.gsub! tag_sub, replacement
    end

    mutable_str
  end

  def JeaCmsImpl.sub_file_contents( path, subs )

    File.open(path) do |f|
      f.map {|l| JeaCmsImpl.sub(l, subs)}.join
    end

  end


end
