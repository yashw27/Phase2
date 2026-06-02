// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use storage reference variable
CONCEPT: Direct storage pointer
=========================================================

OBJECTIVE

- Learn how storage reference variables work
- Understand direct pointers to storage
- Learn difference between storage and memory
- Understand how modifying storage references
  directly changes blockchain state

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

A storage reference variable points directly
to an existing storage location.

Example:

User storage user = users[id];

This does NOT create copy.

Instead:
user becomes POINTER to storage.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Modifying storage reference:

user.age = 50;

directly updates blockchain storage.

---------------------------------------------------------
STORAGE VS MEMORY
---------------------------------------------------------

STORAGE:
- permanent
- expensive
- modifies blockchain state
- acts like pointer/reference

MEMORY:
- temporary copy
- disappears after execution
- modifying memory does NOT update storage

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Storage references are heavily used in:

- DeFi protocols
- staking systems
- NFT marketplaces
- governance contracts
- user profile systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Are storage references intentional?
- Is accidental mutation possible?
- Are references pointing correctly?
- Is storage corruption possible?
- Is memory/storage confusion present?

=========================================================
*/

contract StorageReferencevul {

    struct User {

        uint256 age;

        bool active;
    }

    mapping(address => User) public users;

    function createUser(uint256 _age) public {

        users[msg.sender] = User(_age, true);
    }

    function updateAge(uint256 _newAge) public {

        /*
            STORAGE REFERENCE VARIABLE

            This creates POINTER to actual storage.

            user is NOT copy.

            user directly references:
            users[msg.sender]
        */
        User storage user = users[msg.sender];

        /*
            DIRECT STORAGE MUTATION

            Since user points to storage,
            this updates blockchain state directly.
        */
        user.age = _newAge;
    }

    function deactivateUser() public {

        /*
            Another storage reference example
        */
        User storage user = users[msg.sender];

        user.active = false;
    }

    function getMyData()
        public
        view
        returns (uint256, bool)
    {
        User storage user = users[msg.sender];

        return (user.age, user.active);
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

users[msg.sender]:

age = 0
active = false

---------------------------------------------------------

CALL:
createUser(25)

RESULT:

users[msg.sender]:
age = 25
active = true

---------------------------------------------------------

CALL:
updateAge(40)

EVM ACTIONS:

1. Mapping storage slot located
2. Storage reference created
3. user points directly to storage
4. user.age updated
5. Blockchain state mutated

---------------------------------------------------------

FINAL STATE

users[msg.sender]:
age = 40
active = true

---------------------------------------------------------

IMPORTANT

No copy created.

Storage reference directly modifies storage.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createUser(25)

---------------------------------------------------------

STEP 3:
Call:
getMyData()

EXPECTED:
25, true

---------------------------------------------------------

STEP 4:
Call:
updateAge(99)

---------------------------------------------------------

STEP 5:
Call:
getMyData()

EXPECTED:
99, true

OBSERVE:
Storage updated permanently.

---------------------------------------------------------

STEP 6:
Call:
deactivateUser()

EXPECTED:
99, false

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Update before createUser()

EXPECTED:
Works on default struct values

---------------------------------------------------------

TEST:
Repeated updates

EXPECTED:
Latest storage state persists

---------------------------------------------------------

TEST:
Different Remix accounts

EXPECTED:
Each address has isolated struct storage

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

THIS LINE:

User storage user = users[msg.sender];

creates STORAGE POINTER.

---------------------------------------------------------

VERY IMPORTANT

This is NOT copy:

User memory user = users[msg.sender];

would create temporary copy instead.

---------------------------------------------------------

STORAGE REFERENCE

Changes affect blockchain storage immediately.

---------------------------------------------------------

MEMORY COPY

Changes affect temporary copy only.

=========================================================
STORAGE VS MEMORY EXAMPLE
=========================================================

---------------------------------------------------------
STORAGE
---------------------------------------------------------

User storage user = users[msg.sender];

user.age = 50;

RESULT:
Blockchain storage updated.

---------------------------------------------------------
MEMORY
---------------------------------------------------------

User memory user = users[msg.sender];

user.age = 50;

RESULT:
Only temporary copy changes.

Original storage unchanged.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. ACCIDENTAL STORAGE MUTATION
---------------------------------------------------------

Developers may accidentally modify
real storage when expecting copy.

This causes unintended state changes.

---------------------------------------------------------
2. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Very common Solidity bug source.

Auditors carefully inspect:
- reference types
- assignment behavior
- mutation side effects

---------------------------------------------------------
3. UNEXPECTED SIDE EFFECTS
---------------------------------------------------------

Changing storage references may:
- alter protocol state unexpectedly
- corrupt accounting
- bypass assumptions

---------------------------------------------------------
4. GAS CONSIDERATIONS
---------------------------------------------------------

Storage writes are expensive.

Unnecessary mutations waste gas.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Improper storage references may allow:
- accidental balance updates
- corrupted staking records
- unintended ownership changes

---------------------------------------------------------

REAL-WORLD RISK

Many Solidity bugs happen because:
developers expect copy
but receive storage reference instead.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add function using MEMORY copy
2. Change memory values
3. Observe storage remains unchanged

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- storage creates direct reference/pointer
- Storage references mutate blockchain state
- memory creates temporary copy
- Storage persists permanently
- Storage writes consume gas
- Reference types behave differently
- Memory/storage confusion causes bugs
- Structs inside mappings commonly use storage refs
- Storage references can create side effects
- Auditors inspect pointer behavior carefully

=========================================================
*/

// patch code 


contract UserManager {
    struct User {
        uint256 age;
        bool active;
    }

    mapping(address => User) public users;

    function createUser(uint256 _age) public {
        users[msg.sender] = User(_age, true);
    }

    function deactivateUser() public {
        User storage user = users[msg.sender];
        user.active = false;
    }

    function getMyData()
        public
        view
        returns (uint256, bool)
    {
        User storage user = users[msg.sender];
        return (user.age, user.active);
    }

    // NEW FUNCTION: Demonstrates memory copy
    function testMemoryCopy()
        public
        view
        returns (
            uint256 memoryAge,
            bool memoryActive,
            uint256 storageAge,
            bool storageActive
        )
    {
        // Copy from storage to memory
        User memory userCopy = users[msg.sender];

        // Modify memory copy
        userCopy.age = 999;
        userCopy.active = false;

        // Original storage remains unchanged
        User storage original = users[msg.sender];

        return (
            userCopy.age,
            userCopy.active,
            original.age,
            original.active
        );
    }
}


/*
Audit Report
Title:

Users Can Overwrite Existing Profiles Without Validation

Severity:

Low

Reason:

Existing user data can be overwritten unintentionally because no validation is performed before creating a user.

Location:

Contract: UserManager
Function: createUser(uint256 _age)

Vulnerability Description:

The createUser() function allows any user to create a profile. However, the function does not check whether a profile already exists for the caller.

As a result, a user can repeatedly call createUser() and overwrite their previously stored data.

function createUser(uint256 _age) public {
    users[msg.sender] = User(_age, true);
}

Each call replaces the existing User struct associated with the caller's address.

Impact:

A user may accidentally overwrite their own profile data.

Potential consequences include:

Loss of previously stored age information.
Reactivation of a previously deactivated account.
Unexpected state changes in systems that rely on profile immutability.

While users can only affect their own records, this behavior may violate intended business logic.

Proof of Concept:
User creates a profile:
createUser(25);

Storage:

users[msg.sender] = {
    age: 25,
    active: true
}
User deactivates profile:
deactivateUser();

Storage:

users[msg.sender] = {
    age: 25,
    active: false
}
User calls:
createUser(99);

Storage becomes:

users[msg.sender] = {
    age: 99,
    active: true
}

The previous profile state is completely overwritten.

Root Cause:

The function lacks a check to determine whether the caller already has a registered profile.

No validation exists such as:

require(users[msg.sender].age == 0, "User already exists");

before assigning a new struct.

Recommendation:

Prevent profile recreation if a profile already exists.

Example:

require(users[msg.sender].age == 0, "User already exists");

Alternatively, create a dedicated update function for modifying user information.

Patched Code:
*/
contract UserManagerv {
    struct User {
        uint256 age;
        bool active;
    }

    mapping(address => User) public users;

    function createUser(uint256 _age) public {
        require(users[msg.sender].age == 0, "User already exists");

        users[msg.sender] = User({
            age: _age,
            active: true
        });
    }

    function deactivateUser() public {
        users[msg.sender].active = false;
    }

    function getMyData()
        public
        view
        returns (uint256, bool)
    {
        User storage user = users[msg.sender];
        return (user.age, user.active);
    }
}