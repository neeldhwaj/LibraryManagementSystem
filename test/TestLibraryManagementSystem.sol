pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LibraryManagementSystem.sol";

contract TestLibraryManagementSystem {
    LibraryManagementSystem lms;

    function beforeEach() {
        lms =  new LibraryManagementSystem('Neel');
    }

    function testConstructor() {
    LibraryManagementSystem lms = LibraryManagementSystem(DeployedAddresses.LibraryManagementSystem());
    Assert.equal(lms.totalNumMembers(), 1, "One Default Member - Owner");
    }

    function testDefaultNumBooks() {
        LibraryManagementSystem lms = LibraryManagementSystem(DeployedAddresses.LibraryManagementSystem());
        var bookCount = lms.getNumberOfBooks();
        Assert.equal(bookCount, 0, "Initially Zero books");
    }

    function testGetOwner() {
        // string nam = lms.getOwner();
        // Assert.equal(name, 'Neel', "Owner name should be Neel");
        // Assert.equal(account, web3.eth.coinbase(), "Owner address should be 0");        
        var count = lms.getMemberCount();
        Assert.equal(count, 1, "Owner name should be Neel");
    }

    function testAddMember() {
        // string memberList = "\nNeel\nChandan";
        lms.addMember("Chandan", 0x0);
        Assert.equal(lms.getMemberCount(), 2, "Member count should be two.");
        Assert.equal(lms.getMemberList(), "Neel", "Incorrect member list");
    }

//   function testInitialBalanceWithNewMetaCoin() {
//     MetaCoin meta = new MetaCoin();

//     uint expected = 0;

//     Assert.equal(meta.getMemberCount(), expected, "Zero Members");
//   }

}
