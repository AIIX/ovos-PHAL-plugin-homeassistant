from os.path import dirname, join
from ovos_utils.log import LOG
from mycroft_bus_client.message import Message
from ovos_plugin_manager.phal import PHALPlugin
from ovos_utils.gui import GUIInterface
from ovos_PHAL_plugin_homeassistant.logic.connector import HomeAssistantRESTConnector, HomeAssistantWSConnector
from ovos_PHAL_plugin_homeassistant.logic.device import (HomeAssistantSensor,
                                                         HomeAssistantBinarySensor,
                                                         HomeAssistantLight,
                                                         HomeAssistantMediaPlayer,
                                                         HomeAssistantVacuum)
from ovos_PHAL_plugin_homeassistant.logic.integration import Integrator
from ovos_PHAL_plugin_homeassistant.logic.utils import (map_entity_to_device_type, 
                                                        check_if_device_type_is_group)
from ovos_config.config import update_mycroft_config


class HomeAssistantPlugin(PHALPlugin):
    def __init__(self, bus=None, config=None):
        """ Initialize the plugin 

            Args:
                bus (MycroftBusClient): The Mycroft bus client
                config (dict): The plugin configuration
        """
        super().__init__(bus=bus, name="ovos-PHAL-plugin-homeassistant", config=config)
        self.connector = None
        self.registered_devices = []
        self.bus = bus
        self.gui = GUIInterface(bus=self.bus, skill_id=self.name)
        self.integrator = Integrator(self.bus, self.gui)
        self.instance_available = False
        self.device_types = {
            "sensor": HomeAssistantSensor,
            "binary_sensor": HomeAssistantBinarySensor,
            "light": HomeAssistantLight,
            "media_player": HomeAssistantMediaPlayer,
            "vacuum": HomeAssistantVacuum
        }

        # BUS API FOR HOME ASSISTANT
        self.bus.on("ovos.phal.plugin.homeassistant.get.devices",
                    self.handle_get_devices)
        self.bus.on("ovos.phal.plugin.homeassistant.get.device",
                    self.handle_get_device)
        self.bus.on("ovos.phal.plugin.homeassistant.device.turn_on",
                    self.handle_turn_on)
        self.bus.on("ovos.phal.plugin.homeassistant.device.turn_off",
                    self.handle_turn_off)
        self.bus.on("ovos.phal.plugin.homeassistant.get.device.display.model",
                    self.handle_get_device_display_model)
        self.bus.on("ovos.phal.plugin.homeassistant.get.device.display.list.model",
                    self.handle_get_device_display_list_model)
        self.bus.on("ovos.phal.plugin.homeassistant.call.supported.function",
                    self.handle_call_supported_function)

        # GUI EVENTS
        self.bus.on("ovos-PHAL-plugin-homeassistant.home",
                    self.handle_show_dashboard)
        self.bus.on("ovos-PHAL-plugin-homeassistant.close", 
                    self.handle_close_dashboard)
        self.bus.on("ovos.phal.plugin.homeassistant.show.device.dashboard",
                    self.handle_show_device_dashboard)
        self.bus.on("ovos.phal.plugin.homeassistant.update.device.dashboard",
                    self.handle_update_device_dashboard)

        # LISTEN CONFIG CHANGES
        self.bus.on("ovos.phal.plugin.homeassistant.setup.instance",
                    self.setup_configuration)
        self.bus.on("configuration.updated", self.init_configuration)
        self.bus.on("configuration.patch", self.init_configuration)
        
        self.bus.emit(Message("ovos.phal.plugin.homeassistant.integration.query_media", {
            "phrase": "rocketman"
        }))

        self.init_configuration()

