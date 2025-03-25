# placidus.rb

def placidus(as, dec, lat)
  # as: Ascendant in degrees (0-360)
  # dec: Declination of the planet in degrees (-90 to +90)
  # lat: Latitude of the observer in degrees (-90 to +90)
+
+  # Validate input parameters
+  raise ArgumentError, "Ascendant must be between 0 and 360 degrees." unless (0..360).include?(as)
+  raise ArgumentError, "Declination must be between -90 and +90 degrees." unless (-90..90).include?(dec)
+  raise ArgumentError, "Latitude must be between -90 and +90 degrees." unless (-90..90).include?(lat)
+
+  # Convert degrees to radians
+  as_rad = as * Math::PI / 180
+  dec_rad = dec * Math::PI / 180
+  lat_rad = lat * Math::PI / 180

  # Calculate the right ascension of the Midheaven (MC)
  mc_ra = (as_rad - Math::PI / 2 + Math::PI * 2) % (Math::PI * 2)

  cusps = []
  (1..12).each do |house|
    # Calculate house cusp in ecliptical longitude
    house_pos = (house - 1) * 30
    house_pos_rad = house_pos * Math::PI / 180
    
    # Calculate ARMC for this house
    armc = (mc_ra + house_pos_rad) % (Math::PI * 2)
    
    # Solve the equation for the house cusp
    cusp_ra = solve_placidus_equation(armc, dec_rad, lat_rad)

    # Convert RA to ecliptical longitude
    cusp_lon = ra_to_lon(cusp_ra, dec_rad)
    
    cusps << cusp_lon * 180 / Math::PI
  end

  cusps
end

def solve_placidus_equation(armc, dec, lat)
  # Iterative solver for the Placidus equation
  ra = armc
  for i in 0..100
    ra_prev = ra
    ha = armc - ra
    x = Math.tan(dec) * Math.tan(lat)
    
    # Avoid division by zero
    if Math.cos(ha) == 0
      return ra_prev
    end
    
    ra += (Math.asin(Math.sin(ha) / Math.cos(x)) - ha) / (1 + Math.sin(dec) * Math.tan(lat) * Math.sin(ha) / Math.cos(ha)) * 0.5

    if (ra - ra_prev).abs < 1e-6
      break
    end

    if i == 100
      # Return -1 to indicate that the solution did not converge
      return -1
    end
  end
  ra
end

def ra_to_lon(ra, dec)
  # Convert right ascension (ra) and declination (dec) to ecliptical longitude.
  # ra and dec are in radians.

  # Epsilon represents the obliquity of the ecliptic (approx. 23.44 degrees)
  epsilon = 23.44 * Math::PI / 180

  # Calculate longitude (lon) using the following formula:
  # lon = atan2(sin(ra) * cos(epsilon) + tan(dec) * sin(epsilon), cos(ra))

  lon = Math.atan2(Math.sin(ra) * Math.cos(epsilon) + Math.tan(dec) * Math.sin(epsilon), Math.cos(ra))

  # Ensure longitude is within 0 to 2*pi
  lon = (lon + 2 * Math::PI) % (2 * Math::PI)

  lon
end
