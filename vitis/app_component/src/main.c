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

  int32_t EMIO_START = 54;

  // EMIO pin 14 RX (needs to be set to write)
  XGpioPs_SetDirectionPin(&Gpio, 0 + EMIO_START, 1);
  XGpioPs_SetOutputEnablePin(&Gpio, 0 + EMIO_START, 1);

  // EMIO pin 15 TX (needs to be set to read)
  XGpioPs_SetDirectionPin(&Gpio, 1 + EMIO_START, 0);

  while (1) {
    volatile int32_t val_from_mio = XGpioPs_ReadPin(&Gpio, 14);

    // write to EMIO
    XGpioPs_WritePin(&Gpio, 0 + EMIO_START, val_from_mio);

    volatile int32_t val_from_emio = XGpioPs_ReadPin(&Gpio, 1 + EMIO_START);

    // write to MIO
    XGpioPs_WritePin(&Gpio, 15, val_from_emio);

    //xil_printf("%d %d\r\n", val_from_mio, val_from_emio);
  }

  return 0;
}