# SETUP INSTANCE SUPPORT
    def validate_instance_connection(self, host, api_key):
        """ Validate the connection to the Home Assistant instance

            Args:
                host (str): The Home Assistant instance URL
                api_key (str): The Home Assistant API key

            Returns:
                bool: True if the connection is valid, False otherwise
        """
        try:
            if self.config.get('use_websocket'):
                validator = HomeAssistantWSConnector(host, api_key)
            else:
                validator = HomeAssistantRESTConnector(host, api_key)
            validator.get_all_devices()
            return True
        except Exception as e:
            LOG.error(e)
            return False

    def setup_configuration(self, message):
        """ Handle the setup instance message

            Args:
                message (Message): The message object
        """
        host = message.data.get("url", "")
        key = message.data.get("api_key", "")
        if host and key:
            if self.validate_instance_connection(host, key):
                self.config["host"] = host
                self.config["api_key"] = key
                self.instance_available = True
                config_patch = {
                    "PHAL": {
                        "ovos-PHAL-plugin-homeassistant": {
                            "host": host,
                            "api_key": key
                        }
                    }
                }
                update_mycroft_config(config=config_patch, bus=self.bus)
                self.init_configuration()
                self.bus.emit(Message("ovos-PHAL-plugin-homeassistant.home"))

# INSTANCE INIT OPERATIONS
    def init_configuration(self, message=None):
        """ Initialize instance configuration """
        configuration_host = self.config.get("host", "")
        configuration_api_key = self.config.get("api_key", "")
        if configuration_host != "" and configuration_api_key != "":
            self.instance_available = True
            if self.config.get('use_websocket'):
                self.connector = HomeAssistantWSConnector(configuration_host,
                                                          configuration_api_key)
            else:
                self.connector = HomeAssistantRESTConnector(
                    configuration_host, configuration_api_key)
            self.devices = self.connector.get_all_devices()
            self.registered_devices = []
            self.build_devices()
            self.bus.emit(Message("ovos.phal.plugin.homeassistant.ready"))
        else:
            self.instance_available = False
            self.bus.emit(
                Message("ovos.phal.plugin.homeassistant.requires.configuration"))

    def build_devices(self):
        """ Build the devices from the Home Assistant API """
        for device in self.devices:
            device_type = map_entity_to_device_type(device["entity_id"])
            device_type_is_group = check_if_device_type_is_group(device.get("attributes", {}))
            if device_type is not None:
                if not device_type_is_group:
                    device_id = device["entity_id"]
                    device_name = device.get("attributes", {}).get(
                        "friendly_name", device_id)
                    device_icon = f"mdi:{device_type}"
                    device_state = device.get("state", None)
                    device_attributes = device.get("attributes", {})
                    if device_type in self.device_types:
                        self.registered_devices.append(self.device_types[device_type](
                            self.connector, device_id, device_icon, device_name, device_state, device_attributes))
                    else:
                        LOG.warning(f"Device type {device_type} not supported")
                else:
                    LOG.warning(f"Device type {device_type} is a group, not supported currently")

    def build_display_dashboard_model(self):
        """ Build the dashboard model """
        device_type_model = []
        for device in self.registered_devices:
            device_type = device.device_type
            if device_type not in device_type_model:
                device_type_model.append(device_type)

        display_list_model = []
        for device_type in device_type_model:
            device_type_list_model = []
            for device in self.registered_devices:
                if device.device_type == device_type:
                    device_type_list_model.append(
                        device.get_device_display_model())
            device_human_readable_type = device_type.replace("_", " ").title()
            display_list_model.append({
                "type": device_type,
                "icon": f"mdi:{device_type}",
                "name": device_human_readable_type,
                "devices": device_type_list_model
            })
        return display_list_model

    def build_display_device_model(self, device_type):
        """ Build the device model

        Args:
            device_type (String): The device type to build the model for

        Returns:
            dict: The device model
        """
        device_type_list_model = []
        for device in self.registered_devices:
            if device.device_type == device_type:
                device_type_list_model.append(
                    device.get_device_display_model())
        return device_type_list_model

