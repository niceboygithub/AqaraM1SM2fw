#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>
#include <mtd/mtd-user.h>

#define SIZE_BOOT_INFO 55
#define SIZE_ERASE 0x20000
#define BOOTINFO_MAGIC 0x917c
#define BOOTINFO_VERNUM 0
#define BOOTINFO_VERSION "1.0.2.005"

typedef struct BOOT_INFO {
    uint16_t magic;
    uint16_t vernum;
    uint16_t check_sum;
    uint8_t kernel_curr;
    uint8_t rootfs_curr;
    uint8_t kernel_newest;
    uint8_t rootfs_newest;
    uint8_t kernel0_size[4];
    uint16_t kernel0_checksum;
    uint8_t kernel0_fail;
    uint8_t kernel1_size[4];
    uint8_t kernel1_checksum[2];
    uint8_t kernel1_fail;
    uint8_t rootfs0_size[4];
    uint16_t rootfs0_checksum;
    uint8_t rootfs0_fail;
    uint8_t rootfs1_size[4];
    uint8_t rootfs1_checksum[2];
    uint8_t rootfs1_fail;
    uint8_t root_sum_check;
    uint8_t watchdog_time;
    uint8_t priv_mode;
    uint8_t version[9];
    uint8_t reserved[5];
} boot_info_t;

void usage(void) {
    printf("RTL917FS Mijia Gw boot config tool. version: 1.2.2a\n");
    printf("Usage: boot_ctrl show\n");
    printf("       boot_ctrl priv_mode <on|off>\n");
    printf("       boot_ctrl root_sum <on|off>\n");
    printf("       boot_ctrl slot <0|1>\n");
}

void show_boot_info(boot_info_t info) {
    uint32_t size;
    uint16_t checksum;
#ifdef DEBUG
    printf("magic: %x\n", info.magic);
#endif
    printf("vernum: %d\n", info.vernum);
    printf("bversion: %s\n", info.version);
    printf("kernel: %d %d\n", info.kernel_newest, info.kernel_curr);
    printf("rootfs: %d %d\n", info.rootfs_newest, info.rootfs_curr);
    size = info.kernel0_size[0] << 24 | info.kernel0_size[1] << 16 | info.kernel0_size[2] << 8 | info.kernel0_size[3];
    checksum = (info.kernel0_checksum & 0xFF) << 8 | info.kernel0_checksum >> 8;
    printf("kernel_0: %d %x %d\n", info.kernel0_fail, checksum, size);
    size = info.kernel1_size[0] << 24 | info.kernel1_size[1] << 16 | info.kernel1_size[2] << 8 | info.kernel1_size[3];
    checksum = (info.kernel1_checksum[0] & 0xFF) << 8 | info.kernel1_checksum[1];
    printf("kernel_1: %d %x %d\n", info.kernel1_fail, checksum, size);
    size = info.rootfs0_size[0] << 24 | info.rootfs0_size[1] << 16 | info.rootfs0_size[2] << 8 | info.rootfs0_size[3];
    checksum = (info.rootfs0_checksum & 0xFF) << 8 | info.rootfs0_checksum >> 8;
    printf("rootfs_0: %d %x %d\n", info.rootfs0_fail, checksum, size);
    size = info.rootfs1_size[0] << 24 | info.rootfs1_size[1] << 16 | info.rootfs1_size[2] << 8 | info.rootfs1_size[3];
    checksum = (info.rootfs1_checksum[0] & 0xFF) << 8 | info.rootfs1_checksum[1];
    printf("rootfs_1: %d %x %d\n", info.rootfs1_fail, checksum, size);
    if (info.root_sum_check == 0x0)
        printf("root_sum_check: off\n");
    else
        printf("root_sum_check: on\n");
    if (info.priv_mode == 0x0)
        printf("priv_mode: off\n");
    else
        printf("priv_mode: on\n");
}

