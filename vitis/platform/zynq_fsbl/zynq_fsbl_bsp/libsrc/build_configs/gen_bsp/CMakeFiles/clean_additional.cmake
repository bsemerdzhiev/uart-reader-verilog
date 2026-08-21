# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/borislav/Documents/uart-reg/vitis/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
