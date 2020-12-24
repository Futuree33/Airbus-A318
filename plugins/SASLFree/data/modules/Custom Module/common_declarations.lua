ECAM_COLOURS = {
    ["ORANGE"] = {1.0, 0.625, 0.0, 1.0},
    ["RED"] = {255, 0, 0, 1.0},
    ["GREEN"] = {0.184, 0.733, 0.219, 1.0},
    ["WHITE"] = {1.0, 1.0, 1.0, 1.0},
    ["BLUE"] = {0.004, 1.0, 1.0, 1.0},
    ["GREY"] = {0.25, 0.26, 0.26, 1.0},
    ["YELLOW"] = {1.0, 1.0, 0, 1.0},
}

AirbusFont = sasl.gl.loadFont("fonts/BloggerSans.ttf")
sasl.gl.setFontRenderMode(AirbusFont, TEXT_RENDER_FORCED_MONO, 0.52)

pump_states = {["off"] = 0, ["on"] = 1, ["low"] = 2}
pump_sources = {["engine"] = 0, ["electric"] = 1, ["rat"] = 2}
switch_states = {["off"] = 0, ["on"] = 1, ["fault"] = 2}
auto_man_states = {["auto"] = 0, ["manual"] = 1}
valve_states = {["closed"] = 0, ["transit"] = 1, ["open"] = 2}
units = {["metric"] = 0, ["imperial"] = 1}
enabled_states = {["disabled"] = 0, ["enabled"] = 1}
flight_phases = {
    ["elec_pwr"] = 1,
    ["engine_start"] = 2,
    ["engine_power"] = 3,
    ["at_80_kts"] = 4,
    ["liftoff"] = 5,
    ["above_1500_ft"] = 6,
    ["below_800_ft"] = 7,
    ["touchdown"] = 8,
    ["below_80_kts"] = 9,
    ["engine_shutdown"] = 10
}

efb_units = createGlobalPropertyi("A318/efb/config/units", units.metric)

function get_weight(kg)
    if get(efb_units) == units.metric then
        return kg
    end
    return kg * 2.20462262185
end

function get_temp(celsius)
    if get(efb_units) == units.metric then
        return celsius
    end
    return celsius * 1.8 + 32
end

local vsi = globalPropertyf("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
function get_vsi()
    local vs = {["value"] = 0,
    ["colour"] = ECAM_COLOURS["GREEN"], ["blink"] = false}
    local blink = false
    local value = get(vsi)
    vs["value"] = value
    if value >= 2000 or value <= -2000 then
        vs["colour"] = ECAM_COLOURS["ORANGE"]
    elseif (value >= 1800 and value < 2000) or (value <= -1850 and value > -2000) then
        blink = true
    elseif blink and (value < 1600 or value > -1600) then
        blink = false
    elseif value > 0 then
    end
    vs["blink"] = blink
    return vs
end