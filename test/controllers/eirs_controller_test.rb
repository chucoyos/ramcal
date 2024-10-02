require "test_helper"

class EirsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @eir = eirs(:one)
  end

  test "should get index" do
    get eirs_url
    assert_response :success
  end

  test "should get new" do
    get new_eir_url
    assert_response :success
  end

  test "should create eir" do
    assert_difference("Eir.count") do
      post eirs_url, params: { eir: { container_id: @eir.container_id, fleet_number: @eir.fleet_number, operator: @eir.operator, plate: @eir.plate, transport: @eir.transport } }
    end

    assert_redirected_to eir_url(Eir.last)
  end

  test "should show eir" do
    get eir_url(@eir)
    assert_response :success
  end

  test "should get edit" do
    get edit_eir_url(@eir)
    assert_response :success
  end

  test "should update eir" do
    patch eir_url(@eir), params: { eir: { container_id: @eir.container_id, fleet_number: @eir.fleet_number, operator: @eir.operator, plate: @eir.plate, transport: @eir.transport } }
    assert_redirected_to eir_url(@eir)
  end

  test "should destroy eir" do
    assert_difference("Eir.count", -1) do
      delete eir_url(@eir)
    end

    assert_redirected_to eirs_url
  end
end
