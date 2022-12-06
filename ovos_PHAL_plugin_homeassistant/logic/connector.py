import asyncio
from abc import abstractmethod
from typing import Optional, List

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

    @abstractmethod
    def get_all_devices(self) -> List[dict]:
        """
        Get a list of all devices.
        """

    @abstractmethod
    def get_device_state(self, entity_id: str):
        """
        Get the state of a device.
        Args:
            entity_id (str): HomeAssistant Device ID
        """

    @abstractmethod
    def set_device_state(self, entity_id: str, state: str,
                         attributes: Optional[dict] = None):
        """ Set the state of a device.

        Args:
            entity_id (str): The id of the device.
            state (str): The state to set.
            attributes (dict): The attributes to set.
        """

    @abstractmethod
    def get_all_devices_with_type(self, device_type):
        """ Get all devices with a specific type.

        Args:
            device_type (str): The type of the device.
        """

    @abstractmethod
    def get_all_devices_with_type_and_attribute(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """

    @abstractmethod
    def get_all_devices_with_type_and_attribute_in(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """

    @abstractmethod
    def get_all_devices_with_type_and_attribute_not_in(self, device_type, attribute, value):
        """ Get all devices with a specific type and attribute.

        Args:
            device_type (str): The type of the device.
            attribute (str): The attribute to check.
            value (str): The value of the attribute.
        """

    @abstractmethod
    def turn_on(self, device_id, device_type):
        """ Turn on a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
        """

    @abstractmethod
    def turn_off(self, device_id, device_type):
        """ Turn off a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
        """

    @abstractmethod
    def call_function(self, device_id, device_type, function, arguments=None):
        """ Call a function on a device.

        Args:
            device_id (str): The id of the device.
            device_type (str): The type of the device.
            function (str): The function to call.
            arguments (dict): The arguments to pass to the function.
        """


class HomeAssistantRESTConnector(HomeAssistantConnector):
    def __init__(self, host, api_key):
        super().__init__(host, api_key)
        self.headers = {'Authorization': 'Bearer ' +
                        self.api_key, 'content-type': 'application/json'}

    def get_all_devices(self):
        """ Get all devices from home assistant. """
        url = self.host + ":8123/api/states"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print("Error connecting to home assistant")
            sys.exit(1)

    def get_device_state(self, entity_id):
        """ Get the state of a device. """
        url = self.host + ":8123/api/states/" + entity_id
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print("Error connecting to home assistant")
            sys.exit(1)

    def set_device_state(self, entity_id, state, attributes=None):
        """ Set the state of a device. 

        Args:
            entity_id (str): The id of the device.
            state (str): The state to set.
            attributes (dict): The attributes to set. 
        """
        url = self.host + ":8123/api/states/" + entity_id
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


class HomeAssistantWSConnector(HomeAssistantConnector):
    def __init__(self, host, api_key):
        super().__init__(host, api_key)
        if self.host.startswith('http'):
            self.host.replace('http', 'ws', 1)

        import asyncio
        from hass_client.client import HomeAssistantClient
        self._loop = asyncio.get_event_loop()
        self.client: HomeAssistantClient = self._loop.run_until_complete(
            self.start_client())

    async def start_client(self):
        from hass_client.client import HomeAssistantClient

        client = HomeAssistantClient(self.host, self.api_key)
        await client.connect()
        return client

    @staticmethod
    def _device_entry_compat(devices: dict):
        disabled_devices = list()
        for idx, dev in devices.items():
            if dev.get('disabled_by'):
                LOG.debug(f'Ignoring {dev.get("entity_id")} disabled by '
                          f'{dev.get("disabled_by")}')
                disabled_devices.append(idx)
            else:
                devices[idx].setdefault('type', dev['entity_id'].split('.', 1)[0])
        for idx in disabled_devices:
            devices.pop(idx)

    def get_all_devices(self) -> list:
        devices = self.client.entity_registry
        self._device_entry_compat(devices)
        return list(devices.values())

    def get_device_state(self, entity_id: str) -> dict:
        return self.client.get_state(entity_id, attribute="")

    def set_device_state(self, entity_id: str, state: str, attributes: Optional[dict] = None):
        self.client.set_state(entity_id, state, attributes)

    def get_all_devices_with_type(self, device_type):
        devices = self.get_all_devices()
        return [d for d in devices if d.get('type') == device_type]

    def get_all_devices_with_type_and_attribute(self, device_type, attribute, value):
        devices = self.get_all_devices()
        return [d for d in devices if d['attributes'].get(attribute) == value]

    def get_all_devices_with_type_and_attribute_in(self, device_type, attribute, value):
        devices = self.get_all_devices()
        return [d for d in devices if d['attributes'].get(attribute) in value]

    def get_all_devices_with_type_and_attribute_not_in(self, device_type, attribute, value):
        devices = self.get_all_devices()
        return [d for d in devices if d['attributes'].get(attribute) not in value]

    def turn_on(self, device_id, device_type):
        LOG.debug(f"Turn on {device_id}")
        self._loop.run_until_complete(
            self.client.call_service(device_type, 'turn_on',
                                     {'entity_id': device_id}))

    def turn_off(self, device_id, device_type):
        LOG.debug(f"Turn off {device_id}")
        self._loop.run_until_complete(
            self.client.call_service(device_type, 'turn_off',
                                     {'entity_id': device_id}))

    def call_function(self, device_id, device_type, function, arguments=None):
        arguments = arguments or dict()
        arguments['entity_id'] = device_id
        self._loop.run_until_complete(
            self.client.call_service(device_type, function, arguments))
