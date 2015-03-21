###Spin: Needham-Schroeder

The Needham-Schoeder public-key protocol allows two parties to establish a pair of 
nonces to be used as a session key for private communication between two parties.
  
The expected run of the protocol between Alice (A) and Bob (B) is:

    A                        B
    |     {NonceA, A}KB      |
    |   ----------------->   |
    |                        |
    |   {NonceA, NonceB}KA   |
    |   <-----------------   |
    |                        |
    |       {NonceB}KB       |
    |   ----------------->   |
    
  {...}KX indicates a message encrypted with the public key of X.

  Alice sends Bob her nonce for this session (nonce meaning "number used only once"),
  Bob responds with hers to confirm and his own, and Alice replies with his nonce to
  confirm she has received it. The messages are encrypted using the public key of the 
  intended recipient (KA/KB), and they can only be decrypted by that recipient.
  
  A run concludes correctly in the model below when aliceDone=true,
  bobDone=true and they have the same nonces.
  
  However, this protocol is not entirely secure and can be exploited by a third
  party to gain access to both nonces.
  
  The attack works as follows, where Eve (E) impersonates Alice:
  
    A                        E                       B
    |     {NonceA, A}KE      |    {NonceA, A}KB      |
    |   ----------------->   |  ----------------->   |
    |                        |                       |
    |   {NonceA, NonceB}KA   |  {NonceA, NonceB}KA   |
    |   <-----------------   |  <-----------------   |
    |                        |                       |
    |      {NonceB}KE        |      {NonceB}KB       |
    |   ----------------->   |  ----------------->   |
  
  
  Alice purposely communicates with Eve who then uses Alice's nonce to establish
  a connection with Bob, who might be a legitimate business such as Alice's bank.
  When Bob responds with the nonce pair Eve cannot read it because it is encrypted
  for Alice, so she forwards it to Alice who then helpfully replies, revealing Bob's nonce.
  
  You can tell this attack has occurred in the model if aliceDone=true, bobDone=true
  and all three parties know both nonces.
  
  *** Your assignment is to fill in the Eve process in ns.pml (including assert statements)
  so that Spin finds the above attack. ***
  
  The model's effectiveness depends on what we allow to happen in the
  model: we want it to be general enough to catch the problem.

  (1) If we assume that Alice will only ever talk to Bob, the error we saw in
  class can't happen. So we've got to give her enough flexibility from the start.

  (2) It's not realistic to hard-code the nature of the bug into Eve's process.
  The idea of modeling is to *find unexpected problems*, so we should model
  the various actions Eve can take, without prejudice to the specific actions
  that we saw work in class:

    - Eve can resend messages she receives.
    - Eve can learn from messages she receives (that are encrypted with her key).
    - Eve can construct new messages using what she's learned.

  DON'T worry about letting Eve eavesdrop on other people's channels. We'll
  assume that she can only see messages sent to her.

  DON'T worry about modeling Eve remembering things she learns; it's OK to
  have the learning and sending new messages happen without delay between
  them. (Do make use of the "eveKnowsXNonce" flags though, as they are useful
  in stating properties.)

  It's possible to do both of these things, but it complicates the model and
  it's beyond the scope of this homework.

  You do not need to write any ltl properties or use ./pan -a to do this
  assignment. Assertions in your Eve process should work fine.

  To use:
  
    spin -a <filename>
    gcc -o pan pan.c
    ./pan -E

  Make sure you use ./pan -E to check (not ./pan by itself)---
  without -E, the verifier will tell you about what it thinks are deadlocks.
  You can avoid this by using the "end:" tag, but that's out of scope.
  
  After that fails:
  
    ./pan -t <filename>  does a *guided simulation*, which will include all printfs in the buggy run.
    ./pan -t -p <filename>  shows you the above, plus every step through all processes
    

Hint: If you're where to start, try playing with the Alice/Bob processes and doing some simulation runs,
then incrementally add to Eve's abilities.
  
###Handin:
  To hand in your the project run __cs195y_handin spin__ from a directory containing 
  your program and a readme explaining any significant design decisions.
