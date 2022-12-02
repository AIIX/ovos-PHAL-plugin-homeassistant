import requests
import json
import sys
from ovos_utils.log import LOG

class HomeAssistantConnector:
    def __init__(self, host, api_key):
        """ Constructor 

        Args:
            host (str): The host of the home assistant instance.
            api_key (str): The api key
        """
        self.host = host
        self.api_key = api_key
        self.headers = {'Authorization': 'Bearer ' +
                        api_key, 'content-type': 'application/json'}

    def get_all_devices(self):
        """ Get all devices from home assistant. """
        url = self.host + ":8123/api/states"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print("Error connecting to home assistant")
            sys.exit(1)

    def get_device_state(self, device_id):
        """ Get the state of a device. """
        url = self.host + ":8123/api/states/" + device_id
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print("Error connecting to home assistant")
            sys.exit(1)

    def set_device_state(self, device_id, state, attributes=None):
        """ Set the state of a device. 

        Args:
            device_id (str): The id of the device.
            state (str): The state to set.
            attributes (dict): The attributes to set. 
        """
        url = self.host + ":8123/api/states/" + device_id
        payload = {'state': state, 'attributes': attributes}
        response = requests.post(
            url, data=json.dumps(payload), headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print("Error connecting to home assistant")
            sys.exit(1)

    def get_all_devices_with_type(self, device_type):
        """ Get all devices with a specific type. 

        Args:
            device_type (str): The type of the device.
        """
        devices = self.get_all_devices()
        return [device for device in devices if device["entity_id"].startswith(device_type)]

    def get_all_devices_with_type_and_attribute(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """
        devices = self.get_all_devices()
        return [device for device in devices if device["entity_id"].startswith(device_type) and device["attributes"][attribute] == value]

    def get_all_devices_with_type_and_attribute_in(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """
        devices = self.get_all_devices()
        return [device for device in devices if device["entity_id"].startswith(device_type) and device["attributes"][attribute] in value]

    def get_all_devices_with_type_and_attribute_not_in(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """
        devices = self.get_all_devices()
        return [device for device in devices if device["entity_id"].startswith(device_type) and device["attributes"][attribute] not in value]

    def turn_on(self, device_id, device_type):
        """ Turn on a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
        """
        url = self.host + ":8123/api/services/" + device_type + "/turn_on"
        payload = {'entity_id': device_id}
        response = requests.post(
            url, data=json.dumps(payload), headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)

    def turn_off(self, device_id, device_type):
        """ Turn off a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
        """
        url = self.host + ":8123/api/services/" + device_type + "/turn_off"
        payload = {'entity_id': device_id}
        response = requests.post(
            url, data=json.dumps(payload), headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)

    def call_function(self, device_id, device_type, function, arguments=None):
        """ Call a function on a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
            function (str): The function to call.
            arguments (dict): The arguments to pass to the function.
        """
        url = self.host + ":8123/api/services/" + device_type + "/" + function
        payload = {'entity_id': device_id}
        if arguments:
            for key, value in arguments.items():
                payload[key] = value

        response = requests.post(
            url, data=json.dumps(payload), headers=self.headers)
        
        if response.status_code == 200:
            return json.loads(response.text)