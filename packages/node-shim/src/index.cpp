#include <quickjs/quickjs-libc.h>
#include <quickjs/quickjs.h>
#include <quickjspp.hpp>

#include <cstdlib>
#include <unistd.h>

#include <filesystem>
#include <string>
#include <iostream>
#include <map>
#include <vector>

namespace fs = std::filesystem;

template <class T>
inline constexpr bool always_false_v = false;


extern char **environ;
int main(int argc, char** argv) {
    auto args = std::vector<std::string>(argv + 1, argv + argc);
    auto env = std::map<std::string, std::string>();
    for (auto i = 0; environ[i]; ++i) {
        auto key = std::string(environ[i]);
        auto pos = key.find('=');
        if (pos != std::string::npos) {
            env[key.substr(0, pos)] = key.substr(pos + 1);
        }
    }

    auto nodeShim = NodeShim(args, env);
    auto exitCode = nodeShim.start();
    return exitCode;
}
