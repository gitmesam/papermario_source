
FROM buildpack-deps:stretch
WORKDIR /papermario

# Install system requirements
RUN \
    apt-get update && \
    apt-get install -y -qq build-essential flex libelf-dev libc6-dev libc6-dev-i386 binutils-dev libdwarf-dev gperf && \
    apt-get install -y -qq binutils-mips-linux-gnu

# Download and patch gcc
COPY gcc-2.8.1.diff.990222.gz /papermario/gcc.diff.gz
RUN \
    wget https://ftp.gnu.org/gnu/gcc/gcc-2.8.1.tar.gz && \
    tar -xf gcc-2.8.1.tar.gz && \
    rm gcc-2.8.1.tar.gz && \
    gzip -d gcc.diff.gz && \
    chmod 777 -R gcc-2.8.1 && \
    cd gcc-2.8.1 && \
    patch --strip=1 -i ../gcc.diff && \
    cd .. && \
    rm gcc.diff

# Download and patch binutils
COPY binutils-2.9.1.diff.980925.gz /papermario/binutils.diff.gz
RUN \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.9.1.tar.gz && \
    tar -xf binutils-2.9.1.tar.gz && \
    rm binutils-2.9.1.tar.gz && \
    gzip -d binutils.diff.gz && \
    chmod 777 -R binutils-2.9.1 && \
    cd binutils-2.9.1 && \
    patch --strip=1 -i ../binutils.diff && \
    cd .. && \
    rm binutils.diff

# Configure gcc, fix Makefile and install
COPY miscpatches.diff /papermario/miscpatch.diff
RUN \
    cd gcc-2.8.1 && \
    ./configure --target=mips --prefix=$OUTPUT_DIR --host=i386-pc-linux --build=i386-pc-linux && \
    patch --strip=1 -i ../miscpatch.diff && \
    sed -i 's/CC = \(g\?cc\)/CC = \1 -m32/g' Makefile && \
    sed -i -E 's/LANGUAGES = c .+$/LANGUAGES = c/g' Makefile && \
    make install || true && \
    dir cc1 && \
    cd ..

# Run a test to confirm cc1 works
COPY tests/base.c test.c
RUN \
    cpp test.c | gcc-2.8.1/cc1 -o test.s -fomit-frame-pointer -mips2 -O2 && \
    mips-linux-gnu-as test.s -o test.o -mips2 -O2 && \
    cat test.s && \
    mips-linux-gnu-objdump -dr test.o && \
    rm test.c test.s test.o

ENTRYPOINT ["/bin/bash"]
