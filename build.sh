#! /bin/bash

# 默认构建类型为Debug
BUILD_TYPE=${1:-Debug}

echo "Cleaning build directory..."
rm build -rf 
mkdir build
cd build
echo "Configuring $BUILD_TYPE build..."

cmake -DBUILD_SWIG=OFF -DBUILD_TESTS=OFF -DBoost_ROOT=/usr/local/lib/ ..

# 获取CPU核心数
CPU_CORES=$(nproc)
echo "Building and installing with $CPU_CORES parallel jobs..."
#并行：编译、安装
cmake --build . --target install --parallel $CPU_CORES

#返回到原始目录
cd ..

# 检查构建结果
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build and install completed successfully!"