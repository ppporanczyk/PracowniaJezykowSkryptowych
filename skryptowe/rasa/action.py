from rasa_sdk import Action
import json
from rasa_sdk.events import SlotSet

class OpeningHours(Action):
	def name(self):
		return 'opening_hours'
		
	def run(self, dispatcher, tracker, domain):
		opening_file = open('./data/opening_hours.json')
		data = json.load(opening_file)
		response=""
		for key,val in data[items]:
			if val['open']==0 and ['close']==0:
				response += """{}: closed\n""".format(key)
			else:
				response += """{}: from {} to {}\n""".format(key, val['open'], val['close'])
						
		dispatcher.utter_message(response)
		
		
		return [SlotSet('is_opened',true)]
		
class ShowMenu(Action):
	def name(self):
		return 'show_menu'
		
	def run(self, dispatcher, tracker, domain):

		return []
		
class PlaceAnOrder(Action):
	def name(self):
		return 'place_an_order'
		
	def run(self, dispatcher, tracker, domain):

		return []
