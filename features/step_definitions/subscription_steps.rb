
When /^I visit their user ratings page$/ do
  @festival = @user.picks.first.festival
  subscription = @user.subscription_for(@festival.id)
  visit user_rating_path(@user, subscription.ratings_token)
end

Then /^I should see their film ratings$/ do
  @user.picks.where(festival_id: @festival.id).rated\
             .includes(:film).each do |pick|
    expect(page.find("#rating_#{pick.rating} #film_#{pick.film_id}")).to have_content(pick.film.name)
  end
end
