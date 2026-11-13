// Runs firestore.rules against the local Firestore emulator.
//   cd firestore-tests && npm install && npm test
const { test, before, after, beforeEach, describe } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { serverTimestamp, doc, setDoc, getDoc, getDocs, updateDoc, deleteDoc, collection, query, where, Timestamp } = require('firebase/firestore');

let env;

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({
    projectId: 'demo-studycafe',
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

describe('users', () => {
  test('owner reads and writes their own profile', async () => {
    await assertSucceeds(setDoc(doc(as('a'), 'users/a'), { displayName: 'A', email: 'a@x.y' }));
    await assertSucceeds(getDoc(doc(as('a'), 'users/a')));
  });
  test('others and signed-out users are denied', async () => {
    await seed((db) => setDoc(doc(db, 'users/a'), { displayName: 'A' }));
    await assertFails(getDoc(doc(as('b'), 'users/a')));
    await assertFails(getDoc(doc(anon(), 'users/a')));
    await assertFails(setDoc(doc(as('b'), 'users/a'), { displayName: 'hack' }));
  });
});

describe('leaderboard', () => {
  const ok = { displayName: 'Mia', totalPoints: 120, totalStudyMinutes: 300, currentStreak: 2, longestStreak: 4 };

  test('any signed-in user can read, signed-out cannot', async () => {
    await seed((db) => setDoc(doc(db, 'leaderboard/a'), ok));
    await assertSucceeds(getDoc(doc(as('b'), 'leaderboard/a')));
    await assertFails(getDoc(doc(anon(), 'leaderboard/a')));
  });
  test('owner can write valid data, including a partial merge', async () => {
    await assertSucceeds(setDoc(doc(as('a'), 'leaderboard/a'), ok));
    await assertSucceeds(setDoc(doc(as('a'), 'leaderboard/a'), { currentStreak: 3 }, { merge: true }));
  });
  test('nobody writes another user\'s entry', async () => {
    await assertFails(setDoc(doc(as('b'), 'leaderboard/a'), ok));
  });
  test('extra fields, long names, wrong types and huge scores are rejected', async () => {
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, email: 'a@x.y' }));
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, displayName: 'x'.repeat(41) }));
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, displayName: 42 }));
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, totalPoints: 'many' }));
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, totalPoints: 10000001 }));
    await assertFails(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, totalPoints: -1 }));
    await assertSucceeds(setDoc(doc(as('a'), 'leaderboard/a'), { ...ok, displayName: 'x'.repeat(40) }));
  });
  test('owner can delete their entry, others cannot', async () => {
    await seed((db) => setDoc(doc(db, 'leaderboard/a'), ok));
    await assertFails(deleteDoc(doc(as('b'), 'leaderboard/a')));
    await assertSucceeds(deleteDoc(doc(as('a'), 'leaderboard/a')));
  });
});

describe('reports', () => {
  const report = (me, other, extra = {}) => ({
    reportedUid: other,
    reporterUid: me,
    reason: 'cheating',
    createdAt: serverTimestamp(),
    ...extra,
  });

  test('a signed-in user can report once per player', async () => {
    await assertSucceeds(setDoc(doc(as('a'), 'reports/a_b'), report('a', 'b')));
    await assertFails(setDoc(doc(as('a'), 'reports/a_b'), report('a', 'b'))); // second time = update
  });
  test('the id must encode reporter and player; reporter must be the caller', async () => {
    await assertFails(setDoc(doc(as('a'), 'reports/whatever'), report('a', 'b')));
    await assertFails(setDoc(doc(as('a'), 'reports/c_b'), report('c', 'b')));
  });
  test('only known reasons and fields', async () => {
    await assertFails(setDoc(doc(as('a'), 'reports/a_b'), report('a', 'b', { reason: 'because' })));
    await assertFails(setDoc(doc(as('a'), 'reports/a_b'), report('a', 'b', { note: 'x' })));
  });
  test('reports cannot be read back from the app', async () => {
    await seed((db) => setDoc(doc(db, 'reports/a_b'), { reportedUid: 'b', reporterUid: 'a', reason: 'other' }));
    await assertFails(getDoc(doc(as('a'), 'reports/a_b')));
    await assertFails(getDoc(doc(as('b'), 'reports/a_b')));
  });
});

