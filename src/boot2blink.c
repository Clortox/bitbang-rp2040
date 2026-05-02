#include <stdbool.h>
#include <stdint.h>

#define RESETS_RESET *(volatile uint32_t *)(0x4000c000)
#define RESETS_RESET_DONE *(volatile uint32_t *)(0x4000c008)
#define IO_BANK0_GPIO25_CTRL *(volatile uint32_t *)(0x400140cc)
#define SIO_GPIO_OE_SET *(volatile uint32_t *)(0xd0000024)
#define SIO_GPIO_OUT_XOR *(volatile uint32_t *)(0xd000001c)

__attribute__((section(".boot2"))) void bootStage2(void) {
  RESETS_RESET &= ~(1 << 5);
  while (!(RESETS_RESET_DONE & (1 << 5)))
    ;

  IO_BANK0_GPIO25_CTRL = 5;
  // this sets gpio as output
  SIO_GPIO_OE_SET |= 1 << 25;

  while (true) {
    for (uint32_t i = 0; i < 100000; ++i)
      ;
    // toggle
    SIO_GPIO_OUT_XOR |= 1 << 25;
  }
}
