cmake_minimum_required(VERSION 3.21)
project(fzaudio_fixture_plugin)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(FIXTURE_PLUGIN_NAME "FixtureAudio")
set(FIXTURE_STAGE_DIR "${CMAKE_BINARY_DIR}/Release")
set(FIXTURE_VST3_DIR "${FIXTURE_STAGE_DIR}/${FIXTURE_PLUGIN_NAME}.vst3")
set(FIXTURE_AU_DIR "${FIXTURE_STAGE_DIR}/${FIXTURE_PLUGIN_NAME}.component")
set(FIXTURE_CLAP_FILE "${FIXTURE_STAGE_DIR}/${FIXTURE_PLUGIN_NAME}.clap")
set(FIXTURE_MACOS_DIR "Contents/MacOS")
set(FIXTURE_INFO_DIR "Contents")
add_executable(fzaudio_fixture_payload "${CMAKE_CURRENT_SOURCE_DIR}/plugin_stub.c")
set_target_properties(fzaudio_fixture_payload PROPERTIES OUTPUT_NAME "FixtureAudioPayload")

add_custom_target(fzaudio_fixture_plugins ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory "${FIXTURE_STAGE_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${FIXTURE_VST3_DIR}/${FIXTURE_MACOS_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${FIXTURE_AU_DIR}/${FIXTURE_MACOS_DIR}"
  COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:fzaudio_fixture_payload>" "${FIXTURE_VST3_DIR}/${FIXTURE_MACOS_DIR}/${FIXTURE_PLUGIN_NAME}"
  COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:fzaudio_fixture_payload>" "${FIXTURE_AU_DIR}/${FIXTURE_MACOS_DIR}/${FIXTURE_PLUGIN_NAME}"
  COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:fzaudio_fixture_payload>" "${FIXTURE_CLAP_FILE}"
  COMMAND ${CMAKE_COMMAND} -E touch "${FIXTURE_VST3_DIR}/${FIXTURE_INFO_DIR}/Info.plist"
  COMMAND ${CMAKE_COMMAND} -E touch "${FIXTURE_AU_DIR}/${FIXTURE_INFO_DIR}/Info.plist"
  DEPENDS fzaudio_fixture_payload
  BYPRODUCTS
    "${FIXTURE_VST3_DIR}/${FIXTURE_MACOS_DIR}/${FIXTURE_PLUGIN_NAME}"
    "${FIXTURE_AU_DIR}/${FIXTURE_MACOS_DIR}/${FIXTURE_PLUGIN_NAME}"
    "${FIXTURE_CLAP_FILE}"
)
