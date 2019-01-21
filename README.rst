
This is the source repository for work on decompiling
Paper Mario for the Nintendo 64.

Summary of information known
============================

The 2008 Intelligent Systems FTP leak revealed the company
used gcc 2.8.1 and binutils 2.9.1 to compile ROMs for the
Nintendo 64, with some custom patches.

The patches from the FTP are reproduced here exactly, and
they can be applied using the Linux ``gunzip`` and ``patch``
tools.

As these compilers are very dated, changes in C standards
makes them uncompilable by default on modern compilers.

While we don't have a way to compile these in their entirety
yet, `miscpatches.diff <miscpatches.diff>`__ contains two
patches that allow ``cc1`` to be built, and so we can compile
C into ``.s`` (ASM source) files.

Ideally we would then also use the Intelligent Systems binutils
to assemble these into ``.o`` (object) files, but we don't yet
have a method of building this version yet. Until we do, we can
use modern binutils to assemble code and hope for accuracy.


Building source for comparison
==============================

If you don't want to build gcc yourself, the pipeline for a working ``cc1``
has been set up in the repository `Dockerfile <Dockerfile>`__.
You can either build this Dockerfile yourself, or use the pre-built
container on the Docker Hub using:

.. code:: sh

    docker run -it gorialis/is-gcc:latest

Once gcc 2.8.1 is built, you can use it in combination with binutils
to generate ASM binary that can be compared to routines in the game
ROM:

.. code:: sh

    cpp yourcode.c | gcc-2.8.1/cc1 -o yourcode.s -fomit-frame-pointer -mips2 -O2
    mips-linux-gnu-as yourcode.s -o yourcode.o -mips2 -O2
    mips-linux-gnu-objdump -dr yourcode.o

This shows the annotated instructions with the binary in hex, so you
can compare it to the ROM.
