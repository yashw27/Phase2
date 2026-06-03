// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use memory struct
CONCEPT: Temporary structs
=========================================================

OBJECTIVE

- Learn how memory structs work
- Understand temporary struct allocation
- Learn difference between memory structs and storage structs
- Understand temporary object lifecycle

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory structs:
- exist temporarily
- live only during execution
- disappear after function ends

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Memory structs do NOT persist
on blockchain storage.

They are useful for:
- temporary calculations
- data transformation
- returning grouped data
- processing information safely

---------------------------------------------------------
MEMORY STRUCT VS STORAGE STRUCT
---------------------------------------------------------

MEMORY STRUCT:
- temporary
- isolated copy
- cheaper
- disappears after execution

STORAGE STRUCT:
- permanent
- stored on blockchain
- expensive
- persists forever

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory structs used in:

- temporary user objects
- order processing
- calculations
- validation logic
- returned API-style responses

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is struct temporary or persistent?
- Is developer expecting storage mutation?
- Are copies handled safely?
- Are references intentional?
- Can large structs waste gas?

=========================================================
*/

contract MemoryStructExamplevul {

    /*
        STRUCT DEFINITION

        Groups related data together.
    */
    struct User {

        string name;

        uint256 age;

        bool active;
    }

    /*
        STORAGE STRUCT

        Stored permanently on blockchain.
    */
    User public storedUser;

    function createMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            MEMORY STRUCT CREATION

            Temporary struct allocated in memory.
        */
        User memory tempUser = User({

            name: "Alice",

            age: 25,

            active: true
        });

        /*
            tempUser exists only during execution.
        */
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function createAndModifyMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            Temporary memory struct
        */
        User memory tempUser = User({

            name: "Bob",

            age: 30,

            active: true
        });

        /*
            MODIFY MEMORY STRUCT

            Changes affect only temporary copy.
        */
        tempUser.age = 99;

        tempUser.active = false;

        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function storeUser() public {

        /*
            STORAGE MUTATION

            This persists permanently.
        */
        storedUser = User({

            name: "Charlie",

            age: 40,

            active: true
        });
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createMemoryStruct()

EVM ACTIONS:

1. Temporary memory allocated
2. Struct created in memory
3. Values assigned
4. Data returned
5. Memory cleared after execution

---------------------------------------------------------

IMPORTANT

tempUser does NOT persist permanently.

---------------------------------------------------------

CALL:
createAndModifyMemoryStruct()

INITIAL MEMORY STRUCT:

{
    name: "Bob",
    age: 30,
    active: true
}

---------------------------------------------------------

AFTER MODIFICATION:

{
    name: "Bob",
    age: 99,
    active: false
}

---------------------------------------------------------

AFTER FUNCTION ENDS:
Memory struct destroyed.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createMemoryStruct()

EXPECTED:
"Alice", 25, true

---------------------------------------------------------

STEP 3:
Call:
createAndModifyMemoryStruct()

EXPECTED:
"Bob", 99, false

---------------------------------------------------------

STEP 4:
Call:
storedUser()

EXPECTED:
Empty/default values

OBSERVE:
Memory structs did NOT persist.

---------------------------------------------------------

STEP 5:
Call:
storeUser()

---------------------------------------------------------

STEP 6:
Call:
storedUser()

EXPECTED:
"Charlie", 40, true

OBSERVE:
Storage struct persists permanently.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Modify memory struct repeatedly

EXPECTED:
Fresh struct created each execution

---------------------------------------------------------

TEST:
Use empty strings

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Large struct data

OBSERVE:
More memory allocation
= higher gas usage

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS CREATES MEMORY STRUCT:

User memory tempUser

---------------------------------------------------------

STRUCT EXISTS ONLY:
during function execution.

---------------------------------------------------------

AFTER EXECUTION:
Memory cleared automatically.

---------------------------------------------------------

VERY IMPORTANT

Memory structs:
do NOT persist on blockchain.

=========================================================
MEMORY STRUCT MUTABILITY
=========================================================

MEMORY STRUCTS ARE MUTABLE

Example:

tempUser.age = 99;

---------------------------------------------------------

HOWEVER:
Changes remain temporary only.

=========================================================
MEMORY VS STORAGE STRUCT
=========================================================

---------------------------------------------------------
MEMORY STRUCT
---------------------------------------------------------

Temporary

Cheap

Destroyed after execution

---------------------------------------------------------
STORAGE STRUCT
---------------------------------------------------------

Permanent

Expensive

Stored on blockchain forever

=========================================================
GAS OBSERVATION
=========================================================

MEMORY STRUCTS:
Cheaper than storage

---------------------------------------------------------

LARGE STRUCTS:
Still increase memory cost

---------------------------------------------------------

STORAGE WRITES:
Most expensive operations

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may think:
memory modifications persist.

They do NOT.

---------------------------------------------------------
2. COPY ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether struct is:
- temporary copy
OR
- storage reference

---------------------------------------------------------
3. LARGE MEMORY STRUCTS
---------------------------------------------------------

Huge structs may:
- waste gas
- increase execution cost

---------------------------------------------------------
4. SILENT LOGIC FAILURES
---------------------------------------------------------

Protocol may expect:
storage mutation

but only memory updated.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer modifies memory struct
expecting permanent update.

Critical state never changes.

Possible impact:
- broken access control
- failed accounting
- incorrect balances

---------------------------------------------------------

ANOTHER RISK

Attacker supplies huge struct data.

Result:
high gas consumption.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Copy storage struct into memory
2. Modify memory copy
3. Show storage remains unchanged

BONUS:
Compare:
memory struct vs storage struct behavior

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory structs are temporary
- Memory structs disappear after execution
- Memory structs are mutable
- Storage structs persist permanently
- Memory changes do not affect storage
- Memory cheaper than storage
- Large structs increase gas usage
- Copy/reference confusion causes bugs
- Structs group related data together
- Auditors inspect struct semantics carefully

=========================================================
*/

contract MemoryStructExample {

    struct User {
        string name;
        uint256 age;
        bool active;
    }

    User public storedUser;

    function storeUser() public {
        storedUser = User({
            name: "Charlie",
            age: 40,
            active: true
        });
    }

    function modifyMemoryCopy()
        public
        view
        returns (
            string memory memoryName,
            uint256 memoryAge,
            bool memoryActive,
            string memory storageName,
            uint256 storageAge,
            bool storageActive
        )
    {
        /*
            STORAGE -> MEMORY COPY
        */
        User memory tempUser = storedUser;

        /*
            MODIFY MEMORY COPY ONLY
        */
        tempUser.age = 99;
        tempUser.active = false;

        /*
            RETURN BOTH STRUCTS
        */
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active,
            storedUser.name,
            storedUser.age,
            storedUser.active
        );
    }
}


/*
Audit Report
Title:

Memory Struct Copy Does Not Modify Original Storage Struct

Severity:

Informational

Reason:

When a storage struct is copied into memory, Solidity creates an independent temporary copy. Modifications to the memory struct do not affect the original storage struct.

Location

Contract: MemoryStructExample
Function: modifyMemoryCopy()

Vulnerability Description

The modified function copies a storage struct into memory and then modifies the memory copy.

Example:

function modifyMemoryCopy()
    public
    view
    returns (
        string memory memoryName,
        uint256 memoryAge,
        bool memoryActive,
        string memory storageName,
        uint256 storageAge,
        bool storageActive
    )
{
    User memory tempUser = storedUser;

    tempUser.age = 99;
    tempUser.active = false;

    return (
        tempUser.name,
        tempUser.age,
        tempUser.active,
        storedUser.name,
        storedUser.age,
        storedUser.active
    );
}

The memory struct is completely separate from the storage struct.

Any changes made to tempUser affect only the temporary memory copy.

Impact

No security impact.

However, developers unfamiliar with Solidity's data locations may incorrectly assume that modifying the memory copy updates the original storage struct.

Potential consequences:

Business logic errors.
Incorrect assumptions about state updates.
Confusion during testing and debugging.
Proof of Concept
Step 1: Store User
storeUser();

Storage state:

storedUser = {
    name: "Charlie",
    age: 40,
    active: true
}
Step 2: Create Memory Copy
User memory tempUser = storedUser;

Memory state:

tempUser = {
    name: "Charlie",
    age: 40,
    active: true
}
Step 3: Modify Memory Copy
tempUser.age = 99;
tempUser.active = false;

Memory state:

tempUser = {
    name: "Charlie",
    age: 99,
    active: false
}

Storage remains:

storedUser = {
    name: "Charlie",
    age: 40,
    active: true
}
Root Cause

The following statement creates a memory copy:

User memory tempUser = storedUser;

This operation copies all struct fields into temporary memory.

Subsequent modifications affect only the copied struct.

Recommendation

Use memory structs when:

Temporary calculations are required.
Data transformations are needed.
State updates are not intended.

Use storage references when:

Persistent modifications are desired.
Contract state should be updated.
Patched Code

*/


contract MemoryStructExamplev {

    struct User {
        string name;
        uint256 age;
        bool active;
    }

    User public storedUser;

    function storeUser() public {
        storedUser = User({
            name: "Charlie",
            age: 40,
            active: true
        });
    }

    function modifyMemoryCopy()
        public
        view
        returns (
            string memory memoryName,
            uint256 memoryAge,
            bool memoryActive,
            string memory storageName,
            uint256 storageAge,
            bool storageActive
        )
    {
        /*
            STORAGE -> MEMORY COPY
        */
        User memory tempUser = storedUser;

        /*
            MODIFY MEMORY COPY ONLY
        */
        tempUser.age = 99;
        tempUser.active = false;

        /*
            RETURN BOTH STRUCTS
        */
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active,
            storedUser.name,
            storedUser.age,
            storedUser.active
        );
    }
}