import json

import requests
from bs4 import BeautifulSoup
import time

# Find all building ids
url = "https://moseskonto.tu-berlin.de/moses/verzeichnis/raeume/gebaeude.html"
page = requests.get(url)

soup = BeautifulSoup(page.content, "html.parser")
buildings = soup.find_all("td", {"class": "", "role": "gridcell"})
building_ids = []

counter = 0
for building in buildings:
    counter = counter + 1
    if counter % 2 == 0:
        continue
    id_start_index = str(building).index("gebaeude=") + 9
    id_end_index = str(building).index('">\n')
    building_ids.append(str(building)[id_start_index:id_end_index])

# Find all rooms by searching through all the individual building pages
room_url = "https://moseskonto.tu-berlin.de/moses/verzeichnis/raeume/gebaeude_info.html?gebaeude="
room_data = {}

for current_id in building_ids:
    page = requests.get(room_url + current_id)
    soup = BeautifulSoup(page.content, "html.parser")
    time.sleep(1)

    counter = 0
    rooms = soup.find_all("td", {"class": "", "role": "gridcell"})

    current_room_id = ""
    current_room_name = ""
    current_room_type = ""
    current_room_seat_count = 0
    for room in rooms:
        if counter % 4 == 0:
            current_room_id = str(room.a.get('href'))[(str(room.a.get('href')).index("raumgruppe=") + 11):]
            current_room_name = str(room.a.string).replace("\n", "")[24:].replace("  ", "")
            if current_room_name[-1] == " ":
                current_room_name = current_room_name[0:len(current_room_name) - 1]
        elif (counter - 1) % 4 == 0:
            current_room_type = str(room.string).replace("\n", "").replace(" ", "")
        elif (counter - 3) % 4 == 0:
            if "Online" in current_room_type:
                continue
            current_room_seat_count = int(str(room.string).replace("\n", "").replace(" ", ""))
            room_data[current_room_id] = {
                "name": current_room_name,
                "type": current_room_type,
                "seat_count": current_room_seat_count
            }
        counter = counter + 1

# Write the dataset to a JSON file
file = open("room_data.json", "w", encoding="utf8")
file.write(str(json.dumps(room_data, indent=4, ensure_ascii=False)))
file.close()
