// Pruebas de firestore.rules contra el emulador de Firestore.
//
// Ejecutar desde esta carpeta:
//   npm run test:emulator
// (arranca el emulador con un proyecto "demo-" que nunca toca datos reales,
//  corre las pruebas y lo apaga)
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-grocery-store';
const ALICE = 'alice';
const BOB = 'bob';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

const db = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

/** Writes data bypassing the rules (test setup). */
async function seed(path, data) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), path), data);
  });
}

// Collections isolated by the `userId` field (current model).
for (const name of ['products', 'carts', 'clients']) {
  describe(`/${name}`, () => {
    test('owner can create a document with their own userId', async () => {
      await assertSucceeds(setDoc(doc(db(ALICE), `${name}/d1`), { userId: ALICE }));
    });

    test('cannot create a document on behalf of another user', async () => {
      await assertFails(setDoc(doc(db(ALICE), `${name}/d1`), { userId: BOB }));
    });

    test('unauthenticated users cannot read', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await assertFails(getDoc(doc(anon(), `${name}/d1`)));
    });

    test('owner can read; another user cannot', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await assertSucceeds(getDoc(doc(db(ALICE), `${name}/d1`)));
      await assertFails(getDoc(doc(db(BOB), `${name}/d1`)));
    });

    test('query filtered by own userId is allowed; unfiltered query is denied', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await seed(`${name}/d2`, { userId: BOB });
      await assertSucceeds(
        getDocs(query(collection(db(ALICE), name), where('userId', '==', ALICE))),
      );
      await assertFails(getDocs(collection(db(ALICE), name)));
    });

    test('another user cannot update or delete', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await assertFails(updateDoc(doc(db(BOB), `${name}/d1`), { x: 1 }));
      await assertFails(deleteDoc(doc(db(BOB), `${name}/d1`)));
      await assertSucceeds(deleteDoc(doc(db(ALICE), `${name}/d1`)));
    });
  });
}

describe('/clients', () => {
  test('owner cannot transfer a client to another user', async () => {
    await seed('clients/c1', { userId: ALICE, name: 'Ana' });
    await assertFails(updateDoc(doc(db(ALICE), 'clients/c1'), { userId: BOB }));
    await assertSucceeds(updateDoc(doc(db(ALICE), 'clients/c1'), { name: 'Ana M.' }));
  });
});

describe('/sales-history', () => {
  test('owner can create and read their sales', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'sales-history/s1'), { userId: ALICE }));
    await assertSucceeds(getDoc(doc(db(ALICE), 'sales-history/s1')));
    await assertFails(getDoc(doc(db(BOB), 'sales-history/s1')));
  });

  test('sales are immutable (no update or delete, even by the owner)', async () => {
    await seed('sales-history/s1', { userId: ALICE, total: 10 });
    await assertFails(updateDoc(doc(db(ALICE), 'sales-history/s1'), { total: 0 }));
    await assertFails(deleteDoc(doc(db(ALICE), 'sales-history/s1')));
  });
});

describe('checkout (same writes as PaymentRepositoryImpl)', () => {
  test('owner can atomically update stock, create the sale and delete the cart', async () => {
    await seed('products/p1', { userId: ALICE, stockQuantity: 10 });
    await seed('carts/c1', { userId: ALICE });

    const alice = db(ALICE); // a batch needs refs from the same instance
    const batch = writeBatch(alice);
    batch.update(doc(alice, 'products/p1'), { stockQuantity: 8 });
    batch.set(doc(alice, 'sales-history/c1'), { userId: ALICE, status: 'paid' });
    batch.delete(doc(alice, 'carts/c1'));
    await assertSucceeds(batch.commit());
  });

  test("another user cannot charge someone else's cart", async () => {
    await seed('products/p1', { userId: ALICE, stockQuantity: 10 });
    await seed('carts/c1', { userId: ALICE });

    const bob = db(BOB);
    const batch = writeBatch(bob);
    batch.update(doc(bob, 'products/p1'), { stockQuantity: 8 });
    batch.delete(doc(bob, 'carts/c1'));
    await assertFails(batch.commit());
  });
});

describe('/users', () => {
  test('a user can create, read and update only their own profile', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), `users/${ALICE}`), { name: 'Alice' }));
    await assertSucceeds(getDoc(doc(db(ALICE), `users/${ALICE}`)));
    await assertFails(getDoc(doc(db(BOB), `users/${ALICE}`)));
    await assertFails(setDoc(doc(db(BOB), `users/${ALICE}`), { name: 'Hacked' }));
  });

  test('profiles cannot be deleted', async () => {
    await seed(`users/${ALICE}`, { name: 'Alice' });
    await assertFails(deleteDoc(doc(db(ALICE), `users/${ALICE}`)));
  });
});

// ───────────────────────── Multi-store (Phase 1) ─────────────────────────

const CAROL = 'carol'; // employee of Alice's store

