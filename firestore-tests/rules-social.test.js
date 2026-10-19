// Security rules for the "focusing now" status and treats between friends.
const { test, before, after, beforeEach, describe } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const {
  serverTimestamp, doc, setDoc, getDoc, getDocs, updateDoc, deleteDoc,
  collection, query, where, limit, orderBy, Timestamp,
} = require('firebase/firestore');

let env;

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({
    projectId: 'demo-studycafe-social',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host,
      port: Number(port),
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();
const seed = (fn) => env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
const minutes = (n) => Timestamp.fromDate(new Date(Date.now() + n * 60000));

describe('presence (focusing now)', () => {
  const presence = (extra = {}) => ({
    name: 'Mia',
    endsAt: minutes(25),
    updatedAt: serverTimestamp(),
    ...extra,
  });

  test('a user publishes their own status and removes it', async () => {
    await assertSucceeds(setDoc(doc(as('a'), 'presence/a'), presence()));
    await assertSucceeds(deleteDoc(doc(as('a'), 'presence/a')));
  });

  test('nobody writes or deletes the status of someone else; signed-out cannot write', async () => {
    await assertFails(setDoc(doc(as('b'), 'presence/a'), presence()));
    await assertFails(setDoc(doc(anon(), 'presence/a'), presence()));
    await seed((db) => setDoc(doc(db, 'presence/a'), { name: 'Mia', endsAt: minutes(25), updatedAt: Timestamp.now() }));
    await assertFails(deleteDoc(doc(as('b'), 'presence/a')));
  });

  test('the end time must be in the future and at most 3 hours away', async () => {
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ endsAt: minutes(-5) })));
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ endsAt: minutes(181) })));
    await assertSucceeds(setDoc(doc(as('a'), 'presence/a'), presence({ endsAt: minutes(179) })));
  });

  test('name and fields are validated', async () => {
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ name: '' })));
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ name: 'x'.repeat(41) })));
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ name: 5 })));
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ email: 'a@x.y' })));
    await assertFails(setDoc(doc(as('a'), 'presence/a'), presence({ updatedAt: Timestamp.fromDate(new Date(0)) })));
  });

  test('signed-in users can list at most 30, signed-out none', async () => {
    await seed((db) => setDoc(doc(db, 'presence/a'), { name: 'Mia', endsAt: minutes(25), updatedAt: Timestamp.now() }));
    const q = (db, n) => query(collection(db, 'presence'), where('endsAt', '>', Timestamp.now()), orderBy('endsAt'), limit(n));
    await assertSucceeds(getDocs(q(as('b'), 30)));
    await assertFails(getDocs(q(as('b'), 31)));
    await assertFails(getDocs(collection(as('b'), 'presence')));
    await assertFails(getDocs(q(anon(), 10)));
  });
});

describe('gifts', () => {
  const slot = () => Math.floor(Date.now() / 600000);
  const gift = (from, to, extra = {}) => ({
    fromUid: from,
    fromName: 'Mia',
    toUid: to,
    itemId: 'tea_green',
    seen: false,
    slot: slot(),
    createdAt: serverTimestamp(),
    ...extra,
  });
  const id = (from, to) => `${from}_${to}_${slot()}`;
  const focusing = (uid) =>
    seed((db) => setDoc(doc(db, `presence/${uid}`), { name: 'Sam', endsAt: minutes(20), updatedAt: Timestamp.now() }));

  test('a treat to a friend who is focusing right now succeeds', async () => {
    await focusing('sam');
    await assertSucceeds(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
  });

  test('a second treat to the same friend in the same slot is refused', async () => {
    await focusing('sam');
    await assertSucceeds(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam', { itemId: 'cake_cheese' })));
  });

  test('the friend must be focusing: no status, or an expired one', async () => {
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
    await seed((db) => setDoc(doc(db, 'presence/sam'), { name: 'Sam', endsAt: minutes(-1), updatedAt: Timestamp.now() }));
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
  });

  test('cannot send to yourself or pretend to be someone else', async () => {
    await focusing('mia');
    await focusing('sam');
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'mia')}`), gift('mia', 'mia')));
    await assertFails(setDoc(doc(as('eve'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('eve', 'sam')));
  });

  test('the document id must encode sender, friend and the current slot', async () => {
    await focusing('sam');
    await assertFails(setDoc(doc(as('mia'), 'gifts/anything'), gift('mia', 'sam')));
    await assertFails(setDoc(doc(as('mia'), `gifts/mia_sam_${slot() - 1}`), gift('mia', 'sam', { slot: slot() - 1 })));
    await assertFails(setDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam', { slot: slot() + 5 })));
  });

  test('only known treats, no extra fields, never created as already seen', async () => {
    await focusing('sam');
    const ref = () => doc(as('mia'), `gifts/${id('mia', 'sam')}`);
    await assertFails(setDoc(ref(), gift('mia', 'sam', { itemId: 'gold_bar' })));
    await assertFails(setDoc(ref(), gift('mia', 'sam', { message: 'hi' })));
    await assertFails(setDoc(ref(), gift('mia', 'sam', { seen: true })));
    await assertFails(setDoc(ref(), gift('mia', 'sam', { fromName: '' })));
    await assertFails(setDoc(ref(), gift('mia', 'sam', { fromName: 'x'.repeat(41) })));
    await assertFails(setDoc(ref(), gift('mia', 'sam', { createdAt: Timestamp.fromDate(new Date(0)) })));
    await assertSucceeds(setDoc(ref(), gift('mia', 'sam')));
  });

  test('the signed-out cannot send', async () => {
    await focusing('sam');
    await assertFails(setDoc(doc(anon(), `gifts/${id('mia', 'sam')}`), gift('mia', 'sam')));
  });

  const seedGift = () =>
    seed((db) =>
      setDoc(doc(db, `gifts/${id('mia', 'sam')}`), {
        fromUid: 'mia', fromName: 'Mia', toUid: 'sam', itemId: 'tea_green', seen: false, slot: slot(), createdAt: Timestamp.now(),
      }),
    );

  test('only the recipient reads their treats', async () => {
    await seedGift();
    await assertSucceeds(getDoc(doc(as('sam'), `gifts/${id('mia', 'sam')}`)));
    await assertSucceeds(getDocs(query(collection(as('sam'), 'gifts'), where('toUid', '==', 'sam'))));
    await assertFails(getDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`)));
    await assertFails(getDoc(doc(as('eve'), `gifts/${id('mia', 'sam')}`)));
    await assertFails(getDocs(query(collection(as('eve'), 'gifts'), where('toUid', '==', 'sam'))));
    await assertFails(getDocs(collection(as('eve'), 'gifts')));
  });

  test('the recipient marks it as read, once, and changes nothing else', async () => {
    await seedGift();
    const ref = () => doc(as('sam'), `gifts/${id('mia', 'sam')}`);
    await assertFails(updateDoc(ref(), { seen: true, itemId: 'cake_cheese' }));
    await assertFails(updateDoc(ref(), { toUid: 'eve', seen: true }));
    await assertSucceeds(updateDoc(ref(), { seen: true }));
    await assertFails(updateDoc(ref(), { seen: false }));
  });

  test('the sender cannot edit or delete; the recipient can clear their inbox', async () => {
    await seedGift();
    await assertFails(updateDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`), { seen: true }));
    await assertFails(deleteDoc(doc(as('mia'), `gifts/${id('mia', 'sam')}`)));
    await assertFails(deleteDoc(doc(as('eve'), `gifts/${id('mia', 'sam')}`)));
    await assertSucceeds(deleteDoc(doc(as('sam'), `gifts/${id('mia', 'sam')}`)));
  });
});
