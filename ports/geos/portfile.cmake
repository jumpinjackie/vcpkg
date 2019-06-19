include(vcpkg_common_functions)

set(GEOS_VERSION 3.6.3)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 f88adcf363433e247a51fb1a2c0b53f39b71aba8a6c01dd08aa416c2e980fe274a195e6edcb5bb5ff8ea81b889da14a1a8fb2849e04669aeba3b6d55754dc96a
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GEOS_VERSION}
    PATCHES geos_c-static-support.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DGEOS_ENABLE_TESTS=False
)
vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(CMAKE_HOST_UNIX OR CMAKE_HOST_APPLE)
    # geos-config is unique per build type, so copy both
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/tools/geos-config)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/geos/rel)
        file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/tools/geos-config 
            DESTINATION ${CURRENT_PACKAGES_DIR}/share/geos/rel
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
        )
    endif ()
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/tools/geos-config)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/geos/dbg)
        file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/tools/geos-config
            DESTINATION ${CURRENT_PACKAGES_DIR}/share/geos/dbg
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
        )
    endif()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright COPYONLY)

vcpkg_copy_pdbs()
