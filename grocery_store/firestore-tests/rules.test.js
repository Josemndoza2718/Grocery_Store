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

// Collections of the old per-user model: read-only backup for their owner
// (the app only reads them to migrate them into a store).
for (const name of ['products', 'carts', 'clients', 'sales-history']) {
  describe(`legacy /${name}`, () => {
    test('owner can read their documents and query them by userId', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await seed(`${name}/d2`, { userId: BOB });
      await assertSucceeds(getDoc(doc(db(ALICE), `${name}/d1`)));
      await assertSucceeds(
        getDocs(query(collection(db(ALICE), name), where('userId', '==', ALICE))),
      );
    });

    test("cannot read another user's documents or list everything", async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await assertFails(getDoc(doc(db(BOB), `${name}/d1`)));
      await assertFails(getDocs(collection(db(ALICE), name)));
      await assertFails(getDoc(doc(anon(), `${name}/d1`)));
    });

    test('nobody can write anymore (old app versions are blocked)', async () => {
      await seed(`${name}/d1`, { userId: ALICE });
      await assertFails(setDoc(doc(db(ALICE), `${name}/d2`), { userId: ALICE }));
      await assertFails(updateDoc(doc(db(ALICE), `${name}/d1`), { x: 1 }));
      await assertFails(deleteDoc(doc(db(ALICE), `${name}/d1`)));
    });
  });
}

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

// ───────────────────────── Multi-store data (Phase 2) ─────────────────────────

const DAVE = 'dave'; // employee of Bob's store

/** Alice owns s1 (Carol works there); Bob owns s2 (Dave works there). */
async function seedStores() {
  await seed('stores/s1', storeData(ALICE));
  await seed('stores/s2', storeData(BOB));
  await seed(`employees/${CAROL}`, { storeId: 's1' });
  await seed(`employees/${DAVE}`, { storeId: 's2' });
}

describe('stores/{id}/products', () => {
  test('members read; outsiders and other stores cannot', async () => {
    await seedStores();
    await seed('stores/s1/products/p1', { name: 'Harina', stockQuantity: 10 });
    await assertSucceeds(getDoc(doc(db(ALICE), 'stores/s1/products/p1')));
    await assertSucceeds(getDoc(doc(db(CAROL), 'stores/s1/products/p1')));
    await assertSucceeds(getDocs(collection(db(CAROL), 'stores/s1/products')));
    await assertFails(getDoc(doc(db(BOB), 'stores/s1/products/p1')));
    await assertFails(getDoc(doc(db(DAVE), 'stores/s1/products/p1')));
  });

  test('only the owner creates, edits and deletes products', async () => {
    await seedStores();
    await seed('stores/s1/products/p1', { name: 'Harina', stockQuantity: 10, price: 1 });
    await assertSucceeds(
      setDoc(doc(db(ALICE), 'stores/s1/products/p2'), { name: 'Arroz', stockQuantity: 5 }),
    );
    await assertSucceeds(updateDoc(doc(db(ALICE), 'stores/s1/products/p1'), { price: 2 }));
    await assertSucceeds(
      updateDoc(doc(db(ALICE), 'stores/s1/products/p1'), { stockQuantity: 50 }),
    );
    await assertFails(
      setDoc(doc(db(CAROL), 'stores/s1/products/p3'), { name: 'X', stockQuantity: 1 }),
    );
    await assertFails(updateDoc(doc(db(CAROL), 'stores/s1/products/p1'), { price: 0 }));
    await assertFails(deleteDoc(doc(db(CAROL), 'stores/s1/products/p1')));
    await assertSucceeds(deleteDoc(doc(db(ALICE), 'stores/s1/products/p2')));
  });

  test('an employee can only DECREASE stock, never restock or go negative', async () => {
    await seedStores();
    await seed('stores/s1/products/p1', { name: 'Harina', stockQuantity: 10 });
    await assertSucceeds(
      updateDoc(doc(db(CAROL), 'stores/s1/products/p1'), { stockQuantity: 7 }),
    );
    await assertFails(
      updateDoc(doc(db(CAROL), 'stores/s1/products/p1'), { stockQuantity: 9 }),
    );
    await assertFails(
      updateDoc(doc(db(CAROL), 'stores/s1/products/p1'), { stockQuantity: -1 }),
    );
    await assertFails(
      updateDoc(doc(db(CAROL), 'stores/s1/products/p1'), { stockQuantity: 6, price: 0 }),
    );
  });
});

for (const name of ['clients', 'carts']) {
  describe(`stores/{id}/${name}`, () => {
    test('all members manage them; other stores cannot', async () => {
      await seedStores();
      await assertSucceeds(setDoc(doc(db(CAROL), `stores/s1/${name}/x1`), { name: 'Ana' }));
      await assertSucceeds(updateDoc(doc(db(ALICE), `stores/s1/${name}/x1`), { name: 'Ana M.' }));
      await assertSucceeds(getDocs(collection(db(CAROL), `stores/s1/${name}`)));
      await assertFails(getDoc(doc(db(DAVE), `stores/s1/${name}/x1`)));
      await assertFails(setDoc(doc(db(BOB), `stores/s1/${name}/x2`), { name: 'Hack' }));
      await assertSucceeds(deleteDoc(doc(db(CAROL), `stores/s1/${name}/x1`)));
    });
  });
}

