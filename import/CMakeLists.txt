# -------------------------------------------------------------------
# Copyright (c) 2013-2022, AIT Austrian Institute of Technology GmbH.
# All rights reserved. See file FMIPP_LICENSE for details.
# -------------------------------------------------------------------

cmake_minimum_required(VERSION 3.8)

project(fmipp_import)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

add_library(fmippim SHARED
  base/src/BareFMU.cpp
  base/src/CallbackFunctions.cpp
  base/src/DynamicalSystem.cpp
  base/src/FMUCoSimulation_v1.cpp
  base/src/FMUCoSimulation_v2.cpp
  base/src/FMUModelExchange_v1.cpp
  base/src/FMUModelExchange_v2.cpp
  base/src/LogBuffer.cpp
  base/src/ModelDescription.cpp
  base/src/ModelManager.cpp
  base/src/PathFromUrl.cpp
  integrators/src/Integrator.cpp
  integrators/src/IntegratorStepper.cpp
  utility/src/FixedStepSizeFMU.cpp
  utility/src/History.cpp utility/src/IncrementalFMU.cpp
  utility/src/InterpolatingFixedStepSizeFMU.cpp
  utility/src/RollbackFMU.cpp
  utility/src/VariableStepSizeFMU.cpp
)

if(INCLUDE_SUNDIALS)
  if(WIN32) # windows-specific
    target_link_libraries(fmippim ${CMAKE_DL_LIBS} ${Boost_LIBRARIES} sundials_cvode sundials_nvecserial sundials_sunlinsoldense)
  else() # linux-specific
    target_link_libraries(fmippim ${CMAKE_DL_LIBS} ${Boost_LIBRARIES} sundials_cvode sundials_nvecserial sundials_sunlinsoldense m)
  endif()

  set_target_properties(fmippim PROPERTIES POSITION_INDEPENDENT_CODE ON)
else()
  target_link_libraries(fmippim ${CMAKE_DL_LIBS} ${Boost_LIBRARIES})
endif()

# OS-specific dependencies here
if(WIN32)
  target_link_libraries(fmippim shlwapi)

  if(MSVC AND MSVC_VERSION VERSION_LESS 1600) # Visual Studio 2008 or older
    set_target_properties(fmippim PROPERTIES COMPILE_FLAGS "-DBUILD_FMI_DLL /EHsc")
  else() # MINGW and newer than Visual Studio 2008
    set_target_properties(fmippim PROPERTIES COMPILE_FLAGS "-DBUILD_FMI_DLL")
  endif()
endif()

if(BUILD_SWIG)
  add_subdirectory(swig)
endif()

# 安装C++
# 指定头文件的安装路径
install(TARGETS fmippim
  EXPORT fmippim
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin)

# 安装头文件并保持目录结构
install(DIRECTORY base/include/ DESTINATION include/import/base/include PATTERN "*.cpp" EXCLUDE)
install(DIRECTORY integrators/include/ DESTINATION include/import/integrators/include PATTERN "*.cpp" EXCLUDE)
install(DIRECTORY utility/include/ DESTINATION include/import/utility/include PATTERN "*.cpp" EXCLUDE)

# 导出目标
install(EXPORT fmippim FILE "fmippim.cmake" NAMESPACE fmipp:: DESTINATION lib/cmake/fmipp/fmippim/)