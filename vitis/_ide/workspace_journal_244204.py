# 2026-08-21T11:31:08.532284464
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="uart_plat")
status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../uart-reg/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../uart-reg/design_1_wrapper.xsa")

status = platform.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../uart-reg/design_1_wrapper.xsa")

status = platform.build()

vitis.dispose()

