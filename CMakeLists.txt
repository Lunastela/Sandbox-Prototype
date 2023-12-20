cmake_minimum_required(VERSION 3.24)

option(SUPERBUILD "Perform a superbuild (or not)" OFF)

project(Sandbox-Prototype LANGUAGES CXX)

if (SUPERBUILD)
  if (EMSCRIPTEN)
    set(LIB_BUILD_DIR_NAME embuild)
  else ()
    set(LIB_BUILD_DIR_NAME build)
  endif ()
  include(lib/CMakeLists.txt)
  include(cmake/superbuild.cmake)
  return()
endif ()

# For some reason windows compiles the SDL2 dirs to a different location than Linux? TODO Looking into this later
# TODO cross-compiling/using one compiler (ninja) instead of using VS2022 on Windows and Make on Linux
# TODO at some point run a crapintosh build
if (WIN32)
  set(SDL2_DIR "lib/build/cmake")
else ()
  set(SDL2_DIR "lib/build/lib/cmake/SDL2")
endif ()
set(bgfx_DIR "lib/build/lib/cmake/bgfx")
set(imgui.cmake_DIR "lib/build/lib/cmake/imgui.cmake")
find_package(SDL2 REQUIRED CONFIG CMAKE_FIND_ROOT_PATH_BOTH)
find_package(bgfx REQUIRED CONFIG CMAKE_FIND_ROOT_PATH_BOTH)
find_package(imgui.cmake REQUIRED CONFIG CMAKE_FIND_ROOT_PATH_BOTH)

set(SOURCES
  src/main.cpp
)

add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE ${SOURCES} sdl-imgui/imgui_impl_sdl2.cpp
                                       bgfx-imgui/imgui_impl_bgfx.cpp)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_11)
target_link_libraries(
  ${PROJECT_NAME} PRIVATE SDL2::SDL2-static SDL2::SDL2main bgfx::bgfx bgfx::bx
                          imgui.cmake::imgui.cmake)

add_custom_command(
  TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND
    ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/shader/build
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/shader/build
  VERBATIM)

set_target_properties(
  ${PROJECT_NAME}
  # required for project when using visual studio generator
  PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/$<CONFIG>)

if (WIN32)
  # copy the SDL2.dll to the same folder as the executable
  add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:SDL2::SDL2>
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
    VERBATIM)
endif ()
