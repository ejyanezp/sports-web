// web/passkeys.js

async function createPasskey() {
  return await navigator.credentials.create({
    publicKey: window.passkeyCreateOptions
  });
}

async function signWithPasskey() {
  return await navigator.credentials.get({
    publicKey: window.passkeyGetOptions
  });
}

window.passkeys = {
  create: createPasskey,
  sign: signWithPasskey
};