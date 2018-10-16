include SearchHelper

module HousesHelper

  def is_user_interested(house_id,user_id)
    interests = Interest.where(house_id: house_id, user_id:user_id)
    #puts "IIII"
    #puts interests.length
    return (interests.length>0)
  end

  def get_interests_inquiries_text(house_id, logged_in,current_user)
    interests = Interest.where(house_id: house_id)
    interestCount = interests.count
    @showInterestSection = (interestCount > 0)
    isUserInterested = false
    if logged_in
      interests.each do |interest|
        if interest.user_id == current_user.id
          isUserInterested = true
          break
        end
      end
    end

    if isUserInterested
      if interestCount == 1
        interestText = "You are interested"
      elsif interestCount == 2
        interestText = "You and 1 other person are interested"
      else
        interestText = "You and #{interestCount-1} others are interested"
      end
    else
      if interestCount == 0
        interestText = nil
      elsif interestCount == 1
        interestText = "1 person is interested"
      else
        interestText = "#{interestCount} people are interested"
      end
    end
    @interestText = interestText

    #inquiries = Interest.where(house_id: house_id) # todo: query after creating inquiries table and join
    user_res = User.find_by_sql("SELECT u.id,iq.id AS iqid, iq.interest_id, u.name, u.email, iq.subject, iq.message, iq.reply, u.phone, u.preferred_contact_method
FROM users u
  JOIN interests AS i ON i.user_id=u.id
  JOIN inquiries AS iq ON iq.interest_id=i.id
WHERE i.house_id="+house_id.to_s)

    inquiriesCount = user_res.count
    @showInquiriesSection = (inquiriesCount > 0)
    hasUserInquired = false
    if logged_in
      user_res.each do |user|
        if user.id == current_user.id
          hasUserInquired = true
          break
        end
      end
    end


    if hasUserInquired
      if inquiriesCount == 1
        inquiriesText = "You have inquired"
      elsif inquiriesCount == 2
        inquiriesText = "You and 1 other person have inquired"
      else
        inquiriesText = "You and #{interestCount-1} others have inquired"
      end
    else
      if inquiriesCount == 0
        inquiriesText = nil
      elsif inquiriesCount == 1
        inquiriesText = "1 person has inquired"
      else
        inquiriesText = "#{interestCount} people have inquired"
      end
    end
    @inquiriesText = inquiriesText
  end


  def get_formatted_price(price)
    return "#{price.to_i}."+"#{(price % 1.0)}"[2..3]
  end

  def get_price_range_filter
    range = [House.minimum("list_price"),House.maximum("list_price")]
    return range
  end

  def get_company_list_filter
    companyIds = House.distinct.pluck(:company_id)
    companies = Company.where(id:companyIds)
    return companies
  end

  def get_floor_filter
    range = [House.minimum("floors"),House.maximum("floors")]
    return range
  end

  def get_basement_filter
    return [true,false]
  end

  def get_sqft_filter
    range = [House.minimum("sq_footage").to_i,House.maximum("sq_footage").to_i]
    return range
  end

  def get_year_filter
    range = [House.minimum("year_build"),House.maximum("year_build")]
    return range
  end

  def get_all_filters
    # filters = {}
    # filters["price_range"] = get_price_range_filter
    # filters["company"] = get_company_list_filter
    # filters["floor"] = get_floor_filter
    # filters["basement"] = get_basement_filter
    # filters["sqft"] = get_sqft_filter
    # filters["year"] = get_year_filter

    filters = []
    #
    floors = get_floor_filter
    floor_min = floors[0]
    floor_max = floors[1]
    floor_options = []
    i = floor_min
    while i <= floor_max
      floor = {}
      floor["name"] = (i == 1) ? (i.to_s + " Floor") : (i.to_s + " Floors")
      floor["value"] = i.to_s
      floor_options.push(floor)
      i+=1
    end

    price_range = get_price_range_filter
    filters.push(
        {
            "heading":"Price",
            "input_name":"list_price",
            "is_multi_select":false,
            "is_range":true,
            "range":[price_range[0],price_range[1]],
            "url_alphabet":get_filter_alphabet_by_value("list_price")
        }
    )
    filters.push(
        {
            "heading":"Floors",
            "input_name":"floors",
            "is_multi_select":true,
            "url_alphabet":get_filter_alphabet_by_value("floors"),
            "options":floor_options
        }
    )

    company_options = []
    companies = get_company_list_filter
    companies.each do |company|
      a_company = {}
      a_company["name"] = company.name
      a_company["value"] = company.id
      company_options.push(a_company)
    end

    filters.push(
        {
            "heading":"Company",
            "input_name":"company_id",
            "is_multi_select":true,
            "url_alphabet":get_filter_alphabet_by_value("company_id"),
            "options":company_options
        }
    )

    sqft = get_sqft_filter
    sqft_min = sqft[0]
    sqft_max = sqft[1]
    filters.push(
        {
            "heading":"Size",
            "input_name":"sq_footage",
            "is_range":true,
            "range":[sqft_min,sqft_max],
            "url_alphabet":get_filter_alphabet_by_value("sq_footage")
        }
    )

    puts filters

    return filters
  end

  def get_house_url(id)
    return "/houses/#{id.to_s}"
  end

end
