require "application_system_test_case"

class PricingsTest < ApplicationSystemTestCase
  setup do
    @pricing = pricings(:one)
  end

  test "visiting the index" do
    visit pricings_url
    assert_selector "h1", text: "Pricings"
  end

  test "should create pricing" do
    visit pricings_url
    click_on "New pricing"

    fill_in "Client", with: @pricing.client_id
    fill_in "Grace period days", with: @pricing.grace_period_days
    fill_in "Price", with: @pricing.price
    fill_in "Service", with: @pricing.service_id
    fill_in "Start delay", with: @pricing.start_delay
    click_on "Create Pricing"

    assert_text "Pricing was successfully created"
    click_on "Back"
  end

  test "should update Pricing" do
    visit pricing_url(@pricing)
    click_on "Edit this pricing", match: :first

    fill_in "Client", with: @pricing.client_id
    fill_in "Grace period days", with: @pricing.grace_period_days
    fill_in "Price", with: @pricing.price
    fill_in "Service", with: @pricing.service_id
    fill_in "Start delay", with: @pricing.start_delay
    click_on "Update Pricing"

    assert_text "Pricing was successfully updated"
    click_on "Back"
  end

  test "should destroy Pricing" do
    visit pricing_url(@pricing)
    click_on "Destroy this pricing", match: :first

    assert_text "Pricing was successfully destroyed"
  end
end
