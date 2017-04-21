'use strict';
import expectThrow from './helpers/expectThrow';

const LibraryManagementsystem = artifacts.require('../contracts/LibraryManagementSystem.sol');

contract('LibraryManagementsystem', function() {
    let lms;

    beforeEach(async function() {
        lms = await LibraryManagementsystem.new('Neel');
    });

    describe('testConstructor', function() {
        it('Should have one default member - owner', async function() {
            let totalNumberOfMembers = await lms.totalNumMembers();
            assert.equal(totalNumberOfMembers, 1, 'Should have owner as first member');
        });

        it('Should have zero books inititally', async function() {
            let initialNumBooks = await lms.getNumberOfBooks();
            // assert.equal(initialNumBooks, 0);
            assert.isTrue(initialNumBooks == 0);
        });
    });

    describe('addMember', function() {
        it('Should add a member', async function() {
            assert.equal( await lms.getMemberCount(), 1);
            await lms.addMember('Neel P', 0x0);
            assert.equal(await lms.getMemberCount(), 2);
        });

        it('Should not add default member and/or already existing member', async function() {
            let memberCount = await lms.getMemberCount();
            assert.equal(await lms.getMemberCount(), 1);

            await lms.addMember('Neel', web3.eth.coinbase);
            memberCount = await lms.getMemberCount();
            assert.equal(memberCount.valueOf(), 1, 'Member count should still be 1 as owner is already added.')

            await lms.addMember('Sanchit B', 0x0);
            memberCount = await lms.getMemberCount();
            assert.equal(memberCount.valueOf(), 2, 'Two members added');

            await lms.addMember('Sanchit B', 0x0); //Adding duplicate member
            memberCount = await lms.getMemberCount();
            assert.equal(memberCount.valueOf(), 2, "Num of members should still be 2");
        });
    });

    describe ('addBook', function() {
        it('Should add a book', async function() {
            let bookCount = await lms.getNumberOfBooks();
            assert.equal(bookCount, 0);
            await lms.addBook("title", "author", "publisher");
            bookCount = await lms.totalNumBooks();
            assert.equal(bookCount, 1);
        });
    });

    describe ('getMemberDetails', function() {
        it('Should return owner details', async function() {
            let [name, account, memberStatus, dateAdded] = await lms.getMemberDetails(web3.eth.coinbase);
            assert.equal(name, 'Neel');
            assert.equal(account, web3.eth.coinbase);
            assert.equal(memberStatus.valueOf(), 0);
            // console.log(Date.now());
        });

        it('Should return any member details', async function() {
            await lms.addMember("Chandan Kumar", 0x0);
            let [name, account, memberStatus, dateAdded] = await lms.getMemberDetails(0x0);
            assert.equal(name, 'Chandan Kumar');
            assert.equal(account, 0x0);
            assert.equal(memberStatus.valueOf(), 0);

        });
    });

    describe ('getMemberList', function() {
        it.skip('Should return a String with names of all the members', async function() {
            let memberList = '';
            await lms.addMember('NeelP', 0x0 );
            await lms.addMember('SanchitB', 0x1);

            assert.equal(await lms.getMemberCount(), 3, 'Three Members');

            memberList = await lms.getMemberList();
            console.log(memberList);
            assert.equal('\nNeel\nNeelP\nSanchitB', memberList);

        });
    });

    describe ('deactivateMember', function() {
        it('Should deactivate a member when it exists', async function() {
            await lms.addMember('Test1', 0x0);
            let [name, account, memberStatus, dateAdded] = await lms.getMemberDetails(0x0);
            assert.equal(name, 'Test1');
            assert.equal(account, 0x0);
            assert.equal(memberStatus.valueOf(), 0);

            await lms.deactivateMember(0x0);
            [name, account, memberStatus, dateAdded] = await lms.getMemberDetails(0x0);
            assert.equal(name, 'Test1');
            assert.equal(account, 0x0);
            assert.equal(memberStatus.valueOf(), 1);
        });

        it('expect a throw when memeber doesnt exists', async function() {
            await lms.addMember('Test1', 0x0);
            let [name, account, memberStatus, dateAdded] = await lms.getMemberDetails(0x0);
            assert.equal(name, 'Test1');
            assert.equal(account, 0x0);
            assert.equal(memberStatus.valueOf(), 0);

            await lms.deactivateMember(0x0);
            await expectThrow(lms.deactivateMember(0x01));
        });
    });

    // describe('addBook', function() {
    //     it('Should add a book', async function() {
    //         let bookCount = await lms.getNumberOfBooks();
    //         assert.equal(bookCount, 0, 'Should be zero inititally');

    //         await lms.addBook('title1', 'author1', 'publisher1');
    //         bookCount = await lms.getNumberOfBooks();
    //         assert.equal(bookCount, 1, 'Should change to 1')
    //     });
    // });
   
});