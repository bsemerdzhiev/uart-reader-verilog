# 2026-08-21T00:48:30.494279402
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "uart",hw_design = "$COMPONENT_LOCATION/../../uart-reg/design_1_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="uart_app",platform = "$COMPONENT_LOCATION/../uart/export/uart/uart.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="uart")
status = platform.build()

comp = client.get_component(name="uart_app")
comp.build()

status = platform.build()

client.delete_component(name="uart")

client.delete_component(name="uart_app")

platform = client.create_platform_component(name = "uart_plat",hw_design = "$COMPONENT_LOCATION/../../uart-reg/design_1_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../uart_plat/export/uart_plat/uart_plat.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="uart_plat")
status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

component = client.get_component(name="app_component")

lscript = component.get_ld_script(path="/home/borislav/Documents/uart-reg/vitis/app_component/src/lscript.ld")

lscript.regenerate()

status = platform.build()

comp.build()

client.delete_component(name="app_component")

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../uart_plat/export/uart_plat/uart_plat.xpfm",domain = "standalone_ps7_cortexa9_0")

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

