# Utils for the plugin

def map_entity_to_device_type(entity):
    """Map an entity to a device type.

    Args:
        entity (str): The entity to map.
    """
    if entity.startswith("sensor."):
        return "sensor"
    elif entity.startswith("binary_sensor."):
        return "binary_sensor"
    elif entity.startswith("cover."):
        return "cover"
    elif entity.startswith("light."):
        return "light"
    elif entity.startswith("switch."):
        return "switch"
    elif entity.startswith("media_player."):
        return "media_player"
    elif entity.startswith("climate."):
        return "climate"
    elif entity.startswith("vacuum."):
        return "vacuum"
    else:
        return None
