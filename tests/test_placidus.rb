require 'minitest/autorun'
require_relative '../placidus'

class TestPlacidus < Minitest::Test
  def test_placidus
    # Example values for Ascendant, Declination, and Latitude
    as = 120.0
    dec = 23.5
    lat = 40.0

    # Calculate Placidus house cusps
    cusps = placidus(as, dec, lat)

    # Assert that the result is an array of 12 values
    assert_instance_of Array, cusps
    assert_equal 12, cusps.size

    # You can add more specific assertions based on expected values
    # For example, if you know the expected value for a specific cusp:
    # assert_in_delta expected_cusp_value, cusps[0], 0.1 
    # (assert within a delta of 0.1 degrees)

    # For now, we'll just check that the cusps are within a reasonable range (0-360)
    cusps.each do |cusp|
      assert cusp >= 0, "Cusp value is negative: #{cusp}"
      assert cusp <= 360, "Cusp value exceeds 360: #{cusp}"
    end

    # Check if any cusp indicates non-convergence (-1)
    assert_equal false, cusps.include?(-1), "Placidus calculation did not converge for some cusps."
  end

  def test_placidus_extreme_latitude
    as = 180.0
    dec = 10.0
    lat = 89.0 # Close to North Pole

    cusps = placidus(as, dec, lat)

    assert_instance_of Array, cusps
    assert_equal 12, cusps.size
    assert_equal false, cusps.include?(-1), "Placidus calculation did not converge for some cusps (extreme latitude)."
  end

  def test_placidus_extreme_declination
    as = 90.0
    dec = 89.0 # Close to maximum declination
    lat = 30.0

    cusps = placidus(as, dec, lat)

    assert_instance_of Array, cusps
    assert_equal 12, cusps.size
    assert_equal false, cusps.include?(-1), "Placidus calculation did not converge for some cusps (extreme declination)."
  end

  def test_placidus_negative_values
    as = 270.0
    dec = -20.0
    lat = -45.0

    cusps = placidus(as, dec, lat)

    assert_instance_of Array, cusps
    assert_equal 12, cusps.size
    assert_equal false, cusps.include?(-1), "Placidus calculation did not converge for some cusps (negative values)."
  end

  def test_placidus_invalid_ascendant
    assert_raises ArgumentError do
      placidus(-10, 20, 30)
    end
    assert_raises ArgumentError do
      placidus(370, 20, 30)
    end
  end

  def test_placidus_invalid_declination
    assert_raises ArgumentError do
      placidus(100, -100, 30)
    end
    assert_raises ArgumentError do
      placidus(100, 100, 30)
    end
  end

  def test_placidus_invalid_latitude
    assert_raises ArgumentError do
      placidus(100, 20, -100)
    end
    assert_raises ArgumentError do
      placidus(100, 20, 100)
    end
  end
end
