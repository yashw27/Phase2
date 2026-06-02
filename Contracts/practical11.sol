// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Delete array item
CONCEPT: Sparse array behavior
=========================================================

OBJECTIVE

- Learn how delete works on arrays
- Understand sparse array creation
- Learn why delete does not shrink arrays
- Understand risks caused by empty slots

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Using:

delete array[index];

DOES NOT:
- remove index
- shift elements
- reduce array length

It ONLY resets value to default.

---------------------------------------------------------
EXAMPLE
---------------------------------------------------------

Before delete:

[5, 10, 15]

After:
delete numbers[1];

Result:

[5, 0, 15]

Length still = 3

---------------------------------------------------------
DEFAULT VALUES
---------------------------------------------------------

uint256 => 0
bool => false
address => address(0)

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can sparse arrays break logic?
- Are deleted entries handled safely?
- Does protocol incorrectly count empty slots?
- Can attackers abuse gaps?
- Is array cleanup implemented correctly?

=========================================================
*/

contract SparseArrayBehaviorvul {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function deleteItem(uint256 _index) public {
        delete numbers[_index];
    }

    function getArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

numbers = []

---------------------------------------------------------

CALL:
addNumber(5)
addNumber(10)
addNumber(15)

ARRAY:

[5,10,15]

length = 3

---------------------------------------------------------

CALL:
deleteItem(1)

EVM ACTIONS:

1. EVM locates numbers[1]
2. Storage slot reset to default value
3. numbers[1] becomes 0

---------------------------------------------------------

FINAL ARRAY

[5,0,15]

IMPORTANT:
Length remains 3

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
addNumber(5)

---------------------------------------------------------

STEP 3:
Call:
addNumber(10)

---------------------------------------------------------

STEP 4:
Call:
addNumber(15)

---------------------------------------------------------

STEP 5:
Call:
getArray()

EXPECTED:
[5,10,15]

---------------------------------------------------------

STEP 6:
Call:
deleteItem(1)

---------------------------------------------------------

STEP 7:
Call:
getArray()

EXPECTED:
[5,0,15]

---------------------------------------------------------

STEP 8:
Call:
getLength()

EXPECTED:
3

OBSERVE:
Array size did not shrink.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Delete first element

deleteItem(0)

EXPECTED:
First value becomes 0

---------------------------------------------------------

TEST:
Delete last element

deleteItem(2)

EXPECTED:
Last value becomes 0

---------------------------------------------------------

TEST:
Delete invalid index

deleteItem(999)

EXPECTED:
Transaction reverts

Reason:
Index out of bounds

---------------------------------------------------------

TEST:
Delete same index twice

EXPECTED:
No error

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

ARRAY STORAGE

Arrays store values sequentially.

Example:

slot0 => array length
slot1 => numbers[0]
slot2 => numbers[1]
slot3 => numbers[2]

---------------------------------------------------------

DELETE OPERATION

delete numbers[1];

ONLY resets value.

Storage layout remains same.

---------------------------------------------------------

IMPORTANT

delete does NOT:
- remove slot
- shift values
- reduce length

=========================================================
DELETE VS POP
=========================================================

---------------------------------------------------------
DELETE
---------------------------------------------------------

delete numbers[1];

Result:
[5,0,15]

length = 3

---------------------------------------------------------
POP
---------------------------------------------------------

numbers.pop();

Result:
[5,10]

length = 2

---------------------------------------------------------

pop() only removes LAST element.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. SPARSE ARRAY BUGS
---------------------------------------------------------

Sparse arrays may break:
- reward systems
- counting logic
- voting mechanisms
- iteration assumptions

---------------------------------------------------------
2. LOOP RISKS
---------------------------------------------------------

Loops may incorrectly process:
0 values as valid entries.

---------------------------------------------------------
3. STORAGE FRAGMENTATION
---------------------------------------------------------

Repeated delete operations create:
- fragmented storage
- inefficient arrays
- wasted gas

---------------------------------------------------------
4. BUSINESS LOGIC FAILURES
---------------------------------------------------------

If 0 is meaningful,
deleted entries may bypass validations.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose array stores active stakers.

Attacker deletes entries repeatedly.

Result:
- empty gaps created
- reward logic breaks
- participant counting fails

---------------------------------------------------------

REAL-WORLD ISSUE

Sparse arrays have caused:
- governance bugs
- staking calculation errors
- incorrect payout distribution

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Item is removed completely
2. Elements shift left
3. Array length decreases

Example:

Before:
[5,10,15]

Remove index 1

After:
[5,15]

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- delete resets value to default
- delete does NOT remove array index
- delete does NOT reduce length
- Sparse arrays contain gaps
- Arrays remain sequential in storage
- pop() differs from delete
- Sparse arrays may break protocol logic
- Invalid indexes revert
- Auditors inspect cleanup logic carefully
- Storage fragmentation affects efficiency

=========================================================
*/

// patch code



contract DynamicArrayRemoval {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function removeItem(uint256 _index) public {
        require(_index < numbers.length, "Invalid index");

        // Shift elements left
        for (uint256 i = _index; i < numbers.length - 1; i++) {
            numbers[i] = numbers[i + 1];
        }

        // Remove last duplicate element
        numbers.pop();
    }

    function getArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}


/*
Audit Report

Title: Improper Array Element Deletion Causes Sparse Array

Severity: Low

Reason: Deleted elements remain in the array as default values, causing unexpected behavior and data inconsistency.

Location:

Contract: SparseArrayBehavior
Function: deleteItem()

Vulnerability Description:

The `deleteItem()` function uses the Solidity `delete` keyword on an array element:

```solidity
delete numbers[_index];
```

When applied to a dynamic array element, `delete` does not remove the element from the array. Instead, it resets the element to its default value (`0` for `uint256`) while preserving the array length.

As a result, the array becomes sparse and contains empty slots that may be interpreted as valid data by other parts of the protocol.

Impact:

An attacker or user can create arrays containing unintended zero values.

Potential consequences include:

* Incorrect array processing
* Data inconsistency
* Unexpected application behavior
* Incorrect calculations when iterating through the array
* Frontend display issues

Example:

Before deletion:

```solidity
[5, 10, 15]
```

Call:

```solidity
deleteItem(1);
```

After deletion:

```solidity
[5, 0, 15]
```

Array length:

```solidity
3
```

The element is not actually removed.

Proof of Concept:

Deploy the contract.

Add values:

```solidity
addNumber(5);
addNumber(10);
addNumber(15);
```

Current array:

```solidity
[5, 10, 15]
```

Call:

```solidity
deleteItem(1);
```

Result:

```solidity
[5, 0, 15]
```

Check length:

```solidity
getLength();
```

Returns:

```solidity
3
```

The array length remains unchanged and the deleted element is replaced with `0`.

Root Cause:

The Solidity `delete` keyword resets the value at a specific index but does not:

* Shift remaining elements
* Remove the array slot
* Reduce array length

The implementation assumes that `delete` removes the element entirely, which is incorrect for dynamic arrays.

Recommendation:

Shift all elements after the deleted index one position to the left and remove the final duplicated element using `pop()`.

Patched Code:
*/


contract DynamicArrayRemovalv {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function removeItem(uint256 _index) public {
        require(_index < numbers.length, "Invalid index");

        for (uint256 i = _index; i < numbers.length - 1; i++) {
            numbers[i] = numbers[i + 1];
        }

        numbers.pop();
    }

    function getArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}

