// Identifiers for agents. Don't worry about actual keys.
#define ALICE 0
#define BOB 1
#define EVE 2

// use constant for clarity
#define UNUSED 0

// a cyphertext message: contains a source, two ints of data and also whose key it's encrypted with.
// Note that source and key are not necessarily the same.
typedef cyphertext {
  int from; // ALICE, BOB or EVE
  int whoseKey;  // ALICE, BOB or EVE
  int part1;
  int part2;
};

// One channel for each agent. Message to agent N goes in channel N
// size 0 channel cannot store; must transfer synchronously
chan messages[3] = [0] of {cyphertext};

int nonceA = 0;
int nonceB = 0;
bool eveKnowsANonce = false;
bool eveKnowsBNonce = false;

// Hint: these "done" flags are useful for stating properties.
bool aliceDone = false;
bool bobDone = false;

///////////////////////////////////////////////////////////////////////////////
// Alice initiates a connection...
///////////////////////////////////////////////////////////////////////////////

active proctype Alice () {
  int partner;

  // Partner selection: Alice can try to contact either Eve or Bob  
  select(partner : 1 .. 2); // Alice's target agent
  select(nonceA : 1 .. 10); // Alice's secret (> 0, which is initial val)
  printf("Alice starting. Partner=%d, Nonce=%d\n",partner, nonceA);

  // Step 1: transmit: <identity, nonce> to partner, encrypted with partner's key
  messages[partner]!ALICE,partner,ALICE,nonceA; // src=ALICE, key=partner, data1=ALICE, data2=nonceA
  printf("Alice sent step 1\n");

  // Step 2: receive reply encrypted with ALICE's public key
  // Note: when reading with ?, eval(d) matches a value; d writes into that value.
  int receivedNonceB;
  messages[ALICE]?eval(partner),ALICE,eval(nonceA),receivedNonceB; // receive when src=partner, key=ALICE and data1=nonceA
  printf("Alice received step 2\n");

  // Step 3: send final ack
  messages[partner]!ALICE,partner,receivedNonceB,UNUSED;
  printf("Alice sent step 3; nonces: %d, %d\n", nonceA, receivedNonceB);

  aliceDone = true;
}

///////////////////////////////////////////////////////////////////////////////
// Bob listens for a connection...
///////////////////////////////////////////////////////////////////////////////

active proctype Bob () {
  select(nonceB : 11 .. 20); // Bob's secret (Different from Alice's, for ease in debugging) 
  printf("Bob starting. Nonce=%d\n",nonceB);

  // Step 1: wait for connection
  // Partner is not necessarily src.
  int src, partner, receivedNonceA;
  messages[BOB]?src,BOB,partner,receivedNonceA;
  printf("Bob received step 1 (src=%d, partner=%d)\n",src,partner);

  // Step 2: send reply (back to src, encrypted with partner's key)
  messages[src]!BOB,partner,receivedNonceA,nonceB;
  printf("Bob sent step 2\n");

  // Step 3: await final ack (again, needn't be from partner)
  messages[BOB]?src,BOB,eval(nonceB),_;
  printf("Bob received step 3; nonces: %d, %d\n", receivedNonceA, nonceB);

  bobDone = true;
}

///////////////////////////////////////////////////////////////////////////////
// Eve attempts to attack the protocol...
///////////////////////////////////////////////////////////////////////////////

active proctype Eve () {
  int src, partner, receivedNonceA;
  do
  :: messages[EVE]?_,EVE,_,_; // _ is a placeholder, matches anything but doesn't record the value
     printf("Eve received a message but isn't implemented yet!\n");
  od;
}