# BUS API HANDLERS
    def handle_get_devices(self, message):
        """ Handle the get devices message

            Args:
                message (Message): The message object
        """
        self.bus.emit(message.response(data=self.registered_devices))

    def handle_get_device(self, message):
        device_id = message.data.get("device_id", None)
        if device_id is not None:
            for device in self.registered_devices:
                if device.device_id == device_id:
                    self.bus.emit(message.response(data=device))
                    return
        self.bus.emit(message.response(data=None))

    def handle_turn_on(self, message):
        """ Handle the turn on message 

            Args:
                message (Message): The message object
        """
        device_id = message.data.get("device_id", None)
        if device_id is not None:
            for device in self.registered_devices:
                if device.device_id == device_id:
                    response = device.turn_on()
                    self.bus.emit(message.response(data=response))
                    return
        else:
            LOG.warning("No device id provided")

    def handle_turn_off(self, message):
        """ Handle the turn off message

            Args:
                message (Message): The message object
        """
        device_id = message.data.get("device_id", None)
        if device_id is not None:
            for device in self.registered_devices:
                if device.device_id == device_id:
                    response = device.turn_off()
                    self.bus.emit(message.response(data=response))
                    return
        else:
            LOG.error("No device id provided")

    def handle_call_supported_function(self, message):
        """ Handle the call supported function message

        Args:
            message (Message): The message object
        """
        device_id = message.data.get("device_id", None)
        function_name = message.data.get("function_name", None)
        function_args = message.data.get("function_args", None)
        if device_id is not None and function_name is not None:
            for device in self.registered_devices:
                if device.device_id == device_id:
                    if function_args is not None:
                        response = device.call_function(
                            function_name, function_args)
                    else:
                        response = device.call_function(function_name)
                    self.bus.emit(message.response(data=response))
                    return
        else:
            LOG.error("Device id or function name not provided")

    def handle_get_device_display_model(self, message):
        """ Handle the get device display model message

            Args:
                message (Message): The message object
        """
        device_id = message.data.get("device_id", None)
        if device_id is not None:
            for device in self.registered_devices:
                if device.device_id == device_id:
                    self.bus.emit(message.response(
                        data=device.get_device_display_model()))
                    return
        self.bus.emit(message.response(data=None))

    def handle_get_device_display_list_model(self, message):
        """ Handle the get device display list model message 

            Args:
                message (Message): The message object
        """
        display_list_model = {"items": self.build_display_list_model()}
        self.bus.emit(message.response(data=display_list_model))

# GUI INTERFACE HANDLERS
    def handle_show_dashboard(self, message):
        """ Handle the show dashboard message 

            Args:
                message (Message): The message object
        """
        if self.instance_available:
            display_list_model = {
                "items": self.build_display_dashboard_model()}
            self.gui["dashboardModel"] = display_list_model
            self.gui["instanceAvailable"] = True
            self.gui.send_event("ovos.phal.plugin.homeassistant.change.dashboard", {
                                "dash_type": "main"})
            page = join(dirname(__file__), "ui", "Dashboard.qml")
            self.gui.show_page(page, override_idle=True)
        else:
            self.gui["dashboardModel"] = {"items": []}
            self.gui["instanceAvailable"] = False
            self.gui.send_event("ovos.phal.plugin.homeassistant.change.dashboard", {
                                "dash_type": "main"})
            page = join(dirname(__file__), "ui", "Dashboard.qml")
            self.gui.show_page(page, override_idle=True)
            
    def handle_close_dashboard(self, message):
        """ Handle the close dashboard message

            Args:
                message (Message): The message object
        """
        self.gui.release()

    def handle_show_device_dashboard(self, message):
        """ Handle the show device dashboard message 

            Args:
                message (Message): The message object
        """
        device_type = message.data.get("device_type", None)
        if device_type is not None:
            self.gui["deviceDashboardModel"] = {
                "items": self.build_display_device_model(device_type)}
            self.gui.send_event("ovos.phal.plugin.homeassistant.change.dashboard", {
                                "dash_type": "device"})

    def handle_update_device_dashboard(self, message):
        """ Handle the update device dashboard message 

            Args:
                message (Message): The message object
        """
        device_type = message.data.get("device_type", None)
        if device_type is not None:
            self.gui["deviceDashboardModel"] = {
                "items": self.build_display_device_model(device_type)}
