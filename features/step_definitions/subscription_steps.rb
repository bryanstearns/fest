
When /^I visit their user ratings page$/ do
  @festival = @user.picks.first.festival
  subscription = @user.subscription_for(@festival.id)
  visit user_ratings_path(subscription.ratings_token)
end

Then /^I should see their film ratings$/ do
  @user.picks.where(festival_id: @festival.id).rated\
             .includes(:film).each do |pick|
    page.find("#rating-#{pick.rating} #film-#{pick.film_id}").should have_content(pick.film.name)
  end
end