describe('invite_codes', () => {
  test('owner creates a valid code; others can look it up but not list', async () => {
    await assertSucceeds(setDoc(doc(as('a'), 'invite_codes/ABC234'), { ownerUid: 'a' }));
    await assertSucceeds(getDoc(doc(as('b'), 'invite_codes/ABC234')));
    await assertFails(getDocs(collection(as('b'), 'invite_codes')));
    await assertFails(getDoc(doc(anon(), 'invite_codes/ABC234')));
  });
  test('malformed ids and foreign owners are rejected', async () => {
    await assertFails(setDoc(doc(as('a'), 'invite_codes/abc234'), { ownerUid: 'a' }));
    await assertFails(setDoc(doc(as('a'), 'invite_codes/ABC23'), { ownerUid: 'a' }));
    await assertFails(setDoc(doc(as('a'), 'invite_codes/ABCI23'), { ownerUid: 'a' }));
    await assertFails(setDoc(doc(as('a'), 'invite_codes/ABC234'), { ownerUid: 'b' }));
    await assertFails(setDoc(doc(as('a'), 'invite_codes/ABC234'), { ownerUid: 'a', extra: 1 }));
  });
  test('a code cannot be taken over or changed', async () => {
    await seed((db) => setDoc(doc(db, 'invite_codes/ABC234'), { ownerUid: 'a' }));
    await assertFails(setDoc(doc(as('b'), 'invite_codes/ABC234'), { ownerUid: 'b' }));
    await assertFails(updateDoc(doc(as('a'), 'invite_codes/ABC234'), { ownerUid: 'b' }));
    await assertFails(deleteDoc(doc(as('b'), 'invite_codes/ABC234')));
    await assertSucceeds(deleteDoc(doc(as('a'), 'invite_codes/ABC234'))); // owner, account deletion
  });
});

describe('referrals', () => {
  const referral = (referrer, code = 'ABC234', extra = {}) => ({
    referrerUid: referrer,
    code,
    claimed: false,
    createdAt: serverTimestamp(),
    ...extra,
  });
  const seedCode = () => seed((db) => setDoc(doc(db, 'invite_codes/ABC234'), { ownerUid: 'inviter' }));

  test('a new user redeems a real code once', async () => {
    await seedCode();
    await assertSucceeds(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter')));
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter'))); // again = update
  });
  test('cannot redeem for someone else, or with a made-up referrer', async () => {
    await seedCode();
    await assertFails(setDoc(doc(as('friend'), 'referrals/other'), referral('inviter')));
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('someone-else')));
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter', 'ZZZ999')));
  });
  test('cannot redeem your own code', async () => {
    await seedCode();
    await assertFails(setDoc(doc(as('inviter'), 'referrals/inviter'), referral('inviter')));
  });
  test('cannot create it already claimed or with extra fields', async () => {
    await seedCode();
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter', 'ABC234', { claimed: true })));
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter', 'ABC234', { points: 9999 })));
    await assertFails(setDoc(doc(as('friend'), 'referrals/friend'), referral('inviter', 'ABC234', { createdAt: Timestamp.fromDate(new Date(0)) })));
  });
  test('the signed-out cannot redeem', async () => {
    await seedCode();
    await assertFails(setDoc(doc(anon(), 'referrals/friend'), referral('inviter')));
  });

  const seedReferral = () => seed(async (db) => {
    await setDoc(doc(db, 'invite_codes/ABC234'), { ownerUid: 'inviter' });
    await setDoc(doc(db, 'referrals/friend'), { referrerUid: 'inviter', code: 'ABC234', claimed: false, createdAt: Timestamp.now() });
  });

  test('inviter and invitee can read it, strangers cannot', async () => {
    await seedReferral();
    await assertSucceeds(getDoc(doc(as('inviter'), 'referrals/friend')));
    await assertSucceeds(getDoc(doc(as('friend'), 'referrals/friend')));
    await assertFails(getDoc(doc(as('stranger'), 'referrals/friend')));
  });
  test('inviter can list their own pending referrals; a stranger cannot list someone else\'s', async () => {
    await seedReferral();
    const mine = query(collection(as('inviter'), 'referrals'), where('referrerUid', '==', 'inviter'), where('claimed', '==', false));
    await assertSucceeds(getDocs(mine));
    const theirs = query(collection(as('stranger'), 'referrals'), where('referrerUid', '==', 'inviter'));
    await assertFails(getDocs(theirs));
    await assertFails(getDocs(collection(as('stranger'), 'referrals')));
  });
  test('inviter claims once, only the claimed flag', async () => {
    await seedReferral();
    await assertFails(updateDoc(doc(as('inviter'), 'referrals/friend'), { claimed: true, code: 'AAAAAA' }));
    await assertFails(updateDoc(doc(as('inviter'), 'referrals/friend'), { referrerUid: 'friend', claimed: true }));
    await assertSucceeds(updateDoc(doc(as('inviter'), 'referrals/friend'), { claimed: true }));
    await assertFails(updateDoc(doc(as('inviter'), 'referrals/friend'), { claimed: true })); // already claimed
    await assertFails(updateDoc(doc(as('inviter'), 'referrals/friend'), { claimed: false }));
  });
  test('the invitee cannot claim for the inviter; only the invitee can delete the record', async () => {
    await seedReferral();
    await assertFails(updateDoc(doc(as('friend'), 'referrals/friend'), { claimed: true }));
    await assertFails(deleteDoc(doc(as('inviter'), 'referrals/friend')));
    await assertSucceeds(deleteDoc(doc(as('friend'), 'referrals/friend'))); // invitee, account deletion
  });
});