uint16_t calcuate_checksum(uint8_t *buf) {
    int i;
    uint8_t base0 = 0xff, base1 = 0xff;
    for (i = 6; i < SIZE_BOOT_INFO; i++) {
        if (i % 2 == 0) {
            if (buf[i] > base0) {
                base1 = base1 - 1;
                base0 = 256 + base0 - buf[i];
            } else {
                base0 = base0 - buf[i];
            }
        } else {
            if (buf[i] > base1) {
                base0 = base0 - 1;
                base1 = 256 + base1 - buf[i];
            } else {
                base1 = base1 - buf[i];
            }
        }
    }
    return base1 << 8 | base0;
}
/*
magic: 917c
vernum: 0
bversion: 1.0.2.005
kernel: 0 0
rootfs: 0 0
kernel_0: 0 cb43 2157572
kernel_1: 0 c8cf 2157572
rootfs_0: 0 742c 10108932
rootfs_1: 0 84df 8781828
root_sum_check: off
priv_mode: on
*/

boot_info_t bootinfo_default(void) {
    boot_info_t info;
    memset(&info, 0x0, sizeof(info));
    info.magic = BOOTINFO_MAGIC;
    info.vernum = BOOTINFO_VERNUM;
    info.check_sum = 0x9979;
    info.kernel_curr = 0x0;
    info.rootfs_curr = 0x0;
    info.kernel_newest = 0x0;
    info.rootfs_newest = 0x0;
    info.kernel0_size[0] = 0x0;
    info.kernel0_size[1] = 0x20;
    info.kernel0_size[2] = 0xec;
    info.kernel0_size[3] = 0x04;
    info.kernel0_checksum = 0x43cb;
    info.kernel0_fail = 0;
    info.kernel1_size[0] = 0;
    info.kernel1_size[1] = 0x20;
    info.kernel1_size[2] = 0xec;
    info.kernel1_size[3] = 0x04;
    info.kernel1_checksum[0] = 0xc8;
    info.kernel1_checksum[1] = 0xcf;
    info.kernel1_fail = 0;
    info.rootfs0_size[0] = 0;
    info.rootfs0_size[1] = 0x9a;
    info.rootfs0_size[2] = 0x40;
    info.rootfs0_size[3] = 0x04;
    info.rootfs0_checksum = 0x2c74;
    info.rootfs0_fail = 0;
    info.rootfs1_size[0] = 0;
    info.rootfs1_size[1] = 0x86;
    info.rootfs1_size[2] = 0x00;
    info.rootfs1_size[3] = 0x04;
    info.rootfs1_checksum[0] = 0x84;
    info.rootfs1_checksum[1] = 0xdf;
    info.rootfs1_fail = 0;
    info.root_sum_check = 0;
    info.watchdog_time = 0;
    info.priv_mode = 0x1;
    memcpy(info.version, BOOTINFO_VERSION, sizeof(info.version));
    return info;
}


