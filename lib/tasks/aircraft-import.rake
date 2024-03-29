# Aircraft List Resources
# https://en.wikipedia.org/wiki/Category:Grumman_aircraft
# https://en.wikipedia.org/wiki/Grumman
# https://en.wikipedia.org/wiki/Category:Bell_aircraft
# https://en.wikipedia.org/wiki/Bell_Aircraft
# https://en.wikipedia.org/wiki/Convair
# https://en.wikipedia.org/wiki/List_of_United_States_bomber_aircraft
# https://en.wikipedia.org/wiki/Lists_of_military_aircraft_of_the_United_States
# https://en.wikipedia.org/wiki/List_of_active_United_States_military_aircraft
# https://en.wikipedia.org/wiki/List_of_Lockheed_aircraft
# https://en.wikipedia.org/wiki/List_of_fighter_aircraft
# https://en.wikipedia.org/wiki/List_of_bomber_aircraft
# https://en.wikipedia.org/wiki/List_of_aircraft_of_the_Royal_Air_Force
# https://en.wikipedia.org/wiki/Category:Lists_of_military_aircraft

namespace :aircraft do
  desc "Import data from opensky network aircraft database"
  task opensky_network: :environment do
    abort "\n\n[*]Deprecated\n\n"

    require 'csv'

    csv_file = "#{Rails.root}/tmp/data/aircraftDatabase.csv"

    counter = 0
    collect_rows = []

    first = OpenskyNetworkRaw.first

    OpenskyNetworkRaw.delete_all

    puts "\nImporting ... "
    CSV.foreach(csv_file, headers: true) do |row|
      counter = counter + 1

      row = OpenskyNetworkRaw.new(row.to_hash)

      row.save

      break if counter == 10000
    end
    puts "\nDone"
  end

  desc "Import a small sample of aircraft models for testing"
  task import_test_data: :environment do
    require 'csv'

    aircraft_models = [
      "Lockheed C-69/Lockheed C-121 Constellation, military transport versions of the Constellation",
      "YC-121F Constellation, experimental turboprop version",
      "Lockheed R6V Constitution, large transport aircraft",
      "Lockheed C-130 Hercules, medium combat transport (AC-130 gunship) (other variants)",
      "Lockheed C-141 Starlifter, long-range jet transport",
      "Lockheed C-5 Galaxy, heavy transport",
      "Lockheed P-38 Lightning, twin-engine propeller fighter",
      "Lockheed P-80 Shooting Star, the United States Air Force's first operational jet fighter",
      "Lockheed T-33 Shooting Star, trainer jet",
      "Lockheed F-94 Starfire, all-weather fighter",
      "Lockheed F-104 Starfighter, interceptor and later a multi-mission fighter, the 'missile with a man in it'",
      "Lockheed F-117 Nighthawk, stealth fighter attack aircraft",
      "General Dynamics F-16 Fighting Falcon, multirole fighter (Originally General Dynamics)",
      "PV-1 Ventura and PV-2 Harpoon, Maritime patrol/bomber",
      "PO-1W/WV-1 Constellation, AWACS version of the Constellation",
      "EC-121/WV-2 Warning Star, AWACS version of the Super Constellation",
      "Lockheed SR-71 Blackbird, reconnaissance (A-12) (M-21) (YF-12)",
      "Northrop Grumman B-2 Spirit",
      "Northrop Grumman E-2 Hawkeye",
      "Northrop Grumman RQ-4 Global Hawk",
      "Northrop Grumman X-47B",
      "Northrop Grumman MQ-8 Fire Scout",
      "Boeing AH-64 Apache",
      "Boeing E-3 Sentry (AWACS)",
      "Boeing E-767",
      "Boeing EA-18G Growler",
      "Boeing F/A-18E/F Super Hornet",
      "Boeing P-8 Poseidon",
      "Boeing E-767 Airborne Warning and Control System (AWACS)",
      "Boeing T-7 Red Hawk (Advanced Pilot Training System)",
      "Rockwell OV-10 Bronco",
      "Rockwell B-1 Lancer",
      "BAE Hawk",
      "BAE Harrier II"
    ]

    ::AircraftImage.delete_all
    ::Aircraft.delete_all
    aircraft_models.each do |entry|
      row = Aircraft.new(model: entry)
      row.save
    end

    puts "\nDone"
  end

  desc "Import aircraft models"
  task import: :environment do
    require 'csv'

    aircraft_models = [
      "Lockheed Vega",
      "Lockheed Model 10 Electra",
      "Lockheed Model 12 Electra Junior",
      "Lockheed Model 14 Super Electra",
      "Lockheed Model 18 Lodestar",
      "Lockheed Constellation, airliner",
      "Lockheed L-049 Constellation, first model of the Lockheed Constellation",
      "Lockheed L-649 Constellation, improved Lockheed Constellation",
      "Lockheed L-749 Constellation, further improved Lockheed Constellation",
      "Lockheed L-1049 Super Constellation, largest produced model of the Lockheed Constellation",
      "Lockheed L-1649 Starliner, last model of the Lockheed Constellation",
      "Lockheed Saturn",
      "Lockheed L-188 Electra",
      "Lockheed JetStar, business jet",
      "Lockheed L-1011 TriStar, wide-body airliner",
      "Lockheed C-69/Lockheed C-121 Constellation, military transport versions of the Constellation",
      "YC-121F Constellation, experimental turboprop version",
      "Lockheed R6V Constitution, large transport aircraft",
      "Lockheed C-130 Hercules, medium combat transport (AC-130 gunship) (other variants)",
      "Lockheed C-141 Starlifter, long-range jet transport",
      "Lockheed C-5 Galaxy, heavy transport",
      "Lockheed P-38 Lightning, twin-engine propeller fighter",
      "Lockheed P-80 Shooting Star, the United States Air Force's first operational jet fighter",
      "Lockheed T-33 Shooting Star, trainer jet",
      "Lockheed F-94 Starfire, all-weather fighter",
      "Lockheed F-104 Starfighter, interceptor and later a multi-mission fighter, the 'missile with a man in it'",
      "Lockheed F-117 Nighthawk, stealth fighter attack aircraft",
      "General Dynamics F-16 Fighting Falcon, multirole fighter (Originally General Dynamics)",
      "Lockheed F-22, air superiority stealth fighter",
      "Lockheed F-35, air superiority and strike missions",
      "Lockheed Hudson, maritime patrol/bomber",
      "PV-1 Ventura and PV-2 Harpoon, Maritime patrol/bomber",
      "PO-1W/WV-1 Constellation, AWACS version of the Constellation",
      "EC-121/WV-2 Warning Star, AWACS version of the Super Constellation",
      "Lockheed P-2 Neptune, maritime patrol",
      "Lockheed P-3 Orion, ASW patrol",
      "Lockheed CP-140 Aurora, Maritime patrol aircraft",
      "Lockheed U-2/TR-1, reconnaissance",
      "Lockheed SR-71 Blackbird, reconnaissance (A-12) (M-21) (YF-12)",
      "Lockheed S-3 Viking, patrol/attack",
      "YO-3A Quiet Star",
      "Lockheed CL-475, rigid-rotor helicopter",
      "XH-51A/B (Lockheed CL-595/Model 286), compound helicopter testbed",
      "Lockheed AH-56 Cheyenne, prototype attack compound helicopter",
      "UGM-27 Polaris",
      "UGM-73 Poseidon",
      "UGM-89 Perseus",
      "UGM-96 Trident I",
      "UGM-133 Trident II",
      "High Virgo",
      "Lockheed X-7",
      "Lockheed X-17",
      "Lockheed L-301 (aka X-24C)",
      "Lockheed Star Clipper",
      "Corona",
      "RM-81 Agena",
      "Agena target vehicle",
      "Apollo Launch Escape System",
      "Northrop N-3PB",
      "Northrop A-17",
      "Northrop P-61 Black Widow",
      "Northrop XP-56 Black Bullet",
      "Northrop P-64",
      "Northrop XP-79 Flying Ram",
      "Northrop YB-35",
      "Northrop YB-49",
      "Northrop F-5 Freedom Fighter / Tiger II",
      "Northrop T-38 Talon",
      "Northrop YA-9",
      "Northrop Grumman B-2 Spirit",
      "Northrop Grumman E-2 Hawkeye",
      "Northrop Grumman RQ-4 Global Hawk",
      "Northrop Grumman X-47B",
      "Northrop Grumman MQ-8 Fire Scout",
      "Boeing 757",
      "Boeing 767",
      "Boeing 777",
      "Boeing 787 Dreamliner",
      "Boeing 737 Classic series",
      "Boeing 737 Next Generation series",
      "Boeing 737 MAX series",
      "Boeing 747-8",
      "Boeing AH-64 Apache",
      "Boeing E-3 Sentry (AWACS)",
      "Boeing E-767",
      "Boeing EA-18G Growler",
      "Boeing F/A-18E/F Super Hornet",
      "Boeing P-8 Poseidon",
      "Boeing KC-46 Pegasus",
      "Boeing 777X",
      "Boeing T-45 Goshawk",
      "Boeing C-17 Globemaster III",
      "Boeing 717 (formerly McDonnell Douglas MD-95)",
      "Boeing 737 AEW&C",
      "Boeing YAL-1 Airborne Laser",
      "Boeing X-32 (Joint Strike Fighter prototype)",
      "Boeing X-45 (Unmanned Combat Air Vehicle)",
      "Boeing CST-100 Starliner (Spacecraft)",
      "Boeing MQ-25 Stingray",
      "Boeing 737 Business Jet",
      "Boeing 777 Freighter",
      "Boeing 747 Dreamlifter",
      "Boeing 737-700ER",
      "Boeing 787-10 Dreamliner",
      "Boeing T-X (Advanced Pilot Training System)",
      "Boeing 737-800 Boeing Converted Freighter (BCF)",
      "Boeing 737-900ER",
      "Boeing 737 MAX 10",
      "Boeing KC-767",
      "Boeing E-767 Airborne Warning and Control System (AWACS)",
      "Boeing 767-400ER",
      "Boeing 737-900 Boeing Business Jet (BBJ3)",
      "Boeing 737 MAX 200",
      "Boeing T-7 Red Hawk (Advanced Pilot Training System)",
      "McDonnell Douglas DC-3",
      "McDonnell Douglas DC-9",
      "McDonnell Douglas MD-80 series",
      "McDonnell Douglas MD-90 series",
      "McDonnell Douglas F-4 Phantom II",
      "McDonnell Douglas F-15 Eagle",
      "McDonnell Douglas F/A-18 Hornet",
      "McDonnell Douglas AV-8B Harrier II",
      "McDonnell Douglas C-17 Globemaster III",
      "McDonnell Douglas MD-11",
      "McDonnell Douglas A-4 Skyhawk",
      "McDonnell Douglas AH-64 Apache",
      "McDonnell Douglas C-47 Skytrain",
      "McDonnell Douglas C-9 Nightingale",
      "McDonnell Douglas KC-10 Extender",
      "McDonnell Douglas YC-15",
      "McDonnell Douglas YF-23 Black Widow II",
      "McDonnell Douglas MD-520N",
      "McDonnell Douglas MD-600N",
      "McDonnell Douglas MD-500 Defender",
      "McDonnell Douglas MD-17 Globemaster III",
      "McDonnell Douglas MD-94X",
      "McDonnell Douglas MD-12",
      "McDonnell Douglas MD-600 Explorer",
      "McDonnell Douglas MD-715",
      "McDonnell Douglas MD-220",
      "McDonnell Douglas MD-160",
      "McDonnell Douglas MD-21",
      "McDonnell Douglas X-36",
      "McDonnell Douglas XF-85 Goblin",
      "McDonnell Douglas XF-88 Voodoo",
      "McDonnell Douglas XF-90",
      "McDonnell Douglas X-3 Stiletto",
      "McDonnell Douglas X-45 UCAV",
      "McDonnell Douglas X-36 Tailless Fighter Agility Research Aircraft",
      "McDonnell Douglas X-50 Dragonfly",
      "McDonnell Douglas X-53 Active Aeroelastic Wing",
      "McDonnell Douglas X-55 Advanced Composite Cargo Aircraft",
      "McDonnell Douglas YF-110",
      "McDonnell Douglas XF-103",
      "McDonnell Douglas XF-85",
      "McDonnell Douglas YAH-64",
      "Rockwell OV-10 Bronco",
      "Rockwell B-1 Lancer",
      "Rockwell Aero Commander",
      "Rockwell Sabreliner",
      "Rockwell XFV-12",
      "Rockwell XF-105",
      "Rockwell X-30 NASP (National Aerospace Plane)",
      "Rockwell XF-108 Rapier",
      "Rockwell XFV-12A",
      "Rockwell XFV-12B",
      "Rockwell XF-103",
      "Rockwell XF-84H Thunderscreech",
      "Rockwell XF-91 Thunderceptor",
      "Rockwell X-31",
      "Rockwell-MBB X-31",
      "Rockwell XF-100",
      "Rockwell X-33",
      "Rockwell-MBB X-31A",
      "Rockwell-MBB X-31B",
      "Rockwell-MBB X-31C",
      "Rockwell X-36",
      "Rockwell-MBB X-31D",
      "Rockwell-MBB X-31E",
      "Rockwell-MBB X-31F",
      "Rockwell-MBB X-31G",
      "Rockwell-MBB X-31H",
      "Rockwell-MBB X-31I",
      "Rockwell-MBB X-31J",
      "Rockwell-MBB X-31K",
      "Rockwell-MBB X-31L",
      "Rockwell-MBB X-31M",
      "Rockwell-MBB X-31N",
      "Rockwell-MBB X-31O",
      "Rockwell-MBB X-31P",
      "Rockwell-MBB X-31Q",
      "Rockwell-MBB X-31R",
      "Rockwell-MBB X-31S",
      "Rockwell-MBB X-31T",
      "Rockwell-MBB X-31U",
      "Rockwell-MBB X-31V",
      "Rockwell-MBB X-31W",
      "Rockwell-MBB X-31X",
      "Rockwell-MBB X-31Y",
      "Rockwell-MBB X-31Z",
      "BAE Hawk",
      "BAE Harrier II",
      "BAE Tornado",
      "BAE Nimrod",
      "BAE Jetstream",
      "BAE 146",
      "BAE ATP (Advanced Turbo-Prop)",
      "BAE Sea Harrier",
      "BAE Strikemaster",
      "BAE EAP (Experimental Aircraft Programme)",
      "BAE P.125",
      "BAE P.1216",
      "BAE P.1121",
      "BAE Skylynx",
      "BAE Mantis",
      "BAE Corax",
      "BAE Raven",
      "BAE Taranis",
      "BAE Tempest",
      "BAE Maelstrom",
      "BAE Kestrel",
      "BAE HERTI",
      "BAE HERTI-1",
      "BAE HERTI-2",
      "BAE Midge",
      "BAE Mosquito",
      "BAE Gnat",
      "BAE Mosquito TR Mk. 33",
      "BAE Systems Demon",
      "BAE Systems Magma",
      "BAE Systems Taranis",
      "BAE Systems Replica",
      "BAE Systems Sharp Claw",
      "BAE Systems Mantis",
      "BAE Systems Corax",
      "BAE Systems Raven",
      "BAE Systems Tempest",
      "Raytheon Beechcraft King Air",
      "Raytheon Hawker",
      "Raytheon Sentinel R1",
      "Raytheon T-6 Texan II",
      "Raytheon/Bombardier Sentinel",
      "Raytheon Ground Based Radar",
      "Raytheon AN/TPY-2 Radar",
      "Raytheon JLENS (Joint Land Attack Cruise Missile Defense Elevated Netted Sensor System)",
      "Raytheon HAWK Missile System",
      "Raytheon AIM-120 AMRAAM (Advanced Medium-Range Air-to-Air Missile)",
      "Raytheon AIM-9 Sidewinder",
      "Raytheon AGM-65 Maverick",
      "Raytheon AGM-88 HARM (High-Speed Anti-Radiation Missile)",
      "Raytheon AGM-154 Joint Standoff Weapon (JSOW)",
      "Raytheon AGM-176 Griffin",
      "Raytheon AIM-120C-7 AMRAAM",
      "Raytheon AIM-120D AMRAAM",
      "Raytheon AIM-9X Sidewinder",
      "Raytheon AGM-88E Advanced Anti-Radiation Guided Missile (AARGM)",
      "Raytheon Miniature Air Launched Decoy (MALD)",
      "Raytheon MALD-J (Miniature Air Launched Decoy - Jammer)",
      "Raytheon Coyote UAV",
      "Raytheon Coyote Block 2 UAV",
      "Raytheon Coyote Block 3 UAV",
      "Raytheon Coyote Block 4 UAV",
      "Raytheon Coyote Block 5 UAV",
      "Raytheon Common Sensor Payload (CSP)",
      "Raytheon Common Ground Control System (CGCS)",
      "Raytheon Universal Control System (UCS)",
      "Raytheon Advanced Targeting Forward-Looking Infrared (ATFLIR)",
      "Raytheon Advanced Countermeasure Electronic System (ACES)",
      "Raytheon Advanced Radar Warning Receiver (ARWR)",
      "Raytheon Next Generation Jammer (NGJ)",
      "Raytheon Silent Knight Radar",
      "Raytheon Advanced Precision Kill Weapon System (APKWS)",
      "Raytheon Quickstrike Extended Range (QS-ER)",
      "Raytheon Joint Standoff Weapon Extended Range (JSOW-ER)"
    ]

    ::AircraftImage.delete_all
    ::Aircraft.delete_all
    aircraft_models.each do |entry|
      row = Aircraft.new(model: entry)
      row.save
    end

    puts "\nDone"
  end
end
