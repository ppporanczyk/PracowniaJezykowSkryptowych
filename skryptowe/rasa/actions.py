from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals


from rasa_sdk import Action
import json
from rasa_sdk.events import SlotSet

class OpeningHours(Action):
	def name(self):
		return "opening_hours"
		
	def run(self, dispatcher, tracker, domain):
		slot_day = tracker.get_slot('ask_day')
		slot_hour = tracker.get_slot('ask_hour')
		print(slot_day,slot_hour)
		try:
			with open('data/opening_hours.json') as opening_file:
				data = json.load(opening_file)
				week = data['items']
				response=""
				
				if slot_day:
					slot_day = slot_day[0].upper() + slot_day[1:].lower()
					if slot_hour:
						response += self.specified_hour(week, slot_day, int(slot_hour))
					else:
						response += self.specified_date(week, slot_day)
				else:
					for day in  week:
						if slot_hour:
							response += self.specified_hour(week, day, int(slot_hour))
						else:
							response += self.specified_date(week, day)
								
				dispatcher.utter_message(response)
		except ValueError as e:
			print(e)
		
		return [SlotSet("ask_day",None),SlotSet("ask_hour",None)]
	
	def specified_hour(self, data, day, hour):
		response=""
		if data[day]['open']>hour or data[day]['close']<=hour:
			if data[day]['open']==0 and data[day]['close']==0:
				response += """On {} we are closed\n""".format(day.lower())
			else:
				response +=  """We are closed at this time, visit us from {} to {}\n""".format(data[day]['open'], data[day]['close'])
		else:
			response += """Yes! On {} we are open from {} to {}\n""".format(day.lower(), data[day]['open'], data[day]['close'])
		return response
		
		
	def specified_date(self, data, day):
		response=""
		if data[day]['open']==0 and data[day]['close']==0:
			response += """On {} we are closed\n""".format(day.lower())
		else:
			response += """On {} we are open from {} to {}\n""".format(day.lower(), data[day]['open'], data[day]['close'])
		return response
		
class ShowMenu(Action):
	def name(self):
		return "show_menu"
		
	def run(self, dispatcher, tracker, domain):
		try:
			with open('data/menu.json') as menu_file:
				data = json.load(menu_file)
				response=""
				for meal in  data['items']:
					response += """{} - {}$\n\n""".format(meal['name'], meal['price'])							
				dispatcher.utter_message(response)
		except ValueError as e:
			print(e)
		return []
		
class PlaceAnOrder(Action):
	def name(self):
		return "place_an_order"
		
	def run(self, dispatcher, tracker, domain):
		slot_meal = tracker.get_slot('meal')
		list_meal = slot_meal.split(",")
		user_order = []
		unproper_order = None
		try:
			with open('data/menu.json') as menu_file:
				data = json.load(menu_file)
				data = data['items']
				response=""
				menu = [meal["name"] for meal in  data]
				for meal in list_meal:
					meal= meal.lower()
					single_pos = None
					for position_menu in menu:
						if position_menu.lower() in meal:
							single_pos = self.read_meal(meal,position_menu)
							break
					if single_pos:
						user_order.append(single_pos)
					else:
						unproper_order = """\nWe do not have this position in our menu: """ + meal
						
				response+="""Your order:\n"""
				for pos in user_order:
					response+="""{} x{}\n""".format(pos['meal'],pos['number'])
					if pos['extra']:
						response+="""\t {}\n""".format(pos['extra'])
						
				cost = self.count_bill(user_order, data)
				if unproper_order:
					response+=unproper_order
				response+="""\nIn total {}$\n""".format(cost)
				dispatcher.utter_message(response)
				
		except ValueError as e:
			print(e)
		return []

	def read_meal(self, meal,position_menu):
		print(meal)
		single_pos = dict()
		single_pos['meal']=position_menu
		opt_list = ['with', 'without','no']
		meal=meal.strip()
		first_word = meal.split(" ")[0]
		if first_word.isdigit():
			single_pos['number'] = int(first_word)
		else:
			single_pos['number'] = 1
		single_pos['extra']=None	
		for opt in opt_list:
			if opt in meal:
				index = meal.index(opt)
				single_pos['extra']=meal[index:]
				
		return single_pos
		
	def count_bill(self, user_order,data):
		result = 0
		for order in user_order:
			name =order['meal'][0].upper() + order['meal'][1:].lower()
			for elem in data:
				if elem['name'] ==name:
					result+=elem['price']*order['number']
					break
		return result
		
