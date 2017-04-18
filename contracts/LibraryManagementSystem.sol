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
        uint memberID;
        string name;
        address account;
        MemberStatus memberStatus;
    }

    //State Variables
    uint public totalNumBooks;
    uint public totalNumMembers;
    mapping (uint => Book) public bookCatalog;
    mapping (uint => Member) public memberList;

    //Only owner modifier
    modifier onlyOwner() {
        if(msg.sender != owner) throw;
        _;
    }

    //Only member modifier
    modifier onlyMember() {
        for (var index = 0; index < totalNumMembers; index++) {
            if (msg.sender == memberList[index].account) {
                bool isMember = true;
            }
        }
        if (isMember != true) throw;
        _;
    }

    //Constructor
    function LibraryManagementSystem(string name) {
        owner = msg.sender;
        //Make owner as first member of the LibraryManagementSystem
        memberList[totalNumMembers++] = Member(totalNumMembers, name, msg.sender, MemberStatus.Active);
    }

    //Returns both name and account address
    function getOwner() constant returns (string, address) {
        return (memberList[0].name, memberList[0].account);
    }

    //Add a new member to the memberList
    function addMember(string name, address account) public onlyMember {
        memberList[totalNumMembers++] = Member(totalNumMembers, name, account, MemberStatus.Active);
    }

    //Add a new book to the bookCatalog
    function addBook(string title, string author, string publisher) public onlyMember {
        bookCatalog[totalNumBooks++] = Book(totalNumBooks, title, author, publisher, BookState.Available, msg.sender, 0, 0, 0, msg.sender);
    }

    //Add a new member with Books
    function addMemberWithBooks(string name, string speciallyConstructedBookString, string bookSeparator, string fieldSeparator) {
        //First add a member. Then parse the speciallyConstructedBookString and add book one by one using addBook() functionality
        //Each book is separated by the 'bookSeparator'. And each field of the book is separated by the 'fieldSeparator'.
        //bookSeparator and fieldSeparator can be of user's choice.
        //e.g "Title1 | Author1 | Publisher1 ; Title2 | Author2 | Publisher2"

        memberList[totalNumMembers++] = Member(totalNumMembers, name, msg.sender, MemberStatus.Active); // Added a member.

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
    function getMemberList() returns (string) {
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
    function borrowBook(uint bookID, uint dueDate) public onlyMember {
        bookCatalog[bookID].bookState = BookState.Borrowed;
        bookCatalog[bookID].borrower = msg.sender;
        bookCatalog[bookID].lastIssueDate = block.timestamp;
        bookCatalog[bookID].dueDate = dueDate;
        
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

    //Get Member Details
    function getMemberDetails(uint memberID) public onlyMember constant returns(string) {

    }
    
    //Deactivate Member. When member leaves the organisation. Also call removeBook() associated with the member
    function deactivateMember(uint memberID) public onlyOwner {

    }

    //Remove book from the catalogue. 
    function removeBook(uint bookID) public onlyOwner {

    }

    //Search a book. Return the book ID and use getBookDetails() to display the string
    function searchBook(string name) public onlyMember returns(uint) {

    }

    //Kill contract
    // function kill() public onlyOwner {
    //     selfdestruct(owner);
    // }
}