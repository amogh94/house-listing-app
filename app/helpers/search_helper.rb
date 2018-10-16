module SearchHelper

  @isSearch = false
  @isBrowse = false
  @searchKeywords = ""
  @result = []

  def get_house_attribute_map
    return ({"a":"sq_footage","b":"floors","c":"basement","d":"company_id","e":"realtor_id","f":"list_price","g":"style"})
  end

  def get_filter_alphabet_by_value(attributeValue)
    attributeKey = get_house_attribute_map.select{|key,value| value == attributeValue.to_s}
    return attributeKey.keys[0]
  end

  def get_house_attributes_having_range
    return ['a','b','f']
  end

  def get_search_href(keyword,params)
    keyword = keyword.gsub(/[.\/,&()\"\']/, '').gsub(/[\s\-]+/, '-')
    # params = {"basement":1, "realtor_id":2}
    href_parts = []
    if(!params.nil? && params.count > 0)
      url_parts = get_search_or_browse_url_parts(params)
      filter_values = url_parts[:words].join("+")
      filter_alphabets = url_parts[:alphabets].join("")
    else
      filter_values = ""
      filter_alphabets = ""
    end
    keyword.gsub!(" ","-")
    filter_alphabets = get_search_constant+filter_alphabets
    href_parts.push("/houses")

    if(filter_values.length > 0)
      filter_values = filter_values+"+"+keyword
    else
      filter_values = keyword
    end
    href_parts.push(filter_values)
    href_parts.push(filter_alphabets)
    href = href_parts.join("+")
    return href
  end

  def get_browse_href(params)
    href_parts = []
    url_parts = get_search_or_browse_url_parts(params)
    filter_alphabets = url_parts[:alphabets].join("")
    filter_alphabets = get_browse_constant+filter_alphabets
    href_parts.push("/houses")
    href_parts.push(url_parts[:words].join("+"))
    href_parts.push(filter_alphabets)
    href = href_parts.join("+")
    return href
  end

  def get_search_or_browse_url_parts(params)
    filterValues = []
    filterAlphabets = []
    params.each do |attributeKey, paramValues|
      map = get_house_attribute_map
      attributeKey = map.select{|key,value| value == attributeKey.to_s}
      if(attributeKey.keys.nil?)
        next
      end

      attributeKey = attributeKey.keys[0]
      filterAlphabets.push(attributeKey)
      if paramValues.kind_of?(Array)
        paramValue = []
        paramValues.each do |value|
          begin
            value = value.to_s
            if(attributeKey.to_s == "d")
              value = Company.find(value).name
            elsif attributeKey.to_s == "e"
              value = User.find(value).name
            end
            value.gsub!(" ","-")
          rescue
            next
          end
          paramValue.push(value)
        end
        if get_house_attributes_having_range.include?attributeKey.to_s
          paramValues = paramValue.join("-")
        else
          paramValues = paramValue.join("_")
        end
      else
        paramValues = paramValues.to_s
        begin
          if(attributeKey.to_s == "d")
            paramValues = Company.find(paramValues).name
          elsif attributeKey.to_s == "e"
            paramValues = User.find(paramValues).name
          end

          paramValues.gsub!(" ","-")

        rescue
          next
        end
      end
      filterValues.push(paramValues)
    end
    return {"words":filterValues,"alphabets":filterAlphabets}
  end

  def run
    searchConstant = get_search_constant
    browseConstant = get_browse_constant

    appliedFilters = request.fullpath.split("+")


    appliedFilters.shift
    numberOfFilters = appliedFilters.length - 1
    appliedFilters[numberOfFilters] = appliedFilters[numberOfFilters].split("?")[0]
    type = appliedFilters[numberOfFilters][0]
    filterAlphabets = appliedFilters.pop
    filterAlphabets = filterAlphabets[1..-1]
    if type == searchConstant
      @isSearch = true
      @searchKeywords = appliedFilters.pop
    elsif type == browseConstant
      @isBrowse= true
    else
      puts "bakwas"
      # todo: redirect to home
    end



    numberOfFilters = appliedFilters.length


    if filterAlphabets.length < appliedFilters.length
      diff = appliedFilters.length - filterAlphabets.length
      appliedFilters = appliedFilters.first(0-diff)

    elsif filterAlphabets.length > appliedFilters.length
      diff = filterAlphabets.length - appliedFilters.length
      filterAlphabets = filterAlphabets.first(0-diff)
    end

    # this is for houses
    map = get_house_attribute_map

    numericRange = get_house_attributes_having_range
    queryReqd = {
        "d":{"model":Company.new,"attribute":"name"},
        "e":{"model":User.new,"attribute":"name"}
    }

    filters = {}
    mapKeys = map.keys
    index = -1
    mapKeys.each do |mapKey|

      # if filter alphabets doesnt contain mapKey, continu

      if !(filterAlphabets.include? mapKey.to_s)
        next
      end
      index += 1

      appliedFilter = appliedFilters[index]

      if numericRange.include? mapKey.to_s
        begin
        split = appliedFilter.split("-")
        appliedFilters[index] = [split[0]..split[1]]
        rescue
          end
      end
      if appliedFilters[index].kind_of?(String)
        appliedFilters[index] = appliedFilters[index].split("_")
        appliedFilters[index].each_with_index do |part,partIndex|
          appliedFilters[index][partIndex].gsub!("-"," ") if part.kind_of?(String)
        end
      end

      if queryReqd.keys.include? mapKey
        modelName = queryReqd[mapKey][:model]
        attribute = queryReqd[mapKey][:attribute]
        queryResults = modelName.class.where(attribute => appliedFilters[index])

        resultIds = []
        queryResults.each do |res|
          resultIds.push(res.id)
        end
        if resultIds.length > 0
          appliedFilters[index] = resultIds
        end
      end
      if !appliedFilters[index].nil?
        filters[map[mapKey]] = appliedFilters[index]
      end
    end

    if is_search_request?
      @result = House.where(filters).where("location like ?","%#{@searchKeywords.gsub("-"," ")}%")
    else
      @result = House.where(filters)
    end

  end

  def is_search_request?
    return @isSearch
  end

  def is_browse_request?
    if params[:exp].nil?
      return true
    end
    return @isBrowse
  end

  def get_result
    return @result
  end

  def get_search_keywords
    if is_search_request?
      return @searchKeywords
    end
  end

  def get_search_constant
    return "x"
  end

  def get_browse_constant
    return "w"
  end

  def do_redirect
    # for applied filters, match expected URL versus given URL
  end

end