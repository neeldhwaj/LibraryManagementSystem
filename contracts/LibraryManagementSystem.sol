pragma solidity ^0.4.0;

import "./strings.sol";
import "zeppelin/ownership/Ownable.sol";
import "zeppelin/lifecycle/Killable.sol";

contract LibraryManagementSystem is Killable{
    address public owner; // Owner public address
    using strings for *; //For using the strings library.

    //enumeration to capture the various states of the book
    enum BookState {
        Available,
        Borrowed,
        Overdue,
        Lost,
        Removed
    }

    //Book Data Structure
    struct Book {
        uint bookID;
        string title;
        string author;
        string publisher;
        BookState bookState;
        address owner;
        uint lastIssueDate;
        uint dueDate;
        uint avgRating;
        address borrower;
    }

    //enumeration to capture the states of the member
    enum MemberStatus {
        Active,
        Inactive
    }

    //Member Data Structure
    struct Member {
        string name;
        address account;
        MemberStatus memberStatus;
        uint dateAdded;
    }

    //State Variables
    uint public totalNumBooks;
    uint public totalNumMembers;
    mapping (uint => Book) public bookCatalog;
    mapping (uint => Member) public memberList;
    mapping (address => uint) public memberIndex;

    //Only owner modifier
    modifier onlyOwner() {
        if(msg.sender != owner) throw;
        _;
    }

    //Only member modifier
    modifier onlyMember() {
        for (var index = 1; index <= totalNumMembers; index++) {
            if (msg.sender == memberList[index].account) {
                bool isMember = true;
                break;
            }
        }
        if (isMember != true) {
            throw;
        } else {
            _;
        }
    }

    //Constructor
    function LibraryManagementSystem(string name) {
        owner = msg.sender;
        //Make owner as first member of the LibraryManagementSystem
        memberList[++totalNumMembers] = Member(name, msg.sender, MemberStatus.Active, now);
        memberIndex[owner] = totalNumMembers;
    }

    //Returns both name and account address
    function getOwner() constant returns (string, address) {
        return (memberList[0].name, memberList[0].account);
    }

    //Add a new member to the memberList
    function addMember(string name, address account) public onlyOwner {
        // var (ownerName, ownerAddress) = getOwner();
        var index = memberIndex[account];

        //Re-Activate member if it exists
        if(index!=0) {
            memberList[index].memberStatus = MemberStatus.Active;
            return;
        }

        //If index is 0; Add the member
        memberList[++totalNumMembers] = Member(name, account, MemberStatus.Active, now);
        memberIndex[account] = totalNumMembers;

        // for (var index = 0; index < totalNumMembers; index++) {
        //     if (memberList[index].account == account) {
        //         bool memberAlreadyAdded = true;
        //     }
        // }
        // if (!memberAlreadyAdded && account!= ownerAddress) {
        //     memberList[totalNumMembers++] = Member(totalNumMembers, name, account, MemberStatus.Active);            
        // }
    }

    //Deactivate Member. When member leaves the organisation. Also call removeBook() associated with the member
    function deactivateMember(address account) public onlyOwner {
        var index = memberIndex[account];

        if (index!=0) {
            memberList[index].memberStatus = MemberStatus.Inactive;
        }
        else {
            throw;
        }

    }

    //Get Member Details
    function getMemberDetails(address account) public onlyMember constant returns(string, address, MemberStatus, uint) {
        var index = memberIndex[account];
        return(memberList[index].name, memberList[index].account, memberList[index].memberStatus, memberList[index].dateAdded);        
    }

    //Get owner Details
    function getOwnerDetails() public constant returns(string, address, MemberStatus, uint){
        getMemberDetails(memberList[1].account);
    }


    //Add a new book to the bookCatalog
    function addBook(string title, string author, string publisher) public onlyMember {
        bookCatalog[++totalNumBooks] = Book({
            bookID: totalNumBooks,
            title: title,
            author: author,
            publisher: publisher,
            bookState: BookState.Available,
            owner: msg.sender,
            lastIssueDate: 0,
            dueDate: 0,
            avgRating: 0,
            borrower: msg.sender
        });
    }

    //Add a new member with Books
    function addMemberWithBooks(string name, string speciallyConstructedBookString, string bookSeparator, string fieldSeparator) {
        //First add a member. Then parse the speciallyConstructedBookString and add book one by one using addBook() functionality
        //Each book is separated by the 'bookSeparator'. And each field of the book is separated by the 'fieldSeparator'.
        //bookSeparator and fieldSeparator can be of user's choice.
        //e.g "Title1 | Author1 | Publisher1 ; Title2 | Author2 | Publisher2"

        memberList[totalNumMembers++] = Member(name, msg.sender, MemberStatus.Active, now); // Added a member.

        //Now adding book(s)
        var books = speciallyConstructedBookString.toSlice();
        var bookSeparatorDelim = bookSeparator.toSlice();
        var booksArray = new string[](books.count(bookSeparatorDelim));
        for (uint index = 0; index < booksArray.length ; index++) {
            var book = books.split(bookSeparatorDelim).toString().toSlice();
            var title = book.split(fieldSeparator.toSlice()).toString();
            var author = book.split(fieldSeparator.toSlice()).toString();
            var publisher = book.toString();
            addBook(title, author, publisher);
        }
    }

    //Get Member Count
    function getMemberCount() constant returns (uint) {
        return totalNumMembers;
    }

    //Get Number of Books
    function getNumberOfBooks() constant returns (uint) {
        return totalNumBooks;
    }

    //Get Member names
    function getMemberList() constant returns (string) {
        string memory memberNames;
        for (var index = 0; index < totalNumMembers; index++) {
            memberNames = (memberNames.toSlice().concat("\n".toSlice())).toSlice().concat((memberList[index].name).toSlice());
        }
        return memberNames;
    }

    //Get Book List. Returns a string with Book titles
    function getBookList() constant returns (string) {
        string memory bookNames = "";
        for (var index = 0; index < totalNumBooks; index++) {
            if ((bookNames.toSlice().contains((bookCatalog[index].title).toSlice())) != true) {
                bookNames = (bookNames.toSlice().concat("\n".toSlice())).toSlice().concat((bookCatalog[index].title).toSlice());
            }
        }
        return bookNames;
    }
    
    //Borrow Book
    function borrowBook(uint bookID) public onlyMember {
        if(bookID<totalNumBooks && bookCatalog[bookID].bookState != BookState.Borrowed) {
            bookCatalog[bookID].bookState = BookState.Borrowed;
            bookCatalog[bookID].borrower = msg.sender;
            bookCatalog[bookID].lastIssueDate = now;
            bookCatalog[bookID].dueDate = bookCatalog[bookID].lastIssueDate + 2592000; //30 days from date of lastIssueDate
        }        
    }
    
    //Return Book
    function returnBook(uint bookID) public onlyMember {
        bookCatalog[bookID].bookState = BookState.Available;
        bookCatalog[bookID].borrower = bookCatalog[bookID].owner;
        bookCatalog[bookID].dueDate = 0;
    }

    //Get Book Details
    function getBookDetails(uint bookID) public onlyMember constant returns(string) {

    }
    
    //Remove book from the catalogue. 
    function removeBook(uint bookID) public onlyOwner {

    }

}