import json
import requests
from bs4 import BeautifulSoup
import time
from os import listdir
from os.path import isfile, join
import pandas
from difflib import get_close_matches

# Path, that contains all CSV timetable files downloaded from
# https://moseskonto.tu-berlin.de/moses/verzeichnis/veranstaltungen/raum.html?raumgruppe=31&search=true, etc.
path_to_csv_timetables = "..."
csv_files = [f for f in listdir(path_to_csv_timetables) if isfile(join(path_to_csv_timetables, f))]
course_data = {}

# Read all courses from ISIS
isis_course_links = {}
page_counter = 0
url = "https://isis.tu-berlin.de/course/search.php?excludearchived=1&perpage=50&page=" + str(page_counter)
page = requests.get(url)
soup = BeautifulSoup(page.content, "html.parser")
time.sleep(1)
courses_current_page = soup.find_all("h3", {"class": "coursename"})

while len(courses_current_page) > 0:
    for course in courses_current_page:
        isis_course_links[course.a.string] = course.a.get("href")
    page_counter = page_counter + 1
    url = "https://isis.tu-berlin.de/course/search.php?excludearchived=1&perpage=50&page=" + str(page_counter)
    page = requests.get(url)
    soup = BeautifulSoup(page.content, "html.parser")
    time.sleep(1)
    courses_current_page = soup.find_all("h3", {"class": "coursename"})

# Go through every CSV file and write data for every course into the course_data dictionary
for csv_file in csv_files:
    if ".csv" in csv_file:
        content = pandas.read_csv(path_to_csv_timetables + str(csv_file), sep=";")
        for row in content.itertuples():
            currentKey = row[2]
            if currentKey in course_data.keys():
                course_data[currentKey]["events"].append(
                    {
                        "rooms": str(row[8]).split(", "),
                        "iso_start": row[9],
                        "iso_end": row[10]
                    }
                )
            else:
                studies = []
                if len(str(row[5])) != 0:
                    studies = str(row[5]).split(", ")

                course_name = row[1]
                print(course_name)
                if len(row[1].split(" (")) > 0:
                    course_name = row[1].split(" (")[0]

                # Get course information from MOSES
                url = "https://moseskonto.tu-berlin.de/moses/modultransfersystem/bolognamodule/suchen.html?text=" + course_name + "&modulversionGueltigkeitSemester=71"
                page = requests.get(url)
                soup = BeautifulSoup(page.content, "html.parser")
                time.sleep(1)

                moses_course_link = ""
                potential_moses_course_links = soup.findAll("a", {"title": "Modulbeschreibung anzeigen"})
                for link in potential_moses_course_links:
                    if link.string == course_name:
                        moses_course_link = link.get("href")
                        break

                if len(moses_course_link) == 0 and len(potential_moses_course_links) > 0:
                    moses_course_link = potential_moses_course_links[0].get("href")

                course_ects = 0
                course_supervisor = ""
                course_faculty = ""
                course_institute = ""
                course_department = ""
                course_email = ""
                course_learning_outcomes = ""
                course_content = ""
                course_semester = ""
                course_type_of_exam = ""
                course_language = ""
                course_grading = ""
                if len(moses_course_link) > 0:
                    page = requests.get(moses_course_link)
                    soup = BeautifulSoup(page.content, "html.parser")
                    time.sleep(1)

                    parent_data = soup.find_all("label")
                    for label in parent_data:
                        if len(label.parent.contents) < 3:
                            continue

                        label_title = label.string
                        label_siblings = label.parent.contents
                        if label_title == "Leistungspunkte:":
                            course_ects = int(label_siblings[3].string)
                        elif label_title == "Modulverantwortliche*r:":
                            course_supervisor = str(label_siblings[3].string)
                        elif label_title == "Fakultät:":
                            course_faculty = str(label_siblings[3].string).replace("  ", "").replace("\n", "")
                        elif label_title == "Institut:":
                            course_institute = str(label_siblings[4].string).replace("  ", "").replace("\n", "")
                        elif label_title == "Fachgebiet:":
                            course_department = str(label_siblings[4]).replace("  ", "").replace("\n", "")
                        elif label_title == "E-Mail-Adresse:":
                            course_email = str(label_siblings[3].string).replace("  ", "").replace("\n", "")

                    text_areas = soup.find_all("span", {"class": "preformatedTextarea"})
                    course_learning_outcomes = str(text_areas[0].string)
                    course_content = str(text_areas[1].string)

                    strong_texts = soup.find_all("strong")
                    course_semester = str(strong_texts[5].string)

                    course_type_of_exam = str(soup.find("span", {"class": "fa fa-legal fa-space"}).parent.parent.contents[2]).replace("  ", "").replace("\n", "")
                    course_language = str(soup.find("span", {"class": "fa fa-globe fa-space"}).parent.parent.contents[2]).replace("  ", "").replace("\n", "")
                    course_grading = str(soup.find("span", {"class": "fa fa-star-half-o fa-space"}).parent.parent.contents[2]).replace("  ", "").replace("\n", "")

                isis_course_link = ""
                potential_isis_courses = []
                for isis_link_name in list(isis_course_links.keys()):
                    if course_name in isis_link_name:
                        potential_isis_courses.append(isis_link_name)

                if len(potential_isis_courses) > 0:
                    isis_course_link = isis_course_links[potential_isis_courses[0]]

                course_data[currentKey] = {
                    "name": course_name,
                    "full_name": currentKey,
                    "type": row[3],
                    "studies": studies,
                    "ects": course_ects,
                    "supervisor": course_supervisor,
                    "faculty": course_faculty,
                    "institute": course_institute,
                    "department": course_department,
                    "email": course_email,
                    "learning_outcomes": course_learning_outcomes,
                    "description": course_content,
                    "exam_type": course_type_of_exam,
                    "language": course_language,
                    "grading": course_grading,
                    "moses_link": moses_course_link,
                    "isis_link": isis_course_link,
                    "events": [
                        {
                            "rooms": str(row[8]).split(", "),
                            "iso_start": row[9],
                            "iso_end": row[10]
                        }
                    ]
                }

# Write the dataset to a JSON file
file = open("course_data.json", "w", encoding="utf8")
file.write(str(json.dumps(course_data, indent=4, ensure_ascii=False)))
file.close()