// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Return large memory array
CONCEPT: Memory allocation
=========================================================

OBJECTIVE

- Learn how large memory arrays are allocated
- Understand memory expansion costs
- Learn how returning large arrays affects gas
- Understand scalability risks in Solidity

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory arrays are allocated dynamically
during execution.

Larger arrays:
- require more memory
- consume more gas
- increase execution cost

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Returning large arrays can become expensive.

Reason:
EVM must:
- allocate memory
- store elements
- encode return data

---------------------------------------------------------
REAL-WORLD IMPORTANCE
---------------------------------------------------------

Large memory operations affect:

- scalability
- gas efficiency
- DOS resistance
- protocol usability

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Large arrays appear in:

- DeFi protocols
- NFT collections
- staking systems
- governance snapshots
- batch operations

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can arrays grow unbounded?
- Can functions become uncallable?
- Is gas exhaustion possible?
- Are loops scalable?
- Is pagination needed?

=========================================================
*/

contract LargeMemoryArrayvul {

    /*
        STORAGE ARRAY

        Persists permanently.
    */
    uint256[] public storedValues;

    function addValues(uint256 _count) public {

        /*
            Add values into storage array.

            WARNING:
            Large loops increase gas usage.
        */
        for (uint256 i = 0; i < _count; i++) {

            storedValues.push(i);
        }
    }

    function returnLargeArray(uint256 _size)
        public
        pure
        returns (uint256[] memory)
    {

        /*
            CREATE LARGE MEMORY ARRAY

            Memory allocated dynamically.
        */
        uint256[] memory tempArray =
            new uint256[](_size);

        /*
            Fill memory array
        */
        for (uint256 i = 0; i < _size; i++) {

            tempArray[i] = i + 1;
        }

        /*
            Entire array returned.

            Larger arrays:
            higher gas cost.
        */
        return tempArray;
    }

    function copyStorageToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            FULL STORAGE -> MEMORY COPY

            Dangerous if storage array becomes huge.
        */
        return storedValues;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
returnLargeArray(5)

EVM ACTIONS:

1. Allocate memory for 5 elements
2. Create temporary array
3. Fill array using loop
4. Encode return data
5. Return memory array
6. Memory cleared after execution

---------------------------------------------------------

RETURNED ARRAY:

[1,2,3,4,5]

=========================================================

CALL:
returnLargeArray(1000)

OBSERVE:

- more memory allocation
- more loop iterations
- higher gas consumption
- larger return data

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
returnLargeArray(5)

EXPECTED:
[1,2,3,4,5]

---------------------------------------------------------

STEP 3:
Call:
returnLargeArray(50)

OBSERVE:
Higher execution cost

---------------------------------------------------------

STEP 4:
Call:
returnLargeArray(500)

OBSERVE:
Even higher gas usage

---------------------------------------------------------

STEP 5:
Call:
addValues(20)

---------------------------------------------------------

STEP 6:
Call:
copyStorageToMemory()

EXPECTED:
Returns all stored values

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
_size = 0

EXPECTED:
Empty array returned

---------------------------------------------------------

TEST:
Very large _size

OBSERVE:
Possible:
- high gas cost
- out-of-gas errors

---------------------------------------------------------

TEST:
Huge storage array copy

OBSERVE:
Function may become expensive/unusable

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS LINE:

new uint256[](_size)

---------------------------------------------------------

ALLOCATES:
dynamic memory space.

---------------------------------------------------------

LARGER ARRAYS:
require more EVM memory expansion.

---------------------------------------------------------

VERY IMPORTANT

Memory is temporary:
cleared after execution.

=========================================================
MEMORY EXPANSION COST
=========================================================

EVM charges gas for:
- allocating memory
- expanding memory
- writing values
- encoding return data

---------------------------------------------------------

LARGE ARRAYS:
grow gas costs rapidly.

=========================================================
RETURN DATA COST
=========================================================

Returning large arrays also costs gas.

Reason:
EVM must ABI-encode:
every array element.

=========================================================
SCALABILITY RISK
=========================================================

UNBOUNDED ARRAYS ARE DANGEROUS.

Functions may become:
- too expensive
- uncallable
- DOS vulnerable

=========================================================
GAS OBSERVATION
=========================================================

SMALL ARRAY:
Cheap

---------------------------------------------------------

LARGE ARRAY:
Expensive

---------------------------------------------------------

VERY LARGE ARRAY:
Possible out-of-gas failure

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. DOS VIA GAS EXHAUSTION
---------------------------------------------------------

Huge arrays may:
- exceed block gas limit
- make function unusable

---------------------------------------------------------
2. UNBOUNDED LOOPS
---------------------------------------------------------

Loops over attacker-controlled size
are dangerous.

---------------------------------------------------------
3. STORAGE-TO-MEMORY COPYING
---------------------------------------------------------

Copying massive storage arrays
can break scalability.

---------------------------------------------------------
4. PAGINATION REQUIREMENT
---------------------------------------------------------

Auditors often recommend:
pagination instead of returning everything.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker grows storage array massively.

Then calls:
copyStorageToMemory()

Result:
- excessive gas usage
- DOS condition
- function unusable

---------------------------------------------------------

REAL-WORLD ISSUE

Many protocols became uncallable
because arrays grew too large.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add pagination support
2. Return only partial array range
3. Avoid returning entire huge array

BONUS:
Implement:
(start, limit) logic

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory arrays allocate temporary memory
- Large arrays increase gas consumption
- Memory expansion costs gas
- Returning arrays requires ABI encoding
- Large return data becomes expensive
- Unbounded loops create scalability risks
- Storage-to-memory copying can be dangerous
- DOS via gas exhaustion is common
- Pagination improves scalability
- Auditors inspect array growth carefully

=========================================================
*/


contract LargeMemoryArray {

    uint256[] public storedValues;

    function addValues(uint256 _count) public {
        for (uint256 i = 0; i < _count; i++) {
            storedValues.push(i);
        }
    }

    function getValuesPaginated(
        uint256 start,
        uint256 limit
    )
        public
        view
        returns (uint256[] memory)
    {
        if (start >= storedValues.length) {
            return new uint256[](0);
        }

        uint256 end = start + limit;

        if (end > storedValues.length) {
            end = storedValues.length;
        }

        uint256[] memory result =
            new uint256[](end - start);

        for (uint256 i = 0; i < end - start; i++) {
            result[i] = storedValues[start + i];
        }

        return result;
    }

    function totalValues()
        public
        view
        returns (uint256)
    {
        return storedValues.length;
    }
}


/*
Audit Report

Title: Unbounded Array Copy May Cause Gas Exhaustion and Denial of Service

Severity: Medium

Reason:
Returning an entire storage array without pagination can lead to excessive memory allocation and gas consumption as the array grows.

Location:

Contract: LargeMemoryArray

Function: copyStorageToMemory()

Vulnerability Description:
The copyStorageToMemory() function returns the entire storedValues storage array.

```solidity
function copyStorageToMemory()
    public
    view
    returns (uint256[] memory)
{
    return storedValues;
}
```

When Solidity returns a storage array, the entire array must first be copied from storage into memory. As the array grows, the memory allocation and copy operation become increasingly expensive.

Because the addValues() function allows arbitrary growth of the storedValues array, the array may eventually become too large to return efficiently.

Impact:
An attacker or legitimate user can continuously increase the size of storedValues by calling addValues().

Consequences may include:

* Excessive gas consumption during view calls.
* Increased RPC response size.
* Frontend performance degradation.
* Failure of integrations attempting to retrieve the entire array.
* Potential denial of service for applications relying on the function.

Proof of Concept:

1. Deploy the contract.

2. Populate the storage array:

```solidity
addValues(100000);
```

3. Call:

```solidity
copyStorageToMemory();
```

4. Observe:

* Large memory allocation.
* Large response payload.
* Potential RPC timeout or execution failure for sufficiently large arrays.

Root Cause:
The function performs an unbounded storage-to-memory copy.

No pagination or range limitation exists to restrict the amount of data returned in a single call.

Recommendation:
Implement pagination using start and limit parameters so that callers retrieve only a subset of the array.

Example:

```solidity
function getValuesPaginated(
    uint256 start,
    uint256 limit
)
    public
    view
    returns (uint256[] memory)
{
    // return only requested range
}
```

Patched Code:

*/

contract LargeMemoryArrayv {

    uint256[] public storedValues;

    function addValues(uint256 _count) public {
        for (uint256 i = 0; i < _count; i++) {
            storedValues.push(i);
        }
    }

    function getValuesPaginated(
        uint256 start,
        uint256 limit
    )
        public
        view
        returns (uint256[] memory)
    {
        if (start >= storedValues.length) {
            return new uint256[](0);
        }

        uint256 end = start + limit;

        if (end > storedValues.length) {
            end = storedValues.length;
        }

        uint256[] memory result =
            new uint256[](end - start);

        for (uint256 i = 0; i < end - start; i++) {
            result[i] = storedValues[start + i];
        }

        return result;
    }

    function totalValues()
        public
        view
        returns (uint256)
    {
        return storedValues.length;
    }
}
