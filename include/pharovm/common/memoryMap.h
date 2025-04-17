#ifndef MEMORY_MAP_H
#define MEMORY_MAP_H


#include <stdint.h>

#if __riscv
#   define ConfWordSize 4
#   define CodeZoneInitialAddress   0x10000000  // "(256 MB)"
#   define NewSpaceInitialAddress   0x20000000  // "(512 MB)";
#   define OldSpaceInitialAddress   0x40000000  // "(1024 MB)";
#   define PermSpaceInitialAddress  0x80000000  // "(2048 MB)";
#   define StackPagesInitialAddress 0x0F000000  // "(240 MB)";
#else
/* Common case, all other architectures */
#   if UINTPTR_MAX == 0xffffffff
/* 32-bit */
#       define ConfWordSize 4
#       define CodeZoneInitialAddress   0x10000000  // "(256 MB)"
#       define NewSpaceInitialAddress   0x20000000  // "(512 MB)";
#       define OldSpaceInitialAddress   0x40000000  // "(1024 MB)";
#       define PermSpaceInitialAddress  0x80000000  // "(2048 MB)";
#       define StackPagesInitialAddress 0x0F000000  // "(240 MB)";
#   elif UINTPTR_MAX == 0xffffffffffffffff
/* 64-bit */
#       define ConfWordSize 8
#       define CodeZoneInitialAddress   0x320000000   //  "12.5GB";
#       define NewSpaceInitialAddress   0x360000000   // "13.5GB";
#       define OldSpaceInitialAddress   0x10000000000 // "1024GB";
#       define PermSpaceInitialAddress  0x20000000000 // "2048GB";
#       define StackPagesInitialAddress 0x300000000   // "12GB";
#   endif
#endif

#endif /* MEMORY_MAP_H */