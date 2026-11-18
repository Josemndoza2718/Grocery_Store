# Plan de implementación: Multi-tienda

> Objetivo: que cada **tienda** sea un universo independiente. El dueño puede tener
> varias tiendas; cada empleado pertenece a **una sola** tienda; los clientes son
> datos de cada tienda (no inician sesión).
>
> Estado: **Fases 0 y 1 completadas** · Rama: `feature/multi-tienda`

---

## 1. Decisiones tomadas

| Tema | Decisión |
|---|---|
| Clientes | Son registros de la tienda (nombre al que se asigna un carrito). No inician sesión. Si un cliente compra en 2 tiendas, existe un registro independiente en cada una. |
| Acceso a clientes | Todos los miembros de la tienda (dueño y empleados) ven y gestionan los clientes de la tienda. |
| Dueño | Puede tener varias tiendas. Elige con cuál trabajar al iniciar sesión. |
| Empleado | Pertenece a una sola tienda hasta que el dueño lo desvincule (o él la abandone). Garantizado por la base de datos: el id del documento del empleado es su UID. |
| Empleado sin tienda | Puede crear su propia tienda y convertirse en dueño. |
| Invitaciones | Código corto (p. ej. `K7M-4QX`), un solo uso, caduca en 48 h, compartido por WhatsApp/cualquier app con `share_plus`. Sin correo (no requiere plan Blaze). |
| Roles | Se eliminan el `isAdmin` autoasignado en el registro. Eres **dueño** de las tiendas que creas y **empleado** de la tienda cuyo código usaste. |
| Configuración | IVA y tasa de cambio pasan al documento de la tienda (hoy viven en cada teléfono). |
| Caché local | Se eliminan los espejos en Sembast; se usa la persistencia offline nativa de Firestore. |

### Matriz de permisos

| Acción | Dueño | Empleado |
|---|:---:|:---:|
| Ver productos | ✅ | ✅ |
| Crear / editar / borrar productos y reponer stock | ✅ | ❌ |
| Descontar stock al cobrar (solo vía transacción de cobro) | ✅ | ✅ |
| Ver / crear / editar / borrar clientes | ✅ | ✅ |
| Crear carritos y cobrar | ✅ | ✅ |
| Historial de ventas | Todas las de la tienda | Solo las que **él** cobró |
| Configurar IVA y tasa de cambio | ✅ | ❌ (solo lectura) |
| Invitar / desvincular empleados | ✅ | ❌ |
| Editar / archivar tienda | ✅ | ❌ |
| Abandonar la tienda | — | ✅ |

---

## 2. Modelo de datos en Firestore

```
users/{uid}                       name, email, phone, createdAt
                                  lastStoreId?            (última tienda usada por un dueño)
                                  migratedAt?             (migración de datos legados)

stores/{storeId}                  name, description, ownerId, iva, exchangeRate,
                                  archived (bool), createdAt, updatedAt

employees/{uid}                   storeId, name, email, invitationCode, createdAt
                                  (id = UID → un empleado no puede estar en 2 tiendas)

invitations/{code}                storeId, storeName, createdBy, expiresAt,
                                  usedBy (null hasta usarse), usedAt, createdAt

stores/{storeId}/products/{id}    name, description, price, imageUrl, idStock,
                                  stockQuantity, createdAt, updatedAt
stores/{storeId}/clients/{id}     name, description, createdAt
stores/{storeId}/carts/{id}       ownerId (cliente), ownerCarName, status, products[],
                                  createdBy (uid), createdAt, updatedAt
stores/{storeId}/sales/{id}       (igual que carts) + soldBy (uid), soldByName,
                                  subtotal, iva, discount, delivery, exchangeRate,
                                  total, payAt
```

