## Versions:
(STM8S003F3P6 pinout)
- UART_Hardware: UART1 TX pin 2; RX pin 3 (115200 bauds) 547 bytes (original code)
- - Application address 0x8280 (Free 7645 bytes)

- UART_Software: UART1 TX pin 15; RX pin 14 (9600 bauds) 935 bytes (by timers)
- - Application address 0x83C0 (Free 7257 bytes)

- No bootloader: application address 0x8000 (Free 8192 bytes)

- See also Makefile for changing application address
- - (LDFLAGS += --code-loc 0x83C0)

## stm8-bootloader
Serial bootloader for STM8S and STM8L microcontrollers. A detailed write-up on this bootloader is posted [here](https://lujji.github.io/blog/serial-bootloader-for-stm8).

(Backup PDF in the Doc folder)

## Features

* **small** - fits in 547 bytes (SDCC v3.6.8 #9951)
* **fast** - uploads 4k binary in 1 second @115200bps
* **configurable** - can be adjusted for parts with different flash block size

## Configuration

The default configuration targets low-density devices (STM8S003). To compile for a different target `MCU` and `FAMILY` makefile variables are adjusted accordingly.

Bootloader configuration is located in `config.h`.
* **BLOCK_SIZE** - flash block size according to device datasheet. This should be set to 64 for low-density devices or 128 for devices with >8k flash.
* **BOOT_ADDR** - application boot address.
* **BOOT_PIN** - entry jumper. This is set to PD3 by default.
* **RELOCATE_IVT** - when set to 1 (default) the interrupt vectors are relocated. When set to 0 the bootloader will overwrite it's own interrupt vector table with the application's IVT, thus eliminating additional CPU overhead during interrupts. Write-protection cannot be used in this case and resulting binary is slightly larger.

### Changing boot address
Boot address must be a multiple of BLOCK_SIZE. Address is set in 2 places:
 * config.h
 * init.s

Main application is compiled with `--code-loc <address>` option. When RELOCATE_IVT is set to 0, 0x80 must be subtracted from application address and isr29 must be implemented: `void dummy_isr() __interrupt(29) __naked { ; }`.

## Build instructions
Build and flash the bootloader:

``` bash
$ make && make flash
```

Enable write-protection (UBC) on pages 0-9 _(TODO: must be adjusted for STML)_:

``` bash
$ make opt-set
```

## Uploading the firmware

- Bootloader: [UART_Hardware](https://github.com/rtek1000/stm8-bootloader/tree/master/UART_Hardware)

There is a demo application inside `app` directory (0x8280) which toggles PD4 via interrupts. To upload the application short PD3 to ground, power-cycle the MCU and run the uploader utility. DTR pin on UART-USB converter (TTL level only: 5V) can be connected to RESET pin on STM8 for automatic reset.

(boot.py: 115200 bauds)

``` bash
$ cd app && make
$ python ../uploader/boot.py -p /dev/ttyUSB0 firmware.bin
```
## Uploading the firmware (board W1209)

- Bootloader: [USART_Software](https://github.com/rtek1000/stm8-bootloader/tree/master/USART_Software)

There is a demo application inside `app` directory (0x83C0) which toggles PA3 (Relay) via interrupts. To upload the application short PC3 to ground (press SET button), power-cycle the MCU and run the uploader utility. DTR pin on UART-USB converter (TTL level only: 5V) can be connected to RESET pin on STM8 for automatic reset (RESET connection is close to the display: NRST).

(boot-9600.py: 9600 bauds)

``` bash
$ cd app && make
$ python ../uploader/boot.py -p /dev/ttyUSB0 firmware.bin
```

- W1209 board schematic:

![image](https://raw.githubusercontent.com/rtek1000/stm8-bootloader/master/Doc/thermostat-w1209.jpg)

-------------

## Uploading the firmware using ST-link

- The bootloader starts at address 0x8000, and if it does not enter update mode, it jumps to the application address.
- The bootloader must be made to jump to the correct application start address.
- The bootloader can also be made to launch more than one application, one at a time.
- The [stm8flash](https://github.com/vdudouyt/stm8flash) allows you to direct the start of firmware programming, by default it is 0x8000, but you can use the directive -s 0x8000 for example.
- To test the bootloader whether the bootloader is jumping to the application address, you can program the bootloader and application using ST-link:

To program the bootloader:

```stm8flash -c stlinkv2 -p stm8s003?3 -s 0x8000 -w bootloader_file.bin```

To program the app (base adress 0x8280):

```stm8flash -c stlinkv2 -p stm8s003?3 -s 0x8280 -w app_file.bin```

To program the app (base adress 0x83C0):

```stm8flash -c stlinkv2 -p stm8s003?3 -s 0x83C0 -w app_file.bin```

-------------

Note: This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
