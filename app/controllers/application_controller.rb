include SearchHelper

class ApplicationController < ActionController::Base
  protect_from_forgery
  # Returns the current logged-in user (if any).
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  def get_admin_role_id
    return 4
  end

  def roles
    roles = {
      '1' => "House Hunter",
      '2' => "Realtor",
      '3' => "Both",
      '4' => "Admin"
    }
    return roles
  end

  def topInterestsLimit
    return 4
  end

  def myHousesLimit
    return 4
  end

  def get_user_role
    begin
    role = current_user.role
    return role
    rescue
      return -1;
    end
  end


  def isOnlyHouseHunter?
    role = get_user_role
    return (role == 1)
  end

  def isOnlyRealtor?
    role = get_user_role
    return (role == 2)
  end

  def isRealtor?(user)
    if(user.nil?)
      false
    else
      return (user.role.to_i >= 2 && user.role.to_i <= 4)
    end
  end

  def isHouseHunter?(user)
    return user.role !=2
  end

  def isRealtorAndHouseHunter?
    role = get_user_role
    return (role == 3)
  end

  def isOnlyAdmin?
    role = get_user_role
    return (role == 4)
  end

  def nav_bar_details
    nav_bar = {}
    if logged_in?
      nav_bar["name"] = "Hi " + current_user.name + "!"
      nav_bar["nameLink"] = "/users/#{current_user.id}"
      nav_bar["loggedIn"] = true
      nav_bar["links"] = []
      nav_bar["userid"] = current_user.id
      # if realtor ONLY:
      if isOnlyRealtor?
        nav_bar = get_realtor_nav_bar(nav_bar)
      end


      if isOnlyHouseHunter?
        nav_bar = get_house_hunter_nav_bar(nav_bar)
      end

      if isRealtorAndHouseHunter?

        nav_bar = get_house_hunter_nav_bar(nav_bar)
        nav_bar = get_realtor_nav_bar(nav_bar)
      end

      if isOnlyAdmin?
        nav_bar = get_realtor_nav_bar(nav_bar)
        nav_bar = get_house_hunter_nav_bar(nav_bar)
        nav_bar = get_admin_nav_bar(nav_bar)
        # if admin
      end

    else
      # not logged in
      nav_bar["name"] = "Home"
      nav_bar["nameLink"] = "/"
      nav_bar["loggedIn"] = false
      nav_bar = get_house_hunter_nav_bar(nav_bar)
    end
    return nav_bar
  end

  def get_realtor_nav_bar(nav_bar)
    if(!current_user.company_id.nil?)
      myCompany = Company.find(current_user.company_id)
      myCompany = myCompany.name
      actions = [
          {"title":myCompany,"link":"/companies/#{current_user.company_id}"},
          {"title":"All Companies","link":"/companies"},
          {"title":"Create New Company","link":"/companies/new"}
      ]
    else
      actions = [
          {"title":"All Companies","link":"/companies"},
          {"title":"Create New Company","link":"/companies/new"}
      ]
    end
    nav_bar["links"].push(
        {
            "heading":"Companies",
            "actions":actions
        }
    )
    houses = House.where(:realtor_id=>current_user.id).limit(myHousesLimit).reverse_order
    allMyHousesCount = House.where(:realtor_id=>current_user.id).count
    houseActions = []
    houses.each do |house|
      action = {
          "title":house.location[0..18].gsub(/\s\w+\s*$/,'...'),
          "link":"/houses/#{house.id}"
      }
      houseActions.push(action)

    end

    houseActions.push({"title":"All Houses","link":"/houses"})
    if allMyHousesCount > myHousesLimit
      houseActions.push({"title":"My Houses","link":get_browse_href({"realtor_id":current_user.id})})
    end


    houseActions.push({"title":"List a House","link":"/houses/new"})

    nav_bar["links"].push(
        {
            "heading":"Houses",
            "actions":houseActions
        }
    )
    interestHouses = House.find_by_sql("SELECT h.location FROM interests i JOIN houses h ON i.house_id = h.id WHERE h.realtor_id = #{current_user.id} ORDER BY i.id DESC LIMIT #{topInterestsLimit}")
    interestActions = []
    interestHouses.each do |house|
      interestActions.push({"title":house.location,"link":"/houses/#{house.id}"})
    end
    nav_bar["links"].push(
        {"heading":"Interests","actions":[ ], "link": "/interests"}
    )
    nav_bar["links"].push(
        {"heading":"Inquiries","actions":[ ], "link":"/inquiries"}
    )
    return nav_bar
  end

  def get_house_hunter_nav_bar(nav_bar)
    if logged_in?

      houses = House.find_by_sql("SELECT h.location,h.id FROM interests i JOIN houses h ON i.house_id = h.id WHERE user_id = 2 ORDER BY i.id DESC LIMIT #{topInterestsLimit}")
      interestActions = []
      houses.each do |house|
        interestActions.push({"title":house.location,"link":"/houses/#{house.id}"})
      end

      #if !houses.nil? && houses.count > 0
        nav_bar["links"].push(
          #{"heading":"My Interests","actions":interestActions,"count":Interest.where(user_id: current_user.id).count}
            {"heading":"My Interests","actions":[], "link":"/interests"}
        )
      #end
      nav_bar["links"].push(
          {"heading":"My Inquiries","actions":[], "link":"/inquiries"}
      )
    end
    if(nav_bar["links"].nil? || nav_bar["links"].length == 0)
      nav_bar["links"] = []
    end
    nav_bar["links"].push(
      {"heading":"Explore Homes","actions":[],"link":"/houses"}
    )
    nav_bar["links"].push(
        {"heading":"Explore Companies","actions":[],"link":"/companies"}
    )

    return nav_bar
  end

  def get_admin_nav_bar(nav_bar)
    nav_bar["links"].push(
        {"heading":"Users","actions":[],"link":"/users/new"}
    )
    return nav_bar
  end


end