Notas:
- `userId` desaparece de productos/carritos/ventas: la pertenencia la da la ruta.
- `sales` guarda los importes finales y la tasa del momento → el historial deja de
  recalcular con la tasa actual (corrige el problema #9 de la revisión inicial).
- Nombres en camelCase, como el resto del código.

### Índices compuestos necesarios
- `stores/{id}/sales`: `soldBy ASC` + `updatedAt DESC` (historial del empleado).
- `stores/{id}/sales`: `updatedAt DESC` (historial del dueño; índice simple, automático).
- ~~`stores`: `ownerId ASC` + `createdAt ASC`~~ → no hace falta: se ordena en memoria.

---

## 3. Reglas de seguridad (borrador)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    function signedIn()        { return request.auth != null; }
    function me()              { return request.auth.uid; }
    function storeDoc(id)      { return get(/databases/$(db)/documents/stores/$(id)).data; }
    function employeeDoc()     { return get(/databases/$(db)/documents/employees/$(me())).data; }
    function isEmployeeAny()   { return exists(/databases/$(db)/documents/employees/$(me())); }
    function isOwner(id)       { return signedIn() && storeDoc(id).ownerId == me(); }
    function isEmployee(id)    { return signedIn() && isEmployeeAny() && employeeDoc().storeId == id; }
    function isMember(id)      { return isOwner(id) || isEmployee(id); }
    function onlyChanges(keys) { return request.resource.data.diff(resource.data).affectedKeys().hasOnly(keys); }

    // ── Perfil ──
    match /users/{userId} {
      allow read, create, update: if signedIn() && me() == userId;
      allow delete: if false;
    }

    // ── Tiendas ──
    match /stores/{storeId} {
      // Se evalúa con resource.data para que la consulta "mis tiendas" (where ownerId == uid) sea válida
      allow read: if signedIn() && (resource.data.ownerId == me() || isEmployee(storeId));
      // Un empleado vinculado a una tienda no puede crear tiendas
      allow create: if signedIn() && request.resource.data.ownerId == me() && !isEmployeeAny();
      allow update: if isOwner(storeId) && request.resource.data.ownerId == resource.data.ownerId;
      allow delete: if false; // se archiva (archived = true)

      match /products/{id} {
        allow read: if isMember(storeId);
        allow create, delete: if isOwner(storeId);
        // El empleado solo puede DESCONTAR stock (cobro); reponer es cosa del dueño
        allow update: if isOwner(storeId)
          || (isEmployee(storeId)
              && onlyChanges(['stockQuantity', 'updatedAt'])
              && request.resource.data.stockQuantity < resource.data.stockQuantity
              && request.resource.data.stockQuantity >= 0);
      }

      match /clients/{id} { allow read, write: if isMember(storeId); }
      match /carts/{id}   { allow read, write: if isMember(storeId); }

      match /sales/{id} {
        allow read: if isOwner(storeId)
          || (isEmployee(storeId) && resource.data.soldBy == me());
        allow create: if isMember(storeId) && request.resource.data.soldBy == me();
        allow update, delete: if false; // ventas inmutables
      }
    }

    // ── Empleados ──
    match /employees/{employeeId} {
      allow read: if signedIn() && (me() == employeeId || isOwner(resource.data.storeId));
      // Se crea en el mismo batch que marca la invitación como usada
      allow create: if signedIn() && me() == employeeId
        && validInvitation(request.resource.data.invitationCode, request.resource.data.storeId);
      allow update: if false;
      // Desvincular (dueño) o abandonar (empleado)
      allow delete: if signedIn() && (me() == employeeId || isOwner(resource.data.storeId));

      function validInvitation(code, storeId) {
        let before = get(/databases/$(db)/documents/invitations/$(code)).data;
        let after  = getAfter(/databases/$(db)/documents/invitations/$(code)).data;
        return before.storeId == storeId
          && before.usedBy == null
          && request.time < before.expiresAt
          && after.usedBy == me();
      }
    }

    // ── Invitaciones ──
    match /invitations/{code} {
      allow get: if signedIn();                                   // validar un código
      allow list: if signedIn() && resource.data.createdBy == me(); // el dueño ve las suyas
      allow create: if isOwner(request.resource.data.storeId)
        && request.resource.data.createdBy == me()
        && request.resource.data.usedBy == null;
      // Marcar como usada solo junto con la creación del empleado
      allow update: if signedIn()
        && resource.data.usedBy == null
        && request.time < resource.data.expiresAt
        && onlyChanges(['usedBy', 'usedAt'])
        && request.resource.data.usedBy == me()
        && existsAfter(/databases/$(db)/documents/employees/$(me()));
      allow delete: if isOwner(resource.data.storeId);
    }

    // ── Colecciones legadas (solo durante la migración, se eliminan en la Fase 5) ──
    match /products/{id}      { allow read, delete: if signedIn() && resource.data.userId == me(); }
    match /carts/{id}         { allow read, delete: if signedIn() && resource.data.userId == me(); }
    match /clients/{id}       { allow read, delete: if signedIn() && resource.data.userId == me(); }
    match /sales-history/{id} { allow read, delete: if signedIn() && resource.data.userId == me(); }
  }
}
```

> Las reglas se validarán con pruebas automáticas en el emulador antes de publicarse
> (ver Fase 0). Cada `get()`/`exists()` cuenta como lectura; el máximo por petición
> es 10, holgado para estas reglas.

---

## 4. Cambios de arquitectura en la app

### 4.1 Sesión por tienda
Hoy los view models se recrean por **usuario** (`MultiProvider` con `key: uid` en
`main.dart`). Pasan a recrearse por **usuario + tienda**:

```
StreamBuilder<User?>  (authStateChanges)
 └─ SessionGate                  ← resuelve la tienda activa
     ├─ cargando ............... Splash
     ├─ migración pendiente .... MigrationScreen
     ├─ sin tienda ............. NoStoreScreen  (Crear tienda | Tengo un código)
     ├─ dueño con varias ....... StorePickerScreen
     └─ sesión lista ........... MultiProvider(key: '$uid-$storeId', sessionProviders(session))
                                  └─ MaterialApp → MainPage
