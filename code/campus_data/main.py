import json

if __name__ == '__main__':

    with open("/Users/x/Desktop/campus_app/code/campus_data/course_data_indexed.json") as course_file:
        with open("/Users/x/Desktop/campus_app/code/campus_data/room_data.json") as room_file:
            course_data = json.load(course_file)
            room_data = json.load(room_file)

            course_keys = []
            for key in course_data:
                course_keys.append(key)

            room_keys = []
            for key in room_data:
                room_keys.append(key)

            for course_key in course_keys:
                for event in course_data[course_key]["events"]:
                    event["room_ids"] = []
                    for room in event["rooms"]:
                        for room_key in room_keys:
                            if room in room_data[room_key]["name"] or room_data[room_key]["name"] in room:
                                event["room_ids"].append(room_key)

            file = open("course_data_indexed.json", "w", encoding="utf8")
            file.write(str(json.dumps(course_data, indent=4, ensure_ascii=False)))
            file.close()