int main(int argc, char *argv[]) {
    mtd_info_t mtd_info;           // the MTD structure
    erase_info_t ei;               // the erase block structure
    uint8_t i, priv_mode, root_sum_check, slot;
    int fd;
    unsigned char data[SIZE_ERASE] = {0x0};
    unsigned char read_buf[SIZE_BOOT_INFO] = {0x00};
    boot_info_t info;
    uint8_t modify_boot_info = 0, modify_slot = 0;
    uint16_t checksum;

    if (argc <= 1) {
        goto error_usage;
    }

    fd = open("/dev/mtd1", O_RDWR);  // open the mtd device for reading and writing

    ioctl(fd, MEMGETINFO, &mtd_info);   // get the device info

    #ifdef DEBUG
        printf("MTD Type: %x\nMTD total size: %x bytes\nMTD erase size: %x bytes\n",
            mtd_info.type, mtd_info.size, mtd_info.erasesize);
    #endif

    ei.length = mtd_info.erasesize;   // set the erase block size
    for (ei.start = 0; ei.start < mtd_info.size; ei.start += ei.length) {
        ioctl(fd, MEMUNLOCK, &ei);
    }

    lseek(fd, 0, SEEK_SET);               // go to the first block
    read(fd, read_buf, sizeof(read_buf));

#ifdef DEBUG
    for (i = 0; i < SIZE_BOOT_INFO; i++)
        printf("buf[%d] = 0x%02x\n", i, (unsigned int)read_buf[i]);
#endif

    memcpy(&info, read_buf, sizeof(info));
    priv_mode = info.priv_mode;
    root_sum_check = info.root_sum_check;

    if (strncmp("priv_mode\0", argv[1], 10) == 0) {
        if (argc <= 2)
            goto error_usage;
        if (strncmp("on\0", argv[2], 3) == 0) {
            priv_mode = 1;
            modify_boot_info = 1;
        } else if (strncmp("off\0", argv[2], 4) == 0) {
            priv_mode = 0;
            modify_boot_info = 1;
        }
    }

    if (strncmp("root_sum\0", argv[1], 9) == 0) {
        if (argc <= 2)
            goto error_usage;
        if (strncmp("on\0", argv[2], 3) == 0) {
            root_sum_check = 1;
            modify_boot_info = 1;
        } else if (strncmp("off\0", argv[2], 4) == 0) {
            root_sum_check = 0;
            modify_boot_info = 1;
        }
    }

    if (strncmp("slot\0", argv[1], 5) == 0) {
        if (argc <= 2)
            goto error_usage;
        if (strncmp("1\0", argv[2], 2) == 0) {
            slot = 1;
            modify_slot = 1;
        } else if (strncmp("0\0", argv[2], 2) == 0) {
            slot = 0;
            modify_slot = 1;
        }
    }

    if (strncmp("default\0", argv[1], 8) == 0) {
        info = bootinfo_default();
        slot = 0;
        priv_mode = 1;
        root_sum_check = 0;
        modify_boot_info = 1;
    }

    if (info.magic != BOOTINFO_MAGIC) {
        printf("Err: boot_info.magic error\n");
        goto exit;
    }
    if (info.vernum != BOOTINFO_VERNUM) {
        printf("Err: version mismatch, its version:%d, mine:%d\n", info.vernum, BOOTINFO_VERSION);
        goto exit;
    }
    checksum = calcuate_checksum(read_buf);
    if (info.check_sum != checksum) {
        printf("Err: boot_info.sum error\n");
        goto exit;
    }
    if (modify_boot_info || modify_slot) {
        info.priv_mode = priv_mode;
        info.root_sum_check = root_sum_check;
        if (modify_slot == 1) {
            if (slot == 0 && info.kernel_newest == 0x1) {
                info.kernel_newest = 0;
                if (info.rootfs_newest == 1)
                    info.check_sum += 0x101;
                else
                    info.check_sum += 0x100;
                info.rootfs_newest = 0;
            } else if (slot == 1 && info.kernel_newest == 0x0) {
                info.kernel_newest = 1;
                if (info.rootfs_newest == 0)
                    info.check_sum -= 0x101;
                else
                    info.check_sum -= 0x100;
                info.rootfs_newest = 1;
            }
        }
        memcpy(data, &info, sizeof(info));

        ei.length = mtd_info.erasesize;   // set the erase block size
        for (ei.start = 0; ei.start < mtd_info.size; ei.start += ei.length) {
            ioctl(fd, MEMUNLOCK, &ei);
            // printf("Eraseing Block %#x\n", ei.start); // show the blocks erasing
                                                    // warning, this prints a lot!
            ioctl(fd, MEMERASE, &ei);
        }

        lseek(fd, 0, SEEK_SET);        // go back to first block's start
        write(fd, data, sizeof(data));  // write our message

        goto exit;
    }

    if (strncmp("show\0", argv[1], 5) == 0) {
        show_boot_info(info);
        goto exit;
    }


error_usage:
    usage();
    return -1;
exit:
    close(fd);
    return 0;
}
