extends Label

@onready var date_timer = $dateTimer
@onready var date_label = $"."

# Variables to track the current in-game date
var current_date = { "day": 1, "month": 1, "year": 2002 }

# List of month names and their respective day counts (not accounting for leap years)
var months = [
	{ "name": "Jan.", "days": 31 },
	{ "name": "Feb.", "days": 28 },
	{ "name": "Mar.", "days": 31 },
	{ "name": "Apr.", "days": 30 },
	{ "name": "May.", "days": 31 },
	{ "name": "Jun.", "days": 30 },
	{ "name": "Jul.", "days": 31 },
	{ "name": "Aug.", "days": 31 },
	{ "name": "Sep.", "days": 30 },
	{ "name": "Oct.", "days": 31 },
	{ "name": "Nov.", "days": 30 },
	{ "name": "Dec.", "days": 31 }
]

func _ready():
	Global.DATE = get_formatted_date()
	date_label.text = Global.DATE

func _on_date_timer_timeout():
	increment_date()
	Global.DATE = get_formatted_date()
	date_label.text = Global.DATE
	date_timer.start()


# Function to check if a year is a leap year
func is_leap_year(year):
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

# Function to increase the date by 1 day
func increment_date():
	current_date["day"] += 1

	# Get the current month index
	var month_index = current_date["month"] - 1

	# Adjust for leap years in February
	var days_in_month = months[month_index]["days"]
	if month_index == 1 and is_leap_year(current_date["year"]): # February in a leap year
		days_in_month = 29

	# Check if the day exceeds the number of days in the current month
	if current_date["day"] > days_in_month:
		current_date["day"] = 1
		current_date["month"] += 1

		# Check if the month exceeds December
		if current_date["month"] > 12:
			current_date["month"] = 1
			current_date["year"] += 1

# Function to get the formatted date as a string
func get_formatted_date():
	var month_name = months[current_date["month"] - 1]["name"]
	return "%s %d, %d" % [month_name, current_date["day"], current_date["year"]]
