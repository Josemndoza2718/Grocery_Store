# Pruebas de reglas de Firestore

Prueban [`../firestore.rules`](../firestore.rules) contra el **emulador** de Firestore,
con un proyecto `demo-grocery-store` que nunca toca los datos reales.

## Requisitos
- Node.js 18+ y Firebase CLI (`npm i -g firebase-tools`).
- Java 17+. El de Android Studio sirve (no está en el PATH por defecto):

```bash
# Git Bash
export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
export PATH="$JAVA_HOME/bin:$PATH"
```

```powershell
# PowerShell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

## Ejecutar

```bash
cd firestore-tests
npm install          # solo la primera vez
npm run test:emulator
```

`test:emulator` arranca el emulador, ejecuta `rules.test.js` y lo apaga.

## Publicar las reglas (después de que las pruebas pasen)

```bash
# desde la carpeta grocery_store/
firebase deploy --only firestore:rules      # reglas
firebase deploy --only firestore:indexes    # índices (firestore.indexes.json)
```