const storeData = (ownerId, extra = {}) => ({
  name: 'Abasto Central',
  description: '',
  ownerId,
  iva: 16,
  exchangeRate: 36.5,
  archived: false,
  createdAt: '2026-11-18T00:00:00.000',
  updatedAt: '2026-11-18T00:00:00.000',
  ...extra,
});

describe('/stores', () => {
  test('a user can create a store they own', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'stores/s1'), storeData(ALICE)));
  });

  test('cannot create a store owned by someone else', async () => {
    await assertFails(setDoc(doc(db(ALICE), 'stores/s1'), storeData(BOB)));
  });

  test('cannot create an archived store or with invalid fields', async () => {
    await assertFails(
      setDoc(doc(db(ALICE), 'stores/s1'), storeData(ALICE, { archived: true })),
    );
    await assertFails(setDoc(doc(db(ALICE), 'stores/s1'), storeData(ALICE, { name: '' })));
    await assertFails(setDoc(doc(db(ALICE), 'stores/s1'), storeData(ALICE, { iva: -1 })));
    await assertFails(
      setDoc(doc(db(ALICE), 'stores/s1'), storeData(ALICE, { name: 'x'.repeat(81) })),
    );
  });

  test('an employee linked to a store cannot create stores', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertFails(setDoc(doc(db(CAROL), 'stores/s2'), storeData(CAROL)));
  });

  test('owner can read and list their stores; others cannot', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed('stores/s2', storeData(BOB));
    await assertSucceeds(getDoc(doc(db(ALICE), 'stores/s1')));
    await assertFails(getDoc(doc(db(BOB), 'stores/s1')));
    await assertSucceeds(
      getDocs(query(collection(db(ALICE), 'stores'), where('ownerId', '==', ALICE))),
    );
    await assertFails(getDocs(collection(db(ALICE), 'stores')));
  });

  test('employee can read their store but not another one', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed('stores/s2', storeData(BOB));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(getDoc(doc(db(CAROL), 'stores/s1')));
    await assertFails(getDoc(doc(db(CAROL), 'stores/s2')));
  });

  test('only the owner can update, and ownership cannot be transferred', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(updateDoc(doc(db(ALICE), 'stores/s1'), { name: 'Nuevo nombre' }));
    await assertSucceeds(updateDoc(doc(db(ALICE), 'stores/s1'), { archived: true }));
    await assertFails(updateDoc(doc(db(ALICE), 'stores/s1'), { ownerId: BOB }));
    await assertFails(updateDoc(doc(db(CAROL), 'stores/s1'), { name: 'Hack' }));
    await assertFails(updateDoc(doc(db(BOB), 'stores/s1'), { name: 'Hack' }));
  });

  test('stores cannot be deleted', async () => {
    await seed('stores/s1', storeData(ALICE));
    await assertFails(deleteDoc(doc(db(ALICE), 'stores/s1')));
  });
});

describe('/employees', () => {
  test('a user can read their own link, even if it does not exist', async () => {
    await assertSucceeds(getDoc(doc(db(CAROL), `employees/${CAROL}`)));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(getDoc(doc(db(CAROL), `employees/${CAROL}`)));
  });

  test("the store owner can read and list the store's employees", async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(getDoc(doc(db(ALICE), `employees/${CAROL}`)));
    await assertSucceeds(
      getDocs(query(collection(db(ALICE), 'employees'), where('storeId', '==', 's1'))),
    );
  });

  test("other users cannot read someone else's link", async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertFails(getDoc(doc(db(BOB), `employees/${CAROL}`)));
  });

  test('links cannot be created or edited yet (Phase 3: invitation codes)', async () => {
    await seed('stores/s1', storeData(ALICE));
    await assertFails(setDoc(doc(db(CAROL), `employees/${CAROL}`), { storeId: 's1' }));
    await assertFails(setDoc(doc(db(ALICE), `employees/${CAROL}`), { storeId: 's1' }));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertFails(updateDoc(doc(db(CAROL), `employees/${CAROL}`), { storeId: 's2' }));
  });

  test('the owner can unlink an employee and the employee can leave', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertFails(deleteDoc(doc(db(BOB), `employees/${CAROL}`)));
    await assertSucceeds(deleteDoc(doc(db(ALICE), `employees/${CAROL}`)));

    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(deleteDoc(doc(db(CAROL), `employees/${CAROL}`)));
  });

  test('after being unlinked the employee loses access to the store', async () => {
    await seed('stores/s1', storeData(ALICE));
    await seed(`employees/${CAROL}`, { storeId: 's1' });
    await assertSucceeds(getDoc(doc(db(CAROL), 'stores/s1')));
    await deleteDoc(doc(db(ALICE), `employees/${CAROL}`));
    await assertFails(getDoc(doc(db(CAROL), 'stores/s1')));
  });

  test('the last-store preference can be saved in the own profile', async () => {
    await assertSucceeds(
      setDoc(doc(db(ALICE), `users/${ALICE}`), { lastStoreId: 's1' }, { merge: true }),
    );
  });
});
