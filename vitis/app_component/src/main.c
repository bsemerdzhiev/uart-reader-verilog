#include "xgpiops.h"
#include <xparameters.h>

int main() {
    XGpioPs Gpio;
    XGpioPs_Config *ConfigPtr;

    ConfigPtr = XGpioPs_LookupConfig(XPAR_XGPIOPS_0_BASEADDR);
    XGpioPs_CfgInitialize(&Gpio, ConfigPtr, ConfigPtr->BaseAddr);

    // MIO 14 = RX, leave as input (default)
    XGpioPs_SetDirectionPin(&Gpio, 14, 0);

    // MIO 15 = TX, set as output and enable the driver
    XGpioPs_SetDirectionPin(&Gpio, 15, 1);
    XGpioPs_SetOutputEnablePin(&Gpio, 15, 1);

    while (1) {
        // nothing else needed — hardware handles RX/TX from here
    }

    return 0;
}