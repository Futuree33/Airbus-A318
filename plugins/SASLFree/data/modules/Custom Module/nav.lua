-- A318 Created by X-Bureau --

position = {50, 600, 522, 522}
size = {522, 522}

-- abstracts the information so it makes more sense
-- also SNAKE_CASE to make sure that it isn't edited
-- means that it should be a constant. (aka final or const)
local PAGE_POS = {
    x = position[1],
    y = position[2],
    w = position[3],
    h = position[4]
}
local PAGE_SIZE = {x = size[1], y = size[2]}

--get datarefs
local airspeed = globalPropertyf("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
local altitude = globalPropertyf("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
local pitch = globalPropertyf("sim/cockpit2/gauges/indicators/pitch_electric_deg_pilot")
local roll = globalPropertyf("sim/cockpit2/gauges/indicators/roll_electric_deg_pilot")


--fonts
local AirbusFont = sasl.gl.loadFont("fonts/PanelFont.ttf")

--colors
local PFD_GREEN = {0.184, 0.733, 0.219, 1.0}
local PFD_LIGHT_GREEN = {0, 1.0, 0.35, 1.0}
local PFD_WHITE = {1.0, 1.0, 1.0, 1.0}
local PFD_BLUE = {0.004, 1.0, 1.0, 1.0}
local PFD_GREY = {0.25, 0.26, 0.26, 1.0}

--get images
local artificial_horizon_overlay = sasl.gl.loadImage("images/PFD_Overlay_1.png", 0, 0, 552, 522)
local ground_decal = sasl.gl.loadImage("images/Ground_Horizon_Decal.png", 0, 0, 552, 522)
local tapes_overlay = sasl.gl.loadImage("images/PFD_Overlay_2.png", 0, 0, 552, 522)
local background = sasl.gl.loadImage("images/horizon_background.png", 0, 0, 508, 1050)
local pscale = sasl.gl.loadImage("images/horizon_pitch_scale.png", 0, 0, 508, 1050)
local pscale_ground = sasl.gl.loadImage("images/ground_horizon_pitch_scale.png", 0, 0, 508, 1050)
local align = sasl.gl.loadImage("PFD_Alignment.png", 0, 105, 522, 522)
local pitch_indicator = sasl.gl.loadImage("images/PFD_Other.png", 0, 0, 226, 48)

local TAPE_CFG = {
    --airspeed
    {
        x = 6,
        y = 190,
        w = 50,
        h = 400, 
        font_size = 25,

        get_data = function () return get(airspeed) end, -- callback to get data
        padding = 0,        -- do not pad
        data_h = 100,       -- 100 knts are displayed in the height

        data_max = 500,     -- 500 knots is the largest number
        data_min = 40,      -- 40 knots is lowest number
        tick_interval = 10, -- tick every 10 knts
        num_interval = 20,  -- number every 10 knts
    },
    --alt
    {
        x = 385,
        y = 190,
        w = 50,
        h = 400, 
        font_size = 20,

        get_data = function () return get(altitude) / 100 end, -- callback to get data
        padding = 3,        -- pad 0 infront of numbers less than 3 digits
        data_h = 20,       -- 100 knts are displayed in the height

        data_max = 500,     -- 500 knots is the largest number
        data_min = 0,      -- 40 knots is lowest number
        tick_interval = 10, -- tick every 10 knts
        num_interval = 5,  -- number every 10 knts
    },
}

--custom functions
local function draw_tapes()
  --speed indicator
  -- trail and error time bOIS
  for i,tape in ipairs(TAPE_CFG) do
    interval = tape.data_h / tape.num_interval

    -- 1 knts is tape.w / tape.data_h
    knt_interval = tape.h / tape.data_h
    knt_interval_offset = knt_interval * (math.max(tape.get_data(), tape.data_min) % tape.num_interval)
    knt_interval_final = knt_interval_offset * -1

    data = math.max(tape.get_data(), tape.data_min)
    data_rounded = math.floor(data / tape.num_interval) * tape.num_interval

    for j = 1,interval do
      j_offset = math.ceil(interval / 2)
      j_final = j - j_offset
      data_offset = data_rounded + (j_final * tape.num_interval)
      data_final = data_offset

      y_offset = (j - 1) * (tape.h / interval)
      y_final = y_offset + knt_interval_final

      if data_final >= tape.data_min then
          --padding
          data_final = tostring(data_final)
          while string.len(data_final) < tape.padding do
              data_final = "0" .. data_final
          end
          --draw
          sasl.gl.drawText(
            AirbusFont,
            tape.x,
            tape.y + y_final,
            data_final,
            tape.font_size,
            false, false, TEXT_ALIGN_LEFT, PFD_WHITE)
        end
    end
  end
end

local function draw_artificial_horizon()

  sasl.gl.setClipArea(0, 51, 510, 522)
	sasl.gl.drawRotatedTexture(background, 0 - get(roll), -7, ((0 - get(pitch)) * 5) - 200, 500, 1000, PFD_WHITE)
  if math.floor(get(altitude)) < 49 then
	sasl.gl.drawRotatedTexture(pscale_ground, 0 - get(roll), -7, ((0 - get(pitch)) * 5) - 200, 500, 1000, PFD_WHITE)
	sasl.gl.drawTexture(ground_decal, -5, 50, 522, 522)
  elseif get(altitude) > 50 and get(altitude) < 2500 then
    sasl.gl.drawRotatedTexture(pscale_ground, 0 - get(roll), -7, ((0 - get(pitch)) * 5) -200, 500, 1000, PFD_WHITE)
	sasl.gl.drawText(AirbusFont, 198, 205, math.floor(get(altitude)), 24, false, false, TEXT_ALIGN_LEFT, PFD_LIGHT_GREEN) 
  else
	sasl.gl.drawRotatedTexture(pscale, 0 - get(roll), -7, ((0 - get(pitch)) * 5) - 198, 500, 1000, PFD_WHITE)
  end


  --sasl.gl.drawRotatedTexture(align, (0 - get(roll)*.2), -16, 155, 522, 522, PFD_WHITE)
    
  sasl.gl.drawTexture(pitch_indicator, 97, 275, 228, 48, PFD_WHITE)

-- angle, x, y, width, height, color
end

function draw()

  -- draw AH
  draw_artificial_horizon()

  sasl.gl.drawTexture(artificial_horizon_overlay, -15, 50, 550, 522)

  -- draw tapes
  draw_tapes()

  sasl.gl.drawTexture(tapes_overlay, -15, 50, 550, 522)
  --sasl.gl.drawRectangle(14, 108, 50, 280, {1, 0, 0})
  

  -- cleanup
  sasl.gl.resetClipArea()
end

    

