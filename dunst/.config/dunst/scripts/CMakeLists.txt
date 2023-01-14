cmake_minimum_required(VERSION 3.10)
project(NotificationLogger)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")
add_executable(notificationLogger notificationLogger.cpp)

find_package(PkgConfig REQUIRED)
find_package(CURL REQUIRED)
find_package(Boost REQUIRED)

pkg_check_modules(GTKMM REQUIRED gtkmm-3.0)

include_directories(${GTKMM_INCLUDE_DIRS} ${workspaceFolder})
include_directories(${Boost_INCLUDE_DIRS})
include_directories(${CURL_INCLUDE_DIRS})

link_directories(${GTKMM_LIBRARY_DIRS})
target_link_libraries(notificationLogger ${CURL_LIBRARIES})
target_link_libraries(notificationLogger ${GTKMM_LIBRARIES} -pthread -lz -lgiomm-2.4)
target_link_libraries(notificationLogger ${Boost_LIBRARIES})



