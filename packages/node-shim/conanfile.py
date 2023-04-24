"""
This code defines a Conan recipe for the node-shim project. It sets the name and
version of the project, as well as the license, author, URL, description, and
topics. It also sets the settings and options for the project.

The exports_sources line includes the CMakeLists.txt file and the source files.
The config_options function removes the fPIC option on Windows. The layout
function uses the CMake layout. The generate function generates the CMake
toolchain. The build function builds the project. The package function installs
the project. Finally, the package_info function sets the package info.
"""

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout

class NodeShimRecipe(ConanFile):
    name = "node-shim"
    version = "1.0.0"

    license = "MIT"
    author = ["Jorge Prendes <jorge.prendes@gmail.com>", "Jacob Hummer jcbhmr@outlook.com"]
    url = "https://github.com/jprendes/emception/tree/main/packages/node-shim"
    description = "🩹 A shim of Node.js for Emscripten scripts"
    topics = ("emscripten", "node", "shim", "quickjs")

    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    exports_sources = "CMakeLists.txt", "src/*"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def test(self):
        cmake = CMake(self)
        cmake.test()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["node-shim"]
        self.cpp_info.includedirs.append("vendor")
