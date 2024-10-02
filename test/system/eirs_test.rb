require "application_system_test_case"

class EirsTest < ApplicationSystemTestCase
  setup do
    @eir = eirs(:one)
  end

  test "visiting the index" do
    visit eirs_url
    assert_selector "h1", text: "Eirs"
  end

  test "should create eir" do
    visit eirs_url
    click_on "New eir"

    fill_in "Container", with: @eir.container_id
    fill_in "Fleet number", with: @eir.fleet_number
    fill_in "Operator", with: @eir.operator
    fill_in "Plate", with: @eir.plate
    fill_in "Transport", with: @eir.transport
    click_on "Create Eir"

    assert_text "Eir was successfully created"
    click_on "Back"
  end

  test "should update Eir" do
    visit eir_url(@eir)
    click_on "Edit this eir", match: :first

    fill_in "Container", with: @eir.container_id
    fill_in "Fleet number", with: @eir.fleet_number
    fill_in "Operator", with: @eir.operator
    fill_in "Plate", with: @eir.plate
    fill_in "Transport", with: @eir.transport
    click_on "Update Eir"

    assert_text "Eir was successfully updated"
    click_on "Back"
  end

  test "should destroy Eir" do
    visit eir_url(@eir)
    click_on "Destroy this eir", match: :first

    assert_text "Eir was successfully destroyed"
  end
end
