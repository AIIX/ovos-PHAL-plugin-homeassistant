# OVOS PHAL Home Assistant Plugin

The PHAL Plugin provides GUI interfaces and API for Home Assistant Instants.

# Demo GIF
![HomeAssistant PHAL Demo](demo/demo.gif)

### Installation

Plugin Support Two Installation Methods:
1. Install from Github URL

Note: PIP install from URL will not install the .desktop file and icon if installing to a venv or virtual environment, so you need to manually install them to the system or user directory.

Note: PIP install will attempt to install the .desktop file and icon to the system directory, or user directory if the system directory is not writable. If this is not a virtual environemnt.

```bash
pip install git+https://github.com/AIIX/ovos-PHAL-plugin-homeassistant
```

2. Manual Install from Git Clone
```bash
git clone https://github.com/AIIX/ovos-PHAL-plugin-homeassistant
cd ovos-PHAL-plugin-homeassistant
cp -r res/desktop/ovos-phal-homeassistant.desktop ~/.local/share/applications/
cp -r res/icon/ovos-phal-homeassistant.png ~/.local/share/icons/
pip install .
```

### Configuration (Instance Setup)

Plugin Supports Two Configuration Methods:
1. Using the GUI
   - Install the plugin
   - Open the application from the homescreen menu
   - Click the "Connect Instance" button
   - Enter the URL of the Home Assistant Instance
   - Enter the Long-Lived Access Token (API KEY)
   - Press the "Confirm" button 

2. Manually Editing the Config File
   - Add the following to the config file:
   ```json
        "PHAL": {
            "ovos-PHAL-plugin-homeassistant": {
                "host": "https://someurl.toinstance",
                "api_key": "api key from the instance"
            }
        }
   ```

### Usage

The plugin provides a GUI interface for Home Assistant Instances. It also provides an API for other plugins or skills to user.

The plugin is in early development, so there are some features that are not yet implemented. It currently supports the following entities:
- Media Player
- Light
- Vacuum
- Binary Sensor
- Sensor

---------------------------------------  
#### BUS API (For Other Plugins / GUIs) - WIP / TODO Documentation
#### EXPANDING DEVICE / ENTITY SUPPORT - WIP / TODO Documentation