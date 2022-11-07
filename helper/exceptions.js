const PREFIX = "Returned error: VM Exception while processing transaction: ";

async function tryCatch(promise, message) {
  try {
    await promise;
    return promise;
  } catch (error) {
    console.log("error", error);
    assert(error, "Expected an error but did not get one");
    assert(
      error.message.startsWith(PREFIX + message),
      "Expected an error starting with '" +
        PREFIX +
        message +
        "' but got '" +
        error.message +
        "' instead",
    );
  }
}

module.exports = {
  catchRevert: async function (promise) {
    return tryCatch(promise, "revert");
  },
  catchOutOfGas: async function (promise) {
    return tryCatch(promise, "out of gas");
  },
  catchInvalidJump: async function (promise) {
    return tryCatch(promise, "invalid JUMP");
  },
  catchInvalidOpcode: async function (promise) {
    return tryCatch(promise, "invalid opcode");
  },
  catchStackOverflow: async function (promise) {
    return tryCatch(promise, "stack overflow");
  },
  catchStackUnderflow: async function (promise) {
    return tryCatch(promise, "stack underflow");
  },
  catchStaticStateChange: async function (promise) {
    return tryCatch(promise, "static state change");
  },
};
