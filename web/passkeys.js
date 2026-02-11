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
      json.response.clientDataJSON = bufferToBase64Url(cred.response.clientDataJSON);
    }
    if (cred.response.attestationObject) {
      json.response.attestationObject = bufferToBase64Url(cred.response.attestationObject);
    }
    if (cred.response.authenticatorData) {
      json.response.authenticatorData = bufferToBase64Url(cred.response.authenticatorData);
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

function base64urlToBytes(base64url) {
  // Convert from Base64URL to standard Base64
  let base64 = base64url.replace(/-/g, '+').replace(/_/g, '/');

  // Add padding if missing
  const pad = base64.length % 4;
  if (pad) {
    base64 += '='.repeat(4 - pad);
  }

  // Decode to binary string
  const binary = atob(base64);

  // Convert binary string to Uint8Array
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes;
}

function utf8ToBytes(str) {
  const encoder = new TextEncoder();
  return encoder.encode(str);
}

// API global para Flutter
window.passkeys = {
  // Crear Passkey (registro)
  async create(userId, userEmail, challengeB64, rpId) {
    const challengeBytes = base64urlToBytes(challengeB64);
    const publicKey = {
      challenge: challengeBytes,
      // // Relying Party
      rp: {
        name: "Challengers",
        // Relying Party Identifier == Es el dominio para el cual el passkey es válido
        id: rpId,
      },
      user: {
        id:  utf8ToBytes(userId),
        name: userEmail,
        displayName: userEmail,
      },
      // Indica qué algoritmos de clave pública acepta tu backend.
      pubKeyCredParams: [
        { type: "public-key", alg: -7 },   // ES256
        { type: "public-key", alg: -257 }, // RS256
      ],
      // residentKey - si la passkey debe ser residente
      // userVerification - si debe pedir biometría/PIN
      authenticatorSelection: {
        residentKey: "required",      // puede ser tambien "preferred"
        userVerification: "required", // puede ser tambien "preferred"
      },
      // Tiempo máximo para completar la operación.
      timeout: 60000,
      // none → No quiero certificados del dispositivo. Solo dame la clave pública.
      // indirect / direct → Dame certificados que prueben que la passkey viene de un hardware específico (TPM, YubiKey, etc.
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