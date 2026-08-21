#include <array>
#include <cerrno>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <endian.h>
#include <fcntl.h>
#include <iostream>
#include <termios.h>
#include <unistd.h>

int open_uart(const char *device) {
  int fd = open(device, O_RDWR | O_NOCTTY | O_SYNC);
  if (fd < 0) {
    fprintf(stderr, "Failed to open %s: %s\n", device, strerror(errno));
    return -1;
  }

  termios tty{};
  if (tcgetattr(fd, &tty) != 0) {
    fprintf(stderr, "tcgetattr failed: %s\n", strerror(errno));
    close(fd);
    return -1;
  }

  cfsetispeed(&tty, B110);
  cfsetospeed(&tty, B110);

  tty.c_cflag &= ~PARENB; // no parity
  tty.c_cflag &= ~CSTOPB; // 1 stop bit
  tty.c_cflag &= ~CSIZE;
  tty.c_cflag |= CS8;      // 8 data bits
  tty.c_cflag &= ~CRTSCTS; // no hardware flow control
  tty.c_cflag |= CREAD | CLOCAL;

  tty.c_lflag &= ~ICANON; // raw mode, not line-buffered
  tty.c_lflag &= ~(ECHO | ECHOE | ISIG);
  tty.c_iflag &= ~(IXON | IXOFF | IXANY); // no software flow control
  tty.c_oflag &= ~OPOST;                  // raw output, no processing

  tty.c_cc[VMIN] = 0;  // block until 1 byte (response size) arrives...
  tty.c_cc[VTIME] = 4; // ...or 4 second (40 deciseconds) timeout

  if (tcsetattr(fd, TCSANOW, &tty) != 0) {
    fprintf(stderr, "tcsetattr failed: %s\n", strerror(errno));
    close(fd);
    return -1;
  }

  return fd;
}

void write_to_register(int32_t fd, uint8_t address, int64_t value) {
  std::array<uint8_t, 10> request = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  request[0] = 0x01;

  request[1] = address;

  request[2] = 0x21;

  // memcpy(&request[2], &value, 8);

  write(fd, &request, sizeof(request));

  uint8_t res;

  read(fd, &res, 1);

  std::cout << int32_t(res) << "\n";

  if (res != 0x01) {
    std::cout << "Could not write!\n";
  } else {
    std::cout << "Successful write\n";
  }
}

int64_t read_from_register(int32_t fd, uint8_t address) {
  std::array<uint8_t, 2> request;

  request[0] = 0x02;

  request[1] = address;

  write(fd, &request, sizeof(request));

  std::array<uint8_t, 9> response;

  for (int32_t i{0}; i < 9; i++) {
    read(fd, &response[i], 1);
  }

  for (int32_t i{0}; i < 9; i++) {
    std::cout << int32_t(response[i]) << "\n";
  }

  // uint64_t ans = 0;
  // for (int32_t i{0}; i < 8; i++) {
  //   ans |= (response[i + 1] << (i * 8));
  // }
  // memcpy(&ans, &response[1], 8);
  // ans = __bswap_64(ans);
  // std::cout << ans << "\n";

  std::cout << "end\n";
  if (response[0] != 0x02) {
    std::cout << "Could not read!\n";
    return -1;
  }

  return -1;
}

int main() {
  int fd = open_uart("/dev/ttyUSB1");
  if (fd < 0)
    return 1;
  tcflush(fd, TCIOFLUSH);

  // write_to_register(fd, 0, 20);

  std::cout << read_from_register(fd, 0) << "\n";

  close(fd);
  return 0;
}