describe('stores/{id}/sales', () => {
  test('sales must be attributed to whoever creates them', async () => {
    await seedStores();
    await assertSucceeds(setDoc(doc(db(CAROL), 'stores/s1/sales/v1'), { soldBy: CAROL }));
    await assertFails(setDoc(doc(db(CAROL), 'stores/s1/sales/v2'), { soldBy: ALICE }));
    await assertFails(setDoc(doc(db(DAVE), 'stores/s1/sales/v3'), { soldBy: DAVE }));
  });

  test('owner sees every sale; an employee only the ones they charged', async () => {
    await seedStores();
    await seed('stores/s1/sales/v1', { soldBy: CAROL, updatedAt: '2026-01-02' });
    await seed('stores/s1/sales/v2', { soldBy: ALICE, updatedAt: '2026-01-01' });

    await assertSucceeds(getDocs(collection(db(ALICE), 'stores/s1/sales')));
    await assertSucceeds(getDoc(doc(db(CAROL), 'stores/s1/sales/v1')));
    await assertFails(getDoc(doc(db(CAROL), 'stores/s1/sales/v2')));
    // The employee query must be filtered by their own uid.
    await assertSucceeds(
      getDocs(query(collection(db(CAROL), 'stores/s1/sales'), where('soldBy', '==', CAROL))),
    );
    await assertFails(getDocs(collection(db(CAROL), 'stores/s1/sales')));
  });

  test('sales are immutable', async () => {
    await seedStores();
    await seed('stores/s1/sales/v1', { soldBy: ALICE, total: 10 });
    await assertFails(updateDoc(doc(db(ALICE), 'stores/s1/sales/v1'), { total: 0 }));
    await assertFails(deleteDoc(doc(db(ALICE), 'stores/s1/sales/v1')));
  });
});

describe('checkout in a store (same writes as PaymentRepositoryImpl)', () => {
  async function seedCheckout() {
    await seedStores();
    await seed('stores/s1/products/p1', { name: 'Harina', stockQuantity: 10 });
    await seed('stores/s1/carts/c1', { ownerId: 'cl1' });
  }

  for (const [who, uid] of [['owner', ALICE], ['employee', CAROL]]) {
    test(`the ${who} can charge: stock down + sale + delete cart`, async () => {
      await seedCheckout();
      const fs = db(uid); // a batch needs refs from the same instance
      const batch = writeBatch(fs);
      batch.update(doc(fs, 'stores/s1/products/p1'), { stockQuantity: 8 });
      batch.set(doc(fs, 'stores/s1/sales/c1'), { soldBy: uid, status: 'paid' });
      batch.delete(doc(fs, 'stores/s1/carts/c1'));
      await assertSucceeds(batch.commit());
    });
  }

  test("a member of another store cannot charge this store's cart", async () => {
    await seedCheckout();
    const fs = db(DAVE);
    const batch = writeBatch(fs);
    batch.update(doc(fs, 'stores/s1/products/p1'), { stockQuantity: 8 });
    batch.set(doc(fs, 'stores/s1/sales/c1'), { soldBy: DAVE, status: 'paid' });
    batch.delete(doc(fs, 'stores/s1/carts/c1'));
    await assertFails(batch.commit());
  });
});

describe('legacy migration (same writes as LegacyMigrationRepositoryImpl)', () => {
  test('the owner can copy legacy data into their store keeping the ids', async () => {
    await seedStores();
    await seed('products/p1', { userId: ALICE, name: 'Harina', stockQuantity: 3 });
    await seed('sales-history/v1', { userId: ALICE, total: 5 });

    const fs = db(ALICE);
    const products = await getDocs(
      query(collection(fs, 'products'), where('userId', '==', ALICE)),
    );
    const sales = await getDocs(
      query(collection(fs, 'sales-history'), where('userId', '==', ALICE)),
    );
    const batch = writeBatch(fs);
    products.forEach((d) => batch.set(doc(fs, `stores/s1/products/${d.id}`), d.data()));
    sales.forEach((d) =>
      batch.set(doc(fs, `stores/s1/sales/${d.id}`), { ...d.data(), soldBy: ALICE }),
    );
    batch.set(doc(fs, 'stores/s1/clients/cl1'), { name: 'Ana', userId: ALICE });
    batch.set(doc(fs, 'stores/s1/carts/c1'), { ownerId: 'cl1', createdBy: ALICE });
    await assertSucceeds(batch.commit());

    // Retrying is safe for everything except sales (immutable): the app skips
    // the ids that already exist in the store.
    await assertFails(
      setDoc(doc(fs, 'stores/s1/sales/v1'), { userId: ALICE, total: 5, soldBy: ALICE }),
    );
  });

  test('the migrated-at mark is saved in the own profile', async () => {
    await assertSucceeds(
      setDoc(
        doc(db(ALICE), `users/${ALICE}`),
        { migratedAt: '2026-11-18', migratedToStoreId: 's1' },
        { merge: true },
      ),
    );
  });
});
