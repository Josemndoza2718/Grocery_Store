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