```

- Nueva entidad `AppSession { uid, storeId, storeName, role (owner|employee) }`
  con getters de permisos (`canEditProducts`, `canManageEmployees`, `canSeeAllSales`…).
- `SessionGate` escucha `employees/{uid}`: si el dueño desvincula al empleado, la
  sesión se cierra al instante y vuelve a `NoStoreScreen`.
- El dueño cambia de tienda desde Ajustes → vuelve a `StorePickerScreen`.

### 4.2 Repositorios por tienda
Los repositorios dejan de ser singletons globales en `providers.dart` y se crean en
`sessionProviders(session)` con el `storeId` (ruta `stores/{storeId}/...`).

### 4.3 Un solo dashboard
`AdminDashboard` y `UserDashboard` son hoy casi idénticos → se unifican en
`HomeDashboard`, que muestra u oculta acciones según `AppSession`
(p. ej. botón "Agregar producto" y borrar producto solo para el dueño).

---

## 5. Fases

Cada fase termina con: `flutter analyze` sin errores, tests en verde, pruebas de
reglas en el emulador y prueba manual en dispositivo. **Las fases 1 y 2 se publican
juntas** a los dispositivos (la Fase 1 sola deja la app en un estado intermedio).

### Fase 0 — Preparación · tamaño S · ✅ completada
- [x] Hacer commit del trabajo pendiente actual en `main` y crear `feature/multi-tienda`.
- [x] Añadir sección `firestore` a `firebase.json` (rules + indexes) para publicar con
      `firebase deploy --only firestore` en vez de copiar/pegar en la consola.
- [x] Crear `firestore.indexes.json` (+ `.firebaserc` con el proyecto por defecto).
- [x] Montar pruebas de reglas con el Emulator Suite en `firestore-tests/`
      (`@firebase/rules-unit-testing`; Node.js + Firebase CLI + Java 17 de Android Studio).
      25 pruebas de las reglas actuales en verde.
- [x] Borrar código legado muerto: `car/*`, `cash/*`, `category/*`, `CheckViewModel`,
      `CashProductRepositoryImpl`, `CartRepositoryImpl`, `ProductRepositoryImpl`,
      `SendProductFirebaseUseCases`, `CreateSaleUseCase`, archivos `* copy.dart`.
      También: categorías (sin uso), `DetailPayPage` (maqueta), `GeneralListWidget`,
      modelos `CartModel`/`ProductModel`/`CategoryModel`, `my_localizations.dart` y la
      dependencia `flutter_localization`.
- [x] Reemplazar `test/widget_test.dart` por pruebas de entidades (`test/domain/entities_test.dart`).

### Fase 1 — Tiendas y sesión · tamaño L · ✅ completada
- [x] Entidades: `Store`, `Employee`, `AppSession` (`Invitation` pasa a la Fase 3, donde se usa).
- [x] `StoreRepository` (crear, editar, archivar, stream de "mis tiendas", leer una).
- [x] `EmployeeRepository` (stream de `employees/{uid}`, listar por tienda, borrar).
- [x] `SessionController` + `SessionGate` + `NoStorePage` + `StorePickerPage` +
      `StoreFormPage` (crear/editar). 12 pruebas unitarias del `SessionController`.
- [x] `main.dart`: providers por `uid + storeId`; `sessionProviders(AppSession)`;
      `Provider<AppSession>` disponible en toda la sesión.
- [x] Recordar última tienda del dueño en `users/{uid}.lastStoreId`.
- [x] Reglas: `stores`, `employees` (lectura/borrado; alta en Fase 3) + 15 pruebas en emulador (40 en total).
- [x] Registro: quitar el selector de rol `isAdmin`. `HomePage` elige el dashboard
      según el rol de la sesión.
- [x] Ajustes: sección "Tienda" (dueño: editar / cambiar de tienda; empleado: abandonar).

### Fase 2 — Datos dentro de la tienda + migración · tamaño L
- [ ] Repositorios con `storeId`: productos, clientes, carritos, ventas, cobro.
- [ ] Cobro (`PaymentRepositoryImpl`): rutas nuevas + `soldBy`, `soldByName` y totales
      finales (subtotal, IVA, descuento, delivery, tasa, total).
- [ ] Carritos: `createdBy`.
- [ ] IVA y tasa leídos/escritos en `stores/{storeId}` (quitar de `Prefs`).
- [ ] Quitar espejos Sembast de los repositorios nuevos.
- [ ] Historial: dueño → todas las ventas (filtro opcional por empleado);
      empleado → `where soldBy == uid`.
- [ ] **Migración automática** de los datos actuales (ver §6).
- [ ] Reglas de subcolecciones + reglas legadas de solo lectura/borrado + tests.
- [ ] Índices compuestos.
- [ ] Unificar dashboards en `HomeDashboard` con permisos por rol.

### Fase 3 — Empleados e invitaciones · tamaño M
- [ ] Dueño: "Invitar empleado" → genera código (alfabeto sin caracteres ambiguos,
      p. ej. sin `0/O/1/I`), crea `invitations/{code}` y abre el menú de compartir.
- [ ] Dueño: lista de invitaciones pendientes (revocar) y de empleados (desvincular).
- [ ] Empleado: pantalla "Tengo un código" → valida y ejecuta **batch**:
      crear `employees/{uid}` + marcar `invitations/{code}.usedBy`.
- [ ] Empleado: opción "Abandonar tienda".
- [ ] Mensajes claros: código inválido, caducado, ya usado, ya perteneces a una tienda.
- [ ] Reglas de `invitations` + tests (código caducado, reutilizado, de otra tienda…).

### Fase 4 — CRUD de tienda y configuración · tamaño M
- [ ] Pantalla de la tienda: editar nombre/descripción, IVA, tasa de cambio.
- [ ] Archivar tienda (no se borra: borrar subcolecciones desde la app exige borrar
      documento por documento). Al archivar, se desvincula a los empleados.
- [ ] Ajustes: "Cambiar de tienda" (dueño), "Abandonar tienda" (empleado).
- [ ] Ocultar en la UI todo lo que el rol no permite (las reglas ya lo bloquean).

### Fase 5 — Limpieza y endurecimiento · tamaño S
- [ ] Tras confirmar que todos los dispositivos migraron: eliminar reglas de
      colecciones legadas y el código de migración.
- [ ] Eliminar `isAdmin` de `users`, `PrefKeys.userId/userRole`, `ClientRepositoryImpl`
      (Sembast) y `MigrateLocalClientsUseCase`.
- [ ] Revisión final de reglas con el emulador y checklist de pruebas manuales (§7).

---

## 6. Migración de los datos actuales

Se ejecuta en la app (sin servidor), una vez por usuario, desde `SessionGate`:

1. **Condición**: el usuario no es empleado, no tiene `users/{uid}.migratedAt`
   y tiene datos legados (`products`/`carts`/`clients`/`sales-history` con su
   `userId`, o clientes en Sembast local).
2. **Tienda destino**: si ya tiene tiendas (p. ej. creó una al probar la Fase 1),
   la primera que creó; si no, crea una con **id determinista** `legacy_{uid}`,
   nombre "Mi tienda" (editable después), e IVA/tasa tomados de `Prefs`.
3. Copia cada colección a su subcolección **conservando los ids** (los carritos
   siguen enlazados a sus clientes por `ownerId`), en batches de ≤ 400 escrituras.
   En las ventas añade `soldBy = uid`; en los carritos `createdBy = uid`.
4. Verifica conteos (origen = destino).
5. Marca `users/{uid}.migratedAt`.
6. Borra los documentos legados y los clientes locales de Sembast.

Es **idempotente**: si se interrumpe (sin red, app cerrada), al reintentar escribe
los mismos ids en la misma tienda y continúa. Muestra `MigrationScreen` con progreso.

⚠️ Las versiones antiguas de la app seguirían escribiendo en las colecciones
legadas: hay que **instalar la versión nueva en todos los dispositivos** antes de
publicar las reglas nuevas.

---

## 7. Checklist de pruebas manuales (al final)

- [ ] Usuario nuevo → crea tienda → crea productos/clientes → cobra.
- [ ] Usuario existente → migración → ve sus productos, clientes, carritos y ventas.
- [ ] Dueño con 2 tiendas → datos separados al cambiar de tienda.
- [ ] Dueño invita → empleado usa el código → entra directo a la tienda.
- [ ] Código usado / caducado / inválido → mensaje correcto.
- [ ] Empleado: no ve "Agregar producto"; cobra; ve solo sus ventas.
- [ ] Empleado cobra con stock insuficiente → error y no se comparte factura.
- [ ] Dueño desvincula empleado → la sesión del empleado se cierra al instante.
- [ ] Empleado desvinculado crea su propia tienda.
- [ ] Empleado vinculado no puede crear tienda.
- [ ] Sin conexión: ver productos/clientes cacheados; cobro muestra error claro.

---

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| Reglas mal escritas exponen datos de otra tienda | Pruebas de reglas en emulador antes de cada publicación. |
| Migración interrumpida | Ids deterministas + idempotencia + borrado de legados solo tras verificar. |
| Dispositivos con versión vieja | Actualizar todos antes de publicar reglas nuevas. |
| Cobro sin conexión | Ya falla con mensaje (transacción); se mantiene. |
| Coste de lecturas por `get()` en reglas | Bajo para el volumen esperado; si crece, migrar a custom claims (requiere Cloud Functions). |
