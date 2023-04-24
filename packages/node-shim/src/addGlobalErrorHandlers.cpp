#include "addGlobalErrorHandlers.h"
#include <sstream>
#include <string>
#include <quickjspp.hpp>

namespace node_shim {

static std::string currentExceptionToString(Context& context) {
  auto error = m_context.getException();
  std::sstream ss;

  if (!error.isError()) {
    ss << "Throw: ";
  }
  ss << (std::string)error
  if (error["stack"]) {
    ss << "\n";
    ss << (std::string)error["stack"];
  }
  return ss.str();
}

void addGlobalErrorHandlers(Context& context) {
  context.onUnhandledPromiseRejection = [&](const qjs::Value& x){
      std::cerr << "Unhandled promise rejection: " << currentExceptionToString(context) << "\n";
  };
  context.onUncaughtException = [&](const qjs::Value& x){
      std::cerr << "Unhandled exception: " << currentExceptionToString(context) << "\n";
  };
}

} // namespace node_shim
