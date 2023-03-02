cmake_minimum_required(VERSION 3.10)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
project(notificationLogger)
include(CTest)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")
add_executable(notificationLogger notificationLogger.cpp)

find_package(PkgConfig REQUIRED)
find_package(CURL REQUIRED)
find_package(Boost REQUIRED)

include_directories(${Boost_INCLUDE_DIRS})
include_directories(${CURL_INCLUDE_DIRS})

target_link_libraries(${PROJECT_NAME} ${GTK_LIBRARIES})

target_link_libraries(notificationLogger ${CURL_LIBRARIES})
target_link_libraries(notificationLogger ${Boost_LIBRARIES})
add_test(example_test notificationLogger)
add_custom_target(
  test_memcheck
  COMMAND ${CMAKE_CTEST_COMMAND} --force-new-ctest-process --test-action
          memcheck
  COMMAND cat "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryChecker.*.log"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
