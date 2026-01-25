// web/passkeys.js

// Utilidad: bytes aleatorios
function randomBytes(length) {
  const array = new Uint8Array(length);
  window.crypto.getRandomValues(array);
  return array;
}

// Convierte cualquier credential a JSON serializable
function credentialToJSON(cred) {
  if (!cred) return null;

  function bufferToBase64Url(buffer) {
    const bytes = new Uint8Array(buffer);
    let binary = "";
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary)
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/g, "");
  }

  const json = {
    id: cred.id,
    type: cred.type,
  };

  if (cred.rawId) {
    json.rawId = bufferToBase64Url(cred.rawId);
  }

  if (cred.response) {
    json.response = {};
    if (cred.response.clientDataJSON) {
      json.response.clientDataJSON = bufferToBase64Url(
        cred.response.clientDataJSON
      );
    }
    if (cred.response.attestationObject) {
      json.response.attestationObject = bufferToBase64Url(
        cred.response.attestationObject
      );
    }
    if (cred.response.authenticatorData) {
      json.response.authenticatorData = bufferToBase64Url(
        cred.response.authenticatorData
      );
    }
    if (cred.response.signature) {
      json.response.signature = bufferToBase64Url(cred.response.signature);
    }
    if (cred.response.userHandle) {
      json.response.userHandle = bufferToBase64Url(cred.response.userHandle);
    }
  }

  return JSON.stringify(json);
}

// API global para Flutter
window.passkeys = {
  // Crear Passkey (registro)
  async create(userId, userEmail) {
    const publicKey = {
      challenge: randomBytes(32),

      rp: {
        name: "Sports App",
      },

      user: {
        id: new TextEncoder().encode(userId),
        name: userEmail,
        displayName: userEmail,
      },

      pubKeyCredParams: [
        { type: "public-key", alg: -7 },   // ES256
        { type: "public-key", alg: -257 }, // RS256
      ],

      authenticatorSelection: {
        residentKey: "required",
        userVerification: "required",
      },

      timeout: 60000,
      attestation: "none",
    };

    const cred = await navigator.credentials.create({ publicKey });
    return credentialToJSON(cred);
  },

  // Login / firma con Passkey
  async sign(publicKeyOptions) {
    const cred = await navigator.credentials.get({
      publicKey: publicKeyOptions,
    });
    return credentialToJSON(cred);
  },
};